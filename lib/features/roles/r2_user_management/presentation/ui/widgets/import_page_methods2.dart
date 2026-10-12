/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: import_page_methods2.dart
/// Purpose: Declares `ImportPageMethods2`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/import_page.dart';

extension ImportPageMethods2 on _UploadFileTabletRolesState {
  void _showHeaderErrorDialog(List<String> missingHeaders) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/roles_lottie_assets/rejected.json',
              width: 90.sp,
              height: 90.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.sp),
            Text(
              "Warning Invalid Column Title",
              style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              "Some required columns are missing: ${missingHeaders.join(', ')}",
              style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  void _showMissingHeadersWarning(List<String> missingHeaders) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Warning Invalid Column Title: ${missingHeaders.join(', ')}'),
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.orange,
      ),
    );
  }
  void _showAdditionalColumnsWarning(List<String> additionalHeaders) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Warning Additional Column: ${additionalHeaders.join(', ')}'),
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.orange,
      ),
    );
  }
  Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          }
        }

        if (status.isPermanentlyDenied) {
          var manageStatus = await Permission.manageExternalStorage.status;
          if (manageStatus.isDenied) {
            manageStatus = await Permission.manageExternalStorage.request();
          }
          return manageStatus.isGranted;
        }

        return status.isGranted;
      } else if (Platform.isIOS) {
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}
