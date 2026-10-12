// ***************************** FILE INFO ***************************** //
// File Name: add_employee_intl_phone_field.dart
// Purpose: Provides the AddEmployeeIntlPhoneField widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/59-custom_intl_phone_field.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../core/helper/main_helper/countries.dart';
import '../../../../../../core/helper/main_helper/phone_number.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_read_only_scope.dart';

/// A validated HR adapter for the shared international phone field.
class AddEmployeeIntlPhoneField extends StatelessWidget {
  const AddEmployeeIntlPhoneField({
    super.key,
    required this.numberController,
    required this.countryCodeController,
    required this.label,
    this.isRequired = true,
  });

  final TextEditingController numberController;
  final TextEditingController countryCodeController;
  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final isEnabled = AddEmployeeReadOnlyScope.isEnabled(context);
    final initialCountry = _countryForCode(countryCodeController.text);
    final initialValue = PhoneNumber(
      countryISOCode: initialCountry.code,
      countryCode: countryCodeController.text.isEmpty
          ? '+${initialCountry.fullCountryCode}'
          : countryCodeController.text,
      number: numberController.text,
    );

    final field = isEnabled
        ? FormField<PhoneNumber>(
            initialValue: initialValue,
            validator: (value) => HrValidator.number(
              S.of(context),
              required: isRequired,
            )(value?.number),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (state) => Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  context.read<AddEmployeeCubit>().refreshProgress();
                }
              },
              child: _buildPhoneField(
                context,
                initialCountry: initialCountry,
                errorText: state.errorText,
                onChanged: (phone) {
                  state.didChange(phone);
                  _savePhone(context, phone);
                },
                onCountryChanged: (country) {
                  final phone = PhoneNumber(
                    countryISOCode: country.code,
                    countryCode: '+${country.fullCountryCode}',
                    number: numberController.text,
                  );
                  state.didChange(phone);
                  _savePhone(context, phone);
                },
              ),
            ),
          )
        : _buildPhoneField(
            context,
            initialCountry: initialCountry,
            errorText: null,
            onChanged: null,
            onCountryChanged: null,
          );

    return field;
  }

  /// Method Name: [_buildPhoneField]
  ///
  /// Purpose: Builds the shared international phone input with HR styling.
  ///
  /// Parameters:
  /// - [context]: Build context used for localized validation and cubit access.
  /// - [initialCountry]: Country restored from the stored dial code.
  /// - [errorText]: Validation message rendered by the feature-level form field.
  /// - [onChanged]: Callback for national-number changes.
  /// - [onCountryChanged]: Callback for country-selection changes.
  ///
  /// Returns: A configured international phone field.
  Widget _buildPhoneField(
    BuildContext context, {
    required Country initialCountry,
    required String? errorText,
    required ValueChanged<PhoneNumber>? onChanged,
    required ValueChanged<Country>? onCountryChanged,
  }) {
    return IntlPhoneField(
      controller: numberController,
      initialCountryCode: initialCountry.code,
      enabled: AddEmployeeReadOnlyScope.isEnabled(context),
      readOnly: !AddEmployeeReadOnlyScope.isEnabled(context),
      disableLengthCheck: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
      onCountryChanged: onCountryChanged,
    );
  }

  /// Method Name: [_savePhone]
  ///
  /// Purpose: Delegates separate number and dial-code persistence to the flow cubit.
  ///
  /// Parameters:
  /// - [context]: Build context containing the flow cubit.
  /// - [phone]: Newly selected phone value.
  ///
  /// Returns: No value; the cubit updates both controllers and progress.
  void _savePhone(BuildContext context, PhoneNumber phone) {
    context.read<AddEmployeeCubit>().updatePhoneNumber(
          numberController: numberController,
          countryCodeController: countryCodeController,
          phoneNumber: phone,
        );
  }

  /// Method Name: [_countryForCode]
  ///
  /// Purpose: Restores the picker country from the persisted dial code.
  ///
  /// Parameters:
  /// - [value]: Stored dial code, with or without a leading plus sign.
  ///
  /// Returns: The matching country, or Egypt when no code is stored.
  Country _countryForCode(String value) {
    final digits = value.replaceAll('+', '').trim();
    if (digits.isEmpty) {
      return countries.firstWhere((country) => country.code == 'EG');
    }
    return countries.firstWhere(
      (country) =>
          country.fullCountryCode == digits || country.dialCode == digits,
      orElse: () => countries.firstWhere((country) => country.code == 'EG'),
    );
  }
}
