// ***************************** FILE INFO ***************************** //
// File Name: employee_details_header.dart
// Purpose: Displays the read-only employee profile summary header.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../utils/employee_details_phone_formatter.dart';

/// Displays selected employee identity, contacts, and view-only actions.
class EmployeeDetailsHeader extends StatelessWidget {
  const EmployeeDetailsHeader(
      {required this.employee, required this.onEdit, super.key});

  final HrEmployeeEntity employee;
  final VoidCallback onEdit;

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves the employee department in the active app language.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether English department names are required.
  ///
  /// Returns: The resolved department name, or an empty value when unavailable.
  String _departmentName(bool isEnglish) {
    final id = employee.departmentId?.trim() ?? '';
    if (id.isEmpty) return '';
    return Get.find<MainCoreDepartmentCubit>().getDepartmentName(id, isEnglish);
  }

  /// Method Name: [_buildAvatar]
  ///
  /// Purpose: Builds a circular employee photo with an explicit cover fit.
  ///
  /// Returns: A local, network, or fallback avatar widget.
  Widget _buildAvatar() {
    final photo = employee.photo?.trim() ?? '';
    final diameter = 88.r;
    Widget fallback() => ClipOval(
          child: CardSvg.icon(CardSvg.male, size: 88),
        );

    Widget image;
    if (photo.isEmpty) {
      image = fallback();
    } else if (photo.startsWith('assets/')) {
      image = Image.asset(
        photo,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
      );
    } else {
      image = Image.network(
        photo,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(color: AppColors.barrierColor, child: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final name = employee.fullNameForLanguage(isEnglish: isEnglish);
    final title = employee.jobTitleForLanguage(isEnglish: isEnglish);
    final department = _departmentName(isEnglish);
    final localization = S.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 680.w;
          final details = _details(
            localization: localization,
            name: name,
            title: title,
            department: department,
          );
          final actions = _actions(localization);
          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                SizedBox(height: 14.h),
                actions,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              SizedBox(width: 18.w),
              actions
            ],
          );
        },
      ),
    );
  }

  /// Method Name: [_details]
  ///
  /// Purpose: Builds the employee avatar and metadata region of the header.
  ///
  /// Returns: The responsive employee identity content.
  Widget _details({
    required S localization,
    required String name,
    required String? title,
    required String department,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatHelper.capitalize(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CardStyles.title(20),
              ),
              SizedBox(height: 10.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final firstColumn = [
                    _infoRow(
                      label: '${localization.jobTitle}:',
                      value: title?.trim().isNotEmpty == true
                          ? title!.trim()
                          : localization.notAvailable,
                      icon: CardSvg.icon(
                        CardSvg.jobTitle,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                    _infoRow(
                      label: '${localization.department}:',
                      value: department.isEmpty
                          ? localization.notAvailable
                          : department,
                      icon: CardSvg.icon(
                        CardSvg.department,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ];
                  final phone = EmployeeDetailsPhoneFormatter.format(
                    countryCode: employee.mobilePhone?.countryCode,
                    number: employee.mobilePhone?.number,
                  );
                  final secondColumn = [
                    _infoRow(
                      label: '${localization.businessEmail}:',
                      value: employee.email?.trim().isNotEmpty == true
                          ? employee.email!.trim()
                          : localization.notAvailable,
                      icon: CardSvg.icon(
                        CardSvg.email,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                    _infoRow(
                      label: '${localization.phoneNumber}:',
                      value: phone.isEmpty ? localization.notAvailable : phone,
                      icon: CardSvg.icon(
                        CardSvg.phone,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ];
                  final columns = [firstColumn, secondColumn];
                  if (constraints.maxWidth < 560.w) {
                    return _metadataColumn([...firstColumn, ...secondColumn]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columns
                        .map((column) =>
                            Expanded(child: _metadataColumn(column)))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metadataColumn(List<Widget> fields) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            if (index > 0) SizedBox(height: 10.h),
            fields[index],
          ],
        ],
      );

  Widget _infoRow({
    required String label,
    required String value,
    required Widget icon,
  }) =>
      CardInfoRow(
        info: CardInfo(label: label, value: value, icon: icon),
      );

  /// Method Name: [_actions]
  ///
  /// Purpose: Builds view-only header action controls.
  ///
  /// Returns: The message and edit action column.
  Widget _actions(S localization) {
    Widget button(String label, String icon) => customButtonWithSvg(
          title: label,
          function: () {},
          textStyle: CardStyles.title(16).copyWith(color: AppColors.textButton),
          height: 40.h,
          width: 164.w,
          space: 8.w,
          radius: 8.r,
          color: AppColors.primary,
          image: icon,
          widthImage: 22.r,
          heightImage: 22.r,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(localization.message, AppAssets.message),
        SizedBox(height: 10.h),
        customButtonWithSvg(
          title: localization.edit,
          function: onEdit,
          textStyle: CardStyles.title(16).copyWith(color: AppColors.textButton),
          height: 40.h,
          width: 164.w,
          space: 8.w,
          radius: 8.r,
          color: AppColors.primary,
          image: AppAssets.edit,
          widthImage: 22.r,
          heightImage: 22.r,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        ),
      ],
    );
  }
}
