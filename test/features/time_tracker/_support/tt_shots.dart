/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: tt_shots.dart
/// Purpose: The UI-quality-pass render kit — devices (iPad 1024×1366
///          landscape / portrait, iPhone 390×844), the app's ScreenUtil
///          design-size ladder, a stand-in for the tablet shell (rail +
///          header, nested Navigator so pushed pages stay inside it), the
///          real Cairo / Material fonts, light / dark theme switching and
///          [ttShot] — the whole screen (dialogs included) saved as a PNG.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass)
///
/// PNGs are written only when the `TT_SHOTS` environment variable names an
/// output folder (`TT_SHOTS=/path/to/QA/ui_pass/after flutter test …`);
/// otherwise [ttShot] does nothing and the screens run as plain widget
/// tests (any exception / overflow still fails them).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// One rendered device.
class TtDevice {
  const TtDevice(this.name, this.size);

  final String name;
  final Size size;

  bool get isPhone => size.shortestSide < 600;

  /// main.dart `_getDesignSize` (ScreenUtil ladder).
  Size get designSize {
    final double w = size.width;
    final double h = size.height;
    if (w >= 1920) return const Size(1920, 1080);
    if (w >= 1366) return const Size(1366, 768);
    if (w >= 768) return w > h ? const Size(1024, 768) : const Size(768, 1024);
    return w > h ? const Size(812, 375) : const Size(375, 812);
  }
}

const TtDevice kIpadH = TtDevice('ipadH', Size(1366, 1024));
const TtDevice kIpadV = TtDevice('ipadV', Size(1024, 1366));
const TtDevice kIphone = TtDevice('iphone', Size(390, 844));

/// The owner's own iPad Air 11" (portrait), for spot checks.
const TtDevice kIpad11V = TtDevice('ipad11V', Size(820, 1180));

const List<TtDevice> kTtDevices = <TtDevice>[kIpadH, kIpadV, kIphone];

/// The output folder, or null (no PNGs written).
String? get ttShotDir {
  final String? dir = Platform.environment['TT_SHOTS'];
  return dir == null || dir.trim().isEmpty ? null : dir.trim();
}

Future<void> _font(String family, List<String> files) async {
  final FontLoader loader = FontLoader(family);
  for (final String f in files) {
    final Uint8List bytes = File(f).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// Function Name: [loadTtFonts]
///
/// Purpose: Load Cairo (as both `Cairo` and `CairoArabic`, like the app's
/// StyleText) and the Material icon font. Call from `setUpAll`.
///
/// Return type: [Future<void>]
Future<void> loadTtFonts() async {
  const String cairo = 'assets/fonts/fonts_english/Cairo';
  final List<String> files = <String>[
    for (final String w in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) '$cairo/Cairo-$w.ttf',
  ].where((String f) => File(f).existsSync()).toList();
  await _font('Cairo', files);
  await _font('CairoArabic', files);
  final String? root = Platform.environment['FLUTTER_ROOT'];
  final List<String> candidates = <String>[
    if (root != null) '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final String c in candidates) {
    if (File(c).existsSync()) {
      await _font('MaterialIcons', <String>[c]);
      break;
    }
  }
}

/// Function Name: [setTtTheme]
///
/// Purpose: Switch the app colours (and the GetX locale StyleText reads for
/// its font family). Reset with `setTtTheme(dark: false, locale: 'en')`.
///
/// Return type: [void]
void setTtTheme({required bool dark, required String locale}) {
  AppTheme.isDark = dark;
  AppColors.currentThemeColors = dark ? AppTheme.darkThemeColors : AppTheme.lightThemeColors;
  Get.locale = Locale(locale);
}

/// Function Name: [ttFrame]
///
/// Purpose: The tablet shell stand-in — an 82-wide rail on the start side
/// and an 82-high header (like the app on an iPad), the module in a nested
/// Navigator (pushed pages stay inside, dialogs cover everything). On a
/// phone: a 56-high app bar.
///
/// Return type: [Widget Function(Widget)]
Widget Function(Widget) ttFrame(TtDevice device) => (Widget page) {
      final Widget module = Navigator(
        onGenerateRoute: (RouteSettings s) => MaterialPageRoute<void>(settings: s, builder: (_) => page),
      );
      if (device.isPhone) {
        return Builder(
          builder: (BuildContext context) => ColoredBox(
            color: AppColors.background,
            child: Column(
              children: <Widget>[
                Container(height: 56, color: AppColors.card),
                Expanded(child: module),
              ],
            ),
          ),
        );
      }
      return Builder(
        builder: (BuildContext context) => ColoredBox(
          color: AppColors.background,
          child: Column(
            children: <Widget>[
              Container(height: 82, color: AppColors.card),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Container(width: 82, color: AppColors.card),
                    Expanded(child: module),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    };

/// Function Name: [ttWaitImages]
///
/// Purpose: Give asset images / SVGs real time to decode, then repaint.
///
/// Return type: [Future<void>]
Future<void> ttWaitImages(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Function Name: [ttShot]
///
/// Purpose: Save the whole screen as `<TT_SHOTS>/<name>.png` (no-op without
/// `TT_SHOTS`).
///
/// Return type: [Future<void>]
Future<void> ttShot(WidgetTester tester, String name, {double pixelRatio = 1}) async {
  final String? dir = ttShotDir;
  if (dir == null) return;
  await ttWaitImages(tester);
  await tester.runAsync(() async {
    final RenderView view = tester.binding.renderViews.first;
    final OffsetLayer layer = view.debugLayer! as OffsetLayer;
    final ui.Image image = await layer.toImage(Offset.zero & view.size, pixelRatio: pixelRatio);
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) return;
    final File file = File('$dir/$name.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes.buffer.asUint8List());
  });
}
