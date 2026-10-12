/// Module: Policy Management
/// Description: Page opened from GrcModuleDetailsPage's "Policy Weight
///              Issue" button. Two tabs: "Policies Weight" (an editable
///              table of the Active/Scheduled policies making up the
///              module's weight total, with Equal Weight / manual editing)
///              and "History" (every recorded weight change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, get_it, PolicyWeightIssueCubit,
///               PolicyWeightHistoryCubit, PolicyWeightHistoryTab
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';

/// class name: [PolicyWeightIssuePage]
///
/// purpose: host the Policies Weight / History tabs for one GRC Module,
///          provisioning its own [PolicyWeightIssueCubit] and
///          [PolicyWeightHistoryCubit] (same pattern as
///          GrcPreviousModuleOwnersPage / AddChampionPage provisioning
///          their own cubits when pushed).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;

  const PolicyWeightIssuePage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyWeightIssueCubit>(
          create: (_) =>
              GetIt.instance<PolicyWeightIssueCubit>()..load(module.moduleId),
        ),
        BlocProvider<PolicyWeightHistoryCubit>(
          create: (_) => GetIt.instance<PolicyWeightHistoryCubit>(),
        ),
      ],
      child: _PolicyWeightIssueBody(module: module),
    );
  }
}

class _PolicyWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _PolicyWeightIssueBody({required this.module});

  @override
  State<_PolicyWeightIssueBody> createState() => _PolicyWeightIssueBodyState();
}

class _PolicyWeightIssueBodyState extends State<_PolicyWeightIssueBody> {
  int _selectedTab = 0;
  bool _historyLoaded = false;
  bool _applyingDialogShown = false;

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  /// Month name and digits both from the active locale -- "14 Sep 2026" in
  /// English, "١٤ سبتمبر ٢٠٢٦" in Arabic. `DateFormat(..., 'ar')` gives the
  /// month name but LATIN digits, which is why this goes through the shared
  /// helper instead, like the other GRC tables.
  String _date(BuildContext context, DateTime date) =>
      LocalizedDate.of(context, date, pattern: 'd MMM yyyy');

  /// A weight or count in the locale's numerals.
  String _num(BuildContext context, String digits) =>
      LocalizedNumber.digits(context, digits);

  /// The header style RoleTableView uses -- white 14/500 on `blackShadow`.
  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  @override
  Widget build(BuildContext context) {
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: context.isArabic
          ? widget.module.moduleNameAr
          : widget.module.moduleNameEn,
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: S.of(context).policyWeightIssue,
      // Tabs over an Expanded tab body: needs a bounded height, which the
      // frame's phone branch does not give.
      child: SideFrameBoundedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(),
            SizedBox(height: 15.h),
            Expanded(
              child: _selectedTab == 0 ||
                      !GrcPermission.canViewPolicyWeightHistory
                  ? _buildPoliciesWeightTab(context)
                  : const PolicyWeightHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  /// The app's tab bar (10-custom_tabs.dart) rather than a local one.
  ///
  /// This page used to hand-roll its own, and its underline was a Container
  /// pinned to `width: 90.w` -- a guess that fitted neither label in either
  /// language. CustomTabs sizes the bar to the text by construction
  /// (IntrinsicWidth + a stretched Column), and keeps the bar in the layout
  /// as transparent when unselected, so the row does not shift by 2px each
  /// time you switch tabs.
  ///
  /// CustomTabs takes titles that are ALREADY translated, so the raw keys go
  /// through grcTr here.
  Widget _buildTabs() {
    return CustomTabs(
      tabs: <String>[
        grcTr(context, 'Policies Weight'),
        // Policy_Weight_History. Dropping the tab is what hides the history --
        // see the guard in build(), which keeps the weights tab on screen if
        // a stale _selectedTab survives the permission going away.
        if (GrcPermission.canViewPolicyWeightHistory)
          grcTr(context, 'History'),
      ],
      selectedValue: _selectedTab,
      onChanged: _selectTab,
      spacing: 24.w,
      textStyle: StyleText.fontSize16Weight500,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.secondaryText,
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 1 && !_historyLoaded) {
      _historyLoaded = true;
      context
          .read<PolicyWeightHistoryCubit>()
          .loadHistory(widget.module.moduleId);
    }
  }

  Widget _buildPoliciesWeightTab(BuildContext context) {
    return BlocConsumer<PolicyWeightIssueCubit, PolicyWeightIssueState>(
      listener: (context, state) {
        if (state is PolicyWeightIssueApplying) {
          _applyingDialogShown = true;
          showLoadingIndicator();
          return;
        }
        if (_applyingDialogShown) {
          _applyingDialogShown = false;
          hideLoadingIndicator();
        }
        if (state is PolicyWeightIssueApplySuccess) {
          showSuccessDialog(
            context: context,
            subtitle: S.of(context).youHaveSuccessfullyEditedPoliciesWeights,
          );
        }
        if (state is PolicyWeightIssueFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is PolicyWeightIssueLoading ||
            state is PolicyWeightIssueInitial) {
          // CircleProgressMaster is the app's spinner (66-circle_progress),
          // and it centres itself -- the Center wrapper here was redundant.
          // The applying state already went through showLoadingIndicator from
          // the same file; the first load was the one still rolling its own.
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: const CircleProgressMaster(),
          );
        }

        final cubit = context.read<PolicyWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is PolicyWeightIssueFailure && !cubit.hasRows) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final isEditing =
            (state is PolicyWeightIssueLoaded && state.isEditing) ||
                state is PolicyWeightIssueApplying;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.textButton
                    ),
                    title: S.of(context).equalPolicyWeight,
                    function: cubit.applyEqualWeight,
                    width: 160.w,
                    height: 36.h,
                    color: AppColors.primary,
                  ),
                const Spacer(),
                // Edit_Policy_Weight_Issue. Policy_Weight_Issue alone opens
                // this page read-only; editing the weights is its own switch.
                if (!isEditing && GrcPermission.canEditPolicyWeightIssue)
                  // NOTE: customButtonWithSvg IGNORES `width`/`height` -- they
                  // exist only so the dozens of stale call sites keep
                  // compiling while ButtonSizing enforces the app-wide size.
                  // `fixedWidth`/`fixedHeight` are the opt-in escape hatch,
                  // which is what keeps this button at the 100x36 it was.
                  customButtonWithSvg(
                    title: S.of(context).Edit,
                    function: cubit.enterEditMode,
                    image: 'assets/icons_assets/data_grc_assets/edit_pen.svg',
                    widthImage: 16.w,
                    heightImage: 16.h,
                    space: 8.w,
                    fixedWidth: 100.w,
                    fixedHeight: 36.h,
                    color: AppColors.primary,
                    colorBorder: AppColors.primary,
                    svgColor: AppColors.textButton,
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              // iPhone (375): the eight-column table becomes one card per
              // policy, exactly as the phone design draws it. iPad (768) and
              // desktop keep the table and scroll it sideways.
              child: screenSizeOf(context) == ScreenSize.mobile
                  ? SingleChildScrollView(
                      child: _buildCards(context, rowsData, isEditing, cubit),
                    )
                  // Vertical only: _buildTable owns the horizontal scroller
                  // now, exactly as role_management_home.dart wraps
                  // RoleTableView in a plain SingleChildScrollView.
                  : SingleChildScrollView(
                      child: _buildTable(context, rowsData, isEditing, cubit),
                    ),
            ),
            SizedBox(height: 12.h),
            Align(
                alignment: Alignment.centerRight,
                child: _buildTotalWeight(rowsData)),
            SizedBox(height: 12.h),
            if (isEditing)
              Row(
                children: [
                  customButton(
                    title: S.of(context).discardChange,
                    function: cubit.discardChanges,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.darkGrey,
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).applyChanges,
                    function: rowsData.totalWeightValid
                        ? () => showConfirmDialog(
                              context: context,
                              title: S.of(context).editingPoliciesWeight,
                              cancelLabel: S.of(context).no,
                              confirmLabel: S.of(context).yes,
                              subtitle:
                                  S.of(context).areYouSureYouWantToEditPoliciesWeight,
                              onConfirm: () =>
                                  cubit.applyChanges(
                                    widget.module.moduleId,
                                    moduleOwners: widget.module.moduleOwners,
                                  ),
                            )
                        : () {},
                    width: 150.w,
                    height: 38.h,
                    color: rowsData.totalWeightValid
                        ? AppColors.primary
                        : AppColors.secondaryText,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  static const List<double> _columnWidths = [
    40,
    110,
    150,
    200,
    110,
    100,
    110,
    110
  ];
  static const List<String> _headers = [
    'NO',
    'Policy Number',
    'Policy Name',
    'Policy Description',
    'Policy Weight',
    'No of Controls',
    'Start Date',
    'End Date',
  ];

  // ------------------------------------------------------------------
  // PHONE: one card per policy
  // ------------------------------------------------------------------
  Widget _buildCards(
    BuildContext context,
    PolicyWeightIssueRows rowsData,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rowsData.rows.length; i++) ...[
          if (i != 0) SizedBox(height: 10.h),
          _buildCard(context, rowsData.rows[i], isEditing, cubit),
        ],
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    PolicyWeightIssueRow row,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isArabic ? row.policyNameAr : row.policyNameEn,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              isEditing
                  ? SizedBox(
                      width: 76.w,
                      child: TextField(
                        controller: row.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => cubit.revalidate(),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.card,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 6.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.r)),
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${S.of(context).policyWeight}: '
                        '${_num(context, _formatWeight(row.currentWeight))}',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
            ],
          ),
          SizedBox(height: 8.h),
          _cardLine(
            context,
            grcTr(context, 'Policy Number'),
            _num(context, isArabic ? row.policyNumberAr : row.policyNumberEn),
          ),
          _cardLine(context, S.of(context).startDate,
              _date(context, row.startDate)),
          _cardLine(
              context, S.of(context).endDate, _date(context, row.endDate)),
          SizedBox(height: 4.h),
          Text(
            S.of(context).description,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 4.h),
          Text(
            isArabic ? row.policyDescriptionAr : row.policyDescriptionEn,
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _cardLine(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
          children: [
            TextSpan(
              text: value.trim().isEmpty ? '-' : value,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  /// Built to the same recipe as RoleTableView
  /// (roles/r1_role_management/presentation/ui/widgets/table_widget.dart), so
  /// this table reads like every other table in the app: locale-aware
  /// Directionality, the horizontal scroller owned here rather than by the
  /// caller, a 10.sp rounded clip, FixedColumnWidth per column, a
  /// `blackShadow` header in white 14/500 and rows alternating between
  /// `evenRowColor` and `oddRowColor`.
  ///
  /// It was a hand-rolled Column of Rows of SizedBoxes before: no header
  /// band, no row striping, no rounded clip, and column alignment held
  /// together only by every cell repeating the same width.
  ///
  /// The one thing this table has that RoleTableView does not is an EDITABLE
  /// cell -- Policy Weight becomes a TextField in edit mode. A Table handles
  /// that fine (`defaultVerticalAlignment: middle` centres it against the
  /// text cells); the field simply keeps its own padding rather than the
  /// shared [_textCell] one.
  Widget _buildTable(
    BuildContext context,
    PolicyWeightIssueRows rowsData,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
  ) {
    final bool isArabic = context.isArabic;

    // The table fills the page. The eight columns in [_columnWidths] add up
    // to a fixed ~930, which on a desktop left a band of empty background
    // down the trailing edge; on a narrow window the same widths overflow.
    // So the widths are treated as PROPORTIONS, not pixels:
    //
    //   room to spare -> FlexColumnWidth, same ratios, stretched to the full
    //                    width, no horizontal scroll at all
    //   too narrow    -> FixedColumnWidth at the designed pixel sizes, inside
    //                    the horizontal scroller, so nothing is squeezed
    //                    below its readable width
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double designedWidth = _columnWidths
            .fold<double>(0, (double sum, double width) => sum + width.w);
        final bool fits = constraints.maxWidth >= designedWidth;

        final Widget table = Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: <int, TableColumnWidth>{
            for (var i = 0; i < _columnWidths.length; i++)
              i: fits
                  // Flex takes the designed width as a RATIO, so the columns
                  // keep their relative sizes while filling the screen.
                  ? FlexColumnWidth(_columnWidths[i])
                  : FixedColumnWidth(_columnWidths[i].w),
          },
          children: <TableRow>[
            TableRow(
              decoration: BoxDecoration(color: AppColors.blackShadow),
              children: <Widget>[
                for (final String header in _headers)
                  Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Text(
                      grcTr(context, header),
                      style: _headerStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
              ],
            ),
            for (var i = 0; i < rowsData.rows.length; i++)
              _buildRow(context, rowsData.rows[i], i, isEditing, cubit),
          ],
        );

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: fits
                ? table
                // A Table with flex columns cannot live inside a horizontal
                // scroller (unbounded width), which is why the narrow branch
                // is the fixed-width one.
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: designedWidth, child: table),
                  ),
          ),
        );
      },
    );
  }

  TableRow _buildRow(
    BuildContext context,
    PolicyWeightIssueRow row,
    int index,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
  ) {
    final bool isArabic = context.isArabic;
    final int rowNumber = index + 1;

    return TableRow(
      decoration: BoxDecoration(
        color:
            rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
      children: <Widget>[
        _textCell(context, LocalizedNumber.of(context, rowNumber), maxLines: 1),
        _textCell(
          context,
          _num(context, isArabic ? row.policyNumberAr : row.policyNumberEn),
          maxLines: 1,
        ),
        _textCell(
          context,
          isArabic ? row.policyNameAr : row.policyNameEn,
          maxLines: 2,
        ),
        _textCell(
          context,
          isArabic ? row.policyDescriptionAr : row.policyDescriptionEn,
          maxLines: 3,
        ),

        // The editable column. In edit mode the cell is the field itself, so
        // it carries its own tighter padding rather than [_textCell]'s.
        isEditing
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: TextField(
                  controller: row.weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => cubit.revalidate(),
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              )
            : _textCell(
                context,
                _num(context, _formatWeight(row.currentWeight)),
                maxLines: 1,
              ),

        _textCell(
          context,
          LocalizedNumber.of(context, row.noOfControls),
          maxLines: 1,
        ),
        _textCell(context, _date(context, row.startDate), maxLines: 1),
        _textCell(context, _date(context, row.endDate), maxLines: 1),
      ],
    );
  }

  /// One text cell, padded and styled the way RoleTableView pads and styles
  /// its own -- 10.sp all round, 12/500.
  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Text(
        text.trim().isEmpty ? '-' : text,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildTotalWeight(PolicyWeightIssueRows rowsData) {
    final valid = rowsData.totalWeightValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: valid ? AppColors.green : AppColors.red),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${S.of(context).totalWeight} : '
            '${_num(context, _formatWeight(double.parse(rowsData.totalWeight.toStringAsFixed(2))))}',
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            S.of(context).totalWeightShouldBe100,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
