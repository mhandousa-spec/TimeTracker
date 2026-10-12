/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: export_directory.dart
/// Purpose: Declares `ExportDirectory` — the one place that decides where a
///          generated file (CSV, PDF, report) is written so the user can
///          actually find it.
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Reported: "when export in role he not export". It did export. Every export
/// in the app wrote to `getApplicationDocumentsDirectory()`, and because
/// `com.apple.security.app-sandbox` is true, on macOS that is NOT `~/Documents`
/// — it is
///
///     ~/Library/Containers/com.example.knowticedPlus/Data/Documents/
///
/// a folder the user never opens and Finder does not surface. The write
/// succeeded, the success dialog played, and no file appeared anywhere the user
/// looked. Three separate copies of that decision existed:
/// `RoleCubit.exportRolesToCsv`, `core/.../csv_helper.dart` and the services
/// module's own `CSVHelper` — so fixing one left the others broken.
///
/// THE FIX IS AN ENTITLEMENT, NOT A PATH
/// -------------------------------------
/// `getDownloadsDirectory()` is ALSO redirected into the container by the
/// sandbox — writing there fails with `Operation not permitted` — unless the
/// app declares `com.apple.security.files.downloads.read-write`. That
/// entitlement was added on 27/8/2026 (see `macos/Runner/*.entitlements`) for
/// the Knowledge Hub download, and it makes macOS point
/// `getDownloadsDirectory()` at the user's real `~/Downloads`. This helper is
/// the same resolution Knowledge Hub's `_downloadFileDesktop` performs, lifted
/// out so every export shares it.
///
/// If a future export lands in the container again, check that entitlement
/// before changing this file.
///
/// BELT AND BRACES, ADDED 10/9/2026 — "the exported file must appear in
/// Downloads on macOS". The entitlement note above is correct, but it is a
/// build-time promise: a build made before 27/8/2026, a target whose
/// entitlements were not re-applied, or a future edit that drops the key, all
/// silently put `getDownloadsDirectory()` back inside the container — and the
/// export then "succeeds" into a folder nobody can open, with nothing to show
/// for it. [resolve] now RECOGNISES a containerised path and walks back out to
/// the real `~/Downloads`, which the entitlement lets it write to. When the
/// entitlement is doing its job the path never matches and nothing changes.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class ExportDirectory {
  const ExportDirectory._();

  /// Function Name: [resolve]
  ///
  /// Purpose: The directory a generated file should be written to on this
  ///          platform — the one the user can open afterwards.
  ///
  /// Per platform:
  /// - Android: the public `Download` folder, created if missing. Scoped
  ///   storage keeps this readable by the Files app.
  /// - iOS: the app's Documents folder. iOS has no user-visible Downloads; the
  ///   Files app exposes Documents instead, so it is the correct target there.
  /// - macOS / Windows / Linux: the real Downloads folder — see the entitlement
  ///   note above for why this works on macOS — falling back to `$HOME/Downloads`
  ///   (`%USERPROFILE%\Downloads`) and finally to Documents, so an export never
  ///   fails outright just because the folder could not be resolved.
  ///
  /// Returns: [Future<Directory>] an existing, writable directory.
  static Future<Directory> resolve() async {
    if (Platform.isAndroid) {
      final Directory publicDownloads =
          Directory('/storage/emulated/0/Download');
      if (!await publicDownloads.exists()) {
        await publicDownloads.create(recursive: true);
      }
      return publicDownloads;
    }

    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }

    Directory? downloads = _unsandboxed(await getDownloadsDirectory());

    if (downloads == null) {
      // `HOME` is redirected too inside a sandboxed macOS app, so this fallback
      // needs the same treatment as the call above.
      final String? home = Platform.isWindows
          ? Platform.environment['USERPROFILE']
          : Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        downloads = _unsandboxed(
          Directory('$home${Platform.pathSeparator}Downloads'),
        );
      }
    }

    if (downloads == null) {
      return getApplicationDocumentsDirectory();
    }

    // The folder can legitimately be absent (a fresh container, a stripped
    // Linux home). Creating it is cheap; failing to create it means we have no
    // business writing there, so fall back rather than throw at the call site.
    if (!await downloads.exists()) {
      try {
        await downloads.create(recursive: true);
      } catch (e) {
        return getApplicationDocumentsDirectory();
      }
    }

    return downloads;
  }

  /// The same directory outside the macOS app container, when [directory] is
  /// inside one and the real folder exists.
  ///
  /// A sandboxed macOS app sees its home as
  /// `/Users/<name>/Library/Containers/<bundle id>/Data`, and every standard
  /// folder under it. Everything before `/Library/Containers/` is the REAL
  /// home, so the real folder is that prefix plus the tail after `Data`.
  ///
  /// Returns [directory] unchanged on every other platform, on an
  /// already-real path, and whenever the rebuilt path does not exist — a
  /// guess that is not there is worse than the container.
  static Directory? _unsandboxed(Directory? directory) {
    if (directory == null || !Platform.isMacOS) return directory;

    const String marker = '/Library/Containers/';
    final int markerAt = directory.path.indexOf(marker);
    if (markerAt < 0) return directory;

    const String dataSegment = '/Data';
    final int dataAt = directory.path.indexOf(dataSegment, markerAt);
    if (dataAt < 0) return directory;

    final String realPath = directory.path.substring(0, markerAt) +
        directory.path.substring(dataAt + dataSegment.length);
    final Directory real = Directory(realPath);
    if (!real.existsSync()) return directory;

    debugPrint('ExportDirectory: leaving the app container, '
        '${directory.path} -> $realPath');
    return real;
  }

  /// Function Name: [reveal]
  ///
  /// Purpose: Show the user the file that was just written, by opening the
  ///          folder it landed in.
  ///
  /// ADDED 10/9/2026. A desktop export is silent by design — no save panel, no
  /// destination to choose — so the only evidence it produced anything is a
  /// success dialog naming a path the user then has to go and find. Opening the
  /// folder makes the file appear in front of them, which is what "it must
  /// appear in Downloads" actually asks for.
  ///
  /// Best-effort and never fatal: the file is already written and the caller
  /// has already reported success, so a file manager that will not open is not
  /// worth turning a finished export into an error.
  ///
  /// Parameters:
  /// - [filePath]: the file that was written; its FOLDER is what opens.
  static Future<void> reveal(String filePath) async {
    if (Platform.isAndroid || Platform.isIOS) return;
    try {
      final String folder = File(filePath).parent.path;
      await launchUrl(Uri.file(folder));
    } catch (e) {
      debugPrint('ExportDirectory.reveal failed for $filePath: $e');
    }
  }
}
