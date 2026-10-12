/// Module: GRC Policy Management
/// Description: Data model for uploaded policy/control document metadata.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: file_picker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Added `file` + fromPlatformFile factory so
///                                the picked file can be uploaded, not just
///                                displayed.
///                   2026-07-15 - Added `url` + fromUrl factory for
///                                already-uploaded, read-only documents
///                                (Policy Details page)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_info.dart
/// Purpose: Contains PolicyDocumentInfo, an immutable model for a picked
///          document's display metadata plus the actual File to upload, or
///          the remote URL for an already-uploaded, read-only document.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// class name: [PolicyDocumentInfo]
///
/// purpose: immutable value object that carries display metadata (name,
///          formatted size, formatted date) plus either the local [file] to
///          upload for a freshly picked document, or the remote [url] of an
///          already-uploaded document shown read-only.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentInfo {
  final String name;
  final String sizeLabel;
  final String dateLabel;
  final File? file;
  final String? url;

  const PolicyDocumentInfo({
    required this.name,
    required this.sizeLabel,
    required this.dateLabel,
    this.file,
    this.url,
  });

  /// function name: [fromPlatformFile]
  ///
  /// purpose: build a [PolicyDocumentInfo] straight from the [PlatformFile]
  ///          returned by `showUploadDialog`'s onSubmit callback.
  ///
  /// parameters:
  ///            [PlatformFile] platformFile: the file picked via file_picker
  ///
  /// return type: [PolicyDocumentInfo]
  factory PolicyDocumentInfo.fromPlatformFile(PlatformFile platformFile) {
    return PolicyDocumentInfo(
      name: platformFile.name,
      sizeLabel: _formatBytes(platformFile.size),
      dateLabel: _formatToday(),
      file: File(platformFile.path!),
    );
  }

  /// function name: [fromUrl]
  ///
  /// purpose: build a read-only [PolicyDocumentInfo] for a document that is
  ///          already uploaded — only its download [url] is known, no local
  ///          [File] or byte size is available.
  ///
  /// parameters:
  ///            [String] url: the document's download URL
  ///
  /// return type: [PolicyDocumentInfo]
  factory PolicyDocumentInfo.fromUrl(String url) {
    // Mirrors fileNameOf() in core/custom/52-custom_upload_document.dart,
    // spelled out rather than imported: this is a DOMAIN entity and that
    // file pulls in flutter/material with it.
    final withoutQuery = url.split('?').first;
    final segments = withoutQuery.split('/');
    final rawName = segments.isNotEmpty ? segments.last : withoutQuery;
    String name;
    try {
      name = Uri.decodeFull(rawName);
    } catch (_) {
      name = rawName;
    }
    // '1789419500602_report.pdf' -> 'report.pdf'. PolicyStorageDataSource
    // names every upload '<epochMillis>_<originalName>' and this factory
    // printed the stamp along with it. 10+ digits, so a real name that
    // merely starts with a number ('2024_budget.xlsx') is left alone.
    final stamped = RegExp(r'^\d{10,}_(.+)$').firstMatch(name);
    if (stamped != null) name = stamped.group(1)!;
    return PolicyDocumentInfo(
      name: name.isEmpty ? url : name,
      sizeLabel: '',
      dateLabel: '',
      url: url,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _formatToday() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
