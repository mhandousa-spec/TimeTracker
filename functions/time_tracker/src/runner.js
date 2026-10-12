'use strict';
/**
 * Orchestration — the glue between Firestore and the pure rules. No firebase
 * import: `db` (firebase-admin Firestore), `toTimestamp`, `messaging` and
 * `logger` are injected (tests use an in-memory fake).
 *
 *   runScheduler()        every 5 min: companies → assigned employees → plan →
 *                         claim marker + write notification / alert /
 *                         auto check-out in ONE transaction → FCM push.
 *   onRequestWritten()    Requests/{id} written: pending_approvals to the
 *                         current step's approver(s) with their REAL count.
 *
 * Send-once: every send creates its Notification_Log marker in the same
 * transaction; a second run (overlap, retry, old client sweep with the same
 * id) finds the marker and stays silent. Before writing, the transaction
 * re-reads the attendance day and re-plans: an event that stopped being due
 * (checked out, resumed …) is dropped.
 */

const defaultConfig = require('./config');
const { createData } = require('./data');
const { plainTimestamp } = require('./timestamp');
const { PATHS, PAGES } = require('./schema');
const time = require('./rules/time');
const { parseDay, attendanceDocId } = require('./rules/attendance');
const { planEmployee, upkeepFor } = require('./rules/planner');
const { attendanceWrite } = require('./rules/mutations');
const { isCoveredByLeave, excusesLateArrival } = require('./rules/leaves');
const access = require('./rules/access');
const approvals = require('./rules/approvals');
const { markerId, markerDoc, approverSubject, dailySubject } = require('./rules/dedupe');
const { renderBoth, pendingCountVariables } = require('./texts');
const { notificationDoc, pushMessage } = require('./notifications');

const silentLogger = { info() {}, warn() {}, error() {}, debug() {} };

function createTtlCache(ttlMs, clock) {
  const store = new Map();
  return {
    async get(key, load) {
      const hit = store.get(key);
      if (hit && clock() - hit.at < ttlMs) return hit.value;
      const value = await load();
      store.set(key, { value, at: clock() });
      return value;
    },
    clear() {
      store.clear();
    },
  };
}

function createRunner({
  db,
  toTimestamp = plainTimestamp,
  messaging = null,
  logger = silentLogger,
  config = defaultConfig,
  clock = () => Date.now(),
  planOptions = {},
} = {}) {
  if (!db) throw new Error('createRunner needs a Firestore instance.');
  const data = createData(db);
  const cache = createTtlCache(config.CACHE_MS, clock);
  const options = { lateArrivalOnServer: config.LATE_ARRIVAL_ON_SERVER, ...planOptions };

  /** Per-company lazy loaders (directory / roles cached across warm runs). */
  function companyContext(cid) {
    const memo = new Map();
    const once = (key, load) => {
      if (!memo.has(key)) memo.set(key, load());
      return memo.get(key);
    };
    return {
      directory: () => cache.get(`dir:${cid}`, () => data.loadDirectory(cid)),
      companyTimeZone: () => cache.get(`tz:${cid}`, () => data.loadCompanyTimeZone(cid)),
      access: () => cache.get(`acc:${cid}`, () => data.loadAccess(cid)),
      requestsOf: (email) => once(`req:${email}`, () => data.loadRequestsOf(cid, email)),
      allRequests: () => once('all-requests', () => data.loadAllRequests(cid)),
      template: (key, isReminder = false) => once(`tpl:${key}:${isReminder}`, () => data.loadTemplate(cid, key, isReminder)),
    };
  }

  function variablesFor(candidate, setup, names) {
    const en = {};
    const ar = {};
    const v = candidate.vars || {};
    if (v.time !== undefined) {
      en.time = time.formatClock(v.time, setup.timeZone, 'en');
      ar.time = time.formatClock(v.time, setup.timeZone, 'ar');
    }
    if (v.minutes !== undefined) en.minutes = String(v.minutes);
    if (v.count !== undefined) {
      // KP-TT-011 (9/10/2026): the counted phrase too, in both languages.
      const counted = pendingCountVariables(v.count);
      Object.assign(en, counted.en);
      Object.assign(ar, counted.ar);
    }
    if (v.employeeName && names) {
      en.employeeName = names.en;
      ar.employeeName = names.ar;
    }
    return { en, ar };
  }

  async function push(outcome, template, rendered, receiverEmail, pageKey) {
    if (outcome !== 'sent' || !template.push || !config.FCM_PUSH || !messaging) return false;
    try {
      await messaging.send(pushMessage({ rendered, receiverEmail, pageKey }));
      return true;
    } catch (error) {
      // Push is best-effort: the in-app notification is already stored.
      logger.warn('[time_tracker] push failed', { receiverEmail, error: String(error && error.message) });
      return false;
    }
  }

  /** Send-once write: marker + optional attendance change + optional notification. */
  async function processCandidate(cid, emp, candidate, ctx, nowMs, report) {
    const setup = emp.setup;
    let outcome = 'sent';
    if (candidate.leaveCheck) {
      const requests = await ctx.requestsOf(setup.email);
      const excused =
        candidate.leaveCheck.kind === 'late'
          ? excusesLateArrival(requests, setup.email, candidate.dayKey, setup, candidate.leaveCheck.firstCheckInMs)
          : isCoveredByLeave(requests, setup.email, candidate.dayKey, setup);
      if (excused) outcome = 'on_leave';
    }
    if (outcome === 'sent' && candidate.gate === 'check_in') {
      const [dir, acc] = await Promise.all([ctx.directory(), ctx.access()]);
      if (!access.canCheckInAndOut(acc, dir.byEmail.get(setup.email))) outcome = 'no_permission';
    }
    let receiver = setup.email;
    let names = null;
    if (candidate.receiver === 'manager') {
      const dir = await ctx.directory();
      receiver = access.managerOf(dir, setup.email);
      names = access.employeeNames(dir, setup.email);
      if (receiver === '' && outcome === 'sent') outcome = 'no_receiver';
    }
    const template = await ctx.template(candidate.event);
    if (outcome === 'sent' && !template.enabled) outcome = 'disabled';
    const skipChanges = outcome === 'on_leave' || (outcome === 'no_permission' && candidate.changesNeedGate);

    const markerRef = db.doc(data.markerPath(cid, candidate.markerId));
    const dayRef = db.doc(data.attendancePath(cid, candidate.dayId));
    const result = await db.runTransaction(async (tx) => {
      const marker = await tx.get(markerRef);
      if (marker.exists) return { status: 'already' };
      const daySnap = await tx.get(dayRef);
      const fresh = daySnap.exists ? daySnap.data() : null;
      const days = { ...emp.days, [candidate.dayKey]: parseDay(candidate.dayId, fresh) };
      const replanned = planEmployee({ setup, todayKey: emp.todayKey, days, settings: emp.settings, nowMs, options });
      const current = replanned.candidates.find((c) => c.markerId === candidate.markerId);
      if (!current) return { status: 'stale' };

      if (current.changes && !skipChanges) {
        const write = attendanceWrite({
          id: candidate.dayId,
          doc: fresh,
          setup,
          dayKey: candidate.dayKey,
          changes: current.changes,
          nowMs,
          actor: config.SYSTEM_ACTOR,
          toTimestamp,
          allowCreate: current.createDayIfMissing,
        });
        if (write) {
          if (write.merge) tx.set(dayRef, write.data, { merge: true });
          else tx.set(dayRef, write.data);
        }
      }
      tx.create(
        markerRef,
        markerDoc({
          id: candidate.markerId,
          subject: candidate.subject,
          event: candidate.event,
          occurrenceMs: candidate.occurrenceMs,
          receiverEmail: receiver,
          outcome,
          nowMs,
          actor: config.SYSTEM_ACTOR,
          toTimestamp,
        }),
      );
      let rendered = null;
      if (outcome === 'sent') {
        const vars = variablesFor(current, setup, names);
        rendered = renderBoth(template, vars.en, vars.ar);
        tx.create(
          db.collection(PATHS.notifications(cid)).doc(),
          notificationDoc({
            rendered,
            senderEmail: config.SYSTEM_SENDER,
            receiverEmail: receiver,
            pageKey: current.page,
            nowMs,
          }),
        );
      }
      return { status: 'done', rendered };
    });
    report.count(result.status === 'done' ? outcome : result.status);
    if (result.status === 'done') await push(outcome, template, result.rendered, receiver, candidate.page);
  }

  async function processUpkeep(cid, emp, item, nowMs, report) {
    const ref = db.doc(data.attendancePath(cid, item.dayId));
    const wrote = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) return false;
      const fresh = snap.data();
      const again = upkeepFor({ setup: emp.setup, day: parseDay(item.dayId, fresh), nowMs });
      if (!again) return false;
      const write = attendanceWrite({
        id: item.dayId,
        doc: fresh,
        setup: emp.setup,
        dayKey: item.dayKey,
        changes: again.changes,
        nowMs,
        actor: config.SYSTEM_ACTOR,
        toTimestamp,
      });
      if (!write) return false;
      if (write.merge) tx.set(ref, write.data, { merge: true });
      else tx.set(ref, write.data);
      return true;
    });
    if (wrote) report.count('upkeep');
  }

  function newReport(companyId) {
    const counts = {};
    return {
      companyId,
      counts,
      count(key) {
        counts[key] = (counts[key] || 0) + 1;
      },
    };
  }

  /** One company: every assigned employee, then the daily approvals reminder. */
  async function runCompany(cid) {
    const nowMs = clock();
    const report = newReport(cid);
    const settings = await data.loadSettings(cid);
    const hasHr = await data.loadHasHr(cid);
    const ctx = companyContext(cid);
    const companyTimeZone = await ctx.companyTimeZone();
    const zones = { companyTimeZone, defaultTimeZone: config.DEFAULT_TIME_ZONE };
    const setups = hasHr ? await data.loadHrSetups(cid, zones) : await data.loadTimeTrackerSetups(cid, zones);
    report.employees = setups.length;

    const employees = setups.map((setup) => {
      const todayKey = time.dayKeyOf(nowMs, setup.timeZone);
      const keys = [time.addDays(todayKey, -1), todayKey];
      return { setup, todayKey, keys, ids: keys.map((k) => attendanceDocId(setup.email, k)), settings };
    });
    const stored = await data.loadAttendance(cid, employees.flatMap((e) => e.ids));
    const plans = [];
    for (const emp of employees) {
      emp.days = {};
      emp.keys.forEach((k, i) => {
        emp.days[k] = parseDay(emp.ids[i], stored.get(emp.ids[i]));
      });
      try {
        plans.push({ emp, plan: planEmployee({ setup: emp.setup, todayKey: emp.todayKey, days: emp.days, settings, nowMs, options }) });
      } catch (error) {
        report.count('error');
        logger.error('[time_tracker] plan failed', { cid, email: emp.setup.email, error: String(error && error.stack) });
      }
    }
    const due = plans.flatMap((p) => p.plan.candidates.map((c) => ({ emp: p.emp, c })));
    report.due = due.length;
    const claimed = await data.existingMarkers(cid, due.map((d) => d.c.markerId));
    for (const { emp, c } of due) {
      if (claimed.has(c.markerId)) {
        report.count('already');
        continue;
      }
      try {
        await processCandidate(cid, emp, c, ctx, nowMs, report);
      } catch (error) {
        report.count('error');
        logger.error('[time_tracker] event failed', { cid, marker: c.markerId, error: String(error && error.stack) });
      }
    }
    for (const { emp, plan } of plans) {
      for (const item of plan.upkeep) {
        try {
          await processUpkeep(cid, emp, item, nowMs, report);
        } catch (error) {
          report.count('error');
          logger.error('[time_tracker] upkeep failed', { cid, day: item.dayId, error: String(error && error.stack) });
        }
      }
    }
    try {
      await dailyApprovals(cid, companyTimeZone, nowMs, ctx, report);
    } catch (error) {
      report.count('error');
      logger.error('[time_tracker] daily approvals failed', { cid, error: String(error && error.stack) });
    }
    return report;
  }

  async function sendPendingApprovals({ cid, receivers, counts, isReminder, occurrenceMs, subjectOf, sender, requestId, ctx, nowMs, report, gate }) {
    const template = await ctx.template('pending_approvals', isReminder);
    for (const email of receivers) {
      let outcome = template.enabled ? 'sent' : 'disabled';
      if (outcome === 'sent' && gate && !(await gate(email))) outcome = 'no_permission';
      const subject = subjectOf(email);
      const id = markerId(subject, 'pending_approvals', occurrenceMs);
      const ref = db.doc(data.markerPath(cid, id));
      const count = Math.max(1, counts.get(email) || 0);
      // KP-TT-011 (9/10/2026): "1 request" / "طلب واحد" — never "1 requests".
      const vars = pendingCountVariables(count);
      const rendered = renderBoth(template, vars.en, vars.ar);
      const status = await db.runTransaction(async (tx) => {
        const marker = await tx.get(ref);
        if (marker.exists) return 'already';
        tx.create(
          ref,
          markerDoc({ id, subject, event: 'pending_approvals', occurrenceMs, receiverEmail: email, outcome, nowMs, actor: config.SYSTEM_ACTOR, toTimestamp }),
        );
        if (outcome === 'sent') {
          tx.create(
            db.collection(PATHS.notifications(cid)).doc(),
            notificationDoc({
              rendered,
              senderEmail: sender,
              receiverEmail: email,
              pageKey: PAGES.approvalDetails,
              nowMs,
              requestId: requestId(email),
              isReminder,
            }),
          );
        }
        return 'done';
      });
      report.count(status === 'done' ? outcome : status);
      if (status === 'done') await push(outcome, template, rendered, email, PAGES.approvalDetails);
    }
  }

  /** A1 daily reminder: once a day (from 09:00 company time) for requests waiting > 2 days. */
  async function dailyApprovals(cid, companyTimeZone, nowMs, ctx, report) {
    const tz = time.pickTimeZone(companyTimeZone, config.DEFAULT_TIME_ZONE);
    if (time.zonedParts(nowMs, tz).hour < config.DAILY_APPROVALS_REMINDER_HOUR) return;
    const dayStart = time.dayStartMs(time.dayKeyOf(nowMs, tz), tz);
    const runId = markerId(`daily_${cid}`, 'pending_approvals', dayStart);
    const runRef = db.doc(data.markerPath(cid, runId));
    if ((await runRef.get()).exists) return;

    const requests = await ctx.allRequests();
    const hrSet = approvals.anyWaitingAtHr(requests)
      ? access.hrApproverEmails(await ctx.access(), await ctx.directory())
      : new Set();
    const due = approvals.dailyApprovalReminders(requests, hrSet, nowMs, config.APPROVAL_OVERDUE_AFTER_MINUTES * time.MINUTE_MS);
    if (due.size > 0) {
      const [dir, acc] = await Promise.all([ctx.directory(), ctx.access()]);
      await sendPendingApprovals({
        cid,
        receivers: [...due.keys()],
        counts: new Map([...due].map(([email, r]) => [email, r.count])),
        isReminder: true,
        occurrenceMs: dayStart,
        subjectOf: dailySubject,
        sender: config.SYSTEM_SENDER,
        requestId: (email) => due.get(email).requestId,
        ctx,
        nowMs,
        report,
        gate: async (email) => access.canReceiveApprovalReminder(acc, dir.byEmail.get(email)),
      });
    }
    try {
      await runRef.create(
        markerDoc({ id: runId, subject: `daily_${cid}`, event: 'pending_approvals', occurrenceMs: dayStart, receiverEmail: '', outcome: 'daily_run', nowMs, actor: config.SYSTEM_ACTOR, toTimestamp }),
      );
    } catch (_) {
      // Another run finished first — its per-approver markers already deduped.
    }
  }

  /** Every company (or TT_COMPANY_IDS), one after another; one failure never stops the rest. */
  async function runScheduler() {
    const ids = config.COMPANY_IDS && config.COMPANY_IDS.length > 0 ? config.COMPANY_IDS : await data.listCompanyIds();
    const reports = [];
    for (const cid of ids) {
      try {
        reports.push(await runCompany(cid));
      } catch (error) {
        logger.error('[time_tracker] company failed', { cid, error: String(error && error.stack) });
        reports.push({ companyId: cid, failed: true });
      }
    }
    logger.info('[time_tracker] sweep done', { companies: reports.length, reports });
    return reports;
  }

  /**
   * Requests/{requestId} was written: `pending_approvals` when the request
   * ENTERED a step (Is_Reminder false) or the requester sent a reminder
   * (Is_Reminder true), to the current step's approver(s), each with his REAL
   * pending total.
   */
  async function onRequestWritten({ cid, requestId, before, after, eventTimeMs }) {
    const nowMs = clock();
    const report = newReport(cid);
    const b = approvals.parseRequest(requestId, before);
    const a = approvals.parseRequest(requestId, after);
    const trigger = approvals.pendingApprovalsTrigger(b, a);
    if (!trigger) {
      report.count('no_transition');
      return report;
    }
    const ctx = companyContext(cid);
    const all = approvals.withLatest(await ctx.allRequests(), a);
    const current = approvals.actionableStep(a);
    const needHr = current.step.step === 'hr' || approvals.anyWaitingAtHr(all);
    const hrSet = needHr ? access.hrApproverEmails(await ctx.access(), await ctx.directory()) : new Set();
    const receivers = approvals.stepReceivers(a, hrSet).map((r) => r.email);
    if (receivers.length === 0) {
      report.count('no_receiver');
      return report;
    }
    const counts = new Map(receivers.map((email) => [email, approvals.waitingCount(all, email, hrSet.has(email))]));
    const occurrenceMs = a.updatedMs !== null ? a.updatedMs : Number.isFinite(eventTimeMs) ? eventTimeMs : nowMs;
    await sendPendingApprovals({
      cid,
      receivers,
      counts,
      isReminder: trigger.isReminder,
      occurrenceMs,
      subjectOf: (email) => approverSubject(requestId, email),
      sender: approvals.actorOf(after) || config.SYSTEM_SENDER,
      requestId: () => requestId,
      ctx,
      nowMs,
      report,
      gate: null,
    });
    report.receivers = receivers;
    report.counts = Object.fromEntries(counts);
    return report;
  }

  return { runScheduler, runCompany, onRequestWritten, clearCache: () => cache.clear() };
}

module.exports = { createRunner };
