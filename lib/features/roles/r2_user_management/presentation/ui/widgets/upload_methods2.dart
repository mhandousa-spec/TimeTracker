/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_methods2.dart
/// Purpose: Declares `UploadMethods2`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension UploadMethods2 on _UploadFileDetailsTabletRolesState {
  // ✅ UPDATE ERROR LOCATION LIST — computation lives on the controller.
  void updateErrorLocations() {
    errorLocations = userManagementController
        .buildErrorLocations(validationErrors);
    currentErrorIndex = userManagementController
        .normalizeErrorIndex(currentErrorIndex, errorLocations.length);
  }

  void focusErrorField(bool forward) {
    if (errorLocations.isEmpty) {
      return;
    }

    setState(() {
      currentErrorIndex = userManagementController.nextErrorIndex(
          currentErrorIndex, errorLocations.length, forward);
    });

    final entry = errorLocations[currentErrorIndex];
    final rowIndex = entry.key;
    final header = entry.value;


    final controller = formData[rowIndex][header];
    final node = focusNodes[rowIndex][header];
    final key = fieldKeys[rowIndex][header];

    // Scroll to the field first, then focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final contextToScroll = key?.currentContext;
        if (contextToScroll != null) {
          Scrollable.ensureVisible(
            contextToScroll,
            duration: const Duration(milliseconds: 500),
            alignment: 0.3,
            curve: Curves.easeInOut,
          ).then((_) {
            // Focus after scrolling is complete
            if (controller != null && node != null) {
              controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
              FocusScope.of(context).requestFocus(node);
            }
          });
        } else {
        }
      });
    });
  }
  /// Uses the shared CustomDialogManager instead of a bespoke AlertDialog.
  /// Note this auto-dismisses rather than waiting for an "Ok" tap.
  void showErrorDialog() {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: 'assets/lottie_assets/roles_lottie_assets/rejected.json',
      title: "You must solve these errors",
    );
  }

}
