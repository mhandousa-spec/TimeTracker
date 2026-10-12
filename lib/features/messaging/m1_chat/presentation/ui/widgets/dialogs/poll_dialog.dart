/// Module: messaging / chat / presentation/ui/widgets/dialogs/poll_dialog.dart
/// Purpose: Poll dialog (Figma 6799:5666): question, options (+ Option),
///          Hide Voters, Allow Multiple Answers and Scheduled (date + time).
///          Send posts the poll now, or schedules it.
/// Created At: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../../core/custom/58-default_switch_button.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../domain/entity/new_message_content_entity.dart';
import '../../../controller/main_controllers/master_chat_cubit.dart';
import 'chat_dialog_widgets.dart';

const int _maxOptions = 10;

class _PollRequest {
  const _PollRequest(this.poll, this.sendAt);
  final PollPayload poll;
  final DateTime? sendAt; // null = send now
}

Future<void> showPollDialog(BuildContext context, MasterChatCubit cubit) async {
  final bool isAr = chatDialogIsAr(context);
  final _PollRequest? req = await showChatDialog<_PollRequest>(
    context: context,
    width: 356.w,
    child: const _PollDialog(),
  );
  if (req == null || !context.mounted) return;

  final bool ok = await CustomDialogManager.runWithLoading<bool>(
    context,
    () => req.sendAt == null
        ? cubit.sendPollMessage(req.poll)
        : cubit.scheduleMessage(poll: req.poll, sendAt: req.sendAt!),
  );
  if (!ok) {
    chatDialogToast(isAr ? 'تعذر إرسال الاستطلاع' : 'Could not send the poll');
  } else if (req.sendAt != null) {
    chatDialogToast(isAr ? 'تمت جدولة الاستطلاع' : 'Poll scheduled');
  }
}

class _PollDialog extends StatefulWidget {
  const _PollDialog();

  @override
  State<_PollDialog> createState() => _PollDialogState();
}

class _PollDialogState extends State<_PollDialog> {
  final TextEditingController _question = TextEditingController();
  final List<TextEditingController> _options = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  bool _hideVoters = false;
  bool _allowMultiple = false;
  bool _scheduled = false;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_options.length >= _maxOptions) return;
    setState(() => _options.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_options.length <= 2) return;
    setState(() => _options.removeAt(i).dispose());
  }

  void _send() {
    final bool isAr = chatDialogIsAr(context);
    final String question = _question.text.trim();
    if (question.isEmpty) {
      chatDialogToast(isAr ? 'اكتب السؤال' : 'Write the question');
      return;
    }
    // Blank and repeated options are dropped (case-insensitive).
    final List<String> options = <String>[];
    final Set<String> seen = <String>{};
    for (final c in _options) {
      final String o = c.text.trim();
      if (o.isNotEmpty && seen.add(o.toLowerCase())) options.add(o);
    }
    if (options.length < 2) {
      chatDialogToast(isAr
          ? 'أضف خيارين مختلفين على الأقل'
          : 'Add at least two different options');
      return;
    }
    DateTime? sendAt;
    if (_scheduled) {
      sendAt = combineDateTime(_date, _time);
      if (sendAt == null) {
        chatDialogToast(
            isAr ? 'اختر التاريخ والوقت' : 'Choose the date and time');
        return;
      }
      if (!sendAt.isAfter(DateTime.now())) {
        chatDialogToast(
            isAr ? 'اختر وقتاً في المستقبل' : 'Choose a time in the future');
        return;
      }
    }
    Navigator.of(context).pop(_PollRequest(
      PollPayload(
        question: question,
        options: options,
        allowMultiple: _allowMultiple,
        hideVoters: _hideVoters,
      ),
      sendAt,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChatDialogBadgeHeader(
              icon: 'assets/icons_assets/messaging_assets/poll_bars.svg',
              title: isAr ? 'استطلاع' : 'Poll',
            ),
            SizedBox(height: 16.h),
            ChatFieldLabel(isAr ? 'السؤال' : 'Question'),
            ChatTextField(
              controller: _question,
              hint: isAr ? 'اكتب سؤالك' : 'Ask Question',
              radius: 6.4,
            ),
            SizedBox(height: 12.h),
            ChatFieldLabel(isAr ? 'الخيارات' : 'Options'),
            for (int i = 0; i < _options.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: ChatTextField(
                        controller: _options[i],
                        hint: isAr ? 'خيار ${i + 1}' : 'Option ${i + 1}',
                        radius: 6.4,
                      ),
                    ),
                    if (_options.length > 2)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _removeOption(i),
                        icon: Icon(Icons.close,
                            size: 16.r, color: AppColors.secondaryBlack),
                      ),
                  ],
                ),
              ),
            if (_options.length < _maxOptions)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: InkWell(
                  onTap: _addOption,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    width: 80.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.blackButton,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage(
                          assetPath:
                              'assets/icons_assets/main_icons_assets/plus.svg',
                          width: 12.r,
                          height: 12.r,
                          fit: BoxFit.contain,
                          color: AppColors.field,
                        ),
                        SizedBox(width: 4.w),
                        Text(isAr ? 'خيار' : 'Option',
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.field)),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 12.h),
            _SwitchRow(
              label: isAr ? 'إخفاء المصوتين' : 'Hide Voters',
              value: _hideVoters,
              onChanged: (v) => setState(() => _hideVoters = v),
            ),
            _SwitchRow(
              label: isAr ? 'السماح بإجابات متعددة' : 'Allow Multiple Answers',
              value: _allowMultiple,
              onChanged: (v) => setState(() => _allowMultiple = v),
            ),
            _SwitchRow(
              label: isAr ? 'مجدول' : 'Scheduled',
              value: _scheduled,
              onChanged: (v) => setState(() => _scheduled = v),
            ),
            if (_scheduled) ...[
              SizedBox(height: 8.h),
              ChatFieldLabel(isAr ? 'التاريخ' : 'Date'),
              ChatDateField(
                  value: _date, onPicked: (d) => setState(() => _date = d)),
              SizedBox(height: 10.h),
              ChatFieldLabel(isAr ? 'الوقت' : 'Time'),
              ChatTimeField(
                  value: _time, onPicked: (t) => setState(() => _time = t)),
            ],
            SizedBox(height: 20.h),
            ChatDialogButtons(
              primaryLabel: isAr ? 'إرسال' : 'Send',
              onPrimary: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text)),
          ),
          DefaultSwitchButton(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
