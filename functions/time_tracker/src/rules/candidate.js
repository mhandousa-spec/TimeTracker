'use strict';
/**
 * One notification the planner decided is due ("candidate"). It carries
 * everything the runner needs: the marker id (send once), the receiver
 * kind, the gate, the attendance change to write with it, and the variables.
 */

const { markerId } = require('./dedupe');
const { attendanceDocId } = require('./attendance');
const { PAGES } = require('../schema');

/** Events whose notification needs the employee's `Check_In_And_Out` switch. */
const CHECK_IN_GATED = Object.freeze([
  'missed_check_in',
  'missed_check_out',
  'automatic_check_out_applied',
  'shift_start_reminder',
  'shift_end_reminder',
  'late_arrival_recorded',
]);

/**
 * @param {object} p
 * @param {string} p.event            event key (texts.TEMPLATES)
 * @param {object} p.setup            schedule.build*Setup result
 * @param {string} p.dayKey           attendance day the event belongs to
 * @param {number} p.occurrenceMs     the due time (part of the marker id)
 * @param {'employee'|'manager'} [p.receiver]
 * @param {object} [p.vars]           {time: ms} | {minutes: n} | {employeeName: true}
 * @param {object|null} [p.changes]   attendance changes written with it
 * @param {boolean} [p.createDayIfMissing]
 * @param {object|null} [p.leaveCheck] {kind: 'whole_day'} | {kind: 'late', firstCheckInMs}
 * @param {boolean} [p.changesNeedGate] skip the changes too when the gate denies
 */
function makeCandidate(p) {
  const dayId = attendanceDocId(p.setup.email, p.dayKey);
  return {
    event: p.event,
    email: p.setup.email,
    dayKey: p.dayKey,
    dayId,
    subject: dayId,
    occurrenceMs: p.occurrenceMs,
    markerId: markerId(dayId, p.event, p.occurrenceMs),
    receiver: p.receiver || 'employee',
    gate: CHECK_IN_GATED.includes(p.event) ? 'check_in' : null,
    vars: p.vars || {},
    changes: p.changes || null,
    createDayIfMissing: !!p.createDayIfMissing,
    leaveCheck: p.leaveCheck || null,
    changesNeedGate: !!p.changesNeedGate,
    page: PAGES.mainPage,
  };
}

module.exports = { CHECK_IN_GATED, makeCandidate };
