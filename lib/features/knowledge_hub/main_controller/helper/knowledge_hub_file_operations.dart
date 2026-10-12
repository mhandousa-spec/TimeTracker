import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ NEW IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

// ============= HELPER FUNCTIONS FOR FILE OPERATIONS =============

/// ✅ NEW: Refresh Firebase Storage URL to fix expired token (402 error)
Future<String> _refreshFirebaseStorageUrl(String fileUrl) async {
  try {
    final uri = Uri.parse(fileUrl);
    final pathSegments = uri.path.split('/o/');

    if (pathSegments.length > 1) {
      final storagePath =
      Uri.decodeComponent(pathSegments[1].split('?').first);
      log('📂 Storage path extracted: $storagePath');
      final ref = FirebaseStorage.instance.ref(storagePath);
      final freshUrl = await ref.getDownloadURL();
      log('✅ Fresh Firebase URL obtained');
      return freshUrl;
    }
  } catch (e) {
    log('⚠️ Could not refresh Firebase URL, using original: $e');
  }
  return fileUrl;
}

/// Download file to device's Downloads folder (Cross-platform)
Future<bool> downloadFile(
    BuildContext context, {
      required String fileUrl,
      required String fileName,
    }) async {
  try {
    log('🔽 Starting download for: $fileName');
    log('📍 Original URL: $fileUrl');

    // ✅ STEP 1: Refresh Firebase Storage URL to fix 402 expired token
    final freshUrl = await _refreshFirebaseStorageUrl(fileUrl);
    log('📍 Fresh URL: $freshUrl');

    // ✅ STEP 2: Extract file extension using fresh URL
    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      try {
        final uri = Uri.parse(freshUrl);
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

    // ✅ STEP 3: Download using freshUrl
    if (Platform.isAndroid) {
      return await _downloadFileAndroid(freshUrl, finalFileName);
    } else if (Platform.isIOS) {
      return await _downloadFileIOS(context, freshUrl, finalFileName);
    } else {
      return await _downloadFileDesktop(freshUrl, finalFileName);
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
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    log('📱 Android SDK: $sdkInt');

    if (sdkInt >= 33) {
      log('✅ Android 13+, no permission needed');
    } else if (sdkInt >= 30) {
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

    if (sdkInt >= 29) {
      log('📲 Using scoped storage (Android 10+)');

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

      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        log('❌ Temp file does not exist');
        return false;
      }

      final fileSize = await tempFile.length();
      log('✅ Temp file downloaded: $fileSize bytes');

      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: fileName,
      );

      final finalPath = await FlutterFileDialog.saveFile(params: params);

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
    } else {
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

    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      log('❌ Temp file does not exist');
      return false;
    }

    final fileSize = await tempFile.length();
    log('✅ Temp file downloaded: $fileSize bytes');

    final params = SaveFileDialogParams(
      sourceFilePath: tempPath,
      fileName: fileName,
    );

    final finalPath = await FlutterFileDialog.saveFile(params: params);

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

    Directory? downloadDir = await getDownloadsDirectory();

    if (downloadDir == null) {
      log('⚠️ getDownloadsDirectory returned null, trying alternatives');

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

      if (downloadDir == null || !await downloadDir.exists()) {
        log('⚠️ Downloads directory not found, using Documents');
        downloadDir = await getApplicationDocumentsDirectory();
      }
    }

    // Make sure the target directory exists before writing. On macOS the
    // sandbox container's Downloads folder (or the Documents fallback) may not
    // have been created yet, which would otherwise fail file creation.
    try {
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
        log('📁 Created download directory: ${downloadDir.path}');
      }
    } catch (e) {
      log('⚠️ Could not ensure download directory exists: $e');
    }

    final downloadPath =
        '${downloadDir.path}${Platform.pathSeparator}$fileName';
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
Future<bool> viewFileInApp(
    BuildContext context, {
      required String fileUrl,
      required String fileName,
    }) async {
  try {
    log('👁️ Opening file: $fileName');
    log('📍 URL: $fileUrl');

    // ✅ Refresh Firebase Storage URL first
    final freshUrl = await _refreshFirebaseStorageUrl(fileUrl);

    String finalFileName = fileName;
    if (!fileName.contains('.')) {
      final uri = Uri.parse(freshUrl);
      final urlPath = uri.path;
      final extension = urlPath.substring(urlPath.lastIndexOf('.'));
      finalFileName = '$fileName$extension';
      log('📝 Added extension: $finalFileName');
    }

    if (!finalFileName.contains('.')) {
      try {
        final uri = Uri.parse(freshUrl);
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

    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$finalFileName';

    log('📂 Cache path: $filePath');

    final file = File(filePath);
    // ✅ Always re-download with fresh URL (avoids stale cached 402 file)
    log('⏳ Downloading file to cache with fresh URL...');
    await dio.download(
      freshUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          log('⏳ Loading file: $progress%');
        }
      },
    );
    log('✅ File cached successfully');

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

void showLoadingDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogContext) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Container(
          width: 411.w,
          height: 200.h,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleProgressMaster(),
              SizedBox(height: 16.h),
              Text(
                message,
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
  );
}

showSuccessDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  showDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) {
      Future.delayed(Duration(seconds: 2), () {
        if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      });

      return Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Container(
          width: 411.w,
          height: 200.h,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true),
              SizedBox(height: 16.h),
              Text(
                message,
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
      );
    },
  );
}

void showErrorDialog(BuildContext context, String message) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 411.sp,
            height: 273.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
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
                    Navigator.of(dialogContext).pop();
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