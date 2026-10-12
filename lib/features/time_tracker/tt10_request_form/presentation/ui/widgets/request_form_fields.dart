/// Module: time_tracker / tt10_request_form / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_form_fields.dart
/// Purpose: Declares the parts of the "Creating New Request" card —
///          `RequestTimeField` (label + 12-hour time + its error) and
///          `RequestAttachmentsField` (the uploaded file cards + the Upload
///          Attachment box).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:17016`: "Start Time / End Time" grey 36-high fields; "Request
/// Attachments" label in the start half, file cards ("Watermark.png · 62
/// KB · Uploaded Date: 28 Dec 2023", red ⊖) in the end half — core
/// `ProductWarrantyCard` (22), same as the phase-2 transaction document.
/// Several files (up to 5) may be attached. Owner rules: no required stars;
/// fields side by side stay top-aligned when one shows an error.
/// Updated: 9/10/2026 - UI fix round 1 (owner finding 6): the add control is
/// the yellow "Upload" button of Figma `661:16900` / `661:17016`
/// (`TtUploadButton`, red border while a required file is missing), not a
/// grey text box.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_time_field.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// "Start Time" + the time field (minutes since midnight, null = none).
class RequestTimeField extends StatelessWidget {
  const RequestTimeField({
    super.key,
    required this.label,
    required this.minutes,
    required this.onChanged,
    this.error,
  });

  final String label;
  final int? minutes;
  final ValueChanged<int> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final int? m = minutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: kFieldLabelGap.sp),
          child: Text(label, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ),
        TimeTrackerTimeField(
          value: m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60),
          hint: S.of(context).chooseTime,
          hasError: error != null,
          onPicked: (TimeOfDay t) => onChanged(t.hour * 60 + t.minute),
        ),
        TtFieldError(error),
      ],
    );
  }
}

/// "Request Attachments": the file cards and the upload box.
class RequestAttachmentsField extends StatelessWidget {
  const RequestAttachmentsField({
    super.key,
    required this.files,
    required this.isUploading,
    required this.canAdd,
    required this.onUpload,
    required this.onRemove,
    this.error,
  });

  final List<RequestAttachment> files;
  final bool isUploading;
  final bool canAdd;
  final VoidCallback onUpload;
  final ValueChanged<int> onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < files.length; i++) ...<Widget>[
          ProductWarrantyCard(
            key: ValueKey<String>('requestFileCard_$i'),
            title: '',
            width: double.infinity,
            fileName: files[i].name,
            fileSize: TimeTrackerFormat.fileSize(context, files[i].sizeBytes),
            date: s.timeTrackerUploadedOn(TimeTrackerFormat.date(context, files[i].uploadedAt ?? DateTime.now())),
            onRemove: () {
              HapticController.high();
              onRemove(i);
            },
          ),
          SizedBox(height: 8.h),
        ],
        if (isUploading)
          SizedBox(height: 64.h, child: const Center(child: CircleProgressMaster()))
        else if (canAdd)
          TtUploadButton(
            key: const ValueKey<String>('requestUploadBox'),
            label: s.upload,
            hasError: error != null,
            onTap: onUpload,
          ),
        TtFieldError(error),
      ],
    );
    final Widget label = Text(s.timeTrackerRequestAttachments,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text));
    if (context.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[label, SizedBox(height: kFieldLabelGap.sp), content],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Padding(padding: EdgeInsetsDirectional.only(top: 8.h), child: label)),
        SizedBox(width: 15.w),
        Expanded(child: content),
      ],
    );
  }
}
