import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class MediaHandler {
  final String appName = "Knowticed plus";

  /// Get the app-specific directory
  Future<String> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory("${directory.path}/$appName");
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir.path;
  }

  /// Check if the file already exists
  Future<File?> _checkFileExists(String fileName) async {
    final appDirPath = await _getAppDirectory();
    final filePath = "$appDirPath/$fileName";
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Download the file if it doesn't exist
  Future<File> downloadFile(String fileUrl, String fileName, {String path = ''}) async {
    final appDirPath = await _getAppDirectory();

    // Remove query parameters from filename
    fileName = fileName.split('?').first;

    // ✅ FIX: Only decode if the string actually contains valid percent encoding
    try {
      // Check if the string contains % followed by valid hex characters
      if (fileName.contains('%') && RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(fileName)) {
        fileName = Uri.decodeComponent(fileName);
      }
    } catch (e) {
      
      // If decoding fails, just continue with the original filename
    }

    // Replace invalid characters with underscore
    fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]|[\x00-\x1F]'), '_');

    // Trim whitespace from both ends
    fileName = fileName.trim();

    // Handle long filenames
    const maxLength = 120;
    if (fileName.length > maxLength) {
      final ext = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '';
      final base = fileName.substring(0, maxLength - ext.length - 1);
      fileName = '${base}_${DateTime.now().millisecondsSinceEpoch % 10000}$ext';
    }

    // Build the full file path
    final filePath = path.isEmpty
        ? "$appDirPath/$fileName"
        : "$appDirPath/$path/$fileName";

    

    // Optional: Check if file exists
    /*
    final file = await _checkFileExists(fileName);
    if (file != null) {
      return file; // File already exists
    }
    */

    // Create directory if path is provided
    if (path.isNotEmpty) {
      final dir = Directory("$appDirPath/$path");
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // File does not exist, download it
    try {
      final dio = Dio();

      // ✅ FIX: Add timeout and error handling
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            
          }
        },
      );

      return File(filePath);
    } on DioException catch (e) {

      throw Exception("Failed to download file: ${e.message}");
    } catch (e) {
      
      throw Exception("Failed to download file: $e");
    }
  }

  /// Get the file path (checks if the file exists or downloads it)
  Future<String> getFilePath(String fileUrl, String fileName) async {
    final file = await downloadFile(fileUrl, fileName);
    return file.path;
  }
}