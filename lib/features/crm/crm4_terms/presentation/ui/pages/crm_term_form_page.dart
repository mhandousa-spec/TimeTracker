// ****************** FILE INFO ******************
// File Name: crm_term_form_page.dart
// Purpose: Form and details page for viewing, adding, and editing CRM Terms
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/ui/widgets/crm_term_clause_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTermFormPage extends StatefulWidget {
  final CrmTermModel? term;
  final String mode; // 'add', 'edit', 'view'

  const CrmTermFormPage({
    super.key,
    this.term,
    this.mode = 'add',
  });

  @override
  State<CrmTermFormPage> createState() => _CrmTermFormPageState();
}

class _CrmTermFormPageState extends State<CrmTermFormPage> {
  late String _currentMode;
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final List<_ClauseControllerGroup> _clauseControllers =
      <_ClauseControllerGroup>[];

  bool get _hasChanges {
    if (_currentMode != 'edit') return true;
    final CrmTermModel? t = widget.term;
    if (t == null) return true;
    if (_nameEnController.text.trim() != t.nameEn.trim()) return true;
    if (_nameArController.text.trim() != t.nameAr.trim()) return true;
    if (_clauseControllers.length != t.clauses.length) return true;
    for (int i = 0; i < _clauseControllers.length; i++) {
      final _ClauseControllerGroup group = _clauseControllers[i];
      final CrmTermClauseModel orig = t.clauses[i];
      if (group.en.text.trim() != orig.textEn.trim() ||
          group.ar.text.trim() != orig.textAr.trim()) {
        return true;
      }
    }
    return false;
  }

  bool get _canSubmit {
    final bool hasName = _nameEnController.text.trim().isNotEmpty ||
        _nameArController.text.trim().isNotEmpty;
    return hasName &&
        _clauseControllers.any(
          (_ClauseControllerGroup clause) =>
              clause.en.text.trim().isNotEmpty ||
              clause.ar.text.trim().isNotEmpty,
        ) &&
        _hasChanges;
  }

  @override
  void initState() {
    super.initState();
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
    _currentMode = widget.mode;
    _initializeForm();
  }

  void _initializeForm() {
    final CrmTermModel? t = widget.term;
    if (t != null) {
      _nameEnController.text = t.nameEn;
      _nameArController.text = t.nameAr;
      for (final CrmTermClauseModel c in t.clauses) {
        final _ClauseControllerGroup clause = _ClauseControllerGroup(
          id: c.id,
          en: TextEditingController(text: c.textEn),
          ar: TextEditingController(text: c.textAr),
        );
        clause.en.addListener(_refreshSubmitState);
        clause.ar.addListener(_refreshSubmitState);
        _clauseControllers.add(clause);
      }
    }

    if (_clauseControllers.isEmpty) {
      _addNewClause();
    }
  }

  void _addNewClause() {
    final _ClauseControllerGroup clause = _ClauseControllerGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      en: TextEditingController(),
      ar: TextEditingController(),
    );
    clause.en.addListener(_refreshSubmitState);
    clause.ar.addListener(_refreshSubmitState);
    setState(() {
      _clauseControllers.add(clause);
    });
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  void _removeClause(int index) {
    if (_clauseControllers.length <= 1) return;
    setState(() {
      final _ClauseControllerGroup removed = _clauseControllers.removeAt(index);
      removed.dispose();
    });
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    for (final _ClauseControllerGroup c in _clauseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _switchToEditMode() {
    setState(() {
      _currentMode = 'edit';
    });
  }

  void _onDiscard() {
    CrmNavigationHelper.pop(context);
  }

  void _onSave() {
    final String nameEn = _nameEnController.text.trim();
    final String nameAr = _nameArController.text.trim();

    if (nameEn.isEmpty && nameAr.isEmpty) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.crmAlert,
        subtitle: S.current.crmPleaseEnterTermName,
      );
      return;
    }

    final List<CrmTermClauseModel> clauses = <CrmTermClauseModel>[];
    int order = 0;
    for (final _ClauseControllerGroup c in _clauseControllers) {
      final String en = c.en.text.trim();
      final String ar = c.ar.text.trim();
      if (en.isNotEmpty || ar.isNotEmpty) {
        clauses.add(
          CrmTermClauseModel(
            id: c.id,
            textEn: en.isNotEmpty ? en : ar,
            textAr: ar.isNotEmpty ? ar : en,
            order: order++,
          ),
        );
      }
    }

    if (clauses.isEmpty) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.crmAlert,
        subtitle: S.current.crmPleaseAddAtLeastOneType,
      );
      return;
    }

    final CrmTermModel updatedTerm =
        (widget.term ?? CrmTermModel.getEmptyModel()).copyWith(
      nameEn: nameEn.isNotEmpty ? nameEn : nameAr,
      nameAr: nameAr.isNotEmpty ? nameAr : nameEn,
      clauses: clauses,
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSaveTerm,
      subtitle: S.current.crmSaveTermConfirm,
      onConfirm: () async {
        if (!mounted) return;
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{
            'action': 'save',
            'term': updatedTerm,
          },
        );
      },
    );
  }

  void _onRemoveTap() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemoveTerm,
      subtitle: S.current.crmRemoveTermConfirm,
      onConfirm: () {
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{
            'action': 'delete',
            'term': widget.term,
          },
        );
      },
    );
  }

  String _pageTitle(bool isArabic) {
    if (_currentMode == 'add') {
      return S.current.crmAddTerm;
    }
    if (_currentMode == 'edit') {
      final String name = widget.term?.localizedName(isArabic) ?? '';
      return isArabic ? 'تعديل $name' : 'Edit ${widget.term?.nameEn ?? "Term"}';
    }
    return widget.term?.localizedName(isArabic) ?? S.current.crmTermsDetails;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final bool isReadOnly = _currentMode == 'view';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmTerms,
        fourthTitle: _pageTitle(isArabic),
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Section Title and Top Actions for View mode
              if (isReadOnly) ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      S.current.crmTermsDetails,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        CustomEditIcon(
                          title: S.current.crmEdit,
                          onTap: _switchToEditMode,
                          color: AppColors.primary,
                          svgColor: AppColors.black,
                        ),
                        SizedBox(width: 10.sp),
                        CustomDeleteIcon(
                          title: isArabic ? 'إزالة' : 'Remove',
                          onTap: _onRemoveTap,
                          color: AppColors.delete,
                          svgColor: AppColors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.sp),
              ] else ...<Widget>[
                Text(
                  S.current.crmTermsDetails,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 12.sp),
              ],

              // White Container containing form fields (NO border)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Term Name (English on left, Arabic on right with RTL)
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        label: 'Term Name',
                        controller: _nameEnController,
                        hint: 'Text Here',
                        readOnly: isReadOnly,
                        textDirection: TextDirection.ltr,
                      ),
                      right: Directionality(
                        textDirection: TextDirection.rtl,
                        child: CustomTextField(
                          label: 'اسم المصطلح',
                          controller: _nameArController,
                          hint: 'اكتب هنا',
                          readOnly: isReadOnly,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.sp),

                    if (!isMobile) ...<Widget>[
                      Text(
                        S.current.crmTerms,
                        style: StyleText.fontSize14Weight600.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 12.sp),
                    ],

                    // Dynamic Clause rows
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _clauseControllers.length,
                      itemBuilder: (BuildContext context, int index) {
                        final _ClauseControllerGroup c =
                            _clauseControllers[index];
                        return CrmTermClauseRow(
                          key: ValueKey<String>(c.id),
                          index: index,
                          controllerEn: c.en,
                          controllerAr: c.ar,
                          isReadOnly: isReadOnly,
                          canDelete: _clauseControllers.length > 1,
                          onDelete: () => _removeClause(index),
                        );
                      },
                    ),

                    // "+ Term" button (only in edit/add mode)
                    if (!isReadOnly) ...<Widget>[
                      SizedBox(height: 8.sp),
                      SizedBox(
                        width: 100.sp,
                        child: customButtonWithSvg(
                          title: isArabic ? 'شرط' : 'Term',
                          function: _addNewClause,
                          color: AppColors.black,
                          image: AppAssets.add,
                          widthImage: 16.sp,
                          heightImage: 16.sp,
                          colorBorder: AppColors.transparent,
                          svgColor: AppColors.white,
                          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                            fontSize: 14.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Action Buttons (Discard & Save)
              if (!isReadOnly) ...<Widget>[
                SizedBox(height: 24.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    customButton(
                      title: S.current.crmDiscard,
                      function: _onDiscard,
                      color: AppColors.grey,
                      textColor: AppColors.black,
                      width: 110.sp,
                    ),
                    customButton(
                      title: S.current.crmSave,
                      function: _canSubmit ? _onSave : () {},
                      color: _canSubmit
                          ? AppColors.primary
                          : AppColors.disabledGrey,
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color:
                            _canSubmit ? AppColors.black : AppColors.darkGrey,
                      ),
                      width: 110.sp,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 40.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClauseControllerGroup {
  final String id;
  final TextEditingController en;
  final TextEditingController ar;

  _ClauseControllerGroup({
    required this.id,
    required this.en,
    required this.ar,
  });

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}
