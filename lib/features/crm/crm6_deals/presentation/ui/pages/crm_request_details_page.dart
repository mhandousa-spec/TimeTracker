// ****************** FILE INFO ******************
// File Name: crm_request_details_page.dart
// Purpose: Request Details view page showing status, Approved Details (date, time, approver info card), and Quote Details matching Figma screenshot 5
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmRequestDetailsPage extends StatelessWidget {
  final String dealTitle;
  final CrmDealRequestModel request;

  const CrmRequestDetailsPage({
    super.key,
    required this.dealTitle,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: dealTitle.isNotEmpty ? dealTitle : 'ERP System Deal',
        secondTitle: FormatHelper.localizedString(
          englishName: 'Requests',
          arabicName: 'الطلبات',
        ),
        thirdTitle: FormatHelper.localizedString(
          englishName: 'Request Name',
          arabicName: 'اسم الطلب',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── 1. Top Status Badge ─────────────────────────────────────────
              _buildStatusPill(request.status),

              SizedBox(height: 18.sp),

              // ── 2. Approved Details Section Card ───────────────────────────
              CrmSectionCard(
                title: FormatHelper.localizedString(
                  englishName: '${request.status.labelEn} Details',
                  arabicName: 'تفاصيل ${request.status.labelAr}',
                ),
                showHideToggle: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Date & Time
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        label: 'Date',
                        initialValue: request.approvalDate,
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                      right: CustomTextField(
                        label: 'Time',
                        initialValue: request.approvalTime,
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                    ),

                    SizedBox(height: 16.sp),

                    // By Label
                    Text(
                      'By',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 8.sp),

                    // Approver Info Card
                    _buildApproverCard(context),
                  ],
                ),
              ),

              SizedBox(height: 24.sp),

              // ── 3. Quote Details Section Card ───────────────────────────────
              CrmSectionCard(
                title: FormatHelper.localizedString(
                  englishName: 'Quote Details',
                  arabicName: 'تفاصيل عرض الأسعار',
                ),
                showHideToggle: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Quote Number (half-width)
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        label: 'Quote Number',
                        initialValue: request.quoteNo,
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                      right: const SizedBox.shrink(),
                    ),

                    SizedBox(height: 14.sp),

                    // Quote Date & Quote Date Until
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        label: 'Quote Date',
                        initialValue: request.createdDate,
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                      right: CustomTextField(
                        label: 'Quote Date Until',
                        hint: 'select',
                        initialValue: request.validUntil,
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                    ),

                    SizedBox(height: 14.sp),

                    // Note EN
                    CustomTextField(
                      label: 'Note',
                      initialValue: request.note,
                      readOnly: true,
                      fillColor: AppColors.background,
                      maxLines: 3,
                      minLines: 3,
                    ),

                    SizedBox(height: 14.sp),

                    // Note AR
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomTextField(
                        label: 'ملاحظة',
                        initialValue: request.noteAr,
                        readOnly: true,
                        fillColor: AppColors.background,
                        maxLines: 3,
                        minLines: 3,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(CrmRequestStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.labelEn,
        style: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildApproverCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 40.sp,
              height: 40.sp,
              color: const Color(0xFFE2E8F0),
              child: Image.asset(
                AppAssets.male,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: 24.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.sp),

          // User Info (Name, Job Title, Dept, Phone, Email)
          Expanded(
            child: Wrap(
              spacing: 16.sp,
              runSpacing: 4.sp,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  request.approverName,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Job Title: ${request.approverRole}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  'Department: ${request.approverDepartment}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  'Phone: ${request.approverPhone}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  'Email: ${request.approverEmail}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.sp),

          // Message Button
          customButtonWithSvg(
            title: FormatHelper.localizedString(
              englishName: 'Message',
              arabicName: 'رسالة',
            ),
            image: AppAssets.message,
            widthImage: 14.sp,
            heightImage: 14.sp,
            colorBorder: Colors.transparent,
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
            ),
            function: () {
              CrmControlDialogs.showSuccessDialog(
                context: context,
                title: 'Start Conversation',
                subtitle: 'Opening chat with ${request.approverName}...',
              );
            },
          ),
        ],
      ),
    );
  }
}
