import 'dart:io';

import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/form_builder/attachment_helper.dart';


/// ************************* FILE INFO ***************************
class AttachmentEntity {
  String path;
  String name;
  int size;
  String createdAt;

  AttachmentEntity(
      {required this.path,
      required this.name,
      required this.size,
      required this.createdAt});
  static final String _codingKey = "^*^*^*^";
  String get encodedAttachmentData {
    String encodedData = path;
    encodedData += _codingKey;
    encodedData += name;
    encodedData += _codingKey;
    encodedData += size.toString();
    encodedData += _codingKey;
    encodedData += createdAt;
    return encodedData;
  }

  static AttachmentEntity fromDecodedData(String encodedData) {
    List<String> decodedData = encodedData.split(_codingKey);
    String path = decodedData[0];
    String name = decodedData[1];
    int size = int.parse(decodedData[2]);
    String createdAt = decodedData[3];
    return AttachmentEntity(path: path, name: name, size: size, createdAt: createdAt);
  }

  static AttachmentEntity fromFile(File file) {
    String path = file.path;
    String name = getAttachmentNameWithExtension(path);
    int size = (file.lengthSync() / 1024).round();
    String createdAt =  DateFormat('dd_MMM_yyyy').format(DateTime.now());
    return AttachmentEntity(
        path: path, name: name, size: size, createdAt: createdAt);
  }
}
