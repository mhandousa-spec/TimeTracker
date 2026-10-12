/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_state.dart
/// Purpose: Immutable state for CompanyCubit. Replaces the mutable fields and
///          14 TextEditingControllers that used to live on the GetX
///          CompanyController — every form value is state now, edited via cubit
///          setters and rendered through BlocBuilder.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N03/N09: renamed EmployeeBrandingModel ->
///          EmployeeBrandingEntity, and added [restartRequested] so the cubit
///          can ask the UI to remount instead of calling
///          `RestartWidget.restartApp(Get.context!)` after a `Future.delayed`.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';

/// Sentinel so `copyWith` can distinguish "leave unchanged" from "set to null".
/// Needed because the branding fields are legitimately reset to null (see
/// company_branding_screen's reset flow).
const Object _unset = Object();

enum CompanyStatus { initial, loading, success, failure }

class CompanyState {
  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  final CompanyStatus status;

  /// One-shot feedback for BlocListener. Cleared with [CompanyState.consumed].
  final String? successMessage;
  final String? errorMessage;

  /// One-shot: a font change needs the app subtree remounted. The cubit sets
  /// it; the page performs the restart with its own context and then calls
  /// [consumed] (CR-SKEL-SE3-N08, N09).
  final bool restartRequested;

  // ─── Loaded data ───────────────────────────────────────────────────────────
  final CompanyModel? company;
  final EmployeeBrandingEntity? employeeBranding;

  // ─── Unsaved branding selections ───────────────────────────────────────────
  final int brandingSelectedIndex;
  final String? selectedEnglishFont;
  final String? selectedArabicFont;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? imageUrl;

  // ─── Company information form ──────────────────────────────────────────────
  final String companyName;
  final String taxNumber;
  final String birthDate;
  final String country;
  final String city;
  final String stateOrProvince;
  final String email;
  final String phone;
  final String streetAddress;
  final String code;

  // ─── Contact information form ──────────────────────────────────────────────
  final String contactFirstName;
  final String contactLastName;
  final String contactEmail;
  final String contactPhone;

  const CompanyState({
    required this.status,
    this.successMessage,
    this.errorMessage,
    this.restartRequested = false,
    this.company,
    this.employeeBranding,
    required this.brandingSelectedIndex,
    this.selectedEnglishFont,
    this.selectedArabicFont,
    this.primaryColor,
    this.secondaryColor,
    this.imageUrl,
    required this.companyName,
    required this.taxNumber,
    required this.birthDate,
    required this.country,
    required this.city,
    required this.stateOrProvince,
    required this.email,
    required this.phone,
    required this.streetAddress,
    required this.code,
    required this.contactFirstName,
    required this.contactLastName,
    required this.contactEmail,
    required this.contactPhone,
  });

  factory CompanyState.initial() => const CompanyState(
        status: CompanyStatus.initial,
        brandingSelectedIndex: 0,
        companyName: '',
        taxNumber: '',
        birthDate: '',
        country: '',
        city: '',
        stateOrProvince: '',
        email: '',
        phone: '',
        streetAddress: '',
        code: '',
        contactFirstName: '',
        contactLastName: '',
        contactEmail: '',
        contactPhone: '',
      );

  /// True when the loaded company is active — the condition guarding every
  /// branding read in the settings widgets.
  bool get isCompanyActive => company?.status == 'active';

  /// True when the Branding tab holds an unsaved selection (24/8/2026).
  ///
  /// These five are exactly what `CompanyCubit.updateCompanyModel()` writes,
  /// and it writes each one only when it is non-null — they start null and are
  /// set the moment the user picks a logo, colour or font, and go back to null
  /// on `clearBrandingSelections()`.
  ///
  /// So "all five null" means Apply would append NOTHING to the company
  /// document, yet still run the confirm dialog and report "saved
  /// successfully". Gating the button on this is a correctness fix as much as
  /// a visual one.
  bool get hasBrandingChanges =>
      imageUrl != null ||
      primaryColor != null ||
      secondaryColor != null ||
      selectedEnglishFont != null ||
      selectedArabicFont != null;

  CompanyState copyWith({
    CompanyStatus? status,
    Object? successMessage = _unset,
    Object? errorMessage = _unset,
    bool? restartRequested,
    Object? company = _unset,
    Object? employeeBranding = _unset,
    int? brandingSelectedIndex,
    Object? selectedEnglishFont = _unset,
    Object? selectedArabicFont = _unset,
    Object? primaryColor = _unset,
    Object? secondaryColor = _unset,
    Object? imageUrl = _unset,
    String? companyName,
    String? taxNumber,
    String? birthDate,
    String? country,
    String? city,
    String? stateOrProvince,
    String? email,
    String? phone,
    String? streetAddress,
    String? code,
    String? contactFirstName,
    String? contactLastName,
    String? contactEmail,
    String? contactPhone,
  }) {
    return CompanyState(
      status: status ?? this.status,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      restartRequested: restartRequested ?? this.restartRequested,
      company: identical(company, _unset) ? this.company : company as CompanyModel?,
      employeeBranding: identical(employeeBranding, _unset)
          ? this.employeeBranding
          : employeeBranding as EmployeeBrandingEntity?,
      brandingSelectedIndex: brandingSelectedIndex ?? this.brandingSelectedIndex,
      selectedEnglishFont: identical(selectedEnglishFont, _unset)
          ? this.selectedEnglishFont
          : selectedEnglishFont as String?,
      selectedArabicFont: identical(selectedArabicFont, _unset)
          ? this.selectedArabicFont
          : selectedArabicFont as String?,
      primaryColor:
          identical(primaryColor, _unset) ? this.primaryColor : primaryColor as Color?,
      secondaryColor: identical(secondaryColor, _unset)
          ? this.secondaryColor
          : secondaryColor as Color?,
      imageUrl: identical(imageUrl, _unset) ? this.imageUrl : imageUrl as String?,
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      birthDate: birthDate ?? this.birthDate,
      country: country ?? this.country,
      city: city ?? this.city,
      stateOrProvince: stateOrProvince ?? this.stateOrProvince,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      code: code ?? this.code,
      contactFirstName: contactFirstName ?? this.contactFirstName,
      contactLastName: contactLastName ?? this.contactLastName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  /// Drops one-shot feedback after a BlocListener has shown it.
  CompanyState consumed() => copyWith(
        successMessage: null,
        errorMessage: null,
        restartRequested: false,
      );
}
