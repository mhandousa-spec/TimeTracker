/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: umdr_methods3.dart
/// Purpose: Declares `UmdrMethods3`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/user_management_details_request.dart';

extension UmdrMethods3 on _UserManagementDetailsRequestSettingsState {
  /// The single card holding every change in the request.
  ///
  /// Landscape: two columns — "Current Details" and "New Details" — each
  /// listing all changed fields in the same order, so the two sides line up
  /// row for row. Portrait: the pair is stacked per field, separated by a
  /// divider, because two columns are too narrow to read on a phone.
  Widget _buildChangesCard({
    required bool lightMode,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: AppColors.card,
      ),
      // PADDING 8/9/2026: was `vertical: 15.h` against `horizontal: 15.sp` —
      // two different scales, so the top and bottom insets did not match the
      // sides. One value, one scale.
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawn once for the whole request, not once per change.
          _buildSectionHeader(lightMode, _translateSectionTitle(section)),
          SizedBox(height: 20.h),
          if (isMobile)
            ..._buildStackedChanges(lightMode)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).current_details,
                    titleColor:
                    lightMode ? AppColors.blackButton : AppColors.white,
                    isNew: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).new_details,
                    titleColor: AppColors.green,
                    isNew: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// One side of the comparison: a title plus every changed field's value.
  Widget _buildValueColumn({
    required bool lightMode,
    required String title,
    required Color titleColor,
    required bool isNew,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: StyleText.fontSize16Weight600.copyWith(color: titleColor),
        ),
        SizedBox(height: 15.h),
        for (int i = 0; i < changes.length; i++) ...[
          _buildFieldCell(
            lightMode: lightMode,
            fieldName: changes[i]['fieldName'] ?? '',
            value:
            (isNew ? changes[i]['newValue'] : changes[i]['oldValue']) ?? '',
            isNew: isNew,
          ),
          if (i != changes.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  /// Phone layout: current/new stacked per field, all still inside one card.
  List<Widget> _buildStackedChanges(bool lightMode) {
    final widgets = <Widget>[];

    for (int i = 0; i < changes.length; i++) {
      final change = changes[i];

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatHelper.capitalize(S.of(context).current_details),
              style:
              StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(
              lightMode: lightMode,
              fieldName: change['fieldName'] ?? '',
              value: change['oldValue'] ?? '',
              isNew: false,
            ),
            SizedBox(height: 12.h),
            Text(
              FormatHelper.capitalize(S.of(context).new_details),
              style:
              StyleText.fontSize16Weight600.copyWith(color: AppColors.green),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(
              lightMode: lightMode,
              fieldName: change['fieldName'] ?? '',
              value: change['newValue'] ?? '',
              isNew: true,
            ),
          ],
        ),
      );

      if (i != changes.length - 1) {
        // Role QA p.31: the line between one field's New Details and the next
        // field's Current Details is removed; the gap alone separates them.
        widgets.add(SizedBox(height: 24.h));
      }
    }

    return widgets;
  }

  /// A single read-only value. Keyed by its contents so the internal controller
  /// refreshes when the request data reloads — this used to build a
  /// TextEditingController on every paint, which was never disposed.
  Widget _buildFieldCell({
    required bool lightMode,
    required String fieldName,
    required String value,
    required bool isNew,
  }) {
    final String display = value.isEmpty ? '-' : value;

    return CustomTextField(
      key: ValueKey('$fieldName-$isNew-$display'),
      label: FormatHelper.capitalize(_getFieldLabel(fieldName)),
      hint: _getFieldLabel(fieldName),
      initialValue: display,
      enabled: false,
      fillColor: isNew ? null : AppColors.background,
    );
  }
  Widget _buildSectionHeader(bool lightMode, String sectionTitle) {
    bool isInsuranceSection =
        sectionTitle.contains('Insurance') || sectionTitle.contains('التأمين');

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.primary.withOpacity(.15),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: isInsuranceSection
                  ? "assets/icons_assets/main_icons_assets/insurance_document_shield.svg"
                  : "assets/icons_assets/main_icons_assets/emergency_contact_person.svg",
              width: 16.w,
              height: 16.h,
              fit: BoxFit.fill,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          FormatHelper.capitalize(sectionTitle),
          style: StyleText.fontSize18Weight500.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }
  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r), color: AppColors.card),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          children: [
            CustomTextField(
              hint: S.of(context).requestNote,
              controller: requestNoteController,
              enabled: false,
              label: S.of(context).requestNote,
              submitted: submitted,
              maxLines: 3,
              height: 72,
              textDirection:
              isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              showCharCount: true,
            ),
            SizedBox(height: 20.h),

            // ── Shows Approve+Reject when pending, badge otherwise ────────
            _buildStatusButton(),
          ],
        ),
      ),
    );
  }
}
