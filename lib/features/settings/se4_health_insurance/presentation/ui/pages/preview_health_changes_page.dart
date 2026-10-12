/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: preview_health_changes_page.dart
/// Purpose: Reviews health-insurance edits before they are submitted as a request.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N11/N15/N17: the Firestore batch write and its try/catch moved
///          into RequestsCubit/RequestsRepository; raw colours route through
///          AppColors.
///
/// REMAINING (CR-SKEL-SE4-N12): still ~1,200 LOC. Decomposing it into
/// widgets/sections/ is separate work.

///*************************** FILE INFO ****************************///
/// Purpose: Preview page for comparing old and new health insurance information
/// Author: Claude AI Assistant
/// Created At: 31/10/2025
/// Modified: Mobile responsive layout - vertical stacking on mobile, show only changed fields
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/grc/grc_module/grc_owner/presentation/ui/create_policy.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/widgets/request_error_dialog.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';

// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s3_services_requests/my_request_details/widget/dailog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class PreviewHealthInsuranceChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;

  // Health Insurance Controllers
  final TextEditingController insuranceNameController;
  final TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  final TextEditingController firstContact_FirstNameController;
  final TextEditingController firstContact_LastNameController;
  final TextEditingController firstContact_RelationshipController;
  final TextEditingController firstContact_EmailController;
  final TextEditingController firstContact_PhoneController;
  final TextEditingController firstContact_LanguageController;
  final TextEditingController firstContact_CountryController;
  final TextEditingController firstContact_ProvinceController;
  final TextEditingController firstContact_CityController;
  final TextEditingController firstContact_StreetController;

  // 2nd Emergency Contact Controllers
  final TextEditingController secondContact_FirstNameController;
  final TextEditingController secondContact_LastNameController;
  final TextEditingController secondContact_RelationshipController;
  final TextEditingController secondContact_EmailController;
  final TextEditingController secondContact_PhoneController;
  final TextEditingController secondContact_LanguageController;
  final TextEditingController secondContact_CountryController;
  final TextEditingController secondContact_ProvinceController;
  final TextEditingController secondContact_CityController;
  final TextEditingController secondContact_StreetController;

  const PreviewHealthInsuranceChangesPage({
    super.key,
    required this.changes,
    required this.insuranceNameController,
    required this.insurancePolicyNumberController,
    required this.firstContact_FirstNameController,
    required this.firstContact_LastNameController,
    required this.firstContact_RelationshipController,
    required this.firstContact_EmailController,
    required this.firstContact_PhoneController,
    required this.firstContact_LanguageController,
    required this.firstContact_CountryController,
    required this.firstContact_ProvinceController,
    required this.firstContact_CityController,
    required this.firstContact_StreetController,
    required this.secondContact_FirstNameController,
    required this.secondContact_LastNameController,
    required this.secondContact_RelationshipController,
    required this.secondContact_EmailController,
    required this.secondContact_PhoneController,
    required this.secondContact_LanguageController,
    required this.secondContact_CountryController,
    required this.secondContact_ProvinceController,
    required this.secondContact_CityController,
    required this.secondContact_StreetController,
  });

  @override
  State<PreviewHealthInsuranceChangesPage> createState() => _PreviewHealthInsuranceChangesPageState();
}

class _PreviewHealthInsuranceChangesPageState extends State<PreviewHealthInsuranceChangesPage> {
  late TextEditingController requestNoteController;

  /// Owned by this page: the request flow is entered from here and torn down
  /// with it, so there is nothing to provide higher up the tree.
  final RequestsCubit _requestsCubit = RequestsCubit();
  bool isSubmitting = false;

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

  /// Submit, greyed out and untappable until the note is filled — and while a
  /// submit is already in flight, which is what `isSubmitting` guarded before.
  Widget _buildSubmitButton(BuildContext context, {required double width}) {
    final enabled = _hasRequestNote && !isSubmitting;

    // FIXED 8/9/2026 — the disabled label was unreadable. Two causes, both
    // here: `AppColors.textButton` is `AppTheme.contrastColor()`, so in light
    // mode it resolves to (near) black — dark text on the grey disabled fill —
    // and the `Opacity(0.5)` wrapper then washed out whatever was left.
    // The grey fill already reads as disabled on its own, so the opacity layer
    // is gone and the disabled label is pinned to white.
    return IgnorePointer(
      ignoring: !enabled,
      child: customButton(
        title: isSubmitting ? S.of(context).submitting : S.of(context).submit,
        function: () => _submitChanges(context),
        height: 38.h,
        width: width,
        color: enabled ? AppColors.primary : AppColors.darkGrey,
        textStyle: StyleText.fontSize16Weight500.copyWith(
          color: enabled ? AppColors.textButton : AppColors.white,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).previewHealthInsuranceChanges,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Conditional based on device
              if (isMobile)
                // CHANGED 8/9/2026 — the trailing `SizedBox(height: 10.sp)`
                // that used to close this Column is gone.
                //
                // The shared `SizedBox(height: 10.sp)` below already separates
                // this heading from the card under it, so the local one made
                // the gap 20.sp here while "New Details" — which has only its
                // own 10.sp — sat at half that. The two headings now clear
                // their cards by the same amount.
                Text(
                  S.of(context).current_details,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).current_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.sp),
                    Expanded(
                      child: Text(
                        S.of(context).new_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 10.sp),

              // Main Content - Conditional layout
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: true,
                    ),

                    SizedBox(height: 20.sp),

                    // New Details Header
                    Text(
                      S.of(context).new_details,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),

                    SizedBox(height: 10.sp),

                    // New Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: false,
                    ),
                  ],
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
            // CHANGED 8/9/2026 — both buttons are 150.w x 38.h with a Spacer
            // between them, which is exactly what the Discard / Preview pair
            // at the bottom of edit_page_request_health.dart uses. This page
            // is the step straight after that one, so the row must not change
            // shape underneath the user.
            //
            // `150.w`, not `150.sp`, for the same reason — matching the edit
            // page means matching the unit it measures in.
            //
            // Mobile used to wrap each button in `Expanded` with a 10.sp gap,
            // so the pair stretched the full width and read as two banners.
            isMobile ?   Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customButton(
                    title: S.of(context).discardChange,
                    function: isSubmitting ? () {} : () {
                      Navigator.pop(context);
                    },
                    height: 38.h,
                    width: 150.w,
                    color: AppColors.darkGrey,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Spacer(),
                  _buildSubmitButton(context, width: 150.w),
                ],
              ) : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                customButton(
                  title: S.of(context).discardChange,
                  function: isSubmitting ? () {} : () {
                    Navigator.pop(context);
                  },
                  height: 38.h,
                  width: 150.w,
                  color: AppColors.darkGrey,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Spacer(),
                _buildSubmitButton(context, width: 150.w),
              ],
            ),

              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(
      BuildContext context,
      bool lightMode, {
        required bool isCurrentColumn,
      }) {
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Helper function to check if field should be shown
    bool shouldShowField(String fieldKey) {
      if (!isMobile) return true; // Show all fields on tablet/desktop
      return widget.changes.containsKey(fieldKey); // Show only changed fields on mobile
    }

    // Local wrapper so every call below can keep passing "did this field
    // change?" without also having to know which column it is in. The green
    // highlight marks the NEW value — on the Current Details side it just
    // outlined the old value the user is replacing.
    /// The value of one field, for whichever column is being built.
    ///
    /// FIXED 24/8/2026 — the whole Current Details column showed "-".
    ///
    /// It used to read `insuranceController.healthInsuranceEntity` and
    /// `.emergencyContactEntity`. Nothing in the app ever populates those two,
    /// so they were always null; `?? ''` turned every current value into an
    /// empty string and `_fieldDisplay` prints '-' for empty. Meanwhile the
    /// real previous values were sitting right here the whole time: the edit
    /// page builds `changes[key]['oldValue']` from `currentEmployeeHistory`.
    ///
    /// A field the user did NOT touch has no entry in `changes` — and its
    /// controller still holds the value the edit page loaded it with, so the
    /// controller is the correct fallback for BOTH columns.
    String _valueFor(String fieldKey, TextEditingController controller) {
      if (!isCurrentColumn) return controller.text;

      final change = widget.changes[fieldKey];
      if (change is Map && change['oldValue'] != null) {
        return change['oldValue'].toString();
      }
      return controller.text;
    }

    Widget _buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String value,
      bool hasChanged,
    ) {
      return _fieldDisplay(
        label: label,
        value: value,
        showHighlight: hasChanged && !isCurrentColumn,
      );
    }

    // Helper to check if any insurance fields should be shown
    bool hasInsuranceFields = shouldShowField('insuranceName') ||
        shouldShowField('insurancePolicyNumber');

    // Helper to check if any first contact fields should be shown
    bool hasFirstContactFields = shouldShowField('firstContact_firstName') ||
        shouldShowField('firstContact_lastName') ||
        shouldShowField('firstContact_relationship') ||
        shouldShowField('firstContact_email') ||
        shouldShowField('firstContact_phone') ||
        shouldShowField('firstContact_language') ||
        shouldShowField('firstContact_country') ||
        shouldShowField('firstContact_province') ||
        shouldShowField('firstContact_city') ||
        shouldShowField('firstContact_street');

    // Helper to check if any second contact fields should be shown
    bool hasSecondContactFields = shouldShowField('secondContact_firstName') ||
        shouldShowField('secondContact_lastName') ||
        shouldShowField('secondContact_relationship') ||
        shouldShowField('secondContact_email') ||
        shouldShowField('secondContact_phone') ||
        shouldShowField('secondContact_language') ||
        shouldShowField('secondContact_country') ||
        shouldShowField('secondContact_province') ||
        shouldShowField('secondContact_city') ||
        shouldShowField('secondContact_street');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health Insurance Section
        if (hasInsuranceFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Insurance Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath: 'assets/icons_assets/main_icons_assets/insurance_document_shield.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).healthInsurance,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                // Insurance Name
                if (shouldShowField('insuranceName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insuranceName,
                    _valueFor('insuranceName', widget.insuranceNameController),
                    widget.changes.containsKey('insuranceName'),
                  ),
                  if (shouldShowField('insurancePolicyNumber'))
                    SizedBox(height: 12.sp),
                ],

                // Insurance Policy Number
                if (shouldShowField('insurancePolicyNumber'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insurancePolicyNumber,
                    _valueFor('insurancePolicyNumber', widget.insurancePolicyNumberController),
                    widget.changes.containsKey('insurancePolicyNumber'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 1st Emergency Contact Section
        if (hasFirstContactFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 1st Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).emergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('firstContact_firstName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).firstName,
                    _valueFor('firstContact_firstName', widget.firstContact_FirstNameController),
                    widget.changes.containsKey('firstContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_lastName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).lastName,
                    _valueFor('firstContact_lastName', widget.firstContact_LastNameController),
                    widget.changes.containsKey('firstContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_relationship')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).relationship,
                    _valueFor('firstContact_relationship', widget.firstContact_RelationshipController),
                    widget.changes.containsKey('firstContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_email')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).email,
                    _valueFor('firstContact_email', widget.firstContact_EmailController),
                    widget.changes.containsKey('firstContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_phone')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    _valueFor('firstContact_phone', widget.firstContact_PhoneController),
                    widget.changes.containsKey('firstContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_language')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).language,
                    _valueFor('firstContact_language', widget.firstContact_LanguageController),
                    widget.changes.containsKey('firstContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    _valueFor('firstContact_country', widget.firstContact_CountryController),
                    widget.changes.containsKey('firstContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).province,
                    _valueFor('firstContact_province', widget.firstContact_ProvinceController),
                    widget.changes.containsKey('firstContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    _valueFor('firstContact_city', widget.firstContact_CityController),
                    widget.changes.containsKey('firstContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    _valueFor('firstContact_street', widget.firstContact_StreetController),
                    widget.changes.containsKey('firstContact_street'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 2nd Emergency Contact Section
        if (hasSecondContactFields || !isMobile)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 2nd Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvgImage(
                      assetPath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).secondEmergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('secondContact_firstName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).firstName,
                    _valueFor('secondContact_firstName', widget.secondContact_FirstNameController),
                    widget.changes.containsKey('secondContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_lastName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).lastName,
                    _valueFor('secondContact_lastName', widget.secondContact_LastNameController),
                    widget.changes.containsKey('secondContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_relationship')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).relationship,
                    _valueFor('secondContact_relationship', widget.secondContact_RelationshipController),
                    widget.changes.containsKey('secondContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_email')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).email,
                    _valueFor('secondContact_email', widget.secondContact_EmailController),
                    widget.changes.containsKey('secondContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_phone')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    _valueFor('secondContact_phone', widget.secondContact_PhoneController),
                    widget.changes.containsKey('secondContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_language')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).language,
                    _valueFor('secondContact_language', widget.secondContact_LanguageController),
                    widget.changes.containsKey('secondContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                    _valueFor('secondContact_country', widget.secondContact_CountryController),
                    widget.changes.containsKey('secondContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).province,
                    _valueFor('secondContact_province', widget.secondContact_ProvinceController),
                    widget.changes.containsKey('secondContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                    _valueFor('secondContact_city', widget.secondContact_CityController),
                    widget.changes.containsKey('secondContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    _valueFor('secondContact_street', widget.secondContact_StreetController),
                    widget.changes.containsKey('secondContact_street'),
                  ),

              ],
            ),
          ),
        // Request Note (only in New Details column).
        //
        // MOVED 29/9/2026 (Settings mobile bug p.10): it sat inside the 2nd
        // Emergency Contact card, which mobile hides unless that contact
        // changed — so an insurance-only request had no note field and Submit
        // (which needs the note) stayed grey for good.
        if (!isCurrentColumn) ...[
          SizedBox(height: 20.sp),
          CustomTextField(
            label: S.of(context).request_note,
            hint: S.of(context).textHere,
            controller: requestNoteController,
            required: true,
            maxLines: 3,
            // ADDED 8/9/2026 — the 0/500 counter was missing because
            // CustomTextField only renders one when a limit is asked
            // for: `maxLength`, or `showCharCount` (which implies 500).
            // This field passed neither, so there was nothing to show
            // and nothing capping the note either.
            maxLength: 500,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
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
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          // minHeight, not a fixed height: a BoxDecoration border is drawn
          // *inside* the box, so a fixed 36.h left only 36.h - 20.h padding - 4
          // border for the text and clipped it — but only on the changed
          // (green-bordered) fields, which is why those looked cut off.
          constraints: BoxConstraints(minHeight: 36.h),
          width: double.infinity,
          // ALIGNMENT 24/8/2026: was `AlignmentDirectional.centerStart`, which
          // resolves to the RIGHT edge under an Arabic (RTL) Directionality —
          // so every value jumped to the right side of its box in Arabic. The
          // values are to sit on the left in BOTH languages, so this is the
          // absolute `Alignment.centerLeft`, not the directional one. The
          // LABEL above is left directional on purpose: it still follows the
          // language.
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
            // Always draw a 2px border — transparent when not highlighted — so
            // both columns keep identical inner geometry and the two sides of
            // the comparison stay row-for-row aligned.
            border: Border.all(
              color: showHighlight ? AppColors.green : AppColors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Absolute left, for the same reason as the alignment above. The
            // text DIRECTION is deliberately left alone — forcing LTR would
            // mis-order punctuation inside an Arabic value.
            textAlign: TextAlign.left,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  /// Map field names from changes to model field names
  String _mapFieldNameToModelField(String changeFieldName) {
    final fieldMapping = {
      'insuranceName': 'insuranceName',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'firstContact_firstName': 'firstContactFirstName',
      'firstContact_lastName': 'firstContactLastName',
      'firstContact_relationship': 'firstContactRelationship',
      'firstContact_email': 'firstContactEmail',
      'firstContact_phone': 'firstContactPhone',
      'firstContact_language': 'firstContactLanguage',
      'firstContact_country': 'firstContactCountry',
      'firstContact_province': 'firstContactProvince',
      'firstContact_city': 'firstContactCity',
      'firstContact_street': 'firstContactStreet',
      'secondContact_firstName': 'secondContactFirstName',
      'secondContact_lastName': 'secondContactLastName',
      'secondContact_relationship': 'secondContactRelationship',
      'secondContact_email': 'secondContactEmail',
      'secondContact_phone': 'secondContactPhone',
      'secondContact_language': 'secondContactLanguage',
      'secondContact_country': 'secondContactCountry',
      'secondContact_province': 'secondContactProvince',
      'secondContact_city': 'secondContactCity',
      'secondContact_street': 'secondContactStreet',
    };

    return fieldMapping[changeFieldName] ?? changeFieldName;
  }

  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Raise a change request for everything edited in this session.
  ///
  /// The Firestore write, the employee-existence check and the error handling
  /// moved into `RequestsCubit` / `RequestsRepository` — this method only
  /// gathers values, dispatches, and drives the dialogs (CR-SKEL-SE6-N01/N02,
  /// CR-SKEL-SE4-N11).
  ///
  /// UPDATED 24/8/2026: this screen edits two settings sections at once — the
  /// insurance fields and the two emergency contacts — and used to file both as
  /// one `Health Insurance` request. `se5_emergency_contact` is its own
  /// section, so the edits are now split by field name and filed as up to two
  /// requests. An employee who touched only a next-of-kin phone number no
  /// longer receives a notification about their health insurance, and a
  /// reviewer sees the two kinds of change as separate items.
  Future<void> _submitChanges(BuildContext context) async {
    showConfirmationDialog(
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        final NavigatorState navigator = Navigator.of(context);

        // Read before the first await — `context` must not be touched
        // afterwards. Carries the language the reviewers' notification is
        // sent in.
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

        final List<FieldChange> emergencyChanges = changes
            .where((FieldChange c) => _isEmergencyContactField(c.fieldName))
            .toList();
        final List<FieldChange> insuranceChanges = changes
            .where((FieldChange c) => !_isEmergencyContactField(c.fieldName))
            .toList();

        final String employeeId = employee?.id ?? '';
        final String employeeName =
            '${employee?.firstName?.lastOrNull ?? ''} ${employee?.lastName?.lastOrNull ?? ''}'
                .trim();
        final String employeeEmail = employee?.email?.lastOrNull ?? '';
        final String requestNote = requestNoteController.text.trim();

        // Both sections are submitted when both were edited. A section with no
        // edits raises nothing — filing an empty request would put a card in
        // the reviewer's queue with no changes to decide on, and
        // `RequestsRepository.submitRequest` rejects it anyway.
        bool ok = true;

        if (insuranceChanges.isNotEmpty) {
          ok = await _requestsCubit.submit(
            section: SettingsRequestKind.healthInsurance.sectionName,
            employeeId: employeeId,
            employeeName: employeeName,
            employeeEmail: employeeEmail,
            requestNote: requestNote,
            changes: insuranceChanges,
            isArabic: isArabic,
          );
        }

        if (ok && emergencyChanges.isNotEmpty) {
          ok = await _requestsCubit.submit(
            section: SettingsRequestKind.emergencyContact.sectionName,
            employeeId: employeeId,
            employeeName: employeeName,
            employeeEmail: employeeEmail,
            requestNote: requestNote,
            changes: emergencyChanges,
            isArabic: isArabic,
          );
        }

        // Nothing was edited at all — treat it as a failed submission so the
        // success dialog does not claim a request was raised.
        if (insuranceChanges.isEmpty && emergencyChanges.isEmpty) ok = false;

        hideLoadingIndicator();

        if (!mounted) return;

        if (!ok) {
          _requestsCubit.clearMessages();
          await RequestErrorDialog.show(context);
          return;
        }

        _requestsCubit.clearMessages();

        // Uses the shared dialog from core/custom/dialogs rather than the
        // page-local copy that se6's preview_changes_page still carries; the
        // local one was lost in the CR-SKEL-SE4-N11 refactor.
        await showSuccessDialog(
          context: context,
          lottieAsset: 'assets/lottie_assets/main_lottie_assets/approved.json',
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

  /// Function Name: [_isEmergencyContactField]
  ///
  /// Purpose: Whether an edited field belongs to the Emergency Contact section
  ///          rather than to Health Insurance.
  ///
  /// The edit screen emits `firstContact_*` / `secondContact_*` for the two
  /// contacts — the exact spellings `RequestFieldMapping` lists — and plain
  /// `insurance_*` names for the policy itself. Matching the prefix is what
  /// splits the two sections; `RequestFieldMapping._snakeToCamel` folds the
  /// same names, so an approval still writes them either way.
  ///
  /// Parameters:
  /// - [fieldName]: The request field name as the edit screen wrote it.
  ///
  /// Returns: [bool] true for an emergency-contact field.
  static bool _isEmergencyContactField(String fieldName) {
    final String key = fieldName.toLowerCase();
    return key.startsWith('firstcontact') || key.startsWith('secondcontact');
  }

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isMobile = ContextExtension(context).isPhone;
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
                        textStyle: StyleText.fontSize15Weight500.copyWith(
                          color: AppColors.white,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
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
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
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
}