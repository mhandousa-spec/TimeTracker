/// Module: messaging / chat / presentation/ui/widgets/dialogs/disappearing_messages_dialog.dart
/// Purpose: Disappearing Messages dialog (Figma 6799:16789) — 24 Hours /
///          7 Days / 90 Days / Always / Off.
///
///   • 24 Hours / 7 Days / 90 Days: a message disappears that long after
///     it was sent.
///   • Always: a message disappears once it has been seen (from the next
///     time the chat is opened, so it never vanishes while being read).
///   • Off: nothing disappears; hidden messages come back.
/// Created At: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import 'chat_dialog_widgets.dart';

/// Hours per option; 0 = Always, -1 = Off (null in the cubit).
enum DisappearingOption {
  hours24(24),
  days7(168),
  days90(2160),
  always(0),
  off(-1);

  const DisappearingOption(this.hours);
  final int hours;

  static DisappearingOption fromHours(int? hours) {
    if (hours == null) return DisappearingOption.off;
    return DisappearingOption.values.firstWhere((o) => o.hours == hours,
        orElse: () => DisappearingOption.hours24);
  }

  String label(bool isAr) => switch (this) {
        DisappearingOption.hours24 => isAr ? '24 ساعة' : '24 Hours',
        DisappearingOption.days7 => isAr ? '7 أيام' : '7 Days',
        DisappearingOption.days90 => isAr ? '90 يوماً' : '90 Days',
        DisappearingOption.always => isAr ? 'دائماً' : 'Always',
        DisappearingOption.off => isAr ? 'إيقاف' : 'Off',
      };
}

Future<void> showDisappearingMessagesDialog(
    BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = chatDialogIsAr(context);
  final DisappearingOption current =
      DisappearingOption.fromHours(cubit.disappearingHoursOption);

  final DisappearingOption? picked = await showChatDialog<DisappearingOption>(
    context: context,
    width: 335.w,
    child: _DisappearingMessagesDialog(initial: current),
  );
  if (picked == null || picked == current || !context.mounted) return;

  final int? hours = picked == DisappearingOption.off ? null : picked.hours;
  final bool ok = await CustomDialogManager.runWithLoading<bool>(
      context, () => cubit.setDisappearingOption(hours));
  if (!ok) {
    chatDialogToast(isAr
        ? 'تعذر تحديث الرسائل المؤقتة'
        : 'Could not update disappearing messages');
    return;
  }
  chatDialogToast(hours == null
      ? (isAr ? 'تم إيقاف الرسائل المؤقتة' : 'Disappearing messages off')
      : (isAr
          ? 'الرسائل المؤقتة: ${picked.label(true)}'
          : 'Disappearing messages: ${picked.label(false)}'));
}

class _DisappearingMessagesDialog extends StatefulWidget {
  const _DisappearingMessagesDialog({required this.initial});
  final DisappearingOption initial;

  @override
  State<_DisappearingMessagesDialog> createState() =>
      _DisappearingMessagesDialogState();
}

class _DisappearingMessagesDialogState
    extends State<_DisappearingMessagesDialog> {
  late DisappearingOption _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatDialogTitle(isAr ? 'الرسائل المؤقتة' : 'Disappearing Messages'),
          SizedBox(height: 8.h),
          ChatDialogSubtitle(isAr
              ? 'اجعل الرسائل في هذه المحادثة تختفي'
              : 'Make Messages In This Chat Disappear'),
          SizedBox(height: 12.h),
          for (final DisappearingOption o in DisappearingOption.values)
            ChatRadioOption<DisappearingOption>(
              value: o,
              groupValue: _selected,
              label: o.label(isAr),
              onChanged: (v) => setState(() => _selected = v),
            ),
          SizedBox(height: 16.h),
          ChatDialogButtons(
            primaryLabel: isAr ? 'تطبيق' : 'Apply',
            onPrimary: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
    );
  }
}
