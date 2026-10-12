'use strict';
/**
 * Who is who: the employee directory (`Employees_Info`), roles
 * (`Roles` + `Subscription_Admin`) and their Time Tracker switches
 * (`time_tracker_module_permissions/{roleId}`).
 *
 * Port of `RoleApproverDirectory`, `RoleHistoryModel.fromMap` (names /
 * modules / status), `ModuleNameAliases.canonical` and the permission rule
 * "a leaf works only when its section master is on as well". A switch is a
 * bool, 'true', or a history list whose last entry is current. A missing
 * switch = denied (the app's rule). An employee holds a role when his `Role`
 * equals the role's id OR name (both spellings exist in tenant data).
 */

const { PERMISSIONS } = require('../schema');
const { str, norm, nestedCurrent, isPlainObject } = require('../fields');

/** Statuses that hide an employee (`EmployeeDirectoryRepositoryImpl`). */
const HIDDEN_STATUSES = Object.freeze(['inactive', 'deleted', 'disabled', 'terminated']);

const MODULE_ALIASES = Object.freeze({ tracking: 'time_tracker', 'time-tracker': 'time_tracker', 'time tracker': 'time_tracker' });

function canonicalModule(name) {
  const key = String(name || '').trim().toLowerCase();
  return MODULE_ALIASES[key] || key;
}

/** `RoleApproverDirectory.isOn`. */
function isOn(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') return value.toLowerCase() === 'true';
  if (Array.isArray(value) && value.length > 0) return isOn(value[value.length - 1]);
  return false;
}

function lastString(raw) {
  if (Array.isArray(raw)) {
    for (let i = raw.length - 1; i >= 0; i--) if (typeof raw[i] === 'string') return raw[i];
    return '';
  }
  return str(raw);
}

/** `Selected_Modules` / `selectedModules`: flat list, list of lists, or wrapped history. */
function currentModules(data) {
  const raw = data.Selected_Modules !== undefined ? data.Selected_Modules : data.selectedModules;
  if (raw === undefined || raw === null) {
    return data.Time_Tracking_Module !== undefined ? ['tracking'] : [];
  }
  if (!Array.isArray(raw) || raw.length === 0) return [];
  const last = raw[raw.length - 1];
  if (Array.isArray(last)) return last.filter((m) => typeof m === 'string');
  if (isPlainObject(last) && Array.isArray(last.Values)) return last.Values.filter((m) => typeof m === 'string');
  return raw.filter((m) => typeof m === 'string');
}

/** One role document → {id, keys (lower id + name), deleted, licensed}. */
function parseRole(docId, data, collection) {
  const d = data || {};
  const id = str(d.Role_Id) || docId;
  const nameRaw = d.Role_Name !== undefined ? d.Role_Name : d.Name !== undefined ? d.Name : d.Access_Name !== undefined ? d.Access_Name : d.roleName;
  const name = lastString(nameRaw) || docId;
  const status = lastString(d.Status).toLowerCase();
  return {
    id,
    name,
    keys: [...new Set([id, name].map((k) => String(k || '').trim().toLowerCase()).filter(Boolean))],
    // `getUnDeletedRoles`: only the `Roles` collection is filtered on status.
    deleted: collection === 'Roles' && status === 'deleted',
    licensed: currentModules(d).some((m) => canonicalModule(m) === 'time_tracker'),
  };
}

/** A section master AND its leaf are on. */
function hasSwitch(switches, section, leaf) {
  const s = switches || {};
  return isOn(s[section]) && (leaf === null || leaf === undefined || isOn(s[leaf]));
}

/** One `Employees_Info` document → directory entry. */
function parseEmployee(docId, data) {
  const d = data || {};
  const join = (a, b) => `${str(a).trim()} ${str(b).trim()}`.trim();
  return {
    id: str(nestedCurrent(d, 'Id')) || docId,
    email: norm(nestedCurrent(d, 'Email')),
    nameEn: join(nestedCurrent(d, 'First_Name'), nestedCurrent(d, 'Last_Name')),
    nameAr: join(nestedCurrent(d, 'First_Name_In_Arabic'), nestedCurrent(d, 'Last_Name_In_Arabic')),
    role: str(nestedCurrent(d, 'Role')).trim(),
    status: str(nestedCurrent(d, 'Status')).trim().toLowerCase(),
    supervisor: norm(nestedCurrent(d, 'Supervisor')),
    departmentId: str(nestedCurrent(d, 'Department_Id')).trim(),
  };
}

/** Directory indexes: byEmail (first wins, like the app) and byId. */
function buildDirectory(employees) {
  const byEmail = new Map();
  const byId = new Map();
  for (const e of employees) {
    if (e.id) byId.set(e.id, e);
    if (e.email && !byEmail.has(e.email)) byEmail.set(e.email, e);
  }
  return { byEmail, byId };
}

const isHidden = (employee) => HIDDEN_STATUSES.includes(employee.status);

/**
 * The access index: role key → switches of every LICENSED, non-deleted role
 * holding that key (several roles can share a key; any one granting wins).
 */
function buildAccess(roles, switchesByRoleId) {
  const byKey = new Map();
  for (const role of roles) {
    if (role.deleted || !role.licensed) continue;
    const switches = switchesByRoleId.get(role.id) || {};
    for (const key of role.keys) {
      if (!byKey.has(key)) byKey.set(key, []);
      byKey.get(key).push(switches);
    }
  }
  return { byKey };
}

/** Does [employee] (directory entry) hold section/leaf through his role? */
function employeeHas(access, employee, section, leaf) {
  if (!access || !employee) return false;
  const list = access.byKey.get(String(employee.role || '').trim().toLowerCase()) || [];
  return list.some((switches) => hasSwitch(switches, section, leaf));
}

const canCheckInAndOut = (access, employee) =>
  employeeHas(access, employee, PERMISSIONS.checkInSection, PERMISSIONS.checkInAndOut);

const canReceiveApprovalReminder = (access, employee) =>
  employeeHas(access, employee, PERMISSIONS.approvalsSection, PERMISSIONS.viewApprovals) &&
  employeeHas(access, employee, PERMISSIONS.approvalsSection, PERMISSIONS.approveAndReject);

/**
 * HR approvers (FINAL SPEC): `Approve_And_Reject` + `Approvals_All_Departments`
 * through a licensed role; hidden employees excluded.
 */
function hrApproverEmails(access, directory) {
  const out = new Set();
  for (const e of directory.byEmail.values()) {
    if (isHidden(e)) continue;
    const list = access.byKey.get(e.role.toLowerCase()) || [];
    const ok = list.some(
      (s) =>
        hasSwitch(s, PERMISSIONS.approvalsSection, PERMISSIONS.approveAndReject) &&
        hasSwitch(s, PERMISSIONS.approvalsSection, PERMISSIONS.approvalsAllDepartments),
    );
    if (ok) out.add(e.email);
  }
  return out;
}

/** The employee's direct manager (Org Chart `Supervisor`), '' when none / self. */
function managerOf(directory, email) {
  const me = norm(email);
  const e = directory.byEmail.get(me);
  const manager = e ? e.supervisor : '';
  return manager === me ? '' : manager;
}

/** `{{employeeName}}` in both languages (falls back to the other, then the email). */
function employeeNames(directory, email) {
  const e = directory ? directory.byEmail.get(norm(email)) : null;
  const en = e ? e.nameEn || e.nameAr : '';
  const ar = e ? e.nameAr || e.nameEn : '';
  return { en: en || norm(email), ar: ar || norm(email) };
}

module.exports = {
  HIDDEN_STATUSES,
  canonicalModule,
  isOn,
  currentModules,
  parseRole,
  hasSwitch,
  parseEmployee,
  buildDirectory,
  isHidden,
  buildAccess,
  employeeHas,
  canCheckInAndOut,
  canReceiveApprovalReminder,
  hrApproverEmails,
  managerOf,
  employeeNames,
};
