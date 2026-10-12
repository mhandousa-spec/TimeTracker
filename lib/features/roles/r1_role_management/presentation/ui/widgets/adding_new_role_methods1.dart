/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: adding_new_role_methods1.dart
/// Purpose: Declares `AddingNewRoleMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Script-locked the four text boxes and tightened the
///                      Next gate (script rules + a real module selection).

part of '../pages/adding_new_role.dart';

// ── MODULE GRID CELL METRICS ────────────────────────────────────────────
// One source of truth for the module tiles, shared by the grid delegate in
// adding_new_role.dart and by `_moduleItem` below, so the cell height can
// never drift from what the cell actually draws.
//
// The cell is: a SQUARE icon tile, a fixed gap, then a label box that is
// always two lines tall. Because every part has a fixed height, a name that
// wraps to two lines grows downwards into space already reserved for it —
// it never shortens the square above it and never shifts it up.
// `.sp` is resolved at call time, so these are getters, not consts.
double get _kModuleTileSide => 48.sp;
double get _kModuleTileGap => 6.sp;
/// Two lines of 10.sp text at a 1.2 line height (24.sp), plus a little slack
/// so a taller-rendering glyph can't trip a pixel overflow.
double get _kModuleLabelHeight => 26.sp;
/// Total height of one grid cell — feeds `mainAxisExtent`.
double get kModuleCellExtent =>
    _kModuleTileSide + _kModuleTileGap + _kModuleLabelHeight;

extension AddingNewRoleMethods1 on _AddingNewRoleState {
  // REMOVED 12/8/2026: `_containsArabic` / `_containsEnglish` — dead wrappers
  // over `controller.containsArabic` / `controller.containsEnglish` with no
  // call sites left in this part file. Call the RoleCubit methods directly.
  // ─────────────────────────────────────────────
  // STATUS TOGGLE DIALOG — shared CustomDialogManager flow
  // ─────────────────────────────────────────────
  /// Confirm → apply → success for the role's status switch.
  ///
  /// The whole sequence is [CustomDialogManager.showDialogFlow]: it shows the
  /// confirm dialog, runs [onConfirm] only if the user accepts, and shows the
  /// success dialog only when that returns true. Nothing here draws a dialog of
  /// its own.
  ///
  /// COPY REWRITTEN 29/8/2026 — every line named "the status" without saying
  /// whose, or what it became:
  ///
  ///  * Title was "Changing Status" (تغيير الحالة) — present-tense, as if the
  ///    change were already running, and silent about it being a ROLE. Now
  ///    "Change Role Status" / "تغيير حالة الدور".
  ///  * Success subtitle was the bare word "Activated" / "معطل", which read as
  ///    a label with nothing attached. It now names the field and its new
  ///    value — "Role Status: Active" / "حالة الدور: نشط" — the same wording
  ///    and the same [RoleStatus] table the switch row itself now shows, so
  ///    the dialog and the screen behind it agree word for word.
  ///
  /// Both languages come from the existing ARB entries; nothing here is
  /// English-only or composed by hand.
  Future<void> _showStatusConfirmDialog(
      BuildContext context, bool newValue) async {
    final RoleStatus newStatus =
        newValue ? RoleStatus.active : RoleStatus.inactive;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
      confirmTitle: S.of(context).changeRoleStatus,
      confirmSubtitle: newValue
          ? S.of(context).areYouSureYouWantToActivateThisRole
          : S.of(context).areYouSureYouWantToDeactivateThisRole,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        controller.toggleActiveStatus(newValue);
        return true;
      },
      // FIXED 29/8/2026: was a static check.json + "Changing Status" title,
      // which read like the action was still in progress. Now the animated
      // success lottie and a "Status updated successfully" title.
      successLottie: AppAssets.successful,
      successTitle: S.of(context).statusUpdatedSuccessfully,
      successSubtitle:
          '${S.of(context).roleStatus}: ${newStatus.getLocalizedName(context)}',
    );
  }
  // ── module loading helpers (unchanged) ──────────────────────────────────

  Future<List<String>> _getAllowedModulesForRoleCreation() =>
      controller.getAllowedModulesForRoleCreation();

  // ── field builders (unchanged) ──────────────────────────────────────────

  Widget _buildEnglishNameField() {
    // ✅ Forced LTR: label, hint, value and counter stay left-aligned even when
    // the app locale is Arabic.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomTextField(
        label: 'Role Name',
        hint: 'Role Name',
        controller: controller.roleNameController,
        required: true,
        // ADDED 25/8/2026: English-only. The formatter refuses an edit that
        // ADDS an Arabic character and the field paints its own inline error,
        // so the rule is visible while typing — not only after pressing Next.
        restrictByDirection: true,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        height: 36,
        valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle:
        StyleText.fontSize16Weight400.copyWith(fontSize: 14.sp),
        onChanged: (value) => controller.emitSafely(RoleModuleSelected()),
      ),
    );
  }
  Widget _buildArabicNameField() {
    // ✅ Forced RTL: the Directionality flips the label row and the counter,
    // textDirection/textAlign flip the typed value and the hint.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'اسم الدور',
        hint: 'اسم الدور',
        controller: controller.roleNameControllerAr,
        required: true,
        // ADDED 25/8/2026: Arabic-only, mirror of the English name field.
        restrictByDirection: true,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        height: 36,
        valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle:
        StyleText.fontSize16Weight400.copyWith(fontSize: 14.sp),
        onChanged: (value) => controller.emitSafely(RoleModuleSelected()),
      ),
    );
  }
  Widget _buildEnglishDescriptionField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomTextField(
        label: 'Role Description',
        hint: 'Role Description',
        controller: controller.roleDescriptionController,
        required: true,
        // ADDED 25/8/2026 — English-only, but NOT via `restrictByDirection`.
        //
        // That flag's RTL branch whole-matches Arabic letters and spaces, which
        // a 500-character description cannot satisfy: an ASCII digit or a full
        // stop is enough to fail it. The two description boxes therefore ban
        // the wrong SCRIPT and nothing else — digits, punctuation and line
        // breaks stay legal in both. The name fields, being short, keep the
        // stricter flag.
        //
        // The description fields carry no `onChanged`; the Next gate listens to
        // the TextEditingControllers directly, so typing still re-evaluates it.
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.deny(RegExp(r'[؀-ۿ]')),
        ],
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        maxLines: 3,
        minLines: 3,
        maxLength: 500,
        showCharCount: true,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle:
        StyleText.fontSize16Weight400.copyWith(fontSize: 14.sp),
      ),
    );
  }
  Widget _buildArabicDescriptionField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: 'وصف الدور',
        hint: 'اكتب وصف',
        controller: controller.roleDescriptionControllerAr,
        required: true,
        // ADDED 25/8/2026: Latin letters refused, mirror of the English
        // description box. See the note there for why this is a formatter and
        // not `restrictByDirection`.
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
        ],
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: 3,
        minLines: 3,
        maxLength: 500,
        showCharCount: true,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        valueStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText),
        hintStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        labelStyle:
        StyleText.fontSize16Weight400.copyWith(fontSize: 14.sp),
      ),
    );
  }
  Widget _moduleItem(Modules module, BuildContext context) {
    String moduleString = _moduleEnumToString(module);
    bool isSelected = controller.selectedModules.contains(moduleString);

    // Settings is always on, so it renders in the "active" style too.
    bool isHighlighted = isSelected || module == Modules.settings;

    return InkWell(
      onTap: () async {
        if (module != Modules.settings) {
          await controller.selectModule(moduleString);
        }
      },
      borderRadius: BorderRadius.circular(4.sp),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The tile is a true square: 48.sp a side, but never wider than the
          // cell it sits in, so a narrow column can't stretch it into a
          // rectangle or overflow the grid.
          final double tileSide =
              constraints.maxWidth.isFinite && constraints.maxWidth < _kModuleTileSide
                  ? constraints.maxWidth
                  : _kModuleTileSide;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // FIXED 29/8/2026 (2): was MainAxisAlignment.center, so a cell whose
            // name wrapped to two lines was taller overall and its square rode
            // UP relative to its one-line neighbours — the tiles no longer sat
            // on one line. Every cell now starts at the top of its slot, so all
            // squares share the same top edge whatever their label does.
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── ICON TILE ──────────────────────────────────────────
              // FIXED 29/8/2026: was an Expanded stretch tile, so the icon box
              // filled the cell as a wide rectangle and the module name below it
              // pushed on its height. It is now a fixed SQUARE (width == height)
              // centred in the cell, and the name is a separate row underneath —
              // so the name can wrap without ever changing the tile's size.
              Container(
                width: tileSide,
                height: tileSide,
                padding: EdgeInsets.all(6.sp),
                decoration: BoxDecoration(
                  color:
                  isHighlighted ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: CustomSvgImage(
                  assetPath: module.iconPath,
                  height: 24.sp,
                  width: 24.sp,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    isHighlighted
                        ? AppColors.textButton
                        : AppColors.secondaryBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              SizedBox(height: _kModuleTileGap),

              // ── MODULE NAME ────────────────────────────────────────
              // The label lives in a box that is ALWAYS two lines tall, whether
              // the name needs one line or two. A long name grows downwards
              // into space that was already reserved for it — it never borrows
              // height from the square above it and never moves it.
              SizedBox(
                width: double.infinity,
                height: _kModuleLabelHeight,
                child: Align(
                  // Top-aligned, so the FIRST line of every name sits on the
                  // same baseline and a second line simply hangs below it.
                  alignment: Alignment.topCenter,
                  child: Text(
                    module.getModuleName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
                      fontSize: 10.sp,
                      height: 1.2,
                      color: AppColors.text,
                      fontWeight:
                          isHighlighted ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  /// Whether the first step of role creation is complete enough to continue.
  ///
  /// ADDED 13/8/2026: "التالي" was always enabled and styled as a live primary
  /// action. Pressing it early ran `formKey.validate()`, which painted red
  /// errors — so the only way to learn the form was incomplete was to try.
  /// The button is now visibly disabled until it will actually work.
  ///
  /// Every field on this step is `required: true`, and the module grid is part
  /// of the same step, so "fill all the page" means all four names and
  /// descriptions plus at least one module. `_onNextPressed` still validates —
  /// this only governs whether the button is offered.
  ///
  /// TIGHTENED 25/8/2026 — the old gate asked only "is it non-empty?", which
  /// let two broken states through:
  ///
  ///  * SCRIPT. An Arabic name typed into the English box (or the reverse) is
  ///    non-empty, so Next lit up on a value the field itself was already
  ///    flagging red. Each of the four boxes now refuses the wrong script while
  ///    typing, and the gate re-applies that same box's rule — the strict one
  ///    for the names, the looser prose one for the descriptions — so the
  ///    button and the inline error can never disagree.
  ///  * MODULES. `initAddingRoleController` seeds `selectedModules` with
  ///    `settings` (it is mandatory and its tile is not tappable), so
  ///    `selectedModules.isNotEmpty` was true before the user touched the grid
  ///    and the module half of the gate never bit. It now counts only the
  ///    modules the user can actually choose.
  bool get _canProceedToPermissions =>
      _isEnglishText(controller.roleNameController.text) &&
      _isStrictArabicText(controller.roleNameControllerAr.text) &&
      _isEnglishText(controller.roleDescriptionController.text) &&
      _isArabicText(controller.roleDescriptionControllerAr.text) &&
      _hasSelectedModule;

  /// A filled English field: at least one Latin letter, no Arabic character.
  ///
  /// Mirrors the LTR branch of `CustomTextField`'s own validation. Digits,
  /// punctuation and spaces are allowed — only the wrong SCRIPT is refused.
  bool _isEnglishText(String value) {
    final String text = value.trim();
    if (text.isEmpty) return false;
    if (controller.containsArabic(text)) return false;
    return controller.containsEnglish(text);
  }

  /// A filled Arabic field: at least one Arabic letter, no Latin letter.
  ///
  /// The rule for the description box, where digits and punctuation are part of
  /// ordinary prose.
  bool _isArabicText(String value) {
    final String text = value.trim();
    if (text.isEmpty) return false;
    if (controller.containsEnglish(text)) return false;
    return controller.containsArabic(text);
  }

  /// A filled Arabic NAME: Arabic letters and spaces only, nothing else.
  ///
  /// Mirrors the RTL branch of `CustomTextField`'s own validation, which the
  /// name field opts into through `restrictByDirection`. Keeping the same rule
  /// here is what stops the button and the field's inline error disagreeing.
  bool _isStrictArabicText(String value) {
    final String text = value.trim();
    if (text.isEmpty) return false;
    return RegExp(r'^[؀-ۿ\s]+$').hasMatch(text);
  }

  /// At least one module picked by the user, ignoring the always-on `settings`
  /// module that the cubit adds by itself.
  bool get _hasSelectedModule => controller.selectedModules.any(
        (String module) => RoleCubit.canonicalModuleName(module) != 'settings',
      );

  void _onNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    RoleLogService.log(RoleLogService.actionCreateRole);

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);

    await controller.ensureSettingsSelected();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<RoleCubit>.value(
          value: controller,
          child: RolePermissionSwitches(),
        ),
      ),
    );
  }
  // REMOVED 12/8/2026: `_stringToModuleEnum` wrapper — the module grid now
  // calls RoleCubit.moduleEnumsFor directly.

  String _moduleEnumToString(Modules module) =>
      controller.moduleEnumToSelectionString(module);
}
