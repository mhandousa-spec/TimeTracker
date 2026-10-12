/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/statistics_tab/filter_statistics.dart
/// ************************* FILE INFO *************************** ///
/// File Name: filter_statistics.dart
/// Purpose: Filter statistics — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import '../../../../controller/analytics_cubit.dart';
import './filter_statistics_dialog.dart';
// ADDED 2/9/2026 — the Export permission check.
import '../../../../../../main_controller/helper/knowledge_hub_permissions.dart';

Widget filterStatistics(
  BuildContext context, {
  required TextEditingController searchController,
  required Function(String) onSearchChanged,
}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AppSearchTextField(
        controller: searchController,
        onChanged: onSearchChanged,
      ),
      SizedBox(width: 10.w,),
      Container(
        height: 38.h,
        width: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card
        ),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => Center(
                child: BlocProvider.value(
                  value: context.read<AnalyticsCubit>(),
                  child: FilterStatisticsDialog(),
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
                height: 23.h,
                width: 23.w,
                color: AppColors.secondaryText
              ),
              SizedBox(width: 8.sp),
              Text(S.of(context).filter,style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              )
            ],
          ),
        ),
      ),
      // GATED 2/9/2026 on `exportStatisticsTable`, which was checked nowhere
      // in the module — the Export button rendered for every role that could
      // reach the statistics tab.
      if (KnowledgeHubAccess.canExportStatistics) ...[
      SizedBox(width: 10.w,),
      GestureDetector(
        // IMPLEMENTED 22/9/2026 — reported as "not work", and it did not: this
        // `onTap` was an empty body, so the Export button was a painted
        // rectangle. It now writes the VISIBLE rows (the table after the
        // filter and search are applied) through `CSVHelper.exportForUser`,
        // which is the app's one save path — SAF / "Save to Files" on phones,
        // the real Downloads folder on desktop, UTF-8 BOM so Excel reads the
        // Arabic columns.
        onTap: () => _exportStatistics(context),
        child: Container(
          height: 38.h,
          width: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/main_icons_assets/assets_export.svg',
                height: 20.h,
                width: 20.w,
                fit: BoxFit.fill,

                  color: AppColors.textButton
              ),
              Row(
                children: [
                  SizedBox(width: 5.w,),
                  Text(
                    S.of(context).export,
                    style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ],
    ],
  );
}

/// Writes the statistics table to a CSV and hands it to the user.
///
/// Reads the rows from [AnalyticsCubit] rather than rebuilding them from the
/// widget tree, so the file matches the table exactly — same columns, same
/// order, same filter.
Future<void> _exportStatistics(BuildContext context) async {
  final cubit = context.read<AnalyticsCubit>();
  final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

  final List<String> headers = <String>[
    S.of(context).number,
    S.of(context).employeeName,
    S.of(context).department,
    S.of(context).jobTitle,
    S.of(context).date,
    S.of(context).time,
    S.of(context).action,
  ];

  final rows = cubit.buildStatisticsExportRows(
    headers: headers,
    isArabic: isArabic,
  );

  // Header only: nothing to export, and a file with one line in it is a worse
  // answer than saying so.
  if (rows.length <= 1) {
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
      title: S.of(context).noDataAvailable,
    );
    return;
  }

  final String fileName =
      'knowledge_hub_statistics_${DateTime.now().millisecondsSinceEpoch}';

  final result = await CSVHelper().exportRowsForUser(
    fileName: fileName,
    rows: rows,
  );

  if (!context.mounted) return;

  // CHANGED 28/9/2026 (Knowledge Hub bug report p.24): the outcome is a
  // confirmation DIALOG, not a SnackBar ("Export Successful" in the corner),
  // and — see `CSVHelper.exportForUser` — the file manager no longer opens.
  final String? error = result.fold((l) => l, (_) => null);
  final String? path = result.fold((_) => null, (r) => r);

  if (error != null) {
    log('❌ Statistics export failed: $error');
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      title: S.of(context).exportFailed,
      subtitle: error,
    );
    return;
  }

  // An empty path is the user dismissing the save sheet — nothing was written
  // and nothing went wrong, so there is nothing to report.
  if (path == null || path == CSVHelper.exportCancelled) return;
  log('✅ Statistics exported to: $path');
  await CustomDialogManager.showSuccess(
    context: context,
    lottiePath: 'assets/lottie_assets/main_lottie_assets/check.json',
    title: S.of(context).exportSuccessful,
    subtitle: S.of(context).exportSuccess,
  );
}
