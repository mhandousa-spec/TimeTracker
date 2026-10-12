'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const s = require('../src/rules/schedule');
const { wrap } = require('../src/history');
const { ms, ts, locationDoc, assignmentDoc, historyDoc } = require('./helpers');

test('schedule: location read with the app names (Work_Start_Time …, wrapped Working_Days)', () => {
  const loc = s.parseLocation('loc1', locationDoc({ start: 480, end: 960, days: [7, 1, 2, 3, 4], lateAfter: 10 }));
  assert.equal(loc.startMinutes, 480);
  assert.equal(loc.endMinutes, 960);
  assert.deepEqual(loc.workingDays, [7, 1, 2, 3, 4]);
  assert.equal(loc.lateAfterMinutes, 10);
  assert.equal(loc.timeZone, 'Asia/Riyadh');
  assert.equal(loc.isActive, true);
});

test('schedule: location read with the TARGET names (Work_Start_Minutes, plain Working_Days, Status)', () => {
  const loc = s.parseLocation('loc2', {
    timestamps: [ts('2026-10-01T00:00:00Z')],
    Name_English: ['HQ'],
    Work_Start_Minutes: [600],
    Work_End_Minutes: [1080],
    Working_Days: [6, 7, 1, 2, 3, 4],
    Allowed_Break_Minutes: [30],
    Is_Break_Allowed: [true],
    Status: 'active',
    Time_Zone: ['Africa/Cairo'],
  });
  assert.equal(loc.nameEn, 'HQ');
  assert.equal(loc.startMinutes, 600);
  assert.deepEqual(loc.workingDays, [6, 7, 1, 2, 3, 4]);
  assert.equal(loc.breakMinutes, 30);
  assert.equal(loc.timeZone, 'Africa/Cairo');
});

test('schedule: missing hours default 09:00–17:00, empty days = all 7, removed = inactive', () => {
  const loc = s.parseLocation('x', historyDoc({ Location_Status: 'deleted', Working_Days: wrap([]) }));
  assert.equal(loc.startMinutes, 540);
  assert.equal(loc.endMinutes, 1020);
  assert.deepEqual(loc.workingDays, [1, 2, 3, 4, 5, 6, 7]);
  assert.equal(loc.isActive, false);
});

test('schedule: location holds the DEFAULT rules (Allowed_Break_Minutes / Allowed_Pause_Minutes; legacy Break_Minutes)', () => {
  const loc = s.parseLocation('loc1', locationDoc({ breakAllowed: true, breakMinutes: 30, pauseAllowed: true, pauseMinutes: 20 }));
  assert.deepEqual([loc.breakMinutes, loc.pauseMinutes], [30, 20]);
  const legacy = s.parseLocation('loc1', locationDoc({ breakAllowed: true, breakMinutes: 45, legacyBreakField: true }));
  assert.equal(legacy.breakMinutes, 45);
  assert.equal(legacy.pauseMinutes, 0); // missing Allowed_Pause_Minutes = no pause limit
  const r = s.resolveRules({ location: loc, assignment: s.parseAssignment('a@co.com', assignmentDoc({ email: 'a@co.com' })) });
  assert.equal(r.source, 'location');
  assert.deepEqual([r.rules.isBreakAllowed, r.rules.breakMinutes, r.rules.isPauseAllowed, r.rules.pauseMinutes], [true, 30, true, 20]);
});

test('schedule: Custom_Rules precedence — employee (Is_Custom) → group (Is_Custom) → location', () => {
  const location = s.parseLocation('loc1', locationDoc({ breakAllowed: true, breakMinutes: 30, pauseAllowed: true, pauseMinutes: 20 }));
  const groupDoc = (isCustom) =>
    historyDoc({ Custom_Rules: { Is_Custom: isCustom, Is_Break_Allowed: false, Allowed_Break_Minutes: 0, Is_Pause_Allowed: true, Allowed_Pause_Minutes: 10 }, Is_Deleted: false });

  const own = s.parseAssignment('a@co.com', assignmentDoc({
    email: 'a@co.com',
    groupId: 'g1',
    customRules: { Is_Custom: true, Is_Break_Allowed: true, Allowed_Break_Minutes: 60, Is_Pause_Allowed: false, Allowed_Pause_Minutes: 5 },
  }));
  const byEmployee = s.resolveRules({ location, assignment: own, group: s.parseGroup('g1', groupDoc(true)) });
  assert.equal(byEmployee.source, 'employee');
  assert.deepEqual([byEmployee.rules.breakMinutes, byEmployee.rules.isPauseAllowed, byEmployee.rules.pauseMinutes], [60, false, 0]);

  const member = s.parseAssignment('b@co.com', assignmentDoc({ email: 'b@co.com', groupId: 'g1' }));
  const byGroup = s.resolveRules({ location, assignment: member, group: s.parseGroup('g1', groupDoc(true)) });
  assert.equal(byGroup.source, 'group');
  assert.deepEqual([byGroup.rules.isBreakAllowed, byGroup.rules.breakMinutes, byGroup.rules.pauseMinutes], [false, 0, 10]);

  // Is_Custom false → the map is ignored; a deleted group never applies
  assert.equal(s.resolveRules({ location, assignment: member, group: s.parseGroup('g1', groupDoc(false)) }).source, 'location');
  const deleted = { ...s.parseGroup('g1', groupDoc(true)), isDeleted: true };
  assert.equal(s.resolveRules({ location, assignment: member, group: deleted }).source, 'location');

  // employee Custom_Rules with Is_Custom false → falls through to the group
  const notCustom = s.parseAssignment('c@co.com', assignmentDoc({ email: 'c@co.com', groupId: 'g1', customRules: { Is_Custom: false, Is_Pause_Allowed: false } }));
  assert.equal(s.resolveRules({ location, assignment: notCustom, group: s.parseGroup('g1', groupDoc(true)) }).source, 'group');
});

test('schedule: Custom_Rules without Allowed_Pause_Minutes = no pause limit; history map → last revision', () => {
  const location = s.parseLocation('loc1', locationDoc({ pauseAllowed: true, pauseMinutes: 20 }));
  const a = s.parseAssignment('a@co.com', historyDoc({
    Employee_Email: 'a@co.com',
    Location_Id: 'loc1',
    Custom_Rules: { Is_Custom: true, Is_Pause_Allowed: true },
  }));
  assert.equal(s.resolveRules({ location, assignment: a }).rules.pauseMinutes, 0);
  const twoRevisions = {
    Location_Id: ['loc1', 'loc1'],
    Custom_Rules: [{ Is_Custom: true, Is_Pause_Allowed: true, Allowed_Pause_Minutes: 5 }, { Is_Custom: false }],
  };
  assert.equal(s.resolveRules({ location, assignment: s.parseAssignment('d@co.com', twoRevisions) }).source, 'location');
});

test('schedule: the app\'s legacy FLAT override fields are only a fallback (pause length inherited from the location)', () => {
  const location = s.parseLocation('loc1', locationDoc({ breakAllowed: true, breakMinutes: 30, pauseAllowed: false, pauseMinutes: 25 }));
  const legacy = s.parseAssignment('a@co.com', assignmentDoc({
    email: 'a@co.com',
    legacy: { Is_Custom_Rules: true, Is_Break_Allowed: false, Break_Minutes: 0, Is_Pause_Allowed: true },
  }));
  const r = s.resolveRules({ location, assignment: legacy });
  assert.equal(r.source, 'employee');
  assert.deepEqual([r.rules.isBreakAllowed, r.rules.isPauseAllowed, r.rules.pauseMinutes], [false, true, 25]);
  // missing Is_Custom_Rules on a legacy row = custom (app rule); Is_Custom_Rules false = follow the location
  const followsLocation = s.parseAssignment('b@co.com', assignmentDoc({ email: 'b@co.com', legacy: { Is_Custom_Rules: false, Is_Pause_Allowed: true } }));
  assert.equal(s.resolveRules({ location, assignment: followsLocation }).source, 'location');
  // Custom_Rules wins over leftover flat fields
  const both = s.parseAssignment('c@co.com', assignmentDoc({
    email: 'c@co.com',
    customRules: { Is_Custom: true, Is_Pause_Allowed: false },
    legacy: { Is_Custom_Rules: true, Is_Pause_Allowed: true },
  }));
  assert.equal(s.resolveRules({ location, assignment: both }).rules.isPauseAllowed, false);
});

test('schedule: TT setup — unassigned / inactive location → null; zone fallback location → company → default', () => {
  const location = s.parseLocation('loc1', locationDoc({ timeZone: null }));
  const assignment = s.parseAssignment('a@co.com', assignmentDoc({ email: 'A@Co.com', startDate: '2026-12-01T00:00:00+03:00' }));
  const setup = s.buildTimeTrackerSetup({ assignment, location, companyTimeZone: 'Africa/Cairo', defaultTimeZone: 'Asia/Riyadh' });
  assert.equal(setup.email, 'a@co.com');
  assert.equal(setup.timeZone, 'Africa/Cairo');
  assert.equal(setup.startDateKey, '2026-11-30'); // 00:00 Riyadh = 23:00 Cairo (winter, UTC+2) the day before
  const noCompany = s.buildTimeTrackerSetup({ assignment, location, companyTimeZone: '', defaultTimeZone: 'Asia/Riyadh' });
  assert.equal(noCompany.timeZone, 'Asia/Riyadh');
  const unassigned = s.parseAssignment('b', assignmentDoc({ email: 'b@co.com', locationId: '' }));
  assert.equal(s.buildTimeTrackerSetup({ assignment: unassigned, location, defaultTimeZone: 'Asia/Riyadh' }), null);
  const inactive = s.parseLocation('loc1', locationDoc({ status: 'inactive' }));
  assert.equal(s.buildTimeTrackerSetup({ assignment, location: inactive, defaultTimeZone: 'Asia/Riyadh' }), null);
});

test('schedule: target-schema Is_Deleted assignment = unassigned', () => {
  const a = s.parseAssignment('c@co.com', { Location_Id: ['loc1'], Is_Deleted: true });
  assert.equal(a.isAssigned, false);
});

test('schedule: HR setup — unknown working week (decision 9), grace 0, pause on, no break', () => {
  const shift = s.parseHrShift('sh1', { Id: 'sh1', Location_Ids: ['L1'], Start_Minutes: [480], End_Minutes: [960], Timestamps: [1] });
  const setup = s.buildHrSetup({ email: 'h@co.com', shift, location: null, companyTimeZone: '', defaultTimeZone: 'Asia/Riyadh' });
  assert.equal(setup.schedule.isWorkingWeekKnown, false);
  assert.equal(setup.schedule.lateAfterMinutes, 0);
  assert.equal(setup.rules.isPauseAllowed, true);
  assert.equal(s.breakLimitMinutes(setup), 0);
  assert.equal(s.hrShiftIdOf({ Shift_Id: ['a', 'sh1'] }), 'sh1');
});

test('schedule: shiftOn — day shift, grace, KSA working week', () => {
  const setup = { timeZone: 'Asia/Riyadh', schedule: { startMinutes: 540, endMinutes: 1020, workingDays: [7, 1, 2, 3, 4], lateAfterMinutes: 15, isWorkingWeekKnown: true } };
  const thu = s.shiftOn(setup, '2026-10-08');
  assert.equal(thu.isWorkingDay, true);
  assert.equal(thu.startMs, ms('2026-10-08T06:00:00Z'));
  assert.equal(thu.lateThresholdMs, ms('2026-10-08T06:15:00Z'));
  assert.equal(thu.endMs, ms('2026-10-08T14:00:00Z'));
  assert.equal(s.shiftOn(setup, '2026-10-09').isWorkingDay, false); // Friday
  assert.equal(s.shiftOn(setup, '2026-10-10').isWorkingDay, false); // Saturday
});

test('schedule: shiftOn — overnight shift ends the next day', () => {
  const setup = { timeZone: 'Asia/Riyadh', schedule: { startMinutes: 22 * 60, endMinutes: 6 * 60, workingDays: [1, 2, 3, 4, 5, 6, 7], lateAfterMinutes: 0, isWorkingWeekKnown: true } };
  const shift = s.shiftOn(setup, '2026-10-08');
  assert.equal(shift.isOvernight, true);
  assert.equal(shift.startMs, ms('2026-10-08T19:00:00Z'));
  assert.equal(shift.endMs, ms('2026-10-09T03:00:00Z'));
});

test('schedule: assignment start date gates the day', () => {
  assert.equal(s.hasStarted({ startDateKey: '2026-10-10' }, '2026-10-09'), false);
  assert.equal(s.hasStarted({ startDateKey: '2026-10-10' }, '2026-10-10'), true);
  assert.equal(s.hasStarted({ startDateKey: null }, '2026-10-01'), true);
});
