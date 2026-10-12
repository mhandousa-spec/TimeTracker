// ***************************** FILE INFO ***************************** //
// File Name: add_location_dialog.dart
// Purpose: Renders and submits the bilingual Add Location dialog.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/1-custom_dropdown.dart';
import '../../../../../../core/custom/2-custom_textfield.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/hr/input_formatter.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../core/helper/main_helper/countries.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../controller/department_locations_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Provides the responsive form used to create an HR Department location.
class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key});

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  Country? _selectedCountry;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController();
    _nameArController = TextEditingController();
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 650.w;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      backgroundColor: AppColors.field,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 880.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(localization),
                SizedBox(height: 28.h),
                _buildNameFields(localization, isWide),
                SizedBox(height: 20.h),
                _buildCountryField(localization, isWide),
                SizedBox(height: 28.h),
                _buildActions(localization, _isSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Method Name: [_buildHeader]
  ///
  /// Purpose: Builds the title and location icon from the reference dialog.
  ///
  /// Parameters:
  /// - [localization]: Localized dialog title.
  ///
  /// Returns: The dialog header.
  Widget _buildHeader(S localization) {
    return Row(
      children: [
        Container(
          width: 44.sp,
          height: 44.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CustomSvgImage(
            assetPath: AppAssets.locationIcon,
            width: 24.sp,
            height: 24.sp,
            color: AppColors.textButton,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          localization.addLocation,
          style: StyleText.fontSize20Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  /// Method Name: [_buildNameFields]
  ///
  /// Purpose: Builds the English and Arabic name inputs responsively.
  ///
  /// Parameters:
  /// - [localization]: Localized labels and placeholders.
  /// - [isWide]: Whether the dialog has room for two columns.
  ///
  /// Returns: The bilingual location-name fields.
  Widget _buildNameFields(S localization, bool isWide) {
    final englishField = _buildEnglishNameField(localization);
    final arabicField = _buildArabicNameField(localization);
    if (!isWide) {
      return Column(
        children: [
          englishField,
          SizedBox(height: 16.h),
          arabicField,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: englishField),
        SizedBox(width: 24.w),
        Expanded(child: arabicField),
      ],
    );
  }

  /// Method Name: [_buildEnglishNameField]
  ///
  /// Purpose: Builds the English location-name input.
  ///
  /// Parameters:
  /// - [localization]: Localized label and placeholder.
  ///
  /// Returns: The English name field.
  Widget _buildEnglishNameField(S localization) {
    return FormField<String>(
      initialValue: _nameEnController.text,
      validator: HrValidator.name(
        localization,
        script: HrNameScript.english,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Directionality(
        textDirection: TextDirection.ltr,
        child: CustomTextField(
          controller: _nameEnController,
          label: localization.locationNameEnglish,
          hint: localization.employeeEnglishNameHint,
          required: true,
          errorText: field.errorText,
          textDirection: TextDirection.ltr,
          fillColor: AppColors.background,
          onChanged: (value) {
            field.didChange(value);
            setState(() {});
          },
          inputFormatters: [
            HrInputFormatter.englishName,
            LengthLimitingTextInputFormatter(20),
          ],
        ),
      ),
    );
  }

  /// Method Name: [_buildArabicNameField]
  ///
  /// Purpose: Builds the Arabic location-name input.
  ///
  /// Parameters:
  /// - [localization]: Localized label and placeholder.
  ///
  /// Returns: The Arabic name field.
  Widget _buildArabicNameField(S localization) {
    return FormField<String>(
      initialValue: _nameArController.text,
      validator: HrValidator.name(
        localization,
        script: HrNameScript.arabic,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Directionality(
        textDirection: TextDirection.rtl,
        child: CustomTextField(
          controller: _nameArController,
          label: localization.locationNameArabic,
          hint: localization.employeeArabicNameHint,
          required: true,
          errorText: field.errorText,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          fillColor: AppColors.background,
          onChanged: (value) {
            field.didChange(value);
            setState(() {});
          },
          inputFormatters: [
            HrInputFormatter.arabicName,
            LengthLimitingTextInputFormatter(20),
          ],
        ),
      ),
    );
  }

  /// Method Name: [_buildCountryField]
  ///
  /// Purpose: Builds the country selector while retaining only its code.
  ///
  /// Parameters:
  /// - [localization]: Localized selector label and hint.
  /// - [isWide]: Whether the selector should use half-dialog width.
  ///
  /// Returns: The country dropdown.
  Widget _buildCountryField(S localization, bool isWide) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return FormField<Country>(
      initialValue: _selectedCountry,
      validator: (country) => HrValidator.requiredSelection(
        country?.code,
        localization,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final dropdown = CustomDropdown<Country>(
          value: field.value,
          label: localization.country,
          hint: localization.selectCountry,
          required: false,
          errorText: field.errorText,
          fillColor: AppColors.background,
          items: countries
              .map(
                (country) => DropdownItem<Country>(
                  value: country,
                  label:
                      '${country.flag} ${country.localizedName(languageCode)}',
                ),
              )
              .toList(),
          onChanged: (country) {
            field.didChange(country);
            setState(() => _selectedCountry = country);
          },
        );
        return isWide ? SizedBox(width: 400.w, child: dropdown) : dropdown;
      },
    );
  }

  /// Method Name: [_buildActions]
  ///
  /// Purpose: Builds the discard and create actions from the reference.
  ///
  /// Parameters:
  /// - [localization]: Localized action labels.
  /// - [isSaving]: Disables create while the write is in progress.
  ///
  /// Returns: The dialog action row.
  Widget _buildActions(S localization, bool isSaving) {
    final canCreate = !isSaving &&
        _nameEnController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _selectedCountry != null;
    return Row(
      children: [
        customButton(
          exactWidth: 138.sp,
          title: localization.discard,
          function: isSaving ? () {} : () => Navigator.of(context).pop(),
          color: AppColors.secondaryButton,
          textStyle: StyleText.fontSize15Weight400.copyWith(
            color: AppColors.textButton,
          ),
        ),
        const Spacer(),
        customButton(
          exactWidth: 138.sp,
          title: localization.create,
          function: canCreate ? _submit : () {},
          color: canCreate ? AppColors.primary : AppColors.disabledGrey,
          textStyle: StyleText.fontSize15Weight400.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ],
    );
  }

  /// Method Name: [_submit]
  ///
  /// Purpose: Validates the form and sends the typed values to the Cubit.
  ///
  /// Returns: Completes after the Cubit receives a valid submission.
  Future<void> _submit() async {
    final localization = S.of(context);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await _showCreateConfirmation(localization);
  }

  /// Method Name: [_showCreateConfirmation]
  ///
  /// Purpose: Runs the confirmation, persistence, and success dialog flow.
  ///
  /// Parameters:
  /// - [localization]: Localized confirmation and feedback text.
  ///
  /// Returns: Completes after the entire dialog flow is dismissed.
  Future<void> _showCreateConfirmation(S localization) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: localization.confirm,
      confirmSubtitle: localization.confirmCreateLocation,
      confirmYesText: localization.yes,
      confirmNoText: localization.no,
      onConfirm: () => _persistLocation(localization),
      successLottie: AppAssets.successful,
      successTitle: localization.successful,
      successSubtitle: localization.locationCreatedSuccess,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }

  /// Method Name: [_persistLocation]
  ///
  /// Purpose: Shows the shared loading state and persists the location.
  ///
  /// Parameters:
  /// - [localization]: Localized failure feedback text.
  ///
  /// Returns: True when the location is saved successfully.
  Future<bool> _persistLocation(S localization) async {
    setState(() => _isSaving = true);
    unawaited(showLoadingIndicator());
    bool created;
    try {
      created = await context.read<DepartmentLocationsCubit>().createLocation(
            nameEn: _nameEnController.text.trim(),
            nameAr: _nameArController.text.trim(),
            countryCode: _selectedCountry!.code,
          );
    } catch (_) {
      created = false;
    } finally {
      hideLoadingIndicator();
      if (mounted) setState(() => _isSaving = false);
    }
    if (!mounted) return false;
    if (!created) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
        title: localization.error,
        subtitle: localization.errorOccurred,
      );
      return false;
    }
    return true;
  }
}
