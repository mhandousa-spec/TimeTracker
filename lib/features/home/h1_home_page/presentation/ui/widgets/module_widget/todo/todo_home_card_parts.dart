/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_home_card_parts.dart
/// Purpose: Declares the pieces the three home To-Do cards share —
///          `TodoHomeCardMetrics`, `TodoHomeCardScope` (cubit + card frame +
///          tap to open the module + loading / error states),
///          `TodoHomeCardHeader`, `TodoHomeCountRow` and `openTodoModule`.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Owner round 3: header icon = the To-Do MODULE icon
///          (`Modules.todo.iconPath`); one height for all three cards (the
///          checklist card is the reference); widths from the home grid
///          (`kHomeWidgetNarrowWidth` / `kHomeWidgetCompactWidth`, same as the
///          Services / Roles cards); count rows = icon + label + count in
///          colours readable in dark mode; `openTodoModule(todoId:)`.
///
/// Figma: To-Do widget node 130:8096 (three cards: counts · top 3 · priority).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Sizes shared by the three home To-Do cards.
abstract final class TodoHomeCardMetrics {
  /// Totals / priority cards — one home-grid column, like Services'
  /// "My Request" and "Service" cards.
  static double get narrowWidth => kHomeWidgetNarrowWidth.w;

  /// Checklist card — the home grid's three-stat width (Roles cards).
  static double get wideWidth => kHomeWidgetCompactWidth.w;

  /// ONE height for all three cards, taken from the checklist card: padding
  /// 20 · header 21 · gap 8 · three single-line rows 3 x 18 + 2 x 8, plus
  /// room for a title that wraps. The totals / priority bodies fit inside.
  static double get height => 140.sp;

  /// Line height pinned on every text in the cards so the bodies above
  /// measure the same in English and Arabic fonts.
  static const double lineHeight = 1.5;
}

/// Function Name: [openTodoModule]
///
/// Purpose: Low haptic, then open the To-Do module — on its list, or with
/// [todoId]'s details pushed on top of the list.
///
/// Parameters:
///   [BuildContext] context
///   [String?] todoId: open this to-do's details (home checklist row).
///
/// Return type: [void]
void openTodoModule(BuildContext context, {String? todoId}) {
  HapticController.low();
  navigateTo(context, TodoModuleEntry(initialTodoId: todoId));
}

/// Provides a [TodoHomeCubit], draws the card frame (fixed
/// [TodoHomeCardMetrics.height]) and the header, and hands [builder] the
/// loaded state; the body fills the height left under the header. Tapping
/// anywhere on the card opens the module.
class TodoHomeCardScope extends StatelessWidget {
  const TodoHomeCardScope({
    required this.width,
    required this.builder,
    super.key,
  });

  final double width;
  final Widget Function(BuildContext context, TodoHomeState state) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoHomeCubit>(
      create: (_) => TodoHomeCubit()..init(),
      child: SizedBox(
        width: width,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openTodoModule(context),
          child: StandardContainer(
            height: TodoHomeCardMetrics.height,
            child: BlocConsumer<TodoHomeCubit, TodoHomeState>(
              listenWhen: (TodoHomeState p, TodoHomeState c) =>
                  c.actionError != null && p.actionError != c.actionError,
              listener: _showActionError,
              builder: (BuildContext context, TodoHomeState state) => Column(
                spacing: 8.sp,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const TodoHomeCardHeader(),
                  Expanded(child: _body(context, state)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, TodoHomeState state) {
    switch (state.status) {
      case TodoHomeStatus.loading:
        return Center(
          child: SizedBox(
            width: 20.sp,
            height: 20.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      case TodoHomeStatus.failure:
        return _message(S.of(context).todoLoadError);
      case TodoHomeStatus.noAccess:
        return _message(S.of(context).todoNoAccess);
      case TodoHomeStatus.loaded:
        return builder(context, state);
    }
  }

  Widget _message(String text) => Text(
        text,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
      );

  void _showActionError(BuildContext context, TodoHomeState state) {
    final TodoHomeActionError? error = state.actionError;
    context.read<TodoHomeCubit>().clearActionError();
    if (error == null) return;
    showErrorDialog(
      context: context,
      title: S.of(context).error,
      subtitle: error == TodoHomeActionError.noPermission
          ? S.of(context).todoNoPermission
          : S.of(context).todoSaveError,
      closeLabel: S.of(context).ok,
    );
  }
}

/// "To-Do List" + the To-Do module icon — the first row of every To-Do card.
class TodoHomeCardHeader extends StatelessWidget {
  const TodoHomeCardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.sp,
      children: <Widget>[
        Expanded(
          child: Text(
            S.of(context).homeScreenToDoListTitle,
            style: StyleText.fontSize14Weight700.copyWith(
              color: AppColors.text,
              height: TodoHomeCardMetrics.lineHeight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Same svg as the drawer / nav entry, tinted like the other modules'
        // home-card icons (owner, round 3).
        CustomSvgImage(
          assetPath: Modules.todo.iconPath,
          width: 20.sp,
          height: 20.sp,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

/// One "icon · label ........ count" row on the totals and priority cards.
///
/// The icon sits white (or [glyphColor]) on a solid [color] circle, and the
/// label and count use the theme text colour — the thin coloured glyphs
/// alone were nearly invisible on the dark card (owner, round 3).
class TodoHomeCountRow extends StatelessWidget {
  const TodoHomeCountRow({
    required this.iconPath,
    required this.color,
    required this.label,
    required this.count,
    this.glyphColor,
    super.key,
  });

  final String iconPath;

  /// Status / priority colour (circle fill).
  final Color color;

  /// Glyph tint; defaults to white. Pass a dark colour on a light fill.
  final Color? glyphColor;

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = StyleText.fontSize12Weight500.copyWith(
      color: AppColors.text,
      height: TodoHomeCardMetrics.lineHeight,
    );
    return Row(
      spacing: 4.sp,
      children: <Widget>[
        Container(
          width: 18.sp,
          height: 18.sp,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: CustomSvgImage(
            assetPath: iconPath,
            width: 11.sp,
            height: 11.sp,
            color: glyphColor ?? AppColors.white,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          LocalizedNumber.of(context, count),
          style: StyleText.fontSize12Weight600.copyWith(
            color: AppColors.text,
            height: TodoHomeCardMetrics.lineHeight,
          ),
        ),
      ],
    );
  }
}
