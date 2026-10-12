/// ************************* FILE INFO *************************** ///
/// File Name: file_card.dart
/// Purpose: Contains all data of each knowledge file viewed in home page.
/// Author: Youssef Khaled

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart'; // ✅ ADD THIS
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/87-responsive_card_grid.dart';
import '../../../data/models/create_knowledge_new_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/shared_functions/format_date.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import './file_card_widgets/card_date.dart';
import './file_card_widgets/card_values.dart';

/// Rewrite the ASCII digits in [value] as Arabic-Indic numerals (٠١٢…) when
/// [arabic] is true, so the publish/last-edit dates read in Arabic figures
/// under the Arabic locale (letters and separators are left untouched).
String _localizeDigits(String value, bool arabic) {
  if (!arabic) return value;
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var out = value;
  for (var i = 0; i < western.length; i++) {
    out = out.replaceAll(western[i], eastern[i]);
  }
  return out;
}

Widget fileCard(
    BuildContext context, {
      required CreateKnowledgeModel knowledge,
      String? currentUserEmail, // ✅ ADD THIS PARAMETER (optional)
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  var isArabic = Localizations.localeOf(context).languageCode == 'ar';

  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/knowledgeVideo.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/excell.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }

  // ✅ NEW: Determine if current user is owner or contributor
  bool isOwner() {
    try {
      // Get current user email
      String? userEmail = currentUserEmail;

      // If not passed as parameter, try to get from controller
      if (userEmail == null || userEmail.isEmpty) {
        try {
          final employeeController = Get.find<MainCoreEmployeeController>();
          userEmail = employeeController.employeeEntity?.email;
        } catch (e) {
          print('⚠️ Could not get user email from controller: $e');
          return false; // If we can't determine, assume not owner
        }
      }

      if (userEmail == null || userEmail.isEmpty) {
        return false;
      }

      // Check if current user created this document
      if (knowledge.createdByEmail.isEmpty) {
        return false;
      }

      String creatorEmail = knowledge.createdByEmail.first.toLowerCase().trim();
      String currentEmail = userEmail.toLowerCase().trim();

      return creatorEmail == currentEmail;
    } catch (e) {
      print('⚠️ Error checking ownership: $e');
      return false;
    }
  }

  // ✅ FIX: Get department name in the correct language
  String getDepartmentName() {
    try {
      final departmentController = Get.find<MainCoreDepartmentCubit>();
      final departmentNameOrId = knowledge.currentOwningDepartment;

      // First, try to get department ID from the name
      String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: departmentNameOrId.toLowerCase(),
      );

      // If we couldn't get ID, it might already be an ID, so use it directly
      if (departmentId == null || departmentId == "none") {
        departmentId = departmentNameOrId;
      }

      // Get department name based on current locale
      String? localizedName;
      if (isArabic) {
        localizedName = departmentController.getArabicDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        );
      } else {
        localizedName = departmentController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        );
      }

      // Return localized name or fallback to original value
      return localizedName ?? knowledge.currentOwningDepartment;
    } catch (e) {
      // Fallback to the stored value if controller not found
      print('⚠️ Error getting department name: $e');
      return knowledge.currentOwningDepartment;
    }
  }

  final imageUrl = _getImageUrl(knowledge);
  final fileIcon = imageUrl == null ? getFileIcon(knowledge.currentDocumentExtension) : null;

  final uploadDate = _localizeDigits(
    formatDate(
        knowledge.timeStamp.lastOrNull != null
            ? DateTime.tryParse(knowledge.timeStamp.lastOrNull!)
            : null
    ),
    isArabic,
  );
  final lastEditDate = _localizeDigits(_getLastEditDate(knowledge), isArabic);

  // ✅ NEW: Determine badge text and color
  final bool userIsOwner = isOwner();
  final String badgeText = userIsOwner ? S.of(context).owner : S.of(context).contributor;
  final Color badgeColor = AppColors.primary; // ✅ Both use primary color now
  // The card is laid out inside a fixed-extent grid cell, so its content must
  // adapt to whatever height it is given instead of asserting its own. Text
  // scaling is clamped and the vertical gaps/padding collapse under pressure so
  // the card never overflows, at any window size or text scale.
  return MediaQuery.withClampedTextScaling(
    maxScaleFactor: 1.2,
    child: Stack(
      children: [
        // Fills the grid cell so every card keeps the same background size no
        // matter how much its content had to shrink.
        Positioned.fill(
          child: LayoutBuilder(
          builder: (context, constraints) {
            // Padding shrinks on short cells rather than squeezing the text.
            final double vPadding = constraints.hasBoundedHeight
                ? (constraints.maxHeight * 0.12).clamp(2.0, 10.0)
                : 10.0;
            final double hPadding = 10.0;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: lightMode
                    ? AppColors.white
                    : AppColors.chatBackground,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: hPadding,
                vertical: vPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildFilePreview(
                    imageUrl: imageUrl,
                    fileIcon: fileIcon,
                    fileExtension: knowledge.currentDocumentExtension,
                    getFileIcon: getFileIcon,
                    lightMode: lightMode,
                    maxHeight: constraints.hasBoundedHeight
                        ? (constraints.maxHeight - vPadding * 2)
                        .clamp(0.0, double.infinity)
                        : double.infinity,
                  ),
                  SizedBox(width: 10.h),

                  // Text block. Laid out at its natural size inside a fixed
                  // width, then uniformly scaled down by FittedBox if the cell
                  // is shorter than the content needs. This is what makes the
                  // card overflow-proof at any grid size / text scale.
                  Expanded(
                    child: ResponsiveCardContent(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Document name
                                Text(
                                  FormatHelper.capitalize(isArabic
                                      ? knowledge.currentNameArabic
                                      : knowledge.currentNameEnglish,),
                                  style: StyleText.fontSize12Weight500
                                      .copyWith(
                                    color: lightMode
                                        ? AppColors.blackButton
                                        : AppColors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.sp),

                                // Owning department - ✅ FIXED: Now dynamic
                                buildInfoRow(
                                  context,
                                  label:
                                  "${S.of(context).owning_department}: ",
                                  value: isArabic
                                      ? getDepartmentName()
                                      : FormatHelper.capitalize(
                                      getDepartmentName()),
                                  lightMode: lightMode,
                                ),

                                SizedBox(height: 6.sp),

                                // Dates row
                                Row(
                                  children: [
                                    buildDateInfo(
                                      context,
                                      "${S.of(context).publish_date}: ",
                                      uploadDate,
                                      lightMode,
                                    ),
                                    Spacer(),
                                    Align(
                                      alignment: isArabic
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: buildDateInfo(
                                        context,
                                        '${S.of(context).last_edit}: ',
                                        lastEditDate,
                                        lightMode,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
          ),
        ),

        // ✅ UPDATED: Dynamic Owner/Contributor badge
        Positioned(
          top: 5.h,
          right: isArabic ? null : 5.h,
          left: isArabic ? 5.h : null,
          // Sizes to its label instead of a fixed box, so it can never clip or
          // overflow whatever the locale or text scale is.
          child: Container(
            constraints: BoxConstraints(maxWidth: 80.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: badgeColor, // ✅ Dynamic color
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                badgeText, // ✅ Dynamic text
                maxLines: 1,
                style: StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.textButton,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String? _getImageUrl(CreateKnowledgeModel knowledge) {
  if (knowledge.imageUrl!.isNotEmpty) {
    final url = knowledge.imageUrl!.first;
    if (url.isNotEmpty && url.startsWith('http')) {
      return url;
    }
  }
  return null;
}

Widget _buildFilePreview({
  required String? imageUrl,
  required String? fileIcon,
  required String fileExtension,
  required String Function(String) getFileIcon,
  required bool lightMode,
  double maxHeight = double.infinity,
}) {
  // The preview never exceeds the height the cell actually offers, so a short
  // grid cell shrinks the thumbnail instead of overflowing the row.
  final double previewHeight =
  maxHeight.isFinite ? (45.h).clamp(0.0, maxHeight) : 45.h;
  final double previewWidth =
  previewHeight <= 0 ? 0.0 : 40.w * (previewHeight / (45.h));

  if (imageUrl != null) {
    // Display actual image with loading and error handling
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Image.network(
        imageUrl,
        width: previewWidth,
        height: previewHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image fails to load
          return CustomSvgImage(
            assetPath: getFileIcon(fileExtension),
            height: previewHeight,
            width: previewWidth,
            fit: BoxFit.contain,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show loading indicator while image is loading
          return Container(
            width: previewWidth,
            height: previewHeight,
            decoration: BoxDecoration(
              color: lightMode ? Colors.grey[200] : Colors.grey[800],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    lightMode ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  } else {
    // Display file type icon when no image is available
    return SizedBox(
      width: previewWidth,
      height: previewHeight,
      child: CustomSvgImage(
        assetPath: fileIcon ?? getFileIcon(fileExtension),
        width: previewWidth,
        height: previewHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}

String _getLastEditDate(CreateKnowledgeModel knowledge) {
  if (knowledge.timestamps.isEmpty) return 'N/A';
  final lastTimestamp = knowledge.timestamps.last;
  final lastEditDateTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
  return formatDate(lastEditDateTime);
}