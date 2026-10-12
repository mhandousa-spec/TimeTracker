// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

String capitalize(String input) {
  input.toLowerCase();
  input = applyAbbreviation(input);

  if (input.isEmpty) {
    return "";
  }

  List<String> words = input.split(" ");
  words = words.map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1);
    } else {
      return "";
    }
  }).toList();
  // print('words: $words');
  return words.join(" ");
}

String applyAbbreviation(String input) {
  for (String abbreviation in abbreviation) {
    RegExp regex = RegExp(r'\b' + abbreviation + r'\b', caseSensitive: false);
    if (regex.hasMatch(input)) {
  //    print('abbreviation: $abbreviation input : $input');
      input = input.replaceAllMapped(regex, (match) => abbreviation.toUpperCase());
    //  print ('new input : $input');
    }
  }
  return input;
}

// ❌ DELETED - Use SortOptionRole from filter_widget.dart instead
// enum SortOption { firstName, lastName, firstLogin, lastLogin }

enum SortRequest { firstName, lastName, date, department }

enum Connectiontype {
  email,
  phone,
  text;

  String toJson() => name;
  static Connectiontype fromJson(String? json) =>
      json != null ? values.byName(json) : Connectiontype.text;
}

extension ParseToStringConnectiontype on Connectiontype {
  String toShortString() {
    if (toString().split('.').last == 'email') {
      return 'Email';
    }
    if (toString().split('.').last == 'phone') {
      return 'Phone';
    }
    if (toString().split('.').last == 'text') {
      return 'Text';
    }
    return '';
  }
}

enum LanguageType {
  Arabic,
  English;

  String toJson() => name;
  static LanguageType? fromJson(String? json) {
    if (json == 'Arabic' || json == 'arabic') {
      return LanguageType.Arabic;
    }
    if (json == 'English' || json == 'english') {
      return LanguageType.English;
    }
    return null;
  }
}

enum GenderType {
  male,
  female,
  notSay;

  String toJson() => name;
  static GenderType? fromJson(String? json) {
    if (json == 'Male' || json == 'male') {
      return GenderType.male;
    }
    if (json == 'Female' || json == 'female') {
      return GenderType.female;
    }
    if (json == 'notSay' || json == 'Rather Not To Say') {
      return GenderType.notSay;
    }
    return null;
  }
}

extension ParseToStringGenderType on GenderType {
  String? toShortString() {
    if (toString().split('.').last == 'notSay') {
      return 'Rather Not To Say';
    }
    if (toString().split('.').last == 'Male' ||
        toString().split('.').last == 'male') {
      return 'Male';
    }
    if (toString().split('.').last == 'Female' ||
        toString().split('.').last == 'female') {
      return 'Female';
    }
    return null;
  }
}

enum IndustryType {
  entertainment,
  foodServices,
  government,
  utilities,
  administration,
  business,
  transportation,
  education,
  realEstate,
  construction,
  healthcare,
  manufacturing,
  engineering,
  financialServices,
  onlineRetail,
  hospitality,
  other;

  String toJson() => name;
  static IndustryType? fromJson(String? json) {
    if (json == 'Entertainment' || json == 'entertainment') {
      return IndustryType.entertainment;
    }
    if (json == 'Food Services' || json == 'foodServices') {
      return IndustryType.foodServices;
    }
    if (json == 'Government' || json == 'government') {
      return IndustryType.government;
    }
    if (json == 'Utilities' || json == 'utilities') {
      return IndustryType.utilities;
    }
    if (json == 'Administration' || json == 'administration') {
      return IndustryType.administration;
    }
    if (json == 'Business' || json == 'business') {
      return IndustryType.business;
    }
    if (json == 'Transportation' || json == 'transportation') {
      return IndustryType.transportation;
    }
    if (json == 'Education' || json == 'education') {
      return IndustryType.education;
    }
    if (json == 'Real Estate' || json == 'realEstate') {
      return IndustryType.realEstate;
    }
    if (json == 'Construction' || json == 'construction') {
      return IndustryType.construction;
    }
    if (json == 'Healthcare' || json == 'healthcare') {
      return IndustryType.healthcare;
    }
    if (json == 'Manufacturing' || json == 'manufacturing') {
      return IndustryType.manufacturing;
    }
    if (json == 'Engineering' || json == 'engineering') {
      return IndustryType.engineering;
    }
    if (json == 'Financial Services' || json == 'financialServices') {
      return IndustryType.financialServices;
    }
    if (json == 'OnlineRetail' || json == 'onlineRetail') {
      return IndustryType.onlineRetail;
    }
    if (json == 'Hospitality' || json == 'hospitality') {
      return IndustryType.hospitality;
    }
    if (json == 'Other' || json == 'other') {
      return IndustryType.other;
    }
    return null;
  }
}

extension ParseToStringIndustryType on IndustryType {
  String? toShortString() {
    if (toString().split('.').last == 'Entertainment' ||
        toString().split('.').last == 'entertainment') {
      return 'Entertainment';
    }
    if (toString().split('.').last == 'FoodServices' ||
        toString().split('.').last == 'foodServices') {
      return 'Food Services';
    }
    if (toString().split('.').last == 'Government' ||
        toString().split('.').last == 'government') {
      return 'Government';
    }
    if (toString().split('.').last == 'Utilities' ||
        toString().split('.').last == 'utilities') {
      return 'Utilities';
    }
    if (toString().split('.').last == 'Administration' ||
        toString().split('.').last == 'administration') {
      return 'Administration';
    }
    if (toString().split('.').last == 'Business' ||
        toString().split('.').last == 'business') {
      return 'Business';
    }
    if (toString().split('.').last == 'Transportation' ||
        toString().split('.').last == 'transportation') {
      return 'Transportation';
    }
    if (toString().split('.').last == 'Education' ||
        toString().split('.').last == 'education') {
      return 'Education';
    }
    if (toString().split('.').last == 'RealEstate' ||
        toString().split('.').last == 'realEstate') {
      return 'Real Estate';
    }
    if (toString().split('.').last == 'Construction' ||
        toString().split('.').last == 'construction') {
      return 'Construction';
    }
    if (toString().split('.').last == 'Healthcare' ||
        toString().split('.').last == 'healthcare') {
      return 'Healthcare';
    }
    if (toString().split('.').last == 'Manufacturing' ||
        toString().split('.').last == 'manufacturing') {
      return 'Manufacturing';
    }
    if (toString().split('.').last == 'Engineering' ||
        toString().split('.').last == 'engineering') {
      return 'Engineering';
    }
    if (toString().split('.').last == 'FinancialServices' ||
        toString().split('.').last == 'financialServices') {
      return 'Financial Services';
    }
    if (toString().split('.').last == 'OnlineRetail' ||
        toString().split('.').last == 'onlineRetail') {
      return 'Online Retail';
    }
    if (toString().split('.').last == 'Hospitality' ||
        toString().split('.').last == 'hospitality') {
      return 'Hospitality';
    }
    if (toString().split('.').last == 'Other' ||
        toString().split('.').last == 'other') {
      return 'Other';
    }
    return null;
  }
}

// ignore: camel_case_types
enum userType {
  free,
  paid;

  String toJson() => name.toLowerCase();
  static userType fromJson(String? json) {
    if (json == 'free') {
      return userType.free;
    }
    if (json == 'paid') {
      return userType.paid;
    }
    return userType.free;
  }
}

extension ParseToStringUserType on userType {
  String toShortString() {
    if (toString().split('.').last == 'Free') {
      return 'Free';
    }
    if (toString().split('.').last == 'Paid') {
      return 'Paid';
    }
    return 'Free';
  }
}

enum ConnectionStatus {
  blocked,
  connected,
  pending,
  unknow,
  deleted,
  noShow,
  canceled;

  String toJson() => name;
  static ConnectionStatus? fromJson(String? json) {
    if (json == 'blocked') {
      return ConnectionStatus.blocked;
    }
    if (json == 'deleted') {
      return ConnectionStatus.deleted;
    }
    if (json == 'connected') {
      return ConnectionStatus.connected;
    }
    if (json == 'canceled') {
      return ConnectionStatus.canceled;
    }
    if (json == 'unknow') {
      return ConnectionStatus.unknow;
    }
    if (json == 'pending') {
      return ConnectionStatus.pending;
    }
    if (json == 'noShow') {
      return ConnectionStatus.noShow;
    }
    return null;
  }

  String? toShortString() {
    if (toString().split('.').last == 'blocked') {
      return 'blocked';
    }
    if (toString().split('.').last == 'deleted') {
      return 'deleted';
    }
    if (toString().split('.').last == 'connected') {
      return 'connected';
    }
    if (toString().split('.').last == 'canceled') {
      return 'canceled';
    }
    if (toString().split('.').last == 'pending') {
      return 'pending';
    }
    if (toString().split('.').last == 'unknow') {
      return 'unknow';
    }
    if (toString().split('.').last == 'noShow') {
      return 'noShow';
    }
    return null;
  }
}

class QrScanResult {
  ConnectionStatus? connectionStatusForHim;
  ConnectionStatus? connectionStatusForMe;
  QrScanResult({this.connectionStatusForHim, this.connectionStatusForMe});
}

enum NotificationType {
  marketing,
  updates;

  String toJson() => name;
  static NotificationType fromJson(String? json) {
    if (json == 'marketing') {
      return NotificationType.marketing;
    }
    return NotificationType.updates;
  }

  String toShortString() {
    if (toString().split('.').last == 'marketing') {
      return 'marketing';
    }
    return 'updates';
  }
}

// VibrateType is defined in core/theme/haptic_controller.dart — use that one.

enum Languages {
  english,
  arabic,
  hindi,
  turkish,
  mandarin,
}

enum Currencys {
  usd, // United States Dollar
  eur, // Euro
  cny, // Chinese Yuan
  sar, // Saudi Riyal
  egp, // Egyptian Pound
  jpy, // Japanese Yen
  gbp, // Pound Sterling
  aud, // Australian Dollar
  cad, // Canadian Dollar
  chf, // Swiss Franc
  cnh, // Chinese Renminbi (Offshore)
  hkd, // Hong Kong Dollar
  nzd, // New Zealand Dollar
}

enum ConnectionStatusPerson { pending, add, chat }


