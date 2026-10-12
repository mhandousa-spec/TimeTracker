'use strict';
/**
 * Firestore reads for the runner. The firebase-admin `Firestore` instance is
 * INJECTED (tests pass an in-memory fake), so nothing here imports firebase.
 *
 * Reads are bounded per company and run:
 *   * Settings/general, the licence, the assignments (+ locations, referenced
 *     groups) — or, with HR, Shift_Assignments + Shifts + hr/Locations;
 *   * ONLY yesterday's and today's Attendance documents of ASSIGNED employees
 *     (two ids per employee, one batched getAll);
 *   * the Notification_Log markers of the candidates (one batched getAll);
 *   * lazily, only when a due event needs them: the employee's own Requests
 *     (leave check), the employee directory + role switches (gates, manager,
 *     names, HR approvers), the notification templates.
 */

const { PATHS } = require('./schema');
const { lastOfAny, nestedCurrent, norm } = require('./fields');
const { F } = require('./schema');
const { parseSettings, hasHrModule, companyTimeZoneOf } = require('./rules/settings');
const sched = require('./rules/schedule');
const { parseRequest } = require('./rules/approvals');
const access = require('./rules/access');
const { templateId, LEGACY_KEYS, resolveTemplate } = require('./texts');

const GET_ALL_CHUNK = 300;

function createData(db) {
  async function docData(path) {
    const snap = await db.doc(path).get();
    return snap.exists ? snap.data() : null;
  }

  async function collectionDocs(path) {
    const snap = await db.collection(path).get();
    return snap.docs.map((d) => ({ id: d.id, data: d.data() }));
  }

  /** Batched getAll → Map path → data | null. */
  async function getMany(paths) {
    const out = new Map();
    const unique = [...new Set(paths)];
    for (let i = 0; i < unique.length; i += GET_ALL_CHUNK) {
      const chunk = unique.slice(i, i + GET_ALL_CHUNK);
      if (chunk.length === 0) continue;
      const snaps = await db.getAll(...chunk.map((p) => db.doc(p)));
      snaps.forEach((s, j) => out.set(chunk[j], s.exists ? s.data() : null));
    }
    return out;
  }

  /** Companies with a Time Tracker module document (`Demo/{cid}/Modules/time_tracker`). */
  async function listCompanyIds() {
    const refs = await db.collection(PATHS.companies()).listDocuments();
    const ids = refs.map((r) => r.id);
    const modules = await getMany(ids.map((id) => PATHS.moduleDoc(id)));
    return ids.filter((id) => modules.get(PATHS.moduleDoc(id)) !== null);
  }

  const loadSettings = async (cid) => parseSettings(await docData(PATHS.settingsDoc(cid)));

  /**
   * The company default zone: `Time_Zone` of the company record —
   * `Demo/{cid}/Companys/{cid}`, then the approved rename
   * `Demo/{cid}/Companies/{cid}`; the first valid value wins, '' when none
   * (→ TT_DEFAULT_TIME_ZONE).
   */
  async function loadCompanyTimeZone(cid) {
    for (const path of PATHS.companyRecordCandidates(cid)) {
      const zone = companyTimeZoneOf(await docData(path));
      if (zone !== '') return zone;
    }
    return '';
  }
  const loadHasHr = async (cid) => hasHrModule(await docData(PATHS.licenceDoc(cid)));

  /** Company WITHOUT HR: every assigned employee's set-up. */
  async function loadTimeTrackerSetups(cid, { companyTimeZone, defaultTimeZone }) {
    const [assignmentDocs, locationDocs] = await Promise.all([
      collectionDocs(PATHS.locationAssignments(cid)),
      collectionDocs(PATHS.locations(cid)),
    ]);
    const locations = new Map(locationDocs.map((d) => [d.id, sched.parseLocation(d.id, d.data)]));
    const assignments = assignmentDocs.map((d) => sched.parseAssignment(d.id, d.data)).filter((a) => a.isAssigned);
    const groupIds = [
      ...new Set(assignments.filter((a) => a.groupId !== '' && !a.rules.isCustom).map((a) => a.groupId)),
    ];
    const groupData = await getMany(groupIds.map((id) => `${PATHS.groups(cid)}/${id}`));
    const groups = new Map(
      groupIds
        .map((id) => [id, groupData.get(`${PATHS.groups(cid)}/${id}`)])
        .filter(([, data]) => data !== null && data !== undefined)
        .map(([id, data]) => [id, sched.parseGroup(id, data)]),
    );
    const setups = [];
    for (const a of assignments) {
      const setup = sched.buildTimeTrackerSetup({
        assignment: a,
        location: locations.get(a.locationId) || null,
        group: a.groupId ? groups.get(a.groupId) || null : null,
        companyTimeZone,
        defaultTimeZone,
      });
      if (setup) setups.push(setup);
    }
    return setups;
  }

  /** Company WITH HR: Shift_Assignments → Shifts (+ hr/Locations). */
  async function loadHrSetups(cid, { companyTimeZone, defaultTimeZone }) {
    const [assignmentDocs, shiftDocs, locationDocs] = await Promise.all([
      collectionDocs(PATHS.hrShiftAssignments(cid)),
      collectionDocs(PATHS.hrShifts(cid)),
      collectionDocs(PATHS.hrLocations(cid)),
    ]);
    const shifts = new Map(shiftDocs.map((d) => [d.id, sched.parseHrShift(d.id, d.data)]));
    const locations = new Map(locationDocs.map((d) => [d.id, sched.parseLocation(d.id, d.data)]));
    // Keyed by employee EMAIL (target) or by Employees_Info id (HR today).
    const needIds = assignmentDocs
      .filter((d) => !d.id.includes('@'))
      .map((d) => String(lastOfAny(d.data, F.hrEmployeeId) || d.id));
    const employees = await getMany(needIds.map((id) => `${PATHS.employeesInfo(cid)}/${id}`));
    const setups = [];
    for (const d of assignmentDocs) {
      const email = d.id.includes('@')
        ? norm(d.id)
        : norm(nestedCurrent(employees.get(`${PATHS.employeesInfo(cid)}/${String(lastOfAny(d.data, F.hrEmployeeId) || d.id)}`), 'Email'));
      const shift = shifts.get(sched.hrShiftIdOf(d.data)) || null;
      const location = shift ? locations.get(shift.locationId) || null : null;
      const setup = sched.buildHrSetup({ email, shift, location, companyTimeZone, defaultTimeZone });
      if (setup) setups.push(setup);
    }
    return setups;
  }

  const attendancePath = (cid, id) => `${PATHS.attendance(cid)}/${id}`;
  const markerPath = (cid, id) => `${PATHS.notificationLog(cid)}/${id}`;

  /** Attendance documents by id → Map id → data | null. */
  async function loadAttendance(cid, ids) {
    const byPath = await getMany(ids.map((id) => attendancePath(cid, id)));
    return new Map(ids.map((id) => [id, byPath.get(attendancePath(cid, id)) || null]));
  }

  /** The marker ids that already exist. */
  async function existingMarkers(cid, ids) {
    const byPath = await getMany(ids.map((id) => markerPath(cid, id)));
    return new Set(ids.filter((id) => byPath.get(markerPath(cid, id)) !== null));
  }

  /** The employee's OWN requests (history docs keep the same email in every row). */
  async function loadRequestsOf(cid, email) {
    const snap = await db.collection(PATHS.requests(cid)).where(F.requesterEmail[0], 'array-contains', norm(email)).get();
    const out = snap.docs.map((d) => parseRequest(d.id, d.data()));
    if (out.length > 0) return out.filter((r) => r && r.isKnown);
    // Target schema stores a plain string.
    const plain = await db.collection(PATHS.requests(cid)).where(F.requesterEmail[0], '==', norm(email)).get();
    return plain.docs.map((d) => parseRequest(d.id, d.data())).filter((r) => r && r.isKnown);
  }

  /**
   * Every request of the company (the REAL pending count). History documents
   * cannot be filtered on their CURRENT status / step server-side, so the
   * collection is read; switch to count() queries once the target schema's
   * current-value `Status` / `Current_Step` / `Current_Approver_Email` land.
   */
  async function loadAllRequests(cid) {
    return (await collectionDocs(PATHS.requests(cid)))
      .map((d) => parseRequest(d.id, d.data))
      .filter((r) => r && r.isKnown);
  }

  async function loadDirectory(cid) {
    const docs = await collectionDocs(PATHS.employeesInfo(cid));
    return access.buildDirectory(docs.map((d) => access.parseEmployee(d.id, d.data)));
  }

  async function loadAccess(cid) {
    const [roleDocs, adminDocs] = await Promise.all([
      collectionDocs(PATHS.roles(cid)).catch(() => []),
      collectionDocs(PATHS.subscriptionAdmin(cid)).catch(() => []),
    ]);
    const roles = [
      ...roleDocs.map((d) => access.parseRole(d.id, d.data, 'Roles')),
      ...adminDocs.map((d) => access.parseRole(d.id, d.data, 'Subscription_Admin')),
    ];
    const wanted = roles.filter((r) => !r.deleted && r.licensed);
    const switches = await getMany(wanted.map((r) => `${PATHS.rolePermissions(cid)}/${r.id}`));
    const byRole = new Map(wanted.map((r) => [r.id, switches.get(`${PATHS.rolePermissions(cid)}/${r.id}`) || {}]));
    return access.buildAccess(roles, byRole);
  }

  /** The template to send [key] with (stored → legacy switch → defaults). */
  async function loadTemplate(cid, key, isReminder) {
    const stored = await docData(`${PATHS.templates(cid)}/${templateId(key)}`);
    const legacyKey = LEGACY_KEYS[key];
    const legacy = !stored && legacyKey ? await docData(`${PATHS.templates(cid)}/${templateId(legacyKey)}`) : null;
    return resolveTemplate(key, { stored, legacy, isReminder });
  }

  return {
    docData,
    getMany,
    listCompanyIds,
    loadSettings,
    loadCompanyTimeZone,
    loadHasHr,
    loadTimeTrackerSetups,
    loadHrSetups,
    loadAttendance,
    existingMarkers,
    loadRequestsOf,
    loadAllRequests,
    loadDirectory,
    loadAccess,
    loadTemplate,
    attendancePath,
    markerPath,
  };
}

module.exports = { createData };
