/// Module: messaging / chat / presentation/ui/widgets/dialogs/schedule_message_dialog.dart
/// Purpose: Schedule Message dialog (Figma 6799:16821): message, optional
///          attachment, date and time → Apply stores it with
///          ScheduledMessagesService, which sends it when due.
/// Created At: 30/9/2026
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import 'chat_dialog_widgets.dart';

class _ScheduleRequest {
  const _ScheduleRequest(this.text, this.attachmentPath, this.sendAt);
  final String text;
  final String? attachmentPath;
  final DateTime sendAt;
}

Future<void> showScheduleMessageDialog(
    BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = chatDialogIsAr(context);
  final _ScheduleRequest? req = await showChatDialog<_ScheduleRequest>(
    context: context,
    width: 550.w,
    radius: 4,
    child: const _ScheduleMessageDialog(),
  );
  if (req == null || !context.mounted) return;

  final bool ok = await CustomDialogManager.runWithLoading<bool>(
    context,
    () => cubit.scheduleMessage(
      text: req.text,
      attachmentPath: req.attachmentPath,
      sendAt: req.sendAt,
    ),
  );
  chatDialogToast(ok
      ? (isAr ? 'تمت جدولة الرسالة' : 'Message scheduled')
      : (isAr ? 'تعذر جدولة الرسالة' : 'Could not schedule the message'));
}

class _ScheduleMessageDialog extends StatefulWidget {
  const _ScheduleMessageDialog();

  @override
  State<_ScheduleMessageDialog> createState() => _ScheduleMessageDialogState();
}

class _ScheduleMessageDialogState extends State<_ScheduleMessageDialog> {
  final TextEditingController _message = TextEditingController();
  String? _attachmentPath;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      final String? path = result?.files.single.path;
      if (path != null) setState(() => _attachmentPath = path);
    } catch (e) {
      debugPrint('[ScheduleMessage] ✗ pick attachment: $e');
    }
  }

  void _apply() {
    final bool isAr = chatDialogIsAr(context);
    final String text = _message.text.trim();
    if (text.isEmpty && _attachmentPath == null) {
      chatDialogToast(isAr
          ? 'اكتب رسالة أو أرفق ملفاً'
          : 'Write a message or upload an attachment');
      return;
    }
    final DateTime? sendAt = combineDateTime(_date, _time);
    if (sendAt == null) {
      chatDialogToast(
          isAr ? 'اختر التاريخ والوقت' : 'Choose the date and time');
      return;
    }
    if (!sendAt.isAfter(DateTime.now())) {
      chatDialogToast(isAr
          ? 'اختر وقتاً في المستقبل'
          : 'Choose a time in the future');
      return;
    }
    Navigator.of(context).pop(_ScheduleRequest(text, _attachmentPath, sendAt));
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    final String? fileName =
        _attachmentPath?.split('/').last.split('\\').last;
    return Padding(
      padding: EdgeInsets.all(15.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatDialogTitle(isAr ? 'جدولة رسالة' : 'Schedule Message'),
          SizedBox(height: 16.h),
          ChatFieldLabel(isAr ? 'الرسالة' : 'Message'),
          ChatTextField(
            controller: _message,
            hint: isAr ? 'اكتب هنا' : 'Text Here',
            maxLines: 3,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName ?? (isAr ? 'رفع مرفق' : 'Upload Attachment'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500.copyWith(
                      color: fileName == null
                          ? AppColors.text
                          : AppColors.secondaryBlack),
                ),
              ),
              if (fileName != null)
                IconButton(
                  onPressed: () => setState(() => _attachmentPath = null),
                  icon: Icon(Icons.close,
                      size: 16.r, color: AppColors.secondaryBlack),
                ),
              InkWell(
                onTap: _pickAttachment,
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  width: 171.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/data_grc_assets/upload_minimalistic.svg',
                        width: 18.r,
                        height: 18.r,
                        fit: BoxFit.contain,
                        color: AppColors.textButton,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          isAr ? 'رفع مرفق' : 'Upload Attachment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.textButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChatFieldLabel(isAr ? 'التاريخ' : 'Date'),
                    ChatDateField(
                      value: _date,
                      onPicked: (d) => setState(() => _date = d),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChatFieldLabel(isAr ? 'الوقت' : 'Time'),
                    ChatTimeField(
                      value: _time,
                      onPicked: (t) => setState(() => _time = t),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ChatDialogButtons(
            primaryLabel: isAr ? 'تطبيق' : 'Apply',
            onPrimary: _apply,
          ),
        ],
      ),
    );
  }
}
