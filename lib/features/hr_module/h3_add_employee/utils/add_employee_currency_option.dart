// ***************************** FILE INFO ***************************** //
// File Name: add_employee_currency_option.dart
// Purpose: Defines currencies available to HR employee position forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

/// Defines MENA and commonly used international employee currencies.
enum CurrencyOption {
  usd,
  eur,
  gbp,
  chf,
  cny,
  jpy,
  inr,
  cad,
  aud,
  aed,
  sar,
  qar,
  kwd,
  bhd,
  omr,
  egp,
  jod,
  mad,
  dzd,
  tnd,
  iqd,
  ils,
  lbp,
  lyd,
  syp,
  yer,
  tryCurrency;

  String get value => name;

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized currency label.
  ///
  /// Returns: The localized currency code and name.
  String get title {
    switch (this) {
      case CurrencyOption.usd:
        return S.current.usd;
      case CurrencyOption.eur:
        return S.current.eur;
      case CurrencyOption.gbp:
        return S.current.gbp;
      case CurrencyOption.chf:
        return S.current.chf;
      case CurrencyOption.cny:
        return S.current.cny;
      case CurrencyOption.jpy:
        return S.current.jpy;
      case CurrencyOption.inr:
        return S.current.inr;
      case CurrencyOption.cad:
        return S.current.cad;
      case CurrencyOption.aud:
        return S.current.aud;
      case CurrencyOption.aed:
        return S.current.aed;
      case CurrencyOption.sar:
        return S.current.sar;
      case CurrencyOption.qar:
        return S.current.qar;
      case CurrencyOption.kwd:
        return S.current.kwd;
      case CurrencyOption.bhd:
        return S.current.bhd;
      case CurrencyOption.omr:
        return S.current.omr;
      case CurrencyOption.egp:
        return S.current.egp;
      case CurrencyOption.jod:
        return S.current.jod;
      case CurrencyOption.mad:
        return S.current.mad;
      case CurrencyOption.dzd:
        return S.current.dzd;
      case CurrencyOption.tnd:
        return S.current.tnd;
      case CurrencyOption.iqd:
        return S.current.iqd;
      case CurrencyOption.ils:
        return S.current.ils;
      case CurrencyOption.lbp:
        return S.current.lbp;
      case CurrencyOption.lyd:
        return S.current.lyd;
      case CurrencyOption.syp:
        return S.current.syp;
      case CurrencyOption.yer:
        return S.current.yer;
      case CurrencyOption.tryCurrency:
        return S.current.tryCurrency;
    }
  }
}
