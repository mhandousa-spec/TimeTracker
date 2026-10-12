import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 18/1/2025
// Objectives:Enum representing different types of field types in a form.
enum FormFieldType {
  image,
  textField,
  email,
  phone,
  location,
  dropDown,
  radio,
  checkBox,
  description,
  attachment,
  link,
  digitalSignature,
  dateSelector,
  address,
  timeSelector,
  title,
  radioTextField,
  termsAndCondition,
}

/// Leading-glyph size for a field-type row, per Figma node 7444-41905 (16 × 16
/// against a 24-tall label, 8 before the text). Kept equal to
/// `kLeadingIconSize` in `drop_down_widget.dart`, which is what actually draws
/// these on the field-type dropdown.
const double kFieldTypeIconSize = 16;

/// Extension to provide additional functionalities to the FieldType enum.
extension FieldTypeExtension on FormFieldType {
  /// The STABLE, language-independent identifier for the field type.
  ///
  /// FIXED 19/8/2026 — this used to double as the on-screen label, which is why
  /// field types showed English while the rest of the app was in Arabic. It is
  /// still English on purpose: it is what gets written to Firestore, what
  /// [fromName] parses back, and what `DropdownMenuItem.value` carries, so
  /// translating it would silently orphan every form already saved. Anything
  /// the user READS must use [label] instead.
  String get name {
    switch (this) {
      case FormFieldType.image:
        return 'Image';
      case FormFieldType.textField:
        return 'Text Field';
      case FormFieldType.email:
        return 'Email';
      case FormFieldType.phone:
        return 'Phone';
      case FormFieldType.location:
        return 'Location';
      case FormFieldType.dropDown:
        return 'Drop Down';
      case FormFieldType.radio:
        return 'Radio';
      case FormFieldType.checkBox:
        return 'Check Box';

      case FormFieldType.termsAndCondition:
        return 'Terms And Condition';

      case FormFieldType.description:
        return 'Description';
      case FormFieldType.attachment:
        return 'Attachment';
      case FormFieldType.link:
        return 'Link';
      case FormFieldType.digitalSignature:
        return 'Attached Digital Signature';
      case FormFieldType.dateSelector:
        return 'Date Selector';
      case FormFieldType.address:
        return 'Address';
      case FormFieldType.timeSelector:
        return 'Time Selector';
      case FormFieldType.title:
        return 'Title';
      case FormFieldType.radioTextField:
        return 'Radio - Text Field';
    }
  }

  /// The translated label for the field type — use this everywhere a human
  /// reads it. Backed by `intl_en.arb` / `intl_ar.arb`, so it follows the
  /// active locale instead of being frozen to English like [name].
  String get label {
    final s = S.current;
    switch (this) {
      case FormFieldType.image:
        return s.fieldTypeImage;
      case FormFieldType.textField:
        return s.fieldTypeTextField;
      case FormFieldType.email:
        return s.fieldTypeEmail;
      case FormFieldType.phone:
        return s.fieldTypePhone;
      case FormFieldType.location:
        return s.fieldTypeLocation;
      case FormFieldType.dropDown:
        return s.fieldTypeDropDown;
      case FormFieldType.radio:
        return s.fieldTypeRadio;
      case FormFieldType.checkBox:
        return s.fieldTypeCheckBox;
      case FormFieldType.termsAndCondition:
        return s.fieldTypeTermsAndCondition;
      case FormFieldType.description:
        return s.fieldTypeDescription;
      case FormFieldType.attachment:
        return s.fieldTypeAttachment;
      case FormFieldType.link:
        return s.fieldTypeLink;
      case FormFieldType.digitalSignature:
        return s.fieldTypeDigitalSignature;
      case FormFieldType.dateSelector:
        return s.fieldTypeDateSelector;
      case FormFieldType.address:
        return s.fieldTypeAddress;
      case FormFieldType.timeSelector:
        return s.fieldTypeTimeSelector;
      case FormFieldType.title:
        return s.fieldTypeTitle;
      case FormFieldType.radioTextField:
        return s.fieldTypeRadioTextField;
    }
  }

  /// Returns the icon asset path associated with the enum item.
  String get icon {
    switch (this) {
      case FormFieldType.image:
        return AppAssets.imageIcon;
      case FormFieldType.textField:
        return AppAssets.text;
      case FormFieldType.email:
        return AppAssets.emailIcon;
      case FormFieldType.phone:
        return AppAssets.phoneIcon;
      case FormFieldType.location:
        return AppAssets.locationIcon;
      case FormFieldType.dropDown:
        return AppAssets.dropDownIcon;
      case FormFieldType.radio:
        return AppAssets.radioIcon;
      case FormFieldType.checkBox:
        return AppAssets.checkBoxIcon;
      case FormFieldType.termsAndCondition:
        return AppAssets.checkBoxIcon;
      case FormFieldType.description:
        return AppAssets.descriptionIcon;
      case FormFieldType.attachment:
        return AppAssets.attachmentIcon;
      case FormFieldType.link:
        return AppAssets.linkIcon;
      case FormFieldType.digitalSignature:
        return AppAssets.attachedDigitalSignatureIcon;
      case FormFieldType.dateSelector:
        return AppAssets.calendar;
      case FormFieldType.address:
        return AppAssets.addressIcon;
      case FormFieldType.timeSelector:
        return AppAssets.timeSelectorIcon;
      case FormFieldType.title:
        return AppAssets.text;
      case FormFieldType.radioTextField:
        return AppAssets.radioIcon;
    }
  }

  /// Returns an enum item based on its name.
  static FormFieldType? fromName(String name) {
    return FormFieldType.values.firstWhere((element) => element.name == name,
        orElse: () => FormFieldType.textField);
  }

  /// Returns the dropdown items for the enum.
  ///
  /// FIXED 19/8/2026 — the `SvgPicture.asset` here carried NO width or height,
  /// so every menu row drew its glyph at the SVG's own intrinsic size inside an
  /// unbounded Row. That is the "very big" icon from the bug report, and it
  /// never matched the trigger either, which `AppDropdown` drew at 14 × 6.
  ///
  /// On the field-type dropdown these children no longer render: `DropDownWidget`
  /// now builds each row's leading icon itself, from [fromName], at the single
  /// `kLeadingIconSize` it also uses for the trigger. The size is pinned here
  /// anyway for any caller still feeding this list to `AppDropdown`, and the
  /// gap is 8 rather than 12 to match Figma node 7444-41905.
  static List<DropdownMenuItem<String>> get dropDownItems {
    return FormFieldType.values.map((element) {
      return DropdownMenuItem(
        value: element.name,
        child: Row(
          children: [
            SvgPicture.asset(
              element.icon,
              width: kFieldTypeIconSize.sp,
              height: kFieldTypeIconSize.sp,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Text(
              // value stays `name` (stable), only the visible text is localized
              element.label,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
            ),
          ],
        ),
      );
    }).toList();
  }
}
