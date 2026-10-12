'use strict';
/**
 * One `Attendance/{email}_{yyyy-MM-dd}` document, read tolerantly, and the
 * derived numbers (port of `AttendanceDayModel.fromMap` + `AttendanceCalculator`).
 *
 * Decision D2 / 9 Oct: Break and Pause are TWO interval lists inside a
 * session — `Sessions[].Breaks [{Break_Type, Start, End}]` and
 * `Sessions[].Pauses [{Start, End}]`. Today's app writes Pauses only
 * ("Pause = Break"), so break events stay silent until the app writes Breaks.
 */

const { isHistoryDoc } = require('../history');
const { F, LEAVE_STATUSES } = require('../schema');
const { str, toMillis, norm, lastOfAny, listOfAny, currentList, presentName, isPlainObject } = require('../fields');
const { minutesBetween } = require('./time');

/** `TimeTrackerFirestorePaths.emailKey` — trimmed, lower-cased, never empty or with '/'. */
function emailKey(email) {
  const key = norm(email);
  if (key === '') throw new Error('No email — the Time Tracker document path cannot be resolved.');
  if (key.includes('/')) throw new Error(`Invalid email for a Time Tracker path: "${key}".`);
  return key;
}

/** `{email}_{yyyy-MM-dd}`. */
function attendanceDocId(email, dayKey) {
  return `${emailKey(email)}_${dayKey}`;
}

const ID_DAY = /_(\d{4}-\d{2}-\d{2})$/;

/** The day key at the end of an attendance id, or null. */
function dayKeyFromId(id) {
  const m = ID_DAY.exec(String(id || '').trim());
  return m ? m[1] : null;
}

function parseInterval(raw, kind, index) {
  if (!isPlainObject(raw)) return null;
  const startMs = toMillis(raw[F.intervalStart]);
  if (startMs === null) return null;
  return {
    kind,
    index,
    startMs,
    endMs: toMillis(raw[F.intervalEnd]),
    breakType: kind === 'break' ? str(raw.Break_Type) : '',
  };
}

function parseIntervals(raw, kind) {
  return currentList(raw)
    .map((item, i) => parseInterval(item, kind, i))
    .filter((x) => x !== null);
}

/** One session map → plain object (the raw map is kept for lossless rewrites). */
function parseSession(raw, index) {
  const checkInKey = presentName(raw, F.checkIn);
  const checkOutKey = presentName(raw, F.checkOut);
  const checkInMs = checkInKey ? toMillis(raw[checkInKey]) : null;
  const checkOutMs = checkOutKey ? toMillis(raw[checkOutKey]) : null;
  return {
    index,
    raw,
    checkInMs,
    checkOutMs,
    isOpen: checkOutMs === null,
    workLocationId: str(raw[F.workLocationId[0]]),
    isAutoCheckOut: raw[F.isAutoCheckOut] === true,
    pauses: parseIntervals(raw[F.pauses], 'pause'),
    breaks: parseIntervals(raw[F.breaks], 'break'),
  };
}

/** One `Alerts[]` entry → {type, atMs, minutesOver}. */
function parseAlert(raw) {
  if (!isPlainObject(raw)) return null;
  const type = str(raw[F.alertType]);
  if (type === '') return null;
  const m = raw[F.alertMinutesOver];
  return {
    type,
    atMs: toMillis(raw[F.alertAt]),
    minutesOver: typeof m === 'number' && Number.isFinite(m) ? Math.trunc(m) : 0,
  };
}

/**
 * The stored day (null when the document does not exist).
 * `mode` = 'history' (app codec, `timestamps` column) or 'scalar' (target schema).
 */
function parseDay(id, doc) {
  if (!doc) return null;
  const sessions = listOfAny(doc, F.sessions)
    .filter(isPlainObject)
    .map((raw, i) => parseSession(raw, i))
    .filter((s) => s.checkInMs !== null);
  const status = str(lastOfAny(doc, F.attendanceStatus));
  return {
    id,
    dayKey: dayKeyFromId(id),
    email: norm(lastOfAny(doc, F.employeeEmail)),
    mode: isHistoryDoc(doc) ? 'history' : 'scalar',
    sessions,
    status: status === '' ? null : status,
    // rawIndex = position in the stored list (updates rewrite that entry).
    alerts: listOfAny(doc, F.alerts)
      .map((raw, rawIndex) => {
        const alert = parseAlert(raw);
        return alert === null ? null : { ...alert, rawIndex };
      })
      .filter((a) => a !== null),
    hasPausedMinutesField: presentName(doc, F.pausedMinutes) !== null,
    raw: doc,
  };
}

/** The running session of the day (the last one, while it has no check-out). */
function openSessionOf(day) {
  if (!day || day.sessions.length === 0) return null;
  const last = day.sessions[day.sessions.length - 1];
  return last.isOpen ? last : null;
}

/** The running interval of a list (the last one, while it has no end). */
function openIntervalOf(intervals) {
  if (!intervals || intervals.length === 0) return null;
  const last = intervals[intervals.length - 1];
  return last.endMs === null ? last : null;
}

const isLeaveStatus = (status) => LEAVE_STATUSES.includes(status);

/** Minutes of one interval; an open one runs until the session's end (or now). */
function intervalMinutes(interval, sessionEndMs) {
  return minutesBetween(interval.startMs, interval.endMs === null ? sessionEndMs : interval.endMs);
}

/**
 * `AttendanceCalculator.summarize` (numbers only): worked = Σ span − pauses −
 * breaks (never negative); pauses and breaks summed separately.
 */
function totals(sessions, nowMs) {
  let work = 0;
  let pause = 0;
  let brk = 0;
  for (const s of sessions) {
    const end = s.checkOutMs === null ? nowMs : s.checkOutMs;
    const p = s.pauses.reduce((sum, iv) => sum + intervalMinutes(iv, end), 0);
    const b = s.breaks.reduce((sum, iv) => sum + intervalMinutes(iv, end), 0);
    const worked = minutesBetween(s.checkInMs, end) - p - b;
    work += worked < 0 ? 0 : worked;
    pause += p;
    brk += b;
  }
  return { workMinutes: work, pauseMinutes: pause, breakMinutes: brk };
}

module.exports = {
  emailKey,
  attendanceDocId,
  dayKeyFromId,
  parseSession,
  parseAlert,
  parseDay,
  openSessionOf,
  openIntervalOf,
  isLeaveStatus,
  intervalMinutes,
  totals,
  currentListOf: currentList,
};
