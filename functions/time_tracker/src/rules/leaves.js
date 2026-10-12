'use strict';
/**
 * Approved leave excuses a day (decision D3) — port of
 * `AbsenceRules.isHeldLeave / coversWholeDay / wholeDayLeaves`, evaluated in
 * the employee's location time zone:
 *   * a held leave = not a transaction, status approved or under_review
 *     (a cancellation review still holds it);
 *   * an all-day request covers every day of its range;
 *   * a partial request covers a day only when it spans that day's whole
 *     shift (code-review finding 8) — a 1-hour permission does not.
 */

const { norm } = require('../fields');
const { dayKeyOf } = require('./time');
const { shiftOn } = require('./schedule');

function isHeldLeave(request) {
  return !!request && !request.isTransaction && (request.status === 'approved' || request.status === 'under_review');
}

/** [request] takes the WHOLE of [dayKey] off for [setup]. */
function coversWholeDay(request, dayKey, setup) {
  if (request.startMs === null || request.endMs === null) return false;
  const tz = setup.timeZone;
  const first = dayKeyOf(request.startMs, tz);
  const last = dayKeyOf(request.endMs, tz);
  if (dayKey < first || dayKey > last) return false;
  if (request.isAllDay) return true;
  const shift = shiftOn(setup, dayKey);
  return request.startMs <= shift.startMs && request.endMs >= shift.endMs;
}

/** Some held leave of [email] covers [dayKey] completely. */
function isCoveredByLeave(requests, email, dayKey, setup) {
  const me = norm(email);
  return (requests || []).some((r) => isHeldLeave(r) && r.requesterEmail === me && coversWholeDay(r, dayKey, setup));
}

/**
 * B3: no late_arrival "on a day covered by approved leave or permission" —
 * a whole-day leave, or a permission overlapping [shift start, first check-in].
 */
function excusesLateArrival(requests, email, dayKey, setup, firstCheckInMs) {
  const me = norm(email);
  const shift = shiftOn(setup, dayKey);
  return (requests || []).some((r) => {
    if (!isHeldLeave(r) || r.requesterEmail !== me || r.startMs === null || r.endMs === null) return false;
    if (coversWholeDay(r, dayKey, setup)) return true;
    return !r.isAllDay && r.startMs <= firstCheckInMs && r.endMs >= shift.startMs;
  });
}

module.exports = { isHeldLeave, coversWholeDay, isCoveredByLeave, excusesLateArrival };
