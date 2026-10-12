'use strict';
/**
 * Effective work set-up of ONE employee, and his shift on ONE day, in the
 * location's time zone.
 *
 * Port of `TimeTrackerWorkSetupSource`, `HrWorkSetupSource`,
 * `EffectiveRulesResolver`, `WorkSchedule` and the *Model readers:
 *   * company WITHOUT HR — `Location_Assignments/{email}` → `Locations/{id}`;
 *     hours / working days / Late After always come from the LOCATION
 *     (decision 13); break / pause rules (approved schema): the location
 *     holds the defaults, a group / assignment `Custom_Rules` map with
 *     `Is_Custom` true overrides them — employee → group → location;
 *   * company WITH HR — `hr/Shift_Assignments` → `hr/Shifts` (+ `hr/Locations`):
 *     no working days (week UNKNOWN → working-week checks are skipped,
 *     decision 9), grace 0, pause allowed, no breaks.
 * Time zone (D4): the location's `Time_Zone` → the company record's
 * `Time_Zone` → TT_DEFAULT_TIME_ZONE.
 */

const { lastOf } = require('../history');
const { str, bool, int, norm, lastOfAny, listOfAny, toMillis, isPlainObject } = require('../fields');
const { F } = require('../schema');
const time = require('./time');

const ALL_DAYS = Object.freeze([1, 2, 3, 4, 5, 6, 7]);

/** A positive minute value, else 0 (missing / ≤ 0 = no limit). */
const positive = (raw) => (typeof raw === 'number' && Number.isFinite(raw) && raw > 0 ? Math.trunc(raw) : 0);

/**
 * `Locations/{id}` (TT) or `Modules/hr/Locations/{id}` → plain object.
 * The location holds the DEFAULT break / pause rules (approved schema):
 * `Is_Break_Allowed`, `Allowed_Break_Minutes` (legacy `Break_Minutes`),
 * `Is_Pause_Allowed`, `Allowed_Pause_Minutes` (missing = no pause limit).
 */
function parseLocation(id, doc) {
  const d = doc || {};
  const days = listOfAny(d, F.workingDays)
    .filter((n) => typeof n === 'number' && Number.isFinite(n))
    .map((n) => Math.trunc(n))
    .filter((n) => n >= 1 && n <= 7);
  const status = str(lastOfAny(d, F.locationStatus));
  return {
    id,
    nameEn: str(lastOfAny(d, F.nameEn)),
    nameAr: str(lastOfAny(d, F.nameAr)),
    startMinutes: int(lastOfAny(d, F.workStart), 9 * 60),
    endMinutes: int(lastOfAny(d, F.workEnd), 17 * 60),
    workingDays: days.length === 0 ? ALL_DAYS.slice() : days,
    lateAfterMinutes: Math.max(0, int(lastOfAny(d, F.lateAfter))),
    isBreakAllowed: bool(lastOfAny(d, F.isBreakAllowed)),
    breakMinutes: positive(lastOfAny(d, F.allowedBreakMinutes)),
    isPauseAllowed: bool(lastOfAny(d, F.isPauseAllowed)),
    pauseMinutes: positive(lastOfAny(d, F.allowedPauseMinutes)),
    // Unknown / missing status reads as active (LocationStatus.fromStorageKey).
    isActive: status === '' || status === 'active',
    timeZone: str(lastOfAny(d, F.timeZone)).trim(),
  };
}

const LEGACY_RULE_FIELDS = Object.freeze(['Is_Custom_Rules', 'Is_Break_Allowed', 'Break_Minutes', 'Allowed_Break_Minutes', 'Is_Pause_Allowed']);

/**
 * The override of a group / assignment (approved schema):
 *   * `Custom_Rules` (optional history map) = {Is_Custom, Is_Break_Allowed,
 *     Allowed_Break_Minutes, Is_Pause_Allowed, Allowed_Pause_Minutes} — it
 *     overrides only when `Is_Custom` is true; a missing
 *     `Allowed_Pause_Minutes` there = no pause limit;
 *   * FALLBACK — the app's legacy flat fields (`Is_Custom_Rules`, missing =
 *     true; `Is_Break_Allowed`, `Break_Minutes`, `Is_Pause_Allowed`). They
 *     carry no pause length, so `pauseMinutes` is null = inherit the
 *     location's `Allowed_Pause_Minutes`;
 *   * neither present → no override (`isCustom` false).
 * `Is_Different_Location_Allowed` / `Allowed_Location_Ids` stay flat fields.
 */
function parseRules(doc) {
  const d = doc || {};
  const elsewhere = {
    isDifferentLocationAllowed: bool(lastOfAny(d, F.isDifferentLocationAllowed)),
    allowedLocationIds: listOfAny(d, F.allowedLocationIds).filter((x) => typeof x === 'string'),
  };
  const map = lastOfAny(d, F.customRules);
  if (isPlainObject(map)) {
    const breakRaw = map.Allowed_Break_Minutes !== undefined ? map.Allowed_Break_Minutes : map.Break_Minutes;
    return {
      isCustom: map[F.customIsCustom] === true,
      isBreakAllowed: map.Is_Break_Allowed === true,
      breakMinutes: positive(breakRaw),
      isPauseAllowed: map.Is_Pause_Allowed === true,
      pauseMinutes: positive(map.Allowed_Pause_Minutes),
      source: 'custom_rules',
      ...elsewhere,
    };
  }
  if (LEGACY_RULE_FIELDS.some((k) => d[k] !== undefined)) {
    return {
      // Missing flag (rows written before it) = true — their values were explicit.
      isCustom: lastOfAny(d, F.isCustomRules) !== false,
      isBreakAllowed: bool(lastOfAny(d, F.isBreakAllowed)),
      breakMinutes: positive(lastOfAny(d, F.allowedBreakMinutes)),
      isPauseAllowed: bool(lastOfAny(d, F.isPauseAllowed)),
      pauseMinutes: null,
      source: 'legacy_flat',
      ...elsewhere,
    };
  }
  return {
    isCustom: false,
    isBreakAllowed: false,
    breakMinutes: 0,
    isPauseAllowed: false,
    pauseMinutes: 0,
    source: 'none',
    ...elsewhere,
  };
}

/** `Location_Assignments/{email}` → plain object. */
function parseAssignment(id, doc) {
  const d = doc || {};
  const email = norm(lastOfAny(d, F.employeeEmail)) || norm(id);
  const locationId = str(lastOfAny(d, F.locationId));
  return {
    email,
    locationId,
    startDateMs: toMillis(lastOfAny(d, F.startDate)),
    groupId: str(lastOfAny(d, F.groupId)),
    rules: parseRules(d),
    isAssigned: locationId !== '' && lastOfAny(d, F.isDeleted) !== true,
  };
}

/** `Groups/{id}` → plain object. */
function parseGroup(id, doc) {
  const d = doc || {};
  return { id, rules: parseRules(d), isDeleted: bool(lastOfAny(d, F.isDeleted)) };
}

/** Normalised effective rules (a limit only when its feature is allowed). */
function finalRules(r, location) {
  const pause = r.pauseMinutes === null || r.pauseMinutes === undefined ? location.pauseMinutes : r.pauseMinutes;
  return {
    isBreakAllowed: !!r.isBreakAllowed,
    breakMinutes: r.isBreakAllowed ? r.breakMinutes || 0 : 0,
    isPauseAllowed: !!r.isPauseAllowed,
    pauseMinutes: r.isPauseAllowed ? pause || 0 : 0,
    isDifferentLocationAllowed: !!r.isDifferentLocationAllowed,
    allowedLocationIds: r.allowedLocationIds || [],
    isCustom: !!r.isCustom,
  };
}

/** The location's DEFAULT rules. */
function locationRules(location) {
  return finalRules(
    {
      isBreakAllowed: location.isBreakAllowed,
      breakMinutes: location.breakMinutes,
      isPauseAllowed: location.isPauseAllowed,
      pauseMinutes: location.pauseMinutes,
      isCustom: false,
    },
    location,
  );
}

/**
 * Effective break / pause rules: employee Custom_Rules (Is_Custom true) →
 * group Custom_Rules (Is_Custom true, live group of the assignment) →
 * location defaults. "Different location" stays the app rule: the
 * employee's own when his rules are custom, else the group's, else his own.
 */
function resolveRules({ location, assignment, group }) {
  const a = assignment || null;
  const g = group && !group.isDeleted && a && a.groupId !== '' && a.groupId === group.id ? group : null;
  const own = a ? a.rules : null;
  const elsewhere = own && (own.isCustom || g === null) ? own : g ? g.rules : own;
  const withElsewhere = (r) => ({
    ...r,
    isDifferentLocationAllowed: elsewhere ? !!elsewhere.isDifferentLocationAllowed : false,
    allowedLocationIds: elsewhere ? elsewhere.allowedLocationIds || [] : [],
  });
  if (own && own.isCustom) return { rules: withElsewhere(finalRules(own, location)), source: 'employee' };
  if (g && g.rules.isCustom) return { rules: withElsewhere(finalRules(g.rules, location)), source: 'group' };
  return { rules: withElsewhere(locationRules(location)), source: 'location' };
}

/**
 * The work set-up of an employee of a company WITHOUT HR.
 * @returns {object|null} null = not assigned / location missing or inactive.
 */
function buildTimeTrackerSetup({ assignment, location, group, companyTimeZone, defaultTimeZone }) {
  if (!assignment || !assignment.isAssigned || !location || !location.isActive) return null;
  const timeZone = time.pickTimeZone(location.timeZone, companyTimeZone, defaultTimeZone);
  const { rules, source } = resolveRules({ location, assignment, group });
  return {
    owner: 'time_tracker',
    email: assignment.email,
    locationId: location.id,
    timeZone,
    schedule: {
      startMinutes: location.startMinutes,
      endMinutes: location.endMinutes,
      workingDays: location.workingDays,
      lateAfterMinutes: location.lateAfterMinutes,
      isWorkingWeekKnown: true,
    },
    rules,
    rulesSource: source,
    startDateKey: assignment.startDateMs === null ? null : time.dayKeyOf(assignment.startDateMs, timeZone),
  };
}

/** `hr/Shifts/{id}` → {id, locationId, startMinutes, endMinutes} (`HrWorkSetupMapper.shiftFrom`). */
function parseHrShift(id, doc) {
  const d = doc || {};
  const ownId = str(lastOf(d, 'Id'));
  return {
    id: ownId !== '' ? ownId : id,
    locationId: str(lastOfAny(d, F.hrLocationIds)),
    startMinutes: int(lastOfAny(d, F.hrStartMinutes)),
    endMinutes: int(lastOfAny(d, F.hrEndMinutes)),
  };
}

/** The current shift id of one `hr/Shift_Assignments` document. */
function hrShiftIdOf(doc) {
  return str(lastOfAny(doc || {}, F.hrShiftId));
}

/** HR companies: every assigned employee gets these rules (`HrWorkSetupSource.defaultRules`). */
const HR_DEFAULT_RULES = Object.freeze({
  isBreakAllowed: false,
  breakMinutes: 0,
  isPauseAllowed: true,
  pauseMinutes: 0,
  isDifferentLocationAllowed: true,
  allowedLocationIds: [],
  isCustom: true,
});

/** The work set-up of an employee of a company WITH HR. */
function buildHrSetup({ email, shift, location, companyTimeZone, defaultTimeZone }) {
  if (!email || !shift) return null;
  const timeZone = time.pickTimeZone(location ? location.timeZone : '', companyTimeZone, defaultTimeZone);
  return {
    owner: 'hr',
    email: norm(email),
    locationId: shift.locationId,
    timeZone,
    schedule: {
      startMinutes: shift.startMinutes,
      endMinutes: shift.endMinutes,
      workingDays: ALL_DAYS.slice(),
      lateAfterMinutes: 0,
      // Decision 9: HR shifts store no working days — the week is UNKNOWN.
      isWorkingWeekKnown: false,
    },
    // Pause limit: the HR location's Allowed_Pause_Minutes if it carries one, else none.
    rules: { ...HR_DEFAULT_RULES, pauseMinutes: location ? location.pauseMinutes : 0 },
    rulesSource: 'hr',
    startDateKey: null,
  };
}

/**
 * The shift that STARTS on [dayKey] (`WorkSchedule.startOn / endOn /
 * lateThresholdOn`): an overnight shift (end ≤ start) ends the next day.
 */
function shiftOn(setup, dayKey) {
  const s = setup.schedule;
  const tz = setup.timeZone;
  const overnight = s.endMinutes <= s.startMinutes;
  const grace = Math.max(0, s.lateAfterMinutes);
  return {
    dayKey,
    isWorkingDay: s.workingDays.includes(time.weekdayOfKey(dayKey)),
    isWorkingWeekKnown: s.isWorkingWeekKnown !== false,
    isOvernight: overnight,
    startMs: time.atMinutes(dayKey, s.startMinutes, tz),
    lateThresholdMs: time.atMinutes(dayKey, s.startMinutes + grace, tz),
    endMs: time.atMinutes(dayKey, s.endMinutes + (overnight ? 24 * 60 : 0), tz),
  };
}

/** The assignment has started on [dayKey] (no start date = immediately). */
function hasStarted(setup, dayKey) {
  return !setup.startDateKey || dayKey >= setup.startDateKey;
}

/** Break allowed with a positive limit (B1 gate). */
function breakLimitMinutes(setup) {
  const r = setup.rules || {};
  return r.isBreakAllowed && r.breakMinutes > 0 ? r.breakMinutes : 0;
}

/** Pause allowed for this employee with a positive limit (C1 gate; 0 = no limit). */
function pauseLimitMinutes(setup) {
  const r = setup.rules || {};
  return r.isPauseAllowed && r.pauseMinutes > 0 ? r.pauseMinutes : 0;
}

module.exports = {
  ALL_DAYS,
  parseLocation,
  parseRules,
  parseAssignment,
  parseGroup,
  locationRules,
  resolveRules,
  buildTimeTrackerSetup,
  parseHrShift,
  hrShiftIdOf,
  HR_DEFAULT_RULES,
  buildHrSetup,
  shiftOn,
  hasStarted,
  breakLimitMinutes,
  pauseLimitMinutes,
};
