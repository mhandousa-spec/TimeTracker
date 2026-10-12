/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/knowledge_hub_file_utils.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_file_utils.dart
/// Purpose: File/media picking and file-metadata utilities for the create-knowledge flow.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:io';
import 'dart:developer';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:path/path.dart' as path;
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';

class KnowledgeHubFileUtils {
  // Extract: _getAllowedExtensions()
  static List<String> getAllowedExtensions() {
    return [
      'jpg', 'jpeg', 'png',
      'mp4', 'mov',
      'pdf',
      'doc', 'docx',
      'txt',
      'ppt', 'pptx',
      'xls', 'xlsx',
    ];
  }

  // Single owner of the picker plugins (§16).
  static final MediaPickerService _mediaPicker = MediaPickerService();

  // Extract: _pickImage()
  static Future<File?> pickImage() async {
    log('Picking image from gallery');
    final picked = await _mediaPicker.pickImage(fromCamera: false);

    if (picked?.path != null) {
      log(picked!.name, name: 'Image name');
      return File(picked.path!);
    }
    return null;
  }

  // Extract: _pickDocument()
  static Future<DocumentPickResult?> pickDocument() async {
    log('Picking document file');
    final picked = await _mediaPicker.pickDocument(
      extensions: getAllowedExtensions(),
    );

    if (picked?.path != null) {
      return DocumentPickResult(
        file: File(picked!.path!),
        fileName: picked.name,
        extension:
            path.extension(picked.name).replaceAll('.', '').toUpperCase(),
        iconType: getDocumentIconType(path.extension(picked.name)),
        size: picked.bytes.length,
        uploadedDate: DateTime.now(),
      );
    }
    return null;
  }

  /// Resolves the upload date from a knowledge model. Date-parsing +
  /// error handling live here (out of the UI layer, §11.2): tries the ISO
  /// `timeStamp` field first, then the millisecond `timestamps` array,
  /// falling back to now.
  static DateTime getUploadDateFromModel(CreateKnowledgeModel model) {
    try {
      if (model.timeStamp.isNotEmpty) {
        final lastTimestamp = model.timeStamp.last;
        if (lastTimestamp.isNotEmpty) {
          return DateTime.parse(lastTimestamp);
        }
      }
    } catch (e) {
      log('⚠️ Error parsing timeStamp: $e');
    }

    try {
      if (model.timestamps.isNotEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(model.timestamps.last);
      }
    } catch (e) {
      log('⚠️ Error parsing timestamps: $e');
    }

    return DateTime.now();
  }

  // Extract: _getDocumentIconType()
  static String getDocumentIconType(String extension) {
    const iconMap = {
      '.pdf': 'pdf',
      '.doc': 'word',
      '.docx': 'word',
      '.txt': 'text',
      '.ppt': 'powerpoint',
      '.pptx': 'powerpoint',
      '.xls': 'excel',
      '.xlsx': 'excel',
    };
    return iconMap[extension.toLowerCase()] ?? 'file';
  }

  // Extract: _formatFileSize()
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Extract: _logDocumentInfo()
  static void logDocumentInfo(DocumentPickResult doc) {
    log('═══════════════════════════════════════');
    log('📄 Document Information:');
    log('═══════════════════════════════════════');
    log('documentExtension: ${doc.extension}');
    log('documentIcon: ${doc.iconType}');
    log('documentSize: ${formatFileSize(doc.size)} (${doc.size} bytes)');
    log('documentUploadedDate: ${doc.uploadedDate.toIso8601String()}');
    log('═══════════════════════════════════════');
  }
}

class DocumentPickResult {
  final File file;
  final String fileName;
  final String extension;
  final String iconType;
  final int size;
  final DateTime uploadedDate;

  DocumentPickResult({
    required this.file,
    required this.fileName,
    required this.extension,
    required this.iconType,
    required this.size,
    required this.uploadedDate,
  });
}