'use strict';
/**
 * Tolerant readers for ONE stored value (port of `TimeTrackerFieldCodec`):
 * a missing or mistyped value reads as a safe default, never throws.
 *
 * Two document generations are read side by side:
 *   * the app TODAY — indexed-history docs (`timestamps` + one list per
 *     field, list-valued fields wrapped `{Values: [...]}`), names such as
 *     `Check_In_Date_Time`, `Work_Start_Time`, `Name_En`, `Request_Status`;
 *   * the TARGET schema (target.json, 9 Oct) — current-value fields, plain
 *     lists, names such as `Check_In_At`, `Work_Start_Minutes`,
 *     `Name_English`, `Status`.
 * Every reader takes a list of candidate names and uses the first one the
 * document carries, so the functions keep working while the app migrates.
 */

const { lastOf, isTimestampLike, F_VALUES } = require('./history');

const own = (obj, key) => obj != null && Object.prototype.hasOwnProperty.call(obj, key);

/** Epoch ms of a Timestamp / Date / number / {seconds,nanoseconds}; else null. */
function toMillis(raw) {
  if (raw === null || raw === undefined) return null;
  if (typeof raw === 'number') return Number.isFinite(raw) ? Math.trunc(raw) : null;
  if (raw instanceof Date) return raw.getTime();
  if (isTimestampLike(raw)) return raw.toMillis();
  if (typeof raw === 'object') {
    const s = raw.seconds !== undefined ? raw.seconds : raw._seconds;
    const n = raw.nanoseconds !== undefined ? raw.nanoseconds : raw._nanoseconds;
    if (typeof s === 'number') return s * 1000 + Math.floor((n || 0) / 1e6);
  }
  return null;
}

const str = (raw) => (typeof raw === 'string' ? raw : '');
const bool = (raw) => raw === true;
const int = (raw, fallback = 0) => (typeof raw === 'number' && Number.isFinite(raw) ? Math.trunc(raw) : fallback);
const num = (raw) => (typeof raw === 'number' && Number.isFinite(raw) ? raw : null);
const norm = (email) => str(email).trim().toLowerCase();

/** The first of [names] the document carries. */
function presentName(doc, names) {
  for (const name of names) if (own(doc, name) && doc[name] !== undefined) return name;
  return null;
}

/** The current value of the first present name (history `lastOf`, or the scalar). */
function lastOfAny(doc, names) {
  const name = presentName(doc || {}, names);
  return name === null ? null : lastOf(doc, name);
}

const isPlainObject = (v) => !!v && typeof v === 'object' && !Array.isArray(v) && !isTimestampLike(v);

/**
 * The CURRENT list of a list-valued field, whichever generation wrote it:
 *   * history of wrapped entries `[{Values:[…]}, …, {Values:[…]}]` → last.Values;
 *   * a single wrapped entry `{Values:[…]}` → Values;
 *   * a plain current list (target schema: `[7,1,2,3,4]`, `[{…},{…}]`) → itself.
 * A history whose last entry is null (front padding / cleared) reads as [].
 */
function currentList(raw) {
  if (raw === null || raw === undefined) return [];
  if (!Array.isArray(raw)) {
    return isPlainObject(raw) && Array.isArray(raw[F_VALUES]) ? raw[F_VALUES].slice() : [];
  }
  if (raw.length === 0) return [];
  const looksWrapped = (e) => isPlainObject(e) && Array.isArray(e[F_VALUES]);
  if (raw.some(looksWrapped) || raw.every((e) => e === null)) {
    const last = raw[raw.length - 1];
    if (last === null || last === undefined) return [];
    if (looksWrapped(last)) return last[F_VALUES].slice();
    return Array.isArray(last) ? last.slice() : [];
  }
  return raw.slice();
}

function listOfAny(doc, names) {
  const name = presentName(doc || {}, names);
  return name === null ? [] : currentList(doc[name]);
}

/**
 * `Employees_Info` values are nested per field:
 *   `Email: {Email: ["a@b.c"], Timestamp: [...]}`
 * but some tenants hold a plain history list or a scalar. Returns the current
 * value (last entry) whichever shape is stored.
 */
function nestedCurrent(doc, key) {
  if (!doc) return null;
  let raw = doc[key];
  if (isPlainObject(raw)) {
    if (own(raw, key)) raw = raw[key];
    else {
      const arrayKey = Object.keys(raw).find(
        (k) => Array.isArray(raw[k]) && k !== 'Timestamp' && k !== 'Timestamps' && k !== 'timestamps',
      );
      raw = arrayKey === undefined ? null : raw[arrayKey];
    }
  }
  if (Array.isArray(raw)) return raw.length === 0 ? null : raw[raw.length - 1];
  return raw === undefined ? null : raw;
}

module.exports = {
  toMillis,
  str,
  bool,
  int,
  num,
  norm,
  presentName,
  lastOfAny,
  currentList,
  listOfAny,
  nestedCurrent,
  isPlainObject,
};
