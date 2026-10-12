/// Module: GRC Module Management
/// Description: Page that shows all previously removed owners for a GRC
///              Module, including who assigned them and the date range of
///              each completed stint.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: flutter_bloc, GrcPreviousOwnersCubit, EmployeeHelper,
///               PaginationAppBar, AppColors, AppTheme, intl
/// Revision History: 2026-07-13 - Initial creation
///                    2026-07-13 - Table now spans full width and page
///                                 scrolls vertically instead of the table
///                                 scrolling horizontally.
///                    2026-09-13 - Table restyled to match RoleTableView
///                                 (roles/r1_role_management): same header
///                                 bar, row banding, cell padding and type.
///                                 Kept full-width flex columns rather than
///                                 that widget's fixed widths + horizontal
///                                 scroll. Headers are ARB-backed now.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_previous_owners_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'dart:ui' as ui;


class GrcPreviousModuleOwnersPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcPreviousModuleOwnersPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GrcPreviousOwnersCubit>()
        ..loadHistory(module.moduleId),
      child: _GrcPreviousModuleOwnersBody(module: module),
    );
  }
}

class _GrcPreviousModuleOwnersBody extends StatelessWidget {
  final GRCModuleEntity module;

  const _GrcPreviousModuleOwnersBody({required this.module});

  String _displayEmail(String email) => email;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GrcPreviousOwnersCubit, GrcPreviousOwnersState>(
      builder: (context, state) {
        final List<GRCModuleOwnerHistoryEntry> entries =
            state is GrcPreviousOwnersLoaded ? state.entries : const [];

        return SideFrameMasterServices(
          titleText: S.of(context).grc,
          onFirstTap: () => popFrameRoutes(context, 2),
          secondTitle:
              context.isArabic ? module.moduleNameAr : module.moduleNameEn,
          onSecondTap: () => Navigator.of(context).maybePop(),
          thirdTitle: S.of(context).previousModuleOwners,
          // Two different body wrappers, because the two states want opposite
          // things from the frame.
          //
          // A list SCROLLS: SideFrameScrollableBody, not SideFrameBoundedBody
          // — this page's body already lived in its own SingleChildScrollView
          // and the frame's phone branch is a scroll view too, so nesting them
          // leaves two viewports fighting for the same drag.
          //
          // An empty/loading/error state CENTRES, and centring vertically
          // needs a height to centre inside. The frame hands its child an
          // unbounded height on phone, where `Center` can only centre
          // horizontally — which is why the old sentence sat at the top of the
          // page. SideFrameBoundedBody measures the viewport and gives it one.
          child: _hasContent(state, entries)
              ? SideFrameScrollableBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBody(context, state, entries),
                    ],
                  ),
                )
              : SideFrameBoundedBody(
                  child: Center(child: _buildBody(context, state, entries)),
                ),
        );
      },
    );
  }

  /// True only when there is an actual table to scroll. Loading, failure and
  /// empty all render a single centred block instead.
  bool _hasContent(
    GrcPreviousOwnersState state,
    List<GRCModuleOwnerHistoryEntry> entries,
  ) =>
      state is! GrcPreviousOwnersLoading &&
      state is! GrcPreviousOwnersFailure &&
      entries.isNotEmpty;

  Widget _buildBody(
    BuildContext context,
    GrcPreviousOwnersState state,
    List<GRCModuleOwnerHistoryEntry> entries,
  ) {
    if (state is GrcPreviousOwnersLoading) {
      // No vertical padding of its own any more: build() centres this in the
      // viewport, and the old 60.h only shifted it off that centre.
      return CircularProgressIndicator(color: AppColors.primary);
    }

    if (state is GrcPreviousOwnersFailure) {
      // Same as above — centred by build(), so no padding to fake it here.
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatHelper.capitalize(state.message),
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context
                  .read<GrcPreviousOwnersCubit>()
                  .loadHistory(module.moduleId),
              child: Text(FormatHelper.capitalize(S.of(context).retry)),
            ),
          ],
      );
    }

    if (entries.isEmpty) {
      // CustomEmptyState, rather than hand-rolling the animation here. It
      // wraps the app's ONE empty-state Lottie, and the GRC list page already
      // uses it for the same "nothing here" case, so the two now match. Its
      // own doc asks callers to go through the widget instead of the asset
      // constant, precisely so no screen sizes or captions it differently.
      //
      // The sentence it replaces said nothing the empty page did not, and the
      // vertical padding went with it: the Center in build() positions this.
      return const CustomEmptyState();
    }

    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

    // The 375 frame (MAGDY / node 869:129390) does NOT show a table. Five
    // columns cannot be read at that width, so the design replaces each row
    // with a 345x95 card. Table stays for 768 and 1024.
    if (screenSizeOf(context) == ScreenSize.mobile) {
      return Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _buildOwnerCard(
              context: context,
              entry: entries[i],
              dateFormat: dateFormat,
            ),
          ],
        ],
      );
    }

    // Styled to match RoleTableView (roles/r1_role_management) — same rounded
    // clip, same blackShadow header bar, same even/odd row tokens, same cell
    // padding and type scale — so the two tables read as one component.
    //
    // ONE deliberate difference: RoleTableView wraps itself in a horizontal
    // SingleChildScrollView and sizes every column with FixedColumnWidth,
    // because it has ten columns that cannot fit. This table has five and is
    // asked to fill the page, so the flex widths stay and there is no
    // horizontal scroll — the columns divide whatever width the page gives.
    return Directionality(
      textDirection:
          context.isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FixedColumnWidth(60.w),
            1: const FlexColumnWidth(2.4),
            2: const FlexColumnWidth(2.4),
            3: const FlexColumnWidth(1.4),
            4: const FlexColumnWidth(1.4),
          },
          children: [
            _buildHeaderRow(context),
            for (var i = 0; i < entries.length; i++)
              _buildDataRow(
                context: context,
                entry: entries[i],
                index: i,
                dateFormat: dateFormat,
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow(BuildContext context) {
    // Localized, not the raw English strings these used to be. All five keys
    // already existed in the ARB.
    final headers = <String>[
      S.of(context).number,
      S.of(context).previousOwner,
      S.of(context).assignedBy,
      S.of(context).startDate,
      S.of(context).endDate,
    ];

    return TableRow(
      decoration: BoxDecoration(color: AppColors.blackShadow),
      children: headers
          .map(
            (header) => Padding(
              padding: EdgeInsets.all(10.sp),
              child: Text(
                FormatHelper.capitalize(header),
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildDataRow({
    required BuildContext context,
    required GRCModuleOwnerHistoryEntry entry,
    required int index,
    required DateFormat dateFormat,
  }) {
    // Row numbers are 1-based, and the parity is taken from the NUMBER the
    // user sees, exactly as RoleTableView does it — so row 1 is odd and the
    // banding of the two tables starts on the same tone.
    final int rowNumber = index + 1;
    final Color rowColor =
        rowNumber.isEven ? AppColors.evenRowColor : AppColors.oddRowColor;

    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        // LocalizedNumber, not '$rowNumber': the raw interpolation is always
        // ASCII, so the row index stayed "1" beside Arabic-Indic counts
        // everywhere else in the app.
        _textCell(context, LocalizedNumber.of(context, rowNumber), maxLines: 1),
        _textCell(context, employeeDisplayName(context, entry.ownerEmail)),
        _textCell(context, employeeDisplayName(context, entry.assignedByEmail)),
        // DateFormat('…','ar') gives Arabic month names but its digits depend
        // on which numbering system the intl version hands a bare `ar` — so
        // the digits are mapped here rather than trusted to the format.
        _textCell(
          context,
          LocalizedNumber.digits(context, dateFormat.format(entry.startDate)),
          maxLines: 1,
        ),
        _textCell(
          context,
          LocalizedNumber.digits(context, dateFormat.format(entry.endDate)),
          maxLines: 1,
        ),
      ],
    );
  }

  /// Cell shell — RoleTableView's `_cell`: 10.sp across, 8.sp down.
  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: StyleText.fontSize12Weight500,
        child: child,
      ),
    );
  }

  /// Text cell — RoleTableView's `_textCell`, down to the 12.sp/w600 type and
  /// the '-' it substitutes for an empty value.
  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        // Capitalised HERE rather than at each call site: every cell in the
        // table goes through this one method, so a new column cannot forget
        // it. FormatHelper.capitalize also fixes the known abbreviations
        // ("it" -> "IT", "hr" -> "HR"), which matters because the employee
        // directory stores names and departments lower-case. It is a no-op on
        // dates, on the row number, and on Arabic, which has no case.
        text.isEmpty ? '-' : FormatHelper.capitalize(text),
        maxLines: maxLines,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Mobile card (Figma 869:129418) ────────────────────────────────────────
  //
  // Measured off the frame rather than eyeballed. Card 345x95, white, radius
  // 8, 10 of padding. Inside it, relative to the card's top-left:
  //
  //   row 1  person icon 10x12 at (10,16) | "Module Owner:" 12px #797979 at
  //          x26 | 25x25 avatar at (102,10) | name 12px #2D2D2D at x132
  //   row 2  the same shape at y+35, "Assigned By:"
  //   dates  10px, labels #797979 and values #2D2D2D, start left, end right
  //
  // Sizes go through .sp and the two hexes through the theme: #797979 is
  // AppColors.secondaryText and #2D2D2D is AppColors.text, which is what keeps
  // the card readable in dark mode — the raw Figma values are light-mode only.
  Widget _buildOwnerCard({
    required BuildContext context,
    required GRCModuleOwnerHistoryEntry entry,
    required DateFormat dateFormat,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _personRow(
            context: context,
            label: '${S.of(context).moduleOwner}:',
            email: entry.ownerEmail,
          ),
          SizedBox(height: 10.h),
          _personRow(
            context: context,
            label: '${S.of(context).assignedBy}:',
            email: entry.assignedByEmail,
          ),
          SizedBox(height: 7.h),
          Row(
            children: [
              _dateField(
                context,
                S.of(context).startDate,
                LocalizedNumber.digits(
                    context, dateFormat.format(entry.startDate)),
              ),
              const Spacer(),
              _dateField(
                context,
                S.of(context).endDate,
                LocalizedNumber.digits(
                    context, dateFormat.format(entry.endDate)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// One labelled person line: icon, label, avatar, name.
  Widget _personRow({
    required BuildContext context,
    required String label,
    required String email,
  }) {
    final employee = findEmployeeByEmail(email);
    final String photo = employee.displayPhoto;

    // Is there a real photo, or are we falling back to the default avatar?
    //
    // THE BUG: this used to hand `photo` to AssetImage, and the fallback
    // AppAssets.defaultEmployeeAvatar is assets_male.svg — an SVG, which
    // AssetImage cannot decode. It does not throw, it just paints nothing,
    // which is why the circles came up empty.
    final bool hasPhoto = photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;

    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons_assets/main_icons_assets/person_outline.svg',
          width: 10.sp,
          height: 12.sp,
          colorFilter:
              ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize(label),
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(width: 5.w),
        // `foregroundImage` over an SVG child, NOT `backgroundImage` — the
        // same arrangement access_table.dart and PersonChipCard use, and the
        // reason those avatars render while these did not. A foreground image
        // draws OVER the child, so the default silhouette shows while a photo
        // loads and stays put if the URL 404s.
        CircleAvatar(
          radius: 12.5.sp,
          backgroundColor: AppColors.moreLightGrey,
          foregroundImage: hasPhoto ? appImageProvider(photo) : null,
          child: ClipOval(
            child: CustomSvgImage(
              assetPath: AppAssets.defaultEmployeeAvatar,
              width: 25.sp,
              height: 25.sp,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        // Flexible, so a long name ellipsises inside the card instead of
        // overflowing it — the Figma name is a short sample.
        Flexible(
          child: Text(
            FormatHelper.capitalize(employeeDisplayName(context, email)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
        ),
      ],
    );
  }

  /// "Start Date: 10 Oct 2024" — grey label, dark value, both 10.sp.
  Widget _dateField(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${FormatHelper.capitalize(label)}:',
          style: StyleText.fontSize10Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(width: 4.w),
        Text(
          FormatHelper.capitalize(value),
          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}
