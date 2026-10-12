/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_texts.dart
/// Purpose: Declares `TtDemoText` (one text in English + Arabic) and
///          `TtDemoTexts` — every sentence the DEBUG-ONLY demo data writes:
///          location / group / request-type names, request descriptions,
///          rejection / cancellation reasons and comments.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data, like To-Do's
///            `todo_sample_data.dart`)
///
/// Knowticed is shown to GOVERNMENT clients (owner rule, 7/10/2026): real,
/// professional office wording — no "[TEST]", no placeholder text. Arabic
/// without tanween / diacritics (owner rule).

/// One sentence in both languages.
class TtDemoText {
  const TtDemoText(this.en, this.ar);

  final String en;
  final String ar;

  /// Function Name: [of]
  ///
  /// Purpose: The text in the app language.
  ///
  /// Return type: [String]
  String of({required bool isArabic}) => isArabic ? ar : en;
}

abstract final class TtDemoTexts {
  // ── Locations ───────────────────────────────────────────────────────────
  static const TtDemoText headquarters =
      TtDemoText('Ministry Headquarters', 'مقر الوزارة الرئيسي');
  static const TtDemoText serviceCenter =
      TtDemoText('Citizen Service Center — Nasr City', 'مركز خدمة المواطنين — مدينة نصر');
  static const TtDemoText archive =
      TtDemoText('Records and Archives Building', 'مبنى السجلات والأرشيف');

  // ── Group ───────────────────────────────────────────────────────────────
  static const TtDemoText groupName =
      TtDemoText('Records Digitisation Team', 'فريق رقمنة السجلات');
  static const TtDemoText groupDescription = TtDemoText(
    'Staff working on the digitisation of the ministry archive. Longer '
        'breaks are allowed during the scanning shifts.',
    'الموظفون العاملون على رقمنة أرشيف الوزارة، ويسمح لهم باستراحات أطول خلال '
        'فترات المسح الضوئي.',
  );

  // ── Request types ───────────────────────────────────────────────────────
  static const TtDemoText annual = TtDemoText('Annual Vacation', 'إجازة سنوية');
  static const TtDemoText annualDescription = TtDemoText(
    'Paid annual leave deducted from the yearly vacation balance.',
    'إجازة سنوية مدفوعة تخصم من رصيد الإجازات السنوي.',
  );
  static const TtDemoText sick = TtDemoText('Sick Leave', 'إجازة مرضية');
  static const TtDemoText sickDescription = TtDemoText(
    'Leave for medical reasons. A medical report is required.',
    'إجازة لأسباب صحية، ويشترط إرفاق تقرير طبي.',
  );
  static const TtDemoText mission = TtDemoText('Business Mission', 'مأمورية عمل');
  static const TtDemoText missionDescription = TtDemoText(
    'Official work outside the office, approved by the direct manager.',
    'عمل رسمي خارج المكتب يعتمده المدير المباشر.',
  );
  static const TtDemoText workshop = TtDemoText('Excused — Workshop', 'استئذان — ورشة عمل');
  static const TtDemoText workshopDescription = TtDemoText(
    'Attendance of an approved training workshop, reviewed by Human Resources.',
    'حضور ورشة تدريبية معتمدة، وتراجعه الموارد البشرية.',
  );
  static const TtDemoText emergency = TtDemoText('Emergency Leave', 'إجازة طارئة');
  static const TtDemoText emergencyDescription = TtDemoText(
    'Short leave for urgent family matters. Suspended until the new policy is issued.',
    'إجازة قصيرة للظروف العائلية الطارئة، وموقوفة لحين صدور السياسة الجديدة.',
  );

  // ── Request descriptions ────────────────────────────────────────────────
  static const TtDemoText familyTrip = TtDemoText(
    'Annual leave for a family trip. My tasks are handed over to my colleague.',
    'إجازة سنوية لرحلة عائلية، وتم تسليم مهامي إلى زميلي.',
  );
  static const TtDemoText personalMatters = TtDemoText(
    'Annual leave to complete personal and family matters.',
    'إجازة سنوية لإنهاء بعض الأمور الشخصية والعائلية.',
  );
  static const TtDemoText yearEnd = TtDemoText(
    'Annual leave planned at the end of the quarter, after the reports are submitted.',
    'إجازة سنوية مخطط لها في نهاية الربع بعد تسليم التقارير.',
  );
  static const TtDemoText flu = TtDemoText(
    'Sick leave due to seasonal flu, as stated in the attached medical report.',
    'إجازة مرضية بسبب نزلة برد موسمية حسب التقرير الطبي المرفق.',
  );
  static const TtDemoText checkup = TtDemoText(
    'Medical check-up at the hospital, report attached.',
    'فحص طبي في المستشفى، والتقرير مرفق.',
  );
  static const TtDemoText ministryMeeting = TtDemoText(
    'Coordination meeting at the Ministry of Planning on the shared services project.',
    'اجتماع تنسيقي في وزارة التخطيط بشأن مشروع الخدمات المشتركة.',
  );
  static const TtDemoText siteVisit = TtDemoText(
    'Field visit to the Citizen Service Center to review the queue system.',
    'زيارة ميدانية لمركز خدمة المواطنين لمراجعة نظام الانتظار.',
  );
  static const TtDemoText digitalWorkshop = TtDemoText(
    'Digital transformation workshop organised by the Institute of Public Administration.',
    'ورشة التحول الرقمي التي ينظمها معهد الإدارة العامة.',
  );
  static const TtDemoText archivingWorkshop = TtDemoText(
    'Electronic archiving standards workshop for records officers.',
    'ورشة معايير الأرشفة الإلكترونية لمسؤولي السجلات.',
  );
  static const TtDemoText forgotCheckOut = TtDemoText(
    'I forgot to check out after the evening committee meeting.',
    'نسيت تسجيل الانصراف بعد اجتماع اللجنة المسائي.',
  );
  static const TtDemoText deviceFailure = TtDemoText(
    'The check-in failed because the location service was unavailable in the building.',
    'تعذر تسجيل الحضور بسبب تعطل خدمة الموقع داخل المبنى.',
  );

  // ── Reasons ─────────────────────────────────────────────────────────────
  static const TtDemoText rejectWorkload = TtDemoText(
    'The department is preparing the annual report on these dates. Please choose other dates.',
    'الإدارة تعد التقرير السنوي في هذه التواريخ، يرجى اختيار تواريخ أخرى.',
  );
  static const TtDemoText rejectNoInvitation = TtDemoText(
    'The workshop invitation was not attached. Please resubmit with the official invitation.',
    'لم ترفق دعوة الورشة، يرجى إعادة التقديم مع الدعوة الرسمية.',
  );
  static const TtDemoText cancelPlansChanged = TtDemoText(
    'My travel plans changed, so I no longer need these days.',
    'تغيرت خطة السفر ولم أعد بحاجة إلى هذه الأيام.',
  );
  static const TtDemoText cancelByHrAudit = TtDemoText(
    'Canceled because of the external audit visit. The days were returned to your balance.',
    'تم الإلغاء بسبب زيارة التدقيق الخارجي، وأعيدت الأيام إلى رصيدك.',
  );
  static const TtDemoText cancelRequestReturn = TtDemoText(
    'The project deadline was moved forward, so I would like to cancel this leave.',
    'تم تقديم موعد تسليم المشروع، لذا أرغب في إلغاء هذه الإجازة.',
  );

  // ── Comments ────────────────────────────────────────────────────────────
  static const TtDemoText commentHandover = TtDemoText(
    'Please confirm who will cover the service desk during your leave.',
    'يرجى تأكيد من سيغطي مكتب الخدمة خلال إجازتك.',
  );
  static const TtDemoText commentHandoverReply = TtDemoText(
    'A colleague from my department will cover the desk. The handover note is shared with the team.',
    'سيغطي أحد زملاء الإدارة المكتب، وتمت مشاركة مذكرة التسليم مع الفريق.',
  );
  static const TtDemoText commentReport = TtDemoText(
    'The medical report has been received and filed. Get well soon.',
    'تم استلام التقرير الطبي وحفظه، مع تمنياتنا بالشفاء العاجل.',
  );
  static const TtDemoText commentMissionLetter = TtDemoText(
    'Please share the mission letter after the meeting.',
    'يرجى مشاركة خطاب المأمورية بعد الاجتماع.',
  );
}
