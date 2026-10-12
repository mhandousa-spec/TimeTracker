/// Module: messaging / main_controller / helper / chat_state_icons.dart
/// Purpose: The small pin / mute icons shown under the date on a chat card
///          (direct message or group). Bug report #20–#22.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'chat_settings_service.dart';

class ChatStateIcons extends StatelessWidget {
  const ChatStateIcons({
    super.key,
    required this.chatKey,
    this.hasPinnedMessage = false,
  });

  /// ChatSettingsService key of the chat this card opens.
  final String chatKey;

  /// A message inside the chat is pinned — also shows the pin.
  final bool hasPinnedMessage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ChatSettingsService.pinnedChats,
      builder: (context, pinned, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: ChatSettingsService.mutedChats,
          builder: (context, muted, _) {
            final bool showPin = hasPinnedMessage || pinned.contains(chatKey);
            final bool showMute = muted.contains(chatKey);
            if (!showPin && !showMute) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsetsDirectional.only(top: 4.h, end: 4.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.sp,
                children: [
                  if (showMute)
                    Icon(
                      Icons.volume_off_rounded,
                      size: 14.sp,
                      color: AppColors.secondaryBlack,
                    ),
                  if (showPin)
                    SvgPicture.asset(
                      'assets/icons_assets/messaging_assets/pin_svg.svg',
                      width: 14.sp,
                      height: 14.sp,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
