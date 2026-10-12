/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: company_information_model.dart
/// Purpose: The company details captured at demo signup.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

///************************** FILE INFO **************************///
/// File Name: company_information_model.dart
/// Purpose: Contains the model for holding company information over time.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:knowticed_plus/core/helper/main_helper/enum_single_value_tracking_model.dart';

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/company_size_list.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/industry.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';

class CompanyInformationModel {
  SingleValueModel<String> companyName;
  SingleValueModel<String> companyAddress;
  SingleValueModel<String> taxNumber;
  SingleValueModel<String> country;
  SingleValueModel<String> city;
  SingleValueModel<String> province;
  SingleValueModel<String> zipCode;
  EnumSingleValueTrackingModel<Industry> companyIndustry;
  EnumSingleValueTrackingModel<CompanySize> companySize;

  CompanyInformationModel({
    required this.companyName,
    required this.companyAddress,
    required this.taxNumber,
    required this.country,
    required this.city,
    required this.province,
    required this.zipCode,
    required this.companyIndustry,
    required this.companySize,
  });

  static const String COMPANY_NAME = 'Company_Name';
  static const String COMPANY_ADDRESS = 'Company_Address';
  static const String TAX_NUMBER = 'Tax_Number';
  static const String COUNTRY = 'Country';
  static const String CITY = 'City';
  static const String PROVINCE = 'Province';
  static const String ZIP_CODE = 'Zip_Code';
  static const String COMPANY_INDUSTRY = 'Company_Industry';
  static const String COMPANY_SIZE = 'Company_Size';

  Map<String, dynamic> toMap() {
    return {
      COMPANY_NAME: companyName.toMap(),
      COMPANY_ADDRESS: companyAddress.toMap(),
      TAX_NUMBER: taxNumber.toMap(),
      COUNTRY: country.toMap(),
      CITY: city.toMap(),
      PROVINCE: province.toMap(),
      ZIP_CODE: zipCode.toMap(),
      COMPANY_INDUSTRY: companyIndustry.toMap(),
      COMPANY_SIZE: companySize.toMap(),
    };
  }

  factory CompanyInformationModel.fromMap(Map<String, dynamic> map) {
    return CompanyInformationModel(
      companyName: SingleValueModel<String>.fromMap(map[COMPANY_NAME]),
      companyAddress:
          SingleValueModel<String>.fromMap(map[COMPANY_ADDRESS]),
      taxNumber: SingleValueModel<String>.fromMap(map[TAX_NUMBER]),
      country: SingleValueModel<String>.fromMap(map[COUNTRY]),
      city: SingleValueModel<String>.fromMap(map[CITY]),
      province: SingleValueModel<String>.fromMap(map[PROVINCE]),
      zipCode: SingleValueModel<String>.fromMap(map[ZIP_CODE]),
      companyIndustry:
          EnumSingleValueTrackingModel<Industry>.fromMap(map[COMPANY_INDUSTRY]),
      companySize:
          EnumSingleValueTrackingModel<CompanySize>.fromMap(map[COMPANY_SIZE]),
    );
  }
}
