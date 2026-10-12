
// ignore_for_file: sdk_version_since
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/custom_personal_Info_Container.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';



/// Date Created: 3/Dec/2023
/// Developer Name: Bassem Mohamed
/// App Version: Version 2
/// Date of Last Edit: Migrated to NewEmployeeModelHistory
/// Objectives: Screen showing employee work information including:
/// - Position details
/// - Working history
/// - Work schedule
/// - Education
/// - Skills

class EmployeeWorkInfoScreen extends StatefulWidget {
  const EmployeeWorkInfoScreen({super.key, required this.employee});
  final NewEmployeeModelHistory employee;

  @override
  State<EmployeeWorkInfoScreen> createState() => _EmployeeWorkInfoScreenState();
}

class _EmployeeWorkInfoScreenState extends State<EmployeeWorkInfoScreen> {
  /// Guarded lookup — the controller may not be registered yet when this
  /// widget builds, which used to throw `"AddDepartmentController" not found`.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  // NOTE: this used to hold `RoleController` + `UsersAccessController` (GetX).
  // Both were dead: `addRoleController` and `accessTypeEmployee` were never
  // read, and `getUserAcess()` in the source app has its body commented out,
  // so `getAccessTypeByName()` awaited a no-op and called setState() for
  // nothing.
  //
  // skeleton_app's equivalents are cubits:
  //   roles/r1_role_management/presentation/controller/role_cubit.dart  (RoleCubit)
  //   roles/r3_user_access/presentation/controller/user_access_cubit.dart (UserAccessCubit)
  // UserAccessCubit exposes the full list via getAccountsStatusEntities() /
  // filteredSortedSelectedEntities — there is no single-employee fetch.

  @override
  void initState() {
    super.initState();

    // ✅ DEBUG: Print academic history
    if (widget.employee.academicHistory.isNotEmpty) {
      Map<String, dynamic> lastEntry = widget.employee.academicHistory.last;
    }


  }

  String translateTimeFormat(String original) {
    const Map<String, String> amPmTranslations = {"AM": "ص", "PM": "م"};
    const Map<String, String> numberTranslations = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
    };

    List<String> parts = original.split(" ");
    String timePart = parts[0];
    String periodPart = parts[1];

    String translatedTimePart = timePart
        .split('')
        .map((char) => numberTranslations[char] ?? char)
        .join('');

    String translatedPeriodPart = amPmTranslations[periodPart] ?? periodPart;
    String translatedTime = "$translatedTimePart $translatedPeriodPart";

    parts[0] = translatedTime;
    parts.removeAt(1);

    return parts.join(" ");
  }

  String convertToArabicWeekdays(String weekdays) {
    List<String> weekdaysList = weekdays.split(", ");
    Map<String, String> weekdaysMap = {
      'saturday': 'السبت',
      'sunday': 'الأحد',
      'monday': 'الاثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
    };

    List<String> arabicWeekdaysList = weekdaysList.map((weekday) {
      return weekdaysMap[weekday.toLowerCase()] ?? weekday;
    }).toList();

    return arabicWeekdaysList.join(", ");
  }

  String convertToArabicDate(String date) {
    List<String> dateParts = date.split(", ");
    List<String> dateComponents = dateParts[0].split(" ");

    Map<String, String> monthsMap = {
      'jan': 'يناير', 'feb': 'فبراير', 'mar': 'مارس',
      'apr': 'أبريل', 'may': 'مايو', 'jun': 'يونيو',
      'jul': 'يوليو', 'aug': 'أغسطس', 'sep': 'سبتمبر',
      'oct': 'أكتوبر', 'nov': 'نوفمبر', 'dec': 'ديسمبر',
    };

    String arabicMonth = monthsMap[dateComponents[0].toLowerCase()] ?? dateComponents[0];
    return '$arabicMonth ${dateComponents[1]}, ${dateParts[1]}';
  }

  /// ✅ NEW: Get department name safely
  String _getDepartmentName() {
    String departmentId = widget.employee.departmentId.isNotEmpty
        ? widget.employee.departmentId.last
        : '';

    if (departmentId.isEmpty) return '';

    if (Get.locale.toString().contains('en')) {
      return _departments
          .getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId) ?? '';
    } else {
      return _departments
          .getArabicDepartmentNameFromDepartmentId(departmentId: departmentId) ?? '';
    }
  }

  /// ✅ NEW: Get title safely
  String _getTitle() {
    if (Get.locale.toString().contains('en')) {
      return widget.employee.title.isNotEmpty
          ? widget.employee.title.last
          : '';
    } else {
      return widget.employee.titleInArabic.isNotEmpty
          ? widget.employee.titleInArabic.last
          : '';
    }
  }

  /// ✅ NEW: Get title safely
  String _getSuperVisor() {
    if (Get.locale.toString().contains('en')) {
      return widget.employee.supervisor.isNotEmpty
          ? widget.employee.supervisor.last
          : '';
    } else {
      return widget.employee.supervisor.isNotEmpty
          ? widget.employee.supervisor.last
          : '';
    }
  }

  /// ✅ NEW: Get start date safely
  ///
  /// Returns `'-'` rather than `''` when unknown: the Working Hours branch of
  /// CustomPersonalInfoContainer prints the value as-is, so an empty string
  /// left the row looking like the label had simply lost its value.
  String _getStartDate() {
    if (widget.employee.timestamps.isEmpty) return '-';

    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
        widget.employee.timestamps.first
    );

    String formattedDate = DateFormat('MMM dd, yyyy').format(startDate);

    return Get.locale.toString().contains('en')
        ? formattedDate
        : convertToArabicDate(formattedDate);
  }

  /// Function Name: [_getAcademicField]
  ///
  /// Purpose: Read one field of the employee's education from
  /// `Employees_Info/{id}.Academic_History`, or `'-'` when there is nothing to
  /// show.
  ///
  /// FIXED 22/8/2026 — "when I add info it doesn't show here".
  ///
  /// The old version made two assumptions that do not hold across the data
  /// this collection actually contains:
  ///
  ///  1. It read `academicHistory.last` and stopped. The list holds one map
  ///     **per degree row**, and `_cleanAcademic` in the social-profile save
  ///     path keeps blank rows out — but a row can still be partially filled
  ///     (a university with no graduation year, say). Landing on a row that is
  ///     blank *for this particular field* reported "no data" even though an
  ///     earlier row had it. It now walks the rows newest-first and returns
  ///     the first one that actually carries this field.
  ///  2. Within a row it read `fieldValue[0]`. Every value is stored wrapped
  ///     in an array. For records written by the current social-profile
  ///     screen that array holds exactly one element, so `[0]` happened to be
  ///     right — but older documents store these as **append-only history
  ///     arrays** (see `academic_model.dart`, which still describes that
  ///     shape), where element 0 is the *oldest* revision. For an employee
  ///     created through Active Directory that oldest revision is the empty
  ///     string the record was seeded with, so newly added education read back
  ///     as `''` → `'-'`. Taking the last non-empty element is correct for
  ///     both shapes: with one element it is that element, with a history it
  ///     is the current value.
  String _getAcademicField(String fieldName) {
    final List<Map<String, dynamic>> academicHistory =
        widget.employee.academicHistory;

    if (academicHistory.isEmpty) return '-';

    // ✅ Map to correct Firebase field names
    final String firebaseFieldName;
    switch (fieldName) {
      case 'institutionName':
        firebaseFieldName = 'University';
        break;
      case 'degreeOrCertification':
        firebaseFieldName = 'Graduate_From';
        break;
      case 'yearOfGraduation':
        firebaseFieldName = 'Year_Of_Graduation';
        break;
      case 'gpa':
        firebaseFieldName = 'GPA';
        break;
      default:
        return '-';
    }

    // Newest row first — the most recently entered degree wins, and a row that
    // is blank for this field falls through to the one before it.
    for (int i = academicHistory.length - 1; i >= 0; i--) {
      final String value =
          _currentValueOf(academicHistory[i][firebaseFieldName]);
      if (value.isEmpty) continue;

      return firebaseFieldName == 'Graduate_From'
          ? _readableDegree(value)
          : value;
    }

    return '-';
  }

  /// Function Name: [_currentValueOf]
  ///
  /// Purpose: Pull the *current* value out of one stored field, whichever of
  /// the two shapes it is in.
  ///
  /// Employee records wrap every value in an array. Records written today hold
  /// a single element; records written by earlier builds hold the full
  /// append-only history, current value last. Reading the last non-empty
  /// element is correct for both, and a bare scalar is passed straight
  /// through.
  ///
  /// Returns: [String] the trimmed current value, or `''` when there is none.
  String _currentValueOf(dynamic raw) {
    if (raw == null) return '';

    if (raw is List) {
      for (int i = raw.length - 1; i >= 0; i--) {
        final String value = raw[i]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    return raw.toString().trim();
  }

  /// Degree codes are stored lower-case; this is how they are shown.
  String _readableDegree(String value) {
    switch (value.toLowerCase()) {
      case 'bachelor':
        return "Bachelor's Degree";
      case 'master':
        return "Master's Degree";
      case 'phd':
        return "PhD";
      case 'diploma':
        return "Diploma";
      case 'certificate':
        return "Certificate";
      default:
        return value;
    }
  }

  /// Function Name: [_getSkillsString]
  ///
  /// Purpose: The employee's skills as `Name (Level), Name (Level)`, or `'-'`.
  ///
  /// FIXED 22/8/2026: the old version returned the *empty string* whenever the
  /// list was non-empty but every entry inside it was blank — and
  /// `NewEmployeeModelHistory._parseNestedListSafely` returns exactly that,
  /// `[[]]`, as its "nothing parsed" sentinel. An empty string is not `'-'`,
  /// so what reached the screen depended on which branch of
  /// CustomPersonalInfoContainer rendered it. Both the empty-list and
  /// everything-blank cases now resolve to the same `'-'`.
  ///
  /// CHANGED 9/10/2026 — reads the CURRENT revision only (the last element).
  /// `Skills` is an Employees_Info history list: every write appends one
  /// element holding the whole skill list at that time (Settings → Social
  /// Information now saves that way too). Walking every element as if it were
  /// one "[name, level]" row listed each past revision as a skill, and read
  /// the second skill of a revision as the first one's level.
  String _getSkillsString() {
    final List<String> current = widget.employee.skills.isEmpty
        ? const <String>[]
        : widget.employee.skills.last;
    final String joined = current
        .map((String skill) => skill.trim())
        .where((String skill) => skill.isNotEmpty)
        .join(', ');

    return joined.isEmpty ? '-' : joined;
  }

  /// Function Name: [_getHobbiesString]
  ///
  /// Purpose: The employee's hobbies, comma separated, or `'-'`.
  ///
  /// Same empty-vs-`'-'` fix as [_getSkillsString].
  ///
  /// CHANGED 9/10/2026 — current revision only, as [_getSkillsString].
  String _getHobbiesString() {
    final List<String> current = widget.employee.hobbies.isEmpty
        ? const <String>[]
        : widget.employee.hobbies.last;
    final String joined = current
        .map((String hobby) => hobby.trim())
        .where((String hobby) => hobby.isNotEmpty)
        .join(', ');

    return joined.isEmpty ? '-' : joined;
  }

  /// Function Name: [_orDash]
  ///
  /// Purpose: Render a missing value as `'-'` rather than as blank space.
  ///
  /// Several of the getters below return `''` when the employee has no value
  /// for that field, and the Position Details / Working Hours branches of
  /// CustomPersonalInfoContainer print whatever they are given — so a row read
  /// as a label with nothing after it, which looks like a rendering fault
  /// rather than "not filled in".
  String _orDash(String value) => value.trim().isEmpty ? '-' : value.trim();

  /// ✅ NEW: Get email safely
  String _getEmail() {
    return widget.employee.email.isNotEmpty
        ? widget.employee.email.last
        : '-';
  }

  /// ✅ NEW: Get phone safely
  String _getPhone() {
    if (widget.employee.mobilePhone.isEmpty) return '-';

    MobilePhone phone = widget.employee.mobilePhone.last;

    // Get the last (most recent) phone number and country code
    String countryCode = (phone.countryCode != null && phone.countryCode!.isNotEmpty)
        ? phone.countryCode!.last
        : '';
    String number = (phone.phones != null && phone.phones!.isNotEmpty)
        ? phone.phones!.last
        : '';

    if (countryCode.isEmpty && number.isEmpty) return '-';

    if (countryCode.isEmpty) return number;
    if (number.isEmpty) return countryCode;

    return '$countryCode $number';
  }


  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    // ✅ UPDATED: Safe supervisor check
    bool hasSupervisor = widget.employee.supervisor.isNotEmpty;
    String supervisorEmail = hasSupervisor ? widget.employee.supervisor.last : '';

    // ✅ UPDATED: Safe work location check
    String workLocation = widget.employee.workLocation.isNotEmpty
        ? widget.employee.workLocation.last
        : '';

    return Container(
      color: AppColors.card,
      height: isVertical ? 0.85.h : 0.80.h,  // ~12% more space
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Container(height: 800,color: Colors.red,width: 200,)
              // Position Details
              // LOCALIZATION + COUNT FIX 22/8/2026.
              //
              // `primaryText` was the literal 'Position Details' and the first
              // label was the literal 'Department:' / 'Department :', so in the
              // Arabic UI this section header and its first row stayed English
              // while everything around them was translated. All six labels now
              // come from the .arb bundle.
              //
              // The three lists also disagreed on length, which is what shifted
              // rows against their icons:
              //   • hasSupervisor: 4 icons, 4 labels, but **5** values — the
              //     trailing `_getTitle()` had no label or icon at all, so the
              //     job title simply never appeared. It has both now.
              //   • no supervisor: **7** icons for 6 labels — the trailing
              //     `team.svg` belonged to no row. Removed.
              CustomPersonalInfoContainer(
                primaryText: S.of(context).positionDetails,
                isPersonalInformation: true,
                isPositionDetailes: true,
                numberOfElementsInColumn: 2,
                customIcons: hasSupervisor
                    ? [
                  'assets/icons_assets/organization_chart_assets/new_department.svg',
                  'assets/icons_assets/organization_chart_assets/new_superVisor.svg',
                  'assets/icons_assets/organization_chart_assets/settings_email.svg',
                  'assets/icons_assets/organization_chart_assets/settings_phone.svg',
                  'assets/icons_assets/organization_chart_assets/titleIcon.svg',
                ]
                    : [
                  'assets/icons_assets/organization_chart_assets/FolderWithFiles.svg',
                  'assets/icons_assets/organization_chart_assets/jobCompansation.svg',
                  'assets/icons_assets/main_icons_assets/Case.svg',
                  'assets/icons_assets/organization_chart_assets/titleIcon.svg',
                  'assets/icons_assets/organization_chart_assets/managerOutlined.svg',
                  'assets/icons_assets/organization_chart_assets/MapPoint.svg',
                ],
                personalInfoTexts: hasSupervisor
                    ? [
                  "${S.of(context).department}: ",
                  "${S.of(context).superVisor}: ",
                  "${S.of(context).email}: ",
                  "${S.of(context).phoneNumber}: ",
                  "${S.of(context).title}: ",
                ]
                    : [
                  "${S.of(context).department}: ",
                  "${S.of(context).compensation}: ",
                  "${S.of(context).jobType}: ",
                  "${S.of(context).title}: ",
                  "${S.of(context).manager}: ",
                  "${S.of(context).jobLocation}: ",
                ],
                secondaryTexts: hasSupervisor
                    ? [
                  _orDash(_getDepartmentName()),
                  _orDash(_getSuperVisor()),
                  _getEmail(),
                  _getPhone(),
                  _orDash(_getTitle()),
                ]
                    : [
                  _orDash(_getDepartmentName()),
                  '-', // Job Compensation — not held on the employee record
                  '-', // Job Type — not held on the employee record
                  _orDash(_getTitle()),
                  _orDash(supervisorEmail),
                  _orDash(workLocation),
                ],
              ),

              // Working History
              // Working Hours section
              // COUNT FIX 22/8/2026: five icons were listed against four labels
              // and four values, because the Salary row was commented out of the
              // labels but its `new_sallary.svg` was left in the icon list. Every
              // row below Days Off therefore drew the icon belonging to the row
              // above it. The salary icon is removed with its row.
              //
              // Working Hours and Days Off stay '-' on purpose: there is no
              // corresponding field anywhere on NewEmployeeModelHistory, so
              // there is nothing to read. Wiring them up needs the schema
              // extended first — flagged rather than faked.
              CustomPersonalInfoContainer(
                primaryText: S.of(context).workingHours,
                isPersonalInformation: true,
                isWorkingHours: true, // ✅ NEW FLAG - Enables 3+2 layout
                customIcons: [
                  'assets/icons_assets/organization_chart_assets/new_start_date.svg',
                  'assets/icons_assets/organization_chart_assets/new_work_hourse.svg',
                  'assets/icons_assets/organization_chart_assets/new_day_off.svg',
                  'assets/icons_assets/organization_chart_assets/new_job_location.svg',
                ],
                personalInfoTexts: [
                  "${S.of(context).startDate}: ",
                  "${S.of(context).workingHours}: ",
                  "${S.of(context).daysOff}: ",
                  "${S.of(context).jobLocation}: ",
                ],
                secondaryTexts: [
                  _getStartDate(),
                  '-',
                  '-',
                  _orDash(workLocation),
                ],
              ),

              // Work Schedule
              // General Information section
              CustomPersonalInfoContainer(
                primaryText: S.of(context).generalInformation,
                isPersonalInformation: true,
                isGeneralInfo: true, // ✅ NEW FLAG - Single column layout
                customIcons: [
                  'assets/icons_assets/organization_chart_assets/new_institution_name.svg',
                  'assets/icons_assets/organization_chart_assets/new_degree.svg',
                  'assets/icons_assets/organization_chart_assets/new_start_date.svg',
                  'assets/icons_assets/organization_chart_assets/skills_new.svg',
                  'assets/icons_assets/organization_chart_assets/hobbies_new.svg',
                ],
                personalInfoTexts: [
                  "${S.of(context).institutionName}: ",
                  "${S.of(context).degreeOrCertification}: ",
                  "${S.of(context).graduationYear}: ",
                  "${S.of(context).skills}: ",
                  "${S.of(context).hobbys}: ",
                ],
                secondaryTexts: [
                  _getAcademicField('institutionName'),      // Maps to 'University'
                  _getAcademicField('degreeOrCertification'), // Maps to 'Graduate_From'
                  _getAcademicField('yearOfGraduation'),     // Maps to 'Year_Of_Graduation'
                  _getSkillsString(),                        // Gets skills from employee.skills
                  _getHobbiesString(),                       // Gets hobbies from employee.hobbies
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}