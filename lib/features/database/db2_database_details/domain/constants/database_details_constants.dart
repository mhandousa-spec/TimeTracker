/// Module: database / db2_database_details / domain / constants
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_constants.dart
/// Purpose: Declares `DatabaseGrantFields`, `DatabaseDetailsAssets` and
///          `DatabaseDetailsStrings`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The copy and the field names for the Figma section
/// "INSIDE DATABASE PAGE: Giving Accesses , Editing , Deleting".
///
/// Same arrangement as db1's `create_database_constants.dart`, and for the
/// same reason: these keys are not in `lib/l10n/intl_*.arb` yet and adding
/// them means a codegen run on a machine with the Flutter SDK. The module
/// ships its own en/ar table resolved through `context.isArabic` — the signal
/// the rest of the app already uses for RTL — and the migration is a key-for-
/// key move into the .arb pair plus swapping `DatabaseDetailsStrings.of` for
/// `S.of`. Nothing outside this file changes.
///
/// The COLLECTION path is deliberately NOT re-declared here. It lives in
/// `CreateDatabaseCollections` and this module imports it: two constants for
/// one Firestore path is how a module ends up reading from a collection
/// nothing writes to.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Keys inside an `Access_Grants` document that db1's `DatabaseAccessGrant`
/// does not know about.
///
/// `DatabaseAccessGrant.toMap()` writes the grant itself; this module merges
/// these on top when it rewrites a document. They are named here rather than
/// inline because the write path and the read path are in different files and
/// a typo between them is a silently empty column.
abstract final class DatabaseGrantFields {
  /// People whose access was revoked — see `RemovedAccessMember`.
  static const String removedMembers = 'removed_members';

  /// Employee id of whoever granted the access ("Access Grantor").
  static const String grantedBy = 'granted_by';
  static const String grantedByNameEn = 'granted_by_name_en';
  static const String grantedByNameAr = 'granted_by_name_ar';

  /// Server timestamp of the last rewrite. Not rendered anywhere yet; written
  /// so a support question about when a grant changed has an answer that does
  /// not depend on Firestore's history being enabled.
  static const String updatedAt = 'updated_at';
}

/// Icons this section uses, all already in the app's asset bundle.
///
/// Named constants rather than inline strings because the same icon appears on
/// two or three screens each — the Access button is on the details page and
/// the edit-access footer — and a renamed asset should break the build in one
/// place, not go missing from a button at runtime.
abstract final class DatabaseDetailsAssets {
  static const String _main = 'assets/icons_assets/main_icons_assets';
  static const String _roles = 'assets/icons_assets/roles_assets';
  static const String _database = 'assets/icons_assets/database_builder_assets';

  /// The people-and-key glyph on the "Access" button (Figma 7398:735).
  static const String access = '$_main/user_access_workflow.svg';

  /// "Edit Access" on the Access screen (Figma 7398:10662).
  static const String editAccess = '$_roles/edit_access.svg';

  static const String edit = '$_main/edit_pencil_square.svg';

  /// Note the space in the file name — that is how the asset is named in
  /// `assets/icons_assets/main_icons_assets`, and pubspec ships the folder.
  static const String delete = '$_main/icon _trash.svg';

  static const String export = '$_main/export_arrow.svg';

  /// The "+" on the "+ Table" button.
  static const String addTable = '$_database/plus_head.svg';

  /// Placeholder inside the info card's thumbnail.
  static const String databaseGlyph = '$_database/create_data_base.svg';
}

/// "28 Nov 2025" — the one date format this whole section uses.
///
/// The Figma writes dates that way everywhere it writes them: the info card's
/// Creation and Last Edit lines, both date columns of the Access table, and
/// the exported CSV. db1 has the same formatter twice already (in
/// `access_rule_fields.dart` and in the list card), which is exactly how three
/// screens end up disagreeing about whether the month is a number — so this
/// module keeps ONE, and the CSV shares it with the table it was exported
/// from.
abstract final class DatabaseDateFormat {
  static const List<String> _monthsEn = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _monthsAr = <String>[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// [placeholder] is what an absent date renders as. An em dash on screen,
  /// where a column still has to occupy its width; an empty string in a CSV,
  /// where a dash would be read as data by whatever opens the file.
  static String short(
    DateTime? date, {
    required bool isArabic,
    String placeholder = '—',
  }) {
    if (date == null) return placeholder;
    final List<String> months = isArabic ? _monthsAr : _monthsEn;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// The section's copy, in the two locales the app ships.
class DatabaseDetailsStrings {
  const DatabaseDetailsStrings._(this._isArabic);

  final bool _isArabic;

  factory DatabaseDetailsStrings.of(BuildContext context) =>
      DatabaseDetailsStrings._(context.isArabic);

  String _pick(String en, String ar) => _isArabic ? ar : en;

  // ── Breadcrumbs ──────────────────────────────────────────────────────────
  String get database => _pick('Database', 'قاعدة البيانات');

  /// Third crumb on the details screen. The Figma writes the record's name
  /// followed by the word "Details"; the name is substituted by the caller.
  String detailsCrumb(String title) =>
      _pick('$title Details', 'تفاصيل $title');

  String get accessCrumb => _pick('Access', 'الوصول');

  String editingCrumb(String title) =>
      _pick('Editing $title', 'تعديل $title');

  String get editingDatabaseAccess =>
      _pick('Editing Database Access', 'تعديل صلاحيات قاعدة البيانات');

  String get editingAccessManagement =>
      _pick('Editing Access Management', 'تعديل إدارة الوصول');

  // ── Details page actions (Figma 7398:735 / 847) ──────────────────────────
  String get access => _pick('Access', 'الوصول');
  String get edit => _pick('Edit', 'تعديل');
  String get delete => _pick('Delete', 'حذف');
  String get hide => _pick('Hide', 'إخفاء');
  String get expand => _pick('Expand', 'عرض');
  String get databaseDetails => _pick('Database Details', 'تفاصيل قاعدة البيانات');

  String get accessManagementLabel =>
      _pick('Access Management:', 'إدارة الوصول:');
  String get descriptionLabel => _pick('Description:', 'الوصف:');
  String get creationLabel => _pick('Creation:', 'الإنشاء:');
  String get lastEditLabel => _pick('Last Edit:', 'آخر تعديل:');
  String get noDescription =>
      _pick('No description was added.', 'لم تتم إضافة وصف.');

  // ── Details toolbar ──────────────────────────────────────────────────────
  String get search => _pick('Search', 'بحث');
  String get filter => _pick('Filter', 'تصفية');
  String get sort => _pick('Sort', 'ترتيب');
  String get reset => _pick('Reset', 'إعادة تعيين');
  String get apply => _pick('Apply', 'تطبيق');
  /// The label on the "+ Table" button. The button now opens db3's Creating
  /// Table card; the empty-state and column headings of the list underneath it
  /// belong to that module and live in `CreateTableStrings`.
  ///
  /// REMOVED 16/8/2026, with the section they were placeholders for:
  /// `noTablesYet`, `tableBuilderPendingTitle` and `tableBuilderPending`. The
  /// first is now `CreateTableStrings.noTablesYet` — one owner, next to the
  /// widget that draws it — and the other two said "not wired up yet" about a
  /// screen that exists.
  String get table => _pick('Table', 'جدول');

  // ── Access screen (Figma 7398:10662 / 10875) ─────────────────────────────
  String get editAccess => _pick('Edit Access', 'تعديل الوصول');
  String get export => _pick('Export', 'تصدير');
  String get all => _pick('All', 'الكل');
  String get activeChip => _pick('Active', 'نشط');
  String get deactivatedChip => _pick('Deactivated', 'موقوف');
  String get removedChip => _pick('Removed', 'مُزال');
  String get scheduledChip => _pick('Scheduled', 'مجدول');

  // Table headers — `Group 1597882843`.

  /// Heading of the picture column on the ACCESS table (`access_table.dart`),
  /// which still has one.
  ///
  // `colPicture` REMOVED 17/8/2026. Both tables in this section now put the
  // face in front of the NAME rather than in a column of its own — the member
  // list on 16/8/2026, the access table today — so the heading has no caller
  // left. It also brings the on-screen table and the exported CSV to the same
  // seven columns, which they were not before.
  String get colName => _pick('Employee Name', 'اسم الموظف');
  String get colDepartment => _pick('Department', 'القسم');
  String get colJobTitle => _pick('Job Title', 'المسمى الوظيفي');
  String get colGrantor => _pick('Access Grantor', 'مانح الوصول');
  String get colStart => _pick('Start Date Of Access', 'تاريخ بداية الوصول');
  String get colEnd => _pick('End Date Of Access', 'تاريخ نهاية الوصول');
  String get colAccessType => _pick('Access Type', 'نوع الوصول');
  String get colAccessStatus => _pick('Access Status', 'حالة الوصول');

  String get noAccessYet => _pick(
        'Nobody has been granted access to this database yet.',
        'لم يتم منح صلاحية الوصول لأحد بعد.',
      );
  String get noAccessMatches => _pick(
        'No access rows match this filter.',
        'لا توجد صلاحيات مطابقة لهذه التصفية.',
      );

  // ── Export ───────────────────────────────────────────────────────────────
  String get exportEmptyTitle => _pick('Nothing To Export', 'لا شيء للتصدير');
  String get exportEmpty => _pick(
        'There are no access rows on screen to export.',
        'لا توجد صلاحيات معروضة لتصديرها.',
      );
  String get exportDoneTitle => _pick('Export Ready', 'تم التصدير');
  String exportDone(String fileName) => _pick(
        'Saved $fileName and opened the share sheet.',
        'تم حفظ $fileName وفتح قائمة المشاركة.',
      );
  String get exportFailedTitle => _pick('Export Failed', 'تعذر التصدير');
  String get exportFailed => _pick(
        'The access list could not be written to a file.',
        'تعذر كتابة قائمة الصلاحيات في ملف.',
      );

  // ── Edit database (Figma 7398:6461 / 16968) ──────────────────────────────
  String get discardChanges => _pick('Discard Changes', 'تجاهل التغييرات');
  String get save => _pick('Save', 'حفظ');
  String get databaseTitleEn => 'Database Title';
  String get databaseTitleAr => 'عنوان قاعدة بيانات';
  String get descriptionEn => 'Description';
  String get descriptionAr => 'الوصف';
  String get hintEn => 'Text here';
  String get hintAr => 'اكتب هنا';

  /// The Figma's confirm/success pair for every edit path
  /// (Frames 1597883137 / 1597883138 and their per-screen copies).
  String get editConfirmTitle => _pick('Editing Database', 'تعديل قاعدة البيانات');
  String get editConfirmSubtitle => _pick(
        'Are You Sure You Want To Edit This Database?',
        'هل أنت متأكد من تعديل قاعدة البيانات هذه؟',
      );
  String get editSuccessSubtitle => _pick(
        'You Successfully Edited This Database',
        'تم تعديل قاعدة البيانات بنجاح',
      );

  String get discardConfirmTitle => _pick('Discard Changes', 'تجاهل التغييرات');
  String get discardConfirmSubtitle => _pick(
        'Your changes have not been saved. Leave without saving?',
        'لم يتم حفظ تغييراتك. هل تريد الخروج بدون حفظ؟',
      );
  String get nothingChangedTitle => _pick('Nothing Changed', 'لا توجد تغييرات');
  String get nothingChanged => _pick(
        'Nothing on this screen has been changed yet.',
        'لم يتم تغيير أي شيء في هذه الشاشة بعد.',
      );

  // ── Edit access (Figma 7398:9476 / 10176 / 10612 / 18356) ────────────────
  String get accessManagement => _pick('Access Management', 'إدارة الوصول');
  String get department => _pick('Department', 'القسم');
  String get permissions => _pick('Permissions', 'الصلاحيات');
  String get choosePermissions => _pick('Choose Permissions', 'اختر الصلاحيات');
  String get selectPermission => _pick('Select Permission', 'اختر الصلاحية');
  String get employeeInformation =>
      _pick('Employee  Information', 'بيانات الموظف');
  String get selectAll => _pick('Select All', 'تحديد الكل');
  String get deselectAll => _pick('Deselect All', 'إلغاء تحديد الكل');
  String get review => _pick('Review', 'مراجعة');
  String get grantAccess => _pick('Grant Access', 'منح الوصول');
  String get accessBegins => _pick('Access Begins', 'بداية الوصول');
  String get accessEnds => _pick('Access Ends', 'نهاية الوصول');
  String get startDateOfAccess =>
      _pick('Start Date Of Access', 'تاريخ بداية الوصول');
  String get endDateOfAccess =>
      _pick('End Date Of Access', 'تاريخ نهاية الوصول');
  String get date => _pick('Date', 'التاريخ');
  String get jobTitleLabel => _pick('Job Title:', 'المسمى الوظيفي:');
  String get departmentLabel => _pick('Department:', 'القسم:');
  String get noEmployeesFound => _pick('No employees found', 'لا يوجد موظفون');

  /// Shown on the Open variant before any department has been picked.
  ///
  /// Every pick on that screen belongs to the department in focus, so with no
  /// department there is nowhere for a selection to go — the grid is held back
  /// and says why.
  String get pickDepartmentFirst => _pick(
        'Choose one or more departments above, then pick the people inside '
            'them.',
        'اختر قسمًا أو أكثر بالأعلى، ثم اختر الأشخاص داخله.',
      );
  String get summary => _pick('Summary', 'الملخص');
  String get totalEmployees => _pick('Total Employees', 'إجمالي الموظفين');
  String get totalDepartments => _pick('Total Departments', 'إجمالي الأقسام');

  /// The Personal Access screen (7398:10612) has nothing under the dropdown.
  /// An empty white card reads as a screen that failed to load, so it says
  /// what the empty state MEANS.
  String get personalAccessExplainer => _pick(
        'A personal database belongs to you alone. Nobody else is granted '
            'access, so there is nothing to configure here.',
        'قاعدة البيانات الشخصية ملك لك وحدك. لا يتم منح الوصول لأي شخص آخر، '
            'لذلك لا يوجد ما يتم ضبطه هنا.',
      );

  /// Shown when switching a database that already has grants to Personal.
  String get personalDropsGrantsTitle =>
      _pick('Remove All Access?', 'إزالة جميع الصلاحيات؟');
  String personalDropsGrants(int count) => _pick(
        'Personal access is for you alone. Saving will revoke access for the '
            '$count people who have it now.',
        'الوصول الشخصي لك وحدك. سيؤدي الحفظ إلى إلغاء وصول $count أشخاص لديهم '
            'الصلاحية الآن.',
      );

  /// Shown when switching between Open and Restricted with people already
  /// picked. Worded around the SELECTION rather than around revoking, because
  /// nothing is written until Save — what is lost here is the picking work,
  /// and the people keep their access until the save happens.
  String get accessTypeChangeTitle =>
      _pick('Change Access Type?', 'تغيير نوع الوصول؟');
  String accessTypeChangeSubtitle(int count) => _pick(
        'Open and Restricted access choose people in different ways, so the '
            '$count people picked here will be cleared and have to be chosen '
            'again.',
        'يختار الوصول المفتوح والمقيد الأشخاص بطرق مختلفة، لذلك سيتم مسح '
            '$count أشخاص تم اختيارهم هنا وسيلزم اختيارهم من جديد.',
      );

  String get pickSomeoneFirst => _pick(
        'Select at least one person before continuing.',
        'اختر شخصًا واحدًا على الأقل قبل المتابعة.',
      );
  String get incompleteGrants => _pick(
        'Choose a permission level and both dates for every group.',
        'اختر مستوى الصلاحية وكلا التاريخين لكل مجموعة.',
      );
  String get incompleteRows => _pick(
        'Choose a permission level and both dates for every person you picked.',
        'اختر مستوى الصلاحية وكلا التاريخين لكل شخص اخترته.',
      );

  String get accessSavedTitle => _pick('Access Updated', 'تم تحديث الوصول');
  String get accessSavedSubtitle => _pick(
        'You Successfully Edited This Database',
        'تم تعديل قاعدة البيانات بنجاح',
      );

  // ── Delete (reuses db1's write path) ─────────────────────────────────────
  String get deleteConfirmTitle =>
      _pick('Delete Database', 'حذف قاعدة البيانات');
  String deleteConfirmSubtitle(String title) => _pick(
        'Are you sure you want to delete "$title"? Its access grants are '
            'removed with it and this cannot be undone.',
        'هل أنت متأكد من حذف "$title"؟ سيتم حذف صلاحيات الوصول إليها ولا يمكن '
            'التراجع عن ذلك.',
      );
  String get deleteFailedTitle => _pick('Delete Failed', 'تعذر الحذف');
  String get deletedTitle => _pick('Database Deleted', 'تم حذف قاعدة البيانات');
  String deletedSubtitle(String title) => _pick(
        '"$title" and its access grants have been removed.',
        'تم حذف "$title" وصلاحيات الوصول الخاصة بها.',
      );

  // ── Shared ───────────────────────────────────────────────────────────────
  String get yes => _pick('Yes', 'نعم');
  String get no => _pick('No', 'لا');
  String get close => _pick('Close', 'إغلاق');
  String get retry => _pick('Retry', 'إعادة المحاولة');
  String get errorTitle => _pick('Something Went Wrong', 'حدث خطأ ما');
  String get incompleteTitle => _pick('Missing Information', 'معلومات ناقصة');
  String get couldNotSave => _pick(
        'The changes could not be saved. Check your connection and try again.',
        'تعذر حفظ التغييرات. تحقق من الاتصال وحاول مرة أخرى.',
      );
  String get couldNotLoad => _pick(
        'This database could not be read. Check your connection and try again.',
        'تعذر قراءة قاعدة البيانات. تحقق من الاتصال وحاول مرة أخرى.',
      );

  // ── Validation ───────────────────────────────────────────────────────────
  String get titleEnRequired =>
      _pick('English title is required', 'العنوان بالإنجليزية مطلوب');
  String get titleArRequired =>
      _pick('Arabic title is required', 'العنوان بالعربية مطلوب');
  String titleTooShort(int min) => _pick(
        'Title must be at least $min characters',
        'يجب ألا يقل العنوان عن $min حروف',
      );
  String get duplicateTitle => _pick(
        'Another database already uses this title. Change it and try again.',
        'توجد قاعدة بيانات أخرى بهذا الاسم. غيّره وحاول مرة أخرى.',
      );
}
