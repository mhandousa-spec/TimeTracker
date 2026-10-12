/// Module: Policy Management
/// Description: Page opened from PolicyViewModeWidget's "Control Weight
///              Issue" banner. Two tabs: "Controls Weight" (an editable
///              table of the Controls under this Policy, with Equal Weight
///              / manual editing) and "History" (every recorded weight
///              change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, get_it, ControlWeightIssueCubit,
///               ControlWeightHistoryCubit, ControlWeightHistoryTab
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';

/// class name: [ControlWeightIssuePage]
///
/// purpose: host the Controls Weight / History tabs for one Policy's
///          Controls, provisioning its own [ControlWeightIssueCubit] and
///          [ControlWeightHistoryCubit] (same pattern as
///          `PolicyWeightIssuePage`).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const ControlWeightIssuePage({
    super.key,
    required this.module,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ControlWeightIssueCubit>(
          create: (_) => GetIt.instance<ControlWeightIssueCubit>()
            ..load(module.moduleId, policy.id),
        ),
        BlocProvider<ControlWeightHistoryCubit>(
          create: (_) => GetIt.instance<ControlWeightHistoryCubit>(),
        ),
      ],
      child: _ControlWeightIssueBody(module: module, policy: policy),
    );
  }
}

class _ControlWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const _ControlWeightIssueBody({required this.module, required this.policy});

  @override
  State<_ControlWeightIssueBody> createState() =>
      _ControlWeightIssueBodyState();
}

class _ControlWeightIssueBodyState extends State<_ControlWeightIssueBody> {
  int _selectedTab = 0;
  bool _historyLoaded = false;
  bool _applyingDialogShown = false;

  @override
  Widget build(BuildContext context) {
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    //
    // Crumb taps: PaginationAppBar popped `screensTitles.length - (index+1)`
    // routes on tap and the frame does nothing without an explicit callback,
    // so crumb i of 4 gets popFrameRoutes(context, 3 - i) and the last gets
    // none.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 3),
      secondTitle: context.isArabic
          ? widget.module.moduleNameAr
          : widget.module.moduleNameEn,
      onSecondTap: () => popFrameRoutes(context, 2),
      thirdTitle: context.isArabic
          ? widget.policy.policyNameAr
          : widget.policy.policyNameEn,
      onThirdTap: () => popFrameRoutes(context, 1),
      fourthTitle: S.of(context).controlWeightIssue,
      // Tabs over an Expanded tab body: needs a bounded height, which the
      // frame's phone branch does not give.
      child: SideFrameBoundedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(),
            SizedBox(height: 15.h),
            Expanded(
              child: _selectedTab == 0
                  ? _buildControlsWeightTab(context)
                  : const ControlWeightHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  /// The app's tab bar (10-custom_tabs.dart) rather than a local one --
  /// the same swap PolicyWeightIssuePage made.
  ///
  /// The hand-rolled version this replaces pinned its underline to
  /// `width: 90.w`, a guess that fitted neither label in either language,
  /// and dropped the bar out of the layout when unselected so the row
  /// shifted by 2px on every tab change. CustomTabs sizes the bar to the
  /// text and keeps it in place as transparent.
  ///
  /// CustomTabs takes titles that are ALREADY translated, so the raw keys
  /// go through grcTr here.
  Widget _buildTabs() {
    return CustomTabs(
      tabs: <String>[
        grcTr(context, 'Controls Weight'),
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
          .read<ControlWeightHistoryCubit>()
          .loadHistory(widget.module.moduleId, widget.policy.id);
    }
  }


  Widget _buildControlsWeightTab(BuildContext context) {
    return BlocConsumer<ControlWeightIssueCubit, ControlWeightIssueState>(
      listener: (context, state) {
        if (state is ControlWeightIssueApplying) {
          _applyingDialogShown = true;
          showLoadingIndicator();
          return;
        }
        if (_applyingDialogShown) {
          _applyingDialogShown = false;
          hideLoadingIndicator();
        }
        if (state is ControlWeightIssueApplySuccess) {
          showSuccessDialog(
            context: context,
            subtitle: S.of(context).youHaveSuccessfullyEditedControlsWeights,
          );
        }
        if (state is ControlWeightIssueFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is ControlWeightIssueLoading ||
            state is ControlWeightIssueInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final cubit = context.read<ControlWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is ControlWeightIssueFailure && !cubit.hasRows) {
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
            (state is ControlWeightIssueLoaded && state.isEditing) ||
                state is ControlWeightIssueApplying;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    title: S.of(context).equalControlWeight,
                    function: cubit.applyEqualWeight,
                    width: 170.w,
                    height: 36.h,
                    color: AppColors.black,
                  ),
                const Spacer(),
                // Edit_Control_Weight_Issue. Control_Weight_Issue alone opens
                // this page read-only; editing the weights is its own switch.
                if (!isEditing && GrcPermission.canEditControlWeightIssue)
                  // NOTE: customButtonWithSvg IGNORES `width`/`height` --
                  // they exist only so the dozens of stale call sites keep
                  // compiling while ButtonSizing enforces the app-wide
                  // size. `fixedWidth`/`fixedHeight` are the opt-in escape
                  // hatch, which is what keeps this button at 100x36.
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
              // iPhone (375) has no room for an eight-column table, so the
              // design turns every control row into its own card. iPad (768)
              // and desktop (1024) keep the table.
              child: screenSizeOf(context) == ScreenSize.mobile
                  ? SingleChildScrollView(
                      child: _buildCards(context, rowsData, isEditing, cubit),
                    )
                  // VERTICAL ONLY. _buildTable owns the horizontal scroller
                  // now, and it must: it measures the available width with a
                  // LayoutBuilder to choose between flex and fixed columns,
                  // and a horizontal scroller here would hand it an INFINITE
                  // maxWidth. It would then always pick flex columns and put
                  // them inside an unbounded viewport -- which cannot lay
                  // out, so the whole table rendered as blank space.
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
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.white
                    )
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).applyChanges,
                    function: rowsData.totalWeightValid
                        ? () => showConfirmDialog(
                              context: context,
                              title: S.of(context).editingControlsWeight,
                              cancelLabel: S.of(context).no,
                              confirmLabel: S.of(context).yes,
                              subtitle:
                                  S.of(context).areYouSureYouWantToEditControlsWeight,
                              onConfirm: () => cubit.applyChanges(
                                  widget.module.moduleId, widget.policy.id),
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


  // ------------------------------------------------------------------
  // PHONE (375): one card per control instead of the eight-column table
  // ------------------------------------------------------------------

  /// Same shape PolicyWeightIssuePage uses for its phone cards, so the two
  /// Weight Issue screens read identically on a phone.
  Widget _buildCards(
    BuildContext context,
    ControlWeightIssueRows rowsData,
    bool isEditing,
    ControlWeightIssueCubit cubit,
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
    ControlWeightIssueRow row,
    bool isEditing,
    ControlWeightIssueCubit cubit,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
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
                  isArabic ? row.controlsNameAr : row.controlsNameEn,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${S.of(context).controlWeight}: '
                        '${_num(context, formatControlWeight(row.currentWeight))}',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
            ],
          ),
          SizedBox(height: 8.h),
          _cardLine(context, grcTr(context, 'Control Number'),
              _num(context,
                  isArabic ? row.controlsNumberAr : row.controlsNumberEn)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _cardLine(context, grcTr(context, 'Start Date'),
                    _date(context, row.startDate)),
              ),
              Expanded(
                child: _cardLine(context, grcTr(context, 'End Date'),
                    _date(context, row.endDate)),
              ),
            ],
          ),
          _cardLine(context, grcTr(context, 'No of Departments'),
              LocalizedNumber.of(context, row.noOfDepartments)),
          SizedBox(height: 4.h),
          Text(
            S.of(context).description,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 4.h),
          Text(
            isArabic ? row.controlsDescriptionAr : row.controlsDescriptionEn,
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

  static const List<double> _columnWidths = [
    40,
    110,
    150,
    200,
    110,
    130,
    110,
    110
  ];
  static const List<String> _headers = [
    'NO',
    'Control Number',
    'Control Name',
    'Control Description',
    'Control Weight',
    'No of Departments',
    'Start Date',
    'End Date',
  ];

  /// Month name and digits both from the active locale -- "14 Sep 2026" in
  /// English, "١٤ سبتمبر ٢٠٢٦" in Arabic. `DateFormat(..., 'ar')` gives the
  /// month name but LATIN digits, which is the reason this goes through the
  /// shared helper instead.
  String _date(BuildContext context, DateTime date) =>
      LocalizedDate.of(context, date, pattern: 'd MMM yyyy');

  /// A weight or count in the locale's numerals.
  String _num(BuildContext context, String digits) =>
      LocalizedNumber.digits(context, digits);

  /// The header style RoleTableView uses -- white 14/500 on `blackShadow`.
  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  /// Built to the same recipe as RoleTableView and PolicyWeightIssuePage, so
  /// this table reads like every other table in the app: locale-aware
  /// Directionality, the horizontal scroller owned here rather than by the
  /// caller, a 10.sp rounded clip, a `blackShadow` header band in white
  /// 14/500, and rows alternating `evenRowColor` / `oddRowColor`.
  ///
  /// It was a hand-rolled Column of Rows of SizedBoxes before: no header
  /// band, no striping, no rounded clip, and column alignment held together
  /// only by every cell repeating the same width.
  ///
  /// The eight columns in [_columnWidths] add up to a fixed ~960, which on a
  /// desktop left a band of empty background down the trailing edge, and on
  /// a narrow window overflowed. So the widths are treated as PROPORTIONS,
  /// not pixels:
  ///
  ///   room to spare -> FlexColumnWidth, same ratios, stretched to the full
  ///                    width, no horizontal scroll at all
  ///   too narrow    -> FixedColumnWidth at the designed pixel sizes, inside
  ///                    the horizontal scroller, so nothing is squeezed
  ///                    below its readable width
  ///
  /// The one thing this table has that RoleTableView does not is an EDITABLE
  /// cell -- Control Weight becomes a TextField in edit mode. A Table handles
  /// that fine (`defaultVerticalAlignment: middle` centres it against the
  /// text cells); the field simply keeps its own padding rather than the
  /// shared [_textCell] one.
  Widget _buildTable(
    BuildContext context,
    ControlWeightIssueRows rowsData,
    bool isEditing,
    ControlWeightIssueCubit cubit,
  ) {
    final bool isArabic = context.isArabic;

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
    ControlWeightIssueRow row,
    int index,
    bool isEditing,
    ControlWeightIssueCubit cubit,
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
          _num(context, isArabic ? row.controlsNumberAr : row.controlsNumberEn),
          maxLines: 1,
        ),
        _textCell(
          context,
          isArabic ? row.controlsNameAr : row.controlsNameEn,
          maxLines: 2,
        ),
        _textCell(
          context,
          isArabic ? row.controlsDescriptionAr : row.controlsDescriptionEn,
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
                _num(context, formatControlWeight(row.currentWeight)),
                maxLines: 1,
              ),

        _textCell(
          context,
          LocalizedNumber.of(context, row.noOfDepartments),
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

  Widget _buildTotalWeight(ControlWeightIssueRows rowsData) {
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
            '${_num(context, formatControlWeight(double.parse(rowsData.totalWeight.toStringAsFixed(2))))}',
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
