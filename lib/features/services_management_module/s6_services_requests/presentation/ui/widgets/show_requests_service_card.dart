// ******************* FILE INFO *******************
// File Name: show_requests_service_card
// Description: Show requests service card.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'dart:math';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/reuse_text.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/services/services_notification_service.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_lookup_cache.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CustomServiceCard extends StatelessWidget {
  final String serviceName;
  final String owningDepartment;
  final String serviceProvider;
  final String jobTitle;
  final String durationOfServices;
  final String approval;
  final ServicesHistoryModel model;

  CustomServiceCard({
    super.key,
    required this.serviceName,
    required this.owningDepartment,
    required this.serviceProvider,
    required this.jobTitle,
    required this.durationOfServices,
    required this.approval,
    required this.model,
  });

  var employeeEntity = AppControllers.employee.employeeEntity!;

  // ✅ Helper function to format duration with proper plural forms
  String _formatDuration(String duration, String unit, bool isArabic) {
    try {
      final durationValue = int.tryParse(duration) ?? 0;

      if (isArabic) {
        // Arabic plural rules
        if (unit.toLowerCase().contains('day') || unit.toLowerCase().contains('يوم')) {
          if (durationValue == 1) {
            return '$durationValue يوم';
          } else if (durationValue == 2) {
            return '$durationValue يومين';
          } else {
            return '$durationValue أيام';
          }
        } else if (unit.toLowerCase().contains('week') || unit.toLowerCase().contains('أسبوع')) {
          if (durationValue == 1) {
            return '$durationValue أسبوع';
          } else if (durationValue == 2) {
            return '$durationValue أسبوعين';
          } else {
            return '$durationValue أسابيع';
          }
        } else if (unit.toLowerCase().contains('month') || unit.toLowerCase().contains('شهر')) {
          if (durationValue == 1) {
            return '$durationValue شهر';
          } else if (durationValue == 2) {
            return '$durationValue شهرين';
          } else {
            return '$durationValue أشهر';
          }
        } else if (unit.toLowerCase().contains('year') || unit.toLowerCase().contains('سنة')) {
          if (durationValue == 1) {
            return '$durationValue سنة';
          } else if (durationValue == 2) {
            return '$durationValue سنتين';
          } else {
            return '$durationValue سنوات';
          }
        }
      } else {
        // English plural rules
        if (unit.toLowerCase().contains('day') || unit.toLowerCase().contains('يوم')) {
          return durationValue == 1 ? '$durationValue day' : '$durationValue days';
        } else if (unit.toLowerCase().contains('week') || unit.toLowerCase().contains('أسبوع')) {
          return durationValue == 1 ? '$durationValue week' : '$durationValue weeks';
        } else if (unit.toLowerCase().contains('month') || unit.toLowerCase().contains('شهر')) {
          return durationValue == 1 ? '$durationValue month' : '$durationValue months';
        } else if (unit.toLowerCase().contains('year') || unit.toLowerCase().contains('سنة')) {
          return durationValue == 1 ? '$durationValue year' : '$durationValue years';
        }
      }

      // Fallback: return original if no match
      return '$duration $unit';
    } catch (e) {
      return '$duration $unit';
    }
  }

  // ✅ NEW: Get owning department using MainCore
  Future<Map<String, String>> _getOwningDepartment(BuildContext context) async {
    try {

      final employeeController = AppControllers.employee;

      if (employeeController.employeeEntity == null) {
        return {'english': '', 'arabic': ''};
      }

      final requesterEmail = employeeController.employeeEntity!.email ?? '';

      // Get employee's department ID
      final employeeEntity = employeeController.mapOfEmployeesWithEmailKey[requesterEmail];

      if (employeeEntity == null) {
        return {'english': '', 'arabic': ''};
      }

      final departmentId = employeeEntity.departmentId ?? '';

      if (departmentId.isEmpty) {
        return {'english': '', 'arabic': ''};
      }

      // Get department names from MainCoreDepartmentCubit
      final deptController = context.read<MainCoreDepartmentCubit>();

      final deptNameEnglish = deptController.getDepartmentName(departmentId, true);
      final deptNameArabic = deptController.getDepartmentName(departmentId, false);

      return {
        'english': deptNameEnglish,
        'arabic': deptNameArabic,
      };
    } catch (e) {
      return {'english': '', 'arabic': ''};
    }
  }

  // ✅ NEW: Get service names and duration from CreateServices collection
  Future<Map<String, String>> _getServiceDataFromCreateServices(
      CreateServicesRepository repository) async {
    try {

      // ✅ FIX: Use parentServiceId to get the original service from CreateServices
      final parentServiceId = model.currentId;

      if (parentServiceId.isEmpty) {

        // ✅ FALLBACK: Try using currentId if parentServiceId is empty
        final fallbackId = model.currentId;

        if (fallbackId.isEmpty) {
          return {
            'serviceNameEnglish': '',
            'serviceNameArabic': '',
            'duration': '',
            'unit': '',
          };
        }

        // Use fallback ID
        final serviceId = fallbackId;
      }

      final serviceId = parentServiceId.isNotEmpty ? parentServiceId : model.currentId;

      if (serviceId.isEmpty) {
        return {
          'serviceNameEnglish': '',
          'serviceNameArabic': '',
          'duration': '',
          'unit': '',
        };
      }

      // Path: /Demo/{companyId}/Modules/services/CreateServices/{serviceId} (resolved in repository)
      final data = await repository.getCreateServiceDocById(serviceId);

      if (data == null) {
        return {
          'serviceNameEnglish': '',
          'serviceNameArabic': '',
          'duration': '',
          'unit': '',
        };
      }

      // Extract service names (English & Arabic)
      String serviceNameEnglish = '';
      String serviceNameArabic = '';

      if (data['serviceNameEnglish'] != null) {
        if (data['serviceNameEnglish'] is List) {
          final nameList = data['serviceNameEnglish'] as List;
          serviceNameEnglish = nameList.isNotEmpty ? nameList.last.toString() : '';
        } else {
          serviceNameEnglish = data['serviceNameEnglish'].toString();
        }
      }

      if (data['serviceNameArabic'] != null) {
        if (data['serviceNameArabic'] is List) {
          final nameList = data['serviceNameArabic'] as List;
          serviceNameArabic = nameList.isNotEmpty ? nameList.last.toString() : '';
        } else {
          serviceNameArabic = data['serviceNameArabic'].toString();
        }
      }

      // Extract duration and unit from arrays (last values)
      String duration = '';
      String unit = '';

      if (data['durationOfServices'] != null) {
        if (data['durationOfServices'] is List) {
          final durationList = data['durationOfServices'] as List;
          duration = durationList.isNotEmpty ? durationList.last.toString() : '';
        } else {
          duration = data['durationOfServices'].toString();
        }
      }

      if (data['selectedDurationUnit'] != null) {
        if (data['selectedDurationUnit'] is List) {
          final unitList = data['selectedDurationUnit'] as List;
          unit = unitList.isNotEmpty ? unitList.last.toString() : '';
        } else {
          unit = data['selectedDurationUnit'].toString();
        }
      }

      return {
        'serviceNameEnglish': serviceNameEnglish,
        'serviceNameArabic': serviceNameArabic,
        'duration': duration,
        'unit': unit,
      };
    } catch (e) {
      return {
        'serviceNameEnglish': '',
        'serviceNameArabic': '',
        'duration': '',
        'unit': '',
      };
    }
  }

  // ✅ NEW: Helper to get user's language preference
  Future<bool> _getUserLanguagePreference(
      String userEmail, CreateServicesRepository repository) async {
    final data = await repository.getUserByEmail(userEmail);
    if (data != null) {
      final languageCode = data['languageCode'] ?? 'en';
      return languageCode == 'ar';
    }
    return false;
  }

  // ✅ Send notification to first approver
  //
  // MOVED 30/8/2026 to `ServicesNotificationService`, the same call
  // `_RequestServicesDetailsState._sendNotificationToFirstApprover`
  // (request_details_part2.dart) already makes. What was here was a second,
  // hand-rolled copy of the whole pipeline — fetch the `services` /
  // `needs_approval` template, pick the Arabic or English subject and body,
  // substitute `{{serviceName}}` and `{{requesterName}}`, build a
  // `NotificationModelSystem` with `nameOfPage: 'ApprovalRequestCard'`, upload
  // it, then push — with the module name, the page name and the event key
  // written out as bare strings. Two copies of that meant a template or page
  // rename had to be found in both places.
  //
  // The resolved values are unchanged: template `services_needs_approval`,
  // page `ApprovalRequestCard`, variables `serviceName` + `requesterName`.
  Future<void> _sendNotificationToFirstApprover({
    required String firstApproverEmail,
    required String serviceName,
    required String requesterName,
    required CreateServicesRepository repository,
  }) async {
    if (firstApproverEmail.isEmpty) return;

    final isArabic =
        await _getUserLanguagePreference(firstApproverEmail, repository);

    await ServicesNotificationService.notifyApproverOfNewRequest(
      senderEmail: employeeEntity.email ?? '',
      approverEmail: firstApproverEmail,
      serviceName: serviceName,
      requesterName: requesterName,
      isArabic: isArabic,
    );
  }

  // ✅ Send notification to requester (confirmation)
  //
  // MOVED 30/8/2026, same as above — template `services_request_submitted`,
  // page `RequestServicesToggle`, variable `serviceName`.
  //
  // NOTE one deliberate behaviour change carried over from the shared service:
  // the old inline copy returned early when `!template.hasPush`, which
  // suppressed the in-app notification as well as the push. The sender now
  // writes the in-app document whenever the template is enabled and gates only
  // the FCM push on `hasPush`. Errors are no longer swallowed silently either
  // — the sender logs them and resolves `false`.
  Future<void> sendNotificationToRequester({
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
  }) async {
    if (requesterEmail.isEmpty) return;

    await ServicesNotificationService.notifyRequesterOfSubmission(
      senderEmail: employeeEntity.email ?? '',
      requesterEmail: requesterEmail,
      serviceName: serviceName,
      isArabic: isArabic,
    );
  }

  @override
  Widget build(BuildContext cardContext) {
    final dateTime = Timestamp.now().toDate();
    final formatted = DateFormat("MMMdd_yyyy").format(dateTime);
    final lightMode = Theme.of(cardContext).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(cardContext).languageCode == 'ar';
    final isMobile = ContextExtension(cardContext).isPhone;

    return BlocConsumer<ServicesManagerCubit, ServicesManagerState>(
      listener: (context, state) {},
      builder: (context, state) {
        final repository = ServicesManagerCubit.get(context).repository;
        return FutureBuilder<Map<String, dynamic>>(
          // ✅ Fetch service data (names + duration) AND owning department.
          // Memoised so rebuilds (resize / bloc emit) don't refetch and flash "...".
          future: ServiceLookupCache.cardData(
            model.currentId,
            () => Future.wait([
              _getServiceDataFromCreateServices(repository),
              _getOwningDepartment(context),
            ]).then((results) {
              return {
                'serviceData': results[0] as Map<String, String>,
                'department': results[1] as Map<String, String>,
              };
            }),
          ),
          builder: (context, snapshot) {
            // ✅ Display data from CreateServices and MainCore
            String displayServiceName = serviceName;
            String displayOwningDepartment = owningDepartment;
            String displayDuration = durationOfServices;

            if (snapshot.hasData) {
              final data = snapshot.data!;
              final serviceData = data['serviceData'] as Map<String, String>;
              final deptData = data['department'] as Map<String, String>;

              // Use service name from CreateServices
              if (isArabic) {
                if (serviceData['serviceNameArabic']!.isNotEmpty) {
                  displayServiceName = serviceData['serviceNameArabic']!;
                }
              } else {
                if (serviceData['serviceNameEnglish']!.isNotEmpty) {
                  displayServiceName = serviceData['serviceNameEnglish']!;
                }
              }

              // Use department from MainCore
              if (deptData['english']!.isNotEmpty || deptData['arabic']!.isNotEmpty) {
                displayOwningDepartment = isArabic
                    ? deptData['arabic']!
                    : deptData['english']!;
              }

              // Use duration from CreateServices collection
              if (serviceData['duration']!.isNotEmpty && serviceData['unit']!.isNotEmpty) {
                displayDuration = _formatDuration(
                  serviceData['duration']!,
                  serviceData['unit']!,
                  isArabic,
                );
              }
            }

            return MediaQuery.withClampedTextScaling(
              // Keeps the card's real height in sync with the grid's
              // mainAxisExtent (see ServiceCardMetrics).
              maxScaleFactor: 1.4,
              child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.white
                    : AppColors.chatBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 15.sp, right: 15.sp, left: 15.sp,bottom: 15.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.sp,
                          height: 40.sp,
                          decoration: BoxDecoration(
                            color: lightMode ? AppColors.background : AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: (model.currentImageUrl.isNotEmpty)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CachedNetworkImage(
                              imageUrl: model.currentImageUrl,
                              width: 40.sp,
                              height: 40.sp,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: lightMode
                                    ? AppColors.secondaryText.withOpacity(0.3)
                                    : AppColors.grey.withOpacity(0.3),
                                highlightColor: lightMode
                                    ? AppColors.background
                                    : AppColors.background.withOpacity(0.5),
                                child: Container(
                                  width: 40.sp,
                                  height: 40.sp,
                                  decoration: BoxDecoration(
                                    color: lightMode
                                        ? AppColors.secondaryText.withOpacity(0.1)
                                        : AppColors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return SvgPicture.asset(
                                  'assets/icons_assets/services_assets/clock_dashed.svg',
                                  width: 20.sp,
                                  height: 20.sp,
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.grey,
                                  fit: BoxFit.scaleDown,
                                );
                              },
                            ),
                          )
                              : SvgPicture.asset(
                            "assets/icons_assets/services_assets/headset_support.svg",
                            width: 20.sp,
                            height: 20.sp,
                            color: lightMode ? AppColors.secondaryText : AppColors.grey,
                            fit: BoxFit.scaleDown,
                            semanticsLabel: 'Dart Logo',
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            FormatHelper.capitalize(serviceName),
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.sp),
                    textCorner(
                      image: "assets/icons_assets/services_assets/hand_key_ownership.svg",
                      label: "${S.of(context).OwningDepartment}: ",
                      content: displayOwningDepartment,
                      context: context,
                    ),
                    SizedBox(height: 5.sp),
                    textCorner(
                      image: "assets/icons_assets/main_icons_assets/person_outline.svg",
                      label: "${S.of(context).serviceProvider}: ",
                      content: FormatHelper.capitalize(serviceProvider),
                      context: context,
                    ),
                    SizedBox(height: 5.sp),
                    textCorner(
                      image: "assets/icons_assets/main_icons_assets/Case.svg",
                      label: "${S.of(context).jobTitle}: ",
                      content: FormatHelper.capitalize(jobTitle),
                      context: context,
                    ),
                    SizedBox(height: 5.sp),
                    textCorner(
                      image: "assets/icons_assets/services_assets/clock_dashed.svg",
                      label: "${S.of(context).durationOfService}: ",
                      content: FormatHelper.capitalize(displayDuration),
                      context: context,
                    ),
                    SizedBox(height: 5.sp),
                    textCorner(
                      image: "assets/icons_assets/watermark/approval.svg",
                      label: "${S.of(context).approvals}: ",
                      content: FormatHelper.capitalize(approval),
                      context: context,
                    ),
                    SizedBox(height: 10.sp),
                    Expanded(
                      child: customButton(
                        title: FormatHelper.capitalize(S.of(context).request),
                        function: () {
                          final random = Random().nextInt(100);
                          final dateTime = Timestamp.now().toDate();
                          final formatted = DateFormat("MMMdd_yyyy").format(dateTime);
                          final docId = "Request$random$formatted";

                          // ⚠️ Captured HERE, from the BlocConsumer's context.
                          // The dialog is pushed on the root navigator, so its
                          // context is NOT below the BlocProvider — looking the
                          // cubit up inside the dialog throws ProviderNotFound.
                          final servicesCubit = ServicesManagerCubit.get(context);

                          // Declared outside the StatefulBuilder so setState
                          // doesn't reset it back to false on every rebuild.
                          bool isLoading = false;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  backgroundColor: Theme.of(context).brightness == Brightness.light
                                      ? AppColors.white
                                      : AppColors.chatBackground,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.sp),
                                    width: 411.sp,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Lottie.asset(
                                          'assets/lottie_assets/roles_lottie_assets/createServices.json',
                                          width: 80.sp,
                                          height: 80.sp,
                                          fit: BoxFit.scaleDown,
                                          repeat: true,
                                          animate: true,
                                        ),
                                        SizedBox(height: 8.sp),
                                        Text(
                                          FormatHelper.capitalize(S.of(context).RequestService),
                                          style: StyleText.fontSize20Weight500.copyWith(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? AppColors.blackButton
                                                : AppColors.white,
                                          ),
                                        ),
                                        SizedBox(height: 10.sp),
                                        Text(
                                          FormatHelper.capitalize(S.of(context).AreYouSureYouWantToRequestThisService),
                                          textAlign: TextAlign.center,
                                          style: StyleText.fontSize14Weight500.copyWith(
                                            color: Theme.of(context).brightness == Brightness.light
                                                ? AppColors.secondaryText
                                                : AppColors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 15.h),

                                        if (isLoading)
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10.h),
                                            child: const CircleProgressMaster(),
                                          )
                                        else
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              customButton(
                                                title: FormatHelper.capitalize(S.of(context).no),
                                                function: () => Navigator.pop(context),
                                                textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                                                width: isMobile ? 120.sp : 135.sp,
                                                height: 38.sp,
                                                radius: 8.r,
                                                color: AppColors.secondaryAction,
                                              ),
                                              SizedBox(width: 28.w),
                                              customButton(
                                                title: FormatHelper.capitalize(S.of(context).yes),
                                                function: () async {
                                                  // Bug report p.23: "loading indicator on all page".
                                                  // The spinner used to replace the buttons INSIDE this
                                                  // dialog. Close it and cover the whole page with the
                                                  // app's standard modal loader instead.
                                                  Navigator.pop(context);
                                                  showLoadingIndicator();
                                                  bool loaderShown = true;
                                                  void hideLoader() {
                                                    if (loaderShown) {
                                                      loaderShown = false;
                                                      hideLoadingIndicator();
                                                    }
                                                  }

                                                  try {

                                                    final employeeController = AppControllers.employee;

                                                    if (employeeController.employeeEntity == null) {
                                                      throw Exception("Please log in first");
                                                    }

                                                    final loggedInEmployee = employeeController.employeeEntity!;
                                                    final requesterEmail = loggedInEmployee.email ?? '';

                                                    if (requesterEmail.isEmpty) {
                                                      throw Exception("Employee email is required");
                                                    }

                                                    final approvalList = model.currentApprovalCycle;
                                                    final initialState = approvalList.isEmpty ? 'approved' : 'pending';

                                                    final updatedRequest = ServicesHistoryModel.createMinimalRequest(
                                                      parentServiceId: model.currentId,
                                                      id: model.currentId,
                                                      providerServices: model.currentProviderServices,
                                                      emailRequester: requesterEmail,
                                                      approvalCycle: approvalList,
                                                      state: initialState,
                                                      status: 'active',
                                                    );

                                                    final requesterFullName = "${loggedInEmployee.firstName ?? ''} ${loggedInEmployee.lastName ?? ''}".trim();

                                                    final servicesRequestedModel = RequestedServices(
                                                      id: updatedRequest.currentId,
                                                      requestDate: formatted,
                                                      serviceProvider: updatedRequest.currentProviderServices,
                                                      serviceRequester: requesterFullName,
                                                      status: "Active",
                                                      state: initialState,
                                                    );

                                                    await servicesCubit.addRequestedService(
                                                      docId: updatedRequest.currentId,
                                                      requestModel: servicesRequestedModel,
                                                      uidUser: updatedRequest.currentId,
                                                    );

                                                    await servicesCubit.uploadRequestServices(docId, updatedRequest);

                                                    await servicesCubit.getMyRequestServices();
                                                    await servicesCubit.getMyApprovalServices(requesterEmail);

                                                    final requesterFirstName = isArabic
                                                        ? (loggedInEmployee.firstNameInArabic ?? loggedInEmployee.firstName ?? '')
                                                        : (loggedInEmployee.firstName ?? '');
                                                    final requesterLastName = isArabic
                                                        ? (loggedInEmployee.lastNameInArabic ?? loggedInEmployee.lastName ?? '')
                                                        : (loggedInEmployee.lastName ?? '');
                                                    final requesterFullNameForNotification = "$requesterFirstName $requesterLastName".trim();

                                                    final serviceNameForNotification = isArabic
                                                        ? model.currentServiceNameArabic
                                                        : model.currentServiceNameEnglish;

                                                    if (requesterEmail.isNotEmpty) {
                                                      await sendNotificationToRequester(
                                                        requesterEmail: requesterEmail,
                                                        serviceName: serviceNameForNotification,
                                                        isArabic: isArabic,
                                                      );
                                                    }

                                                    if (approvalList.isNotEmpty) {
                                                      final firstApprover = approvalList.first;
                                                      final firstApproverEmail = firstApprover.email ?? '';

                                                      if (firstApproverEmail.isNotEmpty) {
                                                        await _sendNotificationToFirstApprover(
                                                          firstApproverEmail: firstApproverEmail,
                                                          serviceName: serviceNameForNotification,
                                                          requesterName: requesterFullNameForNotification,
                                                          repository: repository,
                                                        );
                                                      }
                                                    }

                                                    hideLoader();
                                                    if (!cardContext.mounted) return;

                                                    showDialog(
                                                      context: cardContext,
                                                      barrierDismissible: true,
                                                      builder: (dialogCtx) {
                                                        Future.delayed(const Duration(seconds: 2), () {
                                                          if (Navigator.of(dialogCtx).canPop()) {
                                                            Navigator.of(dialogCtx).pop();
                                                          }
                                                          Navigator.of(cardContext).push(
                                                            MaterialPageRoute(builder: (_) => MyRequestServicesToggle()),
                                                          );
                                                        });

                                                        return Dialog(
                                                          backgroundColor: Theme.of(dialogCtx).brightness == Brightness.light
                                                              ? AppColors.white
                                                              : AppColors.chatBackground,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(vertical: 15.h),
                                                            width: 411.sp,
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Lottie.asset(
                                                                  'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                                                                  width: 70.w,
                                                                  height: 70.h,
                                                                  fit: BoxFit.scaleDown,
                                                                ),
                                                                SizedBox(height: 8.h),
                                                                Text(
                                                                  FormatHelper.capitalize(S.of(dialogCtx).serviceRequested),
                                                                  style: StyleText.fontSize20Weight500.copyWith(
                                                                    color: Theme.of(dialogCtx).brightness == Brightness.light
                                                                        ? AppColors.blackButton
                                                                        : AppColors.white,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 10.h),
                                                                Text(
                                                                  FormatHelper.capitalize(S.of(dialogCtx).YouSuccessfullyRequestedThisService),
                                                                  textAlign: TextAlign.center,
                                                                  style: StyleText.fontSize14Weight500.copyWith(
                                                                    color: Theme.of(dialogCtx).brightness == Brightness.light
                                                                        ? AppColors.secondaryText
                                                                        : AppColors.grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } catch (e, stackTrace) {
                                                    debugPrint('❌ REQUEST SERVICE FAILED: $e');
                                                    debugPrintStack(stackTrace: stackTrace);

                                                    hideLoader();
                                                    if (!cardContext.mounted) return;
                                                    // The app's error dialog, not a Material AlertDialog.
                                                    CustomDialogManager.showMessage(
                                                      context: cardContext,
                                                      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
                                                      title: S.of(cardContext).error,
                                                      subtitle: S.of(cardContext).failedToCreateServiceRequest,
                                                    );
                                                  }
                                                },
                                                textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                                                width: isMobile ? 120.sp : 135.sp,
                                                height: 38.sp,
                                                radius: 8.r,
                                                color: AppColors.primary,
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                        height: 35.sp,
                        // ✅ FIX: the Request button only filled part of the card.
                        //
                        // customButton IGNORES `width` on purpose — sizing is
                        // enforced app-wide by ButtonSizing (135.sp on tablet),
                        // so `width: double.infinity` here did nothing and the
                        // button sat at its standard width inside a much wider
                        // card. `exactWidth` is the documented opt-out from
                        // that rule, so the card's own full width wins here.
                        exactWidth: double.infinity,
                        width: double.infinity,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }
}
