/// Module: todo / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: todo_sample_data.dart
/// Purpose: Declares `TodoSampleData` — the DEBUG-ONLY demo to-dos the
///          "Demo tools" sheet loads so the owner can see every To-Do
///          notification and the calendar entries without waiting days.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Pure Dart, no I/O: `TodoListCubit` writes what [TodoSampleData.build]
/// returns through `TodoBaseRepository`. Only reachable from a widget that is
/// built when `kDebugMode` is true, so it is tree-shaken out of release.
///
/// The app is shown to GOVERNMENT clients (owner, 7/10/2026), so the samples
/// are real-looking office tasks — no "[TEST]" prefix, no placeholder text.
/// They are written in the user's language (English or Arabic) and found
/// again for "Remove demo to-dos" by their exact titles in EITHER language
/// ([isSample]).
///
/// ─── WHY THE TIMES LOOK ODD ──────────────────────────────────────────────
///
/// `TodoReminderSweeper` skips any event due BEFORE the to-do was created
/// (except Overdue), and the repository stamps `createdAt` with the write
/// time. So an event "already due" at creation never fires. Each sample is
/// instead built so its event falls due [fireDelay] after loading; the cubit
/// sweeps again right after that, so the notification arrives ~2–3 minutes
/// after "Load demo to-dos" (or press "Send due reminders now" after that).
///
///   1 Budget review   start T+62m, reminder 1 h  → to_do_reminder   @ T+2m
///                                                  (task_now_due    @ T+62m)
///   2 Stakeholder mtg start T+2m, end +2 h       → task_now_due     @ T+2m
///   3 Vendor contract start now-1h, end T+1d+2m  → scheduled_reminder_day_before
///                                                                   @ T+2m
///   4 Risk register   start now-2d, end now-1h   → task_overdue     immediately
///   5 Compliance list monthly from today T+2m    → task_now_due     @ T+2m
///   6 Dashboard       weekly on today's weekday  → task_now_due     @ T+2m
///   7 Leave requests  high, 3 items, unscheduled → no notification
///
/// T = now rounded up to the next whole minute.

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

/// One demo to-do's text in both languages.
class _SampleText {
  const _SampleText({
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    this.itemsEn = const <String>[],
    this.itemsAr = const <String>[],
  });

  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final List<String> itemsEn;
  final List<String> itemsAr;
}

abstract final class TodoSampleData {
  /// How long after loading the demo events fall due.
  static const Duration fireDelay = Duration(minutes: 2);

  static const _SampleText _budget = _SampleText(
    nameEn: 'Review Q4 budget allocation report',
    nameAr: 'مراجعة تقرير توزيع ميزانية الربع الرابع',
    descriptionEn: 'Review the departmental budget allocation for Q4 and '
        'submit comments to the Finance Directorate before the committee '
        'meeting.',
    descriptionAr: 'مراجعة توزيع ميزانية الإدارة للربع الرابع وإرسال '
        'الملاحظات إلى الإدارة المالية قبل اجتماع اللجنة.',
    itemsEn: <String>[
      'Verify expenditure figures',
      'Check alignment with annual plan',
      'Submit comments',
    ],
    itemsAr: <String>[
      'التحقق من أرقام المصروفات',
      'التأكد من التوافق مع الخطة السنوية',
      'إرسال الملاحظات',
    ],
  );

  static const _SampleText _stakeholders = _SampleText(
    nameEn: 'Coordinate stakeholder meeting with the Planning Department',
    nameAr: 'تنسيق اجتماع أصحاب المصلحة مع إدارة التخطيط',
    descriptionEn: 'Confirm attendees, circulate the agenda and book the '
        'main meeting room for the joint review with the Planning '
        'Department.',
    descriptionAr: 'تأكيد الحضور وتعميم جدول الأعمال وحجز قاعة الاجتماعات '
        'الرئيسية للمراجعة المشتركة مع إدارة التخطيط.',
  );

  static const _SampleText _vendor = _SampleText(
    nameEn: 'Renew vendor service contract',
    nameAr: 'تجديد عقد خدمات المورد',
    descriptionEn: 'Review the current service-level terms, obtain Legal '
        'approval and send the renewal to Procurement before the contract '
        'expires.',
    descriptionAr: 'مراجعة شروط مستوى الخدمة الحالية والحصول على موافقة '
        'الشؤون القانونية وإرسال التجديد إلى المشتريات قبل انتهاء العقد.',
  );

  static const _SampleText _risk = _SampleText(
    nameEn: 'Submit quarterly risk register update',
    nameAr: 'رفع تحديث سجل المخاطر الربعي',
    descriptionEn: 'Update the risk ratings and mitigation owners, then '
        'submit the register to the Internal Audit Office.',
    descriptionAr: 'تحديث تقييمات المخاطر والمسؤولين عن المعالجة، ثم رفع '
        'السجل إلى مكتب التدقيق الداخلي.',
  );

  static const _SampleText _compliance = _SampleText(
    nameEn: 'Submit monthly compliance checklist',
    nameAr: 'رفع قائمة التحقق الشهرية للامتثال',
    descriptionEn: 'Complete the monthly compliance checklist and submit it '
        'to the Governance and Compliance Unit.',
    descriptionAr: 'استكمال قائمة التحقق الشهرية للامتثال ورفعها إلى وحدة '
        'الحوكمة والامتثال.',
  );

  static const _SampleText _dashboard = _SampleText(
    nameEn: 'Prepare weekly performance dashboard',
    nameAr: 'إعداد لوحة مؤشرات الأداء الأسبوعية',
    descriptionEn: 'Compile the key performance indicators for the week and '
        'share the dashboard with the department director.',
    descriptionAr: 'تجميع مؤشرات الأداء الرئيسية للأسبوع ومشاركة اللوحة مع '
        'مدير الإدارة.',
  );

  static const _SampleText _leave = _SampleText(
    nameEn: 'Approve pending leave requests',
    nameAr: 'اعتماد طلبات الإجازة المعلقة',
    descriptionEn: 'Review the pending leave requests of the team and approve '
        'or return each one before the end of the working week.',
    descriptionAr: 'مراجعة طلبات الإجازة المعلقة لأعضاء الفريق واعتماد كل '
        'طلب أو إعادته قبل نهاية أسبوع العمل.',
    itemsEn: <String>[
      'Check team coverage for the requested dates',
      'Confirm leave balances with Human Resources',
      'Approve or return each request with a note',
    ],
    itemsAr: <String>[
      'التحقق من تغطية الفريق للتواريخ المطلوبة',
      'تأكيد أرصدة الإجازات مع الموارد البشرية',
      'اعتماد كل طلب أو إعادته مع ملاحظة',
    ],
  );

  static const List<_SampleText> _all = <_SampleText>[
    _budget,
    _stakeholders,
    _vendor,
    _risk,
    _compliance,
    _dashboard,
    _leave,
  ];

  /// Every sample title in both languages — how demo to-dos are found again.
  static final Set<String> _titles = <String>{
    for (final _SampleText t in _all) ...<String>[t.nameEn, t.nameAr],
  };

  /// Function Name: [isSample]
  ///
  /// Purpose: Whether [todo] is one of the demo to-dos (exact title match in
  /// English or Arabic).
  ///
  /// Parameters:
  ///   [TodoEntity] todo
  ///
  /// Return type: [bool]
  static bool isSample(TodoEntity todo) => _titles.contains(todo.name.trim());

  /// Function Name: [build]
  ///
  /// Purpose: The seven demo to-dos, timed against [now] so each raises its
  /// notification [fireDelay] after being written (see the file header).
  ///
  /// Parameters:
  ///   [String] ownerEmail: the signed-in user (to-dos are personal).
  ///   [DateTime] now: the moment "Load demo to-dos" was pressed.
  ///   [bool] isArabic: write the Arabic text instead of the English.
  ///
  /// Return type: [List<TodoEntity>] — drafts with empty ids.
  static List<TodoEntity> build({
    required String ownerEmail,
    required DateTime now,
    required bool isArabic,
  }) {
    // Next whole minute: the sweep rebuilds recurring starts at hh:mm, so a
    // start with seconds would drift earlier than the creation time.
    final DateTime base =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final DateTime fire = base.add(fireDelay);

    TodoEntity make(
      _SampleText text, {
      TodoPriority priority = TodoPriority.medium,
      DateTime? start,
      DateTime? end,
      List<TodoReminder> reminders = const <TodoReminder>[],
      TodoFrequency? frequency,
    }) {
      final List<String> items = isArabic ? text.itemsAr : text.itemsEn;
      final int stamp = now.microsecondsSinceEpoch;
      return TodoEntity(
        id: '',
        ownerEmail: ownerEmail,
        name: isArabic ? text.nameAr : text.nameEn,
        description: isArabic ? text.descriptionAr : text.descriptionEn,
        priority: priority,
        isScheduled: start != null,
        startAt: start,
        endAt: end,
        reminders: reminders,
        hasFrequency: frequency != null,
        frequency: frequency ?? const TodoFrequency(),
        items: <TodoItem>[
          for (int i = 0; i < items.length; i++)
            TodoItem(id: '${stamp + i}', title: items[i]),
        ],
      );
    }

    final DateTime budgetStart = fire.add(const Duration(hours: 1));
    return <TodoEntity>[
      // 1 → to_do_reminder at T+2m (1 hour before a start at T+62m).
      make(
        _budget,
        priority: TodoPriority.high,
        start: budgetStart,
        end: budgetStart.add(const Duration(hours: 3)),
        reminders: const <TodoReminder>[
          TodoReminder(value: 1, unit: TodoReminderUnit.hour),
        ],
      ),
      // 2 → task_now_due at T+2m.
      make(
        _stakeholders,
        start: fire,
        end: fire.add(const Duration(hours: 2)),
      ),
      // 3 → scheduled_reminder_day_before at T+2m (end = T+1d+2m). The start
      // is in the past, so its own task_now_due predates creation and is
      // skipped.
      make(
        _vendor,
        start: base.subtract(const Duration(hours: 1)),
        end: fire.add(const Duration(days: 1)),
      ),
      // 4 → task_overdue on the next sweep (exempt from the creation rule).
      make(
        _risk,
        priority: TodoPriority.high,
        start: base.subtract(const Duration(days: 2)),
        end: base.subtract(const Duration(hours: 1)),
      ),
      // 5 → monthly from today; task_now_due at T+2m, then same day monthly.
      make(
        _compliance,
        start: fire,
        end: fire.add(const Duration(hours: 1)),
        frequency: const TodoFrequency(unit: TodoFrequencyUnit.monthly),
      ),
      // 6 → weekly on today's weekday; task_now_due at T+2m, then weekly.
      make(
        _dashboard,
        priority: TodoPriority.low,
        start: fire,
        end: fire.add(const Duration(hours: 2)),
        frequency: TodoFrequency(
          unit: TodoFrequencyUnit.weekly,
          weekDays: <int>[fire.weekday],
        ),
      ),
      // 7 → no notification: high priority with a 3-item checklist.
      make(_leave, priority: TodoPriority.high),
    ];
  }
}
