import 'package:url_launcher/url_launcher.dart';

/// Opens a previously-uploaded GRC document (a Firebase Storage download
/// URL) in the device's default external viewer/browser — the same
/// `launchUrl` pattern already used for attachments elsewhere in the app
/// (see the task-management attachment widgets).
Future<void> openGrcDocument(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
