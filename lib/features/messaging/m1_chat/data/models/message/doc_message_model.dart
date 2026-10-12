/// Module: messaging / chat / data/models/message/doc_message_model.dart
import 'dart:io';
import 'dart:typed_data';

//Youssef Ashraf
class DocMessageModel {
  String extension;
  String? fileName;
  double totalSize;
  int totalPages;
  String docPath;
  Uint8List? firstPage;

  DocMessageModel(
      {this.totalSize = 0,
      this.totalPages = 0,
      this.extension = '',
      required this.docPath,
      this.fileName,
      this.firstPage}) {
    if (!docPath.contains("http")) {
      fileName = docPath.split('/').last.split('\\').last;

      extension = fileName!.split('.').last;

      totalSize = File(docPath).lengthSync() / (1024 * 1024);
    }
  }

  DocMessageModel copyWith({
    double? totalSize,
    int? totalPages,
    String? extension,
    String? fileName,
    required String docPath,
  }) {
    return DocMessageModel(
      totalSize: totalSize ?? this.totalSize,
      docPath: docPath,
      totalPages: totalPages ?? this.totalPages,
      extension: extension ?? this.extension,
      fileName: fileName ?? this.fileName,
    );
  }

  static const String totalSizeKey = 'Total_Size';
  static const String totalPagesKey = 'Total_Pages';
  static const String extensionKey = 'Extension';
  static const String docPathKey = 'Media_Link';
  static const String fileNameKey = 'File_Name';
  static const String firstPageBytesKey = 'First_Page_Bytes';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      totalSizeKey: totalSize,
      totalPagesKey: totalPages,
      extensionKey: extension,
      fileNameKey: fileName,
      docPathKey: docPath,
      // No first-page image in the message doc any more (29/9/2026) — see
      // DocumentMessageCubit.docUploadListener.
    };
  }

  factory DocMessageModel.fromMap(Map<String, dynamic> map) {
    // Older messages still carry First_Page_Bytes as a list of ints; new ones
    // have none (29/9/2026). Both — and int/double sizes — must read.
    final Object? rawFirstPage = map[firstPageBytesKey];
    final Uint8List? firstPageBytes = rawFirstPage is List
        ? Uint8List.fromList(rawFirstPage.map((e) => (e as num).toInt()).toList())
        : null;

    return DocMessageModel(
        totalSize: (map[totalSizeKey] as num?)?.toDouble() ?? 0,
        totalPages: (map[totalPagesKey] as num?)?.toInt() ?? 0,
        docPath: map[docPathKey] as String,
        extension: map[extensionKey] as String? ?? '',
        fileName: map[fileNameKey] as String?,
        firstPage: firstPageBytes);
  }
}