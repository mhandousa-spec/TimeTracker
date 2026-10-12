/// Module: GRC / Approved Evidence
///
///*************************** FILE INFO ****************************///
/// File Name: approved_evidence_page.dart
/// Purpose: "Approved Evidence" (MAGDY → "MAIN PAGE : Approved Evidence"),
///          opened from the module page's Approved Evidence button.
///            * "Approved Evidence Details" card: Years, Departments,
///              Policies, Controls — multi-select pickers
///              (CustomMultiSelectDropdown, core/custom/31), each with its
///              picks as removable chips under it (GrcAssignmentChip). Each
///              picker offers "All".
///            * Discard (clears the filters; leaves the page when there is
///              nothing to clear) and Download, which exports the matching
///              approved evidence to CSV through the app's Download File
///              dialog (CustomDialogManager.showExport, core/custom/57).
///          Layout per width — MAGDY only draws 768, so 1024 follows it and
///          375 follows the other GRC phone screens:
///            * tablet / desktop: pickers two per row, Discard leading and
///              Download trailing, 150 wide each.
///            * phone: pickers stacked, Discard | Download as equal halves.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/domain/entities/approved_evidence_data.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/presentation/controller/approved_evidence_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Strings the ARB files do not have yet.
String _tr(BuildContext context, String en, String ar) =>
    context.isArabic ? ar : en;

/// Value of the "All" row in every picker.
const String _all = '__all__';

/// class name: [ApprovedEvidencePage]
class ApprovedEvidencePage extends StatelessWidget {
  final GRCModuleEntity module;

  const ApprovedEvidencePage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApprovedEvidenceCubit>(
      create: (_) => ApprovedEvidenceCubit.create(module.moduleId)..load(),
      child: _ApprovedEvidenceBody(module: module),
    );
  }
}

/// The four pickers.
enum _Field { years, departments, policies, controls }

class _ApprovedEvidenceBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _ApprovedEvidenceBody({required this.module});

  @override
  State<_ApprovedEvidenceBody> createState() => _ApprovedEvidenceBodyState();
}

class _ApprovedEvidenceBodyState extends State<_ApprovedEvidenceBody> {
  /// Pickers where the user chose "All" (shown as an "All" chip). An empty
  /// selection means all either way; this only drives the chip.
  final Set<_Field> _allChosen = <_Field>{};

  ApprovedEvidenceCubit get _cubit => context.read<ApprovedEvidenceCubit>();

  bool get _isMobile => screenSizeOf(context) == ScreenSize.mobile;

  // ── selection plumbing ────────────────────────────────────────────────

  /// Turns the multi-select's raw list into the new selection, handling
  /// the "All" row: picking All clears the others, picking anything else
  /// drops All.
  Set<String> _resolve(_Field field, List<String> raw) {
    final bool hadAll = _allChosen.contains(field);
    final bool hasAll = raw.contains(_all);
    setState(() {
      if (hasAll && !hadAll) {
        _allChosen.add(field);
      } else {
        _allChosen.remove(field);
      }
    });
    if (hasAll && !hadAll) return const <String>{};
    return raw.where((v) => v != _all).toSet();
  }

  void _onChanged(_Field field, List<String> raw) {
    final Set<String> picked = _resolve(field, raw);
    switch (field) {
      case _Field.years:
        _cubit.setYears({for (final y in picked) int.parse(y)});
      case _Field.departments:
        _cubit.setDepartments(picked);
      case _Field.policies:
        _cubit.setPolicies(picked);
      case _Field.controls:
        _cubit.setControls(picked);
    }
  }

  void _discard() {
    final bool nothingToClear =
        !_cubit.state.hasFilters && _allChosen.isEmpty;
    if (nothingToClear) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(_allChosen.clear);
    _cubit.reset();
  }

  Future<void> _download(ApprovedEvidenceState st) async {
    final S s = S.of(context);
    final List<ApprovedEvidenceItem> rows = st.selected;
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
        title: s.noData,
        subtitle: _tr(context, 'No approved evidence matches these filters.',
            'لا توجد أدلة معتمدة تطابق هذه الاختيارات.'),
      );
      return;
    }
    final bool ar = context.isArabic;
    final DateFormat df = DateFormat('d MMM yyyy', ar ? 'ar' : 'en');
    await exportGrcCsv(
      context: context,
      defaultFileName:
          'approved_evidence_${widget.module.moduleNameEn.replaceAll(' ', '_')}',
      header: [
        s.no,
        grcTr(context, 'Policy Name'),
        grcTr(context, 'Control Name'),
        s.departments,
        s.controlChampion,
        s.document,
        s.submissionNotes,
        _tr(context, 'Approved Date', 'تاريخ الاعتماد'),
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          [
            i + 1,
            ar ? rows[i].policy.policyNameAr : rows[i].policy.policyNameEn,
            ar ? rows[i].control.controlsNameAr : rows[i].control.controlsNameEn,
            rows[i].departments.map((d) => grcTr(context, d)).join(', '),
            employeeDisplayName(
                context, rows[i].submission.controlChampionEmail),
            rows[i].submission.submissionDocument,
            rows[i].submission.submissionNote,
            df.format(rows[i].approvedAt),
          ],
      ],
    );
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return SideFrameMasterServices(
      titleText: s.grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: s.approvedEvidence,
      child: SideFrameScrollableBody(
        child: BlocBuilder<ApprovedEvidenceCubit, ApprovedEvidenceState>(
          builder: (context, st) {
            final ApprovedEvidenceData? d = st.data;
            if (d == null) {
              if (st.status == ApprovedEvidenceStatus.failure) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      st.message ?? s.noData,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.red),
                    ),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircleProgressMaster()),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _tr(context, 'Approved Evidence Details',
                      'تفاصيل الأدلة المعتمدة'),
                  style: (_isMobile
                          ? StyleText.fontSize14Weight400
                          : StyleText.fontSize16Weight400)
                      .copyWith(color: AppColors.text),
                ),
                SizedBox(height: 8.h),
                _filtersCard(st, d),
                SizedBox(height: 20.h),
                _actions(st),
                SizedBox(height: 30.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filtersCard(ApprovedEvidenceState st, ApprovedEvidenceData d) {
    final S s = S.of(context);
    final bool ar = context.isArabic;

    final Widget years = _field(
      field: _Field.years,
      label: s.years,
      hint: _tr(context, 'Select Years', 'اختر السنوات'),
      options: {
        for (final y in d.years) '$y': LocalizedNumber.digits(context, '$y'),
      },
      selected: {for (final y in st.years) '$y'},
    );

    final Widget departments = _field(
      field: _Field.departments,
      label: s.departments,
      hint: s.selectDepartments,
      options: {for (final dep in d.departments) dep: grcTr(context, dep)},
      selected: st.departments,
    );

    final Widget policies = _field(
      field: _Field.policies,
      label: s.policies,
      hint: _tr(context, 'Select Policies', 'اختر السياسات'),
      options: {
        for (final p in d.policiesFor(st.departments))
          p.id: ar && p.policyNameAr.trim().isNotEmpty
              ? p.policyNameAr
              : p.policyNameEn,
      },
      selected: st.policyIds,
    );

    final Widget controls = _field(
      field: _Field.controls,
      label: s.controls,
      hint: _tr(context, 'Select Controls', 'اختر الضوابط'),
      options: {
        for (final r in d.controlsFor(st.policyIds, st.departments))
          ApprovedEvidenceData.controlKey(r.policy.id, r.control.id):
              ar && r.control.controlsNameAr.trim().isNotEmpty
                  ? r.control.controlsNameAr
                  : r.control.controlsNameEn,
      },
      selected: st.controlIds,
    );

    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GrcResponsiveFieldRow(
            isTablet: !_isMobile,
            children: [years, departments],
          ),
          SizedBox(height: 15.h),
          GrcResponsiveFieldRow(
            isTablet: !_isMobile,
            children: [policies, controls],
          ),
        ],
      ),
    );
  }

  /// One picker plus the chips of what it has picked.
  Widget _field({
    required _Field field,
    required String label,
    required String hint,
    required Map<String, String> options,
    required Set<String> selected,
  }) {
    final S s = S.of(context);
    final bool all = _allChosen.contains(field);
    final double height = _isMobile ? 33 : 38;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomMultiSelectDropdown<String>(
          label: label,
          hint: hint,
          alwaysShowHint: true,
          // Raw value — the dropdown applies .sp itself.
          height: height,
          heightSizesWholeTrigger: true,
          fillColor: AppColors.background,
          values: all ? const <String>[_all] : selected.toList(),
          items: [
            MultiSelectDropdownItem<String>(value: _all, label: s.all),
            for (final e in options.entries)
              MultiSelectDropdownItem<String>(value: e.key, label: e.value),
          ],
          onChanged: (raw) => _onChanged(field, raw),
        ),
        if (all || selected.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.sp,
            runSpacing: 10.sp,
            children: [
              if (all)
                GrcAssignmentChip(
                  label: s.all,
                  onRemove: () => setState(() => _allChosen.remove(field)),
                ),
              for (final key in selected)
                GrcAssignmentChip(
                  label: options[key] ?? key,
                  onRemove: () => _onChanged(
                    field,
                    selected.where((k) => k != key).toList(),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _actions(ApprovedEvidenceState st) {
    final S s = S.of(context);
    final TextStyle text = _isMobile
        ? StyleText.fontSize14Weight500
        : StyleText.fontSize16Weight400;

    Widget discard(double? width) => customButton(
          title: s.discard,
          function: _discard,
          width: width,
          color: AppColors.field,
          textStyle: text.copyWith(color: AppColors.text),
        );

    Widget download(double? width) => customButtonWithSvg(
          title: s.download,
          function: () => _download(st),
          textStyle: text.copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          image: AppAssets.downloadLinear,
          widthImage: 22.sp,
          heightImage: 22.sp,
          space: 8.sp,
          svgColor: AppColors.textButton,
          fixedWidth: width,
        );

    if (_isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double gap = 15.sp;
          final double half = (constraints.maxWidth - gap) / 2;
          return Row(
            children: [
              discard(half),
              SizedBox(width: gap),
              download(half),
            ],
          );
        },
      );
    }
    return Row(
      children: [
        discard(150.w),
        const Spacer(),
        download(150.w),
      ],
    );
  }
}
