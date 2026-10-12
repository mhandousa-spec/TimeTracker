/// Module: messaging / chat / presentation/ui/widgets/app_bar/scheduled_message_banner.dart
/// Purpose: Yellow "Scheduled Message: 12 Feb 2025 At 10:30 PM" chip shown
///          left of the ⋮ in the chat header (Figma 6799:8931) while the
///          current user has a pending scheduled message in the open chat.
///          Hidden when there is none.
/// Created At: 30/9/2026
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';

class ScheduledMessageBanner extends StatefulWidget {
  const ScheduledMessageBanner({super.key});

  @override
  State<ScheduledMessageBanner> createState() => _ScheduledMessageBannerState();
}

class _ScheduledMessageBannerState extends State<ScheduledMessageBanner> {
  String _key = '';
  Stream<DateTime?>? _stream;

  /// Re-subscribes only when the open chat changes.
  Stream<DateTime?> _streamFor(MasterChatCubit cubit) {
    final String key = cubit.chatSettingsKey;
    if (_stream == null || key != _key) {
      _key = key;
      _stream = cubit.nextScheduledMessage();
    }
    return _stream!;
  }

  @override
  Widget build(BuildContext context) {
    final MasterChatCubit cubit = context.watch<MasterChatCubit>();
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return StreamBuilder<DateTime?>(
      stream: _streamFor(cubit),
      builder: (context, snap) {
        final DateTime? next = snap.data;
        if (next == null) return const SizedBox.shrink();
        final String locale = isAr ? 'ar' : 'en';
        final String when =
            '${DateFormat('dd MMM yyyy', locale).format(next)} '
            '${isAr ? 'الساعة' : 'At'} '
            '${DateFormat('hh:mm a', locale).format(next)}';
        return Container(
          height: 20.h,
          constraints: BoxConstraints(maxWidth: 210.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          margin: EdgeInsetsDirectional.only(end: 6.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${isAr ? 'رسالة مجدولة' : 'Scheduled Message'}: $when',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize10Weight400
                .copyWith(color: AppColors.textButton),
          ),
        );
      },
    );
  }
}
