'use strict';
/**
 * Company-level inputs:
 *   * `Modules/time_tracker/Settings/general` (decision 4, house history) —
 *     approved schema: ONLY `Auto_Check_Out_After_Minutes` (default 120;
 *     ≤ 0 switches auto check-out off). Break / pause limits live on the
 *     Location (+ group / employee `Custom_Rules`), not here;
 *   * the company record (`Demo/{cid}/Companys/{cid}`, then the approved
 *     rename `Demo/{cid}/Companies/{cid}`) → `Time_Zone`, the company
 *     default zone (D4);
 *   * `Demo_Requests/{cid}` licence: does the company have HR?
 *     (`CompanyModulesParser.hasHr`: `Demo_Details.Modules` or `Modules`,
 *     each value a bool, a history list or `{Values: [...]}` — the last wins).
 */

const { F } = require('../schema');
const { lastOfAny, nestedCurrent, str } = require('../fields');
const { isValidTimeZone } = require('./time');
const { DEFAULT_AUTO_CHECK_OUT_AFTER_MINUTES } = require('../config');

function parseSettings(doc) {
  const auto = lastOfAny(doc || {}, F.autoCheckOutAfter);
  return {
    autoCheckOutAfterMinutes:
      typeof auto === 'number' && Number.isFinite(auto) ? Math.trunc(auto) : DEFAULT_AUTO_CHECK_OUT_AFTER_MINUTES,
  };
}

/**
 * `Time_Zone` of a company record, whichever shape holds it: the record's
 * nested per-field history `{Time_Zone: {Time_Zone: [...], Timestamp: [...]}}`,
 * a plain history list, a scalar, or the legacy camelCase `timeZone` twin.
 * '' when absent or not a valid IANA zone.
 */
function companyTimeZoneOf(doc) {
  if (!doc) return '';
  for (const key of F.companyTimeZone) {
    const value = str(nestedCurrent(doc, key)).trim();
    if (value !== '' && isValidTimeZone(value)) return value;
  }
  return '';
}

function isModuleOn(value) {
  if (typeof value === 'boolean') return value;
  if (Array.isArray(value)) return value.length > 0 && value[value.length - 1] === true;
  if (value && typeof value === 'object' && Array.isArray(value.Values)) {
    return value.Values.length > 0 && value.Values[value.Values.length - 1] === true;
  }
  return false;
}

/** The licence includes the HR module (fail-closed: missing = no HR). */
function hasHrModule(licenceDoc) {
  if (!licenceDoc) return false;
  const details = licenceDoc.Demo_Details;
  const modules =
    details && typeof details === 'object' && details.Modules && typeof details.Modules === 'object'
      ? details.Modules
      : licenceDoc.Modules;
  if (!modules || typeof modules !== 'object' || Array.isArray(modules)) return false;
  for (const [key, value] of Object.entries(modules)) {
    if (key.trim().toLowerCase() === 'hr') return isModuleOn(value);
  }
  return false;
}

module.exports = { parseSettings, companyTimeZoneOf, hasHrModule, isModuleOn };
