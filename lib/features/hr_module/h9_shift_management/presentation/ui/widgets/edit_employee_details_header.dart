// ***************************** FILE INFO ***************************** //
// File Name: edit_employee_details_header.dart
// Purpose: Displays the employee profile header used in shift editing.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../h2_employees/utils/employee_details_phone_formatter.dart';

/// Builds the responsive employee details header used by the shift dialog.
class EditEmployeeDetailsHeader extends StatelessWidget {
  const EditEmployeeDetailsHeader({
    required this.employee,
    required this.departmentName,
    super.key,
  });

  final HrEmployeeEntity employee;
  final String departmentName;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final localizedName = isEnglish
        ? employee.getFirstAndLastName()
        : employee.getFirstAndLastNameArabic();
    final name = localizedName.trim().isEmpty
        ? employee.getFirstAndLastName()
        : localizedName;
    final localizedTitle = isEnglish ? employee.title : employee.titleInArabic;
    final title = localizedTitle?.trim().isNotEmpty == true
        ? localizedTitle
        : employee.title;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: CardStyles.radius(),
      ),
      child: _details(
        localization: localization,
        name: name,
        title: title,
      ),
    );
  }

  /// Method Name: [_details]
  ///
  /// Purpose: Builds the employee avatar and responsive metadata area.
  ///
  /// Parameters:
  /// - [localization]: Provides localized metadata labels.
  /// - [name]: Employee display name.
  /// - [title]: Employee display title.
  ///
  /// Returns: The employee identity and metadata widget.
  Widget _details({
    required S localization,
    required String name,
    required String? title,
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
                  final phone = EmployeeDetailsPhoneFormatter.format(
                    countryCode: employee.mobilePhone?.countryCode,
                    number: employee.mobilePhone?.number,
                  );
                  final firstColumn = [
                    _infoRow(
                      label: '${localization.title}:',
                      value: _valueOrFallback(title, localization),
                      icon: CardSvg.icon(
                        CardSvg.jobTitle,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    _infoRow(
                      label: '${localization.department}:',
                      value: _valueOrFallback(
                        FormatHelper.capitalize(departmentName),
                        localization,
                      ),
                      icon: CardSvg.icon(
                        CardSvg.department,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ];
                  final secondColumn = [
                    _infoRow(
                      label: '${localization.email}:',
                      value: _valueOrFallback(employee.email, localization),
                      icon: CardSvg.icon(
                        CardSvg.email,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    _infoRow(
                      label: '${localization.phoneNumber}:',
                      value: _valueOrFallback(phone, localization),
                      icon: CardSvg.icon(
                        CardSvg.phone,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ];

                  if (constraints.maxWidth < 560.w) {
                    return _metadataColumn([
                      ...firstColumn,
                      ...secondColumn,
                    ]);
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _metadataColumn(firstColumn)),
                      Expanded(child: _metadataColumn(secondColumn)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Method Name: [_metadataColumn]
  ///
  /// Purpose: Arranges employee metadata rows vertically.
  ///
  /// Parameters:
  /// - [fields]: Metadata rows to display.
  ///
  /// Returns: A vertically spaced metadata column.
  Widget _metadataColumn(List<Widget> fields) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            if (index > 0) SizedBox(height: 10.h),
            fields[index],
          ],
        ],
      );

  /// Method Name: [_infoRow]
  ///
  /// Purpose: Creates one shared-style employee metadata row.
  ///
  /// Parameters:
  /// - [label]: Localized metadata label.
  /// - [value]: Employee metadata value.
  /// - [icon]: Metadata icon.
  ///
  /// Returns: A styled information row.
  Widget _infoRow({
    required String label,
    required String value,
    required Widget icon,
  }) {
    return CardInfoRow(
      info: CardInfo(label: label, value: value, icon: icon),
    );
  }

  /// Method Name: [_buildAvatar]
  ///
  /// Purpose: Displays the employee image or the standard fallback avatar.
  ///
  /// Returns: A circular employee avatar widget.
  Widget _buildAvatar() {
    final photo = employee.photo?.trim() ?? '';
    final diameter = 88.r;
    Widget fallback() => ClipOval(
          child: CardSvg.icon(CardSvg.male, size: 88),
        );

    final image = photo.isEmpty
        ? fallback()
        : photo.startsWith('assets/')
            ? Image.asset(photo, fit: BoxFit.cover)
            : Image.network(photo, fit: BoxFit.cover);

    return Container(
      width: diameter,
      height: diameter,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ColoredBox(color: AppColors.barrierColor, child: image),
    );
  }

  /// Method Name: [_valueOrFallback]
  ///
  /// Purpose: Prevents missing employee metadata from rendering as blank text.
  ///
  /// Parameters:
  /// - [value]: Candidate metadata value.
  /// - [localization]: Provides the localized fallback.
  ///
  /// Returns: The trimmed value or the localized unavailable label.
  String _valueOrFallback(String? value, S localization) {
    return value?.trim().isNotEmpty == true
        ? value!.trim()
        : localization.notAvailable;
  }
}
