/// Module: GRC shared helpers
/// Description: Opens the system file picker for a Policy / Control document
///              and hands back the picked file — no intermediate dialog.
///
/// ADDED 28/9/2026 (GRC bug report p16, "remove this dialog"). Every policy
/// and control document upload used to open an "Upload … Document" dialog
/// that asked for a Document Title and then threw it away (each caller's
/// `onSubmit: (file, title)` only ever used `file`). The button now opens the
/// file picker straight away.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

/// Opens the picker (pdf / doc / docx) and calls [onPicked] with the chosen
/// file, unless the user cancelled or [context] was unmounted meanwhile.
Future<void> pickGrcDocument(
  BuildContext context,
  ValueChanged<PlatformFile> onPicked,
) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'doc', 'docx'],
    withData: true,
  );
  if (!context.mounted) return;
  if (result == null || result.files.isEmpty) return;
  onPicked(result.files.first);
}
