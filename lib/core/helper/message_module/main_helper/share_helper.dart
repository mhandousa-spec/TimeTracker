/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: share_helper.dart
/// Purpose: Declares `ShareHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';

import 'package:flutter/services.dart';

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

//Youssef Ashraf
///Helper Class resbonsible for sharing images for printing docs or sharing widgets as images (Qr)

abstract class ShareHelper {
  // function to capture the widget as an image (used in map view)
  static Future<Uint8List> capture({
    required RenderRepaintBoundary boundary,
  }) async {
    ui.Image image = await boundary.toImage(pixelRatio: 1);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    return pngBytes;
  }

  ///used for sharing widgets as Images
  static Future<void> captureAndShare({
    required RenderRepaintBoundary boundary,
  }) async {
    ui.Image image = await boundary.toImage(pixelRatio: 5);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    String mime = 'image/png';
    final XFile xfile =
        XFile.fromData(pngBytes, mimeType: mime, name: '${Random()}.png');

    await Share.shareXFiles(
      [xfile],
    );
  }

  static shareFile(File file, {String? text}) async {
    final XFile xfile = XFile(
      file.path,
    );

    await Share.shareXFiles(
      [xfile],
      text: text,
    );
  }

  static shareText(
    String text,
  ) async {
    await Share.share(
      text,
    );
  }
}
