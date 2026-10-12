/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_controller_export.dart
/// Purpose: Declares `ActiveDirectoryControllerExport`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './active_directory_controller.dart';
extension ActiveDirectoryControllerExport on ActiveDirectoryController {
  saveChanges({required int rowIndex}) async {

    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: globalNavigatorKey.currentContext!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle:
              S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            changedFields =
                usersData.map((subList) => List.from(subList)).toList();
            isEditable[rowIndex] = false;
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(rowIndex: rowIndex, context: globalNavigatorKey.currentContext!);
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isSaved[rowIndex]   = false;
        isChanged[rowIndex] = false;
    }
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller_export.dart: non-fatal failure: $e');
    }
  }

  saveInvalidChanges({required int rowIndex}) async {

    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isInvalidChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: globalNavigatorKey.currentContext!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle:
              S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            isInvalidEditable[rowIndex] = false;
            invalidChangedFields =
                rowInvalid.map((subList) => List.from(subList)).toList();
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(rowIndex: rowIndex, context: globalNavigatorKey.currentContext!);
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isInvalidSaved[rowIndex]   = false;
        isInvalidChanged[rowIndex] = false;
    }
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
      debugPrint('active_directory_controller_export.dart: non-fatal failure: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXPORT
  // ══════════════════════════════════════════════════════════════════════════

  _getRowDataFromModel({
    required List<dynamic> row,
    required NewEmployeeModelHistory employee,
    required bool isWrongEmployee,
  }) {
    try {
      for (EmployeeDataItems item in EmployeeDataItems.values) {
        item.getRowDataFromModelItem(
            row: row,
            employee: employee,
            isWrongEmployee: isWrongEmployee,
          departmentName: (id, {required arabic}) => (arabic
                  ? departmentCubit.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id)
                  : departmentCubit.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id)) ??
              '',
        );
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  exportToCSV(String fileName) async {
    showLoadingIndicator();
    try {
      List<List> rows = await _getExportData();
      await CSVHelper().exportToCSV(rows, fileName);
      hideLoadingIndicator();
      Navigator.pop(globalNavigatorKey.currentContext!);
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: "SuccessFul",
        subtitle: "Your Data Has Been Saved To Download Folder",
        lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
      );
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: "Error",
        subtitle: "Error At Saving The File",
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      );
    }
  }

  // REMOVED 10/9/2026: `exportSelectedRowsToCSV`.
  //
  // Its only caller was the phone preview page, and it was the reason that
  // page's export never reached the user: it wrote through
  // `CSVHelper.exportToCSV`, a folder write that scoped storage refuses on
  // Android and that lands in the app's unreachable private Documents on iOS.
  // It also answered with a bool, so a save sheet the user dismissed and a
  // failed write were the same answer.
  //
  // The page now builds its own header row — the same `EmployeeDataItems` order
  // this file's `_getExportData` uses — and saves through
  // `CSVHelper.exportForUser`, which hands the file to the system save sheet.

  _getExportData() async {
    try {
      List<List> rows = [];
      rows.add(EmployeeDataItems.values.map((e) => e.name).toList());
      await getEmployeesTableData();
      for (int i = 0; i < usersData.length; i++) {
        rows.add(usersData[i]);
      }
      return rows;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
