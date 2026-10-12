/// Module: Control Owner Management
/// Description: Page that shows every completed Control Owner assignment
///              stint for one Control, including who assigned them and the
///              date range of each completed stint.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, ControlPreviousOwnersCubit, EmployeeHelper,
///               PaginationAppBar, AppColors, AppTheme, intl
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [ControlPreviousOwnersPage]
///
/// purpose: entry-point widget for the Previous Control Owners screen.
///          Provides its own [ControlPreviousOwnersCubit] and loads history
///          for the given {module, policy, control}.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlPreviousOwnersPage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const ControlPreviousOwnersPage({
    super.key,
    required this.module,
    required this.policy,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ControlPreviousOwnersCubit>()
        ..loadHistory(
          moduleId: module.moduleId,
          policyId: policy.id,
          controlId: control.id,
        ),
      child: _ControlPreviousOwnersBody(
        module: module,
        policy: policy,
        control: control,
      ),
    );
  }
}

class _ControlPreviousOwnersBody extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const _ControlPreviousOwnersBody({
    required this.module,
    required this.policy,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    return BlocBuilder<ControlPreviousOwnersCubit, ControlPreviousOwnersState>(
      builder: (context, state) {
        final List<ControlOwnerHistoryEntry> entries =
            state is ControlPreviousOwnersLoaded ? state.entries : const [];

        return SideFrameMasterServices(
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      titleText: isArabic ? module.moduleNameAr : module.moduleNameEn,
      onFirstTap: () => popFrameRoutes(context, 3),
      secondTitle: isArabic ? policy.policyNameAr : policy.policyNameEn,
      onSecondTap: () => popFrameRoutes(context, 2),
      thirdTitle: isArabic
                            ? control.controlsNameAr
                            : control.controlsNameEn,
      onThirdTap: () => popFrameRoutes(context, 1),
      fourthTitle: S.of(context).historyOfControlOwners,
      child: SideFrameScrollableBody(
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildBody(context, state, entries),
                  ],
                ),
      ),
    );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ControlPreviousOwnersState state,
    List<ControlOwnerHistoryEntry> entries,
  ) {
    if (state is ControlPreviousOwnersLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: const CircleProgressMaster(),
        ),
      );
    }

    if (state is ControlPreviousOwnersFailure) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () =>
                  context.read<ControlPreviousOwnersCubit>().loadHistory(
                        moduleId: module.moduleId,
                        policyId: policy.id,
                        controlId: control.id,
                      ),
              child: Text(S.of(context).retry),
            ),
          ],
        ),
      );
    }

    // Empty, not failed -- the ControlPreviousOwnersFailure branch above
    // keeps its own message and retry. This one is the app's single wordless
    // empty state (see 89-custom_empty_state.dart).
    if (entries.isEmpty) {
      return const Center(child: CustomEmptyState());
    }

    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

    // The 375 frame (MAGDY / node 869:144273) does NOT show a table -- five
    // columns are unreadable at that width, so the design replaces each row
    // with a card. Same card GrcPreviousModuleOwnersPage draws for the module
    // owner history, relabelled for a Control. Table stays for 768 / 1024.
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(52.w),
            1: FlexColumnWidth(2.4),
            2: FlexColumnWidth(2.4),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.4),
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

  // ------------------------------------------------------------------
  // PHONE (375): one card per completed ownership stint
  // ------------------------------------------------------------------

  Widget _buildOwnerCard({
    required BuildContext context,
    required ControlOwnerHistoryEntry entry,
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
            label: '${S.of(context).controlOwner}:',
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
  ///
  /// `foregroundImage` over an SVG child, not `backgroundImage` -- the
  /// default silhouette is an SVG that AssetImage cannot decode, so a
  /// background image would simply paint nothing.
  Widget _personRow({
    required BuildContext context,
    required String label,
    required String email,
  }) {
    final employee = findEmployeeByEmail(email);
    final String photo = employee.displayPhoto;
    final bool hasPhoto =
        photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;

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

  /// "Start Date: 10 Oct 2024" -- grey label, dark value, both 10.sp.
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

  TableRow _buildHeaderRow(BuildContext context) {
    final headers = [
      'NO',
      'Control Owner',
      'Assigned By',
      'Start Date',
      'End Date',
    ];

    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (header) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Text(grcTr(context, header),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildDataRow({
    required BuildContext context,
    required ControlOwnerHistoryEntry entry,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? AppColors.background : AppColors.field,
      ),
      children: [
        _cell(
          Text(
            '${index + 1}',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            employeeDisplayName(context, entry.ownerEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            employeeDisplayName(context, entry.assignedByEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.startDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.endDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: child,
    );
  }
}
