/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_model.dart
/// Purpose: The company document — name, address, contact and branding.
/// Author: MohamedFouad
/// Created at: January/14/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N22/N24/N25: the 21 Firestore keys are
///          `static const` instead of literals repeated in fromMap and toMap;
///          the dead commented-out `fromMap` (superseded by the null-guarded
///          one below) is deleted; `role` and `firstName` no longer share a
///          line; the standard header added.
///
/// NOTE ON MUTABILITY (CR-SKEL-SE3-N23): the fields are still non-final. The
/// branding save paths append to the history lists in place
/// (`c.primaryColor!.primaryColor!.add(...)`) and set `status`, so making this
/// immutable means rebuilding all 14 sub-models per write. That is a change to
/// the write semantics, not a refactor, and is deliberately left out of this
/// round — [copyWith] is provided so new code does not have to mutate.

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/address_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/email_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/first_name_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/last_name_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/role_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/arabic_font_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/city_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_industry_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_logo_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_name_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_size_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/country_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/english_font_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/modules_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/primary_color_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/province_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/secondary_color_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/tax_number_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/zip_code.dart';

class CompanyModel {
  /// Firestore field keys. Were repeated as literals in fromMap and toMap.
  static const String fieldCompanyName = 'Company_Name';
  static const String fieldTaxNumber = 'Tax_Number';
  static const String fieldCompanyAddress = 'Company_Address';
  static const String fieldCity = 'City';
  static const String fieldZipCode = 'Zip_Code';
  static const String fieldProvince = 'Province';
  static const String fieldCountry = 'Country';
  static const String fieldCompanyIndustry = 'Company_Industry';
  static const String fieldCompanySize = 'Company_Size';
  static const String fieldModules = 'Modules';
  static const String fieldRole = 'Role';
  static const String fieldFirstName = 'First_Name';
  static const String fieldLastName = 'Last_Name';
  static const String fieldEmail = 'Email';
  static const String fieldPhone = 'Phone';
  static const String fieldCompanyLogo = 'Company_Logo';
  static const String fieldPrimaryColor = 'Primary_Color';
  static const String fieldSecondaryColor = 'Secondary_Color';
  static const String fieldEnglishFont = 'English_Font';
  static const String fieldArabicFont = 'Arabic_Font';
  static const String fieldStatus = 'Status';

  CompanyName? companyName;
  TaxNumber? taxNumber;
  Address? companyAddress;
  City? city;
  ZipCode? zipCode;
  Province? province;
  Country? country;
  CompanyIndustry? companyIndustry;
  CompanySize? companySize;
  CompanyModules? modules;
  Role? role;
  FirstName? firstName;
  LastName? lastName;
  Email? email;
  MobilePhone? phone;
  CompanyLogo? companyLogo;
  PrimaryColor? primaryColor;
  SecondaryColor? secondaryColor;
  EnglishFont? englishFont;
  ArabicFont? arabicFont;
  String? status;
  CompanyModel({
    this.companyName,
    this.taxNumber,
    this.companyAddress,
    this.city,
    this.zipCode,
    this.province,
    this.country,
    this.companyIndustry,
    this.companySize,
    this.modules,
    this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.companyLogo,
    this.primaryColor,
    this.secondaryColor,
    this.englishFont,
    this.arabicFont,
    this.status,
  });


  // ── Legacy field fallback (24/8/2026) ──────────────────────────────────────
  //
  // The company document carries TWO generations of every profile field:
  //
  //   Company_Name : null          <- what this model reads
  //   companyName  : {companyName: ['Bayanat'], timestamps: [...]}   <- the data
  //
  // Every PascalCase profile key on the live document is null while the
  // camelCase twin holds the real value, which is why the Company Information
  // page rendered empty while Branding worked — the branding keys
  // (Company_Logo, Primary_Color, ...) are the only PascalCase ones that were
  // ever populated.
  //
  // Rather than teach every sub-model a second schema, [_field] hands it the
  // shape it already expects: it prefers the PascalCase map and, when that is
  // null, rebuilds an equivalent map out of the camelCase one. Saves keep
  // writing PascalCase, so a document heals itself the first time it is saved.
  //
  // The inner key differs per field and is NOT always the PascalCase name —
  // `Company_Address` holds its values under `Address`, and the camelCase side
  // uses `emails` / `firstNames` / `lastNames` / `address`. Both are passed in
  // explicitly.
  static Map<String, dynamic>? _field(
    Map data, {
    required String modernKey,
    required String legacyKey,
    required String valueKey,
    required String legacyValueKey,
    Map<String, String> extraKeys = const <String, String>{},
  }) {
    final dynamic modern = data[modernKey];
    if (modern != null) return Map<String, dynamic>.from(modern as Map);

    final dynamic legacy = data[legacyKey];
    if (legacy is! Map) return null;

    final Map<String, dynamic> rebuilt = <String, dynamic>{
      valueKey: legacy[legacyValueKey],
      'Timestamp': legacy['timestamps'],
    };
    extraKeys.forEach((String target, String source) {
      rebuilt[target] = legacy[source];
    });
    return rebuilt;
  }

  factory CompanyModel.fromMap(Map data) {
    return CompanyModel(
      companyName: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCompanyName,
          legacyKey: 'companyName',
          valueKey: 'Company_Name',
          legacyValueKey: 'companyName',
        );
        return raw != null ? CompanyName.fromMap(raw) : null;
      }(),
      taxNumber: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldTaxNumber,
          legacyKey: 'taxNumber',
          valueKey: 'Tax_Number',
          legacyValueKey: 'taxNumber',
        );
        return raw != null ? TaxNumber.fromMap(raw) : null;
      }(),
      companyAddress: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCompanyAddress,
          legacyKey: 'companyAddress',
          valueKey: 'Address',
          legacyValueKey: 'address',
        );
        return raw != null ? Address.fromMap(raw) : null;
      }(),
      city: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCity,
          legacyKey: 'city',
          valueKey: 'City',
          legacyValueKey: 'city',
        );
        return raw != null ? City.fromMap(raw) : null;
      }(),
      zipCode: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldZipCode,
          legacyKey: 'zipCode',
          valueKey: 'Zip_Code',
          legacyValueKey: 'zipCode',
        );
        return raw != null ? ZipCode.fromMap(raw) : null;
      }(),
      province: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldProvince,
          legacyKey: 'province',
          valueKey: 'Province',
          legacyValueKey: 'province',
        );
        return raw != null ? Province.fromMap(raw) : null;
      }(),
      country: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCountry,
          legacyKey: 'country',
          valueKey: 'Country',
          legacyValueKey: 'country',
        );
        return raw != null ? Country.fromMap(raw) : null;
      }(),
      companyIndustry: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCompanyIndustry,
          legacyKey: 'companyIndustry',
          valueKey: 'Company_Industry',
          legacyValueKey: 'companyIndustry',
        );
        return raw != null ? CompanyIndustry.fromMap(raw) : null;
      }(),
      companySize: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCompanySize,
          legacyKey: 'companySize',
          valueKey: 'Company_Size',
          legacyValueKey: 'companySize',
        );
        return raw != null ? CompanySize.fromMap(raw) : null;
      }(),
      modules: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldModules,
          legacyKey: 'modules',
          valueKey: 'Modules',
          legacyValueKey: 'modules',
        );
        return raw != null ? CompanyModules.fromMap(raw) : null;
      }(),
      role: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldRole,
          legacyKey: 'role',
          valueKey: 'Role',
          legacyValueKey: 'role',
        );
        return raw != null ? Role.fromMap(raw) : null;
      }(),
      firstName: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldFirstName,
          legacyKey: 'firstName',
          valueKey: 'First_Name',
          legacyValueKey: 'firstNames',
        );
        return raw != null ? FirstName.fromMap(raw) : null;
      }(),
      lastName: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldLastName,
          legacyKey: 'lastName',
          valueKey: 'Last_Name',
          legacyValueKey: 'lastNames',
        );
        return raw != null ? LastName.fromMap(raw) : null;
      }(),
      email: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldEmail,
          legacyKey: 'email',
          valueKey: 'Email',
          legacyValueKey: 'emails',
        );
        return raw != null ? Email.fromMap(raw) : null;
      }(),
      phone: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldPhone,
          legacyKey: 'phone',
          valueKey: 'Phone',
          legacyValueKey: 'phones',
          extraKeys: const <String, String>{'Country_Code': 'countryCode', 'Country_App': 'countryApp'},
        );
        return raw != null ? MobilePhone.fromMap(raw) : null;
      }(),
      companyLogo: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldCompanyLogo,
          legacyKey: 'companyLogo',
          valueKey: 'Company_Logo',
          legacyValueKey: 'companyLogo',
        );
        return raw != null ? CompanyLogo.fromMap(raw) : CompanyLogo(companyLogo: [], timestamps: []);
      }(),
      primaryColor: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldPrimaryColor,
          legacyKey: 'primaryColor',
          valueKey: 'Primary_Color',
          legacyValueKey: 'primaryColor',
        );
        return raw != null ? PrimaryColor.fromMap(raw) : PrimaryColor(primaryColor: [], timestamps: []);
      }(),
      secondaryColor: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldSecondaryColor,
          legacyKey: 'secondaryColor',
          valueKey: 'Secondary_Color',
          legacyValueKey: 'secondaryColor',
        );
        return raw != null ? SecondaryColor.fromMap(raw) : SecondaryColor(secondaryColor: [], timestamps: []);
      }(),
      englishFont: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldEnglishFont,
          legacyKey: 'englishFont',
          valueKey: 'English_Font',
          legacyValueKey: 'englishFont',
        );
        return raw != null ? EnglishFont.fromMap(raw) : EnglishFont(englishFont: [], timestamps: []);
      }(),
      arabicFont: () {
        final Map<String, dynamic>? raw = _field(
          data,
          modernKey: fieldArabicFont,
          legacyKey: 'arabicFont',
          valueKey: 'Arabic_Font',
          legacyValueKey: 'arabicFont',
        );
        return raw != null ? ArabicFont.fromMap(raw) : ArabicFont(arabicFont: [], timestamps: []);
      }(),
      // STATUS 24/8/2026: the document carries `Status: "inactive"` alongside
      // `status: "active"`, and `CompanyState.isCompanyActive` gates every
      // branding read on it. The camelCase one is the live value, so it wins
      // whenever the PascalCase one is missing or says otherwise — an "active"
      // company was being treated as inactive.
      status: (data['status'] as String?) ?? (data[fieldStatus] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        fieldCompanyName: companyName != null ? companyName!.toMap() : null,
        fieldTaxNumber: taxNumber != null ? taxNumber!.toMap() : null,
        fieldCompanyAddress:
            companyAddress != null ? companyAddress!.toMap() : null,
        fieldCity: city != null ? city!.toMap() : null,
        fieldZipCode: zipCode != null ? zipCode!.toMap() : null,
        fieldProvince: province != null ? province!.toMap() : null,
        fieldCountry: country != null ? country!.toMap() : null,
        fieldCompanyIndustry:
            companyIndustry != null ? companyIndustry!.toMap() : null,
        fieldCompanySize: companySize != null ? companySize!.toMap() : null,
        fieldModules: modules != null ? modules!.toMap() : null,
        fieldRole: role != null ? role!.toMap() : null,
        fieldFirstName: firstName != null ? firstName!.toMap() : null,
        fieldLastName: lastName != null ? lastName!.toMap() : null,
        fieldEmail: email != null ? email!.toMap() : null,
        fieldPhone: phone != null ? phone!.toMap() : null,
        fieldCompanyLogo: companyLogo != null ? companyLogo!.toMap() : null,
        fieldPrimaryColor: primaryColor != null ? primaryColor!.toMap() : null,
        fieldSecondaryColor:
            secondaryColor != null ? secondaryColor!.toMap() : null,
        fieldEnglishFont: englishFont != null ? englishFont!.toMap() : null,
        fieldArabicFont: arabicFont != null ? arabicFont!.toMap() : null,
        fieldStatus: status,
      };

  CompanyModel copyWith({
    CompanyName? companyName,
    TaxNumber? taxNumber,
    Address? companyAddress,
    City? city,
    ZipCode? zipCode,
    Province? province,
    Country? country,
    CompanyIndustry? companyIndustry,
    CompanySize? companySize,
    CompanyModules? modules,
    Role? role,
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    MobilePhone? phone,
    CompanyLogo? companyLogo,
    PrimaryColor? primaryColor,
    SecondaryColor? secondaryColor,
    EnglishFont? englishFont,
    ArabicFont? arabicFont,
    String? status,
  }) {
    return CompanyModel(
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      companyAddress: companyAddress ?? this.companyAddress,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      province: province ?? this.province,
      country: country ?? this.country,
      companyIndustry: companyIndustry ?? this.companyIndustry,
      companySize: companySize ?? this.companySize,
      modules: modules ?? this.modules,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyLogo: companyLogo ?? this.companyLogo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      englishFont: englishFont ?? this.englishFont,
      arabicFont: arabicFont ?? this.arabicFont,
      status: status ?? this.status,
    );
  }
}
