/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: industry.dart
/// Purpose: Industries offered at demo signup.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).



enum Industry {
  all,
  entertainment,
  foodServices,

  healthcare,
  manufacturing,
  government,
  utilities,
  administration,
  education,
  business,

  engineering,

  financialServices,
  realEstate,
  construction,
  transportation,
  hospitality,
  onlineRetail,
  other,
}

extension IndustryExtension on Industry {
  String get getName {
    switch (this) {
      case Industry.all:
        return 'All';
      case Industry.entertainment:
        return 'Entertainment';
      case Industry.foodServices:
        return 'Food Services';
      case Industry.healthcare:
        return 'Healthcare';
      case Industry.manufacturing:
        return 'Manufacturing';
      case Industry.government:
        return 'Government';
      case Industry.utilities:
        return 'Utilities';
      case Industry.administration:
        return 'Administration';
      case Industry.education:
        return 'Education';
      case Industry.business:
        return 'Business';
      case Industry.engineering:
        return 'Engineering';
      case Industry.financialServices:
        return 'Financial Services';
      case Industry.realEstate:
        return 'Real Estate';
      case Industry.construction:
        return 'Construction';
      case Industry.transportation:
        return 'Transportation';
      case Industry.hospitality:
        return 'Hospitality';
      case Industry.onlineRetail:
        return 'Online Retail';
      case Industry.other:
        return 'Other';
    }
  }
}

extension IndustryExtension2 on Industry {
  String get getArabicName {
    switch (this) {
      case Industry.all:
        return 'الكل';
      case Industry.entertainment:
        return 'ترفيه';
      case Industry.foodServices:
        return 'خدمات الطعام';
      case Industry.healthcare:
        return 'الرعاية الصحية';
      case Industry.manufacturing:
        return 'تصنيع';
      case Industry.government:
        return 'حكومة';
      case Industry.utilities:
        return 'مرافق';
      case Industry.administration:
        return 'إدارة';
      case Industry.education:
        return 'تعليم';
      case Industry.business:
        return 'عمل';
      case Industry.engineering:
        return 'هندسة';
      case Industry.financialServices:
        return 'خدمات مالية';
      case Industry.realEstate:
        return 'عقارات';
      case Industry.construction:
        return 'بناء';
      case Industry.transportation:
        return 'مواصلات';
      case Industry.hospitality:
        return 'ضيافة';
      case Industry.onlineRetail:
        return 'التجزئة على الانترنت';
      case Industry.other:
        return 'آخر';
    }
  }
}


