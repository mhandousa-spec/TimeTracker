// ****************** FILE INFO ******************
// File Name: crm_merge_history_details_page.dart
// Purpose: History details page with Merge Details & Summary in same row matching Figma screenshots
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:intl/intl.dart';

class CrmMergeHistoryDetailsPage extends StatefulWidget {
  final CrmMergeHistoryModel history;

  const CrmMergeHistoryDetailsPage({
    super.key,
    required this.history,
  });

  @override
  State<CrmMergeHistoryDetailsPage> createState() =>
      _CrmMergeHistoryDetailsPageState();
}

class _CrmMergeHistoryDetailsPageState
    extends State<CrmMergeHistoryDetailsPage> {
  late bool _isUndone;

  @override
  void initState() {
    super.initState();
    _isUndone = widget.history.isRolledBack;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('d/M/yyyy').format(widget.history.mergedAt);
    final String formattedTime =
        DateFormat('h:mm a').format(widget.history.mergedAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmClients,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Duplicates Review & Merge',
          arabicName: 'مراجعة ودمج المكررات',
        ),
        thirdTitle: widget.history.masterClientName,
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: BlocBuilder<CrmDuplicatesCubit, CrmDuplicatesState>(
          builder: (BuildContext context, CrmDuplicatesState state) {
            final CrmDuplicatesCubit cubit = context.read<CrmDuplicatesCubit>();
            final CrmMergePreviewData preview =
                state.mergePreviewFor(widget.history);
            final CrmUndoAvailability undoAvailability =
                state.undoAvailabilityFor(widget.history);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Top Two Cards in the Same Row: Merge Details (Left) & Merge Summary (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Left: Merge Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              FormatHelper.localizedString(
                                englishName: 'Merge Details',
                                arabicName: 'تفاصيل الدمج',
                              ),
                              style:
                                  StyleText.fontSize14Weight500.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.sp),
                            _buildMergeDetailsCard(
                                formattedDate, formattedTime),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.sp),

                      // Right: Merge Summary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              FormatHelper.localizedString(
                                englishName: 'Merge Summary',
                                arabicName: 'ملخص الدمج',
                              ),
                              style:
                                  StyleText.fontSize14Weight500.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.sp),
                            _buildMergeSummaryCard(preview),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.sp),

                  // 2. Merge Preview Card
                  _buildMergePreviewCard(preview),
                  SizedBox(height: 32.sp),

                  // 3. Undo is controlled by the current Merge Controls.
                  if (undoAvailability.isAvailable) ...[
                    _buildUndoBanner(context, cubit, undoAvailability),
                    SizedBox(height: 32.sp),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMergeDetailsCard(String date, String time) {
    return Container(
      height: 130.sp,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Merged By
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                FormatHelper.localizedString(
                  englishName: 'Merged By',
                  arabicName: 'تم الدمج بواسطة',
                ),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 22.sp,
                    height: 22.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CustomSvgImage(
                      assetPath: AppAssets.crmPerson,
                      width: 14.sp,
                      height: 14.sp,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    widget.history.mergedBy,
                    style: StyleText.fontSize12Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                FormatHelper.localizedString(
                  englishName: 'Time',
                  arabicName: 'الوقت',
                ),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              Text(
                time,
                style: StyleText.fontSize12Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                FormatHelper.localizedString(
                  englishName: 'Date',
                  arabicName: 'التاريخ',
                ),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
              Text(
                date,
                style: StyleText.fontSize12Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMergeSummaryCard(CrmMergePreviewData preview) {
    final int updatedCount = widget.history.fieldsUpdated.length;
    final int unchangedCount = preview.totalFieldCount > updatedCount
        ? preview.totalFieldCount - updatedCount
        : 0;
    return Container(
      height: 130.sp,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Fields Updated',
              arabicName: 'الحقول المحدثة',
            ),
            value: updatedCount.toString(),
          ),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'New Values',
              arabicName: 'قيم جديدة',
            ),
            value: updatedCount.toString(),
          ),
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Unchanged',
              arabicName: 'بدون تغيير',
            ),
            value: unchangedCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize12Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMergePreviewCard(CrmMergePreviewData preview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Merge Preview',
            arabicName: 'معاينة الدمج',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Col 1: Full Name & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildPreviewItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Full Name',
                        arabicName: 'الاسم الكامل',
                      ),
                      value: preview.fullName,
                    ),
                    SizedBox(height: 14.sp),
                    _buildPreviewItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Phone',
                        arabicName: 'رقم الهاتف',
                      ),
                      value: preview.phone,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.sp),

              // Col 2: Email & Job Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildPreviewItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Email',
                        arabicName: 'البريد الإلكتروني',
                      ),
                      value: preview.email,
                    ),
                    SizedBox(height: 14.sp),
                    _buildPreviewItem(
                      label: FormatHelper.localizedString(
                        englishName: 'Job Title',
                        arabicName: 'المسمى الوظيفي',
                      ),
                      value: preview.jobTitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 80.sp,
          child: Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: StyleText.fontSize12Weight500.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUndoBanner(
    BuildContext context,
    CrmDuplicatesCubit cubit,
    CrmUndoAvailability undoAvailability,
  ) {
    final String expiryDate = DateFormat('d/M/yyyy').format(
      undoAvailability.expiresAt!,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left Icon + Details
          Row(
            children: <Widget>[
              CustomSvgImage(
                assetPath: AppAssets.crmUndo,
                width: 26.sp,
                height: 26.sp,
              ),
              SizedBox(width: 14.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Undo Available',
                      arabicName: 'التراجع متاح',
                    ),
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'You can undo this merge until $expiryDate',
                      arabicName: 'يمكنك التراجع عن هذا الدمج حتى $expiryDate',
                    ),
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Undo Button
          if (!_isUndone)
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Undo',
                arabicName: 'تراجع',
              ),
              color: AppColors.primary,
              textColor: AppColors.text,
              function: () => _showUndoConfirmationDialog(context, cubit),
            )
          else
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Undo',
                arabicName: 'تراجع',
              ),
              color: AppColors.darkGrey.withValues(alpha: 0.5),
              textColor: AppColors.card,
              function: () {},
            ),
        ],
      ),
    );
  }

  void _showUndoConfirmationDialog(
      BuildContext context, CrmDuplicatesCubit cubit) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(24.sp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Centered Yellow Undo Icon
              CustomSvgImage(
                assetPath: AppAssets.crmUndo,
                width: 32.sp,
                height: 32.sp,
              ),
              SizedBox(height: 12.sp),

              // Title
              Text(
                FormatHelper.localizedString(
                  englishName: 'Undo Merge',
                  arabicName: 'التراجع عن الدمج',
                ),
                style: StyleText.fontSize16Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.sp),

              // Message
              Text(
                FormatHelper.localizedString(
                  englishName: 'Are you sure to undo this merge ?',
                  arabicName: 'هل أنت متأكد من التراجع عن هذا الدمج؟',
                ),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.sp),

              // Actions: Cancel & Undo
              Row(
                children: <Widget>[
                  Expanded(
                    child: customButton(
                      title: FormatHelper.localizedString(
                        englishName: 'Cancel',
                        arabicName: 'إلغاء',
                      ),
                      color: AppColors.grey,
                      textColor: AppColors.text,
                      function: () => Navigator.pop(ctx),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: customButton(
                      title: FormatHelper.localizedString(
                        englishName: 'Undo',
                        arabicName: 'تراجع',
                      ),
                      color: AppColors.primary,
                      textColor: AppColors.text,
                      function: () async {
                        final bool succeeded =
                            await cubit.rollbackMerge(widget.history.id);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (succeeded && mounted) {
                          setState(() => _isUndone = true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
