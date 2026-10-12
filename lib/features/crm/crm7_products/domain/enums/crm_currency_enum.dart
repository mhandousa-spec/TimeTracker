// ****************** FILE INFO ******************
// File Name: crm_currency_enum.dart
// Purpose: Enumeration for supported CRM currencies with short abbreviations and EGP as default.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:get/get.dart';

enum CrmCurrencyEnum {
  egp(
    code: 'EGP',
    symbolAr: 'ج.م',
    symbolEn: 'EGP',
    nameEn: 'EGP',
    nameAr: 'ج.م',
  ),
  usd(
    code: 'USD',
    symbolAr: 'د.أ',
    symbolEn: 'USD',
    nameEn: 'USD',
    nameAr: 'د.أ',
  ),
  sar(
    code: 'SAR',
    symbolAr: 'ر.س',
    symbolEn: 'SAR',
    nameEn: 'SAR',
    nameAr: 'ر.س',
  ),
  aed(
    code: 'AED',
    symbolAr: 'د.إ',
    symbolEn: 'AED',
    nameEn: 'AED',
    nameAr: 'د.إ',
  ),
  kwd(
    code: 'KWD',
    symbolAr: 'د.ك',
    symbolEn: 'KWD',
    nameEn: 'KWD',
    nameAr: 'د.ك',
  ),
  qar(
    code: 'QAR',
    symbolAr: 'ر.ق',
    symbolEn: 'QAR',
    nameEn: 'QAR',
    nameAr: 'ر.ق',
  ),
  bhd(
    code: 'BHD',
    symbolAr: 'د.ب',
    symbolEn: 'BHD',
    nameEn: 'BHD',
    nameAr: 'د.ب',
  ),
  omr(
    code: 'OMR',
    symbolAr: 'ر.ع',
    symbolEn: 'OMR',
    nameEn: 'OMR',
    nameAr: 'ر.ع',
  ),
  eur(
    code: 'EUR',
    symbolAr: 'يورو',
    symbolEn: 'EUR',
    nameEn: 'EUR',
    nameAr: 'يورو',
  ),
  gbp(
    code: 'GBP',
    symbolAr: 'ج.إ',
    symbolEn: 'GBP',
    nameEn: 'GBP',
    nameAr: 'ج.إ',
  );

  final String code;
  final String symbolAr;
  final String symbolEn;
  final String nameEn;
  final String nameAr;

  const CrmCurrencyEnum({
    required this.code,
    required this.symbolAr,
    required this.symbolEn,
    required this.nameEn,
    required this.nameAr,
  });

  /// Default currency is EGP (Egyptian Pound).
  static CrmCurrencyEnum get defaultCurrency => CrmCurrencyEnum.egp;

  /// Dynamic getter returning the short abbreviation based on current app locale.
  String get displayName {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? nameAr : nameEn;
  }

  /// Dynamic getter returning the short symbol/abbreviation based on current app locale.
  String get displaySymbol {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    return isArabic ? symbolAr : symbolEn;
  }

  /// Helper to get localized short abbreviation for a specific language flag.
  String localizedName([bool isArabic = false]) => isArabic ? nameAr : nameEn;

  /// Helper to get localized short symbol for a specific language flag.
  String localizedSymbol([bool isArabic = false]) =>
      isArabic ? symbolAr : symbolEn;

  /// Safe lookup by currency code string. Defaults to `EGP`.
  static CrmCurrencyEnum fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return CrmCurrencyEnum.egp;
    final String normalized = code.trim().toUpperCase();
    return CrmCurrencyEnum.values.firstWhere(
      (CrmCurrencyEnum e) =>
          e.code == normalized || e.name.toUpperCase() == normalized,
      orElse: () => CrmCurrencyEnum.egp,
    );
  }
}
