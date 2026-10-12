import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart'; // ✅ ADD THIS IMPORT
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/address_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/attachment_digital_signature_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/attachment_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/check_box_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/date_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/description_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/drop_down_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/email_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/image_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/link_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/location_ruselt_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/phone_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/radio_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/radio_text_feild_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/text_field_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/time_selector_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_result_widgets/title_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/water_mark_image_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';

import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
/// PreviewScreen - Displays form preview in A4 paper format
/// Respects portrait/landscape orientation with fixed A4 dimensions
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — one header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The three crumbs are the ones PaginationAppBar was given, and
    // `breadcrumbPop` keeps them tappable the way it used to make them.
    return Scaffold(
      backgroundColor: AppColors.background ?? AppColors.grey,
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).creatingForm,
        thirdTitle: S.of(context).preview,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        // Bug report #3: Back / Save For Later / Publish under the preview,
        // the same three actions as the create page.
        child: ContextExtension(context).isPhone
            ? Column(
                children: [
                  _buildBody(context),
                  verticalSpace(16),
                  _buildPreviewActions(context),
                  verticalSpace(16),
                ],
              )
            : Column(
                children: [
                  Expanded(child: _buildBody(context)),
                  verticalSpace(12),
                  _buildPreviewActions(context),
                  verticalSpace(8),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewActions(BuildContext context) {
    final dataCubit = context.read<CreateFormDataCubit>();
    // Editing an existing form: its own screen owns Save/Publish-edit, so the
    // preview only offers Back.
    final dataState = dataCubit.state;
    final bool isCreating = dataState is! CreateFormDataLoaded ||
        dataState.existingFormId == null;

    Widget button({
      required String title,
      required Color color,
      required Color textColor,
      required VoidCallback onTap,
    }) {
      return customButtonWithSvg(
        fixedWidth: 150.w,
        title: title,
        function: onTap,
        textStyle: StyleText.fontSize16Weight500.copyWith(color: textColor),
        color: color,
        image: '',
        widthImage: 0,
        heightImage: 0,
        colorBorder: AppColors.transparent,
      );
    }

    return Row(
      children: [
        button(
          title: S.of(context).back,
          color: AppColors.darkGrey,
          textColor: AppColors.white,
          onTap: () => Navigator.of(context).pop(),
        ),
        if (isCreating) ...[
          horizontalSpace(12),
          button(
            title: S.of(context).saveForLater,
            // Bug report p.31: same darkGrey + white as Back beside it.
            color: AppColors.darkGrey,
            textColor: AppColors.white,
            onTap: () {
              context.read<HomeCubit>().draftNewForm(
                    model: dataCubit.createFormHomeModel(),
                    context: context,
                  );
            },
          ),
          const Spacer(),
          button(
            title: S.of(context).publish,
            color: AppColors.primary,
            textColor: AppColors.black,
            onTap: () {
              // Same validation the create page's Publish runs — its form is
              // still mounted underneath this route.
              final bool valid =
                  dataCubit.formCreateDataKey.currentState?.validate() ?? true;
              if (!valid) {
                Navigator.of(context).pop();
                return;
              }
              context.read<HomeCubit>().publishNewForm(
                    model: dataCubit.createFormHomeModel(),
                    context: context,
                    createFormDataCubit: dataCubit,
                  );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, dataState) {
        return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
          builder: (context, headState) {
            if (dataState is! CreateFormDataLoaded || headState is! CreateFormHeadLoaded) {
              return const CircleProgressMaster();
            }
            return _buildA4PreviewContainer(context, dataState, headState);
          },
        );
      },
    );
  }

  /// ✅ Builds multiple A4 services_management_module displayed vertically - NO nested scrolling
  Widget _buildA4PreviewContainer(
      BuildContext context,
      CreateFormDataLoaded dataState,
      CreateFormHeadLoaded headState,
      ) {
    final bool isLandscape = headState.orientation == 'Landscape';
    final double a4Width = isLandscape ? a4LandscapeWidth : a4PortraitWidth;
    final double a4Height = isLandscape ? a4LandscapeHeight : a4PortraitHeight;

    final double horizontalPadding =
        double.tryParse(headState.horizontalPaddingController.text) ?? 16.0;
    final double verticalPadding =
        double.tryParse(headState.verticalPaddingController.text) ?? 16.0;

    

    // ✅ Single outer ScrollView - no nested scrolling!
    return Center(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              for (int pageIndex = 0; pageIndex < dataState.pages.length; pageIndex++) ...[
                // ✅ ALWAYS show page header (even when collapsed) so user can expand again
                if (dataState.pages.length > 1) ...[
                  SizedBox(
                    width: a4Width, // Match A4 width for alignment
                    child: _buildPageHeader(context, dataState, pageIndex),
                  ),
                  const SizedBox(height: 10),
                ],

                // ✅ Only show A4 container content when expanded
                if (dataState.pages[pageIndex].isPageExpanded) ...[
                  // ✅ Fixed A4 page container
                  Container(
                    width: a4Width,
                    height: a4Height,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                    ),
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(), // ✅ Disable internal scrolling
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: WaterMarkImagePage(
                            page: _buildPageRows(context, dataState, pageIndex),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Spacing between pages
                  if (pageIndex < dataState.pages.length - 1)
                    const SizedBox(height: 30),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, CreateFormDataLoaded dataState, int pageIndex) {
    return Row(
      children: [
        Text(
          '${'Page'} ${pageIndex + 1}',
          style: StyleText.fontSize14Weight500,
        ),
        const Spacer(),
        _buildExpandCollapseButton(context, dataState, pageIndex),
      ],
    );
  }

  Widget _buildExpandCollapseButton(
      BuildContext context,
      CreateFormDataLoaded dataState,
      int pageIndex,
      ) {
    // No InkWell here on purpose: InkWell paints a hover highlight and a ripple
    // on desktop, which showed as a grey box behind the Hide/Expand text.
    // MouseRegion keeps the pointer cursor; GestureDetector keeps the tap.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.read<CreateFormDataCubit>().expandedPage(pageIndex),
        child: Text(
          dataState.pages[pageIndex].isPageExpanded
              ? S.of(context).hide
              : S.of(context).expand,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.blue,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildPageRows(BuildContext context, CreateFormDataLoaded dataState, int pageIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int indexRow = 0;
        indexRow < dataState.pages[pageIndex].rows.length;
        indexRow++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRowWidgets(
              context,
              dataState,
              pageIndex,
              indexRow,
            ),
          ),
          if (indexRow < dataState.pages[pageIndex].rows.length - 1)
            verticalSpace(15),
        ]
      ],
    );
  }

  List<Widget> _buildRowWidgets(
      BuildContext context,
      CreateFormDataLoaded dataState,
      int pageIndex,
      int rowIndex,
      ) {
    final rowControllers = dataState.pages[pageIndex].rows[rowIndex].controllers;

    return List.generate(
      rowControllers.length,
          (index) => [
        if (index != 0) horizontalSpace(15),
        Expanded(
          child: _buildWidget(
            rowControllers[index].type,
            index,
            rowIndex,
            pageIndex,
            dataState.pages[pageIndex].rows[rowIndex].controllers[index],
            rowControllers.length > 1,
          ),
        )
      ],
    ).expand((element) => element).toList();
  }

  // ✅ FIXED - Line 348 - Added Terms and Conditions case
  Widget _buildWidget(
      FormFieldType type,
      int index,
      int rowIndex,
      int pageIndex,
      FieldController fieldController,
      bool isExpand,
      ) {
    final widgetMap = {
      FormFieldType.dropDown: () => DropDownResultWidget(
        isReadOnly: true,
        isExpand: isExpand,
        fieldController: fieldController as DropDownFieldController,
      ),
      FormFieldType.image: () => ImagePreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as ImageFieldController,
      ),
      FormFieldType.textField: () => TextFieldResultWidget(
        isReadOnly: true,
        isExpand: isExpand,
        fieldController: fieldController as TextFieldController,
      ),
      FormFieldType.email: () => EmailResultWidget(
        isReadOnly: true,
        fieldController: fieldController as EmailFieldController,
        isExpand: isExpand,
      ),
      FormFieldType.phone: () => PhoneResultWidget(
        isReadOnly: true,
        isExpand: isExpand,
        fieldController: fieldController as PhoneFieldController,
      ),
      FormFieldType.location: () => LocationResultWidget(
        isReadOnly: true,
        fieldController: fieldController as LocationFieldController,
      ),
      FormFieldType.radio: () => RadioResultWidget(
        isReadOnly: true,
        fieldController: fieldController as RadioFieldController,
      ),
      FormFieldType.checkBox: () => CheckBoxResultWidget(
        isReadOnly: true,
        fieldController: fieldController as CheckBoxFieldController,
      ),
      // ✅ CRITICAL FIX - Added Terms and Conditions case
      FormFieldType.termsAndCondition: () => TermsAndConditionsPreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as TermsConditionsFieldController,
      ),
      FormFieldType.description: () => DescriptionResultWidget(
        isReadOnly: true,
        fieldController: fieldController as DescriptionFieldController,
        isExpand: isExpand,
      ),
      FormFieldType.attachment: () => AttachmentPreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as AttachmentFieldController,
      ),
      FormFieldType.link: () => LinkResultWidget(
        isReadOnly: true,
        fieldController: fieldController as LinkFieldController,
        isExpand: isExpand,
      ),
      FormFieldType.digitalSignature: () => AttachmentDigitalSignatureResultWidget(
        isReadOnly: true,
        fieldController:
        fieldController as AttachmentDigitalSignatureFieldController,
      ),
      FormFieldType.dateSelector: () => DatePreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as DateFieldController,
        isExpand: isExpand,
      ),
      FormFieldType.address: () => AddressPreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as AddressFieldController,
      ),
      FormFieldType.timeSelector: () => TimeSelectorPreviewWidget(
        isReadOnly: true,
        fieldController: fieldController as TimeSelectorFieldController,
      ),
      FormFieldType.title: () => TitleResultWidget(
        fieldController: fieldController as TitleFieldController,
      ),
      FormFieldType.radioTextField: () => RadioTextFieldResultWidget(
        isReadOnly: true,
        fieldController: fieldController as RadioTextFieldController,
      ),
    };
    return widgetMap[type]!();
  }
}