import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/analytics_helper.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_text_field_entity.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
class TextFieldAnalytics extends StatelessWidget {
  TextFieldAnalytics({required this.entity, super.key});
  AnalyticsEntity entity;
  @override
  @override
  Widget build(BuildContext context) {
    // ✅ Add null check
    if (entity.data == null || entity.data!.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: StyleText.fontSize12Weight500,
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: entity.data!.map((item) {
        return SizedBox(
          width: _getItemWidth(context),
          child: mainTextFieldWidget(item, entity.type),
        );
      }).toList(),
    );
  }

  Widget mainTextFieldWidget(AnalyticsTextFieldEntity entity, FormFieldType type) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Submission Date' + ": ",
                        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.spanText)
                            .copyWith(fontSize: 8.sp),
                      ),
                      TextSpan(
                          //number
                          text:
                              ' ${FormDateTimeHelper.formatDate(entity.submissionDate)}',
                          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                              .copyWith(fontSize: 8.sp))
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r)
                      ,
                      child: SizedBox(
                        child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",width: 35.w,height: 35.h,fit: BoxFit.fill,),
                      ),
                    ),
                  ),
                  horizontalSpace(10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FormatHelper.capitalize(entity.person.name),
                          style: StyleText.fontSize12Weight500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Job Title:' + " ",
                                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.spanText),
                              ),
                              TextSpan(
                                  //number
                                  text: entity.person.title,
                                  style:
                                      StyleText.fontSize12Weight400.copyWith(color: AppColors.fullBlack))
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(10),
            if (type == FormFieldType.description)
              descriptionTextField(entity.answers.first)
            else if (type == FormFieldType.phone)
              phoneTextField(entity.answers.first)
            else if (type == FormFieldType.location)
              locationTextField(entity.answers.first)
            else if (type == FormFieldType.address)
              addressTextField(entity.answers.first)
            else if (type == FormFieldType.timeSelector)
              timeSelectorTextField(entity.answers.first)
            else
              customTextField(
                width: type == FormFieldType.dateSelector ? 150.w : null,
                entity.answers.first,
                alignment:
                    type == FormFieldType.dateSelector ? Alignment.center : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget descriptionTextField(String description) {
    
    return Text(
      description,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
      maxLines: 1000,
      textAlign: TextAlign.start,
    );
  }

  Widget _buildPhoneInputRow(String answer) {
    List<String> phone = answer.split('-');
    final Country? country = AnalyticsHelper.safeParsePhoneCode(phone[0]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCountryCodeSelector(Get.context!, country),
        horizontalSpace(8),
        _buildPhoneNumberField(phone.last),
      ],
    );
  }

  Widget _buildPhoneNumberField(String phone) {
    return Expanded(
      child: Center(
          child: CustomTextField(
        height: 36,
        readOnly: true,
        initialValue: phone,
        showCharCount: false,
        maxLines: 1,
        fillColor: AppColors.background,
        width: double.infinity,
      )),
    );
  }

  Widget _buildCountryCodeSelector(BuildContext context, Country? country) {
    return Container(
      height: 36,
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {},
        child: Center(
          child: _buildCountryCodeRow(country),
        ),
      ),
    );
  }

  Widget phoneTextField(String answer) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
        width: _getItemWidth(Get.context!) / 4,
        child: customTextField(answer.split('-').first),
      ),
      SizedBox(
          width: (2.66 * (_getItemWidth(Get.context!) / 4)) - 10.w,
          child: customTextField(answer.split('-').last)),
    ]);
  }

  Row _buildCountryCodeRow(Country? country) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 12,
          child: (country != null)
              ? Image.asset(
                  'assets/png_assets/flags/${country.countryCode.toLowerCase()}.png',
                )
              : Container(),
        ),
        horizontalSpace(8),
        Text(
            (country == null)
                ? ""
                : ' +${FormDateTimeHelper.formatInt(country.phoneCode.toEnglishNumber())}',
            style: StyleText.fontSize14Weight400),
        horizontalSpace(5),
        SizedBox(
          height: 12,
          width: 12,
          child: SvgPicture.asset(
            AppAssets.arrowDown,
            colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  Widget locationTextField(String location) {
    if (location.contains(',')) {
      return customTextField(location);
    } else {
      return Column(children: [
        customTextField(location.split(',').first),
        verticalSpace(10),
        customTextField(
          location.split(',').last,
        ),
      ]);
    }
  }

  Widget customTextField(String text, {Alignment? alignment, double? width}) {
    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(
              child: Container(
            alignment: alignment,
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              text,
              style: StyleText.fontSize12Weight500,
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ],
      ),
    );
  }

  int _getRowItems(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (entity.type == FormFieldType.description) {
      if (screenWidth > 3600) {
        return 4;
      } else if (screenWidth > 2400) {
        return 3;
      } else if (screenWidth <= 2400 && screenWidth > 1200) {
        return 2;
      } else if (screenWidth > 600 && screenWidth < 1200) {
        return 1;
      }
      return 1;
    } else {
      if (screenWidth > 3600) {
        return 6;
      } else if (screenWidth > 2400) {
        return 5;
      } else if (screenWidth <= 2400 && screenWidth > 1200) {
        return 4;
      } else if (screenWidth > 600 && screenWidth < 1200) {
        return 3;
      }
      return 1; // Default for phone
    }
  }

  double _getItemWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    if (isTablet) {
      screenWidth -= isPortrait ? 200.w : 200.w; // Adjust for tablet
    }
    int columns = _getRowItems(context);
    double spacing = 10; // same as Wrap spacing
    return (screenWidth - (columns - 1) * spacing) / columns;
  }

  addressTextField(String answer) {
    List<String> address = answer.split(',   ');
    return Column(
      spacing: 10.h,
      children: [for (String item in address) customTextField(item)],
    );
  }

  timeSelectorTextField(String answer) {
    
    return Row(children: [
      SizedBox(
        width: 50.w,
        child: customTextField(answer.split(' ').first,
            alignment: Alignment.center),
      ),
      horizontalSpace(10),
      SizedBox(
        width: 50.w,
        child: customTextField(answer.split(' ').last,
            alignment: Alignment.center),
      ),
    ]);
  }
}
