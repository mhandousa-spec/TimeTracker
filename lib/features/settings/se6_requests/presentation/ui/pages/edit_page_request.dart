/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request.dart
/// Purpose: The personal-information edit form that feeds the preview page.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N02/N06/N12: the seven try/catch blocks left presentation/ui
///          (four of them were dead — they wrapped `tryParse`); raw colours
///          route through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.
///
/// REMAINING (N05, N13): still ~1,300 LOC, and it hands the preview page live
/// TextEditingControllers.

///*************************** FILE INFO ****************************///
/// Purpose: Edit page for personal information change requests with Arabic support
/// Author: Claude AI Assistant
/// Updated At: 07/11/2025
/// Using CustomValidatedTextField and CustomDropdownFormField
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/preview_changes_page.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/flexible_date_parser.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/gallery_image_picker.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/drop_down.dart' hide CustomDropdownFormFieldFinal;
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/core/custom/60-custom_country_picker.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/location_data_service.dart';

class EditPageRequest extends StatefulWidget {
  const EditPageRequest({super.key});

  @override
  State<EditPageRequest> createState() => _EditPageRequestState();
}

class _EditPageRequestState extends State<EditPageRequest> {
  // Controllers for all fields
  // NAMES 24/8/2026 — six controllers, not three.
  //
  // Each name used to be ONE controller pointed at whichever spelling matched
  // the UI language: in Arabic it edited `firstNameInArabic`, in English it
  // edited `firstName`. So an employee could only ever maintain one of the two,
  // and which one depended on the language they happened to be using. Both are
  // edited together now, side by side.
  late TextEditingController firstNameController; // English spelling
  late TextEditingController firstNameArController; // Arabic spelling
  late TextEditingController middleNameController;
  late TextEditingController middleNameArController;
  late TextEditingController lastNameController;
  late TextEditingController lastNameArController;

  // Labels for the name boxes. Deliberately NOT localized: they name the SCRIPT
  // of the value, not the UI. Localizing them would print the same word above
  // both boxes in a given language and make the pair ambiguous.
  static const String _labelFirstNameEn = 'First Name';
  static const String _labelMiddleNameEn = 'Middle Name';
  static const String _labelLastNameEn = 'Last Name';
  static const String _labelFirstNameAr = 'الاسم الأول';
  static const String _labelMiddleNameAr = 'الاسم الأوسط';
  static const String _labelLastNameAr = 'اسم العائلة';
  // REMOVED 24/8/2026: the email field is gone from this form. The address is
  // not populated for every employee, so the row rendered blank (and
  // `employee!.email!.last` below threw outright when the list was null),
  // which is why it did not show "all the time".
  late TextEditingController phoneController;
  late TextEditingController nationalityController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController dateOfBirthController;

  // LOCATION 24/8/2026: Country / State / City are dropdowns now, not free text.
  //
  // The three TextEditingControllers above stay — PreviewChangesPage reads their
  // `.text`, and the change payload is still plain strings, so nothing
  // downstream had to learn about codes. These two only remember WHICH row is
  // selected, which is what lets the cascade reset the levels below it.
  String? _selectedCountryIso;
  String? _selectedStateCode;

  /// The state/city data is an asset, so it arrives one frame late. Until it
  /// does, `statesOf` returns empty; the country dropdown works either way
  /// because that list comes from country_picker, not from the file.
  bool _locationDataReady = false;

  // Selected values
  String? selectedGender;
  String? selectedMaritalStatus;
  DateTime? selectedDateOfBirth;
  var selectedCountryCode;

  File? _selectedImage;

  /// The picker and its error handling live in the data layer
  /// (CR-SKEL-SE6-N02).
  final GalleryImagePicker _galleryPicker = GalleryImagePicker();

  // Form validation
  bool submitted = false;

  // Change tracking
  Map<String, dynamic> changes = {};

  // Dropdown items - will be initialized with localized values
  List<Map<String, String>> genderItems = [];
  List<Map<String, String>> maritalStatusItems = [];

  /// Guards the one-time init below: didChangeDependencies fires again whenever
  /// an inherited widget changes (locale switch, theme change, …).
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    // Both of these read S.of(context), which depends on the Localizations
    // inherited widget — that is not available yet during initState(), so the
    // work has to happen here instead. _initializeControllers() must run second
    // because it looks up the current gender / marital status inside the lists
    // built by _initializeDropdownItems().
    _initializeDropdownItems();
    _initializeControllers();
    _loadLocationData();
  }

  /// Reads the country/state/city asset, then turns whatever the employee record
  /// already holds ("Kuwait", "Salmiya") back into dropdown selections.
  Future<void> _loadLocationData() async {
    await LocationDataService.instance.load();
    if (!mounted) return;
    setState(() {
      _locationDataReady = true;
      _resolveSavedLocation();
    });
  }

  /// Matching is deliberately loose (see `LocationOption.matchesLoose`) because
  /// these values were typed by hand for years — "Mubarak Al-kabeer
  /// Governorate" has to find "Mubarak Al-Kabeer".
  ///
  /// A value that matches nothing leaves that dropdown unselected rather than
  /// guessing. It is NOT written back as a change: `_trackChange` is not called
  /// here, so opening the page never invents an edit the user did not make.
  void _resolveSavedLocation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final service = LocationDataService.instance;

    final country =
        _firstMatch(service.countries(context), countryController.text);
    _selectedCountryIso = country?.code;
    countryController.text = country?.label(isArabic) ?? '';

    final state = _firstMatch(
      service.statesOf(_selectedCountryIso),
      provinceController.text,
    );
    _selectedStateCode = state?.code;
    provinceController.text = state?.label(isArabic) ?? '';

    final city = _firstMatch(
      service.citiesOf(_selectedCountryIso, _selectedStateCode),
      cityController.text,
    );
    cityController.text = city?.label(isArabic) ?? '';
  }

  LocationOption? _firstMatch(List<LocationOption> options, String? saved) {
    for (final option in options) {
      if (option.matchesLoose(saved)) return option;
    }
    return null;
  }

  void _initializeControllers() {
    if (employee == null) {}

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Get the current mobile phone object
    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone =
        mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    // Extract phone data from MobilePhone object
    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final countryApp = mobilePhone?.countryApp?.lastOrNull ?? "EG";

    // Both spellings are loaded, independent of the UI language. Only the
    // English ones are capitalized — `FormatHelper.capitalize` is an ASCII
    // upper-casing helper and has nothing to do on Arabic text.
    firstNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.firstName?.lastOrNull ?? ''),
    );
    firstNameArController = TextEditingController(
      text: employee?.firstNameInArabic?.lastOrNull ?? '',
    );

    middleNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.middleName?.lastOrNull ?? ''),
    );
    middleNameArController = TextEditingController(
      text: employee?.middleNameInArabic?.lastOrNull ?? '',
    );

    lastNameController = TextEditingController(
      text: FormatHelper.capitalize(employee?.lastName?.lastOrNull ?? ''),
    );
    lastNameArController = TextEditingController(
      text: employee?.lastNameInArabic?.lastOrNull ?? '',
    );

    // Initialize phone controller with the actual phone number
    phoneController = TextEditingController(
      text: phoneNumber,
    );

    nationalityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.nationality?.lastOrNull ?? ''),
    );

    countryController = TextEditingController(
      text: FormatHelper.capitalize(employee?.country?.lastOrNull ?? ''),
    );

    provinceController = TextEditingController(
      text: FormatHelper.capitalize(employee?.province?.lastOrNull ?? ''),
    );

    cityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.city?.lastOrNull ?? ''),
    );

    streetController = TextEditingController(
      text: FormatHelper.capitalize(employee?.street?.lastOrNull ?? ''),
    );

    // Set initial selected values for gender
    final genderValue = employee?.gender?.lastOrNull?.toLowerCase();
    selectedGender = genderItems.firstWhere(
      (item) => item['key'] == genderValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedGender?.isEmpty ?? true) {
      selectedGender = null;
    }

    // Set initial selected values for marital status
    final maritalValue = employee?.maritalStatus?.lastOrNull?.toLowerCase();
    selectedMaritalStatus = maritalStatusItems.firstWhere(
      (item) => item['key'] == maritalValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedMaritalStatus?.isEmpty ?? true) {
      selectedMaritalStatus = null;
    }

    // Set country code - use the extracted country code from MobilePhone
    selectedCountryCode = countryCode;

    // Parse birthday with improved error handling
    final birthdayString = employee?.birthDay?.lastOrNull;

    // Only attempt to parse if we have a non-null, non-empty string
    if (birthdayString != null && birthdayString.trim().isNotEmpty) {
      selectedDateOfBirth = _parseDate(birthdayString);
    } else {
      selectedDateOfBirth = null;
    }
    // Initialize date controller with formatted date (localized if Arabic)
    dateOfBirthController = TextEditingController(
      text: selectedDateOfBirth != null
          ? _formatDateForDisplay(selectedDateOfBirth!)
          : '',
    );
  }

  void _initializeDropdownItems() {
    // Initialize gender items with localized values
    genderItems = [
      {'key': 'male', 'value': S.of(context).male},
      {'key': 'female', 'value': S.of(context).female},
    ];

    // Initialize marital status items with localized values
    maritalStatusItems = [
      {'key': 'single', 'value': S.of(context).single},
      {'key': 'married', 'value': S.of(context).married},
      {'key': 'divorced', 'value': S.of(context).divorced},
      {'key': 'widowed', 'value': S.of(context).widowed},
    ];
  }

  /// Function Name: [_pickImage]
  ///
  /// Purpose: Choose a new profile photo for the request.
  ///
  /// The picker call and its try/catch moved to `GalleryImagePicker`
  /// (CR-SKEL-SE6-N02). A denied permission now surfaces instead of looking
  /// identical to the user cancelling.
  Future<void> _pickImage() async {
    final ImagePickResult result = await _galleryPicker.pick();
    if (!mounted) return;

    switch (result.outcome) {
      case ImagePickOutcome.picked:
        setState(() => _selectedImage = result.file);
        _trackChange('photo', employee?.photo?.lastOrNull, result.file!.path);
        break;
      case ImagePickOutcome.failed:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(S.of(context).failedToPickImage),
              backgroundColor: AppColors.signOut,
              behavior: SnackBarBehavior.floating,
            ),
          );
        break;
      case ImagePickOutcome.cancelled:
        break;
    }
  }

  /// Display format for a date field: `29 Aug 2023`.
  ///
  /// CHANGED 8/9/2026 — was `dd/MM/yyyy` in English and `yyyy/M/dd` in Arabic.
  /// An all-numeric date is ambiguous at a glance — `12/11/1977` reads as 12
  /// November to one reader and December 11 to another — and having the two
  /// locales disagree on field order made it worse. A named month can only be
  /// read one way.
  ///
  /// The month name follows the app language, so Arabic renders as
  /// `٢٩ أغسطس ٢٠٢٣`. Passing the locale explicitly is safe: main() calls
  /// `AppBarDate.ensureDateFormattingInitialized()` at start-up, which loads
  /// intl date symbols for every supported locale.
  ///
  /// DISPLAY ONLY. What gets stored is `picked.toIso8601String()` (see
  /// [_buildDateOfBirthField]), so this touches neither saved data nor
  /// `FlexibleDateParser`, which still reads whatever the record holds.
  String _formatDateForDisplay(DateTime date) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String formatted =
        DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);

    if (isArabic) {
      return ArabicDigits(formatted).toArabicNumbers();
    }
    return formatted;
  }

  // Helper method to convert English numbers to Arabic

  /// Delegates to `FlexibleDateParser`, which is where the four dead
  /// try/catch blocks this method used to hold now do not exist
  /// (CR-SKEL-SE6-N02).
  DateTime? _parseDate(String? dateString) =>
      FlexibleDateParser.parse(dateString);

  String _convertArabicToEnglish(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    firstNameArController.dispose();
    middleNameController.dispose();
    middleNameArController.dispose();
    lastNameController.dispose();
    lastNameArController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  // Country flag / dial code lookups moved to
  // se1_profile/data/utils/phone_country_lookup.dart — each held a try/catch
  // (CR-SKEL-SE6-N02).

  Set<String> touchedFields = {};

  void _markFieldAsTouched(String fieldName) {
    setState(() {
      touchedFields.add(fieldName);
    });
  }

  /// One name box.
  ///
  /// [arabic] picks which spelling this box edits: the Arabic one writes
  /// `<field>_arabic` and compares against `…InArabic`, the English one writes
  /// `<field>`. The text direction follows the SCRIPT of the box, not the UI
  /// language — an Arabic name is RTL even while the app is in English.
  Widget _buildNameField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String field,
    required String? original,
    required bool arabic,
  }) {
    // LABEL SIDE 24/8/2026.
    //
    // `textDirection` already put the VALUE on the correct side, but the label
    // stayed left: CustomTextField draws it in a
    // `Column(crossAxisAlignment: start)`, and `start` resolves against the
    // ambient Directionality — the app locale — not against the field's own
    // direction. So in the English UI "الاسم الأول" sat top-left while the
    // Arabic text it labelled sat bottom-right.
    //
    // Wrapping the field in its own Directionality makes `start` mean the same
    // side the text uses, so label and value line up. Done for BOTH scripts,
    // not just Arabic: in the Arabic UI an English field would otherwise have
    // the same mismatch mirrored.
    return Directionality(
      textDirection: arabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: CustomTextField(
        height: _kFieldHeight,
        label: label,
        hint: hint,
        controller: controller,
        textDirection: arabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        textAlign: arabic ? TextAlign.right : TextAlign.left,
        onChanged: (value) => _trackChange(field, original, value),
      ),
    );
  }

  void _trackChange(String field, dynamic oldValue, dynamic newValue) {
    if (oldValue != newValue) {
      changes[field] = {
        'oldValue': oldValue,
        'newValue': newValue,
      };
    } else {
      changes.remove(field);
    }
  }

  Future<void> _submitChanges() async {
    setState(() {
      submitted = true;
    });

    // A first and a last name are still required, but EITHER spelling
    // satisfies it — someone filling in only Arabic is not blocked.
    final hasFirstName = firstNameController.text.trim().isNotEmpty ||
        firstNameArController.text.trim().isNotEmpty;
    final hasLastName = lastNameController.text.trim().isNotEmpty ||
        lastNameArController.text.trim().isNotEmpty;

    if (!hasFirstName || !hasLastName) {
      _showValidationErrorDialog(S.of(context).pleaseFillInAllRequiredFields);
      return;
    }

    if (changes.isEmpty) {
      _showValidationErrorDialog(S.of(context).youHavenTMadeAnyChangesToSubmit);
      return;
    }

    navigateTo(
      context,
      PreviewChangesPage(
        changes: changes,
        selectedImage: _selectedImage,
        firstNameController: firstNameController,
        firstNameArController: firstNameArController,
        middleNameController: middleNameController,
        middleNameArController: middleNameArController,
        lastNameController: lastNameController,
        lastNameArController: lastNameArController,
        phoneController: phoneController,
        countryController: countryController,
        provinceController: provinceController,
        cityController: cityController,
        streetController: streetController,
        dateOfBirthController: dateOfBirthController,
        selectedGender: selectedGender,
        selectedMaritalStatus: selectedMaritalStatus,
        selectedCountryCode: selectedCountryCode,
      ),
    );
  }

  void _showValidationErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        var lightMode = Theme.of(context).brightness == Brightness.light;
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Material(
            color: AppColors.barrierColor,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 411.w,
                  padding: EdgeInsets.all(24.sp),
                  decoration: BoxDecoration(
                    color:
                        lightMode ? AppColors.white : AppColors.chatBackground,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                          'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.scaleDown,
                          repeat: true),
                      SizedBox(height: 20.h),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isPhone = ContextExtension(context).isPhone;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingMyPersonalData,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).current_details,
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 10.sp),
                    Container(
                      padding: EdgeInsets.only(
                          top: 15.h, right: 15.w, left: 15.w, bottom: 15.sp),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPortrait) ...[
                            _buildAvatarPicker(lightMode),
                            SizedBox(height: 20.sp),
                            // Portrait has no room for two boxes on a line, so
                            // the pairs stack: English then Arabic, per name.
                            _buildNameField(
                              label: _labelFirstNameEn,
                              hint: S.of(context).enterYourFirstName,
                              controller: firstNameController,
                              field: 'first_name',
                              original: employee?.firstName?.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _labelFirstNameAr,
                              hint: _labelFirstNameAr,
                              controller: firstNameArController,
                              field: 'first_name_arabic',
                              original: employee?.firstNameInArabic?.lastOrNull,
                              arabic: true,
                            ),
                            isPhone
                                ? SizedBox(height: 16.h)
                                : SizedBox(height: 12.h),
                            _buildNameField(
                              label: _labelMiddleNameEn,
                              hint: S.of(context).enterYourMiddleName,
                              controller: middleNameController,
                              field: 'middle_name',
                              original: employee?.middleName?.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _labelMiddleNameAr,
                              hint: _labelMiddleNameAr,
                              controller: middleNameArController,
                              field: 'middle_name_arabic',
                              original:
                                  employee?.middleNameInArabic?.lastOrNull,
                              arabic: true,
                            ),
                            isPhone
                                ? SizedBox(height: 16.h)
                                : SizedBox(height: 12.h),
                            _buildNameField(
                              label: _labelLastNameEn,
                              hint: S.of(context).enterYourLastName,
                              controller: lastNameController,
                              field: 'last_name',
                              original: employee?.lastName?.lastOrNull,
                              arabic: false,
                            ),
                            SizedBox(height: 12.h),
                            _buildNameField(
                              label: _labelLastNameAr,
                              hint: _labelLastNameAr,
                              controller: lastNameArController,
                              field: 'last_name_arabic',
                              original: employee?.lastNameInArabic?.lastOrNull,
                              arabic: true,
                            ),
                            isPhone ? SizedBox(height: 16.h) : SizedBox(),
                          ] else ...[
                            _buildAvatarPicker(lightMode),
                            SizedBox(height: 20.sp),
                            // Landscape: three rows of two. English on the
                            // left, Arabic on the right, so each name and its
                            // other spelling sit next to each other instead of
                            // one of them being unreachable in this language.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelFirstNameEn,
                                    hint: S.of(context).enterYourFirstName,
                                    controller: firstNameController,
                                    field: 'first_name',
                                    original: employee?.firstName?.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelFirstNameAr,
                                    hint: _labelFirstNameAr,
                                    controller: firstNameArController,
                                    field: 'first_name_arabic',
                                    original:
                                        employee?.firstNameInArabic?.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelMiddleNameEn,
                                    hint: S.of(context).enterYourMiddleName,
                                    controller: middleNameController,
                                    field: 'middle_name',
                                    original: employee?.middleName?.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelMiddleNameAr,
                                    hint: _labelMiddleNameAr,
                                    controller: middleNameArController,
                                    field: 'middle_name_arabic',
                                    original: employee
                                        ?.middleNameInArabic?.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelLastNameEn,
                                    hint: S.of(context).enterYourLastName,
                                    controller: lastNameController,
                                    field: 'last_name',
                                    original: employee?.lastName?.lastOrNull,
                                    arabic: false,
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _buildNameField(
                                    label: _labelLastNameAr,
                                    hint: _labelLastNameAr,
                                    controller: lastNameArController,
                                    field: 'last_name_arabic',
                                    original:
                                        employee?.lastNameInArabic?.lastOrNull,
                                    arabic: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: isPhone ? 12.h : 16.h),
                          if (isPortrait) ...[
                            CustomDropdown<String>(
                              height: _kFieldHeight,
                              enforceTypeScale: false,
                              valueStyle: _kFieldValueStyle,
                              label: S.of(context).gender,
                              value: selectedGender,
                              items: genderItems
                                  .map((item) => DropdownItem<String>(
                                        value: item['key']!,
                                        label: item['value']!,
                                      ))
                                  .toList(),
                              borderRadius: BorderRadius.circular(4.r),
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                  final selectedItem = genderItems.firstWhere(
                                    (item) => item['key'] == value,
                                    orElse: () => {'key': '', 'value': ''},
                                  );
                                  _trackChange(
                                    'gender',
                                    employee?.gender?.lastOrNull,
                                    selectedItem['key'],
                                  );
                                });
                              },
                            ),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            _buildDateOfBirthField(lightMode),
                            SizedBox(height: isPhone ? 12.h : 16.h),
                            CustomDropdown<String>(
                              height: _kFieldHeight,
                              enforceTypeScale: false,
                              valueStyle: _kFieldValueStyle,
                              label: S.of(context).maritalStatus,
                              value: selectedMaritalStatus,
                              items: maritalStatusItems
                                  .map((item) => DropdownItem<String>(
                                        value: item['key']!,
                                        label: item['value']!,
                                      ))
                                  .toList(),
                              borderRadius: BorderRadius.circular(4.r),
                              onChanged: (value) {
                                setState(() {
                                  selectedMaritalStatus = value;
                                  final selectedItem =
                                      maritalStatusItems.firstWhere(
                                    (item) => item['key'] == value,
                                    orElse: () => {'key': '', 'value': ''},
                                  );
                                  _trackChange(
                                    'marital_status',
                                    employee?.maritalStatus?.lastOrNull,
                                    selectedItem['key'],
                                  );
                                });
                              },
                            ),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomDropdown<String>(
                                    height: _kFieldHeight,
                                    enforceTypeScale: false,
                                    valueStyle: _kFieldValueStyle,
                                    label: S.of(context).gender,
                                    value: selectedGender,
                                    items: genderItems
                                        .map((item) => DropdownItem<String>(
                                              value: item['key']!,
                                              label: item['value']!,
                                            ))
                                        .toList(),
                                    borderRadius: BorderRadius.circular(4.r),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                        final selectedItem =
                                            genderItems.firstWhere(
                                          (item) => item['key'] == value,
                                          orElse: () =>
                                              {'key': '', 'value': ''},
                                        );
                                        _trackChange(
                                          'gender',
                                          employee?.gender?.lastOrNull,
                                          selectedItem['key'],
                                        );
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                    child: _buildDateOfBirthField(lightMode)),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomDropdown<String>(
                                    height: _kFieldHeight,
                                    enforceTypeScale: false,
                                    valueStyle: _kFieldValueStyle,
                                    label: S.of(context).maritalStatus,
                                    borderRadius: BorderRadius.circular(4.r),
                                    value: selectedMaritalStatus,
                                    items: maritalStatusItems
                                        .map((item) => DropdownItem<String>(
                                              value: item['key']!,
                                              label: item['value']!,
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMaritalStatus = value;
                                        final selectedItem =
                                            maritalStatusItems.firstWhere(
                                          (item) => item['key'] == value,
                                          orElse: () =>
                                              {'key': '', 'value': ''},
                                        );
                                        _trackChange(
                                          'marital_status',
                                          employee?.maritalStatus?.lastOrNull,
                                          selectedItem['key'],
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Container(
                      padding:
                          EdgeInsets.only(top: 15.h, right: 15.w, left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    'assets/icons_assets/settings_assets/phone_call_contact.svg',
                                width: 25.w,
                                height: 25.h,
                                fit: BoxFit.fill,
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
                          _buildContactSection(isPortrait, lightMode, isTablet),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Container(
                      padding:
                          EdgeInsets.only(top: 15.h, right: 15.w, left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvgImage(
                                assetPath:
                                    'assets/icons_assets/settings_assets/location_city_pin.svg',
                                width: 25.w,
                                height: 25.h,
                                fit: BoxFit.fill,
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
                          SizedBox(height: 10.sp),
                          _buildLocationSection(
                              isPortrait, lightMode, isTablet),
                          isPhone ? SizedBox() : SizedBox(height: 16.h),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.sp),
                // Replace the preview button section at the bottom of your build method with this:

                // Replace the preview button section at the bottom of your build method with this:

                Row(
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
                          color: AppColors.white),
                    ),
                    Spacer(),
                    customButton(
                      title: S.of(context).preview,
                      function: changes.isEmpty
                          ? () {} // Empty function when disabled (or null if customButton supports it)
                          : () => _submitChanges(), // Wrap async function
                      height: 38.h,
                      width: 150.sp,
                      color: changes.isEmpty
                          ? lightMode
                              ? AppColors.grey
                              : AppColors.darkGrey
                          : AppColors.primary, // Gray if no changes
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: changes.isEmpty
                            ? lightMode
                                ? AppColors.colorBlack
                                : AppColors.white // Lighter text when disabled
                            : AppColors.textButton,
                      ),
                    ),
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

  /// Profile photo with the camera badge. Shared by the portrait (phone) and
  /// landscape layouts — bug report (Settings mobile p.2, "where is the
  /// image?"): portrait used to leave it out, so a phone could not see or
  /// change the photo at all.
  Widget _buildAvatarPicker(bool lightMode) {
    return Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 29.r,
                  backgroundColor: AppColors.background,
                  // (_selectedImage != null ||
                  //     (employee?.photo != null && employee!.photo!.isNotEmpty))
                  //     ? AppColors.transparent
                  //     : AppColors.grey,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(32.r),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: 58.r,
                            height: 58.r,
                          )
                        : (employee?.photo != null &&
                                employee!.photo!.isNotEmpty)
                            ? Image.network(
                                employee!.photo!.last!,
                                fit: BoxFit.cover,
                                errorBuilder: (context,
                                    error, stackTrace) {
                                  return Container(
                                    padding: EdgeInsets.all(
                                        8.sp),
                                    child: SvgPicture.asset(
                                      'assets/icons_assets/main_icons_assets/image_photo_rounded.svg',
                                      width: 26.sp,
                                      height: 26.sp,
                                      color: lightMode
                                          ? AppColors
                                              .colorBlack
                                          : AppColors.white,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                padding:
                                    EdgeInsets.all(8.sp),
                                child: SvgPicture.asset(
                                  'assets/icons_assets/main_icons_assets/image_photo_rounded.svg',
                                  width: 26.sp,
                                  height: 26.sp,
                                ),
                              ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                  },
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: AppColors.primary,
                    child: SvgPicture.asset(
                      'assets/icons_assets/messaging_assets/camera.svg',
                      width: 14.sp,
                      height: 14.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
  }


  /// Birth date picker. NOTE: no outer Padding here — CustomDropdownCalendar
  /// already draws its own label + 6.h gap, exactly like CustomTextField and
  /// CustomDropdown. Any extra top padding pushes this column out of line with
  /// Gender / Marital Status next to it.
  Widget _buildDateOfBirthField(bool lightMode) {
    return CustomDropdownCalendar(
      height: _kFieldHeight,
      key: ValueKey(
        'birthday_${selectedDateOfBirth?.toIso8601String() ?? "empty"}',
      ),
      value: selectedDateOfBirth,
      label: S.of(context).birthday,
      hint: S.of(context).selectdate,
      borderRadius: BorderRadius.circular(4.r),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // Keeps the existing locale-aware dd/MM/yyyy + Arabic-numeral display.
      dateFormatter: _formatDateForDisplay,
      onChanged: (picked) {
        if (picked == null) return;
        setState(() {
          selectedDateOfBirth = picked;
          dateOfBirthController.text = _formatDateForDisplay(picked);
          _trackChange(
            'date_of_birth',
            employee?.birthDay?.lastOrNull,
            picked.toIso8601String(),
          );
        });
      },
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────
  // The name / gender / location rows are three equal columns with a 12.sp
  // gutter. Contact uses the same grid: the phone block spans two columns
  // from the left gridline. Keep the unit as .sp — the other Rows in this file
  // use .sp, and .sp / .w scale differently once minTextAdapt kicks in, which
  // would drift the columns apart.
  double get _gridGap => 12.sp;

  // ── One field box for the whole page (28/9/2026) ─────────────────────────
  // Settings bug report p.8: Gender / Birthday / Marital Status (and the name
  // fields above them) each sized themselves — the dropdown around a 20.sp
  // chevron, the date box around an 18.sp calendar icon, the text fields
  // around a line of text — so the boxes came out at different heights with
  // different space above and below their values, and the dropdowns drew
  // their value at 12 while the text fields and the date drew it at 14.
  // Every CustomTextField / CustomDropdown / CustomDropdownCalendar on this
  // page now takes this one height (each widget then zeroes its vertical
  // padding and centres the value, with the same 12.sp side padding), and
  // the dropdowns draw their value in the same style as the text fields.
  static const double _kFieldHeight = 40;

  TextStyle get _kFieldValueStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.text);

  /// The country-code box. Fixed in BOTH orientations (23/8/2026): it holds a
  /// flag and three or four characters, so it needs a small pinned width and
  /// the number field takes every pixel left over.
  ///
  /// It used to be one full grid column in landscape, which put a 4-character
  /// dial code in a box as wide as the email field beside it.
  double get _dialCodeWidth => 100.sp;

  /// Matches the label CustomTextField / CustomDropdown draw internally, so a
  /// hand-rolled label lines up with the generated ones.
  ///
  /// IMPORTANT: this must be a RichText, not a Text. StyleText styles have
  /// `inherit: true`, so a Text merges them over the ambient DefaultTextStyle
  /// (picking up its `height`/leading) while RichText does not. Using Text here
  /// makes the label a couple of pixels taller than the one CustomTextField
  /// draws, which pushes the phone boxes out of line with the email box.
  Widget _fieldLabel(String label) => RichText(
        text: TextSpan(
          text: label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );

  /// Label + country picker + number, laid out to fill whatever width it is
  /// given. The label is drawn here (rather than on one of the two fields) so
  /// the block starts at the same height as the email column beside it.
  ///
  /// [dialCodeWidth] pins the country-code box. In landscape the caller passes
  /// one full grid column so the code and the number land on columns 2 and 3 —
  /// every box in the card then shares the same three gridlines.
  Widget _buildPhoneField({double? dialCodeWidth}) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone =
        mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final currentCountryCode = selectedCountryCode ?? countryCode;

    final flag = PhoneCountryLookup.flagOf(currentCountryCode);
    final dialCode = PhoneCountryLookup.dialCodeOf(currentCountryCode);
    final displayDialCode =
        isArabic ? _convertToArabicDigits(dialCode) : dialCode;
    final flagAndCode = '$flag $displayDialCode';

    Future<void> pickCountry() async {
      final result = await showCountryPickerDialog(context);
      if (result != null) {
        setState(() {
          selectedCountryCode = result.dialCode;
          _trackChange(
            'country_code',
            mobilePhone?.countryCode?.lastOrNull,
            result.dialCode,
          );
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).phoneNumber),
        SizedBox(height: 6.h),
        Row(
          children: [
            // Country code — read-only, opens the picker on tap.
            // Keyed by the value so the internal controller refreshes when the
            // user picks a different country (no controller built in build()).
            SizedBox(
              width: dialCodeWidth ?? _dialCodeWidth,
              child: CustomTextField(
                height: _kFieldHeight,
                key: ValueKey('dial_code_$flagAndCode'),
                initialValue: flagAndCode,
                hint: flagAndCode,
                textDirection:
                    isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                readOnly: true,
                borderRadius: BorderRadius.circular(4.r),
                onTap: pickCountry,
              ),
            ),
            SizedBox(width: _gridGap),
            Expanded(
              child: CustomTextField(
                height: _kFieldHeight,
                hint: S.of(context).enterThePhoneNumber,
                controller: phoneController,
                textDirection: ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                keyboardType: TextInputType.phone,
                borderRadius: BorderRadius.circular(4.r),
                onChanged: (value) {
                  _trackChange('phone', mobilePhone?.phones?.lastOrNull, value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isPortrait, bool lightMode, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isPortrait
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhoneField(),
                SizedBox(height: 15.sp),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth = (constraints.maxWidth - _gridGap * 2) / 3;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CHANGED 24/8/2026: email used to hold column 1 with
                        // the phone block spanning columns 2 + 3. With email
                        // removed the phone block starts at the left gridline
                        // and keeps the same two-column span, so the dial code
                        // stays its own small fixed width and the number field
                        // takes the rest.
                        SizedBox(
                          width: columnWidth,
                          child: _buildPhoneField(),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                  ],
                );
              },
            ),
    );
  }

  String _convertToArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // ── Location dropdowns ────────────────────────────────────────────────────
  //
  // Country -> State/Governorate -> City, each one feeding the next.
  //
  // Countries come from `country_picker` (already a dependency), so every
  // country in the world is listed and the Arabic names are the package's own.
  // States and cities come from `assets/data/location_data.json`; a country with
  // no entry there simply has an empty state list, and the hint says so instead
  // of leaving the user tapping a dead control.

  Widget _buildCountryDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance.countries(context);

    return CustomDropdown<String>(
      height: _kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).country,
      hint: S.of(context).enterYourCountry,
      value: _selectedCountryIso,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) =>
              DropdownItem<String>(value: o.code, label: o.label(isArabic)))
          .toList(),
      onChanged: (iso) {
        final picked = options.firstWhere((o) => o.code == iso);
        setState(() {
          _selectedCountryIso = iso;
          countryController.text = picked.label(isArabic);

          // The cascade. A state and city chosen under the old country are
          // meaningless under the new one, so they are cleared — and their
          // entries are REMOVED from `changes` rather than recorded as an edit
          // to empty, which would submit a request to wipe the employee's
          // province and city.
          _selectedStateCode = null;
          provinceController.clear();
          cityController.clear();
          changes.remove('province');
          changes.remove('city');
        });

        _trackChange(
            'country', employee?.country?.lastOrNull, countryController.text);
      },
    );
  }

  Widget _buildProvinceDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance.statesOf(_selectedCountryIso);

    return CustomDropdown<String>(
      height: _kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).stateOrProvince,
      hint: _locationHint(
        hasCountry: _selectedCountryIso != null,
        isEmpty: options.isEmpty,
        fallback: S.of(context).enterYourStateOrProvince,
      ),
      value: _selectedStateCode,
      enabled: options.isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) =>
              DropdownItem<String>(value: o.code, label: o.label(isArabic)))
          .toList(),
      onChanged: (code) {
        final picked = options.firstWhere((o) => o.code == code);
        setState(() {
          _selectedStateCode = code;
          provinceController.text = picked.label(isArabic);
          cityController.clear();
          changes.remove('city');
        });

        _trackChange('province', employee?.province?.lastOrNull,
            provinceController.text);
      },
    );
  }

  Widget _buildCityDropdown() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = LocationDataService.instance
        .citiesOf(_selectedCountryIso, _selectedStateCode);

    // Cities carry no code in the data, so the dropdown's value IS the label.
    // That is also what goes into the controller, so no lookup is needed back.
    final current = cityController.text.trim();

    return CustomDropdown<String>(
      height: _kFieldHeight,
      enforceTypeScale: false,
      valueStyle: _kFieldValueStyle,
      label: S.of(context).city,
      hint: _locationHint(
        hasCountry: _selectedStateCode != null,
        isEmpty: options.isEmpty,
        fallback: S.of(context).enterYourCity,
      ),
      value: options.any((o) => o.label(isArabic) == current) ? current : null,
      enabled: options.isNotEmpty,
      borderRadius: BorderRadius.circular(4.r),
      items: options
          .map((o) => DropdownItem<String>(
                value: o.label(isArabic),
                label: o.label(isArabic),
              ))
          .toList(),
      onChanged: (label) {
        setState(() => cityController.text = label);
        _trackChange('city', employee?.city?.lastOrNull, label);
      },
    );
  }

  /// Tells the user WHY a dropdown is empty instead of showing a hint that
  /// promises options it does not have.
  String _locationHint({
    required bool hasCountry,
    required bool isEmpty,
    required String fallback,
  }) {
    if (!hasCountry) return S.of(context).country;
    if (isEmpty && _locationDataReady) return '—';
    return fallback;
  }

  Widget _buildLocationSection(bool isPortrait, bool lightMode, bool isTablet) {
    var isPhone = ContextExtension(context).isPhone;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPortrait) ...[
            _buildCountryDropdown(),
            SizedBox(height: 10.sp),
            _buildProvinceDropdown(),
            SizedBox(height: 10.sp),
            _buildCityDropdown(),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountryDropdown()),
                SizedBox(width: 12.sp),
                Expanded(child: _buildProvinceDropdown()),
                SizedBox(width: 12.sp),
                Expanded(child: _buildCityDropdown()),
              ],
            ),
          ],
          isPhone ? SizedBox(height: 16.h) : SizedBox(height: 16.h),
          CustomTextField(
            height: _kFieldHeight,
            label: S.of(context).streetName,
            hint: S.of(context).enterYourStreetAddress,
            controller: streetController,
            onChanged: (value) {
              _markFieldAsTouched('street');
              _trackChange(
                'street',
                employee?.street?.lastOrNull,
                value,
              );
            },
          ),
          isPhone ? SizedBox(height: 16.h) : SizedBox(),
        ],
      ),
    );
  }
}
