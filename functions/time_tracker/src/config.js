'use strict';
/**
 * Time Tracker server — constants and environment switches.
 *
 * Every number the decisions use lives here (NOTIFICATIONS_VERIFIED.md,
 * "DECISIONS — Moataz 9 Oct"). Company-editable values are NOT here; they are
 * read at run time (approved schema):
 *   * `Modules/time_tracker/Settings/general.Auto_Check_Out_After_Minutes`;
 *   * break / pause defaults on each Location (`Is_Break_Allowed`,
 *     `Allowed_Break_Minutes`, `Is_Pause_Allowed`, `Allowed_Pause_Minutes`),
 *     overridden by a group / assignment `Custom_Rules` map;
 *   * `Time_Zone`: the location's, then the company record's.
 *
 * Environment (functions/time_tracker/.env, read at deploy + run time):
 *   TT_REGION                   functions region (must suit the Firestore location)
 *   TT_DEFAULT_TIME_ZONE        IANA zone used ONLY when neither the location nor
 *                               the company record has one (default Asia/Riyadh)
 *   TT_COMPANY_IDS              optional comma list: only these companies are swept
 *   TT_LATE_ARRIVAL_ON_SERVER   "true" = the scheduler also raises
 *                               late_arrival_recorded (the decision says the app
 *                               does it on check-in; OFF by default)
 *   TT_FCM_PUSH                 "false" = write the in-app notifications only
 */

const env = (typeof process !== 'undefined' && process.env) || {};

function list(raw) {
  return String(raw || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}

module.exports = Object.freeze({
  /** Tenant root collection: `Demo/{companyId}/…`. */
  COMPANY_ROOT: 'Demo',
  /** `Name_of_module` on notifications, template prefix, licence key. */
  MODULE_KEY: 'time_tracker',

  /** C2 — shift_start_reminder: 15 minutes before the shift start. */
  SHIFT_START_REMINDER_LEAD_MINUTES: 15,
  /** A9 — missed_check_out: still checked in 30 minutes after the shift end. */
  MISSED_CHECK_OUT_AFTER_MINUTES: 30,
  /** B2 — break_duration_exceeded: limit + 5 minutes grace (proposed). */
  BREAK_EXCEEDED_GRACE_MINUTES: 5,
  /** B7 — Settings/general.Auto_Check_Out_After_Minutes default (2 hours). */
  DEFAULT_AUTO_CHECK_OUT_AFTER_MINUTES: 120,
  /** A1 — daily reminder for requests waiting more than 2 days. */
  APPROVAL_OVERDUE_AFTER_MINUTES: 2 * 24 * 60,
  /** A1 — the daily pending-approvals reminder goes out from this local hour. */
  DAILY_APPROVALS_REMINDER_HOUR: 9,

  DEFAULT_TIME_ZONE: env.TT_DEFAULT_TIME_ZONE || 'Asia/Riyadh',
  REGION: env.TT_REGION || 'us-central1',
  COMPANY_IDS: list(env.TT_COMPANY_IDS),
  LATE_ARRIVAL_ON_SERVER: env.TT_LATE_ARRIVAL_ON_SERVER === 'true',
  FCM_PUSH: env.TT_FCM_PUSH !== 'false',

  /** Sender of system notifications (same as the app's reminder sweep). */
  SYSTEM_SENDER: 'system@company.com',
  /** `Created_By` / `Modified_By` of rows the server writes (target schema "system"). */
  SYSTEM_ACTOR: 'system',

  /** Warm-instance cache of the employee directory / roles / templates. */
  CACHE_MS: 10 * 60 * 1000,
});
