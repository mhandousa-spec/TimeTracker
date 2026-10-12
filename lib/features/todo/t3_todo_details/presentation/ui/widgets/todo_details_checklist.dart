/// Module: todo / t3_todo_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_details_checklist.dart
/// Purpose: Declares `TodoDetailsChecklist` — the checklist on the details
///          card: one line per item (check · title · red ⊖ remove) and the
///          core `CustomAddRowButton` "+ item" that opens an inline field to
///          add one.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma (1:31079): check 20, 5 gap, Cairo 12 medium title (struck through
/// when done), ⊖ 18 red at a fixed start offset (~194 from the check), lines
/// 35 apart. "+ item" is the shared `CustomAddRowButton` (round 2, 7/10/2026:
/// the hand-made copy used `AppColors.text`, which went white in dark mode).
///
/// The widget only reports intents through callbacks — the page talks to
/// `TodoActionsCubit` and fires the haptics. The field's controller and focus
/// node live here (UI state, MASTER_CODE_REVIEW §16), never in a cubit.
/// With [TodoDetailsChecklist.editable] false (no Edit permission, or the
/// to-do is deleted) every editing control is hidden and ticks are inert.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/100-custom_add_row_button.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/widgets/todo_badges.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TodoDetailsChecklist extends StatefulWidget {
  const TodoDetailsChecklist({
    super.key,
    required this.items,
    required this.editable,
    required this.onToggle,
    required this.onRemove,
    required this.onAdd,
  });

  final List<TodoItem> items;

  /// False hides ⊖ and "+ item" and makes the checks display-only.
  final bool editable;

  /// Tick / untick one line (caller fires the Low haptic).
  final ValueChanged<TodoItem> onToggle;

  /// Remove one line (caller fires the High haptic).
  final ValueChanged<TodoItem> onRemove;

  /// Add a line with the typed title (caller fires the Medium haptic).
  final ValueChanged<String> onAdd;

  @override
  State<TodoDetailsChecklist> createState() => _TodoDetailsChecklistState();
}

class _TodoDetailsChecklistState extends State<TodoDetailsChecklist> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// "+ item": opens the field; with text typed it adds it; with the field
  /// open and empty it closes it again.
  void _onAddPressed() {
    if (!_adding) {
      setState(() => _adding = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
      return;
    }
    if (_controller.text.trim().isEmpty) {
      _focus.unfocus();
      setState(() => _adding = false);
      return;
    }
    _submit(_controller.text);
  }

  /// Keyboard "done" / "+ item" with text: report it, clear the field and keep
  /// it open for the next line.
  void _submit(String value) {
    if (value.trim().isEmpty) return;
    widget.onAdd(value);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bool editable = widget.editable;
    return AnimatedSizeWrap(
      alignment: AlignmentDirectional.topStart.resolve(
        Directionality.of(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final TodoItem item in widget.items)
            _ChecklistLine(
              key: ValueKey<String>(item.id),
              item: item,
              onToggle: editable ? () => widget.onToggle(item) : null,
              onRemove: editable ? () => widget.onRemove(item) : null,
            ),
          if (editable && _adding) ...<Widget>[
            SizedBox(
              width: 300.sp,
              child: CustomTextField(
                controller: _controller,
                focusNode: _focus,
                hint: S.of(context).todoItemHint,
                height: 36,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
              ),
            ),
            SizedBox(height: 10.sp),
          ],
          // Core "+ item" button (theme `header` fill + white content, so it
          // reads in light AND dark mode); it fires the Medium haptic itself.
          if (editable)
            CustomAddRowButton(
              label: S.of(context).item,
              onTap: _onAddPressed,
            ),
        ],
      ),
    );
  }
}

/// One checklist line: check · title · ⊖ (hidden when [onRemove] is null).
class _ChecklistLine extends StatelessWidget {
  const _ChecklistLine({
    super.key,
    required this.item,
    this.onToggle,
    this.onRemove,
  });

  final TodoItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? remove = onRemove;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 15.sp),
      child: Row(
        children: <Widget>[
          TodoCheckIcon(isDone: item.isDone, onTap: onToggle),
          SizedBox(width: 5.sp),
          Flexible(
            child: ConstrainedBox(
              // Keeps the ⊖ column aligned like Figma for short titles; long
              // titles push it along instead of being cut.
              constraints: BoxConstraints(minWidth: 165.sp),
              child: Text(
                item.title,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.text,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.text,
                ),
              ),
            ),
          ),
          if (remove != null) ...<Widget>[
            SizedBox(width: 4.sp),
            Semantics(
              button: true,
              label: S.of(context).todoRemoveItem,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: remove,
                child: Padding(
                  padding: EdgeInsetsDirectional.all(5.sp),
                  child: CustomSvgImage(
                    assetPath: AppAssets.minusCircle,
                    width: 18.sp,
                    height: 18.sp,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
