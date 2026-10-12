/// Module: services_management_module
/// Description: Master Upload screen with two steps:
///              Step 1: Bulk Upload Services Data
///              Step 2: Bulk Upload Service Requests (enabled only after
///              Step 1 is done). All Excel parsing, permission requests and
///              email enrichment now live in MasterUploadCubit — this page
///              only owns per-row TextEditingControllers (widget lifecycle)
///              and drives navigation/dialogs.
/// Author: Amr Mesbah
/// Date: 02/07/2026
/// Dependencies: MasterUploadCubit, MasterUploadStepsHeader,
///              MasterUploadArea, MasterUploadFileDisplay
/// Revision History:
///   - Initial version (UI redesigned to match Figma spec).
///   - 02/07/2026 (Knowticed Team): Removed all 8 try/catch blocks — I/O
///     moved to MasterUploadCubit (fix item 4). Extracted steps header,
///     upload area and file-display sections into ui/widgets/ (fix item 5).
///     Removed GetX (Get.find) in favor of a directly-constructed cubit,
///     matching the s2 pattern (fix item 10, scoped to this file).
import 'package:get/get.dart';

import 'package:flutter/material.dart' hide BorderStyle;
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/pages/master_upload_upload_file_details_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/pages/upload_request_details_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/widgets/master_upload_steps_header.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/widgets/master_upload_area.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/widgets/master_upload_file_display.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/controller/master_upload_cubit.dart';

class MasterUploadScreen extends StatefulWidget {
  const MasterUploadScreen({super.key});

  @override
  State<MasterUploadScreen> createState() => _MasterUploadScreenState();
}

class _MasterUploadScreenState extends State<MasterUploadScreen> {
  late final MasterUploadCubit _cubit;

  // ─── Step 1 state (widget-lifecycle — stays on the page) ─────
  bool _step1Completed = false;
  String? _step1FileName;
  int _step1TotalServices = 0;
  int _step1TotalDepartments = 0;
  List<Map<String, TextEditingController>> _step1FormData = [];
  List<Map<String, String>> _step1ValidationErrors = [];

  Future<Map<String, String>> Function()? _step1UploadFunction;

  // ─── Step 2 state ───────────────────────────────────────────
  bool _step2IsDragging = false;
  String? _step2FileName;
  int _step2UniqueServices = 0;
  int _step2UniqueDepartments = 0;
  bool _showStep2Upload = false;

  @override
  void initState() {
    super.initState();
    // Note: MainCoreEmployeeController / MainCoreDepartmentCubit are
    // GetX-registered singletons elsewhere in the app (not migrated to Cubit
    // by this fix — out of scope per item 10, which limits GetX removal to
    // the cubits introduced by this change).
    _cubit = MasterUploadCubit(
      repository: ServicesManagerCubit.get(context).repository,
      employeeController: AppControllers.employee,
      departmentController: context.read<MainCoreDepartmentCubit>(),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  // ─── Step 1: pick & parse ───────────────────────────────────
  // Single UI-boundary catch of the cubit's typed MasterUploadFailure (not a
  // bare `catch (e)` around raw I/O — the I/O itself has no try/catch left
  // in this page, see MasterUploadCubit).
  Future<void> _pickStep1File() async {
    ParsedStepResult? result;
    try {
      result = await _cubit.pickAndParseStep1();
    } on MasterUploadFailure catch (e) {
      _showErrorDialog(_failureText(e));
      return;
    }
    if (result == null) return;
    _applyStep1Result(result.formData, result.validationErrors, result.fileName);
  }

  void _applyStep1Result(
    List<Map<String, TextEditingController>> parsedFormData,
    List<Map<String, String>> parsedErrors,
    String fileName,
  ) {
    final Set<String> deptSet = {};
    for (final row in parsedFormData) {
      final depts = row['Departments']?.text ?? '';
      if (depts.isNotEmpty) {
        depts
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .forEach(deptSet.add);
      }
    }

    setState(() {
      _step1FileName = fileName;
      _step1FormData = parsedFormData;
      _step1ValidationErrors = parsedErrors;
      _step1TotalServices = parsedFormData.length;
      _step1TotalDepartments = deptSet.length;
    });

    navigateTo(
      context,
      ToggleUploadFileDetailsMaster(
        formData: parsedFormData,
        validationErrors: parsedErrors,
        selectedFileName: fileName,
        onActivated: (Future<Map<String, String>> Function() uploadFn) async {
          setState(() {
            _step1Completed = true;
            _step1UploadFunction = uploadFn;
          });
        },
      ),
    );
  }

  // ─── Step 2: pick & parse ───────────────────────────────────
  Future<void> _pickStep2File() async {
    if (!_step1Completed) return;
    ParsedStepResult? result;
    try {
      result = await _cubit.pickAndParseStep2();
    } on MasterUploadFailure catch (e) {
      _showErrorDialog(_failureText(e));
      return;
    }
    if (result == null) return;
    _applyStep2Result(result.formData, result.validationErrors, result.fileName);
  }

  void _applyStep2Result(
    List<Map<String, TextEditingController>> parsedFormData,
    List<Map<String, String>> parsedErrors,
    String fileName,
  ) {
    final employeeController = AppControllers.employee;
    final Set<String> uniqueServices = {};
    final Set<String> uniqueDepts = {};

    for (final row in parsedFormData) {
      final serviceName = row['Service Name']?.text.trim() ?? '';
      if (serviceName.isNotEmpty) uniqueServices.add(serviceName);

      final requester = row['Email Requester']?.text.trim() ?? '';
      if (requester.isNotEmpty &&
          employeeController.mapOfEmployeesWithEmailKey.containsKey(requester)) {
        final emp = employeeController.mapOfEmployeesWithEmailKey[requester];
        if (emp?.departmentId != null && emp!.departmentId!.isNotEmpty) {
          uniqueDepts.add(emp.departmentId!);
        }
      }
    }

    setState(() {
      _step2FileName = fileName;
      _step2UniqueServices = uniqueServices.length;
      _step2UniqueDepartments = uniqueDepts.length;
    });

    navigateTo(
      context,
      UploadRequestsDetailsToggle(
        formData: parsedFormData,
        validationErrors: parsedErrors,
        selectedFileName: fileName,
        uploadedServicesFormData: _step1FormData,
        step1UploadFunction: _step1UploadFunction,
      ),
    );
  }

  // ─── Drag & Drop Step 2 ─────────────────────────────────────
  Future<void> _onStep2DragDone(DropDoneDetails details) async {
    if (!_step1Completed) return;
    setState(() => _step2IsDragging = false);
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final name = file.name.toLowerCase();
    if (!name.endsWith('.xlsx') && !name.endsWith('.xls')) {
      // ✅ Was a hardcoded English sentence — this key already existed.
      _showErrorDialog(S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }
    final bytes = await file.readAsBytes();
    ParsedStepResult result;
    try {
      await _cubit.ensureEmployeesLoaded();
      result = _cubit.parseDroppedStep2File(bytes, file.name);
    } on MasterUploadFailure catch (e) {
      _showErrorDialog(_failureText(e));
      return;
    }
    _applyStep2Result(result.formData, result.validationErrors, result.fileName);
  }

  /// The cubit cannot translate — it has no BuildContext. When the failure
  /// carries structured column names we build the localized sentence here.
  String _failureText(MasterUploadFailure e) {
    if (e.missingColumns.isEmpty) return e.message;
    return '${S.of(context).missingRequiredColumns}: '
        '${e.missingColumns.join(', ')}';
  }

  // ───────────────────────── Dialogs ──────────────────────────
  //
  // ✅ CHANGED 31/8/2026: the dialog on this screen
  //   • is bilingual (AR/EN) — everything with an .arb key goes through
  //     S.of(context); see [_localized] for the two strings that have none yet,
  //   • uses AppColors.card as its background, and
  //   • closes itself after [_dialogAutoDismiss]. The OK button is gone and
  //     there is nothing to tap.

  /// How long the message dialog stays on screen before closing itself.
  static const Duration _dialogAutoDismiss = Duration(seconds: 3);

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// Picks the Arabic or English variant for the strings on this screen that
  /// have no key in intl_en.arb / intl_ar.arb yet. Move them into the .arb
  /// files in the next localisation pass and this helper disappears.
  String _localized({required String en, required String ar}) =>
      _isArabic ? ar : en;

  /// Shows the error dialog, which dismisses itself after [_dialogAutoDismiss].
  ///
  /// The close runs off the dialog's OWN context and is a no-op once that route
  /// is gone — the user can still tap the barrier, and this page can be popped,
  /// before the timer fires. Popping by the page's context instead would tear
  /// down whatever route happened to be on top by then, or throw "Looking up a
  /// deactivated widget's ancestor".
  void _showErrorDialog(String message) {
    BuildContext? dialogContext;
    var isClosed = false;

    void closeDialog() {
      if (isClosed) return;
      isClosed = true;
      final ctx = dialogContext;
      if (ctx != null && ctx.mounted) {
        Navigator.of(ctx, rootNavigator: true).maybePop();
      }
    }

    Future.delayed(_dialogAutoDismiss, closeDialog);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx;
        return AlertDialog(
          backgroundColor: AppColors.card,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                  width: 90.sp,
                  height: 90.sp),
              SizedBox(height: 16.sp),
              Text(S.of(ctx).error,
                  style: StyleText.fontSize20Weight500
                      .copyWith(color: AppColors.text),
                  textAlign: TextAlign.center),
              SizedBox(height: 8.sp),
              Text(message,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.secondaryText),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      },
    ).then((_) => isClosed = true);
  }

  // ─── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return BlocProvider.value(
      value: _cubit,
      child: SlideInContent(
        from: SlideFrom.bottom,
        child: SideFrameMasterServices(
          titleText: S.of(context).service,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).masterUpload,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MasterUploadStepsHeader(step1Completed: _step1Completed),
                SizedBox(height: 24.sp),
                _buildMainContentCard(lightMode),
                SizedBox(height: 24.sp),
                _buildBottomButtons(lightMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentCard(bool lightMode) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_step1Completed && _step1FileName != null)
            _buildUploadedFileDisplay(isStep2: false)
          else
            MasterUploadArea(
              isStep2: false,
              isDisabled: false,
              isDragging: false,
              onTap: _pickStep1File,
            ),
          if (_showStep2Upload) ...[
            SizedBox(height: 24.sp),
            Divider(color: AppColors.secondaryText.withOpacity(0.3)),
            SizedBox(height: 16.sp),
            Text(S.of(context).step2ServiceRequests,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(height: 12.sp),
            if (_step2FileName != null)
              _buildUploadedFileDisplay(isStep2: true)
            else
              MasterUploadArea(
                isStep2: true,
                isDisabled: !_step1Completed,
                isDragging: _step2IsDragging,
                onTap: _pickStep2File,
                onDragStateChanged: (dragging) =>
                    setState(() => _step2IsDragging = dragging),
                onDragDone: _onStep2DragDone,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadedFileDisplay({required bool isStep2}) {
    return MasterUploadFileDisplay(
      // ✅ The 'Resume 1.pdf' fallbacks were a leftover design placeholder —
      // an English filename for a file the user never picked, and for a .pdf
      // this screen does not even accept. This section only renders once a file
      // IS selected, so both fallbacks were unreachable in practice; they now
      // read as "no file selected", which already has an .arb key.
      fileName: isStep2
          ? (_step2FileName ?? S.of(context).noFileSelected)
          : (_step1FileName ?? S.of(context).noFileSelected),
      totalServicesLabel: isStep2
          ? S.of(context).uniqueServices
          : S.of(context).totalServices,
      totalServicesValue: isStep2
          ? _step2UniqueServices.toString()
          : _step1TotalServices.toString(),
      totalDepartmentsLabel: isStep2
          // ✅ Was English-only. No .arb key for this one yet — see [_localized].
          ? _localized(
              en: 'Unique Department Requesters',
              ar: 'الأقسام الطالبة الفريدة',
            )
          : S.of(context).totalOwningDepartments,
      totalDepartmentsValue: isStep2
          ? _step2UniqueDepartments.toString()
          : _step1TotalDepartments.toString(),
      onEdit: () {
        if (isStep2) {
          // Navigate to Step 2 edit
        } else {
          navigateTo(
            context,
            ToggleUploadFileDetailsMaster(
              formData: _step1FormData,
              validationErrors: _step1ValidationErrors,
              selectedFileName: _step1FileName,
              onActivated: (Future<Map<String, String>> Function() uploadFn) async {
                setState(() {
                  _step1Completed = true;
                  _step1UploadFunction = uploadFn;
                });
              },
            ),
          );
        }
      },
      onDelete: () {
        if (isStep2) {
          setState(() {
            _step2FileName = null;
            _step2UniqueServices = 0;
            _step2UniqueDepartments = 0;
          });
        } else {
          setState(() {
            _step1Completed = false;
            _step1FileName = null;
            _step1FormData = [];
            _step1ValidationErrors = [];
            _step1TotalServices = 0;
            _step1TotalDepartments = 0;
            _step1UploadFunction = null;
            _showStep2Upload = false;
          });
        }
      },
    );
  }

  Widget _buildBottomButtons(bool lightMode) {
    final showNext = _step1Completed && _step2FileName == null;
    final showActivate = _step2FileName != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.of(context).discard,
          function: () {
            Navigator.pop(context);
          },
          width: 150.w,
          height: 38.h,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction),
          color: AppColors.secondaryAction,
        ),
        if (showNext || showActivate)
          customButton(
            title: S.of(context).next,
            function: () {
              if (showNext) {
                setState(() {
                  _showStep2Upload = true;
                });
              }
              // else if (showActivate): activation is handled on the Step 2
              // details screen (UploadRequestsDetailsScreen.uploadToFirebase).
            },
            width: 150.w,
            height: 38.h,
            radius: 8.r,
            color: AppColors.primary,
            textStyle: StyleText.fontSize16Weight400.copyWith(
              color: AppColors.textButton,
            ),
          ),
      ],
    );
  }
}
