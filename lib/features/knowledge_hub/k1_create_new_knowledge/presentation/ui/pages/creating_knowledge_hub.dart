/// Module: knowledge_hub / presentation / s1_create_new_knowledge / master_page/creating_knowledge_hub.dart
/// ************************* FILE INFO *************************** ///
/// File Name: creating_knowledge_hub.dart
/// Purpose: Created to handle creating and submitting new knowledge file to firebase.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Added dropdown for owning department selection with permission check

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';

import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import '../../../../main_controller/helper/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';
import '../../controller/create_knowledge_cubit.dart';
import '../../../../main_controller/presentation/ui/widgets/creating_knowledge_confirmation_dialog.dart';
import '../widgets/action_buttons.dart';
import '../widgets/configuration_section.dart';
import '../widgets/image_and_document_section.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

part './creating_knowledge_hub.data.dart';
part './creating_knowledge_hub.actions.dart';

class CreatingKnowledgeHub extends StatefulWidget {
  final String? knowledgeId;
  const CreatingKnowledgeHub({super.key, this.knowledgeId});

  @override
  State<CreatingKnowledgeHub> createState() => _CreatingKnowledgeHubState();
}

class _CreatingKnowledgeHubState extends State<CreatingKnowledgeHub>
    with _CreatingKnowledgeHubData, _CreatingKnowledgeHubActions {
  @override
  void initState() {
    super.initState();

    // ✅ Set edit mode
    _isEditMode = widget.knowledgeId != null;

    _initializeData();
    _debugDepartmentController();

    // ✅ Fetch knowledge data if editing
    if (_isEditMode) {
      log('📝 EDIT MODE - Fetching knowledge: ${widget.knowledgeId}');
      context.read<CreateKnowledgeCubit>().fetchKnowledgeByKnowledgeId(
        widget.knowledgeId!,
      );
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _arabicController.dispose();
    _englishDescController.dispose();
    _arabicDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    // CHANGED 28/9/2026 (Knowledge Hub bug report p.14 / p.19 — "loading
    // indicator in whole page"). `_isUploading` was already set around every
    // upload but nothing drew it: creating showed a small spinner INSIDE the
    // confirmation dialog, and saving an edit showed nothing at all after the
    // Reason Of Editing dialog closed. The page now puts one full-page modal
    // overlay over itself for as long as an upload runs, for both paths.
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildPageBody(context, isMobile)),
          if (_isUploading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: AppColors.totalBlack.withOpacity(0.5),
                  child: Center(
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.lightPrimary),
                        backgroundColor: AppColors.white.withOpacity(0.6),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageBody(BuildContext context, bool isMobile) {
    return _buildEmployeeDataWrapper(
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          onFirstTap: () => Navigator.of(context).maybePop(),
          secondTitle: _isEditMode
              ? S.of(context)!.editingDocumentDetails(
            Localizations.localeOf(context).languageCode == 'ar'
                ? submittedDocument?.currentNameArabic ?? ''
                : submittedDocument?.currentNameEnglish ?? '',
          )
              : S.of(context).creating_knowledge_hub,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ImageDocumentSection(
                  isMobile: isMobile,
                  selectedImage: _selectedImage,
                  selectedDocument: _selectedDocument,
                  documentFileName: _documentFileName,
                  documentSize: _documentSize,
                  documentUploadedDate: _documentUploadedDate,
                  documentExtension: _documentExtension,
                  submittedDocument: submittedDocument,
                  pickImage: _pickImage,
                  pickDocument: _pickDocument,
                  removeDocument: _removeDocument,
                  englishController: _englishController,
                  arabicController: _arabicController,
                  englishDescController: _englishDescController,
                  arabicDescController: _arabicDescController,
                  documentNameFormKey: _documentNameFormKey,
                  documentDescriptionKey: _documentDescriptionKey,
                  onChanged: () => setState(() {}),
                ),
                SizedBox(height: 15.h),
                ConfigurationSection(
                  dropDownMenuText: _dropDownMenuText,
                  employeeDepartment: _getSelectedOwningDepartmentName(context),  // ✅ UPDATED
                  limitDepartmentAvailability: _limitDepartmentAvailability,
                  schedulePublishing: _schedulePublishing,
                  startDate: _startDate,
                  startTime: _startTime,
                  endDate: _endDate,
                  endTime: _endTime,
                  availableDepartments: _availableDepartments,
                  departmentSelections: _departmentSelections,
                  submittedDocument: submittedDocument,
                  selectedOwningDepartmentId: _selectedOwningDepartmentId,  // ✅ NEW
                  onDocTypeChanged: (value) {
                    if (value != null) {
                      setState(() => _dropDownMenuText = value.toString());
                      log('You choose $value');
                    }
                  },
                  onOwningDepartmentChanged: (departmentId) {  // ✅ NEW
                    setState(() => _selectedOwningDepartmentId = departmentId);
                    log('Selected owning department: $departmentId');
                  },
                  onLimitDepartmentToggle: (value) =>
                      setState(() => _limitDepartmentAvailability = value),
                  onSchedulePublishingToggle: (value) =>
                      setState(() => _schedulePublishing = value),
                  onStartDateSelected: (date) =>
                      setState(() => _startDate = date),
                  onStartTimeSelected: (time) =>
                      setState(() => _startTime = time),
                  onEndDateSelected: (date) => setState(() => _endDate = date),
                  onEndTimeSelected: (time) => setState(() => _endTime = time),
                  onDepartmentAdded: (departmentName) {
                    setState(() {
                      final dept = _availableDepartments.firstWhere(
                            (d) => d.departmentName == departmentName,
                      );
                      _selectedDepartments.add(dept.departmentName ?? '');
                      _departmentSelections[departmentName] = true;
                    });
                  },
                  onDepartmentRemoved: (departmentName) {
                    setState(() {
                      _selectedDepartments.removeWhere(
                            (d) => d == departmentName,
                      );
                      _departmentSelections[departmentName] = false;
                    });
                  },
                ),
                SizedBox(height: 20.sp),
                ActionButtonsSection(
                  onDiscard: () => Navigator.of(context).pop(),
                  onSubmit: _handleSubmitForApproval,
                  isFormComplete: _isFormComplete(),
                  isEditing: _isEditMode,
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      );
  }
}
