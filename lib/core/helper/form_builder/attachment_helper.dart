/// ***************** FILE INFO *****************
/// File Name: attachment_helper.dart
/// Purpose: Helper class for handling attachment-related operations
/// Created on: 6/4/2025
/// Created by: Mohamed Elrashidy

String getAttachmentExtension(String attachmentPath) {
  return attachmentPath.split('.').last;
}

String getAttachmentNameWithExtension(String attachmentPath) {
  String name = "";
  if (attachmentPath.contains('/')) {
    name = attachmentPath.split('/').last;
  } else if (attachmentPath.contains('\\')) {
    name = attachmentPath.split('\\').last;
  }
  return name;
}

String getAttachmentName(String attachmentPath) {
  return getAttachmentNameWithExtension(attachmentPath).split('.').first;
}

String createNewAttachmentName(
    {required String attachmentPath, required String fileNamePrefix}) {
  String fileName = getAttachmentName(attachmentPath);
  String extension = getAttachmentExtension(attachmentPath);
  String newName = "${fileNamePrefix}_${fileName}_$extension.$extension";
  return newName;
}
