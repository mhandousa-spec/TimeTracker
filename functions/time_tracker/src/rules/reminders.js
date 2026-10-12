'use strict';
/**
 * Shift reminders (decision 8) and the missed check-in / check-out /
 * late-arrival rules — port of `TimeTrackerReminderRules`, moved to the server
 * and to the location's time zone (A8, A9, B3, C2, C4).
 *
 * Every rule has a WINDOW so a 5-minute scheduler never reads markers for
 * stale events, and a later step supersedes an earlier one:
 *   shift_start_reminder  [start − 15 min, start)            not checked in, working day
 *   missed_check_in       [start + Late After, shift end)     no session, working day (A8)
 *   shift_end_reminder    [end, end + 30 min)                 still checked in (C4)
 *   missed_check_out      [end + 30 min, end + auto minutes)  still checked in (A9)
 *   automatic check-out   ≥ end + auto minutes                (autoCheckOut.js, B7)
 * Working-week checks need a KNOWN week: HR shifts (decision 9, on hold)
 * skip shift_start_reminder / missed_check_in / absent finalisation.
 * Approved whole-day leave (D3) silences the start reminder and the missed
 * check-in (checked lazily by the runner: `leaveCheck`).
 */

const { MINUTE_MS, minutesBetween } = require('./time');
const { shiftOn, hasStarted } = require('./schedule');
const { isLeaveStatus } = require('./attendance');
const { ALERT_TYPES, makeAlert } = require('./alerts');
const { makeCandidate } = require('./candidate');

const hasSessions = (day) => !!day && day.sessions.length > 0;

/** "Check-In Not Recorded" for the shift starting on [dayKey] ([day] = its stored doc or null). */
function missedCheckIn({ setup, dayKey, day, anyOpenSession, nowMs }) {
  const shift = shiftOn(setup, dayKey);
  if (!shift.isWorkingWeekKnown || !shift.isWorkingDay) return null;
  if (!hasStarted(setup, dayKey)) return null;
  if (nowMs < shift.lateThresholdMs || nowMs >= shift.endMs) return null;
  if (anyOpenSession) return null;
  if (hasSessions(day) || (day && isLeaveStatus(day.status))) return null;
  return makeCandidate({
    event: 'missed_check_in',
    setup,
    dayKey,
    occurrenceMs: shift.lateThresholdMs,
    leaveCheck: { kind: 'whole_day' },
    createDayIfMissing: true,
    changesNeedGate: true,
    changes: { alertsToAdd: [makeAlert(ALERT_TYPES.missedCheckIn, shift.lateThresholdMs, 0)] },
  });
}

/** "Shift Starting Soon", 15 minutes before the shift starting on [dayKey]. */
function shiftStartReminder({ setup, dayKey, day, anyOpenSession, nowMs, leadMinutes }) {
  const shift = shiftOn(setup, dayKey);
  if (!shift.isWorkingWeekKnown || !shift.isWorkingDay) return null;
  if (!hasStarted(setup, dayKey)) return null;
  const dueMs = shift.startMs - leadMinutes * MINUTE_MS;
  if (nowMs < dueMs || nowMs >= shift.startMs) return null;
  if (anyOpenSession || hasSessions(day) || (day && isLeaveStatus(day.status))) return null;
  return makeCandidate({
    event: 'shift_start_reminder',
    setup,
    dayKey,
    occurrenceMs: dueMs,
    leaveCheck: { kind: 'whole_day' },
    vars: { time: shift.startMs },
  });
}

/** The shift of the open session, or null for extra work started after the shift end. */
function shiftOfSession(setup, day, session) {
  if (!session || !session.isOpen) return null;
  const shift = shiftOn(setup, day.dayKey);
  return session.checkInMs > shift.endMs ? null : shift;
}

/** "Shift Ended — Please Check Out", at the shift end while still checked in. */
function shiftEndReminder({ setup, day, session, nowMs, missedAfterMinutes }) {
  const shift = shiftOfSession(setup, day, session);
  if (!shift) return null;
  if (nowMs < shift.endMs || nowMs >= shift.endMs + missedAfterMinutes * MINUTE_MS) return null;
  return makeCandidate({
    event: 'shift_end_reminder',
    setup,
    dayKey: day.dayKey,
    occurrenceMs: shift.endMs,
    vars: { time: shift.endMs },
  });
}

/** "Check-Out Not Recorded", 30 minutes after the shift end while still checked in. */
function missedCheckOut({ setup, day, session, nowMs, missedAfterMinutes, autoCheckOutAfterMinutes }) {
  const shift = shiftOfSession(setup, day, session);
  if (!shift) return null;
  const dueMs = shift.endMs + missedAfterMinutes * MINUTE_MS;
  if (nowMs < dueMs) return null;
  if (autoCheckOutAfterMinutes > 0 && nowMs >= shift.endMs + autoCheckOutAfterMinutes * MINUTE_MS) return null;
  return makeCandidate({
    event: 'missed_check_out',
    setup,
    dayKey: day.dayKey,
    occurrenceMs: dueMs,
    vars: { minutes: missedAfterMinutes },
    changes: { alertsToAdd: [makeAlert(ALERT_TYPES.missedCheckOut, dueMs, 0)] },
  });
}

/**
 * "Late Attendance Recorded" (B3): the FIRST check-in of the day is after
 * start + Late After; {{minutes}} = check-in − shift START (not the grace
 * end). Off-days are never late (`AttendanceCalculator.lateMinutes`). Skipped
 * when the day already holds a late_arrival alert (the app wrote it with the
 * check-in) — so the server never doubles the app.
 */
function lateArrival({ setup, day }) {
  if (!hasSessions(day)) return null;
  const shift = shiftOn(setup, day.dayKey);
  if (!shift.isWorkingDay) return null;
  const first = day.sessions[0].checkInMs;
  if (first <= shift.lateThresholdMs) return null;
  if (day.alerts.some((a) => a.type === ALERT_TYPES.lateArrival)) return null;
  const minutes = minutesBetween(shift.startMs, first);
  return makeCandidate({
    event: 'late_arrival_recorded',
    setup,
    dayKey: day.dayKey,
    occurrenceMs: first,
    leaveCheck: { kind: 'late', firstCheckInMs: first },
    vars: { minutes },
    changes: { alertsToAdd: [makeAlert(ALERT_TYPES.lateArrival, first, minutes)] },
  });
}

/**
 * A day the SERVER created for a missed_check_in alert must not stay
 * undecided: the client absent sweep skips days that have a record. Once the
 * shift has ended with still no session → `Attendance_Status = absent`
 * (`AttendanceCalculator` rule). Never touches a day the app created.
 */
function shouldMarkAbsent({ setup, day, nowMs }) {
  if (!day || hasSessions(day) || day.status !== null) return false;
  if (!day.alerts.some((a) => a.type === ALERT_TYPES.missedCheckIn)) return false;
  const shift = shiftOn(setup, day.dayKey);
  if (!shift.isWorkingWeekKnown || !shift.isWorkingDay) return false;
  return nowMs >= shift.endMs;
}

module.exports = {
  missedCheckIn,
  shiftStartReminder,
  shiftEndReminder,
  missedCheckOut,
  lateArrival,
  shouldMarkAbsent,
  shiftOfSession,
};
