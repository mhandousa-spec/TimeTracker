// ******************* FILE INFO *******************
// File Name: service_header_widget
// Description: Service header widget.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/dialog.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/helper_method.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/success_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';


import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceHeaderWidget extends StatelessWidget {
  final ServicesHistoryModel createServicesModel;

  const ServiceHeaderWidget({
    required this.createServicesModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            FormatHelper.capitalize(S.of(context).serviceDetails),
            style: isMobile
                ? StyleText.fontSize16Weight600.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            )
                : StyleText.fontSize20Weight600.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
        ),
        const Spacer(),

        // Edit Button
        if (ServicesModuleAccess.canEditService)
          CustomEditIcon(
            color: AppColors.primary,
            borderColor: Colors.transparent,
            svgColor: AppColors.textButton,
            title: isMobile ? "" : FormatHelper.capitalize(S.of(context).Edit),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
            onTap: () async {
              // W01: no try/catch in a StatelessWidget build callback (§11.2);
              // the cubit owns error handling for the load.
              showLoadingIndicator();

              await ServicesManagerCubit.get(context)
                  .debugCreateServicesStructure(createServicesModel.currentId);

              final model = await ServicesManagerCubit.get(context)
                  .getDocToEdit(createServicesModel.currentId);

              hideLoadingIndicator();

              if (model != null) {
                navigateTo(
                  context,
                  CreateNewServicesLayout(
                    editingModel: model,
                    docId: model.currentId,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).failedToLoadServiceData),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

        // Gutter belongs to the pair, not to the page — with Edit hidden it
        // would otherwise leave a 15.w hole against the Delete button.
        if (ServicesModuleAccess.canEditService &&
            ServicesModuleAccess.canDeleteService)
          SizedBox(width: 15.w),

        // Delete Button
        if (ServicesModuleAccess.canDeleteService)
          CustomDeleteIcon(
            color: AppColors.red,
            borderColor: Colors.transparent,
            svgColor: AppColors.white,
            title: isMobile ? "" : FormatHelper.capitalize(S.of(context).Delete),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.white,
            ),
            onTap: () {
              showConfirmationDialogServicesDetails(
                lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_warning.json",
                title: S.of(context).deleteServices,
                message: S.of(context).AreYouSureDeleteThisService,
                onConfirm: () async {
                  await ServicesManagerCubit.get(context)
                      .deleteService(createServicesModel.currentId)
                      .then((val) async {
                    await ServicesManagerCubit.get(context).getAllServices();
                    navigateTo(context, LayoutScreenServices());
                  });

                  showSuccessDialogServicesDetails(
                    lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_approved.json",
                    subtitle: S.of(context).servicesDeleteDone,
                    title: S.of(context).deleteServices,
                    context: context,
                  );
                },
                context: context,
              );
            },
          ),
      ],
    );
  }
}
