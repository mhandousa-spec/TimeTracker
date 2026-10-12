'use strict';
/**
 * Automatic check-out (decision 4, B7).
 *
 * A session still open `Settings/general.Auto_Check_Out_After_Minutes`
 * (default 120; ≤ 0 = switched off) after the end of the shift it belongs to
 * is closed by the system:
 *   * recorded check-out = the SHIFT END time (not now);
 *   * `Sessions[].Is_Auto_Check_Out` = true (the badge on the record);
 *   * a running pause / break is closed at that same moment;
 *   * no geofence check (D1 exemption);
 *   * notification automatic_check_out_applied ({{time}} = shift end) +
 *     Alert auto_check_out (Minutes_Over 0).
 * An overnight shift ends the next day. A session started AFTER its day's
 * shift end is extra work: no reminders and no auto check-out (same rule as
 * the client sweep's missed check-out).
 */

const { MINUTE_MS } = require('./time');
const { shiftOn } = require('./schedule');
const { F } = require('../schema');
const { presentName, currentList, toMillis, isPlainObject } = require('../fields');
const { ALERT_TYPES, makeAlert } = require('./alerts');
const { makeCandidate } = require('./candidate');

function autoCheckOutCandidate({ setup, day, session, nowMs, autoCheckOutAfterMinutes }) {
  if (!session || !session.isOpen || !(autoCheckOutAfterMinutes > 0)) return null;
  const shift = shiftOn(setup, day.dayKey);
  if (session.checkInMs > shift.endMs) return null;
  const dueMs = shift.endMs + autoCheckOutAfterMinutes * MINUTE_MS;
  if (nowMs < dueMs) return null;
  return makeCandidate({
    event: 'automatic_check_out_applied',
    setup,
    dayKey: day.dayKey,
    occurrenceMs: session.checkInMs,
    vars: { time: shift.endMs },
    changes: {
      autoCheckOut: { sessionIndex: session.index, checkOutMs: shift.endMs },
      alertsToAdd: [makeAlert(ALERT_TYPES.autoCheckOut, dueMs, 0)],
    },
  });
}

/** Close the running interval of a Pauses / Breaks list at [atMs]; keeps its stored shape. */
function closeOpenIntervals(raw, atMs, toTimestamp) {
  if (raw === undefined || raw === null) return raw;
  const wrapped = isPlainObject(raw) && Array.isArray(raw.Values);
  const list = currentList(raw).map((iv) => {
    if (!isPlainObject(iv)) return iv;
    if (toMillis(iv[F.intervalEnd]) !== null) return iv;
    const start = toMillis(iv[F.intervalStart]);
    const end = start !== null && start > atMs ? start : atMs;
    return { ...iv, [F.intervalEnd]: toTimestamp(end) };
  });
  return wrapped ? { ...raw, Values: list } : list;
}

/**
 * The stored Sessions list with session [sessionIndex] auto-checked-out at
 * [checkOutMs]. Every other key of every session is kept as stored.
 */
function applyAutoCheckOut(rawSessions, sessionIndex, checkOutMs, toTimestamp) {
  return rawSessions.map((raw, i) => {
    if (i !== sessionIndex || !isPlainObject(raw)) return raw;
    const next = { ...raw };
    let key = presentName(next, F.checkOut);
    if (key === null) key = presentName(next, F.checkIn) === F.checkIn[1] ? F.checkOut[1] : F.checkOut[0];
    next[key] = toTimestamp(checkOutMs);
    next[F.isAutoCheckOut] = true;
    if (next[F.pauses] !== undefined) next[F.pauses] = closeOpenIntervals(next[F.pauses], checkOutMs, toTimestamp);
    if (next[F.breaks] !== undefined) next[F.breaks] = closeOpenIntervals(next[F.breaks], checkOutMs, toTimestamp);
    return next;
  });
}

module.exports = { autoCheckOutCandidate, applyAutoCheckOut, closeOpenIntervals };
