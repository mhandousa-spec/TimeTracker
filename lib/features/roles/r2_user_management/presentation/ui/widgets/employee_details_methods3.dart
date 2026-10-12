/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_methods3.dart
/// Purpose: Declares `EmployeeDetailsMethods3`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Permission chips render through PermissionLabel (ar/en).

part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods3 on _RoleEmployeeDetailsPageState {
  Widget _buildModulePermissionRow({
    required bool lightMode,
    required String moduleString,
  }) {
    Modules? module = _getModuleEnum(moduleString);
    if (module == null) return const SizedBox.shrink();

    List<String> actions = _modulePermissions[moduleString] ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.sp,
            alignment: Alignment.center,
            width: 20.sp,
            child: CustomSvgImage(assetPath: 
              module.iconPathRole,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: actions.isEmpty
                ? Container(
              height: 32.sp,
              alignment: Alignment.centerLeft,
              child: Text(
                S.current.no_specific_permissions,
                style: StyleText.fontSize12Weight400.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                if (maxW <= 0 || maxW.isInfinite) {
                  return _buildPermissionChipsWrap(actions, lightMode);
                }
                return _buildPermissionChips(actions, maxW, lightMode);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPermissionChipsWrap(List<String> permissions, bool lightMode) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: permissions.map((p) => _buildChip(p, lightMode)).toList(),
    );
  }
  Widget _buildPermissionChips(
      List<String> permissions, double maxWidth, bool lightMode) {
    if (maxWidth < 200) {
      return _buildPermissionChipsWrap(permissions, lightMode);
    }

    List<Widget> firstRowChips = [];
    List<Widget> secondRowChips = [];
    double firstRowWidth = 0;
    double secondRowWidth = 0;
    final double spacing = 8.w;
    bool firstRowFull = false;

    for (int i = 0; i < permissions.length; i++) {
      final chipWidth = _calculateChipWidth(permissions[i]);
      final spaceNeeded = firstRowChips.isEmpty ? 0 : spacing;

      if (!firstRowFull &&
          firstRowWidth + spaceNeeded + chipWidth <= maxWidth - 5) {
        if (firstRowChips.isNotEmpty) {
          firstRowChips.add(SizedBox(width: spacing));
          firstRowWidth += spacing;
        }
        firstRowChips.add(_buildChip(permissions[i], lightMode));
        firstRowWidth += chipWidth;
      } else if (!firstRowFull) {
        firstRowFull = true;
        secondRowChips.add(_buildChip(permissions[i], lightMode));
        secondRowWidth += chipWidth;
      } else {
        if (firstRowWidth <= secondRowWidth) {
          firstRowChips.add(SizedBox(width: spacing));
          firstRowChips.add(_buildChip(permissions[i], lightMode));
          firstRowWidth += spacing + chipWidth;
        } else {
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
            secondRowWidth += spacing;
          }
          secondRowChips.add(_buildChip(permissions[i], lightMode));
          secondRowWidth += chipWidth;
        }
      }
    }

    bool needsScroll = firstRowWidth > maxWidth || secondRowWidth > maxWidth;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: firstRowChips),
        if (secondRowChips.isNotEmpty) ...[
          SizedBox(height: 8.w),
          Row(mainAxisSize: MainAxisSize.min, children: secondRowChips),
        ],
      ],
    );

    if (needsScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }
    return content;
  }
  /// The permission chip's text, in the active locale.
  ///
  /// LOCALIZED 25/8/2026: the chips rendered `_formatPermissionName`, which
  /// only title-cases the raw Firestore key (`Change_Expiration_Date` ->
  /// "Change Expiration Date"). Every chip on this page therefore stayed
  /// English with the app in Arabic.
  ///
  /// [PermissionLabel.of] is the module's existing answer to exactly this — the
  /// permission enums keep their English `getName`, because that string is also
  /// the Firestore map key, and translation happens at the render site. It
  /// normalizes underscores itself, so the raw key goes straight in, and it
  /// falls back to the English text for any key not yet in its table.
  String _permissionChipLabel(String permissionKey) =>
      PermissionLabel.of(context, permissionKey);

  Widget _buildChip(String permissionKey, bool lightMode) {
    return Container(
      height: 32.sp,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
      alignment: Alignment.center,
      child: Text(
        _permissionChipLabel(permissionKey),
        style: StyleText.fontSize12Weight500.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
    );
  }
  double _calculateChipWidth(String permissionKey) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: _permissionChipLabel(permissionKey),
          style: StyleText.fontSize12Weight500),
      // Measure in the direction the chip will actually be laid out in. This
      // was hardcoded LTR, which was harmless while the text was always
      // English; now that it can be Arabic, the row-packing maths above must
      // measure the string the user will really see.
      textDirection: Directionality.of(context),
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width + 20.sp + 4;
  }
  Widget itemText({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
        ),
      ],
    );
  }
  Widget itemTextProduct({
    required String label,
    required String value,
    required String image,
    Color? valueColor,
  }) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomSvgImage(
          assetPath: image,
          width: 15.sp,
          height: 15.sp,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 3.sp),
        Text(
          FormatHelper.capitalize(label),
          style: ContextExtension(context).isPhone
              ? StyleText.fontSize12Weight500
              .copyWith(color: AppColors.secondaryText)
              : StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: ContextExtension(context).isPhone
              ? StyleText.fontSize12Weight500
              .copyWith(color: valueColor ?? AppColors.text)
              : StyleText.fontSize14Weight500
              .copyWith(color: valueColor ?? AppColors.text),
        ),
      ],
    );
  }
}
