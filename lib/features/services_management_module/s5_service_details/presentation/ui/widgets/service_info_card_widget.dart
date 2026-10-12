// ******************* FILE INFO *******************
// File Name: service_info_card_widget
// Description: Service info card widget.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/helper_method.dart' hide getLocalizedDurationUnit;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approval.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceInfoCardWidget extends StatefulWidget {
  final ServicesHistoryModel createServicesModel;

  const ServiceInfoCardWidget({
    required this.createServicesModel,
    super.key,
  });

  @override
  State<ServiceInfoCardWidget> createState() => _ServiceInfoCardWidgetState();
}

class _ServiceInfoCardWidgetState extends State<ServiceInfoCardWidget> {
  Future<Map<String, dynamic>?>? _providerFuture;

  Map<String, String> get enToArDepartments =>
      context.read<MainCoreDepartmentCubit>().enToAr;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode ? AppColors.white : AppColors.chatBackground,
          ),
          child: Column(
            children: [
              _buildHeaderSection(context, isMobile, lightMode, isArabic),
              isMobile ? SizedBox(height: 18.sp) : SizedBox(height: 18.sp),
              _buildProviderSection(context, isMobile),
              SizedBox(height: 20.sp),
              _buildDepartmentSection(context, isMobile, lightMode, isArabic),
              widget.createServicesModel.currentSelectDepartment.isEmpty
                  ? SizedBox()
                  : SizedBox(height: 20.sp),
              _buildApprovalCycleSection(context, isMobile, lightMode),
            ],
          ),
        ),
        _buildDateBadge(context, isMobile, lightMode),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isMobile, bool lightMode, bool isArabic) {
    return Row(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _buildServiceImage(context, isMobile, lightMode),
        SizedBox(width: 10.w),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Services mobile QA p.7: the card title showed the service
              // DESCRIPTION. It is the service name now, with the description
              // under it.
              isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatHelper.capitalize(isArabic
                        ? widget.createServicesModel.currentServiceNameArabic
                        : widget.createServicesModel.currentServiceNameEnglish),
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                  ),
                  if ((isArabic
                          ? widget.createServicesModel.currentServiceDescriptionArabic
                          : widget.createServicesModel.currentServiceDescriptionEnglish)
                      .trim()
                      .isNotEmpty) ...[
                    SizedBox(height: 4.sp),
                    Text(
                      FormatHelper.capitalize(isArabic
                          ? widget.createServicesModel.currentServiceDescriptionArabic
                          : widget.createServicesModel.currentServiceDescriptionEnglish),
                      style: StyleText.fontSize12Weight400.copyWith(
                        height: 1.4,
                        color: lightMode ? AppColors.secondaryText : AppColors.grey,
                      ),
                    ),
                  ],
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons_assets/services_assets/building_office.svg",
                        width: 17.w,
                        height: 17.h,
                        color: AppColors.secondaryText.withOpacity(.4),
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: 3.sp),
                      Text(
                        "${S.of(context).serviceDescription}",
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode ? AppColors.secondaryText : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    FormatHelper.capitalize(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? widget.createServicesModel.currentServiceDescriptionArabic ?? ''
                          : widget.createServicesModel.currentServiceDescriptionEnglish ?? '',
                    ),
                    style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                      height: 1.5,
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceImage(BuildContext context, bool isMobile, bool lightMode) {
    return Container(
      width: isMobile ? 50.sp : !isTabletLandscape(context) ? 80.sp : 100.sp,
      height: isMobile ? 50.sp : !isTabletLandscape(context) ? 80.sp : 100.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: lightMode ? AppColors.background : AppColors.background,
      ),
      child: (widget.createServicesModel.imageUrl != null && widget.createServicesModel.currentImageUrl.isNotEmpty)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: CachedNetworkImage(
          imageUrl: widget.createServicesModel.currentImageUrl,
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
              width: 40.sp,
              height: 40.sp,
              color: lightMode ? AppColors.secondaryText : AppColors.grey,
              fit: BoxFit.fill,
            );
          },
        ),
      )
          : Center(
        child: SvgPicture.asset(
          "assets/icons_assets/services_assets/headset_support.svg",
          width: isMobile ? 35.w : 50.w,
          height: isMobile ? 35.h : 50.h,
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  /// Resolves the provider to display.
  ///
  /// ✅ FIX ("No provider data found." on services whose Provider_Services is
  /// the empty string "[]"): documents written by paths that only persisted
  /// `Assigned_Provider_Email` (the bulk-upload flow did this for every row
  /// until the enrichment fix in UploadFileDetailsCubit._parseRow) have an
  /// empty provider pool, so computeProvider gets zero candidates and returns
  /// null. The assigned email is still on the document, so fall back to
  /// resolving it against the employee directory rather than showing an empty
  /// state. This also covers documents created before that fix, with no
  /// backfill migration needed.
  Future<Map<String, dynamic>?> _resolveProvider() async {
    final providers = widget.createServicesModel.currentProviderServices;
    if (providers.isNotEmpty) {
      return ServicesManagerCubit.get(context)
          .computeProvider(providerServices: providers);
    }

    final email = widget.createServicesModel.currentAssignedProviderEmail.trim();
    if (email.isEmpty) return null;

    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employeeController = Get.find<MainCoreEmployeeController>();
    if (employeeController.mapOfEmployeesWithEmailKey.isEmpty) {
      await employeeController.getAllNewEmployees();
    }
    final emp = employeeController.mapOfEmployeesWithEmailKey[email];

    // Even with no directory hit the email alone is more useful than the empty
    // state — the card renders '-' for the missing name fields.
    return {
      'id': emp?.id ?? '',
      'email': emp?.email ?? email,
      'firstName': emp?.firstName ?? '',
      'lastName': emp?.lastName ?? '',
      'firstNameInArabic': emp?.firstNameInArabic ?? '',
      'lastNameInArabic': emp?.lastNameInArabic ?? '',
      'title': emp?.title ?? '',
      'titleInArabic': emp?.titleInArabic ?? '',
      'departmentId': emp?.departmentId ?? '',
      'gender': emp?.gender ?? 'male',
      'mobilePhone': {
        'phone': emp?.mobilePhone?.phone ?? '',
        'countryCode': emp?.mobilePhone?.countryCode ?? '',
        'countryApp': emp?.mobilePhone?.countryApp ?? '',
      },
    };
  }

  Widget _buildProviderSection(BuildContext context, bool isMobile) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _providerFuture ??= _resolveProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProviderShimmer(context, isMobile);
        } else if (snapshot.hasData && snapshot.data != null) {
          final provider = snapshot.data!;
          return buildProviderServiceDetailsServices(
            owningDepartment: widget.createServicesModel.currentDepartmentRequester,
            context: context,
            durationUnit: FormatHelper.capitalize(
              getLocalizedDurationUnit(
                context,
                widget.createServicesModel.currentSelectedDurationUnit,
              ),
            ),
            provider: provider,
            requestModel: widget.createServicesModel,
          );
        } else {
          return Center(child: Text(S.of(context).Noproviderdatafound));
        }
      },
    );
  }

  Widget _buildProviderShimmer(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerPlaceholder(context: context, width: 200, height: 20),
            SizedBox(height: 10.h),
            _shimmerPlaceholder(context: context, width: 150, height: 20),
            SizedBox(height: 10.h),
            _shimmerPlaceholder(context: context, width: 180, height: 20),
          ],
        ),
        isMobile ? const SizedBox() : SizedBox(width: MediaQuery.sizeOf(context).width * .05),
        if (!isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerPlaceholder(context: context, width: 160, height: 20),
              SizedBox(height: 10.h),
              _shimmerPlaceholder(context: context, width: 140, height: 20),
              SizedBox(height: 10.h),
              _shimmerPlaceholder(context: context, width: 180, height: 20),
            ],
          ),
      ],
    );
  }

  Widget _shimmerPlaceholder({required BuildContext context, required double width, required double height}) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Shimmer.fromColors(
      baseColor: lightMode
          ? AppColors.secondaryText.withOpacity(0.3)
          : AppColors.grey.withOpacity(0.3),
      highlightColor: lightMode ? AppColors.background : AppColors.background.withOpacity(0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.secondaryText.withOpacity(0.1)
              : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  Widget _buildDepartmentSection(BuildContext context, bool isMobile, bool lightMode, bool isArabic) {
    if (widget.createServicesModel.currentSelectDepartment.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons_assets/services_assets/building_office.svg",
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.fill,

            ),
            SizedBox(width: 6.sp),
            Text(
              "${S.of(context).limitServiceAvailability}:",
              style: isMobile
                  ? StyleText.fontSize12Weight400.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              )
                  : StyleText.fontSize14Weight400.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        Wrap(
          spacing: 8.sp,
          runSpacing: 8.sp,
          children: widget.createServicesModel.currentSelectDepartment.map((departmentRaw) {
            String departmentKey = enToArDepartments.entries
                .firstWhere(
                  (entry) => entry.value == departmentRaw || entry.key == departmentRaw,
              orElse: () => MapEntry(departmentRaw, departmentRaw),
            )
                .key;

            final departmentText = isArabic ? enToArDepartments[departmentKey] ?? departmentKey : departmentKey;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: lightMode ? AppColors.background : AppColors.background,
              ),
              child: Text(
                FormatHelper.capitalize(departmentText),
                style: isMobile
                    ? StyleText.fontSize12Weight400.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                )
                    : StyleText.fontSize14Weight400.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildApprovalCycleSection(BuildContext context, bool isMobile, bool lightMode) {
    if (widget.createServicesModel.currentApprovalCycle.isEmpty) {
      return SizedBox();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${S.of(context).approvalCycle}: ",
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        isMobile
            ? buildApprovalCycle(context, widget.createServicesModel.currentApprovalCycle!, "assets/icons_assets/main_icons_assets/male_avatar.svg")
            : approvalCycleViewTablet(widget.createServicesModel.currentApprovalCycle!, context),
      ],
    );
  }

  Widget _buildDateBadge(BuildContext context, bool isMobile, bool lightMode) {
    return Padding(
      padding: EdgeInsets.only(left: 10.sp, right: 10.sp, top: 10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "${S.of(context).creationDate}: ",
            style: isMobile
                ? StyleText.fontSize10Weight400.copyWith(
              color: lightMode ? AppColors.secondaryText : AppColors.grey,
            )
                : StyleText.fontSize12Weight400.copyWith(
              color: lightMode ? AppColors.secondaryText : AppColors.grey,
            ),
          ),
          Text(
            DateFormat('dd MMM yyyy').format(
              widget.createServicesModel.timestamps.isNotEmpty
                  ? DateTime.fromMillisecondsSinceEpoch(widget.createServicesModel.timestamps.first)
                  : DateTime.now(),
            ),
            style: isMobile
                ? StyleText.fontSize10Weight400.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            )
                : StyleText.fontSize12Weight400.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
