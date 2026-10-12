/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: file_handler.dart
/// Purpose: Declares `FileHandler`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
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
  Future<File> downloadFile(String fileUrl, String fileName) async {
    final appDirPath = await _getAppDirectory();
    final filePath = "$appDirPath/$fileName";

    final file = await _checkFileExists(fileName);
    if (file != null) {
      return file; // File already exists
    }

    // File does not exist, download it
    try {
      final dio = Dio();
      await dio.download(fileUrl, filePath);
      return File(filePath);
    } catch (e) {
      throw Exception("Failed to download file: $e");
    }
  }

  /// Get the file path (checks if the file exists or downloads it)
  Future<String> getFilePath(String fileUrl, String fileName) async {
    final file = await downloadFile(fileUrl, fileName);
    return file.path;
  }

  static getFileExtension(String s) {
    if (s.isEmpty) return '';
    final parts = s.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }
}
