/// Module: settings / se8_watermark / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_settings.dart
/// Purpose: Declares `WatermarkField` and `WatermarkSettings`.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Source: Figma BuJXLizpGcK5eHVBqQomXc, ROLE MANAGEMENT > Watermark >
/// Settings Home Page (node 7524:14303). The panel is node 7524:14371.
///
/// The watermark is the diagonal, repeated identity stamp drawn over the app's
/// content so a screenshot carries the identity of whoever took it. This entity
/// is everything the Settings screen lets an admin choose about it; the drawing
/// itself is `WatermarkPreview` / `WatermarkPainter`.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

/// How the stamp is drawn: bare text, or text inside a rounded pill.
///
/// ADDED 31/8/2026. The Figma "Watermark Style" card opens with a
/// Text / Bubble radio pair that had no field behind it, so the control could
/// not be built at all. `WatermarkPainter` reads this to decide whether to
/// paint a rounded background behind each stamp.
enum WatermarkStyleMode {
  text,
  bubble;

  /// Stable storage key. NEVER change these strings — see [WatermarkField.key].
  String get key {
    switch (this) {
      case WatermarkStyleMode.text:
        return 'text';
      case WatermarkStyleMode.bubble:
        return 'bubble';
    }
  }

  static WatermarkStyleMode fromKey(String? key) {
    for (final WatermarkStyleMode mode in WatermarkStyleMode.values) {
      if (mode.key == key) return mode;
    }
    return WatermarkStyleMode.text;
  }
}

/// The modules the "Watermark Modules" grid offers, in Figma's reading order.
///
/// ADDED 31/8/2026. Drawn from [Modules] rather than restated here, so the
/// icons (`Modules.iconPath`) and names (`Modules.getModuleName`) come from
/// `modules_enum.dart` — a rename or a new icon there flows straight through to
/// this screen with no edit in the settings feature.
///
/// NOT every [Modules] value. `database`, `requests`, `notification`,
/// `employees` and `more` are absent: Figma does not draw them.
///
/// CHANGED 2/9/2026 — `home` and `settings` were on that excluded list too, on
/// the reasoning that the stamp on the settings shell is what lets an admin see
/// their own edits take effect, so letting them switch it off there would be a
/// trap. That call has been overridden: the master Active switch is gone, and
/// this grid is now the ONLY on/off control the feature has — so it has to be
/// able to reach every surface the watermark actually covers, Home and the
/// settings shell included. The preview pane still shows the stamp regardless
/// of what these two tiles say, so the "cannot see my own edit" trap does not
/// bite.
///
/// Home is first because it is the surface an admin thinks of first; Settings
/// is last because it is the least likely to be touched.
///
/// KNOWN GAP: Figma also draws a "Risk Register" tile. There is no
/// `Modules.riskRegister` to back it, so it is omitted rather than invented.
/// Adding that enum value is the fix; this list then picks it up.
const List<Modules> kWatermarkModules = <Modules>[
  Modules.home,
  Modules.messages,
  Modules.services,
  Modules.notes,
  Modules.qiyas,
  Modules.inventory,
  Modules.hr,
  Modules.grc,
  Modules.formBuilder,
  Modules.crm,
  Modules.todo,
  Modules.events,
  Modules.roles,
  Modules.tracking,
  Modules.knowledgeHub,
  Modules.tasks,
  Modules.settings,
];

/// Which employee field the stamp is built from.
///
/// Exactly one is active — Figma draws these as a segmented control, not
/// checkboxes. The date and time flags below are additive on top of it.
enum WatermarkField {
  employeeEmail,
  employeePhone,
  employeeName;

  /// Stable key for storage. NEVER change these strings: a stored settings
  /// document resolves back through [fromKey], and an unknown key silently
  /// falls back to [employeeEmail].
  String get key {
    switch (this) {
      case WatermarkField.employeeEmail:
        return 'employee_email';
      case WatermarkField.employeePhone:
        return 'employee_phone';
      case WatermarkField.employeeName:
        return 'employee_name';
    }
  }

  static WatermarkField fromKey(String? key) {
    for (final WatermarkField field in WatermarkField.values) {
      if (field.key == key) return field;
    }
    return WatermarkField.employeeEmail;
  }
}

/// REMOVED 2/9/2026 — `final bool enabled`.
///
/// It was the master Active switch at the top of the Watermark screen: one flag
/// that decided whether the stamp existed at all, checked by `WatermarkPainter`
/// and by every `WatermarkLayer`. The switch is gone from the screen, and a
/// stored flag with no UI is a trap — a company that had saved `false` would
/// have had an invisible watermark and no way to turn it back on.
///
/// **[modules] is the on/off control now.** An empty set means nothing is
/// stamped, which is the same end state the old switch produced. Do not
/// reintroduce a second gate: two places to check is exactly how the preview
/// pane and the live layers drift apart.
///
/// The `enabled` key is simply ignored on read and no longer written, so
/// existing documents need no migration.
@immutable
class WatermarkSettings {
  /// Which employee field is stamped.
  final WatermarkField field;

  /// Append the current date to the stamp.
  final bool showDate;

  /// Append the current time to the stamp.
  final bool showTime;

  /// 0..1. Figma's default reads "40%".
  final double opacity;

  /// How many stamps are tiled across the surface. Figma's default reads "15".
  ///
  /// Deliberately a COUNT rather than a spacing in pixels: a spacing that looks
  /// right on a 1024 desktop is far too sparse on a 375 phone, whereas "fifteen
  /// of them across" holds at every width. `WatermarkPainter` turns it into a
  /// pixel step from the surface it is actually given.
  final int density;

  /// Font size in logical pixels. Figma's default reads "12.0 px".
  final double fontSize;

  /// Rotation in degrees, counter-clockwise. Figma's default reads "45°".
  final double angle;

  /// Stamp colour, before [opacity] is applied.
  final Color color;

  /// Bare text, or text in a rounded pill. ADDED 31/8/2026.
  final WatermarkStyleMode styleMode;

  /// Which modules carry the stamp. ADDED 31/8/2026.
  ///
  /// Holds `Modules.name` STRINGS, not `Modules` values, on purpose: this set
  /// is serialised to Firestore, and storing enum indices would silently
  /// re-point every stored selection the next time somebody inserts a value in
  /// the middle of `Modules`. Names survive reordering; an unknown name is
  /// dropped on read (see [fromMap]) rather than throwing.
  ///
  /// An EMPTY set means "no module is stamped", which is a real, reachable
  /// choice — it is not treated as "unset". A document with no `modules` key at
  /// all is what falls back to everything; see [fromMap].
  final Set<String> modules;

  const WatermarkSettings({
    required this.field,
    required this.showDate,
    required this.showTime,
    required this.opacity,
    required this.density,
    required this.fontSize,
    required this.angle,
    required this.color,
    required this.styleMode,
    required this.modules,
  });

  /// Every module in [kWatermarkModules], by name.
  static Set<String> get allModuleNames =>
      kWatermarkModules.map((Modules m) => m.name).toSet();

  /// Whether [module] should be stamped under these settings.
  bool stampsModule(Modules module) => modules.contains(module.name);

  /// The values Figma shows on the unedited screen — and what "Reset to
  /// Default" restores.
  static const WatermarkSettings initial = WatermarkSettings(
    field: WatermarkField.employeeEmail,
    showDate: true,
    showTime: false,
    opacity: 0.4,
    density: 15,
    fontSize: 12,
    angle: 45,
    color: Color(0xFF2D2D35),
    styleMode: WatermarkStyleMode.text,
    // ALL modules, not the single tile Figma draws highlighted. The mockup
    // shows Messages selected as a state illustration, not as the default: a
    // watermark is a security control, and shipping it defaulted to one module
    // would leave fourteen screens unstamped for anyone who never opens this
    // page. Opting OUT is the deliberate act; opting in is not.
    //
    // `<String>{...}` spread rather than `allModuleNames` because `initial` is
    // `const` and the getter is not.
    modules: <String>{
      'home',
      'messages',
      'services',
      'notes',
      'qiyas',
      'inventory',
      'hr',
      'grc',
      'formBuilder',
      'crm',
      'todo',
      'events',
      'roles',
      'tracking',
      'knowledgeHub',
      'tasks',
      'settings',
    },
  );

  // Ranges the sliders are bound to. Kept here rather than in the widget so the
  // UI and any stored value are clamped against one definition.
  static const double minOpacity = 0.05;
  static const double maxOpacity = 1;
  static const int minDensity = 3;
  static const int maxDensity = 40;
  static const double minFontSize = 8;
  static const double maxFontSize = 48;
  static const double minAngle = 0;
  static const double maxAngle = 90;

  WatermarkSettings copyWith({
    WatermarkField? field,
    bool? showDate,
    bool? showTime,
    double? opacity,
    int? density,
    double? fontSize,
    double? angle,
    Color? color,
    WatermarkStyleMode? styleMode,
    Set<String>? modules,
  }) {
    return WatermarkSettings(
      field: field ?? this.field,
      showDate: showDate ?? this.showDate,
      showTime: showTime ?? this.showTime,
      opacity: opacity ?? this.opacity,
      density: density ?? this.density,
      fontSize: fontSize ?? this.fontSize,
      angle: angle ?? this.angle,
      color: color ?? this.color,
      styleMode: styleMode ?? this.styleMode,
      // Copied, not aliased. Handing the caller's set straight through would
      // let a later `.add` on it mutate a settings object that is supposed to
      // be immutable — and, worse, mutate `saved` and `draft` together, which
      // is exactly what makes `isDirty` stop noticing module edits.
      modules: <String>{...(modules ?? this.modules)},
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'field': field.key,
        'showDate': showDate,
        'showTime': showTime,
        'opacity': opacity,
        'density': density,
        'fontSize': fontSize,
        'angle': angle,
        // Stored as an int so the document stays readable in the console and
        // survives a JSON round trip; `Color.value` is ARGB.
        'color': color.value,
        'styleMode': styleMode.key,
        // Sorted so two identical selections serialise to the same list and the
        // document stops showing a spurious diff every time the set's iteration
        // order shifts.
        'modules': modules.toList()..sort(),
      };

  /// Every field falls back to [initial] rather than throwing: a settings
  /// document written by an older build must not blank the watermark.
  factory WatermarkSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return initial;

    double asDouble(Object? value, double fallback) =>
        value is num ? value.toDouble() : fallback;
    int asInt(Object? value, int fallback) =>
        value is num ? value.toInt() : fallback;
    bool asBool(Object? value, bool fallback) =>
        value is bool ? value : fallback;

    return WatermarkSettings(
      // NOTE: a legacy document may still carry an 'enabled' key. Nothing reads
      // it and nothing writes it any more — see the class doc. A company that
      // had the watermark switched off turns it off now by clearing the module
      // tiles instead.
      field: WatermarkField.fromKey(map['field'] as String?),
      showDate: asBool(map['showDate'], initial.showDate),
      showTime: asBool(map['showTime'], initial.showTime),
      opacity: asDouble(map['opacity'], initial.opacity)
          .clamp(minOpacity, maxOpacity)
          .toDouble(),
      density:
          asInt(map['density'], initial.density).clamp(minDensity, maxDensity),
      fontSize: asDouble(map['fontSize'], initial.fontSize)
          .clamp(minFontSize, maxFontSize)
          .toDouble(),
      angle: asDouble(map['angle'], initial.angle)
          .clamp(minAngle, maxAngle)
          .toDouble(),
      color: Color(asInt(map['color'], initial.color.value)),
      styleMode: WatermarkStyleMode.fromKey(map['styleMode'] as String?),
      // A document written before this field existed has NO 'modules' key, and
      // it belonged to a company whose watermark covered everything — so a
      // missing key means all modules. A key that IS present is honoured as
      // written, empty list included: that is a choice the admin made on this
      // screen, and since 2/9/2026 it is also how the watermark is switched off
      // — there is no `enabled` flag any more.
      //
      // NOTE: a document written between 31/8/2026 and 2/9/2026 has a 'modules'
      // key that predates the `home` and `settings` tiles, so those two arrive
      // UNTICKED for those companies. That is the honest reading of what was
      // stored; an admin who wants them stamped ticks them once.
      //
      // Unknown names are filtered out rather than kept: a module deleted from
      // `Modules` would otherwise sit in the stored set forever, and
      // `stampsModule` would never match it anyway.
      modules: map.containsKey('modules')
          ? (map['modules'] is Iterable
              ? (map['modules'] as Iterable<dynamic>)
                  .whereType<String>()
                  .where(allModuleNames.contains)
                  .toSet()
              : <String>{})
          : allModuleNames,
    );
  }

  // `==` and `hashCode` are what `WatermarkState.isDirty` is built on, so the
  // two new fields MUST be in both. Leaving `modules` out would mean ticking a
  // module tile left `draft == saved`, Save stayed greyed out, and the edit was
  // silently unsaveable.
  //
  // `modules` is compared with `SetEquality` semantics, not `==`: two sets with
  // the same names are different objects, so the default identity comparison
  // would report EVERY state as dirty and leave Save permanently lit.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatermarkSettings &&
          other.field == field &&
          other.showDate == showDate &&
          other.showTime == showTime &&
          other.opacity == opacity &&
          other.density == density &&
          other.fontSize == fontSize &&
          other.angle == angle &&
          other.color == color &&
          other.styleMode == styleMode &&
          other.modules.length == modules.length &&
          other.modules.containsAll(modules);

  @override
  int get hashCode => Object.hash(
        field,
        showDate,
        showTime,
        opacity,
        density,
        fontSize,
        angle,
        color,
        styleMode,
        // Order-independent, to match the `containsAll` comparison above: an
        // order-sensitive hash would let two equal objects hash differently.
        Object.hashAllUnordered(modules),
      );
}
