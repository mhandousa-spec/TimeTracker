/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: debug_test_employee_switch_screen.dart
/// Purpose: DEBUG-ONLY picker of the "Switch to test employee" sign-in:
///          company id (prefilled with the last-used company) → the test
///          employees of `Demo/{cid}/Employees_Info` (name, role, department)
///          → tap one to sign in as them.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 - DEBUG-ONLY (owner-approved option B; see
///            data/utils/debug_test_employee_switch.dart)
///
/// Only ever pushed by `openDebugTestEmployeeSwitch`, whose callers are all
/// built under `kDebugTestEmployeeSwitchBuild` (compile-time false in release
/// and profile), so this screen is tree-shaken from client builds. It also
/// re-checks the run-time guard and renders nothing usable without it.
///
/// No password is shown, typed or held here: the rows carry name, role,
/// department, email and status only. State: plain StatefulWidget + the
/// existing GetX `LoginController` (the onboarding pattern; not refactored).

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/debug_test_employee.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// DEBUG-ONLY 9/10/2026 — the test-employee picker.
class DebugTestEmployeeSwitchScreen extends StatefulWidget {
  const DebugTestEmployeeSwitchScreen({super.key});

  @override
  State<DebugTestEmployeeSwitchScreen> createState() =>
      _DebugTestEmployeeSwitchScreenState();
}

class _DebugTestEmployeeSwitchScreenState
    extends State<DebugTestEmployeeSwitchScreen> {
  final TextEditingController _companyIdController = TextEditingController();

  /// Resolved, not constructed: the sign-in screen (or the running session)
  /// already registered the one LoginController.
  late final LoginController _loginController =
      Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : Get.put(LoginController());

  bool _loading = false;
  bool _failed = false;
  List<DebugTestEmployee>? _employees;

  /// The company the current list belongs to (what a tap signs in against).
  String _loadedCompanyId = '';

  @override
  void initState() {
    super.initState();
    _prefillAndLoad();
  }

  @override
  void dispose() {
    _companyIdController.dispose();
    super.dispose();
  }

  Future<void> _prefillAndLoad() async {
    if (!isDebugTestEmployeeSwitchEnabled()) return;
    final String companyId = await _loginController.debugLastUsedCompanyId();
    if (!mounted) return;
    _companyIdController.text = companyId;
    await _load();
  }

  Future<void> _load() async {
    if (!isDebugTestEmployeeSwitchEnabled()) return;
    final String companyId = _companyIdController.text.trim();
    if (companyId.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _failed = false;
    });
    final Either<Failure, List<DebugTestEmployee>> result =
        await _loginController.debugLoadTestEmployees(companyId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _failed = result.isLeft();
      _employees = result.getOrElse(() => <DebugTestEmployee>[]);
      _loadedCompanyId = companyId;
    });
  }

  Future<void> _signInAs(DebugTestEmployee employee) async {
    HapticController.medium();
    await _loginController.debugSignInAsTestEmployee(
      context,
      companyId: _loadedCompanyId,
      email: employee.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool enabled = isDebugTestEmployeeSwitchEnabled();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 15.sp, end: 15.sp, top: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      s.debugTestEmployeeTitle,
                      style: StyleText.fontSize18Weight600
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey<String>('debugTestEmployeeClose'),
                    onPressed: () {
                      HapticController.low();
                      Navigator.of(context).maybePop();
                    },
                    icon: Icon(Icons.close, color: AppColors.text, size: 22.sp),
                  ),
                ],
              ),
              SizedBox(height: 4.sp),
              Text(
                enabled ? s.debugTestEmployeeHint : s.debugTestEmployeeDebugOnly,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
              if (enabled) ...<Widget>[
                SizedBox(height: 12.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        key: const ValueKey<String>('debugTestEmployeeCompanyId'),
                        height: 36,
                        controller: _companyIdController,
                        hint: s.debugTestEmployeeCompanyId,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _load(),
                        fillColor: AppColors.card,
                        valueStyle: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.text),
                        hintStyle: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    customButton(
                      title: s.debugTestEmployeeLoad,
                      function: _load,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize14Weight600
                          .copyWith(color: AppColors.textButton),
                    ),
                  ],
                ),
                SizedBox(height: 12.sp),
                Expanded(child: _list(s)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(S s) {
    if (_loading) return const Center(child: CircleProgressMaster());
    if (_failed) return _message(s.debugTestEmployeeLoadFailed);
    final List<DebugTestEmployee>? employees = _employees;
    if (employees == null) return const SizedBox.shrink();
    if (employees.isEmpty) {
      return _message(
          s.debugTestEmployeeEmpty(kDebugTestEmailDomains.join(', ')));
    }
    final bool arabic = context.isArabic;
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 15.sp),
      itemCount: employees.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.sp),
      itemBuilder: (BuildContext context, int index) {
        final DebugTestEmployee employee = employees[index];
        final String role = employee.role.isEmpty
            ? s.debugTestEmployeeNoRole
            : FormatHelper.capitalize(employee.role);
        final String departmentName = employee.department(arabic: arabic);
        final String department = departmentName.isEmpty
            ? s.debugTestEmployeeNoDepartment
            : (arabic ? departmentName : FormatHelper.capitalize(departmentName));
        final String name = employee.name(arabic: arabic);
        return Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: ValueKey<String>('debugTestEmployee_${employee.email}'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => _signInAs(employee),
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    arabic ? name : FormatHelper.capitalize(name),
                    style: StyleText.fontSize14Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    '$role · $department',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    employee.email,
                    textDirection: TextDirection.ltr,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  if (!employee.isActive) ...<Widget>[
                    SizedBox(height: 4.sp),
                    Text(
                      s.debugTestEmployeeStatus(employee.status),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.red),
                    ),
                  ],
                  // CHANGED 9/10/2026 — DEBUG-ONLY: not activated is only a
                  // grey note; the switch still signs a test account in.
                  if (employee.isActivated == false) ...<Widget>[
                    SizedBox(height: 4.sp),
                    Text(
                      s.debugTestEmployeeNotActivatedNote,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _message(String text) => Padding(
        padding: EdgeInsets.only(top: 24.sp),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
}
