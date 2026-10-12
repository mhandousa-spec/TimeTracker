/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_details_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_details_section.dart
/// Purpose: Contains the document details screen in view_knowledge_details.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
// REMOVED_MODULE(messaging): import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE(messaging): import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import './build_action_buttons.dart';

import './document_info_card.dart';

Widget buildDocumentDetailsSection(
    BuildContext context, {
      required String knowledgeId,
      required String documentName,
      required String documentType,
      required String owningDepartment,
      required String publishDate,
      required String documentDescription,
      required String fileUrl,
      required String fileType,
      required String documentExtension,
      required String createdByEmail, // ✅ ADD THIS - creator's email
    }) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  var lightMode = Theme.of(context).brightness == Brightness.light;
  var isMobile = ContextExtension(context).isPhone;
  var isDesktop = MediaQuery.of(context).size.width > 900;
  // ✅ Get employee controller to fetch creator data
  final employeeController = Get.find<MainCoreEmployeeController>();

  // ✅ Get creator's employee data using email
  final creatorEmployee = employeeController.getLocaleEmployee(createdByEmail);

  // ✅ Extract dynamic data with fallbacks
  final String creatorName = creatorEmployee != null
      ? employeeController.getEmployeeName(createdByEmail)
      : 'Unknown User';

  final String creatorTitle = creatorEmployee != null
      ? employeeController.getEmployeeJobTitle(createdByEmail)
      : '-';

  final String creatorDepartment = creatorEmployee != null
      ? employeeController.getEmployeeDepartmentName(createdByEmail)
      : '-';

  final String creatorPhone = () {
    final phone = isArabic ? "${creatorEmployee?.mobilePhone?.phone} ${creatorEmployee?.mobilePhone?.countryCode}" :
    "${creatorEmployee?.mobilePhone?.countryCode} ${creatorEmployee?.mobilePhone?.phone}"
    ;
    if (phone == null || phone.isEmpty) return '-';
    // Remove brackets if they exist
    return phone.replaceAll(RegExp(r'[\[\]]'), '');
  }();

  final String creatorEmail = creatorEmployee?.email ?? createdByEmail;
  // REMOVED_MODULE: messaging is not part of this build, so the chat button
  // below (and the ConnectionsCubit lookup that gated it) are commented out.
  // final currentUserEmail = context.read<ConnectionsCubit>().currentUser.userId;
  // final bool isCreatorCurrentUser = creatorEmail == currentUserEmail;
  final String creatorPhoto = creatorEmployee != null
      ? employeeController.getEmployeePhoto(createdByEmail)
      : "assets/icons_assets/main_icons_assets/assets_male.svg";

  // ✅ Determine if photo is network or asset
  final bool isNetworkPhoto = creatorPhoto.startsWith('http');

  return SingleChildScrollView(
    child: Column(
      children: [

        buildActionButtons(
          createdByEmail : createdByEmail,
          knowledgeId: knowledgeId,
          createdBy: createdByEmail,  // ✅ Add this line
          fileName: documentName,
          fileType: fileType,
          fileUrl: fileUrl,
          department: owningDepartment,
          documentExtension: documentExtension,
        ),


        SizedBox(height: 15.h),

        // ✅ CREATOR INFORMATION CARD
       isMobile ? SizedBox() :  Stack(
          children: [
            Container(

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.card
              ),
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child:ClipRRect(
                        borderRadius: BorderRadius.circular(40.r),
                        child: CustomSvgImage(
                          assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                          width: 75.w, // ✅ Changed to match container size
                          height: 80.h, // ✅ Changed to match container size
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.sp),
                    // ✅ CREATOR DETAILS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Row(
                          children: [
                            Text(
                              FormatHelper.capitalize(creatorName),
                              style: StyleText.fontSize16Weight500.copyWith(
                                  color: lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                        SizedBox(height: 16.sp),

                        // Details Grid
                     !isDesktop ?   Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         // Title
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             SizedBox(
                               child: CustomSvgImage(
                                 assetPath: "assets/icons_assets/main_icons_assets/svg_Case.svg",
                                 width: 16.w,
                                 height: 16.h,
                                 fit: BoxFit.fill,
                               ),
                             ),
                             SizedBox(width: 8.sp),
                             Text(
                               "${S.of(context).title}: ",
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                             Text(
                               FormatHelper.capitalize(creatorTitle),
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: 5.h),
                         // Department
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,

                           children: [
                             CustomSvgImage(
                               assetPath: "assets/icons_assets/main_icons_assets/images_department.svg",
                               width: 11,
                               height: 11,
                               fit: BoxFit.fill,
                             ),
                             SizedBox(width: 8.sp),
                             Text(
                               "${S.of(context).department}: ",
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                             Text(
                               FormatHelper.capitalize(creatorDepartment),
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                           ],
                         ),

                         SizedBox(height: 5.h),
                         // Phone
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,

                           children: [
                             CustomSvgImage(
                               assetPath: "assets/icons_assets/main_icons_assets/phone_number.svg",
                               width: 11,
                               height: 11,
                               fit: BoxFit.scaleDown,
                             ),
                             SizedBox(width: 8.sp),
                             Text(
                               "${S.of(context).phoneNumber}: ",
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                             Text(
                               creatorPhone,
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: 5.h),
                         // Email
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,

                           children: [
                             CustomSvgImage(
                               assetPath: "assets/icons_assets/main_icons_assets/images_email.svg",
                               width: 11,
                               height: 11,
                               fit: BoxFit.scaleDown,
                             ),
                             SizedBox(width: 8.sp),
                             Text(
                               "${S.of(context).email}: ",
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                             ),
                             Text(
                               creatorEmail,
                               style: StyleText.fontSize14Weight500.copyWith(
                                   color: lightMode
                                       ? AppColors.secondaryText
                                       : AppColors.grey
                               ),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ],
                         ),
                       ],
                     ) :
                     Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Left Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Row(
                                  children: [
                                    CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/svg_Case.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.darkGrey,
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      "${S.of(context).title}: ",
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.secondaryText
                                      ),
                                    ),
                                    Text(
                                      FormatHelper.capitalize(creatorTitle),
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18.h),
                                // Department
                                Row(
                                  children: [
                                    CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/images_department.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.darkGrey,
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      "${S.of(context).department}: ",
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.secondaryText
                                      ),
                                    ),
                                    Text(
                                      FormatHelper.capitalize(creatorDepartment),
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.text
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(width: 44.sp),

                            // Right Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone
                                Row(
                                  children: [
                                    CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/phone_number.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.darkGrey,
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      "${S.of(context).phoneNumber}: ",
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color:AppColors.secondaryText
                                      ),
                                    ),
                                    Text(
                                      creatorPhone,
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color:AppColors.text
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 18.h),
                                // Email
                                Row(
                                  children: [
                                    CustomSvgImage(
                                      assetPath: "assets/icons_assets/main_icons_assets/images_email.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.darkGrey,
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      "${S.of(context).email}: ",
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.secondaryText
                                      ),
                                    ),
                                    Text(
                                      creatorEmail,
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: AppColors.text
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

// REMOVED_MODULE(messaging):             // ✅ CHAT BUTTON
// REMOVED_MODULE(messaging):             Positioned(
// REMOVED_MODULE(messaging):               top: 10.sp,
// REMOVED_MODULE(messaging):               left: isArabic ? 10.sp : null,
// REMOVED_MODULE(messaging):               right: isArabic ? null : 10.sp,
// REMOVED_MODULE(messaging):               child: isCreatorCurrentUser  ? SizedBox() : customButtonWithSvg(
// REMOVED_MODULE(messaging):                   space: ContextExtension(context).isPhone ? 0.sp : 8.sp,
// REMOVED_MODULE(messaging):                   colorBorder: AppColors.transparent,
// REMOVED_MODULE(messaging):                   heightImage: 20.h,
// REMOVED_MODULE(messaging):                   widthImage: 20.w,
// REMOVED_MODULE(messaging):                   title: isMobile ? "" : "Chat".tr,
// REMOVED_MODULE(messaging):                   function: () async {
// REMOVED_MODULE(messaging):                     debugPrint("🔴 Button clicked!");
// REMOVED_MODULE(messaging):                     debugPrint("🔴 Creator email: $creatorEmail");
// REMOVED_MODULE(messaging):                     debugPrint("🔴 Context is tablet: ${Get.context!.isTablet}");

// REMOVED_MODULE(messaging):                     try {
// REMOVED_MODULE(messaging):                       await MessageInterfaceConsumer.openSingleChat(
// REMOVED_MODULE(messaging):                           creatorEmail,
// REMOVED_MODULE(messaging):                           Get.context!
// REMOVED_MODULE(messaging):                       );
// REMOVED_MODULE(messaging):                       debugPrint("🟢 openSingleChat completed");
// REMOVED_MODULE(messaging):                     } catch (e) {
// REMOVED_MODULE(messaging):                       debugPrint("❌ Error in button: $e");
// REMOVED_MODULE(messaging):                     }
// REMOVED_MODULE(messaging):                   },
// REMOVED_MODULE(messaging):                   color: AppColors.primary,
// REMOVED_MODULE(messaging):                   width: isMobile ? 38.w : 150.w,
// REMOVED_MODULE(messaging):                   height: 38.h,
// REMOVED_MODULE(messaging):                   radius: 4.r,
// REMOVED_MODULE(messaging):                   textStyle: StyleText.fontSize16Weight500.copyWith(
// REMOVED_MODULE(messaging):                       color: AppColors.textButton
// REMOVED_MODULE(messaging):                   ),
// REMOVED_MODULE(messaging):                   image: 'assets/icons_assets/main_icons_assets/roles_icons_Messages.svg'
// REMOVED_MODULE(messaging):               ),
// REMOVED_MODULE(messaging):             )
          ],
        ),

        isMobile ? SizedBox() :  SizedBox(height: 15.h),

        // ✅ DOCUMENT INFO CARD
        Stack(
          alignment: Alignment.topLeft,
          children: [
            buildDocumentInfoCard(
              context,
              publishDate: publishDate,
              documentDescription: documentDescription,
              documentName: documentName,
              documentType: documentType,
              owningDepartment: owningDepartment,
              documentExtension: documentExtension,
            ),
            Positioned(
              top: 8.sp,
              left: isArabic ? 10.sp : null,
              right: isArabic ? null : 10.sp,
              child: buildPublishDate(context, publishDate: publishDate),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    ),
  );
}