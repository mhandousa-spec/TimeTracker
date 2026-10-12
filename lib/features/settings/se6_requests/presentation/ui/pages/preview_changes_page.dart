/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: preview_changes_page.dart
/// Purpose: Reviews personal-information edits before they are submitted.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N06: the Firestore submit and its try/catch moved into
///          RequestsCubit/RequestsRepository; the country lookups now use the
///          shared PhoneCountryLookup; raw colours route through AppColors.
///
/// REMAINING (N05): still ~1,100 LOC.

///*************************** FILE INFO ****************************///
/// Purpose: Preview page for comparing old and new personal information
/// Author: Claude AI Assistant
/// Created At: 27/10/2025
/// Modified: Mobile responsive layout - vertical stacking on mobile
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import './request_page.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class PreviewChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;
  final File? selectedImage;
  // NAMES 24/8/2026: six controllers, not three. The form now edits the
  // English and the Arabic spelling of each name at the same time instead of
  // editing whichever one matched the current UI language, so the preview has
  // to be handed both and show both.
  final TextEditingController firstNameController;
  final TextEditingController firstNameArController;
  final TextEditingController middleNameController;
  final TextEditingController middleNameArController;
  final TextEditingController lastNameController;
  final TextEditingController lastNameArController;
  // REMOVED 24/8/2026: email is no longer part of the edit form, so there is
  // no email controller to hand over and nothing to preview.
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController dateOfBirthController;
  final String? selectedGender;
  final String? selectedMaritalStatus;
  final String? selectedCountryCode;

  const PreviewChangesPage({
    super.key,
    required this.changes,
    this.selectedImage,
    required this.firstNameController,
    required this.firstNameArController,
    required this.middleNameController,
    required this.middleNameArController,
    required this.lastNameController,
    required this.lastNameArController,
    required this.phoneController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
    required this.dateOfBirthController,
    this.selectedGender,
    this.selectedMaritalStatus,
    this.selectedCountryCode,
  });

  @override
  State<PreviewChangesPage> createState() => _PreviewChangesPageState();
}

class _PreviewChangesPageState extends State<PreviewChangesPage> {
  late TextEditingController requestNoteController;

  /// Owned by this page: the request flow is entered from here and torn down
  /// with it, so there is nothing to provide higher up the tree.
  final RequestsCubit _requestsCubit = RequestsCubit();

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
  }

  /// The request note is MANDATORY (24/8/2026).
  ///
  /// An approver reading the request needs to know why the change is being
  /// asked for, and the note was the only place that says so — it was optional,
  /// so most requests arrived with nothing. Submit is now inert until it holds
  /// something other than whitespace.
  bool get _hasRequestNote => requestNoteController.text.trim().isNotEmpty;

  /// Submit, greyed out and untappable until the note is filled.
  ///
  /// Opacity + IgnorePointer, matching the Preview button on the health edit
  /// page, so a disabled action looks and behaves the same across settings.
  Widget _buildSubmitButton(BuildContext context, {required double width}) {
    final enabled = _hasRequestNote;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: customButton(
          title: S.of(context).submit,
          function: () => _submitChanges(context),
          height: 38.h,
          // FIXED 8/9/2026 — was a hardcoded `135.sp`, which ignored the
          // `width` this method is handed. Both call sites were passing a
          // width and neither of them had any effect.
          width: width,
          color: enabled ? AppColors.primary : AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  // ── Phone ────────────────────────────────────────────────────────────────
  // SPLIT 23/8/2026. These used to be one `_getCurrentPhoneDisplay()` /
  // `_getNewPhoneDisplay()` pair returning "🇪🇬 +20 1012345678" as a single
  // string for a single box. The country code is now its own narrow box beside
  // the number — the same shape the edit screen collects it in — so each half
  // is read separately and each can carry its own change highlight.

  /// The flag + dial code the employee's profile currently holds.
  String _getCurrentPhoneCode() {
    final mobilePhoneList = employee?.mobilePhone;
    final mobilePhone =
        mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    final String countryCode = mobilePhone?.countryCode?.lastOrNull ??
        PersonalProfile.defaultCountryCode;

    return _formatDialCode(countryCode);
  }

  /// The number the employee's profile currently holds, without its code.
  String _getCurrentPhoneNumber() {
    final mobilePhoneList = employee?.mobilePhone;
    final mobilePhone =
        mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    return mobilePhone?.phones?.lastOrNull ?? '';
  }

  /// The flag + dial code this request would write.
  String _getNewPhoneCode() => _formatDialCode(
        widget.selectedCountryCode ?? PersonalProfile.defaultCountryCode,
      );

  /// The number this request would write.
  String _getNewPhoneNumber() => widget.phoneController.text;

  /// "🇪🇬 +20" for a country code, or an empty string when the code resolves
  /// to nothing — so the box falls back to the '-' placeholder rather than
  /// showing a lone flag.
  String _formatDialCode(String countryCode) {
    final String flag = PhoneCountryLookup.flagOf(countryCode);
    final String dialCode = PhoneCountryLookup.dialCodeOf(countryCode);
    if (dialCode.isEmpty) return '';
    return '$flag $dialCode'.trim();
  }

  // Country flag / dial code lookups moved to
  // se1_profile/data/utils/phone_country_lookup.dart: each held a try/catch,
  // which is forbidden in presentation/ui/ (§20/§21, CR-SKEL-SE6-N02). One copy
  // is shared rather than a third being written here.

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingMyPersonalData,
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — tablet/desktop only.
                //
                // CHANGED 8/9/2026. On mobile the old value and the new one now
                // sit in the same field, one under the other, so a single
                // "Current Details" heading above the list (and the "New
                // Details" one that used to sit halfway down it) no longer
                // describes what follows. Both are gone on mobile; the two
                // column headings still make sense on wider screens, where the
                // sides really are two columns.
                if (!isMobile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).current_details,
                          style: StyleText.fontSize16Weight600.copyWith(
                              color: AppColors.text
                          ),
                        ),
                      ),
                      SizedBox(width: 20.sp),
                      Expanded(
                        child: Text(
                          S.of(context).new_details,
                          style: StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.text
                          ),
                        ),
                      ),
                    ],
                  ),
          
                // CHANGED 8/9/2026 — 15.sp on mobile, matching the horizontal
                // inset the page frame applies, so the first card sits as far
                // from the top as it does from the sides.
                //
                // 10.sp was the gap UNDER the "Current Details" heading, back
                // when mobile had one. With the headings gone (see above) this
                // became the whole space above the first card, and it was
                // visibly tighter at the top than at the edges.
                SizedBox(height: isMobile ? 15.sp : 10.sp),

                // Main Content - Conditional layout
                //
                // Mobile builds the list ONCE. Comparing two values meant
                // scrolling a whole block down to the matching field in the
                // second block and holding the first in your head; paired, the
                // new value sits directly under the old one.
                if (isMobile)
                  _buildDetailsColumn(
                    context,
                    lightMode,
                    isCurrentColumn: true,
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Details Column
                      Expanded(
                        child: _buildDetailsColumn(
                          context,
                          lightMode,
                          isCurrentColumn: true,
                        ),
                      ),
          
                      SizedBox(width: 16.sp),
          
                      // New Details Column
                      Expanded(
                        child: _buildDetailsColumn(
                          context,
                          lightMode,
                          isCurrentColumn: false,
                        ),
                      ),
                    ],
                  ),
          
                SizedBox(height: 30.sp),
          
                // Bottom Action Buttons
                //
                // CHANGED 8/9/2026 — both buttons are a fixed 150.sp with a
                // Spacer between them, matching the Discard / Preview pair at
                // the bottom of edit_page_request.dart. This page is the step
                // straight after that one, so the row the user just tapped
                // through should not change shape underneath them.
                //
                // Mobile previously wrapped each button in `Expanded` with a
                // 10.sp gap, so the pair stretched to the full width of the
                // page and read as two banners rather than two buttons.
               isMobile ?   Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    customButton(
                      title: S.of(context).discardChange,
                      function: () {
                        Navigator.pop(context);
                      },
                      height: 38.h,
                      width: 150.sp,
                      color: AppColors.darkGrey,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color:  AppColors.white,
                      ),
                    ),
                    Spacer(),
                    _buildSubmitButton(context, width: 150.sp),
                  ],
                ) : Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   customButton(
                     title: S.of(context).discardChange,
                     function: () {
                       Navigator.pop(context);
                     },
                     height: 38.h,
                     width: 150.sp,
                     color: AppColors.darkGrey,
                     textStyle: StyleText.fontSize16Weight500.copyWith(
                       color: AppColors.white,
                     ),
                   ),
                   Spacer(),
                   _buildSubmitButton(context, width: 150.sp),
                 ],
               ),
          
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(
      BuildContext context,
      bool lightMode, {
        required bool isCurrentColumn,
      })
  {
    final isArabic = Localizations
        .localeOf(context)
        .languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Helper function to check if field should be shown
    bool shouldShowField(String fieldKey) {
      if (!isMobile) return true; // Show all fields on tablet/desktop
      return widget.changes.containsKey(fieldKey); // Show only changed fields on mobile
    }

    // PAIRED MODE — mobile only, added 8/9/2026.
    //
    // On mobile this method is called ONCE and every field renders both of its
    // values: the current one, then the new one directly under it. On wider
    // screens it is still called twice, once per column, and each call renders
    // only the side it was asked for.
    //
    // That is why the builders below now receive BOTH values instead of
    // `isCurrentColumn ? old : new` — the paired layout needs the pair, and the
    // two-column layout picks its half here rather than at fifteen call sites.
    final bool pairValues = isMobile;

    // Local wrapper so every call below can keep passing "did this field
    // change?" without also having to know which column it is in. The green
    // highlight marks the NEW value — on the Current Details side it just
    // outlined the old value the user is replacing, and in paired mode it
    // marks the lower of the two boxes for the same reason.
    Widget _buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String currentValue,
      String newValue,
      bool hasChanged,
    ) {
      if (pairValues) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _fieldLabel(label),
            SizedBox(height: 10.h),
            _valueBox(value: currentValue, showHighlight: false),
            // Tighter than the 12.sp between fields, so the two halves of one
            // comparison group together rather than reading as two fields.
            SizedBox(height: 6.h),
            _valueBox(value: newValue, showHighlight: hasChanged),
          ],
        );
      }

      return _fieldDisplay(
        label: label,
        value: isCurrentColumn ? currentValue : newValue,
        showHighlight: hasChanged && !isCurrentColumn,
      );
    }

    // Helper to check if any personal info fields should be shown
    bool hasPersonalInfoFields = shouldShowField('photo') ||
        shouldShowField('first_name') ||
        shouldShowField('middle_name') ||
        shouldShowField('last_name') ||
        shouldShowField('gender') ||
        shouldShowField('date_of_birth') ||
        shouldShowField('marital_status');

    // Check if any contact fields changed
    bool hasContactChanges =
        shouldShowField('phone') || shouldShowField('country_code');

    // Check if any location fields changed
    bool hasLocationChanges = shouldShowField('country') ||
        shouldShowField('province') ||
        shouldShowField('city') ||
        shouldShowField('street');

    return Column(
      children: [
        // Personal Information Container - only show if there are fields to display
        if (hasPersonalInfoFields) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo - only show if changed on mobile
                if (shouldShowField('photo'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CHANGED 24/8/2026: was a hand-rolled
                      // CircleAvatar + ClipRRect + Image.network stack with
                      // its own error builder. `CustomImagePicker` is the
                      // shared control the rest of the app uses, so the
                      // avatar here now matches everywhere else — in
                      // `readOnly`, since a preview must not let anyone
                      // change the photo.
                      //
                      // Paired mode stacks the two avatars for the same reason
                      // the value boxes stack: the old photo, then the one
                      // replacing it. `imageFile: null` falls back to
                      // `imageUrl`, which is what makes the first one the
                      // current photo.
                      Row(
                        children: [
                          CustomImagePicker(
                            radius: 29.r,
                            readOnly: true,
                            imageFile:
                                (pairValues || isCurrentColumn)
                                    ? null
                                    : widget.selectedImage,
                            imageUrl: (employee?.photo?.isNotEmpty ?? false)
                                ? employee!.photo!.last
                                : null,
                            onImagePicked: (_) {},
                          ),
                        ],
                      ),
                      if (pairValues) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            CustomImagePicker(
                              radius: 29.r,
                              readOnly: true,
                              imageFile: widget.selectedImage,
                              imageUrl: (employee?.photo?.isNotEmpty ?? false)
                                  ? employee!.photo!.last
                                  : null,
                              onImagePicked: (_) {},
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20.sp),
                    ],
                  ),

                // Personal Information — each name is TWO rows now, English
                // and Arabic, because the form edits both. Previously one row
                // showed whichever spelling matched the UI language, which made
                // an edit to the other one invisible in the preview.
                if (shouldShowField('first_name')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    _labelFirstNameEn,
                    FormatHelper.capitalize(employee?.firstName?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.firstNameController.text),
                    widget.changes.containsKey('first_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('first_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    // The Arabic label stays Arabic in both languages, same as
                    // on the edit form, so the two boxes are never ambiguous.
                    _labelFirstNameAr,
                    employee?.firstNameInArabic?.lastOrNull ?? '',
                    widget.firstNameArController.text,
                    widget.changes.containsKey('first_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('middle_name')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    _labelMiddleNameEn,
                    FormatHelper.capitalize(employee?.middleName?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.middleNameController.text),
                    widget.changes.containsKey('middle_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('middle_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    _labelMiddleNameAr,
                    employee?.middleNameInArabic?.lastOrNull ?? '',
                    widget.middleNameArController.text,
                    widget.changes.containsKey('middle_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('last_name')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    _labelLastNameEn,
                    FormatHelper.capitalize(employee?.lastName?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.lastNameController.text),
                    widget.changes.containsKey('last_name'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('last_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    _labelLastNameAr,
                    employee?.lastNameInArabic?.lastOrNull ?? '',
                    widget.lastNameArController.text,
                    widget.changes.containsKey('last_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('gender')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).gender,
                    // Both columns go through _getGenderValue now. The Current
                    // side used to print `employee.gender` straight from
                    // Firestore, which is the raw key — so it was English (and
                    // sometimes lower case) even in Arabic.
                    FormatHelper.capitalize(
                        _getGenderValue(employee?.gender?.lastOrNull)),
                    FormatHelper.capitalize(
                        _getGenderValue(widget.selectedGender)),
                    widget.changes.containsKey('gender'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('date_of_birth')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).birthday,
                    FormatHelper.capitalize(
                        _formatDate(employee?.birthDay?.lastOrNull)),
                    FormatHelper.capitalize(
                        widget.dateOfBirthController.text),
                    widget.changes.containsKey('date_of_birth'),
                  ),
                  if (shouldShowField('marital_status'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('marital_status'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).maritalStatus,
                    FormatHelper.capitalize(_getMaritalStatusValue(
                        employee?.maritalStatus?.lastOrNull)),
                    FormatHelper.capitalize(_getMaritalStatusValue(
                        widget.selectedMaritalStatus)),
                    widget.changes.containsKey('marital_status'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // Contact Section - only show if any contact field changed
        if (hasContactChanges || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Contact Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath: 'assets/icons_assets/settings_assets/phone_call_contact.svg',
                      width: 16.w,
                      height: 16.h,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).contact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),

                // Country code and number are two boxes, not one string. Each
                // half carries its own highlight, so changing the country
                // without touching the digits outlines only the code box.
                if (shouldShowField('phone') || shouldShowField('country_code'))
                  if (pairValues)
                    // Two code+number rows under one label, matching how the
                    // plain fields pair. Each row keeps its own two boxes, so
                    // changing the country without touching the digits still
                    // outlines only the code half of the lower row.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _fieldLabel(S.of(context).phoneNumber),
                        SizedBox(height: 10.h),
                        _phoneValueRow(
                          code: _getCurrentPhoneCode(),
                          number: _getCurrentPhoneNumber(),
                          highlightCode: false,
                          highlightNumber: false,
                        ),
                        SizedBox(height: 6.h),
                        _phoneValueRow(
                          code: _getNewPhoneCode(),
                          number: _getNewPhoneNumber(),
                          highlightCode:
                              widget.changes.containsKey('country_code'),
                          highlightNumber: widget.changes.containsKey('phone'),
                        ),
                      ],
                    )
                  else
                    _phoneFieldDisplay(
                      label: S.of(context).phoneNumber,
                      code: isCurrentColumn
                          ? _getCurrentPhoneCode()
                          : _getNewPhoneCode(),
                      number: isCurrentColumn
                          ? _getCurrentPhoneNumber()
                          : _getNewPhoneNumber(),
                      // Only the New Details column outlines a change — same
                      // rule as _buildFieldDisplay above.
                      highlightCode:
                          widget.changes.containsKey('country_code') &&
                              !isCurrentColumn,
                      highlightNumber: widget.changes.containsKey('phone') &&
                          !isCurrentColumn,
                    ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // Location Section - only show if any location field changed
        if (hasLocationChanges || !isMobile)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Location Section Header
                Row(
                  children: [
                    // CHANGED 8/9/2026 — 16.sp -> 22.sp. The pin reads smaller
                    // than the other section icons at the same nominal size
                    // (its artwork carries more empty margin), so it needed a
                    // larger box to sit level with the "Location" label beside
                    // it. `fit: BoxFit.contain`, not `fill`: the asset is not
                    // square, and `fill` stretched it to whatever box it was
                    // given rather than scaling it.
                    CustomSvgImage(
                      assetPath: 'assets/icons_assets/settings_assets/location_city_pin.svg',
                      width: 22.sp,
                      height: 22.sp,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).location,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),

                if (shouldShowField('country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    FormatHelper.capitalize(employee?.country?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.countryController.text),
                    widget.changes.containsKey('country'),
                  ),
                  if (shouldShowField('province') || shouldShowField('city') || shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).stateOrProvince,
                    FormatHelper.capitalize(employee?.province?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.provinceController.text),
                    widget.changes.containsKey('province'),
                  ),
                  if (shouldShowField('city') || shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    FormatHelper.capitalize(employee?.city?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.cityController.text),
                    widget.changes.containsKey('city'),
                  ),
                  if (shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).streetName,
                    FormatHelper.capitalize(employee?.street?.lastOrNull ?? ''),
                    FormatHelper.capitalize(widget.streetController.text),
                    widget.changes.containsKey('street'),
                  ),

              ],
            ),
          ),
        // Request Note — once per page.
        //
        // MOVED 29/9/2026 (Settings mobile bug p.3/p.5): it used to sit INSIDE
        // the Location card, which mobile only shows when a location field
        // changed. A contact-only or gender-only request therefore had no note
        // field — and Submit, which needs the note, could never be enabled.
        //
        // On tablet/desktop that means the New Details column only.
        // In paired mode there is a single column, built with
        // `isCurrentColumn: true`, so it has to be allowed through
        // here or the note (and with it the enabled Submit button)
        // would vanish on mobile.
        if (!isCurrentColumn || pairValues) ...[
          SizedBox(height: 20.sp),
          CustomTextField(
            label: S.of(context).request_note,
            hint: S.of(context).textHere,
            controller: requestNoteController,
            // Draws the required marker next to the label, so the rule
            // is visible before the user reaches a disabled button.
            required: true,
            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            maxLines: 3,
            onChanged: (_){
              setState(() {

              });
            },
          )
        ],
      ],
    );
  }

  /// One labelled read-only value.
  ///
  /// [showHighlight] — not "has this field changed" — because only the New
  /// Details column outlines a change. See the local wrapper in
  /// _buildDetailsColumn.
  Widget _fieldDisplay({
    required String label,
    required String value,
    required bool showHighlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: 10.h),
        _valueBox(value: value, showHighlight: showHighlight),
      ],
    );
  }

  /// The phone row: a narrow country-code box beside the number, under one
  /// label. Mirrors `_buildPhoneField` on the edit screen — same 100.sp code
  /// box, same 12.sp gutter, number takes whatever is left — so the preview
  /// reads at the proportions the employee typed it in at.
  ///
  /// The `Row` is direction-aware: under an Arabic UI the code lands on the
  /// right, which is the leading edge there.
  Widget _phoneFieldDisplay({
    required String label,
    required String code,
    required String number,
    required bool highlightCode,
    required bool highlightNumber,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        SizedBox(height: 10.h),
        _phoneValueRow(
          code: code,
          number: number,
          highlightCode: highlightCode,
          highlightNumber: highlightNumber,
        ),
      ],
    );
  }

  /// The code + number pair on its own, without a label.
  ///
  /// EXTRACTED 8/9/2026 so the mobile paired layout can stack two of these
  /// under a single "Phone Number" label — the same way the plain fields stack
  /// two value boxes.
  Widget _phoneValueRow({
    required String code,
    required String number,
    required bool highlightCode,
    required bool highlightNumber,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _dialCodeWidth,
          child: _valueBox(
            value: code,
            showHighlight: highlightCode,
            center: true,
          ),
        ),
        SizedBox(width: 12.sp),
        // Expanded, not a second fixed width: the number is the long half
        // and takes the rest of the column.
        Expanded(
          child: _valueBox(
            value: number,
            showHighlight: highlightNumber,
          ),
        ),
      ],
    );
  }

  /// Width of the country-code box. Kept in step with `_dialCodeWidth` on the
  /// edit screen.
  double get _dialCodeWidth => 100.sp;

  Widget _fieldLabel(String label) => Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      );

  /// One read-only value box. Extracted from [_fieldDisplay] so the phone row
  /// can draw two of them side by side without restating the geometry.
  Widget _valueBox({
    required String value,
    required bool showHighlight,
    bool center = false,
  }) {
    return Container(
      // minHeight, not a fixed height: a BoxDecoration border is drawn
      // *inside* the box, so a fixed 36.h left only 36.h - 20.h padding - 4
      // border for the text and clipped it — but only on the changed
      // (green-bordered) fields, which is why those looked cut off.
      constraints: BoxConstraints(minHeight: 36.h),
      width: double.infinity,
      alignment:
          center ? Alignment.center : AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        // Always draw a 2px border — transparent when not highlighted — so
        // both columns keep identical inner geometry and the two sides of
        // the comparison stay row-for-row aligned.
        border: Border.all(
          color: showHighlight ? AppColors.statusApproved : AppColors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
      ),
    );
  }



  /// FIXED 24/8/2026 — "Male" stayed English on the Arabic preview.
  ///
  /// This used to be `{'male': 'Male', 'female': 'Female'}` — a hardcoded
  /// English map with no `S.of(context)` anywhere near it, so the Arabic UI got
  /// the English word. The edit page stores the KEY ('male'), never the label,
  /// so translating here is all that was missing.
  ///
  /// It is also lower-cased before matching, because the Current column feeds
  /// this the raw Firestore value, which is not guaranteed to be lower case.
  // NAME LABELS 24/8/2026 — deliberately NOT run through S.of(context).
  //
  // These label the SCRIPT of the value, not the UI. Localizing them would
  // print "الاسم الأول" on both rows in the Arabic UI (and "First Name" on both
  // in English), so the two boxes would be indistinguishable. Keeping each
  // label in its own language says exactly what belongs in the box, whichever
  // language the app is running in — which is what was asked for.
  static const String _labelFirstNameEn = 'First Name';
  static const String _labelMiddleNameEn = 'Middle Name';
  static const String _labelLastNameEn = 'Last Name';
  static const String _labelFirstNameAr = 'الاسم الأول';
  static const String _labelMiddleNameAr = 'الاسم الأوسط';
  static const String _labelLastNameAr = 'اسم العائلة';

  String _getGenderValue(String? key) {
    switch (key?.trim().toLowerCase()) {
      case 'male':
        return S.of(context).male;
      case 'female':
        return S.of(context).female;
      default:
        return key ?? '';
    }
  }

  /// FIXED 24/8/2026 — same story as [_getGenderValue]: a hardcoded English
  /// map is why "Married" stayed English in Arabic.
  String _getMaritalStatusValue(String? key) {
    switch (key?.trim().toLowerCase()) {
      case 'single':
        return S.of(context).single;
      case 'married':
        return S.of(context).married;
      case 'divorced':
        return S.of(context).divorced;
      case 'widowed':
        return S.of(context).widowed;
      default:
        return key ?? '';
    }
  }

  /// Renders a stored date for display, echoing the raw value back when it is
  /// not parseable. `tryParse` removes the try/catch this used to need.
  /// FIXED 24/8/2026 — the two columns disagreed: Current showed "12/11/1977"
  /// and New showed "١٩٧٧/١١/١٢" for the same date.
  ///
  /// The New side is the edit page's controller, filled by
  /// `_formatDateForDisplay` there, which switches format AND converts the
  /// digits in Arabic. This method did neither. It is now the same rule, so the
  /// two sides are comparable.
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    final DateTime? date = DateTime.tryParse(dateString);
    if (date == null) return dateString;

    // CHANGED 8/9/2026 — `dd MMM yyyy` ("23 Aug 2023") in both locales, to
    // match `_formatDateForDisplay` on the edit page. The two must stay
    // identical or the Current / New columns go back to disagreeing about how
    // the same date looks, which is the bug this method was written to fix.
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String formatted =
        DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);

    return isArabic ? ArabicDigits(formatted).toArabicNumbers() : formatted;
  }


  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Raise a change request for everything edited in this session.
  ///
  /// The Firestore write, the employee-existence check and the error handling
  /// moved into `RequestsCubit` / `RequestsRepository` — this method only
  /// gathers values, dispatches, and drives the dialogs (CR-SKEL-SE6-N01/N02,
  /// CR-SKEL-SE4-N11).
  Future<void> _submitChanges(BuildContext context) async {
    showConfirmationDialog(
      // 21/9/2026 — report p.22: this animation rendered as a small dot in the
      // confirm dialog. Same icon as the Health Insurance confirm (p.14).
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        final NavigatorState navigator = Navigator.of(context);

        // Read before the first await — `context` must not be touched
        // afterwards. Carries the language the reviewers' notification is
        // sent in (ADDED 24/8/2026).
        final bool isArabic =
            Localizations.localeOf(context).languageCode == 'ar';

        // ADDED 21/9/2026 — Settings bug report p.1/p.7: the confirm dialog
        // closed and nothing showed until the success dialog, so the page
        // looked frozen while the request was written. Same overlay the rest
        // of the app uses; always taken down before any dialog that follows.
        showLoadingIndicator();

        // `widget.changes` is a Map<String, dynamic>, so `entries` yields
        // MapEntry<String, dynamic> — annotating the parameter as
        // MapEntry<String, Map<String, dynamic>> made the closure unassignable
        // and collapsed the result to List<dynamic>. Narrow the *value*
        // instead, which is where the real shape lives.
        final List<FieldChange> changes = widget.changes.entries
            .map<FieldChange>((MapEntry<String, dynamic> entry) {
          final Map<String, dynamic> value =
              (entry.value as Map).cast<String, dynamic>();
          return FieldChange(
            fieldName: entry.key,
            oldValue: value['oldValue']?.toString() ?? '',
            newValue: value['newValue']?.toString() ?? '',
          );
        }).toList();

        final bool ok = await _requestsCubit.submit(
          section: ChangeRequest.defaultSection,
          employeeId: employee?.id ?? '',
          employeeName:
              '${employee?.firstName?.lastOrNull ?? ''} ${employee?.lastName?.lastOrNull ?? ''}'
                  .trim(),
          employeeEmail: employee?.email?.lastOrNull ?? '',
          requestNote: requestNoteController.text.trim(),
          changes: changes,
          isArabic: isArabic,
        );

        hideLoadingIndicator();

        if (!mounted) return;

        if (!ok) {
          _requestsCubit.clearMessages();
          await RequestErrorDialog.show(context);
          return;
        }

        _requestsCubit.clearMessages();

        await showSuccessDialog(
          lottiePath: 'assets/lottie_assets/main_lottie_assets/approved.json',
          title: S.of(context).request_submitted,
          subtitle: S.of(context).successfully_submitted_request,
        );

        // Close the success dialog, then the preview and edit pages. Was three
        // `Get.back()` calls interleaved with `Navigator.pop`, which popped
        // whatever route happened to be on top.
        await Future<void>.delayed(const Duration(seconds: 2));
        for (int i = 0; i < 3; i++) {
          if (navigator.canPop()) navigator.pop();
        }
      },
    );
  }

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isPhone = ContextExtension(context).isPhone;
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.white,
                        ),
                        width: isPhone ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        // 21/9/2026 — report p.14/p.22: same grey + white as Discard Changes.
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isPhone ?120.sp : 135.sp,                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showSuccessDialog({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}