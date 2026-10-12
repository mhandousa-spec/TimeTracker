/// Module: GRC shared widgets
/// Description: Layout of the "Reassign Control Champion / Owner Request"
///              screens at 375 / 768 / 1024. State and submission stay in
///              each page; this only arranges what the page hands over.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: GrcPersonProfileCard, GrcOwnerSection, CustomDropdownCalendar
///               (3), CustomTextField (2), GrcAssignmentChip, grcFormButtons
library;

import 'package:knowticed_plus/features/grc/shared/widgets/grc_labeled_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_edit_controls_layout.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcReassignForm]
///
/// purpose: `Current <role>` profile card above one white card holding the
///          new-person picker, the Start / End dates (side by side at
///          768 / 1024, stacked at 375), the request note, the Assigned
///          Controls chips and the Policy / Control rows, then Discard /
///          Submit.
class GrcReassignForm extends StatelessWidget {
  final String moduleName;
  final String pageTitle;
  final String currentLabel;
  final String currentEmail;
  final String newLabel;
  final String? newPersonError;
  final ValueChanged<List<OwnerData>> onNewPersonChanged;

  final DateTime? startDate;
  final String? startDateError;
  final ValueChanged<DateTime?> onStartDateChanged;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onEndDateChanged;

  final TextEditingController noteController;
  final VoidCallback onNoteChanged;

  final List<GrcEditableChip> assignedChips;
  final String? controlsError;
  final List<Widget> pickerRows;
  final VoidCallback onAddPolicy;

  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  /// GRC bug report p4 — "Reassign … Without Request". Null hides the switch
  /// (only Module Owners, who approve these requests, get it). When on, the
  /// reassignment is approved on submit and the Request Note is hidden.
  final bool? withoutRequest;
  final ValueChanged<bool>? onWithoutRequestChanged;
  final String? withoutRequestLabel;

  /// "Request note is required" (p4) — shown when submitting a request.
  final String? noteError;

  const GrcReassignForm({
    super.key,
    required this.moduleName,
    required this.pageTitle,
    required this.currentLabel,
    required this.currentEmail,
    required this.newLabel,
    required this.newPersonError,
    required this.onNewPersonChanged,
    required this.startDate,
    required this.startDateError,
    required this.onStartDateChanged,
    required this.endDate,
    required this.onEndDateChanged,
    required this.noteController,
    required this.onNoteChanged,
    required this.assignedChips,
    required this.controlsError,
    required this.pickerRows,
    required this.onAddPolicy,
    required this.onDiscard,
    required this.onSubmit,
    required this.isSubmitting,
    this.withoutRequest,
    this.onWithoutRequestChanged,
    this.withoutRequestLabel,
    this.noteError,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final TextStyle sectionTitle =
        StyleText.fontSize16Weight400.copyWith(color: AppColors.text);
    final TextStyle subTitle =
        StyleText.fontSize14Weight400.copyWith(color: AppColors.text);

    String formatDate(DateTime d) => LocalizedNumber.digits(
          context,
          DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en').format(d),
        );

    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding;
    // SideFrameScrollableBody adds a scroll view only where the frame does
    // not already scroll (tablet / desktop).
    return SideFrameMasterServices(
      titleText: moduleName,
      onFirstTap: () => popFrameRoutes(context, 1),
      secondTitle: pageTitle,
      child: SideFrameScrollableBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentLabel, style: sectionTitle),
                      SizedBox(height: 8.h),
                      GrcPersonProfileCard(email: currentEmail),
                      SizedBox(height: 15.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: CardStyles.radius(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(newLabel, style: sectionTitle),
                            SizedBox(height: 8.h),
                            GrcOwnerSection(
                              singleSelect: true,
                              errorText: newPersonError,
                              excludeEmails: [currentEmail],
                              onOwnersChanged: onNewPersonChanged,
                            ),
                            SizedBox(height: 30.h),
                            GrcResponsiveFieldRow(
                              isTablet: !isMobile,
                              children: [
                                CustomDropdownCalendar(
                                  label: S.of(context).startDate,
                                  hint: S.of(context).chooseTheDate,
                                  value: startDate,
                                  errorText: startDateError,
                                  onChanged: onStartDateChanged,
                                  fillColor: AppColors.background,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  dateFormatter: formatDate,
                                ),
                                CustomDropdownCalendar(
                                  label: S.of(context).endDate,
                                  hint: S.of(context).chooseTheDate,
                                  value: endDate,
                                  onChanged: onEndDateChanged,
                                  fillColor: AppColors.background,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  dateFormatter: formatDate,
                                ),
                              ],
                            ),
                            if (withoutRequest != null) ...[
                              SizedBox(height: 15.h),
                              GrcLabeledSwitch(
                                label: withoutRequestLabel ?? '',
                                value: withoutRequest!,
                                onChanged: onWithoutRequestChanged,
                              ),
                            ],
                            if (withoutRequest != true) ...[
                              SizedBox(height: 15.h),
                              CustomTextField(
                                label: S.of(context).request_note,
                                hint: S.of(context).Texthere,
                                controller: noteController,
                                maxLines: 4,
                                maxLength: 500,
                                fillColor: AppColors.background,
                                errorText: noteError,
                                submitted: noteError != null,
                                onChanged: (_) => onNoteChanged(),
                              ),
                            ],
                            SizedBox(height: 15.h),
                            Text(S.of(context).assignedControls,
                                style: subTitle),
                            SizedBox(height: 8.h),
                            _chips(context),
                            if (controlsError != null) ...[
                              SizedBox(height: 6.h),
                              Text(
                                controlsError!,
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.red),
                              ),
                            ],
                            SizedBox(height: 20.h),
                            Text(S.of(context).assigningControls,
                                style: sectionTitle),
                            SizedBox(height: 8.h),
                            ...pickerRows,
                            grcAddPolicyButton(context, onTap: onAddPolicy),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      grcFormButtons(
                        context,
                        onDiscard: onDiscard,
                        primaryTitle: S.of(context).submit,
                        onPrimary: onSubmit,
                        isBusy: isSubmitting,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
      ),
    );
  }

  Widget _chips(BuildContext context) {
    if (assignedChips.isEmpty) {
      return Text(
        S.of(context).noControlsAssigned,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      );
    }
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final c in assignedChips)
          GrcAssignmentChip(label: c.label, onRemove: c.onRemove),
      ],
    );
  }
}
