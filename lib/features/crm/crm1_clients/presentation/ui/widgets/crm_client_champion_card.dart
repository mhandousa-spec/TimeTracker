// ****************** FILE INFO ******************
// File Name: crm_client_champion_card.dart
// Purpose: Large champion profile header card for the CRM client profile
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientChampionCard extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmClientTypeModel? clientType;
  final String fallbackTitle;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final VoidCallback? onMessage;
  final VoidCallback? onBlacklist;
  final VoidCallback? onRemove;
  final ValueChanged<String>? onStatusChanged;

  const CrmClientChampionCard({
    super.key,
    required this.record,
    this.clientType,
    this.fallbackTitle = 'Client Profile',
    this.onCall,
    this.onEmail,
    this.onMessage,
    this.onBlacklist,
    this.onRemove,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Bar: Status Dropdown/Badge on Left, Blacklist & Remove on Right
        _buildTopActionBar(context, isMobile),
        SizedBox(height: 12.sp),

        // Champion Large Card Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        ),
      ],
    );
  }

  Widget _buildTopActionBar(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status Badge / Indicator
        _buildStatusPill(context),

        // Action Buttons: Blacklist & Remove
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: record.status.toLowerCase() == 'blacklist'
                    ? 'Request Removal'
                    : 'Blacklist',
                arabicName: record.status.toLowerCase() == 'blacklist'
                    ? 'طلب إزالة'
                    : 'القائمة السوداء',
              ),
              function: onBlacklist ?? () {},
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontSize: 13.sp,
              ),
              color: AppColors.secondaryBlack,
              colorBorder: AppColors.transparent,
              image: AppAssets.crmBlacklist,
              widthImage: 16.sp,
              heightImage: 16.sp,
              svgColor: AppColors.white,
            ),
            SizedBox(width: 8.sp),
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Remove',
                arabicName: 'حذف',
              ),
              function: onRemove ?? () {},
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontSize: 13.sp,
              ),
              color: AppColors.red,
              colorBorder: AppColors.transparent,
              image: AppAssets.crmTrush,
              widthImage: 16.sp,
              heightImage: 16.sp,
              svgColor: AppColors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill(BuildContext context) {
    final String currentStatus =
        record.status.isEmpty ? 'active' : record.status.toLowerCase();
    final Color statusColor = _statusColor(currentStatus);
    final String statusLabel = _statusLabel(currentStatus);

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: AppColors.transparent,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
      ),
      child: PopupMenuButton<String>(
        tooltip: '',
        onSelected: (String newStatus) {
          if (newStatus != currentStatus) {
            onStatusChanged?.call(newStatus);
          }
        },
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.sp),
          side: BorderSide(
            color: AppColors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        offset: Offset(0, 36.sp),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'active',
            height: 38.sp,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.sp,
                  height: 8.sp,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.current.crmActive,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: currentStatus == 'active'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentStatus == 'active'
                        ? AppColors.green
                        : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'inactive',
            height: 38.sp,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.sp,
                  height: 8.sp,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.current.crmInactive,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: currentStatus == 'inactive'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentStatus == 'inactive'
                        ? AppColors.orange
                        : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6.sp),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusLabel,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.white,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 6.sp),
              CustomSvgImage(
                assetPath: AppAssets.arrowDown,
                width: 12.sp,
                height: 12.sp,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar circle
        _buildAvatar(),
        SizedBox(width: 16.sp),

        // Info Columns
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client Name + Badge
              _buildNameAndBadge(),
              SizedBox(height: 10.sp),

              // Metadata Rows
              _buildMetadataGrid(),
            ],
          ),
        ),
        SizedBox(width: 20.sp),

        // Quick Action Buttons (Call, Email, Message)
        _buildQuickActionButtons(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 12.sp),
            Expanded(child: _buildNameAndBadge()),
          ],
        ),
        SizedBox(height: 12.sp),
        _buildMetadataGrid(),
        SizedBox(height: 16.sp),
        _buildQuickActionButtons(context),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56.sp,
      height: 56.sp,
      decoration: BoxDecoration(
        color: AppColors.secondaryBlack,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: clientType?.svgAsset ?? AppAssets.crmPerson,
        width: 30.sp,
        height: 30.sp,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildNameAndBadge() {
    final String displayName = record.primaryDisplayValue ?? fallbackTitle;
    final String typeName = clientType != null
        ? FormatHelper.localizedString(
            englishName: clientType!.nameEn,
            arabicName: clientType!.nameAr,
          )
        : S.current.crmClients;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            displayName,
            style: StyleText.fontSize18Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: Text(
            typeName,
            style: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataGrid() {
    final String typeLabel = clientType?.nameEn ?? 'Company';
    final String countryValue =
        (record.valueFor(null, 'country') ?? 'Egypt').toString();
    final String industryValue = (record.valueFor(null, 'industry') ??
            record.valueFor(null, 'sector') ??
            'IT')
        .toString();
    final String purchasingValue = (record.valueFor(null, 'purchasing_value') ??
            record.valueFor(null, 'purchase_value') ??
            '\$525')
        .toString();

    return Row(
      children: [
        // Column 1: Type & Purchasing Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrmCardInfoItem(
                svgAsset: AppAssets.crmClientsType,
                label:
                    '${FormatHelper.localizedString(englishName: 'Type', arabicName: 'النوع')}:',
                value: typeLabel,
                iconSize: 16,
                fontSize: 12,
              ),
              SizedBox(height: 6.sp),
              CrmCardInfoItem(
                svgAsset: AppAssets.crmPrice,
                label:
                    '${FormatHelper.localizedString(englishName: 'Purchasing Value', arabicName: 'القيمة الشرائية')}:',
                value: purchasingValue,
                iconSize: 16,
                fontSize: 12,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.sp),

        // Column 2: Country & Industry
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrmCardInfoItem(
                svgAsset: AppAssets.addressIcon,
                label:
                    '${FormatHelper.localizedString(englishName: 'Country', arabicName: 'الدولة')}:',
                value: countryValue,
                iconSize: 16,
                fontSize: 12,
              ),
              SizedBox(height: 6.sp),
              CrmCardInfoItem(
                svgAsset: AppAssets.crmIndustryField,
                label:
                    '${FormatHelper.localizedString(englishName: 'Industry', arabicName: 'الصناعة')}:',
                value: industryValue,
                iconSize: 16,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Call',
            arabicName: 'اتصال',
          ),
          function: onCall ?? () {},
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
            fontSize: 13.sp,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.phone,
          widthImage: 16.sp,
          heightImage: 16.sp,
          svgColor: AppColors.black,
        ),
        SizedBox(width: 8.sp),
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Email',
            arabicName: 'بريد',
          ),
          function: onEmail ?? () {},
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
            fontSize: 13.sp,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.email,
          widthImage: 16.sp,
          heightImage: 16.sp,
          svgColor: AppColors.black,
        ),
        SizedBox(width: 8.sp),
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Message',
            arabicName: 'رسالة',
          ),
          function: onMessage ?? () {},
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
            fontSize: 13.sp,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.message,
          widthImage: 16.sp,
          heightImage: 16.sp,
          svgColor: AppColors.black,
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.green;
      case 'inactive':
        return AppColors.orange;
      case 'prospect':
        return AppColors.blue;
      case 'archived':
        return AppColors.grey;
      case 'deleted':
        return AppColors.red;
      default:
        return AppColors.green;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return S.current.crmActive;
      case 'inactive':
        return S.current.crmInactive;
      case 'prospect':
        return S.current.crmProspect;
      case 'archived':
        return S.current.crmArchived;
      default:
        return S.current.crmActive;
    }
  }
}
