import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_views_mobile/subwidgets/indicator_screen_container.dart';

import 'package:knowticed_plus/core/custom/71-custom_appbar_mobile.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

// ignore: must_be_immutable
class EmployeeHealthInsuranceMobile extends StatefulWidget {
  EmployeeHealthInsuranceMobile({
    super.key,
    required this.value,
    required this.valueState,
    required  this.city,
    required this.country,
    required this.emailContact,
    required this.firstNameContact,
    required this.insuranceName,
    required this.lastNameContact,
    required this.phone,
    required this.policeNumber,
    required this.postalCode,
    required this.relation,
    required this.secondNameContact,
    required this.state,
    required this.street,
    this.emailContact2,
    this.firstNameContact2,
    this.lastNameContact2,
    this.relation2,
    this.secondNameContact2,
    this.state2,
    this.street2,
    this.city2,
    this.country2,
    this.hasSecond=false,
    this.hasSecondState,
    required this.phoneContact,
    this.phoneContact2,
    required this.postalCode2,
  });
  double value = 0;
  ValueChanged<double> valueState;
  TextEditingController insuranceName;
  TextEditingController phone;
  TextEditingController policeNumber;
  TextEditingController postalCode;
    TextEditingController postalCode2;
  TextEditingController firstNameContact;
  TextEditingController secondNameContact;
  TextEditingController lastNameContact;
  TextEditingController relation;
  TextEditingController city;
  TextEditingController street;
  TextEditingController state;
  TextEditingController country;
  TextEditingController emailContact;
  TextEditingController phoneContact;
  TextEditingController? phoneContact2;
   TextEditingController? firstNameContact2;
  TextEditingController? secondNameContact2;
  TextEditingController? lastNameContact2;
  TextEditingController? relation2;
  TextEditingController? city2;
  TextEditingController? street2;
  TextEditingController? state2;
  TextEditingController? country2;
  TextEditingController? emailContact2;

  bool hasSecond;
  ValueChanged<bool>? hasSecondState;

  @override
  State<EmployeeHealthInsuranceMobile> createState() =>
      _EmployeeHealthInsuranceMobileState();
}

class _EmployeeHealthInsuranceMobileState
    extends State<EmployeeHealthInsuranceMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBarMobile(
              showIcon: true,
              showMoreIcon: false,
              title: "Health Insurance",
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IndicatorContainerScreen(value: widget.value),
                  HealthInsuranceFields(
                    isNew: true,
                    city: widget.city,
                    emailContact: widget.emailContact,
                    phoneContact2:widget.phoneContact2 ,
                    phoneContact:widget.phoneContact ,
                    postalCode2:widget.postalCode2 ,
                    country: widget.country,
                    firstNameContact: widget.firstNameContact,
                    insuranceName: widget.insuranceName,
                    lastNameContact: widget.lastNameContact,
                    phone: widget.phone,
                    policeNumber: widget.policeNumber,
                    postalCode: widget.postalCode,
                    relation: widget.relation,
                    secondNameContact: widget.secondNameContact,
                    state: widget.state,
                    street: widget.street,
                    value: widget.value,
                    valueState: (value) {
                      setState(() {
                        widget.value = value;
                        widget.valueState(widget.value);
                      });
                    },
                    city2: widget.city2,
                    country2:widget.country2 ,
                    emailContact2:widget.emailContact2 ,
                    firstNameContact2:widget.firstNameContact2 ,
                    hasSecond:widget.hasSecond ,
                    hasSecondState:widget.hasSecondState ,
                    lastNameContact2:widget.lastNameContact2 ,
                    relation2: widget.relation2,
                    secondNameContact2: widget.secondNameContact2,
                    state2: widget.state2,
                    street2: widget.street2,
                  ),
                  SizedBox(
                    height: 0.04.h,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class HealthInsuranceFields extends StatefulWidget {
  HealthInsuranceFields(
      {super.key,
        this.isNew = false,
        this.city,
        this.country,
        this.firstNameContact,
        this.insuranceName,
        this.lastNameContact,
        this.phone,
        this.policeNumber,
        this.postalCode,
        this.relation,
        this.secondNameContact,
        this.state,
        this.street,
        this.value = 0,
        this.valueState,
        this.emailContact,
        this.city2,
        this.country2,
        this.emailContact2,
        this.firstNameContact2,
        this.lastNameContact2,
        this.relation2,
        this.secondNameContact2,
        this.state2,
        this.street2,
        this.hasSecond = false,
        this.hasSecondState,
        this.phoneContact,
        this.postalCode2,
        this.phoneContact2});
  final bool isNew;
  TextEditingController? insuranceName;
  TextEditingController? phone;
  TextEditingController? policeNumber;
  TextEditingController? postalCode;
  TextEditingController? firstNameContact;
  TextEditingController? secondNameContact;
  TextEditingController? lastNameContact;
  TextEditingController? relation;
  TextEditingController? city;
  TextEditingController? street;
  TextEditingController? state;
  TextEditingController? country;
  TextEditingController? emailContact;
  TextEditingController? phoneContact;
  TextEditingController? phoneContact2;
  TextEditingController? postalCode2;
  TextEditingController? firstNameContact2;
  TextEditingController? secondNameContact2;
  TextEditingController? lastNameContact2;
  TextEditingController? relation2;
  TextEditingController? city2;
  TextEditingController? street2;
  TextEditingController? state2;
  TextEditingController? country2;
  TextEditingController? emailContact2;
  double value;
  ValueChanged<double>? valueState;

  bool hasSecond;
  ValueChanged<bool>? hasSecondState;

  @override
  State<HealthInsuranceFields> createState() => _HealthInsuranceFieldsState();
}

class _HealthInsuranceFieldsState extends State<HealthInsuranceFields> {
  String? selectedContact;

  final List<String> contact = [];
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());
  String? _errorMessage;
  String? _errorMessageEmergency;
  String? _errorMessageEmergencySecond;
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    double heightSpacer = isPortrait ? 0.007.h : 0.013.h;
    double heightSpacerTextField = 0.003.h;
    double buttonHeight = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.04.h : 0.04.w)
        : 0.05.h;
    return /*SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: isTablet
                    ? isPortrait
                    ? 0.015.w
                    : 0.04.w
                    : 0.04.w,
                vertical: 0.01.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 0.01.h,
                  ),
                  child: SettingsHeader(
                    imagePath: 'assets/icons_assets/organization_chart_assets/newHealth.svg',
                    text: 'Health Insurance'.tr,
                  ),
                ),
                textfieled(
                  isReadOnly: false,
                  context,
                      (value) {
                    insuranceName2 = value.trim().toLowerCase();
                    addEmployeeController.employeePhone.insuranceName =
                        InsuranceName(
                            insuranceNames: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Insurance Name"
                            : "اسم التأمين غير صالح");
                  },
                  'Enter Insurance Name'.tr, // hintText
                  widget.isNew
                      ? null
                      : employee!.insuranceName?.insuranceNames?.lastOrNull,
                  null, // prefixIcon
                  controller: widget.isNew ? widget.insuranceName : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.insuranceName!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                ),
                SizedBox(
                  height: heightSpacerTextField,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: buttonHeight,
                      child: IntlPhoneField(
                        controller: widget.phone,
                        enabled: true,
                        // autovalidateMode: AutovalidateMode.always,
                        textAlign: Get.locale.toString().contains('ar')
                            ? TextAlign.start
                            : TextAlign.start,
                        pickerDialogStyle: PickerDialogStyle(
                            searchFieldInputDecoration: InputDecoration(
                              enabled: true,
                              hintText: 'search',
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.scrim,
                                    width: 1.0,
                                  )),
                              fillColor:
                              Theme.of(context).colorScheme.inversePrimary,
                              hintStyle: TextStyle(
                                fontSize: isPortrait
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize017.h,
                                fontWeight: FontWeight.w400,
                                color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                    ? Theme.of(context).colorScheme.scrim
                                    : AppColors.colorWhite,
                              ),
                            ),
                            width: .45.w,
                            backgroundColor: Colors.white,
                            countryCodeStyle: TextStyle(
                              fontSize: FontConstants.fontSize017.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                  AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            ),
                            countryNameStyle: TextStyle(
                              fontSize: FontConstants.fontSize017.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                  AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            )),
                        flagsButtonPadding: const EdgeInsets.only(left: 5),
                        showDropdownIcon: false,
                        disableLengthCheck: true,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isTablet
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize017.h,
                            color: themeController.currentTheme ==
                                AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400),
                        dropdownTextStyle: AppFontStyle.cairoRegularStyle
                            .copyWith(
                            fontSize: isTablet
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize017.h,
                            color: themeController.currentTheme ==
                                AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400,
                            height: isTablet ? 1.2 : 1.6),
                        decoration: InputDecoration(
                          filled: true,
                          // contentPadding: Get.locale.toString().contains('en')
                          //     ? const EdgeInsets.only(left: 10, top: 10)
                          //     : const EdgeInsets.only(right: 10, top: 10),
                          focusColor: const Color.fromRGBO(246, 246, 246, 1),
                          hoverColor: const Color.fromRGBO(246, 246, 246, 1),
                          hintText: 'Enter The Insurance Phone Number'.tr,
                          prefix: SizedBox(
                            height: isTablet ? (isPortrait ? 22 : 13) : 32,
                          ),
                          errorStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: isPortrait
                                  ? FontConstants.fontSize012.h
                                  : FontConstants.fontSize014.h,
                              color: AppColors.colorRed,
                              fontWeight: FontWeight.w400),
                          hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: orientation == Orientation.portrait
                                  ? isTablet
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize017.h
                                  : FontConstants.fontSize020.h,
                              color: AppColors.colorGrey,
                              fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor: themeController.currentTheme ==
                              AppColors.lightTheme
                              ? const Color(0xFFF6F6F6)
                              : AppColors.colorBlack,
                        ),
                        onCountryChanged: (value) {},
                        initialCountryCode: employee!.insurancePhoneNumber
                            ?.countryCode?.lastOrNull ??
                            "EG",
                        initialValue: widget.isNew
                            ? ""
                            : employee!.insurancePhoneNumber
                            ?.insurancePhoneNumber?.lastOrNull,
                        onChanged: (value) {
                          setState(() {
                            _errorMessage =
                                Validator.number(value.completeNumber);
                          });

                          addEmployeeController
                              .employeePhone.insurancePhoneNumber =
                              InsurancePhoneNumber(
                                  insurancePhoneNumber: [value.number],
                                  countryApp: [value.countryCode],
                                  countryCode: [value.countryISOCode],
                                  timestamps: [Timestamp.now()]);
                        },
                        // validator: (value) {
                        //   return Validator.number(value!.completeNumber);
                        // },
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: orientation == Orientation.portrait
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize018.h,
                            color: AppColors.delete,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: heightSpacerTextField,
                ),
                textfieled(
                  isReadOnly: false,
                  context,
                      (value) {
                    insurancePolice2 = value.trim();
                    addEmployeeController.employeePhone.insurancePoliceNumber =
                        InsurancePoliceNumber(
                            insurancePoliceNumber: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.insurancePolicyNumber(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Insurance Police Number"
                            : "رقم بوليصة التأمين غير صالحة");
                  },
                  'Enter Insurance Police Number'.tr, // hintText
                  widget.isNew
                      ? null
                      : employee!.insurancePoliceNumber?.insurancePoliceNumber
                      ?.lastOrNull,
                  null, // prefixIcon
                  controller: widget.isNew ? widget.policeNumber : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.policeNumber!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                ),
                *//*
                textfieled(
                  isReadOnly: false,
                  context,
                  (value) {
                    insurancePolice2 = value.trim();
                  },
                  (value) {
                    return Validator.zipCode(
                      value,
                    );
                  },
                  'Enter Postal Code'.tr, // hintText
                  null,
                  null, // prefixIcon
                  controller: widget.isNew ? widget.postalCode : null,
                  onFinish: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.postalCode!.text = value;
                            widget.value += (1 / 13);
                            widget.valueState!(widget.value);
                          });
                        }
                      : null,
                ),
                *//*
              ],
            ),
          ),

          // textfieled(
          //   isReadOnly: false,
          //   context,
          //   (value) {
          //     insurancePhone2 = value.trim();
          //   },
          //   (value) {
          //     return Validator.number(
          //       value,
          //     );
          //   },
          //   'Enter Insurance Phone Number'.tr, // hintText
          //   employee!.insurancePhoneNumber?.insurancePhoneNumber?.lastOrNull,
          //   null, // prefixIcon
          //   controller: null,
          // ),
          SizedBox(
            height: isTablet
                ? isPortrait
                ? 0
                : 0.02.h
                : 0.02.h,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: isTablet
                    ? isPortrait
                    ? 0.015.w
                    : 0.04.w
                    : 0.04.w,
                vertical: 0.01.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.01.h),
                  child: SettingsHeader(
                    imagePath: 'assets/icons_assets/organization_chart_assets/newEmergency.svg',
                    text: 'Emergency Contact Information'.tr,
                  ),
                ),
                textfieled(
                  context,
                      (value) {
                    connectionName2 = value.trim().toLowerCase();
                    addEmployeeController.employeePhone.contactFirstName =
                        ContactFirstName(
                            contactFirstName: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid First Name"
                          : "الاسم الأول غير صالح",
                    );
                  },
                  'Enter First Name'.tr, // hintText
                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactFirstName?.contactFirstName?.lastOrNull}'),
                  null, // prefixIcon
                  controller: widget.isNew ? widget.firstNameContact : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.firstNameContact!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),

                textfieled(
                  context,
                      (value) {
                    connectionMiddleName2 = value.trim().toLowerCase();
                    addEmployeeController.employeePhone.contactMiddleName =
                        ContactMiddleName(
                            contactMiddleName: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.name(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Middle Name"
                            : "اسم الاوسط غير صالح");
                  },
                  'Enter Middle Name'.tr, // hintText

                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactMiddleName?.contactMiddleName?.lastOrNull}'),
                  null,
                  controller: widget.isNew ? widget.secondNameContact : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.secondNameContact!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),
                textfieled(
                  context,
                      (value) {
                    connectionLastName2 = value.trim().toLowerCase();
                    addEmployeeController.employeePhone.contactLastName =
                        ContactLastName(
                            contactLastName: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.name(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Last Name"
                            : "اسم العائلة غير صالح");
                  },
                  'Enter Last Name'.tr, // hintText
                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactLastName?.contactLastName?.lastOrNull}'),
                  null, // prefixIcon
                  controller: widget.isNew ? widget.lastNameContact : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.lastNameContact!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),
                textfieled(
                  context,
                      (value) {
                    connecntionRelation2 = value.trim().toLowerCase();
                    addEmployeeController.employeePhone.contactRelation =
                        ContactRelation(
                            contactRelation: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Name"
                          : "الاسم غير صالح",
                    );
                  },
                  'Enter Contact Relation'.tr, // hintText
                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactRelation?.contactRelation?.lastOrNull}'),
                  //  null,
                  null, // prefixIcon
                  controller: widget.isNew ? widget.relation : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.relation!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),
                textfieled(
                  context,
                      (value) {
                    addEmployeeController.employeePhone.contactPostalCode =
                        ContactPostalCode(
                            contactPostalCode: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.postalCode(
                      value,
                    );
                  },
                  'Enter The Postal Code'.tr, // hintText
                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactPostalCode?.contactPostalCode?.lastOrNull}'),
                  null, // prefixIcon
                  controller: widget.postalCode,
                  isReadOnly: false,
                ),
                SizedBox(
                  height: heightSpacerTextField,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: buttonHeight,
                      child: IntlPhoneField(
                        controller: widget.phoneContact,
                        // autovalidateMode: AutovalidateMode.always,
                        textAlign: Get.locale.toString().contains('ar')
                            ? TextAlign.start
                            : TextAlign.start,
                        enabled: true,
                        pickerDialogStyle: PickerDialogStyle(
                            searchFieldInputDecoration: InputDecoration(
                              enabled: true,
                              hintText: 'search',
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.scrim,
                                    width: 1.0,
                                  )),
                              fillColor:
                              Theme.of(context).colorScheme.inversePrimary,
                              errorStyle: AppFontStyle.cairoRegularStyle
                                  .copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize012.h
                                      : FontConstants.fontSize014.h,
                                  color: AppColors.colorRed,
                                  fontWeight: FontWeight.w400),
                              hintStyle: TextStyle(
                                fontSize: isPortrait
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize017.h,
                                fontWeight: FontWeight.w400,
                                color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                    ? Theme.of(context).colorScheme.scrim
                                    : AppColors.colorWhite,
                              ),
                            ),
                            width: .45.w,
                            backgroundColor: Colors.white,
                            countryCodeStyle: TextStyle(
                              fontSize: FontConstants.fontSize017.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                  AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            ),
                            countryNameStyle: TextStyle(
                              fontSize: FontConstants.fontSize017.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                  AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            )),
                        flagsButtonPadding: const EdgeInsets.only(left: 5),
                        showDropdownIcon: false,
                        disableLengthCheck: true,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isTablet
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize017.h,
                            color: themeController.currentTheme ==
                                AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400),
                        dropdownTextStyle: AppFontStyle.cairoRegularStyle
                            .copyWith(
                            fontSize: isTablet
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize017.h,
                            color: themeController.currentTheme ==
                                AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400,
                            height: isTablet ? 1.2 : 1.6),
                        decoration: InputDecoration(
                          filled: true,
                          // contentPadding: Get.locale.toString().contains('en')
                          //     ? const EdgeInsets.only(left: 10, top: 0)
                          //     : const EdgeInsets.only(right: 10, top: 0),
                          focusColor: const Color.fromRGBO(246, 246, 246, 1),
                          hoverColor: const Color.fromRGBO(246, 246, 246, 1),
                          hintText: 'Enter The Phone Number'.tr,
                          prefix: SizedBox(
                            height: isTablet ? (isPortrait ? 22 : 13) : 31,
                          ),
                          hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: orientation == Orientation.portrait
                                  ? isTablet
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize017.h
                                  : FontConstants.fontSize020.h,
                              color: AppColors.colorGrey,
                              fontWeight: FontWeight.w400),
                          errorStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: isPortrait
                                  ? FontConstants.fontSize012.h
                                  : FontConstants.fontSize014.h,
                              color: AppColors.colorRed,
                              fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor: themeController.currentTheme ==
                              AppColors.lightTheme
                              ? const Color(0xFFF6F6F6)
                              : AppColors.colorBlack,
                        ),
                        onCountryChanged: (value) {},
                        initialCountryCode:
                        employee!.contactNumber?.countryCode?.lastOrNull ??
                            "EG",
                        initialValue: widget.isNew
                            ? ""
                            : employee!
                            .contactNumber?.contactNumber?.lastOrNull,
                        onChanged: (value) {
                          setState(() {
                            _errorMessageEmergency =
                                Validator.number(value.completeNumber);
                          });

                          connecntionPhone2 = value;
                          phone2 = value;
                          addEmployeeController.employeePhone.contactNumber =
                              ContactNumber(
                                  contactNumber: [value.number],
                                  countryApp: [value.countryCode],
                                  countryCode: [value.countryISOCode],
                                  timestamps: [Timestamp.now()]);
                        },
                        // validator: (value) {
                        //   return Validator.number(value!.completeNumber);
                        // },
                      ),
                    ),
                    if (_errorMessageEmergency != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessageEmergency!,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: orientation == Orientation.portrait
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize018.h,
                            color: AppColors.delete,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: heightSpacerTextField,
                ),
                textfieled(
                  context,
                      (value) {
                    connecntionEmail2 = value.trim();
                    addEmployeeController.employeePhone.contactEmail =
                        ContactEmail(
                            contactEmail: [value],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.email(value);
                  },
                  'Enter The Email'.tr, // hintText
                  widget.isNew
                      ? null
                      : '${employee!.contactEmail?.contactEmail?.lastOrNull}',
                  null, // prefixIcon
                  controller: widget.isNew ? widget.emailContact : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.emailContact!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),
                Stack(
                  children: [
                    textfieled(
                      context,
                          (value) async {
                        connecntionCountry2 = value.toLowerCase();
                        addEmployeeController.employeePhone.contactCountry =
                            ContactCountry(
                                contactCountry: [value.toLowerCase()],
                                timestamps: [Timestamp.now()]);
                      },
                          (value) {
                        return Validator.text(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid Country"
                                : "عنوان الدولة غير صحيح");
                      },
                      'Enter The Country'.tr,
                      // (address != null
                      //         ? address!.country
                      //         : widget.userProfile.country!.countries!
                      //                     .lastOrNull !=
                      //                 null
                      //             ? capitalize(
                      //                 '${widget.userProfile.country!.countries!.lastOrNull}')
                      //             : widget.userProfile.country!.countries!
                      //                 .lastOrNull) ??
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.contactCountry?.contactCountry?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.isNew ? widget.country : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.country!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                  ],
                ),
                Stack(
                  children: [
                    // textfieled(
                    //   context,
                    //   (value) async {
                    //     connecntionCity2 = value.toLowerCase();
                    //   },
                    //   (value) {
                    //     return Validator.text(
                    //         value,
                    //         Get.locale.toString().contains('en')
                    //             ? "Invalid City"
                    //             : "عنوان المدينة غير صحيح");
                    //   },
                    //   'Enter The City'.tr,

                    //   widget.isNew
                    //       ? null
                    //       : capitalize(
                    //           '${employee!.contactCity?.contactCity?.lastOrNull}'),
                    //   null, // prefixIcon
                    //   controller: widget.isNew ? widget.city : null,
                    //   onFinish: widget.isNew
                    //       ? (value) {
                    //           setState(() {
                    //             widget.city!.text = value;
                    //             widget.value += (1 / 13);
                    //             widget.valueState!(widget.value);
                    //           });
                    //         }
                    //       : null,
                    //   isReadOnly: false,
                    // ),
                    textfieled(
                      context,
                          (value) async {
                        connecntionProvince2 = value.toLowerCase();
                        addEmployeeController.employeePhone.contactProvince =
                            ContactProvince(
                                contactProvince: [value.toLowerCase()],
                                timestamps: [Timestamp.now()]);
                      },
                          (value) {
                        return Validator.text(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid Province"
                                : "عنوان الحي غير صحيح");
                      },
                      'Enter The State Or Province'.tr,

                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.contactProvince?.contactProvince?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.isNew ? widget.state : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.policeNumber!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                  ],
                ),
                Stack(
                  children: [
                    textfieled(
                      context,
                          (value) async {
                        connecntionCity2 = value.toLowerCase();
                        addEmployeeController.employeePhone.contactCity =
                            ContactCity(
                                contactCity: [value.toLowerCase()],
                                timestamps: [Timestamp.now()]);
                      },
                          (value) {
                        return Validator.text(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid City"
                                : "عنوان المدينة غير صحيح");
                      },
                      'Enter The City'.tr,

                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.contactCity?.contactCity?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.isNew ? widget.city : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.city!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                  ],
                ),
                textfieled(
                  context,
                      (value) {
                    connecntionAddress2 = value.toLowerCase();
                    addEmployeeController.employeePhone.contactAddress =
                        ContactAddress(
                            contactAddress: [value.toLowerCase()],
                            timestamps: [Timestamp.now()]);
                  },
                      (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Street Address"
                            : "عنوان الشارع غير صحيح");
                  },
                  'Enter The Street Address'.tr, // hintText
                  widget.isNew
                      ? null
                      : capitalize(
                      '${employee!.contactAddress?.contactAddress?.lastOrNull}'),
                  null, // prefixIcon
                  controller: widget.isNew ? widget.street : null,
                  onFinish: widget.isNew
                      ? (value) {
                    setState(() {
                      widget.street!.text = value;
                      widget.value += (1 / 13);
                      widget.valueState!(widget.value);
                    });
                  }
                      : null,
                  isReadOnly: false,
                ),

                // Second Contact

                widget.isNew
                    ? widget.hasSecond
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.02.h),
                      child: Text(
                        "Second Contact Data".tr,
                        style: AppFontStyle.cairoRegularStyle
                            .copyWith(
                            fontSize: FontConstants.fontSize016.h,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .inverseSurface),
                      ),
                    ),
                    textfieled(
                      context,
                          (value) {
                        addEmployeeController.employeePhone
                            .secondContactFirstName =
                            SecondContactFirstName(
                                secondContactFirstName: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.name(
                          value,
                          Get.locale.toString().contains('en')
                              ? "Invalid First Name"
                              : "الاسم الأول غير صالح",
                        );
                      },
                      'Enter First Name'.tr, // hintText
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactFirstName?.secondContactFirstName?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.isNew
                          ? widget.firstNameContact2
                          : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.firstNameContact2!.text =
                              value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                    textfieled(
                      context,
                          (value) {
                        addEmployeeController.employeePhone
                            .secondContactMiddleName =
                            SecondContactMiddleName(
                                secondContactMiddleName: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.name(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid Middle Name"
                                : "اسم الاوسط غير صالح");
                      },
                      'Enter Middle Name'.tr, // hintText

                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactMiddleName?.secondContactMiddleName?.lastOrNull}'),
                      null,
                      controller: widget.isNew
                          ? widget.secondNameContact2
                          : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.secondNameContact2!.text =
                              value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                    textfieled(
                      context,
                          (value) {
                        addEmployeeController
                            .employeePhone.secondContactLastName =
                            SecondContactLastName(
                                secondContactLastName: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.name(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid Last Name"
                                : "اسم العائلة غير صالح");
                      },
                      'Enter Last Name'.tr, // hintText
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactLastName?.secondContactLastName?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.isNew
                          ? widget.lastNameContact2
                          : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.lastNameContact2!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                    textfieled(
                      context,
                          (value) {
                        addEmployeeController
                            .employeePhone.secondContactRelation =
                            SecondContactRelation(
                                secondContactRelation: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.name(
                          value,
                          Get.locale.toString().contains('en')
                              ? "Invalid Name"
                              : "الاسم غير صالح",
                        );
                      },
                      'Enter Contact Relation'.tr, // hintText
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactRelation?.secondContactRelation?.lastOrNull}'),
                      //  null,
                      null, // prefixIcon
                      controller:
                      widget.isNew ? widget.relation2 : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.relation2!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                    textfieled(
                      context,
                          (value) {
                        addEmployeeController.employeePhone
                            .secondContactPostalCode =
                            SecondContactPostalCode(
                                secondContactPostalCode: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.postalCode(
                          value,
                        );
                      },
                      'Enter The Postal Code'.tr, // hintText
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactPostalCode?.secondContactPostalCode?.lastOrNull}'),
                      null, // prefixIcon
                      controller: widget.postalCode2,
                      isReadOnly: false,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 0.005.h : 0.007.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: isTablet ? null : 0.05.h,
                            child: IntlPhoneField(
                              controller: widget.phoneContact2,
                              // autovalidateMode: AutovalidateMode.always,
                              textAlign:
                              Get.locale.toString().contains('ar')
                                  ? TextAlign.start
                                  : TextAlign.start,
                              pickerDialogStyle: PickerDialogStyle(
                                  searchFieldInputDecoration:
                                  InputDecoration(
                                    enabled: true,
                                    hintText: 'search',
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .scrim,
                                          width: 1.0,
                                        )),
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    errorStyle: AppFontStyle
                                        .cairoRegularStyle
                                        .copyWith(
                                        fontSize: isPortrait
                                            ? FontConstants
                                            .fontSize012.h
                                            : FontConstants
                                            .fontSize014.h,
                                        color:
                                        AppColors.colorRed,
                                        fontWeight:
                                        FontWeight.w400),
                                    hintStyle: TextStyle(
                                      fontSize: isPortrait
                                          ? FontConstants
                                          .fontSize014.h
                                          : FontConstants
                                          .fontSize017.h,
                                      fontWeight: FontWeight.w400,
                                      color: themeController
                                          .currentTheme ==
                                          AppColors.lightTheme
                                          ? Theme.of(context)
                                          .colorScheme
                                          .scrim
                                          : AppColors.colorWhite,
                                    ),
                                  ),
                                  width: .45.w,
                                  backgroundColor: Colors.white,
                                  countryCodeStyle: TextStyle(
                                    fontSize:
                                    FontConstants.fontSize017.h,
                                    fontWeight: FontWeight.w400,
                                    color: themeController
                                        .currentTheme ==
                                        AppColors.lightTheme
                                        ? AppColors.colorBlack
                                        : AppColors.colorWhite,
                                  ),
                                  countryNameStyle: TextStyle(
                                    fontSize:
                                    FontConstants.fontSize017.h,
                                    fontWeight: FontWeight.w400,
                                    color: themeController
                                        .currentTheme ==
                                        AppColors.lightTheme
                                        ? AppColors.colorBlack
                                        : AppColors.colorWhite,
                                  )),
                              flagsButtonPadding:
                              const EdgeInsets.only(left: 5),
                              showDropdownIcon: false,
                              disableLengthCheck: true,
                              style: AppFontStyle.cairoRegularStyle
                                  .copyWith(
                                  fontSize:
                                  FontConstants.fontSize017.h,
                                  color: themeController
                                      .currentTheme ==
                                      AppColors.lightTheme
                                      ? AppColors.colorBlack
                                      : AppColors.colorWhite,
                                  fontWeight: FontWeight.w400),
                              dropdownTextStyle: AppFontStyle
                                  .cairoRegularStyle
                                  .copyWith(
                                  fontSize:
                                  FontConstants.fontSize017.h,
                                  color: themeController
                                      .currentTheme ==
                                      AppColors.lightTheme
                                      ? AppColors.colorBlack
                                      : AppColors.colorWhite,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2),
                              decoration: InputDecoration(
                                filled: true,
                                contentPadding: Get.locale
                                    .toString()
                                    .contains('en')
                                    ? const EdgeInsets.only(
                                    left: 10, top: 0)
                                    : const EdgeInsets.only(
                                    right: 10, top: 0),
                                focusColor: const Color.fromRGBO(
                                    246, 246, 246, 1),
                                hoverColor: const Color.fromRGBO(
                                    246, 246, 246, 1),
                                hintText: 'Enter The Phone Number'.tr,
                                prefix: const SizedBox(
                                  height: 11,
                                ),
                                hintStyle: AppFontStyle
                                    .cairoRegularStyle
                                    .copyWith(
                                    fontSize: orientation ==
                                        Orientation.portrait
                                        ? isTablet
                                        ? FontConstants
                                        .fontSize014.h
                                        : FontConstants
                                        .fontSize017.h
                                        : FontConstants
                                        .fontSize020.h,
                                    color: AppColors.colorGrey,
                                    fontWeight: FontWeight.w400),
                                errorStyle: AppFontStyle
                                    .cairoRegularStyle
                                    .copyWith(
                                    fontSize: isPortrait
                                        ? FontConstants
                                        .fontSize012.h
                                        : FontConstants
                                        .fontSize014.h,
                                    color: AppColors.colorRed,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1.0),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                fillColor:
                                themeController.currentTheme ==
                                    AppColors.lightTheme
                                    ? const Color(0xFFF6F6F6)
                                    : const Color(0xFF545454),
                              ),
                              onCountryChanged: (value) {},
                              initialCountryCode: employee!
                                  .contactNumber
                                  ?.countryCode
                                  ?.lastOrNull ??
                                  "EG",
                              initialValue: widget.isNew
                                  ? ""
                                  : employee!.contactNumber
                                  ?.contactNumber?.lastOrNull,
                              onChanged: (value) {
                                setState(() {
                                  _errorMessageEmergencySecond =
                                      Validator.number(
                                          value.completeNumber);
                                });
                                phone2 = value;
                                addEmployeeController.employeePhone
                                    .secondContactNumber =
                                    SecondContactNumber(
                                        secondContactNumber: [
                                          value.number
                                        ],
                                        countryApp: [
                                          value.countryCode
                                        ],
                                        countryCode: [
                                          value.countryISOCode
                                        ],
                                        timestamps: [
                                          Timestamp.now()
                                        ]);
                              },
                              // validator: (value) {
                              //   return Validator.number(value!.completeNumber);
                              // },
                            ),
                          ),
                          if (_errorMessageEmergencySecond != null)
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _errorMessageEmergencySecond!,
                                style: AppFontStyle.cairoRegularStyle
                                    .copyWith(
                                  fontSize: orientation ==
                                      Orientation.portrait
                                      ? FontConstants.fontSize014.h
                                      : FontConstants.fontSize018.h,
                                  color: AppColors.delete,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    textfieled(
                      context,
                          (value) {
                        connecntionEmail2 = value.trim();
                        addEmployeeController
                            .employeePhone.secondContactEmail =
                            SecondContactEmail(
                                secondContactEmail: [value],
                                timestamps: [Timestamp.now()]);
                      },
                          (value) {
                        return Validator.email(value);
                      },
                      'Enter The Email'.tr, // hintText
                      widget.isNew
                          ? null
                          : '${employee!.secondContactEmail?.secondContactEmail?.lastOrNull}',
                      null, // prefixIcon
                      controller:
                      widget.isNew ? widget.emailContact2 : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.emailContact2!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                    Stack(
                      children: [
                        textfieled(
                          context,
                              (value) async {
                            addEmployeeController.employeePhone
                                .secondContactCountry =
                                SecondContactCountry(
                                    secondContactCountry: [value],
                                    timestamps: [Timestamp.now()]);
                          },
                              (value) {
                            return Validator.text(
                                value,
                                Get.locale.toString().contains('en')
                                    ? "Invalid Country"
                                    : "عنوان الدولة غير صحيح");
                          },
                          'Enter The Country'.tr,
                          // (address != null
                          //         ? address!.country
                          //         : widget.userProfile.country!.countries!
                          //                     .lastOrNull !=
                          //                 null
                          //             ? capitalize(
                          //                 '${widget.userProfile.country!.countries!.lastOrNull}')
                          //             : widget.userProfile.country!.countries!
                          //                 .lastOrNull) ??
                          widget.isNew
                              ? null
                              : capitalize(
                              '${employee!.secondContactCountry?.secondContactCountry?.lastOrNull}'),
                          null, // prefixIcon
                          controller:
                          widget.isNew ? widget.country2 : null,
                          onFinish: widget.isNew
                              ? (value) {
                            setState(() {
                              widget.country2!.text = value;
                              widget.value += (1 / 13);
                              widget.valueState!(widget.value);
                            });
                          }
                              : null,
                          isReadOnly: false,
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        // textfieled(
                        //   context,
                        //   (value) async {},
                        //   (value) {
                        //     return Validator.text(
                        //         value,
                        //         Get.locale.toString().contains('en')
                        //             ? "Invalid City"
                        //             : "عنوان المدينة غير صحيح");
                        //   },
                        //   'Enter The City'.tr,

                        //   widget.isNew
                        //       ? null
                        //       : capitalize(
                        //           '${employee!.contactCity?.contactCity?.lastOrNull}'),
                        //   null, // prefixIcon
                        //   controller:
                        //       widget.isNew ? widget.city2 : null,
                        //   onFinish: widget.isNew
                        //       ? (value) {
                        //           setState(() {
                        //             widget.city2!.text = value;
                        //             widget.value += (1 / 13);
                        //             widget.valueState!(widget.value);
                        //           });
                        //         }
                        //       : null,
                        //   isReadOnly: false,
                        // ),
                        textfieled(
                          context,
                              (value) async {
                            addEmployeeController.employeePhone
                                .secondContactProvince =
                                SecondContactProvince(
                                    secondContactProvince: [
                                      value.toLowerCase()
                                    ],
                                    timestamps: [
                                      Timestamp.now()
                                    ]);
                          },
                              (value) {
                            return Validator.text(
                                value,
                                Get.locale.toString().contains('en')
                                    ? "Invalid Province"
                                    : "عنوان الحي غير صحيح");
                          },
                          'Enter The State Or Province'.tr,

                          widget.isNew
                              ? null
                              : capitalize(
                              '${employee!.secondContactProvince?.secondContactProvince?.lastOrNull}'),
                          null, // prefixIcon
                          controller:
                          widget.isNew ? widget.state2 : null,
                          onFinish: widget.isNew
                              ? (value) {
                            setState(() {
                              widget.state2!.text = value;
                              widget.value += (1 / 13);
                              widget.valueState!(widget.value);
                            });
                          }
                              : null,
                          isReadOnly: false,
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        textfieled(
                          context,
                              (value) async {
                            addEmployeeController
                                .employeePhone.secondContactCity =
                                SecondContactCity(secondContactCity: [
                                  value.toLowerCase()
                                ], timestamps: [
                                  Timestamp.now()
                                ]);
                          },
                              (value) {
                            return Validator.text(
                                value,
                                Get.locale.toString().contains('en')
                                    ? "Invalid City"
                                    : "عنوان المدينة غير صحيح");
                          },
                          'Enter The City'.tr,

                          widget.isNew
                              ? null
                              : capitalize(
                              '${employee!.secondContactCity?.secondContactCity?.lastOrNull}'),
                          null, // prefixIcon
                          controller:
                          widget.isNew ? widget.city2 : null,
                          onFinish: widget.isNew
                              ? (value) {
                            setState(() {
                              widget.city2!.text = value;
                              widget.value += (1 / 13);
                              widget.valueState!(widget.value);
                            });
                          }
                              : null,
                          isReadOnly: false,
                        ),
                      ],
                    ),
                    textfieled(
                      context,
                          (value) {
                        connecntionAddress2 = value.toLowerCase();
                        addEmployeeController
                            .employeePhone.secondContactAddress =
                            SecondContactAddress(
                                secondContactAddress: [
                                  value.toLowerCase()
                                ],
                                timestamps: [
                                  Timestamp.now()
                                ]);
                      },
                          (value) {
                        return Validator.text(
                            value,
                            Get.locale.toString().contains('en')
                                ? "Invalid Street Address"
                                : "عنوان الشارع غير صحيح");
                      },
                      'Enter The Street Address'.tr, // hintText
                      widget.isNew
                          ? null
                          : capitalize(
                          '${employee!.secondContactAddress?.secondContactAddress?.lastOrNull}'),
                      null, // prefixIcon
                      controller:
                      widget.isNew ? widget.street2 : null,
                      onFinish: widget.isNew
                          ? (value) {
                        setState(() {
                          widget.street2!.text = value;
                          widget.value += (1 / 13);
                          widget.valueState!(widget.value);
                        });
                      }
                          : null,
                      isReadOnly: false,
                    ),
                  ],
                )
                    : const SizedBox.shrink()
                    : const SizedBox.shrink(),
                widget.isNew
                    ? widget.hasSecond
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: EdgeInsets.only(top: 0.02.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.hasSecond = true;

                            widget.hasSecondState!(widget.hasSecond);
                          });
                        },
                        buttonText: "Add Contact".tr,
                        fontSize: FontConstants.fontSize014.h,
                        textColor: AppColors.colorWhite,
                        buttonStyle: ElevatedButton.styleFrom(
                          minimumSize: Size(0.1.w, 0.04.h),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              )),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
                SizedBox(
                  height: 0.01.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );*/Container();
  }
}
