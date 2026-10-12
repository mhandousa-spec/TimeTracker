'use strict';
/**
 * Break and Pause limits (decisions 1, 2, 3, 10).
 *
 * BREAK (B1, B2, B8) — `Sessions[].Breaks`, limit = the employee's
 * effective allowed break minutes (location → group custom → employee
 * custom), measured from THIS break's start. The break does NOT stop:
 *   * limit reached             → break_completed (employee), {{time}} = start + limit;
 *   * limit + 5 min grace passed → break_duration_exceeded (employee)
 *                                  + break_policy_violation_manager (direct manager,
 *                                    every time; HR never)
 *                                  + Alert break_exceeded.
 * PAUSE (C1) — `Sessions[].Pauses`, limit = the employee's effective
 * `Allowed_Pause_Minutes` (location default, overridden by a group /
 * employee `Custom_Rules` with Is_Custom true), only when his effective
 * `Is_Pause_Allowed` is on; missing = no limit. Past the limit →
 * pause_duration_exceeded + Alert pause_exceeded. The pause keeps running.
 * Each is sent once per break / pause (marker occurrence = its start).
 */

const { MINUTE_MS, minutesBetween } = require('./time');
const { openIntervalOf } = require('./attendance');
const { breakLimitMinutes, pauseLimitMinutes } = require('./schedule');
const { ALERT_TYPES, makeAlert, hasAlertWithin } = require('./alerts');
const { makeCandidate } = require('./candidate');

/** Break-limit candidates for the open session [session] of [day]. */
function breakCandidates({ setup, day, session, nowMs, graceMinutes }) {
  const limit = breakLimitMinutes(setup);
  const open = openIntervalOf(session.breaks);
  if (!limit || !open) return [];
  const limitMs = open.startMs + limit * MINUTE_MS;
  const exceededAt = limitMs + graceMinutes * MINUTE_MS;
  const out = [];
  if (nowMs >= limitMs) {
    out.push(
      makeCandidate({
        event: 'break_completed',
        setup,
        dayKey: day.dayKey,
        occurrenceMs: open.startMs,
        vars: { time: limitMs },
      }),
    );
  }
  if (nowMs >= exceededAt) {
    out.push(
      makeCandidate({
        event: 'break_duration_exceeded',
        setup,
        dayKey: day.dayKey,
        occurrenceMs: open.startMs,
        changes: {
          alertsToAdd: [makeAlert(ALERT_TYPES.breakExceeded, exceededAt, minutesBetween(limitMs, nowMs))],
        },
      }),
      makeCandidate({
        event: 'break_policy_violation_manager',
        setup,
        dayKey: day.dayKey,
        occurrenceMs: open.startMs,
        receiver: 'manager',
        vars: { employeeName: true, minutes: limit },
      }),
    );
  }
  return out;
}

/** Pause-limit candidate for the open session [session] of [day]. */
function pauseCandidates({ setup, day, session, nowMs }) {
  const allowed = pauseLimitMinutes(setup);
  if (!allowed) return [];
  const open = openIntervalOf(session.pauses);
  if (!open) return [];
  const limitMs = open.startMs + allowed * MINUTE_MS;
  if (nowMs < limitMs) return [];
  return [
    makeCandidate({
      event: 'pause_duration_exceeded',
      setup,
      dayKey: day.dayKey,
      occurrenceMs: open.startMs,
      vars: { minutes: allowed },
      changes: { alertsToAdd: [makeAlert(ALERT_TYPES.pauseExceeded, limitMs, minutesBetween(limitMs, nowMs))] },
    }),
  ];
}

/**
 * Alerts for breaks / pauses that ENDED past their limit before any run saw
 * them open (record only — no notification after the fact).
 */
function missingOverrunAlerts({ setup, day, graceMinutes }) {
  const breakLimit = breakLimitMinutes(setup);
  const pauseLimit = pauseLimitMinutes(setup);
  const out = [];
  for (const s of day.sessions) {
    for (const iv of s.breaks) {
      if (!breakLimit || iv.endMs === null) continue;
      const at = iv.startMs + (breakLimit + graceMinutes) * MINUTE_MS;
      if (iv.endMs < at || hasAlertWithin(day.alerts, ALERT_TYPES.breakExceeded, iv.startMs, iv.endMs)) continue;
      out.push(makeAlert(ALERT_TYPES.breakExceeded, at, Math.max(0, minutesBetween(iv.startMs, iv.endMs) - breakLimit)));
    }
    for (const iv of s.pauses) {
      if (!pauseLimit || iv.endMs === null) continue;
      const at = iv.startMs + pauseLimit * MINUTE_MS;
      if (iv.endMs < at || hasAlertWithin(day.alerts, ALERT_TYPES.pauseExceeded, iv.startMs, iv.endMs)) continue;
      out.push(makeAlert(ALERT_TYPES.pauseExceeded, at, Math.max(0, minutesBetween(iv.startMs, iv.endMs) - pauseLimit)));
    }
  }
  return out;
}

module.exports = { breakCandidates, pauseCandidates, missingOverrunAlerts };
