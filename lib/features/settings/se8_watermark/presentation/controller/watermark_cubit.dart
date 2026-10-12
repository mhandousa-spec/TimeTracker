/// Module: settings / se8_watermark / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_cubit.dart
/// Purpose: Declares `WatermarkState` and `WatermarkCubit` — the edit session
///          behind the Watermark settings screen.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Holds TWO copies of the settings: [WatermarkState.saved] (what is stored)
/// and [WatermarkState.draft] (what the sliders are showing). Everything the
/// screen needs follows from the pair — the preview renders the draft, "Save"
/// is enabled only while they differ, and "Discard Changes" is just
/// `draft = saved`. Editing the stored copy in place would leave nothing to
/// discard back to.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/data/repository/watermark_repository.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';

@immutable
class WatermarkState {
  /// The last persisted settings.
  final WatermarkSettings saved;

  /// What the controls are currently showing.
  final WatermarkSettings draft;

  /// A load or a save is in flight.
  final bool busy;

  /// Set when a load or save failed. Null clears it.
  final String? error;

  const WatermarkState({
    required this.saved,
    required this.draft,
    this.busy = false,
    this.error,
  });

  /// True while the draft differs from what is stored — drives Save/Discard.
  bool get isDirty => draft != saved;

  WatermarkState copyWith({
    WatermarkSettings? saved,
    WatermarkSettings? draft,
    bool? busy,
    String? error,
  }) {
    return WatermarkState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      busy: busy ?? this.busy,
      // `error` is deliberately NOT `error ?? this.error`: it must clear on the
      // next emit, or one failed write keeps re-raising its dialog.
      error: error,
    );
  }
}

class WatermarkCubit extends Cubit<WatermarkState> {
  WatermarkCubit({WatermarkRepository? repository})
      : _repository = repository ?? WatermarkRepository(),
        super(const WatermarkState(
          saved: WatermarkSettings.initial,
          draft: WatermarkSettings.initial,
        ));

  final WatermarkRepository _repository;

  void emitSafely(WatermarkState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Guards [ensureLoaded] so the many WatermarkLayers on one screen do not
  /// each queue a read.
  bool _loadRequested = false;

  /// Function Name: [ensureLoaded]
  ///
  /// Purpose: Read the stored settings once, however many widgets ask.
  ///
  /// Called from `WatermarkLayer.build`, which runs on every rebuild — so it
  /// must be idempotent, and it must not `emit` synchronously. Emitting during
  /// the build phase marks the watching widget dirty while it is being built
  /// (the "setState() called during build" assertion), so the read is deferred
  /// to after the frame.
  void ensureLoaded() {
    if (_loadRequested) return;
    _loadRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      load();
    });
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read the stored settings and start a clean edit session.
  ///
  /// A failed read leaves the defaults in place rather than blocking the
  /// screen: the admin can still see the controls and save over them.
  ///
  /// Returns: [Future<void>]
  Future<void> load() async {
    _loadRequested = true;
    emitSafely(state.copyWith(busy: true));
    try {
      final WatermarkSettings stored = await _repository.load();
      emitSafely(WatermarkState(saved: stored, draft: stored));
    } catch (e, stackTrace) {
      debugPrint('WatermarkCubit.load failed: $e\n$stackTrace');
      emitSafely(state.copyWith(busy: false, error: e.toString()));
    }
  }

  // ── Draft edits ───────────────────────────────────────────────────────────
  // Each one is a copyWith on the draft only. None of them touch `saved`.

  void selectField(WatermarkField field) => _edit(state.draft.copyWith(field: field));

  void toggleDate(bool value) => _edit(state.draft.copyWith(showDate: value));

  void toggleTime(bool value) => _edit(state.draft.copyWith(showTime: value));

  void setOpacity(double value) => _edit(state.draft.copyWith(opacity: value));

  void setDensity(int value) => _edit(state.draft.copyWith(density: value));

  void setFontSize(double value) => _edit(state.draft.copyWith(fontSize: value));

  void setAngle(double value) => _edit(state.draft.copyWith(angle: value));

  void setColor(Color value) => _edit(state.draft.copyWith(color: value));

  /// ADDED 31/8/2026 — the Text / Bubble radio pair.
  void setStyleMode(WatermarkStyleMode value) =>
      _edit(state.draft.copyWith(styleMode: value));

  /// Function Name: [toggleModule]
  ///
  /// Purpose: Add or remove one module from the stamped set.
  ///
  /// ADDED 31/8/2026 — backs the "Watermark Modules" grid.
  ///
  /// Builds a NEW set rather than mutating `state.draft.modules` in place. An
  /// in-place edit does not change the object's identity, so `isDirty` would
  /// compare the set against itself, see no difference, and leave Save greyed
  /// out — the tile would tick and the change would be unsaveable.
  void toggleModule(Modules module) {
    final Set<String> next = <String>{...state.draft.modules};
    // `remove` returns whether it was there, so this is one lookup, not two.
    if (!next.remove(module.name)) next.add(module.name);
    _edit(state.draft.copyWith(modules: next));
  }

  /// Function Name: [setAllModules]
  ///
  /// Purpose: Select every module, or none.
  ///
  /// Fifteen tiles is a lot of tapping to reach "all but one", which is the
  /// usual shape of this setting.
  void setAllModules(bool selected) => _edit(state.draft.copyWith(
        modules: selected ? WatermarkSettings.allModuleNames : <String>{},
      ));

  void _edit(WatermarkSettings draft) =>
      emitSafely(state.copyWith(draft: draft));

  /// Function Name: [discardChanges]
  ///
  /// Purpose: Throw away the draft and go back to what is stored.
  void discardChanges() => emitSafely(state.copyWith(draft: state.saved));

  /// Function Name: [resetToDefault]
  ///
  /// Purpose: Put the Figma defaults into the DRAFT.
  ///
  /// Deliberately not a save: "Reset to Default" and "Save" are two separate
  /// buttons on the design, so resetting has to stay undoable with Discard
  /// until the admin commits it.
  ///
  /// SIMPLIFIED 2/9/2026 — this used to carry `enabled` over from `saved`, so
  /// that resetting the APPEARANCE could not turn the watermark off as a side
  /// effect. There is no `enabled` any more; the module set IS the on/off, and
  /// `initial.modules` is every module, so a reset now turns everything ON.
  /// That is the intended reading of "reset to default" and it stays undoable
  /// with Discard until the admin presses Save.
  void resetToDefault() =>
      emitSafely(state.copyWith(draft: WatermarkSettings.initial));

  /// Function Name: [save]
  ///
  /// Purpose: Persist the draft and make it the new baseline.
  ///
  /// Returns: [Future<bool>] whether the write succeeded. `CustomDialogManager
  /// .showDialogFlow` only advances to its success step when `onConfirm`
  /// returns true, so a failed write must report false rather than throwing or
  /// returning void — otherwise the user is congratulated on a save that did
  /// not happen.
  Future<bool> save() async {
    if (!state.isDirty || state.busy) return false;
    emitSafely(state.copyWith(busy: true));
    try {
      await _repository.save(state.draft);
      emitSafely(WatermarkState(saved: state.draft, draft: state.draft));
      return true;
    } catch (e, stackTrace) {
      debugPrint('WatermarkCubit.save failed: $e\n$stackTrace');
      emitSafely(state.copyWith(busy: false, error: e.toString()));
      return false;
    }
  }
}
