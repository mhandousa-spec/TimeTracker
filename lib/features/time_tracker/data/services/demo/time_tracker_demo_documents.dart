/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_documents.dart
/// Purpose: Declares `TtDemoDocuments` — renders the DEBUG-ONLY demo
///          attachments as small, formal, bilingual (English + Arabic) A4
///          PDF files: a medical report, a workshop invitation, a business
///          mission order and a committee meeting attendance sheet.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (owner, 14:17 — "tapping an attachment opens a
///            real file"; government audience: formal wording only)
///
/// `package:pdf` (already an app dependency). The Cairo font is passed in
/// (the service loads it from the app's assets) so this file has no I/O.
/// Arabic paragraphs are set right-to-left; dates use Western digits with
/// the month written out ("9 October 2026" / "9 أكتوبر 2026").

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

abstract final class TtDemoDocuments {
  static const List<String> _monthsEn = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _monthsAr = <String>[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String _dateEn(DateTime d) => '${d.day} ${_monthsEn[d.month - 1]} ${d.year}';
  static String _dateAr(DateTime d) => '${d.day} ${_monthsAr[d.month - 1]} ${d.year}';

  static String _time(DateTime d, {required bool ar}) {
    final int h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final String m = d.minute.toString().padLeft(2, '0');
    final String suffix = d.hour < 12 ? (ar ? 'ص' : 'AM') : (ar ? 'م' : 'PM');
    return '${h.toString().padLeft(2, '0')}:$m $suffix';
  }

  static String _reference(TtDemoDocument doc) =>
      'REF-${doc.issuedAt.year}-${(doc.issuedAt.month * 100 + doc.issuedAt.day).toString().padLeft(4, '0')}'
      '-${(doc.employee.email.hashCode & 0xfff).toString().padLeft(4, '0')}';

  /// Function Name: [render]
  ///
  /// Purpose: The PDF bytes of [doc]; [details] is the request's own text
  /// (purpose of a mission / reason of a correction).
  ///
  /// Return type: [Future<Uint8List>]
  static Future<Uint8List> render(
    TtDemoDocument doc, {
    required Uint8List regularFont,
    required Uint8List boldFont,
    String details = '',
  }) {
    final pw.Font regular = pw.Font.ttf(ByteData.sublistView(regularFont));
    final pw.Font bold = pw.Font.ttf(ByteData.sublistView(boldFont));
    final pw.Document pdf = pw.Document(
      title: doc.fileName.replaceAll('.pdf', ''),
      author: 'Knowticed Plus',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    final _Content c = _content(doc, details);
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => _page(c, doc, bold),
    ));
    return pdf.save();
  }

  static _Content _content(TtDemoDocument doc, String details) {
    final TimeTrackerEmployee e = doc.employee;
    final String nameEn = e.name(isArabic: false);
    final String nameAr = e.name(isArabic: true);
    final String titleEn = e.jobTitle(isArabic: false);
    final String titleAr = e.jobTitle(isArabic: true);
    final String days = '${doc.to.difference(doc.from).inDays + 1}';
    switch (doc.kind) {
      case TtDemoDocumentKind.medicalReport:
        return _Content(
          orgEn: 'Nasr City Specialised Hospital — Outpatient Department',
          orgAr: 'مستشفى مدينة نصر التخصصي — العيادات الخارجية',
          titleEn: 'Medical Report',
          titleAr: 'تقرير طبي',
          rows: <_Row>[
            _Row('Patient name', nameEn, 'اسم المريض', nameAr),
            _Row('Examination date', _dateEn(doc.from), 'تاريخ الكشف', _dateAr(doc.from)),
            _Row('Diagnosis', 'Acute upper respiratory tract infection', 'التشخيص', 'التهاب حاد في الجهاز التنفسي العلوي'),
            _Row('Recommended rest', '$days day(s) from ${_dateEn(doc.from)} to ${_dateEn(doc.to)}', 'الراحة الموصى بها',
                '$days يوم من ${_dateAr(doc.from)} إلى ${_dateAr(doc.to)}'),
          ],
          bodyEn: 'After clinical examination, the above-named patient is advised to rest for the period stated '
              'and may return to work afterwards. This report is issued at the patient\'s request for submission '
              'to the employer.',
          bodyAr: 'بعد الكشف السريري ينصح المريض المذكور أعلاه بالراحة خلال المدة الموضحة، ويمكنه العودة إلى العمل '
              'بعدها. صدر هذا التقرير بناء على طلب المريض لتقديمه إلى جهة العمل.',
          signEn: 'Dr. Hesham Kamal — Internal Medicine Consultant',
          signAr: 'د. هشام كمال — استشاري الباطنة',
        );
      case TtDemoDocumentKind.workshopInvitation:
        return _Content(
          orgEn: 'Institute of Public Administration — Training Directorate',
          orgAr: 'معهد الإدارة العامة — إدارة التدريب',
          titleEn: 'Workshop Invitation — Digital Government Forum',
          titleAr: 'دعوة لحضور ورشة عمل — منتدى الحكومة الرقمية',
          rows: <_Row>[
            _Row('Participant', nameEn, 'المشارك', nameAr),
            _Row('Job title', titleEn, 'المسمى الوظيفي', titleAr),
            _Row('Date', _dateEn(doc.from), 'التاريخ', _dateAr(doc.from)),
            _Row('Time', '09:00 AM – 03:00 PM', 'الوقت', '09:00 ص – 03:00 م'),
            _Row('Venue', 'Main Hall, New Administrative Capital', 'المكان', 'القاعة الرئيسية، العاصمة الإدارية الجديدة'),
          ],
          bodyEn: 'The Institute is pleased to invite you to the workshop on digital public services, service '
              'quality indicators and electronic records management. Kindly confirm your attendance through your '
              'Human Resources department.',
          bodyAr: 'يسر المعهد دعوتكم لحضور ورشة العمل الخاصة بالخدمات الحكومية الرقمية ومؤشرات جودة الخدمة وإدارة '
              'السجلات الإلكترونية. يرجى تأكيد الحضور من خلال إدارة الموارد البشرية لديكم.',
          signEn: 'Director of Training',
          signAr: 'مدير إدارة التدريب',
        );
      case TtDemoDocumentKind.travelOrder:
        return _Content(
          orgEn: 'Ministry Headquarters — Human Resources Directorate',
          orgAr: 'مقر الوزارة — الإدارة العامة للموارد البشرية',
          titleEn: 'Business Mission Order',
          titleAr: 'أمر مأمورية عمل',
          rows: <_Row>[
            _Row('Employee', nameEn, 'الموظف', nameAr),
            _Row('Job title', titleEn, 'المسمى الوظيفي', titleAr),
            _Row('Destination', 'Ministry of Planning — New Administrative Capital', 'الجهة',
                'وزارة التخطيط — العاصمة الإدارية الجديدة'),
            _Row('Date', _dateEn(doc.from), 'التاريخ', _dateAr(doc.from)),
            _Row('Time', '${_time(doc.from, ar: false)} – ${_time(doc.to, ar: false)}', 'الوقت',
                '${_time(doc.from, ar: true)} – ${_time(doc.to, ar: true)}'),
          ],
          bodyEn: 'The above-named employee is assigned to the official mission stated, and shall submit a brief '
              'report on its outcome to the direct manager.${details.isEmpty ? '' : ' Purpose: $details'}',
          bodyAr: 'يكلف الموظف المذكور أعلاه بأداء المأمورية الرسمية الموضحة، على أن يقدم تقريرا مختصرا بنتائجها '
              'إلى مديره المباشر.',
          signEn: 'Director of Administrative Affairs',
          signAr: 'مدير الشؤون الإدارية',
        );
      case TtDemoDocumentKind.meetingMinutes:
        return _Content(
          orgEn: 'Ministry Headquarters — Quarterly Service Performance Committee',
          orgAr: 'مقر الوزارة — لجنة أداء الخدمات الربع سنوية',
          titleEn: 'Committee Meeting Attendance Sheet',
          titleAr: 'كشف حضور اجتماع اللجنة',
          rows: <_Row>[
            _Row('Member', nameEn, 'العضو', nameAr),
            _Row('Meeting date', _dateEn(doc.from), 'تاريخ الاجتماع', _dateAr(doc.from)),
            _Row('Arrival', _time(doc.from, ar: false), 'الحضور', _time(doc.from, ar: true)),
            _Row('Departure', _time(doc.to, ar: false), 'الانصراف', _time(doc.to, ar: true)),
          ],
          bodyEn: 'This sheet confirms the member\'s attendance of the committee meeting for the times stated, '
              'which extended beyond the official working hours.',
          bodyAr: 'يثبت هذا الكشف حضور العضو اجتماع اللجنة في الأوقات الموضحة، والذي امتد إلى ما بعد مواعيد العمل '
              'الرسمية.',
          signEn: 'Committee Secretary',
          signAr: 'أمين سر اللجنة',
        );
    }
  }

  static pw.Widget _page(_Content c, TtDemoDocument doc, pw.Font bold) {
    final PdfColor line = PdfColor.fromInt(0xFFD9D9D9);
    final PdfColor accent = PdfColor.fromInt(0xFF2D2D2D);
    pw.Widget ar(String text, {double size = 11, bool strong = false}) => pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(fontSize: size, font: strong ? bold : null, lineSpacing: 3),
        );
    pw.Widget en(String text, {double size = 11, bool strong = false}) =>
        pw.Text(text, style: pw.TextStyle(fontSize: size, font: strong ? bold : null, lineSpacing: 3));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Expanded(child: en(c.orgEn, size: 12, strong: true)),
            pw.SizedBox(width: 20),
            pw.Expanded(child: ar(c.orgAr, size: 12, strong: true)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 2, color: PdfColor.fromInt(0xFFFFDE59)),
        pw.SizedBox(height: 18),
        pw.Center(child: en(c.titleEn, size: 18, strong: true)),
        pw.Center(child: ar(c.titleAr, size: 16, strong: true)),
        pw.SizedBox(height: 6),
        pw.Center(child: en('${_reference(doc)}   ·   ${_dateEn(doc.issuedAt)}', size: 9)),
        pw.SizedBox(height: 18),
        pw.Table(
          border: pw.TableBorder.all(color: line, width: 0.8),
          columnWidths: const <int, pw.TableColumnWidth>{
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(2),
          },
          children: <pw.TableRow>[
            for (final _Row r in c.rows)
              pw.TableRow(children: <pw.Widget>[
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: en(r.labelEn, size: 10, strong: true)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: en(r.valueEn, size: 10)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: ar(r.valueAr, size: 10)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: ar(r.labelAr, size: 10, strong: true)),
              ]),
          ],
        ),
        pw.SizedBox(height: 20),
        en(c.bodyEn),
        pw.SizedBox(height: 10),
        ar(c.bodyAr),
        pw.Spacer(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: <pw.Widget>[
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: <pw.Widget>[
              pw.Container(width: 160, height: 1, color: accent),
              pw.SizedBox(height: 4),
              en(c.signEn, size: 10),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: <pw.Widget>[
              pw.Container(width: 160, height: 1, color: accent),
              pw.SizedBox(height: 4),
              ar(c.signAr, size: 10),
            ]),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Center(
          child: en('This document was issued electronically and attached to the request in Knowticed Plus.', size: 8),
        ),
      ],
    );
  }
}

class _Row {
  const _Row(this.labelEn, this.valueEn, this.labelAr, this.valueAr);

  final String labelEn;
  final String valueEn;
  final String labelAr;
  final String valueAr;
}

class _Content {
  const _Content({
    required this.orgEn,
    required this.orgAr,
    required this.titleEn,
    required this.titleAr,
    required this.rows,
    required this.bodyEn,
    required this.bodyAr,
    required this.signEn,
    required this.signAr,
  });

  final String orgEn;
  final String orgAr;
  final String titleEn;
  final String titleAr;
  final List<_Row> rows;
  final String bodyEn;
  final String bodyAr;
  final String signEn;
  final String signAr;
}
