/// Module: settings / se8_watermark / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_preview.dart
/// Purpose: Declares `WatermarkPainter` and `WatermarkPreview` — the tiled
///          diagonal stamp, both for the Settings preview pane and for use as
///          a real overlay over app content.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Source: Figma BuJXLizpGcK5eHVBqQomXc, node 7524:14443 (the preview pane on
/// the Watermark settings screen).
///
/// Deliberately NOT preview-only. The Settings screen shows the stamp over a
/// blank card, but the same painter is what should sit over real content later
/// — so it takes a [WatermarkSettings] and a sample string and knows nothing
/// about Settings. Wrap any widget with [WatermarkPreview] to stamp it.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
// `show DateFormat`, not a bare import: intl exports its own `TextDirection`,
// which shadows the dart:ui one that `TextPainter` takes and produces
// "The argument type 'TextDirection' can't be assigned to the parameter type
// 'TextDirection'" — two identically-named types from different libraries.
// DateFormat is the only thing this file needs from intl.
import 'package:intl/intl.dart' show DateFormat;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';

/// The stamp exactly as the preview should render it.
///
/// Built from the SIGNED-IN employee so an admin previews their own identity
/// rather than a fake sample — the point of the feature is that the stamp
/// identifies whoever is looking at the screen.
String watermarkStampText(WatermarkSettings settings) {
  final StringBuffer buffer = StringBuffer();

  String employeeValue() {
    // Guarded twice over. `isEmployeeRegistered` covers the cold-start case
    // where Settings opens before the controller is in the locator; the
    // try/catch covers the field names on `employeeEntity` — `email`,
    // `firstName` and `lastName` are used throughout
    // MainCoreEmployeeController, but the PHONE field's name was not
    // verifiable from here, so a miss degrades to the placeholder instead of
    // throwing inside a build. If you know the real getter, name it below and
    // the guard becomes redundant rather than load-bearing.
    if (!AppControllers.isEmployeeRegistered) return '';
    try {
      final dynamic employee = AppControllers.employee.employeeEntity;
      if (employee == null) return '';
      switch (settings.field) {
        case WatermarkField.employeeEmail:
          return (employee.email ?? '').toString();
        case WatermarkField.employeePhone:
          return (employee.mobileNumber ?? '').toString();
        case WatermarkField.employeeName:
          return '${employee.firstName ?? ''} ${employee.lastName ?? ''}'
              .trim();
      }
    } catch (_) {
      return '';
    }
  }

  final String value = employeeValue();
  buffer.write(value.trim().isEmpty ? _placeholderFor(settings.field) : value);

  final DateTime now = DateTime.now();
  if (settings.showDate) {
    buffer.write('   ${DateFormat('dd-MMM-yyyy').format(now)}');
  }
  if (settings.showTime) {
    buffer.write('   ${DateFormat('hh:mm a').format(now)}');
  }
  return buffer.toString();
}

/// Shown when the employee record has no value for the chosen field, so the
/// preview still demonstrates the layout instead of going blank.
String _placeholderFor(WatermarkField field) {
  switch (field) {
    case WatermarkField.employeeEmail:
      return 'name@company.com';
    case WatermarkField.employeePhone:
      return '+000 000 0000';
    case WatermarkField.employeeName:
      return 'Employee Name';
  }
}

/// Paints [text] repeatedly across the whole canvas at [WatermarkSettings.angle].
class WatermarkPainter extends CustomPainter {
  final WatermarkSettings settings;
  final String text;

  /// Resolved once by the caller (which has a BuildContext) rather than read
  /// from a global: the stamp has to be able to render inside a painter.
  final TextDirection textDirection;

  const WatermarkPainter({
    required this.settings,
    required this.text,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The master switch is honoured HERE rather than at each call site, so the
    // preview pane and every WatermarkLayer in the app cannot disagree about
    // whether the stamp is on.
    if (text.trim().isEmpty || size.isEmpty) return;

    // CHANGED 31/8/2026 — was a bare `TextStyle(fontFamily: 'Cairo', ...)`.
    // Derived from `StyleText.fontSize16Weight500` now, like every other piece
    // of text in this feature, so the stamp inherits the app's family and
    // weight instead of restating them. Hardcoding 'Cairo' meant a theme font
    // change would move every label on the screen except the watermark itself.
    //
    // `fontSize` is still overridden from settings, not from the style: it is a
    // user-controlled slider (WatermarkSettings.fontSize), which is the one
    // dimension here that must NOT follow the type scale.
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: StyleText.fontSize16Weight500.copyWith(
          fontSize: settings.fontSize,
          fontWeight: FontWeight.w500,
          color: settings.color.withOpacity(settings.opacity.clamp(0.0, 1.0)),
        ),
      ),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();

    // `density` is "how many across", so the step is derived from the surface
    // rather than being a fixed pixel gap — see the note on the field itself.
    final int across = settings.density.clamp(
      WatermarkSettings.minDensity,
      WatermarkSettings.maxDensity,
    );

    // THE STAMP'S OWN SIZE IS A HARD FLOOR ON THE STEP.
    //
    // FIXED 25/8/2026 — this was `painter.width * 0.55`, i.e. stamps were
    // allowed to sit on top of each other at 45% overlap, and a long email at
    // a large font size came out as an unreadable smear. A watermark that
    // cannot be read identifies nobody, so legibility wins over hitting the
    // requested count: the step is never less than one whole stamp plus a gap.
    //
    // What that means for the slider: density is a TARGET, reached only while
    // the stamps are small enough to fit. Raise the font size and the count
    // saturates — the row simply stops accepting more. That is the honest
    // behaviour; the alternative is a number that lies.
    final double gapX = settings.fontSize * 1.5;
    final double gapY = settings.fontSize * 1.2;
    final double stepX = math.max(size.width / across, painter.width + gapX);
    final double stepY = math.max(size.height / across, painter.height + gapY);

    final double radians = -settings.angle * math.pi / 180;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // Rotating about the centre leaves the corners bare, so the grid is drawn
    // over a box grown by the diagonal — the largest distance any rotation can
    // pull a point away from the centre — and then rotated. Every visible
    // pixel is covered at any angle.
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final double reach =
        math.sqrt(size.width * size.width + size.height * size.height);

    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(radians);

    // ADDED 31/8/2026 — the "Bubble" style. In bubble mode each stamp sits on a
    // rounded pill of its own colour at a fraction of the text's opacity, so
    // the stamp stays legible over busy or dark content instead of dissolving
    // into it. Built once outside the loop: this paint is identical for every
    // stamp, and allocating one per tile is hundreds of allocations per frame.
    final bool bubble = settings.styleMode == WatermarkStyleMode.bubble;
    final Paint? bubblePaint = bubble
        ? (Paint()
          ..color = settings.color
              // A quarter of the text's opacity. At parity the pill is as loud
              // as the text and the whole surface turns into a block of colour.
              .withOpacity((settings.opacity * 0.25).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill)
        : null;
    final double padX = settings.fontSize * 0.5;
    final double padY = settings.fontSize * 0.25;

    for (double y = -reach; y <= reach; y += stepY) {
      // Offset every other row by half a step: a plain grid reads as columns
      // of text, which is not what the design shows.
      final double stagger = (y / stepY).round().isEven ? 0 : stepX / 2;
      int drawn = 0;
      for (double x = -reach; x <= reach; x += stepX) {
        final Offset at = Offset(x + stagger, y);
        if (bubblePaint != null) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                at.dx - padX,
                at.dy - padY,
                painter.width + padX * 2,
                painter.height + padY * 2,
              ),
              // Fully rounded ends — a pill, which is what "bubble" reads as.
              Radius.circular((painter.height + padY * 2) / 2),
            ),
            bubblePaint,
          );
        }
        painter.paint(canvas, at);
        // Guard against a pathological step producing a runaway loop.
        if (++drawn > 400) break;
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WatermarkPainter oldDelegate) =>
      oldDelegate.settings != settings ||
      oldDelegate.text != text ||
      oldDelegate.textDirection != textDirection;
}

/// Stamps [child] (or a blank surface) with the watermark.
class WatermarkPreview extends StatelessWidget {
  final WatermarkSettings settings;

  /// The already-composed stamp, e.g. "john.doe@company.com  25-Aug-2026 02:30 PM".
  final String text;

  /// What sits under the stamp. Null renders the blank card Figma previews on.
  final Widget? child;

  const WatermarkPreview({
    super.key,
    required this.settings,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        if (child != null) child!,
        // IgnorePointer: the stamp must never eat a tap meant for the content
        // underneath it — that is the whole reason it is an overlay and not a
        // background.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: WatermarkPainter(
                settings: settings,
                text: text,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
