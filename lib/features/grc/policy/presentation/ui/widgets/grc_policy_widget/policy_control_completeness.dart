/// Module: GRC Policy Management
/// Description: Pure predicates for whether a policy Control has any data
///              entered, and whether that data satisfies the required
///              fields.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: PolicyControlModel
/// Revision History: 2026-07-15 - Initial creation
library;

import 'policy_control_model.dart';

/// function name: [controlIsTouched]
///
/// purpose: true if [control] has data in any field — Name/Number/
///          Description (EN or AR), Weight, Frequency, Start/End Date, or
///          either document. Used to decide whether an otherwise-empty
///          control card should be treated as "the user started filling
///          this in" versus ignored entirely.
///
/// parameters:
///            [PolicyControlModel] control: the control to inspect
///
/// return type: [bool]
bool controlIsTouched(PolicyControlModel control) {
  return control.nameController.text.trim().isNotEmpty ||
      control.nameArController.text.trim().isNotEmpty ||
      control.numberController.text.trim().isNotEmpty ||
      control.numberArController.text.trim().isNotEmpty ||
      control.descriptionController.text.trim().isNotEmpty ||
      control.descriptionArController.text.trim().isNotEmpty ||
      control.weightController.text.trim().isNotEmpty ||
      (control.frequency?.isNotEmpty ?? false) ||
      control.startDate != null ||
      control.endDate != null ||
      control.documentEn != null ||
      control.documentAr != null;
}

/// function name: [controlArabicTouched]
///
/// purpose: true if the user has entered something into any of [control]'s
///          Arabic fields (Name/Number/Description AR). Turning the
///          policy's Arabic toggle on doesn't by itself make this
///          control's Arabic fields required — only starting to fill one
///          of them in does.
///
/// parameters:
///            [PolicyControlModel] control: the control to inspect
///
/// return type: [bool]
bool controlArabicTouched(PolicyControlModel control) {
  return control.nameArController.text.trim().isNotEmpty ||
      control.numberArController.text.trim().isNotEmpty ||
      control.descriptionArController.text.trim().isNotEmpty;
}

/// function name: [controlIsComplete]
///
/// purpose: true if [control]'s required fields are all filled: Name,
///          Number, Description (English always; Arabic too when
///          [isArabicEnabled] and [controlArabicTouched]), and Weight.
///          Start Date, End Date, and Frequency stay optional even for a
///          touched control.
///
/// parameters:
///            [PolicyControlModel] control: the control to inspect
///            [bool] isArabicEnabled: whether the policy's Arabic fields
///            can be required for this control too
///
/// return type: [bool]
bool controlIsComplete(PolicyControlModel control,
    {required bool isArabicEnabled}) {
  return control.nameController.text.trim().isNotEmpty &&
      control.numberController.text.trim().isNotEmpty &&
      control.descriptionController.text.trim().isNotEmpty &&
      control.weightController.text.trim().isNotEmpty &&
      // The Frequency dropdown counts as a required field. The Control
      // Document slots deliberately do NOT -- they stay optional.
      (control.frequency?.trim().isNotEmpty ?? false) &&
      (!isArabicEnabled ||
          !controlArabicTouched(control) ||
          (control.nameArController.text.trim().isNotEmpty &&
              control.numberArController.text.trim().isNotEmpty &&
              control.descriptionArController.text.trim().isNotEmpty));
}
