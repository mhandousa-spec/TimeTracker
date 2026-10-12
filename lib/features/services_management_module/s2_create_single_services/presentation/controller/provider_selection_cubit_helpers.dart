// ******************* FILE INFO *******************
// File Name: provider_selection_cubit_helpers
// Description: UI/format helpers extracted from provider_selection_cubit (§7 split).
// Module: services_management_module / presentation / s2_create_single_services / controller
// *************************************************
part of 'provider_selection_cubit.dart';

extension ProviderSelectionHelpers on ProviderSelectionCubit {
  String getScreenTitle(BuildContext context) {
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;

    // 004: localized title via .arb instead of a hardcoded Arabic literal.
    if (data.editProvider != null) {
      return S.of(context).editServiceProvider;
    }

    if (data.editingModel == null && data.docId == null) {
      return S.of(context).creatingNewService;
    }

    if (data.editingModel != null) {
      final isDraft = data.editingModel!.currentState == "draft" ||
          data.editingModel!.currentDurationOfServices == "-" ||
          data.editingModel!.currentDurationOfServices.isEmpty;

      final serviceName = Localizations.localeOf(context).languageCode == 'ar'
          ? data.editingModel!.currentServiceNameArabic
          : data.editingModel!.currentServiceNameEnglish;

      if (isDraft) {
        return "${S.of(context).draft} $serviceName";
      } else {
        return "${S.of(context).Editing} $serviceName";
      }
    }

    if (data.docId != null) {
      return S.of(context).creatingNewService;
    }

    return S.of(context).creatingNewService;
  }

  String formatPhoneNumber(dynamic mobilePhone) {
    if (mobilePhone == null) return '';

    var countryCode = mobilePhone.countryCode ?? '';
    var phone = mobilePhone.phone ?? '';

    countryCode = countryCode.replaceAll('[', '').replaceAll(']', '').trim();
    phone = phone.replaceAll('[', '').replaceAll(']', '').trim();

    if (countryCode.isEmpty || phone.isEmpty) return '';

    return '+$countryCode $phone';
  }

  String _ordinalEn(int n) {
    switch (n) {
      case 1: return "First";
      case 2: return "Second";
      case 3: return "Third";
      case 4: return "Fourth";
      case 5: return "Fifth";
      case 6: return "Sixth";
      case 7: return "Seventh";
      case 8: return "Eighth";
      case 9: return "Ninth";
      case 10: return "Tenth";
      default:
        final mod100 = n % 100;
        if (mod100 >= 11 && mod100 <= 13) return "${n}th";
        switch (n % 10) {
          case 1: return "${n}st";
          case 2: return "${n}nd";
          case 3: return "${n}rd";
          default: return "${n}th";
        }
    }
  }

  String _ordinalAr(int n) {
    switch (n) {
      case 1: return "الأول";
      case 2: return "الثاني";
      case 3: return "الثالث";
      case 4: return "الرابع";
      case 5: return "الخامس";
      case 6: return "السادس";
      case 7: return "السابع";
      case 8: return "الثامن";
      case 9: return "التاسع";
      case 10: return "العاشر";
      default: return "رقم $n";
    }
  }
}
