/// Module: knowledge_hub / presentation / s5_submission_details / widgets/build_action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_action_buttons.dart
/// Purpose: Build action buttons — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../../../../k1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

// ============= HELPER FUNCTIONS FOR FILE OPERATIONS =============

/// Download file to device's Downloads folder (Cross-platform)
Future<bool> _downloadFile(
    BuildContext context, {
      required String fileUrl,
      required String fileName,
    }) async {
  try {
    log('🔽 Starting download for: $fileName');
    log('📍 URL: $fileUrl');

    // ✅ EXTRACT FILE EXTENSION FROM URL IF MISSING
    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      // Extract extension from URL
      try {
        final uri = Uri.parse(fileUrl);
        final urlPath = uri.path;
        if (urlPath.contains('.')) {
          final extension = urlPath.substring(urlPath.lastIndexOf('.'));
          finalFileName = '$fileName$extension';
          log('📝 Added extension from path: $finalFileName');
        }
      } catch (e) {
        log('⚠️ Could not extract extension from URL: $e');
      }
    }

    log('✅ Final filename: $finalFileName');

    // ==================== ANDROID ====================
    if (Platform.isAndroid) {
      return await _downloadFileAndroid(fileUrl, finalFileName);
    }
    // ==================== iOS ====================
    else if (Platform.isIOS) {
      return await _downloadFileIOS(context, fileUrl, finalFileName);
    }
    // ==================== WINDOWS/MAC/LINUX ====================
    else {
      return await _downloadFileDesktop(fileUrl, finalFileName);
    }
  } catch (e) {
    log('❌ Error downloading file: $e');
    log('Stack trace: ${StackTrace.current}');
    return false;
  }
}

/// Download file on Android devices
Future<bool> _downloadFileAndroid(String fileUrl, String fileName) async {
  try {
    // Check Android version
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    log('📱 Android SDK: $sdkInt');

    // ✅ Request appropriate permissions based on Android version
    if (sdkInt >= 33) {
      // Android 13+ doesn't need storage permission for Downloads
      log('✅ Android 13+, no permission needed');
    } else if (sdkInt >= 30) {
      // Android 11-12, need MANAGE_EXTERNAL_STORAGE
      var status = await Permission.manageExternalStorage.status;
      log('📋 MANAGE_EXTERNAL_STORAGE status: $status');
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          log('❌ MANAGE_EXTERNAL_STORAGE permission denied');
          return false;
        }
      }
      log('✅ MANAGE_EXTERNAL_STORAGE granted');
    } else {
      // Android 10 and below, need regular storage permission
      var status = await Permission.storage.status;
      log('📋 Storage permission status: $status');
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          log('❌ Storage permission denied');
          return false;
        }
      }
      log('✅ Storage permission granted');
    }

    final dio = Dio();

    // ✅ For Android 10+ (API 29+), use scoped storage with FlutterFileDialog
    if (sdkInt >= 29) {
      log('📲 Using scoped storage (Android 10+)');

      // Download to temporary directory first
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';

      log('⏳ Downloading to temp: $tempPath');
      await dio.download(
        fileUrl,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log('⏳ Download progress: $progress%');
          }
        },
      );

      // Verify temp file
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        log('❌ Temp file does not exist');
        return false;
      }

      final fileSize = await tempFile.length();
      log('✅ Temp file downloaded: $fileSize bytes');

      // Use FlutterFileDialog to save to Downloads with user confirmation
      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );

      final finalPath = await FlutterFileDialog.saveFile(params: params);

      // Clean up temp file
      try {
        await tempFile.delete();
        log('🗑️ Temp file deleted');
      } catch (e) {
        log('⚠️ Could not delete temp file: $e');
      }

      if (finalPath != null) {
        log('✅ File saved to: $finalPath');
        return true;
      } else {
        log('❌ User cancelled save dialog');
        return false;
      }
    }
    // ✅ For Android 9 and below, direct download to Downloads folder
    else {
      log('📲 Using legacy storage (Android 9 and below)');

      Directory? downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        log('⚠️ /Download not found, trying /Downloads');
        downloadDir = Directory('/storage/emulated/0/Downloads');
      }

      if (!await downloadDir.exists()) {
        log('❌ Downloads directory not found, using external storage');
        downloadDir = await getExternalStorageDirectory();
      }

      final downloadPath = '${downloadDir?.path}/$fileName';
      log('📂 Download path: $downloadPath');

      await dio.download(
        fileUrl,
        downloadPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log('⏳ Download progress: $progress%');
          }
        },
      );

      final file = File(downloadPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        log('✅ File downloaded: $fileSize bytes at $downloadPath');
        return true;
      } else {
        log('❌ File does not exist after download');
        return false;
      }
    }
  } catch (e) {
    log('❌ Android download error: $e');
    return false;
  }
}

/// Download file on iOS devices
Future<bool> _downloadFileIOS(
    BuildContext context,
    String fileUrl,
    String fileName,
    ) async {
  try {
    log('📱 iOS download starting');

    final dio = Dio();

    // Download to temporary directory first
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';

    log('⏳ Downloading to temp: $tempPath');
    await dio.download(
      fileUrl,
      tempPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          log('⏳ Download progress: $progress%');
        }
      },
    );

    // Verify temp file
    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      log('❌ Temp file does not exist');
      return false;
    }

    final fileSize = await tempFile.length();
    log('✅ Temp file downloaded: $fileSize bytes');

    // Use FlutterFileDialog to let user save via iOS share sheet
    final params = SaveFileDialogParams(
      sourceFilePath: tempPath,
      fileName: fileName,
    );

    final finalPath = await FlutterFileDialog.saveFile(params: params);

    // Clean up temp file
    try {
      await tempFile.delete();
      log('🗑️ Temp file deleted');
    } catch (e) {
      log('⚠️ Could not delete temp file: $e');
    }

    if (finalPath != null) {
      log('✅ File saved via iOS share sheet');
      return true;
    } else {
      log('❌ User cancelled save dialog');
      return false;
    }
  } catch (e) {
    log('❌ iOS download error: $e');
    return false;
  }
}

/// Download file on Desktop (Windows/macOS/Linux)
Future<bool> _downloadFileDesktop(String fileUrl, String fileName) async {
  try {
    log('💻 Desktop download starting');

    final dio = Dio();

    // Get Downloads directory
    Directory? downloadDir = await getDownloadsDirectory();

    // Fallback options if getDownloadsDirectory returns null
    if (downloadDir == null) {
      log('⚠️ getDownloadsDirectory returned null, trying alternatives');

      // Try to construct Downloads path manually
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          downloadDir = Directory('$userProfile\\Downloads');
          log('🪟 Windows Downloads path: ${downloadDir.path}');
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          downloadDir = Directory('$home/Downloads');
          log('🍎 macOS Downloads path: ${downloadDir.path}');
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          downloadDir = Directory('$home/Downloads');
          log('🐧 Linux Downloads path: ${downloadDir.path}');
        }
      }

      // Final fallback to Documents directory
      if (downloadDir == null || !await downloadDir.exists()) {
        log('⚠️ Downloads directory not found, using Documents');
        downloadDir = await getApplicationDocumentsDirectory();
      }
    }

    final downloadPath = '${downloadDir.path}${Platform.pathSeparator}$fileName';
    log('📂 Download path: $downloadPath');

    await dio.download(
      fileUrl,
      downloadPath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          log('⏳ Download progress: $progress%');
        }
      },
    );

    final file = File(downloadPath);
    if (await file.exists()) {
      final fileSize = await file.length();
      log('✅ File downloaded: $fileSize bytes');
      log('✅ Location: $downloadPath');
      return true;
    } else {
      log('❌ File does not exist after download');
      return false;
    }
  } catch (e) {
    log('❌ Desktop download error: $e');
    return false;
  }
}

/// View file inside the application
Future<bool> _viewFileInApp(
    BuildContext context, {
      required String fileUrl,
      required String fileName,
    }) async {
  try {
    log('👁️ Opening file: $fileName');
    log('📍 URL: $fileUrl');

    // ✅ EXTRACT FILE EXTENSION FROM URL IF MISSING
    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      // Extract extension from URL
      final uri = Uri.parse(fileUrl);
      final urlPath = uri.path;
      final extension = urlPath.substring(urlPath.lastIndexOf('.'));
      finalFileName = '$fileName$extension';
      log('📝 Added extension: $finalFileName');
    }

    // If still no extension, try to get from URL query parameters
    if (!finalFileName.contains('.')) {
      try {
        final uri = Uri.parse(fileUrl);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final lastSegment = segments.last;
          if (lastSegment.contains('.')) {
            final extension =
            lastSegment.substring(lastSegment.lastIndexOf('.'));
            finalFileName = '$fileName$extension';
            log('📝 Extracted extension from path: $finalFileName');
          }
        }
      } catch (e) {
        log('⚠️ Could not extract extension from URL: $e');
      }
    }

    log('✅ Final filename: $finalFileName');

    // Create Dio instance
    final dio = Dio();

    // Get temporary directory to cache file
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$finalFileName'; // ✅ Use finalFileName

    log('📂 Cache path: $filePath');

    // ⚠️ 22/9/2026 — DO NOT REVIVE THIS BRANCH AS-IS.
    //
    // This file is currently unreachable (only `submitted_document_details_section.dart`
    // imports it, and nothing imports that). It is called out because the cache
    // below is keyed on the FILE NAME, and `documentFileName` is not unique —
    // the create flow falls back to the literal 'document' when a name cannot
    // be read. Two documents sharing a name therefore resolve to one temp file
    // and the first one downloaded is served for both, forever.
    //
    // `viewFileInApp` in main_controller/helper/knowledge_hub_file_operations.dart
    // is the live copy and already re-downloads every time for this reason.
    // Use that one rather than resurrecting this.
    //
    // Check if file already exists in cache
    final file = File(filePath);
    if (await file.exists()) {
      log('✅ File exists in cache, reusing');
    } else {
      log('⏳ Downloading file to cache...');
      // Download file to temp directory
      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log('⏳ Loading file: $progress%');
          }
        },
      );
      log('✅ File cached successfully');
    }

    // Verify file exists and has content
    if (await file.exists()) {
      final fileSize = await file.length();
      log('📄 File size: $fileSize bytes');

      if (fileSize == 0) {
        log('❌ File is empty');
        return false;
      }
    } else {
      log('❌ File does not exist after download');
      return false;
    }

    // Open file with default app
    log('🚀 Opening file with default app...');
    final result = await OpenFilex.open(filePath);

    log('📱 OpenFilex result type: ${result.type}');
    log('📱 OpenFilex message: ${result.message}');

    if (result.type == ResultType.done) {
      log('✅ File opened successfully');
      return true;
    } else if (result.type == ResultType.noAppToOpen) {
      log('❌ No app available to open this file type');
      return false;
    } else if (result.type == ResultType.fileNotFound) {
      log('❌ File not found');
      return false;
    } else if (result.type == ResultType.permissionDenied) {
      log('❌ Permission denied');
      return false;
    } else {
      log('❌ Failed to open file: ${result.message}');
      return false;
    }
  } catch (e) {
    log('❌ Error viewing file: $e');
    log('Stack trace: ${StackTrace.current}');
    return false;
  }
}

// ============= DIALOG FUNCTIONS =============

/// Show loading dialog
void _showLoadingDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                style: StyleText.fontSize14Weight500.copyWith(
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
  );
}

/// Show success dialog
void _showSuccessDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: lightMode
          ? AppColors.white
          : AppColors.chatBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.lightGreen,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Auto close after 2 seconds
  Future.delayed(Duration(seconds: 2), () {
    if (context.mounted) Navigator.of(context).pop();
  });
}

/// Show error dialog
void _showErrorDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  showDialog(
    context: context,
    builder: (context) {
      return Material(
        color: AppColors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode
                  ? AppColors.white
                  : AppColors.chatBackground,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.red,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                customButton(
                  title: S.of(context).ok ?? 'OK',
                  function: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}