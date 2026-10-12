'use strict';
/**
 * The scheduler's decision for ONE employee at ONE instant — pure.
 *
 * Inputs: his work set-up (schedule.js), his stored attendance days for
 * YESTERDAY and TODAY in his location's time zone (an overnight session
 * lives in yesterday's document), the company settings and `now`.
 * Output:
 *   * candidates — notifications that are due now (each with its marker id,
 *     receiver kind, gate and the attendance change written with it);
 *   * upkeep     — record-only fixes per day: final `Minutes_Over` of ended
 *     overruns, alerts for overruns that ended between runs, and `absent`
 *     on a day the server created for a missed check-in.
 * The runner re-runs this on the fresh document inside each transaction, so
 * a candidate that stopped being due (the employee resumed, checked out…) is
 * dropped instead of sent.
 */

const config = require('../config');
const { addDays } = require('./time');
const { openSessionOf } = require('./attendance');
const { breakLimitMinutes, pauseLimitMinutes } = require('./schedule');
const { finalOverrunUpdates } = require('./alerts');
const { breakCandidates, pauseCandidates, missingOverrunAlerts } = require('./breaks');
const { autoCheckOutCandidate } = require('./autoCheckOut');
const {
  missedCheckIn,
  shiftStartReminder,
  shiftEndReminder,
  missedCheckOut,
  lateArrival,
  shouldMarkAbsent,
} = require('./reminders');

const defaults = Object.freeze({
  leadMinutes: config.SHIFT_START_REMINDER_LEAD_MINUTES,
  missedAfterMinutes: config.MISSED_CHECK_OUT_AFTER_MINUTES,
  graceMinutes: config.BREAK_EXCEEDED_GRACE_MINUTES,
  lateArrivalOnServer: config.LATE_ARRIVAL_ON_SERVER,
});

/**
 * @param {object} p
 * @param {object} p.setup         work set-up
 * @param {string} p.todayKey      today in the setup's zone
 * @param {object} p.days          dayKey → parsed day (attendance.parseDay) | null
 * @param {object} p.settings      rules/settings.parseSettings
 * @param {number} p.nowMs
 * @param {object} [p.options]     overrides of `defaults`
 */
function planEmployee({ setup, todayKey, days, settings, nowMs, options = {} }) {
  const o = { ...defaults, ...options };
  const yesterdayKey = addDays(todayKey, -1);
  const tomorrowKey = addDays(todayKey, 1);
  const dayOf = (key) => (days && days[key]) || null;
  const today = dayOf(todayKey);
  const yesterday = dayOf(yesterdayKey);
  const candidates = [];
  const push = (c) => {
    if (c) candidates.push(c);
  };

  // The running session: today's, else yesterday's (overnight) — like the client sweep.
  let openDay = null;
  let open = openSessionOf(today);
  if (open) openDay = today;
  else {
    open = openSessionOf(yesterday);
    if (open) openDay = yesterday;
  }

  if (open) {
    push(shiftEndReminder({ setup, day: openDay, session: open, nowMs, missedAfterMinutes: o.missedAfterMinutes }));
    push(
      missedCheckOut({
        setup,
        day: openDay,
        session: open,
        nowMs,
        missedAfterMinutes: o.missedAfterMinutes,
        autoCheckOutAfterMinutes: settings.autoCheckOutAfterMinutes,
      }),
    );
    push(
      autoCheckOutCandidate({
        setup,
        day: openDay,
        session: open,
        nowMs,
        autoCheckOutAfterMinutes: settings.autoCheckOutAfterMinutes,
      }),
    );
    candidates.push(...breakCandidates({ setup, day: openDay, session: open, nowMs, graceMinutes: o.graceMinutes }));
    candidates.push(...pauseCandidates({ setup, day: openDay, session: open, nowMs }));
  }

  for (const key of [yesterdayKey, todayKey]) {
    push(missedCheckIn({ setup, dayKey: key, day: dayOf(key), anyOpenSession: !!open, nowMs }));
  }
  for (const key of [todayKey, tomorrowKey]) {
    push(
      shiftStartReminder({ setup, dayKey: key, day: dayOf(key), anyOpenSession: !!open, nowMs, leadMinutes: o.leadMinutes }),
    );
  }
  if (o.lateArrivalOnServer) {
    for (const day of [yesterday, today]) if (day && day.dayKey) push(lateArrival({ setup, day }));
  }

  const upkeep = [];
  for (const day of [yesterday, today]) {
    if (!day || !day.dayKey) continue;
    const item = upkeepFor({ setup, day, nowMs, graceMinutes: o.graceMinutes });
    if (item) upkeep.push(item);
  }
  return { candidates, upkeep };
}

/** Record-only fixes of one stored day (null when nothing to do). */
function upkeepFor({ setup, day, nowMs, graceMinutes = defaults.graceMinutes }) {
  const limits = { breakMinutes: breakLimitMinutes(setup), pauseMinutes: pauseLimitMinutes(setup) };
  const alertUpdates = finalOverrunUpdates(day.sessions, day.alerts, limits);
  const alertsToAdd = missingOverrunAlerts({ setup, day, graceMinutes });
  const markAbsent = shouldMarkAbsent({ setup, day, nowMs });
  if (alertUpdates.length === 0 && alertsToAdd.length === 0 && !markAbsent) return null;
  return {
    dayKey: day.dayKey,
    dayId: day.id,
    changes: { alertUpdates, alertsToAdd, markAbsent },
  };
}

module.exports = { planEmployee, upkeepFor, defaults };
