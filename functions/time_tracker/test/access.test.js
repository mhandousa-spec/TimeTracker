'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const acc = require('../src/rules/access');
const { employeeDoc } = require('./helpers');

const switches = (o) => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, [v]]));

function world() {
  const roles = [
    acc.parseRole('r1', { Role_Id: 'r1', Role_Name: ['Employee'], Status: ['active'], Selected_Modules: ['time_tracker'] }, 'Roles'),
    acc.parseRole('r2', { Role_Id: 'r2', Role_Name: ['HR Officer'], Status: ['active'], Selected_Modules: ['tracking', 'hr'] }, 'Roles'),
    acc.parseRole('r3', { Role_Id: 'r3', Role_Name: ['Old HR'], Status: ['deleted'], Selected_Modules: ['time_tracker'] }, 'Roles'),
    acc.parseRole('r4', { Role_Id: 'r4', Role_Name: ['No TT'], Status: ['active'], Selected_Modules: ['todo'] }, 'Roles'),
  ];
  const byRole = new Map([
    ['r1', switches({ Check_In_Permissions: true, Check_In_And_Out: true })],
    ['r2', switches({ Approval_Permissions: true, Approve_And_Reject: true, Approvals_All_Departments: true, View_Approvals: true })],
    ['r3', switches({ Approval_Permissions: true, Approve_And_Reject: true, Approvals_All_Departments: true })],
    ['r4', switches({ Check_In_Permissions: true, Check_In_And_Out: true })],
  ]);
  const access = acc.buildAccess(roles, byRole);
  const directory = acc.buildDirectory(
    [
      employeeDoc({ id: '1', email: 'Sara@Co.com', first: 'Sara', last: 'Ali', firstAr: 'سارة', lastAr: 'علي', role: 'Employee', supervisor: 'Mona@Co.com' }),
      employeeDoc({ id: '2', email: 'hala@co.com', first: 'Hala', last: 'H', role: 'r2' }), // role stored by ID
      employeeDoc({ id: '3', email: 'old@co.com', first: 'Old', last: 'O', role: 'Old HR' }),
      employeeDoc({ id: '4', email: 'gone@co.com', first: 'Gone', last: 'G', role: 'HR Officer', status: 'terminated' }),
      employeeDoc({ id: '5', email: 'self@co.com', first: 'Self', last: 'S', role: 'No TT', supervisor: 'self@co.com' }),
    ].map((d) => acc.parseEmployee(d.Id, d)),
  );
  return { access, directory };
}

test('access: switches — bool / "true" / history; section master AND leaf', () => {
  assert.equal(acc.isOn([false, true]), true);
  assert.equal(acc.isOn('true'), true);
  assert.equal(acc.isOn(undefined), false);
  assert.equal(acc.hasSwitch({ Check_In_Permissions: [true], Check_In_And_Out: [true] }, 'Check_In_Permissions', 'Check_In_And_Out'), true);
  assert.equal(acc.hasSwitch({ Check_In_Permissions: [false], Check_In_And_Out: [true] }, 'Check_In_Permissions', 'Check_In_And_Out'), false);
  assert.equal(acc.hasSwitch({}, 'Check_In_Permissions', 'Check_In_And_Out'), false); // missing = denied
});

test('access: module alias tracking → time_tracker; modules as flat / nested / wrapped lists', () => {
  assert.equal(acc.canonicalModule('Tracking'), 'time_tracker');
  assert.deepEqual(acc.currentModules({ Selected_Modules: ['a', 'b'] }), ['a', 'b']);
  assert.deepEqual(acc.currentModules({ selectedModules: [{ Values: ['x'] }, { Values: ['time_tracker'] }] }), ['time_tracker']);
  assert.deepEqual(acc.currentModules({ Time_Tracking_Module: true }), ['tracking']);
});

test('access: employees read from nested Employees_Info fields; role matched by name OR id', () => {
  const { access, directory } = world();
  const sara = directory.byEmail.get('sara@co.com');
  assert.equal(sara.nameEn, 'Sara Ali');
  assert.equal(sara.nameAr, 'سارة علي');
  assert.equal(sara.supervisor, 'mona@co.com');
  assert.equal(acc.canCheckInAndOut(access, sara), true);
  assert.equal(acc.canCheckInAndOut(access, directory.byEmail.get('hala@co.com')), false);
  // an unlicensed role grants nothing
  assert.equal(acc.canCheckInAndOut(access, directory.byEmail.get('self@co.com')), false);
  assert.equal(acc.canCheckInAndOut(access, undefined), false);
});

test('access: HR approvers = Approve_And_Reject + All Departments, licensed, not deleted, not hidden', () => {
  const { access, directory } = world();
  assert.deepEqual([...acc.hrApproverEmails(access, directory)], ['hala@co.com']);
  assert.equal(acc.canReceiveApprovalReminder(access, directory.byEmail.get('hala@co.com')), true);
  assert.equal(acc.canReceiveApprovalReminder(access, directory.byEmail.get('sara@co.com')), false);
});

test('access: direct manager from the Org Chart; self-reference = no manager; names fall back', () => {
  const { directory } = world();
  assert.equal(acc.managerOf(directory, 'SARA@co.com'), 'mona@co.com');
  assert.equal(acc.managerOf(directory, 'self@co.com'), '');
  assert.equal(acc.managerOf(directory, 'unknown@co.com'), '');
  assert.deepEqual(acc.employeeNames(directory, 'hala@co.com'), { en: 'Hala H', ar: 'Hala H' });
  assert.deepEqual(acc.employeeNames(directory, 'unknown@co.com'), { en: 'unknown@co.com', ar: 'unknown@co.com' });
});

test('access: plain-history Employees_Info shape is read too', () => {
  const e = acc.parseEmployee('9', { Email: ['old@co.com', 'new@co.com'], Role: 'Employee', Supervisor: ['m@co.com'] });
  assert.equal(e.email, 'new@co.com');
  assert.equal(e.role, 'Employee');
  assert.equal(e.supervisor, 'm@co.com');
});
