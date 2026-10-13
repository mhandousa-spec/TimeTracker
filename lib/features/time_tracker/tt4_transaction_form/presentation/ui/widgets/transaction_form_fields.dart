/// Module: time_tracker / tt4_transaction_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_form_fields.dart
/// Purpose: Declares the parts of the "Creating Transaction" card —
///          `TransactionDateTimeRow` (label + date | time, with its error),
///          `TransactionDocumentField` (Upload Attachment box or the
///          uploaded file card) and `TransactionFormActions` (Discard /
///          Submit).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:80120` / `661:80227`: field labels Regular 14, grey 36-high
/// fields, file card "Watermark.png · 62 KB · Uploaded Date: 28 Dec 2023"
/// with a red ⊖ (core `ProductWarrantyCard`, 22). Owner rules: no required
/// stars; Submit grey/disabled until valid (tap reveals the errors); date
/// and time fields stay level when one shows an error (top-aligned row).
/// Updated: 9/10/2026 - UI fix round 1: "Transaction Document" uses the
/// yellow "Upload Attachment" button of Figma `661:80120` (`TtUploadButton`,
/// red border while the required file is missing) instead of a grey box.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_time_field.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// "Check In Date" + (date | time) + an error line.
class TransactionDateTimeRow extends StatelessWidget {
  const TransactionDateTimeRow({
    super.key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
    this.error,
  });

  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<TimeOfDay> onTime;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String? message = error;
    final DateTime today = DateTime.now();
    // 12/10/2026 (owner R4 / G1): the red border goes on the part that is
    // MISSING — the date, the time or both (a wrong order marks the time).
    final bool dateMissing = message != null && date == null;
    final bool timeMissing = message != null && (time == null || date != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: kFieldLabelGap.sp),
          child: Text(
            label,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                foregroundDecoration: dateMissing
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: AppColors.red),
                      )
                    : null,
                child: CustomDropdownCalendar(
                  value: date,
                  hint: s.chooseDate,
                  height: 36,
                  // A correction is for a day that already happened.
                  lastDate: DateTime(today.year, today.month, today.day),
                  dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
                  onChanged: (DateTime? d) {
                    if (d != null) onDate(d);
                  },
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: TimeTrackerTimeField(
                value: time,
                hint: s.chooseTime,
                hasError: timeMissing,
                onPicked: onTime,
              ),
            ),
          ],
        ),
        if (message != null)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 4.h),
            child: Text(
              message,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }
}

/// "Transaction Document": the upload box, a spinner, or the file card.
class TransactionDocumentField extends StatelessWidget {
  const TransactionDocumentField({
    super.key,
    required this.attachment,
    required this.isUploading,
    required this.onUpload,
    required this.onRemove,
    this.error,
  });

  final RequestAttachment? attachment;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final RequestAttachment? file = attachment;
    final Widget slot;
    if (isUploading) {
      slot = SizedBox(height: 64.h, child: const Center(child: CircleProgressMaster()));
    } else if (file != null) {
      slot = ProductWarrantyCard(
        key: const ValueKey<String>('transactionFileCard'),
        title: '',
        width: double.infinity,
        // 13/10/2026 (owner G3): remove (–) in the top corner; name, size
        // and date aligned.
        removeOnCorner: true,
        fileName: file.name,
        fileSize: TimeTrackerFormat.fileSize(context, file.sizeBytes),
        date: s.timeTrackerUploadedOn(
          TimeTrackerFormat.date(context, file.uploadedAt ?? DateTime.now()),
        ),
        onRemove: () {
          HapticController.high();
          onRemove();
        },
      );
    } else {
      slot = TtUploadButton(
        key: const ValueKey<String>('transactionUploadBox'),
        label: s.uploadAttachment,
        hasError: error != null,
        onTap: onUpload,
      );
    }
    final Widget label = Text(
      s.timeTrackerTransactionDocument,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );
    final String? message = error;
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        slot,
        if (message != null)
          Padding(
            padding: EdgeInsetsDirectional.only(top: 4.h),
            child: Text(
              message,
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[label, SizedBox(height: kFieldLabelGap.sp), content],
      );
    }
    // Figma: label in the start half, the box / card in the end half.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The label sits level with the file card's middle (G3).
        Expanded(child: Padding(padding: EdgeInsetsDirectional.only(top: file != null ? 18.h : 8.h), child: label)),
        SizedBox(width: 15.w),
        Expanded(child: content),
      ],
    );
  }
}

/// Grey Discard (start) · yellow Submit (end, disabled until valid).
class TransactionFormActions extends StatelessWidget {
  const TransactionFormActions({
    super.key,
    required this.canSubmit,
    required this.onDiscard,
    required this.onSubmit,
    required this.onDisabledTap,
  });

  final bool canSubmit;
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final VoidCallback onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Widget discard = customButton(
      title: s.discard,
      function: onDiscard,
      color: AppColors.secondaryAction,
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
    );
    final Widget submit = KeyedSubtree(
      key: const ValueKey<String>('transactionSubmitButton'),
      child: canSubmit
          ? ShrinkOnTap(
              child: customButton(
                title: s.submit,
                function: onSubmit,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
              ),
            )
          : customButton(
              title: s.submit,
              function: onDisabledTap,
              haptic: () {},
              color: AppColors.disabledButton,
              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.colorGreyDark),
            ),
    );
    if (context.isPhone) {
      return Row(
        children: <Widget>[
          Expanded(child: discard),
          SizedBox(width: 15.w),
          Expanded(child: submit),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 150.w, child: discard),
        SizedBox(width: 150.w, child: submit),
      ],
    );
  }
}
