/// Module: messaging / chat / presentation/ui/widgets/dialogs/mute_notifications_dialog.dart
/// Purpose: Mute Notifications dialog (Figma 6799:16763) — 8 Hours / 1 Week /
///          Always. Opened from the chat ⋮ menu; when the chat is already
///          muted the menu unmutes directly instead.
/// Created At: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import 'chat_dialog_widgets.dart';

enum MuteOption { eightHours, oneWeek, always }

extension on MuteOption {
  Duration? get duration => switch (this) {
        MuteOption.eightHours => const Duration(hours: 8),
        MuteOption.oneWeek => const Duration(days: 7),
        MuteOption.always => null,
      };

  String label(bool isAr) => switch (this) {
        MuteOption.eightHours => isAr ? '8 ساعات' : '8 Hours',
        MuteOption.oneWeek => isAr ? 'أسبوع' : '1 Week',
        MuteOption.always => isAr ? 'دائماً' : 'Always',
      };
}

Future<void> showMuteNotificationsDialog(
    BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = chatDialogIsAr(context);
  if (cubit.isChatMuted) {
    final bool ok = await cubit.unmuteChat();
    chatDialogToast(ok
        ? (isAr ? 'تم إلغاء كتم الإشعارات' : 'Notifications unmuted')
        : (isAr ? 'تعذر إلغاء الكتم' : 'Could not unmute'));
    return;
  }

  final MuteOption? option = await showChatDialog<MuteOption>(
    context: context,
    width: 335.w,
    child: const _MuteNotificationsDialog(),
  );
  if (option == null || !context.mounted) return;

  final bool ok = await CustomDialogManager.runWithLoading<bool>(
      context, () => cubit.muteChatFor(option.duration));
  chatDialogToast(ok
      ? (isAr ? 'تم كتم الإشعارات' : 'Notifications muted')
      : (isAr ? 'تعذر كتم الإشعارات' : 'Could not mute notifications'));
}

class _MuteNotificationsDialog extends StatefulWidget {
  const _MuteNotificationsDialog();

  @override
  State<_MuteNotificationsDialog> createState() =>
      _MuteNotificationsDialogState();
}

class _MuteNotificationsDialogState extends State<_MuteNotificationsDialog> {
  MuteOption _selected = MuteOption.eightHours;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatDialogTitle(isAr ? 'كتم الإشعارات' : 'Mute Notifications'),
          SizedBox(height: 8.h),
          Center(
            child: SizedBox(
              width: 264.w,
              child: ChatDialogSubtitle(isAr
                  ? 'لن يرى أحد في هذه المحادثة أنك كتمتها، وستظل تتلقى إشعاراً إذا تمت الإشارة إليك.'
                  : 'No One Else In This Chat Will See That You Muted It, '
                      'And You Will Still Be Notified If You Are Mentioned.'),
            ),
          ),
          SizedBox(height: 12.h),
          for (final MuteOption o in MuteOption.values)
            ChatRadioOption<MuteOption>(
              value: o,
              groupValue: _selected,
              label: o.label(isAr),
              onChanged: (v) => setState(() => _selected = v),
            ),
          SizedBox(height: 16.h),
          ChatDialogButtons(
            primaryLabel: isAr ? 'كتم' : 'Mute',
            onPrimary: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
    );
  }
}
