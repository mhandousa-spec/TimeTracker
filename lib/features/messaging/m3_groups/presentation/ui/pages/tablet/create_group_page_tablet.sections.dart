part of './create_group_page_tablet.dart';
/// Module: messaging / groups / presentation/ui/pages/tablet/create_group_page_tablet.sections.dart

/// Fields + helper/builder methods for the screen, split out to keep
/// each file under 800 LOC (§7).
mixin _CreateGroupPageTabletSections on State<CreateGroupPageTablet> {
  final TextEditingController searchController = TextEditingController();


  bool _isFormValid = false;


  // ── Language validation error states ─────────────────────────────────────
  String? _nameEnLangError;

  String? _nameArLangError;

  String? _descEnLangError;

  String? _descArLangError;


  // ── Validate language for EN field ──────────────────────────────────────
  String? _validateEnLanguage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (_containsArabic(value.trim())) {
      return 'Please enter English text only';
    }
    return null;
  }


  // ── Validate language for AR field ──────────────────────────────────────
  String? _validateArLanguage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (_containsEnglish(value.trim())) {
      return 'يرجى إدخال نص عربي فقط';
    }
    return null;
  }


  void _validateForm(GroupsCubit controller) {
    final nameEn = controller.groupNameController.text.trim();
    final nameAr = controller.groupNameArController.text.trim();
    final descEn = controller.groupDescriptionController.text.trim();
    final descAr = controller.groupDescriptionArController.text.trim();
    final hasMembers = controller.selectedMembers.isNotEmpty;

    // Check language errors
    final nameEnLangErr = _validateEnLanguage(nameEn);
    final nameArLangErr = _validateArLanguage(nameAr);
    final descEnLangErr = _validateEnLanguage(descEn);
    final descArLangErr = _validateArLanguage(descAr);

    final hasLangError = nameEnLangErr != null ||
        nameArLangErr != null ||
        descEnLangErr != null ||
        descArLangErr != null;

    final fieldsNotEmpty = nameEn.isNotEmpty &&
        nameAr.isNotEmpty &&
        descEn.isNotEmpty &&
        descAr.isNotEmpty;

    final isValid = fieldsNotEmpty && hasMembers && !hasLangError;

    if (isValid != _isFormValid ||
        nameEnLangErr != _nameEnLangError ||
        nameArLangErr != _nameArLangError ||
        descEnLangErr != _descEnLangError ||
        descArLangErr != _descArLangError) {
      setState(() {
        _isFormValid = isValid;
        _nameEnLangError = nameEnLangErr;
        _nameArLangError = nameArLangErr;
        _descEnLangError = descEnLangErr;
        _descArLangError = descArLangErr;
      });
    }
  }


  // ── Combine empty + language check into one error string ────────────────
  String? _getEnFieldError(String value, String validationLabel) {
    if (value.trim().isEmpty) {
      return Validator.isEmpty('', validationLabel);
    }
    if (_containsArabic(value.trim())) {
      return 'Please enter English text only';
    }
    return null;
  }


  String? _getArFieldError(String value, String validationLabel) {
    if (value.trim().isEmpty) {
      return Validator.isEmpty('', validationLabel);
    }
    if (_containsEnglish(value.trim())) {
      return 'يرجى إدخال نص عربي فقط';
    }
    return null;
  }


  // ── EN field: LTR direction ─────────────────────────────────────────────
  Widget _buildEnField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required String validationLabel,
    required GroupsCubit cubit,
    required String? langError,
    int maxLines = 1,
    bool showCounter = false,
    double? height,
    bool isInRow = false,
  }) {
    // Compute the combined error (empty check + language check)
    final currentText = controller.text;
    final combinedError = currentText.isEmpty && langError == null
        ? null // Don't show error while field is pristine
        : langError ?? _getEnFieldError(currentText, validationLabel);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: StyleText.fontSize14Weight400,
            ),
          ),
          verticalSpace(8),
          CustomTextField(
            height: height?.h,
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            hint: hintText,
            maxLength: maxLength,
            maxLines: maxLines,
            showCharCount: showCounter,
            // maxLength alone used to force the "0 / 100" counter, so
            // `showCounter: false` on the name fields did nothing. hideCounter
            // keeps the cap and drops the line.
            hideCounter: !showCounter,
            fillColor: AppColors.background,
            controller: controller,
            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.grey.withOpacity(.5)),
            contentPadding: EdgeInsetsDirectional.symmetric(vertical: 12.sp,horizontal: 12.sp),
            onChanged: (_) => _validateForm(cubit),
            // Error goes through CustomTextField: red border + message on the
            // SAME row as the char counter (message start, counter end).
            errorText: combinedError,
          ),
        ],
      ),
    );
  }


  // ── AR field: RTL direction ─────────────────────────────────────────────
  Widget _buildArField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required String validationLabel,
    required GroupsCubit cubit,
    required String? langError,
    int maxLines = 1,
    bool showCounter = false,
    double? height,
    bool isInRow = false,
  }) {
    final currentText = controller.text;
    final combinedError = currentText.isEmpty && langError == null
        ? null
        : langError ?? _getArFieldError(currentText, validationLabel);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: StyleText.fontSize14Weight400,
            ),
          ),
          verticalSpace(8),
          CustomTextField(
            height: height?.h,
            textDirection: ui.TextDirection.rtl,
            textAlign: TextAlign.right,
            hint: hintText,
            maxLength: maxLength,
            maxLines: maxLines,
            showCharCount: false,
            // maxLength alone used to force the "0 / 100" counter, so
            // `showCounter: false` on the name fields did nothing. hideCounter
            // keeps the cap and drops the line.
            hideCounter: !showCounter,
            fillColor: AppColors.background,
            controller: controller,
            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.grey.withOpacity(.5)),
            contentPadding: EdgeInsetsDirectional.symmetric(vertical: 12.sp,horizontal: 12.sp),

            onChanged: (_) => _validateForm(cubit),
            // Error goes through CustomTextField: red border + message on the
            // SAME row as the char counter (message start, counter end).
            errorText: combinedError,
          ),
        ],
      ),
    );
  }

}
