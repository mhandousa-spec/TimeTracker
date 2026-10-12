/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_information_fields.dart
/// Purpose: The company-information form fields, bound to CompanyCubit state.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N25: added the standard header.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class CompanyInformationFields extends StatefulWidget {
  const CompanyInformationFields({super.key});

  @override
  State<CompanyInformationFields> createState() => _CompanyInformationFieldsState();
}

class _CompanyInformationFieldsState extends State<CompanyInformationFields> {
  bool submitted = false;

  // Controllers for all fields
  late TextEditingController companyNameController;
  late TextEditingController taxNumberController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController industryController;
  late TextEditingController companySizeController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  // Text direction states for each field
  TextDirection companyNameDirection = TextDirection.ltr;
  TextDirection countryDirection = TextDirection.ltr;
  TextDirection provinceDirection = TextDirection.ltr;
  TextDirection cityDirection = TextDirection.ltr;
  TextDirection streetDirection = TextDirection.ltr;
  TextDirection industryDirection = TextDirection.ltr;
  TextDirection firstNameDirection = TextDirection.ltr;
  TextDirection lastNameDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    // Seed from whatever the cubit already has. The company may still be
    // loading on first build, so _syncFromState() below refreshes these when
    // it arrives (every field here is read-only, so there is no user input to
    // clobber).
    final state = context.read<CompanyCubit>().state;
    // Initialize controllers with existing data
    companyNameController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.companyName?.companyName?.lastOrNull ?? '')
    );
    taxNumberController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.taxNumber?.taxNumber?.lastOrNull ?? '')
    );
    countryController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.country?.country?.lastOrNull ?? '')
    );
    provinceController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.province?.province?.lastOrNull ?? '')
    );
    cityController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.city?.city?.lastOrNull ?? '')
    );
    streetController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.companyAddress?.address?.lastOrNull ?? '')
    );
    industryController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.companyIndustry?.companyIndustry?.lastOrNull ?? '')
    );
    companySizeController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.companySize?.companySize?.lastOrNull ?? '')
    );
    firstNameController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.firstName?.firstNames?.lastOrNull ?? '')
    );
    lastNameController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.lastName?.lastNames?.lastOrNull ?? '')
    );
    emailController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.email?.emails?.lastOrNull ?? '')
    );
    phoneNumberController = TextEditingController(
        text: FormatHelper.capitalize(state.company?.phone?.phones?.lastOrNull ?? '')
    );

    // Set initial text directions based on content
    companyNameDirection = _detectTextDirection(companyNameController.text);
    countryDirection = _detectTextDirection(countryController.text);
    provinceDirection = _detectTextDirection(provinceController.text);
    cityDirection = _detectTextDirection(cityController.text);
    streetDirection = _detectTextDirection(streetController.text);
    industryDirection = _detectTextDirection(industryController.text);
    firstNameDirection = _detectTextDirection(firstNameController.text);
    lastNameDirection = _detectTextDirection(lastNameController.text);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    taxNumberController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    industryController.dispose();
    companySizeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  /// Detects if text contains Arabic characters
  bool _containsArabic(String text) {
    if (text.isEmpty) return false;
    // Arabic Unicode range: U+0600 to U+06FF
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }

  /// Detects text direction based on content
  /// Returns RTL if contains Arabic, LTR otherwise
  TextDirection _detectTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    return _containsArabic(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Re-seeds the read-only controllers when the company finishes loading.
  void _syncFromState(CompanyState state) {
    companyNameController.text = FormatHelper.capitalize(state.company?.companyName?.companyName?.lastOrNull ?? '');
    taxNumberController.text = FormatHelper.capitalize(state.company?.taxNumber?.taxNumber?.lastOrNull ?? '');
    countryController.text = FormatHelper.capitalize(state.company?.country?.country?.lastOrNull ?? '');
    provinceController.text = FormatHelper.capitalize(state.company?.province?.province?.lastOrNull ?? '');
    cityController.text = FormatHelper.capitalize(state.company?.city?.city?.lastOrNull ?? '');
    streetController.text = FormatHelper.capitalize(state.company?.companyAddress?.address?.lastOrNull ?? '');
    industryController.text = FormatHelper.capitalize(state.company?.companyIndustry?.companyIndustry?.lastOrNull ?? '');
    companySizeController.text = FormatHelper.capitalize(state.company?.companySize?.companySize?.lastOrNull ?? '');
    firstNameController.text = FormatHelper.capitalize(state.company?.firstName?.firstNames?.lastOrNull ?? '');
    lastNameController.text = FormatHelper.capitalize(state.company?.lastName?.lastNames?.lastOrNull ?? '');
    emailController.text = FormatHelper.capitalize(state.company?.email?.emails?.lastOrNull ?? '');
    phoneNumberController.text = FormatHelper.capitalize(state.company?.phone?.phones?.lastOrNull ?? '');

    companyNameDirection = _detectTextDirection(companyNameController.text);
    countryDirection = _detectTextDirection(countryController.text);
    provinceDirection = _detectTextDirection(provinceController.text);
    cityDirection = _detectTextDirection(cityController.text);
    streetDirection = _detectTextDirection(streetController.text);
    industryDirection = _detectTextDirection(industryController.text);
    firstNameDirection = _detectTextDirection(firstNameController.text);
    lastNameDirection = _detectTextDirection(lastNameController.text);
  }

  /// One block of fields under its own heading.
  ///
  /// ADDED 8/9/2026. Company / Service / Contact used to be three runs of
  /// widgets inside one long Column painted by a single card, so on a phone the
  /// page was one tall slab and the section headings were the only thing
  /// separating them.
  ///
  /// On a phone each block is now its own rounded card, which is how
  /// `se1_profile` builds the personal page: `PersonalInformationFields` drops
  /// its own decoration on a phone and lets PersonalData / ContactInformation /
  /// LocationData each draw a card, separated by 15.sp. The gaps here are the
  /// `SizedBox(height: 15.sp)` section breaks that were already between the
  /// blocks, so they now do the separating instead of just adding air.
  ///
  /// On tablet this returns the bare Column and changes nothing: the sections
  /// stay flush inside the one container, which is the layout that page was
  /// designed around (and which its fixed 470.h assumes).
  Widget _sectionCard(bool isMobile, List<Widget> children) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    if (!isMobile) return content;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      // Matches PersonalData's inset. The parent already pads the page edges,
      // so this is the card's own breathing room, not the page's.
      padding: EdgeInsets.all(15.sp),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return BlocListener<CompanyCubit, CompanyState>(
      listenWhen: (prev, curr) => prev.company != curr.company,
      listener: (context, state) => setState(() => _syncFromState(state)),
      child: Container(
      height: isMobile ? null : 470.h,
      // CHANGED 8/9/2026 — transparent on a phone.
      //
      // Each of the three sections now paints its own card (see
      // [_sectionCard]), so this shell has to stop painting one behind them:
      // a card colour here would fill the gaps between them and they would
      // read as a single slab again, which is the whole thing being fixed.
      // On tablet nothing changes — the sections stay flush inside this one
      // container, exactly as before.
      color: isMobile ? null : AppColors.card,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),

        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(isMobile, <Widget>[


              // Company Section
              Row(
                children: [
                  CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/company.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      S.of(context).company,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 15.sp), // Company header -> first field

              // Row 1: Company Name, Tax Number, Country
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).companyName,
                      hint: S.of(context).textHere,
                      controller: companyNameController,
                      textDirection: companyNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          companyNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).taxNumber,
                      hint: S.of(context).textHere,
                      controller: taxNumberController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).country,
                      hint: S.of(context).textHere,
                      controller: countryController,
                      textDirection: countryDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          countryDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: S.of(context).companyName,
                    hint: S.of(context).textHere,
                    controller: companyNameController,
                    textDirection: companyNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        companyNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 10.sp), // Company Name -> Tax Number
                  CustomTextField(
                    label: S.of(context).taxNumber,
                    hint: S.of(context).textHere,
                    controller: taxNumberController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 10.sp), // Tax Number -> Country
                  CustomTextField(
                    label: S.of(context).country,
                    hint: S.of(context).textHere,
                    controller: countryController,
                    textDirection: countryDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        countryDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.sp), // Row 1 -> Row 2

              // Row 2: Province, City
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).province,
                      hint: S.of(context).textHere,
                      controller: provinceController,
                      textDirection: provinceDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          provinceDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).city,
                      hint: S.of(context).textHere,
                      controller: cityController,
                      textDirection: cityDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          cityDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: S.of(context).province,
                    hint: S.of(context).textHere,
                    controller: provinceController,
                    textDirection: provinceDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        provinceDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 10.sp), // Province -> City
                  CustomTextField(
                    label: S.of(context).city,
                    hint: S.of(context).textHere,
                    controller: cityController,
                    textDirection: cityDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        cityDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 10.sp), // Row 2 -> Street

              // Row 3: Street (full width)
              CustomTextField(
                label: S.of(context).street,
                hint: S.of(context).textHere,
                controller: streetController,
                textDirection: streetDirection,
                enabled: false,
                onChanged: (value) {
                  setState(() {
                    streetDirection = _detectTextDirection(value);
                  });
                },
              ),
              ]),

              SizedBox(height: 15.sp), // Street -> Service section break

              _sectionCard(isMobile, <Widget>[
              // Service Section
              Row(
                children: [
                  CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/services_building_stars.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      S.of(context).service,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 15.sp), // Service header -> first field

              // Row 4: Industry, Company Size
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).industry,
                      hint: S.of(context).textHere,
                      controller: industryController,
                      textDirection: industryDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          industryDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).companySize,
                      hint: S.of(context).textHere,
                      controller: companySizeController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: S.of(context).industry,
                    hint: S.of(context).textHere,
                    controller: industryController,
                    textDirection: industryDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        industryDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 10.sp), // Industry -> Company Size
                  CustomTextField(
                    label: S.of(context).companySize,
                    hint: S.of(context).textHere,
                    controller: companySizeController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              ]),

              SizedBox(height: 15.sp), // Company Size -> Contact section break

              _sectionCard(isMobile, <Widget>[
              // Contact Section
              Row(
                children: [
                  CustomSvgImage(assetPath: "assets/icons_assets/settings_assets/phone_call_contact.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      S.of(context).contact,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 15.sp), // Contact header -> first field

              // Row 5: First Name, Last Name
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).firstName,
                      hint: S.of(context).textHere,
                      controller: firstNameController,
                      textDirection: firstNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          firstNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).lastName,
                      hint: S.of(context).textHere,
                      controller: lastNameController,
                      textDirection: lastNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          lastNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: S.of(context).firstName,
                    hint: S.of(context).textHere,
                    controller: firstNameController,
                    textDirection: firstNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        firstNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 10.sp), // First Name -> Last Name
                  CustomTextField(
                    label: S.of(context).lastName,
                    hint: S.of(context).textHere,
                    controller: lastNameController,
                    textDirection: lastNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        lastNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.sp), // Row 5 -> Row 6

              // Row 6: Email, Phone Number
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).email,
                      hint: S.of(context).textHere,
                      controller: emailController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: S.of(context).phoneNumber,
                      hint: S.of(context).textHere,
                      controller: phoneNumberController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: S.of(context).email,
                    hint: S.of(context).textHere,
                    controller: emailController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 10.sp), // Email -> Phone Number
                  CustomTextField(
                    label: S.of(context).phoneNumber,
                    hint: S.of(context).textHere,
                    controller: phoneNumberController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              ]),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      ),
    );
  }
}