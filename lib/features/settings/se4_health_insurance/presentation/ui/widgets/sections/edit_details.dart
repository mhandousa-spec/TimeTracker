/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_details.dart
/// Purpose: The editable emergency-contact fields used by the request form.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).

///******************** FILE INFO ********************///
/// Purpose: Editable version of emergency contact information section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for emergency contact information with controllers passed from parent
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/controller/health_insurance_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/custom/60-custom_country_picker.dart';
import 'package:knowticed_plus/core/custom/99-custom_country_flag.dart';

class EditableEmergencyContactInformationSection extends StatelessWidget {
  final bool isFirstContact; // true for 1st contact, false for 2nd contact

  // Controllers passed from parent
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController relationshipController;
  final TextEditingController emailController;
  final TextEditingController mobilePhoneController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;

  /// Set to true after the user taps Preview so empty fields show
  /// the "required" error state.
  final bool submitted;

  /// ADDED 9/10/2026 — shown under the header of an OPTIONAL contact (the
  /// 2nd emergency contact): "optional; if you add it, fill every field".
  final String? optionalHint;

  const EditableEmergencyContactInformationSection({
    super.key,
    this.isFirstContact = true,
    this.submitted = false,
    this.optionalHint,
    required this.firstNameController,
    required this.lastNameController,
    required this.relationshipController,
    required this.emailController,
    required this.mobilePhoneController,
    required this.languageController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Column(
      children: [

        isMobile ? SizedBox(height: 0.sp) : SizedBox(),

        SettingsHeader(
          // 0: the card around this section (edit_page_request_health.dart)
          // already applies 15.sp on each side. SettingsHeader's own phone
          // default is another 15.sp, and the two stacked — so the header sat
          // 30.sp in while the fields under it sat at 15.sp.
          // FIXED 8/9/2026. Tablet is unaffected: the default there is already
          // 0. Same pattern as health_insurance_section.dart.
          horizontalPadding: 0,
          imagePath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
          text: headerText,
        ),
        // 9/10/2026 — the optional-contact note (2nd emergency contact).
        if (optionalHint != null && optionalHint!.isNotEmpty) ...[
          SizedBox(height: 6.sp),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              optionalHint!,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
          ),
        ],
        SizedBox(height: 15.sp),

        // First Row/Column: First Name, Last Name, Relationship
        isMobile
            ? Column(
          children: [


            CustomTextField(
              label: S.of(context).firstName,
              hint: S.of(context).enterYourFirstName,
              fillColor: AppColors.background,
              controller: firstNameController,
              enabled: true,
              submitted: submitted,
              required: true,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 10),
            CustomTextField(
              label: S.of(context).lastName,
              fillColor: AppColors.background,
              hint: S.of(context).enterYourLastName,
              controller: lastNameController,
              enabled: true,
              submitted: submitted,
              required: true,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 10),
            CustomTextField(
              label: S.of(context).relationship,
              fillColor: AppColors.background,
              hint: S.of(context).enterContactRelation,
              controller: relationshipController,
              enabled: true,
              submitted: submitted,
              required: true,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).firstName,
                hint: S.of(context).enterYourFirstName,
                controller: firstNameController,
                fillColor: AppColors.background,
                enabled: true,
              submitted: submitted,
              required: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).lastName,
                hint: S.of(context).enterYourLastName,
                controller: lastNameController,
                fillColor: AppColors.background,
                enabled: true,
              submitted: submitted,
              required: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).relationship,
                hint: S.of(context).enterContactRelation,
                controller: relationshipController,
                enabled: true,
              submitted: submitted,
              required: true,
                fillColor: AppColors.background,
              ),
            ),
          ],
        ),
        isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),

        // Second Row/Column: Email, Mobile Phone, Language
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: S.of(context).email,
              hint: S.of(context).enterYourEmail,
              controller: emailController,
              enabled: true,
              submitted: submitted,
              required: true,
              fillColor: AppColors.background,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
            // Bug report (Settings mobile p.4): the number had no separate
            // country-code box — see EmergencyPhoneField.
            EmergencyPhoneField(
              label: S.of(context).phoneNumber,
              hint: S.of(context).enterYourMobilePhone,
              controller: mobilePhoneController,
              submitted: submitted,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).language,
              hint: S.of(context).enterLanguage,
              controller: languageController,
              enabled: true,
              submitted: submitted,
              required: true,
              fillColor: AppColors.background,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).email,
                hint: S.of(context).enterYourEmail,
                controller: emailController,
                fillColor: AppColors.background,
                enabled: true,
              submitted: submitted,
              required: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: EmergencyPhoneField(
                label: S.of(context).phoneNumber,
                hint: S.of(context).enterPhoneNumber,
                controller: mobilePhoneController,
                submitted: submitted,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).language,
                hint: S.of(context).enterLanguage,
                fillColor: AppColors.background,
                controller: languageController,
                enabled: true,
              submitted: submitted,
              required: true,
              ),
            ),
          ],
        ),
        isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),

        // Third Row/Column: Country, Province, City
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: S.of(context).country,
              hint: S.of(context).enterYourCountry,
              controller: countryController,
              enabled: true,
              submitted: submitted,
              required: true,
              fillColor: AppColors.background,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).province,
              hint: S.of(context).enterYourStateOrProvince,
              controller: provinceController,
              enabled: true,
              submitted: submitted,
              required: true,
              fillColor: AppColors.background,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).city,
              hint: S.of(context).enterYourCity,
              controller: cityController,
              enabled: true,
              submitted: submitted,
              required: true,
              fillColor: AppColors.background,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).country,
                hint: S.of(context).enterYourCountry,
                controller: countryController,
                enabled: true,
              submitted: submitted,
              required: true,
                fillColor: AppColors.background,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).province,
                hint: S.of(context).enterYourStateOrProvince,
                controller: provinceController,
                enabled: true,
              submitted: submitted,
              required: true,
                fillColor: AppColors.background,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).city,
                hint: S.of(context).enterYourCity,
                controller: cityController,
                enabled: true,
              submitted: submitted,
              required: true,
                fillColor: AppColors.background,
              ),
            ),
          ],
        ),
        isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),

        // Fourth Row: Street (full width on both mobile and desktop)
        CustomTextField(
          label: S.of(context).street,
          hint: S.of(context).enterYourStreetAddress,
          controller: streetController,
          fillColor: AppColors.background,
          enabled: true,
              submitted: submitted,
              required: true,
        ),
      ],
    );
  }
}

/// Emergency-contact phone with its own country-code box.
///
/// ADDED 29/9/2026 (Settings mobile bug p.4 — "add the field of the code").
/// The contact's phone is stored as ONE string ("+20 10 2456 7316"), so this
/// widget splits it into a dial code (picked from the app's country picker)
/// and the number, and writes "+<code> <number>" back into [controller]. The
/// edit page keeps comparing [controller] with the stored value exactly as
/// before, so change tracking and the request payload are unchanged.
class EmergencyPhoneField extends StatefulWidget {
  const EmergencyPhoneField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.submitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool submitted;

  @override
  State<EmergencyPhoneField> createState() => _EmergencyPhoneFieldState();
}

class _EmergencyPhoneFieldState extends State<EmergencyPhoneField> {
  static const String _defaultDialCode = '20';

  late String _dialCode;
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final String raw = widget.controller.text.trim();
    String dial = _defaultDialCode;
    String number = raw;
    if (raw.startsWith('+')) {
      final String digits = raw.substring(1);
      // Longest dial code that the stored value starts with ("+20…", "+965…").
      String? best;
      for (final Country c in countries) {
        if (c.dialCode.isNotEmpty &&
            digits.startsWith(c.dialCode) &&
            (best == null || c.dialCode.length > best.length)) {
          best = c.dialCode;
        }
      }
      if (best != null) {
        dial = best;
        number = digits.substring(best.length).trim();
      }
    }
    _dialCode = dial;
    _numberController = TextEditingController(text: number);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String get _isoCode {
    for (final Country c in countries) {
      if (c.dialCode == _dialCode) return c.code;
    }
    return '';
  }

  void _sync() {
    final String number = _numberController.text.trim();
    widget.controller.text = number.isEmpty ? '' : '+$_dialCode $number';
  }

  Future<void> _pickCountry() async {
    final Country? picked = await showCountryPickerDialog(context);
    if (picked == null || !mounted) return;
    setState(() => _dialCode = picked.dialCode);
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.text, fontSize: 14.sp),
        ),
        SizedBox(height: 6.sp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            // Country code — opens the picker, shows flag + dial code.
            GestureDetector(
              onTap: _pickCountry,
              child: Container(
                height: 38.sp,
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppCountryFlag(isoCode: _isoCode, width: 20, height: 15),
                    SizedBox(width: 6.sp),
                    Text(
                      '+$_dialCode',
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(width: 4.sp),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16.sp, color: AppColors.secondaryText),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: CustomTextField(
                height: 38,
                hint: widget.hint,
                controller: _numberController,
                fillColor: AppColors.background,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                enabled: true,
                submitted: widget.submitted,
                required: true,
                onChanged: (_) => _sync(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
