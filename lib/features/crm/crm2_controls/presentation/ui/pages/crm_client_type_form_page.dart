// ****************** FILE INFO ******************
// File Name: crm_client_type_form_page.dart
// Purpose: Multi-mode form page for Add, Details (Readonly), and Edit Client Type in CRM Controls
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/routing/crm_routes/crm_routes.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_client_types_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_client_types_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum CrmClientTypeFormMode { add, details, edit }

class CrmClientTypeFormPage extends StatefulWidget {
  final CrmClientTypeFormMode initialMode;
  final String? typeName;
  final String? typeNameAr;
  final String? svgAsset;
  final CrmClientTypeModel? clientType;

  const CrmClientTypeFormPage({
    super.key,
    this.initialMode = CrmClientTypeFormMode.add,
    this.typeName,
    this.typeNameAr,
    this.svgAsset,
    this.clientType,
  });

  @override
  State<CrmClientTypeFormPage> createState() => _CrmClientTypeFormPageState();
}

class _CrmClientTypeFormPageState extends State<CrmClientTypeFormPage> {
  late CrmClientTypeFormMode _mode;
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  CrmClientTypeModel? _clientType;
  File? _pickedImage;
  String? _nameEnError;
  String? _nameArError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _clientType = widget.clientType;
    _nameController = TextEditingController(
      text: _clientType?.nameEn ?? widget.typeName ?? '',
    );
    _nameArController = TextEditingController(
      text: _clientType?.nameAr ?? widget.typeNameAr ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  void _validateEn(String val) {
    if (_mode == CrmClientTypeFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameEnError = S.current.crmFieldRequired);
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(val)) {
      setState(() => _nameEnError = S.current.crmEnglishLettersOnlyTitle);
    } else {
      setState(() => _nameEnError = null);
    }
  }

  void _validateAr(String val) {
    if (_mode == CrmClientTypeFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameArError = 'هذا الحقل مطلوب');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(val)) {
      setState(() => _nameArError = 'هذا الحقل يقبل الحروف العربية فقط');
    } else {
      setState(() => _nameArError = null);
    }
  }

  bool _validateForm() {
    final String en = _nameController.text.trim();
    final String ar = _nameArController.text.trim();

    String? enErr;
    String? arErr;

    if (en.isEmpty) {
      enErr = S.current.crmFieldRequired;
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) {
      enErr = S.current.crmEnglishLettersOnlyTitle;
    }

    if (ar.isEmpty) {
      arErr = 'هذا الحقل مطلوب';
    } else if (RegExp(r'[a-zA-Z]').hasMatch(ar)) {
      arErr = 'هذا الحقل يقبل الحروف العربية فقط';
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
    });

    return enErr == null && arErr == null;
  }

  bool get _hasChanges {
    if (_mode != CrmClientTypeFormMode.edit) return true;
    final String currentEn = _nameController.text.trim();
    final String currentAr = _nameArController.text.trim();
    final String initialEn =
        (_clientType?.nameEn ?? widget.typeName ?? '').trim();
    final String initialAr =
        (_clientType?.nameAr ?? widget.typeNameAr ?? '').trim();
    return currentEn != initialEn ||
        currentAr != initialAr ||
        _pickedImage != null;
  }

  bool get _canSubmit {
    final String en = _nameController.text.trim();
    final String ar = _nameArController.text.trim();
    return en.isNotEmpty &&
        ar.isNotEmpty &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(en) &&
        !RegExp(r'[a-zA-Z]').hasMatch(ar) &&
        _hasChanges;
  }

  Future<void> _pickImage() async {
    if (_mode == CrmClientTypeFormMode.details) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  String get _fourthTitle {
    switch (_mode) {
      case CrmClientTypeFormMode.add:
        return S.current.crmAddType;
      case CrmClientTypeFormMode.edit:
        return S.current.crmEditType;
      case CrmClientTypeFormMode.details:
        return S.current.crmType;
    }
  }

  void _handleRemove() {
    final CrmClientTypeModel? clientType = _clientType;
    if (clientType == null || clientType.isDefault) return;

    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemoveField,
      subtitle: S.current.crmRemoveFieldSubtitle,
      onConfirm: () async {
        showLoadingIndicator();
        final bool removed =
            await context.read<CrmClientTypesCubit>().removeType(clientType);
        hideLoadingIndicator();
        if (!mounted || !removed) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccessful,
          subtitle: S.current.crmRemovedSuccessfully,
          onComplete: () => CrmNavigationHelper.pop(context),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_validateForm()) return;

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        final CrmClientTypesCubit cubit = context.read<CrmClientTypesCubit>();
        showLoadingIndicator();
        bool saved = false;

        if (_mode == CrmClientTypeFormMode.edit && _clientType != null) {
          saved = await cubit.updateType(
            currentType: _clientType!,
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            image: _pickedImage,
          );
          _clientType = cubit.state.selectedType ?? _clientType;
        } else {
          saved = await cubit.createType(
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            image: _pickedImage,
          );
          _clientType = cubit.state.selectedType;
        }
        hideLoadingIndicator();

        if (!mounted || !saved) return;
        if (_mode == CrmClientTypeFormMode.edit) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () {
              setState(() {
                _pickedImage = null;
                _mode = CrmClientTypeFormMode.details;
              });
            },
          );
        } else {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () => CrmNavigationHelper.pop(context),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isReadOnly = _mode == CrmClientTypeFormMode.details;
    final bool canRemove = isReadOnly && (_clientType?.isDefault != true);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlClientsTypes,
        fourthTitle: _fourthTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () {
          Navigator.popUntil(
            context,
            (Route<dynamic> route) => route.settings.name == CrmRoutes.controls,
          );
        },
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmClientTypesCubit, CrmClientTypesState>(
          builder: (BuildContext context, CrmClientTypesState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section and action buttons in same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.current.crmTypeDetails,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isReadOnly)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Button
                            customButtonWithSvg(
                              title: isMobile ? '' : S.current.edit,
                              function: () {
                                setState(() {
                                  _mode = CrmClientTypeFormMode.edit;
                                });
                              },
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              colorBorder: AppColors.transparent,
                              image: AppAssets.edit,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              svgColor: AppColors.black,
                            ),
                            if (canRemove) ...[
                              SizedBox(width: 8.sp),
                              customButtonWithSvg(
                                title: isMobile ? '' : S.current.crmRemove,
                                function: _handleRemove,
                                textStyle: StyleText.fontSize14Weight600
                                    .copyWith(
                                  color: AppColors.white,
                                ),
                                color: AppColors.red,
                                colorBorder: AppColors.transparent,
                                image: AppAssets.crmTrush,
                                widthImage: 18.sp,
                                heightImage: 18.sp,
                                svgColor: AppColors.white,
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 12.sp),

                  // Form Card Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar / Icon Picker Widget
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 64.sp,
                                height: 64.sp,
                                decoration: BoxDecoration(
                                  color: AppColors.disabledGrey,
                                  shape: BoxShape.circle,
                                  image: _pickedImage != null
                                      ? DecorationImage(
                                          image: FileImage(_pickedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : _clientType?.iconUrl.isNotEmpty == true
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                _clientType!.iconUrl,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                ),
                                alignment: Alignment.center,
                                child: _pickedImage == null &&
                                        _clientType?.iconUrl.isNotEmpty != true
                                    ? ((_clientType?.svgAsset.isNotEmpty ==
                                                true ||
                                            widget.svgAsset != null)
                                        ? CustomSvgImage(
                                            assetPath: _clientType
                                                        ?.svgAsset.isNotEmpty ==
                                                    true
                                                ? _clientType!.svgAsset
                                                : widget.svgAsset!,
                                            width: 32.sp,
                                            height: 32.sp,
                                            color: AppColors.black,
                                          )
                                        : Icon(
                                            Icons.photo_outlined,
                                            size: 30.sp,
                                            color: AppColors.darkGrey,
                                          ))
                                    : null,
                              ),
                              if (!isReadOnly)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 22.sp,
                                    height: 22.sp,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                        width: 1.5.sp,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 12.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Fields Row
                        buildResponsiveFields(
                          context: context,
                          left: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type Name',
                                style: StyleText.fontSize14Weight500
                                    .copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextField(
                                controller: _nameController,
                                hint: S.current.crmTextHere,
                                readOnly: isReadOnly,
                                errorText: _nameEnError,
                                onChanged: (val) => _validateEn(val.toString()),
                              ),
                            ],
                          ),
                          right: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'اسم النوع',
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              CustomTextField(
                                textAlign: TextAlign.right,
                                controller: _nameArController,
                                hint: S.current.crmWriteHere,
                                readOnly: isReadOnly,
                                textDirection: TextDirection.rtl,
                                errorText: _nameArError,
                                onChanged: (val) => _validateAr(val.toString()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Buttons Row (Add / Save / Discard)
                  if (!isReadOnly) ...[
                    SizedBox(height: 24.sp),
                    if (isMobile)
                      Row(
                        children: [
                          Expanded(
                            child: customButton(
                              title: S.current.crmDiscard,
                              function: () {
                                if (_mode == CrmClientTypeFormMode.edit) {
                                  setState(() {
                                    _mode = CrmClientTypeFormMode.details;
                                  });
                                } else {
                                  CrmNavigationHelper.pop(context);
                                }
                              },
                              color: AppColors.disabledGrey,
                              textColor: AppColors.black,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Expanded(
                            child: customButton(
                              title: _mode == CrmClientTypeFormMode.add
                                  ? S.current.crmAdd
                                  : S.current.crmSave,
                              function: _canSubmit && !state.isSaving
                                  ? _handleSubmit
                                  : () {},
                              color: _canSubmit && !state.isSaving
                                  ? AppColors.primary
                                  : AppColors.disabledGrey,
                              textStyle:
                                  StyleText.fontSize14Weight500.copyWith(
                                color: _canSubmit && !state.isSaving
                                    ? AppColors.black
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: S.current.crmDiscard,
                            function: () {
                              if (_mode == CrmClientTypeFormMode.edit) {
                                setState(() {
                                  _mode = CrmClientTypeFormMode.details;
                                });
                              } else {
                                CrmNavigationHelper.pop(context);
                              }
                            },
                            color: AppColors.disabledGrey,
                            textColor: AppColors.black,
                            textStyle:
                                StyleText.fontSize14Weight600.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          customButton(
                            title: _mode == CrmClientTypeFormMode.add
                                ? S.current.crmAdd
                                : S.current.crmSave,
                            function: _canSubmit && !state.isSaving
                                ? _handleSubmit
                                : () {},
                            color: _canSubmit && !state.isSaving
                                ? AppColors.primary
                                : AppColors.disabledGrey,
                            textStyle:
                                StyleText.fontSize14Weight500.copyWith(
                              color: _canSubmit && !state.isSaving
                                  ? AppColors.black
                                  : AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                  ],

                  if (state.errorMessage != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      state.errorMessage!,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.red,
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
