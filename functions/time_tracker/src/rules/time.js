'use strict';
/**
 * Time-zone arithmetic (decision D4: every time uses the location's
 * `Time_Zone`, falling back to the company default).
 *
 * Pure, dependency-free: Node's built-in ICU (`Intl.DateTimeFormat`) gives
 * the wall clock of an instant in any IANA zone; `zonedTimeToUtc` inverts it
 * (DST-safe: a wall time inside a spring-forward gap resolves to the first
 * valid instant after it, e.g. Cairo 2026-04-24 00:00 → 01:00 EEST).
 *
 * Day keys are `yyyy-MM-dd` (the attendance document id suffix) and use
 * calendar arithmetic, never +24 h. Weekdays use Dart numbering
 * (1 = Monday … 7 = Sunday) like `Working_Days`.
 */

const MINUTE_MS = 60 * 1000;

const formatters = new Map();
function formatterFor(timeZone) {
  let f = formatters.get(timeZone);
  if (!f) {
    f = new Intl.DateTimeFormat('en-US', {
      timeZone,
      hourCycle: 'h23',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      weekday: 'short',
    });
    formatters.set(timeZone, f);
  }
  return f;
}

const WEEKDAYS = { Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6, Sun: 7 };

/** True for an IANA zone name the runtime knows. */
function isValidTimeZone(timeZone) {
  if (typeof timeZone !== 'string' || timeZone.trim() === '') return false;
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: timeZone.trim() });
    return true;
  } catch (_) {
    return false;
  }
}

/** The first valid zone of [candidates] (location → company → default). */
function pickTimeZone(...candidates) {
  for (const c of candidates) if (isValidTimeZone(c)) return c.trim();
  return 'UTC';
}

/** Wall-clock parts of [ms] in [timeZone]. */
function zonedParts(ms, timeZone) {
  const out = {};
  for (const p of formatterFor(timeZone).formatToParts(new Date(ms))) {
    if (p.type === 'weekday') out.weekday = WEEKDAYS[p.value];
    else if (p.type !== 'literal') out[p.type] = Number(p.value);
  }
  if (out.hour === 24) out.hour = 0; // defensive (some ICU builds)
  return out;
}

/** Offset (ms) of [timeZone] from UTC at instant [ms]. */
function offsetMs(ms, timeZone) {
  const p = zonedParts(ms, timeZone);
  const asUtc = Date.UTC(p.year, p.month - 1, p.day, p.hour, p.minute, p.second);
  return asUtc - Math.floor(ms / 1000) * 1000;
}

/**
 * The instant of wall time [minutes] after local midnight of
 * year-month-day in [timeZone]. Minutes ≥ 1440 roll into the next day(s).
 */
function zonedTimeToUtc(year, month, day, minutes, timeZone) {
  const guess = Date.UTC(year, month - 1, day, 0, minutes);
  const first = offsetMs(guess, timeZone);
  let t = guess - first;
  const second = offsetMs(t, timeZone);
  if (second !== first) t = guess - second;
  return t;
}

const pad = (n, w = 2) => String(n).padStart(w, '0');

function formatDayKey(year, month, day) {
  return `${pad(year, 4)}-${pad(month)}-${pad(day)}`;
}

/** `yyyy-MM-dd` of [ms] in [timeZone]. */
function dayKeyOf(ms, timeZone) {
  const p = zonedParts(ms, timeZone);
  return formatDayKey(p.year, p.month, p.day);
}

const DAY_KEY = /^(\d{4})-(\d{2})-(\d{2})$/;

/** {year, month, day} of a valid key, else null (rejects 2026-02-31). */
function parseDayKey(key) {
  const m = DAY_KEY.exec(String(key || '').trim());
  if (!m) return null;
  const year = Number(m[1]);
  const month = Number(m[2]);
  const day = Number(m[3]);
  const d = new Date(Date.UTC(year, month - 1, day));
  if (d.getUTCFullYear() !== year || d.getUTCMonth() !== month - 1 || d.getUTCDate() !== day) return null;
  return { year, month, day };
}

/** [key] moved by [days] calendar days. */
function addDays(key, days) {
  const p = parseDayKey(key);
  const d = new Date(Date.UTC(p.year, p.month - 1, p.day + days));
  return formatDayKey(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate());
}

/** Dart weekday (1 = Monday … 7 = Sunday) of a day key. */
function weekdayOfKey(key) {
  const p = parseDayKey(key);
  const js = new Date(Date.UTC(p.year, p.month - 1, p.day)).getUTCDay();
  return js === 0 ? 7 : js;
}

/** Local midnight of [key] in [timeZone] (the first valid instant of the day). */
function dayStartMs(key, timeZone) {
  const p = parseDayKey(key);
  return zonedTimeToUtc(p.year, p.month, p.day, 0, timeZone);
}

/** Instant of [minutes] after local midnight of [key] (calendar arithmetic). */
function atMinutes(key, minutes, timeZone) {
  const p = parseDayKey(key);
  return zonedTimeToUtc(p.year, p.month, p.day, minutes, timeZone);
}

/**
 * `{{time}}` value: "9:15 AM" (EN) / "9:15 ص" (AR), wall clock in [timeZone].
 * Western digits in both languages, like every other variable the app fills.
 */
function formatClock(ms, timeZone, language) {
  const p = zonedParts(ms, timeZone);
  const h12 = p.hour % 12 === 0 ? 12 : p.hour % 12;
  const am = p.hour < 12;
  const suffix = language === 'ar' ? (am ? 'ص' : 'م') : am ? 'AM' : 'PM';
  return `${h12}:${pad(p.minute)} ${suffix}`;
}

/** Whole minutes from [fromMs] to [toMs] (Dart `difference.inMinutes`, ≥ 0). */
function minutesBetween(fromMs, toMs) {
  const m = Math.trunc((toMs - fromMs) / MINUTE_MS);
  return m < 0 ? 0 : m;
}

module.exports = {
  MINUTE_MS,
  isValidTimeZone,
  pickTimeZone,
  zonedParts,
  offsetMs,
  zonedTimeToUtc,
  formatDayKey,
  dayKeyOf,
  parseDayKey,
  addDays,
  weekdayOfKey,
  dayStartMs,
  atMinutes,
  formatClock,
  minutesBetween,
};
