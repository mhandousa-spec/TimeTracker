'use strict';
/**
 * Default EN / AR texts of every event the server raises — verbatim from
 * NOTIFICATIONS_VERIFIED.md ("proposed" texts as written; otherwise the
 * code / spec default of `time_tracker_events.dart`).
 *
 * Like the app (`AppNotificationSender.sendFromTemplate`), the admin template
 * `Demo/{cid}/Modules/notification/notification_templates/time_tracker_{key}`
 * WINS when it exists; these defaults are the fallback. Two server rules on
 * top:
 *   * a stored text that is exactly a SUPERSEDED old default (the seeded
 *     wording the 9 Oct decisions replaced — e.g. "Regular working hours have
 *     resumed" now that a break keeps running) is replaced by the new default,
 *     so a tenant seeded before the change does not send false text; a
 *     genuinely edited text is kept;
 *   * renamed keys (`pending_approvals`, `break_policy_violation_manager`)
 *     honour the on/off switch of their LEGACY template while the new
 *     template does not exist yet (never its old text).
 * Updated 9/10/2026 (QA KP-TT-011): `pending_approvals` says "1 request" /
 * "طلب واحد" — `{{countedRequests}}` ([countedRequests]); the earlier
 * count-only wording is SUPERSEDED.
 */

const TEMPLATES = Object.freeze({
  break_completed: {
    titleEn: 'Break Period Concluded',
    titleAr: 'انتهاء فترة الاستراحة',
    bodyEn:
      'Your permitted break period ended at {{time}}. Please end your break and resume work. Any time beyond the permitted duration will be recorded as a break overrun.',
    bodyAr:
      'انتهت فترة الاستراحة المسموح بها في {{time}}. يرجى إنهاء الاستراحة واستئناف العمل. سيُسجَّل أي وقت يتجاوز المدة المسموح بها كتجاوز للاستراحة.',
    variables: ['time'],
  },
  break_duration_exceeded: {
    titleEn: 'Authorised Break Duration Exceeded',
    titleAr: 'تجاوز المدة المسموح بها للاستراحة',
    bodyEn:
      'Your break has exceeded the permitted duration as defined by the organisational break policy. Please adhere to the approved break schedule to avoid policy non-compliance.',
    bodyAr:
      'تجاوزت استراحتك المدة المسموح بها وفقاً لسياسة الاستراحات التنظيمية. يرجى الالتزام بجدول الاستراحات المعتمد لتجنب مخالفة السياسة.',
    variables: [],
  },
  break_policy_violation_manager: {
    titleEn: 'Break Policy Non-Compliance Detected',
    titleAr: 'تم رصد عدم امتثال لسياسة الاستراحات',
    bodyEn:
      '{{employeeName}} has exceeded the permitted break duration of {{minutes}} minutes and is still on break. The overrun has been recorded in their attendance alerts.',
    bodyAr:
      'تجاوز {{employeeName}} مدة الاستراحة المسموح بها وهي {{minutes}} دقيقة ولا يزال في استراحة. تم تسجيل التجاوز في تنبيهات الحضور الخاصة به.',
    variables: ['employeeName', 'minutes'],
  },
  pause_duration_exceeded: {
    titleEn: 'Pause Duration Exceeded',
    titleAr: 'تجاوز مدة الإيقاف المؤقت',
    bodyEn:
      'Your pause has exceeded the permitted {{minutes}} minutes and is still running. Please resume work; the overrun is recorded in your attendance.',
    bodyAr:
      'تجاوز إيقافك المؤقت المدة المسموح بها وهي {{minutes}} دقيقة ولا يزال مستمراً. يرجى استئناف العمل؛ يتم تسجيل التجاوز في سجل حضورك.',
    variables: ['minutes'],
  },
  automatic_check_out_applied: {
    titleEn: 'Automatic Check-Out Recorded',
    titleAr: 'تم تسجيل خروج تلقائي',
    bodyEn:
      'No check-out was recorded for your shift, so the system checked you out automatically at your shift end time, {{time}}. If you left at a different time, please submit an attendance correction request.',
    bodyAr:
      'لم يُسجَّل انصرافك من الوردية، لذا قام النظام بتسجيل انصرافك تلقائياً في وقت نهاية ورديتك، الساعة {{time}}. إذا غادرت في وقت مختلف، يرجى تقديم طلب تصحيح حضور.',
    variables: ['time'],
  },
  missed_check_in: {
    titleEn: 'Check-In Not Recorded',
    titleAr: 'لم يتم تسجيل الحضور',
    bodyEn:
      'No attendance check-in was recorded for your scheduled shift. If this was due to a valid reason, please submit an attendance correction request with the appropriate supporting documentation.',
    bodyAr:
      'لم يتم تسجيل أي حضور لوردية عملك المجدولة. إذا كان ذلك لسبب مشروع يرجى تقديم طلب تصحيح حضور مع المستندات الداعمة المناسبة.',
    variables: [],
  },
  // A9 fix 3: the code's hard-coded "30 minutes" becomes {{minutes}} (the
  // grace is a server constant; the template is admin-editable).
  missed_check_out: {
    titleEn: 'Check-Out Not Recorded',
    titleAr: 'لم يتم تسجيل الانصراف',
    bodyEn:
      '{{minutes}} minutes have passed since the end of your scheduled shift and no check-out has been recorded. Please record your check-out, or submit an attendance correction request if you have already left.',
    bodyAr:
      'مرت {{minutes}} دقيقة على انتهاء ورديتك المجدولة ولم يتم تسجيل انصرافك بعد. يرجى تسجيل الانصراف، أو تقديم طلب تصحيح حضور إذا كنت قد غادرت بالفعل.',
    variables: ['minutes'],
  },
  shift_start_reminder: {
    titleEn: 'Shift Starting Soon',
    titleAr: 'اقتراب بدء الوردية',
    bodyEn: 'Your shift starts at {{time}}. Please remember to check in from your assigned work location.',
    bodyAr: 'تبدأ ورديتك في الساعة {{time}}. يرجى تذكّر تسجيل الحضور من موقع العمل المعيّن لك.',
    variables: ['time'],
  },
  shift_end_reminder: {
    titleEn: 'Shift Ended — Please Check Out',
    titleAr: 'انتهت الوردية — يرجى تسجيل الانصراف',
    bodyEn: 'Your shift ended at {{time}}. Please remember to check out from your assigned work location.',
    bodyAr: 'انتهت ورديتك في الساعة {{time}}. يرجى تذكّر تسجيل الانصراف من موقع العمل المعيّن لك.',
    variables: ['time'],
  },
  // KP-TT-011 (9/10/2026): {{countedRequests}} = the number WITH its noun in
  // correct grammar ("1 request" / "3 requests"; "طلب واحد" / "طلبان" /
  // "3 طلبات" / "11 طلبا") and wording that fits one or many. `count` is
  // still passed for an admin template that uses {{count}}.
  pending_approvals: {
    titleEn: 'Action Required — Pending Approval Requests',
    titleAr: 'مطلوب إجراء — طلبات بانتظار الموافقة',
    bodyEn:
      'You have {{countedRequests}} awaiting your decision. Please review at your earliest convenience to avoid delays in the approval workflow.',
    bodyAr: 'لديك {{countedRequests}} بانتظار قرارك. يرجى المراجعة في أقرب وقت لتفادي التأخير في سير عمل الموافقة.',
    variables: ['countedRequests'],
  },
  late_arrival_recorded: {
    titleEn: 'Late Attendance Recorded',
    titleAr: 'تم تسجيل تأخر في الحضور',
    bodyEn:
      'Your attendance record indicates that you checked in {{minutes}} minutes after your scheduled shift commencement time. This has been logged in the attendance system for review.',
    bodyAr:
      'تشير سجلات حضورك إلى أنك سجّلت حضورك بعد {{minutes}} دقيقة من الوقت المحدد لبدء وردية عملك. تم توثيق ذلك في نظام الحضور للمراجعة.',
    variables: ['minutes'],
  },
});

/** A1: `Is_Reminder` = true → "Reminder" title / body (proposed). */
const REMINDER_VARIANTS = Object.freeze({
  pending_approvals: {
    titleEn: 'Reminder — Pending Approval Requests',
    titleAr: 'تذكير — طلبات بانتظار الموافقة',
    bodyEn:
      'Reminder: you still have {{countedRequests}} awaiting your decision. Please review at your earliest convenience to avoid delays in the approval workflow.',
    bodyAr:
      'تذكير: لا يزال لديك {{countedRequests}} بانتظار قرارك. يرجى المراجعة في أقرب وقت لتفادي التأخير في سير عمل الموافقة.',
    variables: ['countedRequests'],
  },
});

/** Renamed keys → the key whose template switch applies until the new one exists. */
const LEGACY_KEYS = Object.freeze({
  pending_approvals: 'pending_approvals_manager',
  break_policy_violation_manager: 'break_policy_violation_manager_hr',
});

/** Old seeded defaults the 9 Oct decisions replaced (exact strings from time_tracker_events.dart). */
const SUPERSEDED = Object.freeze({
  break_completed: [
    'Your designated break period ended at {{time}}. Regular working hours have resumed. Please ensure full compliance with the applicable time and attendance policy.',
    'انتهت فترة استراحتك المحددة في {{time}}. استُؤنفت ساعات العمل الاعتيادية. يرجى الالتزام الكامل بسياسة الوقت والحضور المعتمدة.',
  ],
  automatic_check_out_applied: [
    'An automatic check-out has been applied to your attendance record upon completion of your scheduled shift or in accordance with applicable system policy. No further action is required.',
    'تم تطبيق تسجيل خروج تلقائي على سجل حضورك عند انتهاء وردية عملك المجدولة أو وفقاً لسياسة النظام المعمول بها. لا يُستلزم اتخاذ أي إجراء إضافي.',
  ],
  missed_check_out: [
    '30 minutes have passed since the end of your scheduled shift and no check-out has been recorded. Please record your check-out, or submit an attendance correction request if you have already left.',
    'مرت 30 دقيقة على انتهاء ورديتك المجدولة ولم يتم تسجيل انصرافك بعد. يرجى تسجيل الانصراف، أو تقديم طلب تصحيح حضور إذا كنت قد غادرت بالفعل.',
  ],
  // KP-TT-011 (9/10/2026): the earlier count-only wording.
  pending_approvals: [
    'Requests awaiting your decision: {{count}}. Please process them to avoid delays in the approval workflow.',
    'عدد الطلبات بانتظار قرارك: {{count}}. يرجى معالجتها لتفادي التأخير في سير عمل الموافقة.',
  ],
});

const DEFAULT_CHANNELS = Object.freeze(['email', 'push']);

/** Firestore template document id: `time_tracker_{key}`. */
const templateId = (key) => `time_tracker_${key}`;

/**
 * The template to send with.
 * @param {string} key                      event key
 * @param {object|null} stored              `time_tracker_{key}` document data, or null
 * @param {object|null} legacy              `time_tracker_{legacyKey}` data, or null
 * @param {boolean} isReminder              pending_approvals reminder variant
 * @returns {{enabled:boolean, push:boolean, titleEn, titleAr, bodyEn, bodyAr, source:string}}
 */
function resolveTemplate(key, { stored = null, legacy = null, isReminder = false } = {}) {
  const base = isReminder && REMINDER_VARIANTS[key] ? REMINDER_VARIANTS[key] : TEMPLATES[key];
  if (!base) throw new Error(`No default template for "${key}".`);
  const switchDoc = stored || legacy;
  const enabled = switchDoc ? switchDoc.isEnabled !== false : true;
  const channels = switchDoc
    ? Array.isArray(switchDoc.selectedNotificationTypes)
      ? switchDoc.selectedNotificationTypes
      : []
    : DEFAULT_CHANNELS;
  const superseded = SUPERSEDED[key] || [];
  const useStored = !!stored && !isReminder;
  const pick = (field, fallback) => {
    if (!useStored) return fallback;
    const v = stored[field];
    if (typeof v !== 'string' || v.trim() === '' || superseded.includes(v)) return fallback;
    return v;
  };
  return {
    enabled,
    push: channels.includes('push'),
    titleEn: pick('subjectEnglish', base.titleEn),
    titleAr: pick('subjectArabic', base.titleAr),
    bodyEn: pick('bodyEnglish', base.bodyEn),
    bodyAr: pick('bodyArabic', base.bodyAr),
    source: stored ? 'stored' : legacy ? 'legacy-switch' : 'default',
  };
}

/**
 * KP-TT-011 (9/10/2026): [count] requests worded for [lang] — the value of
 * `{{countedRequests}}`. Same rule as the app (`TimeTrackerCountWording`):
 *   EN  1 → "1 request", otherwise "n requests";
 *   AR  (CLDR plural categories, by the last two digits; Western digits like
 *       every server text; no tanween) 1 → "طلب واحد", 2 → "طلبان",
 *       3–10 → "n طلبات", 11–99 → "n طلبا", 0 / 100 / 101 / 102 … → "n طلب".
 * @param {number} count
 * @param {'en'|'ar'} lang
 * @returns {string}
 */
function countedRequests(count, lang) {
  const n = Math.max(0, Math.trunc(Number(count) || 0));
  if (lang !== 'ar') return n === 1 ? '1 request' : `${n} requests`;
  if (n === 1) return 'طلب واحد';
  if (n === 2) return 'طلبان';
  const lastTwo = n % 100;
  if (lastTwo >= 3 && lastTwo <= 10) return `${n} طلبات`;
  if (lastTwo >= 11 && lastTwo <= 99) return `${n} طلبا`;
  return `${n} طلب`;
}

/**
 * KP-TT-011: the pending-approvals placeholders for [count] — `{{count}}`
 * (the number) and `{{countedRequests}}` in each language, ready for
 * [renderBoth] (`en` = variables, `ar` = the Arabic override).
 * @param {number} count
 * @returns {{en: object, ar: object}}
 */
function pendingCountVariables(count) {
  return {
    en: { count: String(count), countedRequests: countedRequests(count, 'en') },
    ar: { countedRequests: countedRequests(count, 'ar') },
  };
}

/** `NotificationTemplateService.processTemplate`: replace each `{{key}}` given. */
function render(text, variables) {
  let out = String(text);
  for (const [key, value] of Object.entries(variables || {})) {
    out = out.split(`{{${key}}}`).join(String(value));
  }
  return out;
}

/**
 * Both renderings (the app stores both; the reader's locale picks).
 * [variablesAr] overrides [variables] for the Arabic text (like `variablesAr`).
 */
function renderBoth(template, variables, variablesAr) {
  const ar = { ...(variables || {}), ...(variablesAr || {}) };
  return {
    title: render(template.titleEn, variables),
    body: render(template.bodyEn, variables),
    title_ar: render(template.titleAr, ar),
    body_ar: render(template.bodyAr, ar),
  };
}

module.exports = {
  TEMPLATES,
  REMINDER_VARIANTS,
  LEGACY_KEYS,
  SUPERSEDED,
  DEFAULT_CHANNELS,
  templateId,
  resolveTemplate,
  render,
  renderBoth,
  countedRequests,
  pendingCountVariables,
};
