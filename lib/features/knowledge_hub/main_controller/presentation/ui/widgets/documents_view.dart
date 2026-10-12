/// ************************* FILE INFO *************************** ///
/// File Name: documents_view.dart
/// Purpose: Contains the knowledge file displayed in home page.
/// Author: Youssef Khaled
/// Created At: 3/10/2025

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart' show S;
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../k3_view_knowledge_details/presentation/ui/pages/view_knowledge_details.dart';
import './file_card.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget documentsView(BuildContext context) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar'; // ✅ ADD THIS
  final departmentController = Get.find<MainCoreDepartmentCubit>(); // ✅ ADD THIS

  return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
    buildWhen: (previous, current) =>
    current is FetchingKnowledgeLoadingState ||
        current is FetchingKnowledgeErrorState ||
        current is FetchingKnowledgeEmptyState ||
        current is FetchingKnowledgeSuccessState,
    builder: (context, state) {
      log('State now is: $state');

      if (state is FetchingKnowledgeLoadingState) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (state is FetchingKnowledgeErrorState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60.r, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                '${S.of(context)!.error}: ${state.error}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              customButton(
                function: () =>
                    context.read<CreateKnowledgeCubit>().fetchAllKnowledge(),
                title: S.of(context)!.retry,
              ),
            ],
          ),
        );
      }

      if (state is FetchingKnowledgeEmptyState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json')],
          ),
        );
      }

      if (state is FetchingKnowledgeSuccessState) {
        final knowledgeList = state.knowledgeList;
        final isMobile = ContextExtension(context).isPhone;

        return LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                context,
              ),
              mainAxisExtent: 70.sp,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: isMobile ? 10.h : 15.h,
            ),
            shrinkWrap: true,
            itemCount: knowledgeList.length,
            itemBuilder: (context, index) {
              final knowledge = knowledgeList[index];
              final fileUrl = knowledge.currentDocumentUrl;
              final fileType = knowledge.currentDocumentExtension;

              log(fileUrl, name: 'FILE URL');
              log(fileType, name: 'FILE TYPE');

              final publishDate = DateFormat(
                'dd MMM yyyy',
              ).format(knowledge.currentStartDateTime!.toDate());

              // ✅ Get localized document name
              final localizedDocumentName = isArabic
                  ? knowledge.currentNameArabic
                  : knowledge.currentNameEnglish;

              // ✅ Get localized description
              final localizedDescription = isArabic
                  ? knowledge.currentDescriptionArabic
                  : knowledge.currentDescriptionEnglish;

              // ✅ Get localized document type
              final localizedDocumentType = DocumentTypeHelper.getLocalizedType(
                knowledge.currentKnowledgeDocumentType,
                isArabic,
              );

              // ✅ Get localized department name
              String localizedDepartment = knowledge.currentOwningDepartment;
              try {
                String? departmentId = departmentController
                    .getDepartmentIdFromDepartmentName(
                  departmentName: knowledge.currentOwningDepartment.toLowerCase(),
                );

                if (departmentId != null) {
                  if (isArabic) {
                    localizedDepartment = departmentController
                        .getArabicDepartmentNameFromDepartmentId(
                      departmentId: departmentId,
                    ) ??
                        knowledge.currentOwningDepartment;
                  } else {
                    localizedDepartment = departmentController
                        .getEnglishDepartmentNameFromDepartmentId(
                      departmentId: departmentId,
                    ) ??
                        knowledge.currentOwningDepartment;
                  }
                }
              } catch (e) {
                print('Error getting department name: $e');
              }

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewKnowledgeDetails(
                      emailUser: knowledge.createdByEmail.lastOrNull!,
                      knowledgeId: knowledge.currentKnowledgeId,
                      documentName: knowledge.currentNameEnglish,
                      documentNameAr: knowledge.currentNameArabic, // ✅ ADD THIS
                      publishDate: publishDate,
                      documentType: knowledge.currentKnowledgeDocumentType,
                      owningDepartment: knowledge.currentOwningDepartment,
                      documentEnglishDescription:
                      knowledge.currentDescriptionEnglish,
                      documentEnglishDescriptionAr:
                      knowledge.currentDescriptionArabic, // ✅ ADD THIS
                      fileType: fileType,
                      fileUrl: fileUrl,
                      documentExtension: knowledge.currentDocumentExtension,
                    ),
                  ),
                ).then((Object? removed) {
                  // ADDED 28/9/2026 (Knowledge Hub p.17): refetch after a
                  // removal so the card leaves the list straight away.
                  if (removed == true && context.mounted) {
                    try {
                      context.read<CreateKnowledgeCubit>().fetchAllKnowledge();
                    } catch (_) {
                      // No CreateKnowledgeCubit above this list — nothing to
                      // refresh here.
                    }
                  }
                }),
                child: fileCard(
                  context,
                  knowledge: knowledge,
                  currentUserEmail: Get.find<MainCoreEmployeeController>().employeeEntity?.email, // ✅ ADDED
                ),
              );
            },
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    },
  );
}

// ✅ ADD DocumentTypeHelper class
class DocumentTypeHelper {
  static final Map<String, Map<String, String>> documentTypes = {
    'presentation': {
      'en': 'Presentation',
      'ar': 'عرض تقديمي',
    },
    'form': {
      'en': 'Form',
      'ar': 'نموذج',
    },
    'report': {
      'en': 'Report',
      'ar': 'تقرير',
    },
    'booklet': {
      'en': 'Booklet',
      'ar': 'كتيب',
    },
    'video_recording': {
      'en': 'Video Recording',
      'ar': 'تسجيل فيديو',
    },
    'letter': {
      'en': 'Letter',
      'ar': 'خطاب',
    },
    'mandate': {
      'en': 'Mandate',
      'ar': 'تفويض',
    },
    'policy': {
      'en': 'Policy',
      'ar': 'سياسة',
    },
    'frame_work': {
      'en': 'Frame Work',
      'ar': 'إطار عمل',
    },
    'workshop': {
      'en': 'Workshop',
      'ar': 'ورشة عمل',
    },
    'guidelines': {
      'en': 'Guidelines',
      'ar': 'إرشادات',
    },
    'other': {
      'en': 'Other',
      'ar': 'أخرى',
    },
  };

  /// Get localized document type name
  static String getLocalizedType(String typeKey, bool isArabic) {
    final typeMap = documentTypes[typeKey.toLowerCase().replaceAll(' ', '_')];
    if (typeMap == null) {
      return typeKey; // Return original if not found
    }
    return isArabic ? (typeMap['ar'] ?? typeKey) : (typeMap['en'] ?? typeKey);
  }

  /// Get document type key from English or Arabic name
  static String? getTypeKey(String typeName) {
    for (var entry in documentTypes.entries) {
      if (entry.value['en']?.toLowerCase() == typeName.toLowerCase() ||
          entry.value['ar'] == typeName) {
        return entry.key;
      }
    }
    return null;
  }
}