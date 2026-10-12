'use strict';
/**
 * Test helpers: an in-memory Firestore with the subset of the firebase-admin
 * API the runner uses (doc / collection / where / listDocuments / getAll /
 * runTransaction / create / set {merge}), and builders for app-shaped
 * (indexed-history) documents. No firebase package needed.
 */

const { PlainTimestamp } = require('../src/timestamp');
const { appendRow, wrap } = require('../src/history');

const ms = (iso) => {
  const t = Date.parse(iso);
  if (Number.isNaN(t)) throw new Error(`bad date ${iso}`);
  return t;
};
const ts = (iso) => PlainTimestamp.fromMillis(typeof iso === 'number' ? iso : ms(iso));

function clone(v) {
  if (Array.isArray(v)) return v.map(clone);
  if (v && typeof v === 'object' && (Object.getPrototypeOf(v) === Object.prototype || Object.getPrototypeOf(v) === null)) {
    const out = {};
    for (const [k, x] of Object.entries(v)) out[k] = clone(x);
    return out;
  }
  return v;
}

function equal(a, b) {
  if (a && typeof a.toMillis === 'function' && b && typeof b.toMillis === 'function') return a.toMillis() === b.toMillis();
  return a === b;
}

class Snap {
  constructor(ref, data) {
    this.ref = ref;
    this.id = ref.id;
    this.exists = data !== undefined;
    this._data = data;
  }
  data() {
    return this.exists ? clone(this._data) : undefined;
  }
}

class DocRef {
  constructor(db, path) {
    this.db = db;
    this.path = path;
    this.id = path.split('/').pop();
  }
  async get() {
    this.db.reads++;
    return new Snap(this, this.db.store.get(this.path));
  }
  async set(data, opts) {
    this.db._write(this.path, data, opts && opts.merge);
  }
  async create(data) {
    if (this.db.store.has(this.path)) {
      const e = new Error(`ALREADY_EXISTS: ${this.path}`);
      e.code = 6;
      throw e;
    }
    this.db._write(this.path, data, false);
  }
  collection(sub) {
    return new CollRef(this.db, `${this.path}/${sub}`);
  }
}

class Query {
  constructor(db, path, filters = []) {
    this.db = db;
    this.path = path;
    this.filters = filters;
  }
  where(field, op, value) {
    return new Query(this.db, this.path, [...this.filters, { field, op, value }]);
  }
  async get() {
    const depth = this.path.split('/').length + 1;
    const docs = [];
    for (const [p, data] of this.db.store) {
      if (!p.startsWith(`${this.path}/`) || p.split('/').length !== depth) continue;
      const ok = this.filters.every(({ field, op, value }) => {
        const v = data[field];
        if (op === 'array-contains') return Array.isArray(v) && v.some((x) => equal(x, value));
        if (op === '==') return equal(v, value);
        throw new Error(`op ${op} not supported by the fake`);
      });
      if (ok) {
        this.db.reads++;
        docs.push(new Snap(new DocRef(this.db, p), data));
      }
    }
    docs.sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
    return { docs, empty: docs.length === 0, size: docs.length };
  }
}

class CollRef extends Query {
  constructor(db, path) {
    super(db, path, []);
    this.id = path.split('/').pop();
  }
  doc(id) {
    const docId = id === undefined ? `auto${String(++this.db.autoId).padStart(5, '0')}` : id;
    return new DocRef(this.db, `${this.path}/${docId}`);
  }
  async listDocuments() {
    const depth = this.path.split('/').length + 1;
    const ids = new Set();
    for (const p of this.db.store.keys()) {
      if (!p.startsWith(`${this.path}/`)) continue;
      ids.add(p.split('/').slice(0, depth).join('/'));
    }
    return [...ids].sort().map((p) => new DocRef(this.db, p));
  }
}

class Tx {
  constructor(db) {
    this.db = db;
    this.ops = [];
  }
  async get(ref) {
    return ref.get();
  }
  set(ref, data, opts) {
    this.ops.push(() => this.db._write(ref.path, data, opts && opts.merge));
  }
  create(ref, data) {
    this.ops.push(() => {
      if (this.db.store.has(ref.path)) throw new Error(`ALREADY_EXISTS: ${ref.path}`);
      this.db._write(ref.path, data, false);
    });
  }
}

class FakeFirestore {
  constructor() {
    this.store = new Map();
    this.autoId = 0;
    this.reads = 0;
    this.transactions = 0;
  }
  doc(path) {
    return new DocRef(this, path);
  }
  collection(path) {
    return new CollRef(this, path);
  }
  async getAll(...refs) {
    return Promise.all(refs.map((r) => r.get()));
  }
  async runTransaction(fn) {
    this.transactions++;
    const tx = new Tx(this);
    const result = await fn(tx);
    for (const op of tx.ops) op();
    return result;
  }
  _write(path, data, merge) {
    const next = merge && this.store.has(path) ? { ...this.store.get(path), ...clone(data) } : clone(data);
    this.store.set(path, next);
  }
  /** Seed a document. */
  put(path, data) {
    this.store.set(path, clone(data));
  }
  /** Raw stored data (or undefined). */
  get(path) {
    return this.store.get(path);
  }
  /** Docs directly under a collection: [{id, data}]. */
  list(path) {
    const depth = path.split('/').length + 1;
    return [...this.store.entries()]
      .filter(([p]) => p.startsWith(`${path}/`) && p.split('/').length === depth)
      .map(([p, data]) => ({ id: p.split('/').pop(), data }))
      .sort((a, b) => (a.id < b.id ? -1 : 1));
  }
}

class FakeMessaging {
  constructor() {
    this.sent = [];
  }
  async send(message) {
    this.sent.push(message);
    return `msg${this.sent.length}`;
  }
}

/** A one-row app-codec document. */
function historyDoc(values, atIso = '2026-10-01T06:00:00Z') {
  return appendRow(null, values, ms(atIso));
}

/** Session map in the app's CURRENT shape. */
function session({ checkIn, checkOut = null, pauses = [], breaks = [], locationId = 'loc1', extra = {} }) {
  const s = {
    Check_In_Date_Time: ts(checkIn),
    Check_Out_Date_Time: checkOut === null ? null : ts(checkOut),
    Work_Location_Id: locationId,
    Work_Location_Type: 'office',
    Check_In_Latitude: 24.7136,
    Check_In_Longitude: 46.6753,
    Pauses: pauses.map(([s0, e0]) => ({ Start: ts(s0), End: e0 === null ? null : ts(e0) })),
    ...extra,
  };
  if (breaks.length > 0) {
    s.Breaks = breaks.map(([s0, e0]) => ({ Break_Type: 'lunch', Start: ts(s0), End: e0 === null ? null : ts(e0) }));
  }
  return s;
}

/** An `Attendance/{email}_{day}` document as the app writes it today. */
function attendanceDoc({ email, dayKey, sessions = [], status = 'present', alerts = null, at = '2026-10-01T06:00:00Z' }) {
  const values = {
    Attendance_Id: `${email}_${dayKey}`,
    Employee_Email: email,
    Attendance_Date: ts(`${dayKey}T00:00:00+03:00`),
    Sessions: wrap(sessions),
    Attendance_Status: sessions.length === 0 && status === 'present' ? null : status,
    Late_Minutes: 0,
    Break_Minutes: 0,
    Total_Work_Minutes: 0,
    Is_Corrected_By_Transaction: false,
    Source_Request_Id: '',
    Created_By: email,
    Creation_Date: ts(at),
    Modified_By: email,
  };
  if (alerts) values.Alerts = wrap(alerts);
  return historyDoc(values, at);
}

/**
 * `Locations/{id}` — the location holds the DEFAULT break / pause rules
 * (approved schema: Allowed_Break_Minutes, Allowed_Pause_Minutes);
 * `legacyBreakField` writes the app's old `Break_Minutes` name instead.
 */
function locationDoc({
  start = 540,
  end = 1020,
  days = [7, 1, 2, 3, 4],
  lateAfter = 15,
  breakAllowed = false,
  breakMinutes = 0,
  pauseAllowed = false,
  pauseMinutes = null,
  timeZone = 'Asia/Riyadh',
  status = 'active',
  name = 'Main Office',
  legacyBreakField = false,
} = {}) {
  const values = {
    Location_Id: 'loc1',
    Name_En: name,
    Name_Ar: 'المكتب الرئيسي',
    Work_Start_Time: start,
    Work_End_Time: end,
    Working_Days: wrap(days),
    Late_After_Minutes: lateAfter,
    Is_Break_Allowed: breakAllowed,
    [legacyBreakField ? 'Break_Minutes' : 'Allowed_Break_Minutes']: breakMinutes,
    Is_Pause_Allowed: pauseAllowed,
    Location_Status: status,
  };
  if (pauseMinutes !== null) values.Allowed_Pause_Minutes = pauseMinutes;
  if (timeZone !== null) values.Time_Zone = timeZone;
  return historyDoc(values);
}

/**
 * `Location_Assignments/{email}` (approved schema): optional history map
 * `Custom_Rules` {Is_Custom, Is_Break_Allowed, Allowed_Break_Minutes,
 * Is_Pause_Allowed, Allowed_Pause_Minutes}. `legacy` writes the app's old
 * flat fields (Is_Custom_Rules / Is_Break_Allowed / Break_Minutes / Is_Pause_Allowed).
 */
function assignmentDoc({ email, locationId = 'loc1', customRules = null, legacy = null, groupId = '', startDate = null }) {
  const values = {
    Location_Assignment_Id: email,
    Employee_Email: email,
    Location_Id: locationId,
    Start_Date: startDate ? ts(startDate) : null,
    Is_Different_Location_Allowed: false,
    Allowed_Location_Ids: wrap([]),
    Group_Id: groupId,
  };
  if (customRules) values.Custom_Rules = customRules;
  if (legacy) Object.assign(values, legacy);
  return historyDoc(values);
}

/** `Employees_Info/{id}` (nested per-field history like the HR writer). */
function employeeDoc({ id, email, first, last, firstAr = '', lastAr = '', role = '', supervisor = '', status = 'active', departmentId = '' }) {
  const f = (key, value) => ({ [key]: [value], Timestamp: [ts('2026-01-01T00:00:00Z')] });
  return {
    Id: id,
    Email: f('Email', email),
    First_Name: f('First_Name', first),
    Last_Name: f('Last_Name', last),
    First_Name_In_Arabic: f('First_Name_In_Arabic', firstAr),
    Last_Name_In_Arabic: f('Last_Name_In_Arabic', lastAr),
    Role: f('Role', role),
    Supervisor: f('Supervisor', supervisor),
    Status: f('Status', status),
    Department_Id: f('Department_Id', departmentId),
  };
}

/** A request document as the app writes it (one history row). */
function requestDoc({
  requester,
  status = 'pending',
  steps = [],
  start = '2026-10-15T00:00:00+03:00',
  end = '2026-10-15T23:59:00+03:00',
  allDay = true,
  isTransaction = false,
  createdAt = '2026-10-01T06:00:00Z',
  lastReminder = null,
  modifiedBy = null,
  writeAt = null,
}) {
  return historyDoc(
    {
      Request_Id: 'x',
      Requester_Email: requester,
      Requester_Department_Id: '',
      Request_Type_Id: isTransaction ? '' : 'rt1',
      Is_Transaction: isTransaction,
      Description: '',
      Start_Date_Time: ts(start),
      End_Date_Time: ts(end),
      Is_All_Day: allDay,
      Total_Minutes: 1440,
      Attachments: wrap([]),
      Request_Status: status,
      Approval_Steps: wrap(
        steps.map((s) => ({
          Step: s.step,
          Approver_Email: s.approver || '',
          Decision: s.decision || 'pending',
          Decision_Date_Time: s.decidedAt ? ts(s.decidedAt) : null,
          Reason: '',
          Is_Cancellation_Step: !!s.cancel,
        })),
      ),
      Current_Step: null,
      Cancellation_Reason: '',
      Last_Reminder_Date_Time: lastReminder ? ts(lastReminder) : null,
      // 9 Oct 2026 (data model): no Comments field — comments live in
      // Requests/{id}/Comments/{commentId}; the server never reads them.
      Created_By: requester,
      Creation_Date: ts(createdAt),
      Modified_By: modifiedBy || requester,
    },
    writeAt || createdAt,
  );
}

/** Role + its Time Tracker switches. */
function seedRole(db, cid, { id, name, switches, modules = ['time_tracker'], status = 'active' }) {
  db.put(`Demo/${cid}/Roles/${id}`, { Role_Id: id, Role_Name: [name], Status: [status], Selected_Modules: modules });
  const s = {};
  for (const [k, v] of Object.entries(switches)) s[k] = [v];
  db.put(`Demo/${cid}/time_tracker_module_permissions/${id}`, { Role_Id: id, timestamps: [1], ...s });
}

const ALL_SWITCHES = Object.freeze({
  Check_In_Permissions: true,
  Check_In_And_Out: true,
  Approval_Permissions: true,
  View_Approvals: true,
  Approve_And_Reject: true,
  Approvals_All_Departments: false,
});

/** The basic setup object (as schedule.buildTimeTrackerSetup returns). */
function setupFor({
  email = 'sara@co.com',
  timeZone = 'Asia/Riyadh',
  start = 540,
  end = 1020,
  days = [7, 1, 2, 3, 4],
  lateAfter = 15,
  known = true,
  rules = {},
  startDateKey = null,
} = {}) {
  return {
    owner: 'time_tracker',
    email,
    locationId: 'loc1',
    timeZone,
    schedule: { startMinutes: start, endMinutes: end, workingDays: days, lateAfterMinutes: lateAfter, isWorkingWeekKnown: known },
    rules: {
      isBreakAllowed: false,
      breakMinutes: 0,
      isPauseAllowed: false,
      pauseMinutes: 0,
      isDifferentLocationAllowed: false,
      allowedLocationIds: [],
      isCustom: false,
      ...rules,
    },
    rulesSource: 'location',
    startDateKey,
  };
}

const silent = { info() {}, warn() {}, error(...a) { console.error(...a); }, debug() {} };

module.exports = {
  ms,
  ts,
  clone,
  FakeFirestore,
  FakeMessaging,
  historyDoc,
  session,
  attendanceDoc,
  locationDoc,
  assignmentDoc,
  employeeDoc,
  requestDoc,
  seedRole,
  ALL_SWITCHES,
  setupFor,
  silent,
};
