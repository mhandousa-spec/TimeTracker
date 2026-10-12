'use strict';
/**
 * Indexed-history documents — a line-by-line port of the app's
 * `TimeTrackerHistoryCodec` + `TimeTrackerFieldCodec.wrap/unwrap` +
 * `TimeTrackerAudit.next`
 * (lib/features/time_tracker/data/models/time_tracker_history_codec.dart,
 *  time_tracker_field_codec.dart).
 *
 * Owner rule: EVERY field of a document is a LIST and the document carries
 * `timestamps` (Firestore Timestamps). Every write appends ONE entry to EVERY
 * field and ONE to `timestamps`, so index i of any field is that field's value
 * at `timestamps[i]`; the current value is always the LAST element.
 *
 * `appendRow` mirrors `TimeTrackerHistoryCodec.append` exactly:
 *   * a stored field that the writer does not pass is CARRIED (its last value
 *     appended again — the app's 9/10/2026 code-review rule), so a full `set`
 *     never drops data the writer does not know (e.g. the server's `Alerts`);
 *   * every history is front-padded with null (and `timestamps` with epoch 0)
 *     to the document's row count before the new entry is appended;
 *   * legacy int-millisecond stamps are read and upgraded to Timestamps.
 *
 * Pure: no Firestore import. The `toTimestamp(ms)` factory is injected
 * (firebase-admin `Timestamp.fromMillis` in production).
 */

const { plainTimestamp } = require('./timestamp');

const F_TIMESTAMPS = 'timestamps';
const F_VALUES = 'Values';

const AUDIT = Object.freeze({
  createdBy: 'Created_By',
  creationDate: 'Creation_Date',
  modifiedBy: 'Modified_By',
});

const own = (obj, key) => obj != null && Object.prototype.hasOwnProperty.call(obj, key);

function isTimestampLike(raw) {
  return !!raw && typeof raw === 'object' && typeof raw.toMillis === 'function';
}

/** `_asHistory`: null → [], a list → a copy, anything else → a one-entry history. */
function asHistory(raw) {
  if (raw === null || raw === undefined) return [];
  if (Array.isArray(raw)) return raw.slice();
  return [raw];
}

/** The stored history of [key]. */
function historyOf(doc, key) {
  return asHistory(doc == null ? undefined : doc[key]);
}

/** The current value of [key]: the last history entry, or null. */
function lastOf(doc, key) {
  const history = historyOf(doc, key);
  return history.length === 0 ? null : history[history.length - 1];
}

function toTimestampWith(raw, toTimestamp) {
  if (isTimestampLike(raw)) return raw;
  if (raw instanceof Date) return toTimestamp(raw.getTime());
  if (typeof raw === 'number' && Number.isFinite(raw)) return toTimestamp(Math.trunc(raw));
  if (raw && typeof raw === 'object') {
    const s = raw.seconds !== undefined ? raw.seconds : raw._seconds;
    const n = raw.nanoseconds !== undefined ? raw.nanoseconds : raw._nanoseconds;
    if (typeof s === 'number') return toTimestamp(s * 1000 + Math.floor((n || 0) / 1e6));
  }
  return toTimestamp(0);
}

/** The `timestamps` column as Timestamps (legacy ints upgraded, junk → epoch 0). */
function timestampsOf(doc, toTimestamp = plainTimestamp) {
  return asHistory(doc == null ? undefined : doc[F_TIMESTAMPS]).map((raw) => toTimestampWith(raw, toTimestamp));
}

/** Epoch ms of the latest write (last `timestamps` entry), or null. */
function lastWriteMs(doc) {
  const stamps = timestampsOf(doc);
  if (stamps.length === 0) return null;
  const ms = stamps[stamps.length - 1].toMillis();
  return ms > 0 ? ms : null;
}

function padFront(list, length, filler) {
  if (list.length >= length) return list;
  return [...new Array(length - list.length).fill(filler), ...list];
}

/**
 * The next version of a history document (the full map to `set`).
 *
 * @param {object|null} old    the stored document (null on create)
 * @param {object} values      field name → NEW value (changed or not)
 * @param {number} nowMs       the write time
 * @param {{toTimestamp?: function(number): object}} [opts]
 */
function appendRow(old, values, nowMs, opts = {}) {
  const toTimestamp = opts.toTimestamp || plainTimestamp;
  const source = old || {};
  const next = { ...values };
  for (const key of Object.keys(source)) {
    if (key !== F_TIMESTAMPS && !own(values, key)) next[key] = lastOf(source, key);
  }
  const histories = {};
  for (const key of Object.keys(next)) histories[key] = historyOf(source, key);
  const stamps = timestampsOf(source, toTimestamp);

  let rows = stamps.length;
  for (const history of Object.values(histories)) {
    if (history.length > rows) rows = history.length;
  }

  const out = {};
  for (const key of Object.keys(next)) {
    out[key] = [...padFront(histories[key], rows, null), next[key]];
  }
  out[F_TIMESTAMPS] = [...padFront(stamps, rows, toTimestamp(0)), toTimestamp(nowMs)];
  return out;
}

/** How many history rows the document holds (the longest field). */
function rowCount(doc) {
  let rows = 0;
  for (const value of Object.values(doc || {})) {
    const n = asHistory(value).length;
    if (n > rows) rows = n;
  }
  return rows;
}

/** The document as it was at history row [index] (aligned from the end). */
function rowAt(doc, index) {
  const rows = rowCount(doc);
  const out = {};
  for (const [key, value] of Object.entries(doc || {})) {
    const history = asHistory(value);
    const count = index + 1 - (rows - history.length);
    out[key] = count <= 0 ? [] : history.slice(0, Math.min(count, history.length));
  }
  return out;
}

/** One history entry of a list-valued field: `{Values: [...]}`. */
function wrap(list) {
  return { [F_VALUES]: Array.isArray(list) ? list.slice() : [] };
}

/** The list inside one wrapped entry (`{Values: [...]}` or a bare list). */
function unwrap(raw) {
  const list = raw && typeof raw === 'object' && !Array.isArray(raw) ? raw[F_VALUES] : raw;
  return Array.isArray(list) ? list.slice() : [];
}

/**
 * `TimeTrackerAudit.next`: creator + creation date carry forward from the
 * stored document (or are [actor] / now on create); the modifier is [actor].
 */
function nextAudit(stored, actor, nowMs, opts = {}) {
  const toTimestamp = opts.toTimestamp || plainTimestamp;
  const map = stored || {};
  const createdAt = lastOf(map, AUDIT.creationDate);
  const createdByRaw = lastOf(map, AUDIT.createdBy);
  const createdBy = typeof createdByRaw === 'string' ? createdByRaw : '';
  return {
    [AUDIT.createdBy]: createdBy !== '' ? createdBy : actor,
    [AUDIT.creationDate]: isTimestampLike(createdAt) ? createdAt : toTimestamp(nowMs),
    [AUDIT.modifiedBy]: actor,
  };
}

/** True for an app-codec document (it carries the `timestamps` column). */
function isHistoryDoc(doc) {
  return !!doc && Array.isArray(doc[F_TIMESTAMPS]);
}

module.exports = {
  F_TIMESTAMPS,
  F_VALUES,
  AUDIT,
  isTimestampLike,
  asHistory,
  historyOf,
  lastOf,
  timestampsOf,
  lastWriteMs,
  appendRow,
  rowCount,
  rowAt,
  wrap,
  unwrap,
  nextAudit,
  isHistoryDoc,
};
