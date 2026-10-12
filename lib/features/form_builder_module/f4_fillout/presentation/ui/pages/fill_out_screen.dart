import 'package:get/get.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
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
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_state.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class FillOutScreen extends StatefulWidget {
  const FillOutScreen({super.key, required this.formModel});

  final FormEntity formModel;

  @override
  State<FillOutScreen> createState() => _FillOutScreenState();
}

class _FillOutScreenState extends State<FillOutScreen> {
  late FillOutCubit _cubit;

  // Form validation state lives in the page's StatefulWidget, not the cubit (§16).
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Get cubit reference and initialize it
    _cubit = context.read<FillOutCubit>();

    // ✅ Always reinitialize on hot reload or first load
    if (_cubit.state is FillOutInitial) {
      
      _cubit.init(model: widget.formModel);
      
    } else {
      
    }
  }

  @override
  void dispose() {
    // Don't dispose the cubit itself, just clean up its resources.
    // No try/catch in UI (§11.2) — dispose() must not throw.
    _cubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // CHANGED 19/8/2026 — one header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The crumbs also move OUT of the loaded-state branch: they used to
    // be built inside `if (state is FillOutLoaded)`, so while the form was
    // loading or errored the tablet layout had no header at all.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context)
            .detailsOfTitle(_getTitle(widget.formModel.formHeadModel, context)),
        thirdTitle: S.of(context).fillOutForm,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        child: SingleChildScrollView(
          child: BlocConsumer<FillOutCubit, FillOutState>(
          listener: (context, state) {
            
          },
          builder: (context, state) {

            if (state is FillOutInitial || state is FillOutLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(S.of(context).loadingForm, style: StyleText.fontSize14Weight500),
                    ],
                  ),
                ),
              );
            }

            if (state is FillOutError) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.red),
                      const SizedBox(height: 16),
                      Text(state.message, style: StyleText.fontSize14Weight500),
                    ],
                  ),
                ),
              );
            }

            if (state is FillOutLoaded) {

              final cubit = context.read<FillOutCubit>();

              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 15.w, end: 15.w, top: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(30),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          ContextExtension(context).isTablett ? 565.w : double.infinity,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int pageIndex = 0;
                              pageIndex < widget.formModel.pages.length;
                              pageIndex++) ...[
                                if (widget.formModel.pages.length != 1) ...[
                                  verticalSpace(10),
                                  Text(
                                    '${'Page'} ${pageIndex + 1}',
                                    style:
                                    StyleText.fontSize14Weight500,
                                  ),
                                  verticalSpace(10),
                                ],
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: widget.formModel.formHeadModel
                                          .horizontalPadding ??
                                          0,
                                      vertical: widget.formModel.formHeadModel
                                          .verticalPadding ??
                                          0),
                                  width: ContextExtension(context).isTablett
                                      ? 565.w
                                      : double.infinity,
                                  constraints:
                                  BoxConstraints(minHeight: 323.h),
                                  decoration: ShapeDecoration(
                                    color: AppColors.card,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        child: Transform.scale(
                                          scale: (widget.formModel.formHeadModel
                                              .watermarkSize! /
                                              100),
                                          child: Opacity(
                                              opacity: (widget
                                                  .formModel
                                                  .formHeadModel
                                                  .watermarkOpacity! /
                                                  100),
                                              child: widget.formModel
                                                  .formHeadModel
                                                  .watermark ==
                                                  null
                                                  ? null
                                                  : (widget
                                                  .formModel
                                                  .formHeadModel
                                                  .watermark!
                                                  .contains('http'))
                                                  ? Image.network(widget
                                                  .formModel
                                                  .formHeadModel
                                                  .watermark!)
                                                  : Image.file(File(widget
                                                  .formModel
                                                  .formHeadModel
                                                  .watermark!))),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          _buildPageRows(
                                              pageIndex, context, state, cubit),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              verticalSpace(15),
                              Row(
                                children: [
                                  _buildDiscardButton(context),
                                  const Spacer(),
                                  _buildSubmitButton(context),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
          ),
        ),
      ),
    );
  }

  // ... rest of your methods remain the same ...

  Widget _buildPageRows(int pageIndex, BuildContext context,
      FillOutLoaded state, FillOutCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int indexRow = 0;
        indexRow < state.pages[pageIndex].rows.length;
        indexRow++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: _buildRowWidgets(pageIndex, indexRow, state, cubit),
            ),
          )
        ]
      ],
    );
  }

  List<Widget> _buildRowWidgets(
      int pageIndex,
      int rowIndex,
      FillOutLoaded state,
      FillOutCubit cubit,
      ) {
    final rowControllers = state.pages[pageIndex].rows[rowIndex].controllers;

    return List.generate(
      rowControllers.length,
          (index) => [
        if (index != 0) horizontalSpace(15),
        Expanded(
          child: _buildWidget(
            rowControllers[index].type,
            rowControllers[index],
            state.isSubmitted,
          ),
        )
      ],
    ).expand((element) => element).toList();
  }

  Widget _buildWidget(
      FormFieldType type, FieldController controller, bool isSubmitted) {
    final widgetMap = {
      FormFieldType.dropDown: () => DropDownResultWidget(
        fieldController: controller as DropDownFieldController,
        isValidated: true,
      ),
      FormFieldType.image: () => ImagePreviewWidget(
        fieldController: controller as ImageFieldController,
        isValidated: true,
        isShownError: isSubmitted,
      ),
      FormFieldType.textField: () => TextFieldResultWidget(
        fieldController: controller as TextFieldController,
        isValidated: true,
      ),
      FormFieldType.email: () => EmailResultWidget(
        fieldController: controller as EmailFieldController,
        isValidated: true,
      ),
      FormFieldType.phone: () => PhoneResultWidget(
        fieldController: controller as PhoneFieldController,
        isValidated: true,
      ),
      FormFieldType.radio: () => RadioResultWidget(
        fieldController: controller as RadioFieldController,
        isValidated: true,
        isShownError: isSubmitted,
      ),
      FormFieldType.checkBox: () => CheckBoxResultWidget(
        fieldController: controller as CheckBoxFieldController,
        isValidated: true,
        isShownError: isSubmitted,
      ),
      FormFieldType.description: () => DescriptionResultWidget(
        fieldController: controller as DescriptionFieldController,
        isValidated: true,
      ),
      FormFieldType.link: () => LinkResultWidget(
        fieldController: controller as LinkFieldController,
        isValidated: true,
      ),
      FormFieldType.title: () => TitleResultWidget(
        fieldController: controller as TitleFieldController,
        isValidated: true,
      ),
      FormFieldType.dateSelector: () => DatePreviewWidget(
        fieldController: controller as DateFieldController,
        isValidated: true,
      ),
      FormFieldType.address: () => AddressPreviewWidget(
        fieldController: controller as AddressFieldController,
        isValidated: true,
      ),
      FormFieldType.timeSelector: () => TimeSelectorPreviewWidget(
        fieldController: controller as TimeSelectorFieldController,
        isValidated: true,
      ),
      FormFieldType.attachment: () => AttachmentPreviewWidget(
        fieldController: controller as AttachmentFieldController,
        isValidated: true,
        isShownError: isSubmitted,
      ),
      FormFieldType.digitalSignature: () =>
          AttachmentDigitalSignatureResultWidget(
            fieldController:
            controller as AttachmentDigitalSignatureFieldController,
            isValidated: true,
            isShownError: isSubmitted,
          ),
      FormFieldType.location: () => LocationResultWidget(
        fieldController: controller as LocationFieldController,
        isValidated: true,
      ),
      FormFieldType.radioTextField: () => RadioTextFieldResultWidget(
        fieldController: controller as RadioTextFieldController,
        isValidated: true,
        isShownError: isSubmitted,
      ),
    };
    return widgetMap[type]!();
  }

  Widget _buildDiscardButton(BuildContext context) {
    return customButtonWithSvg(
      title: 'Discard',
      function: () {
        context.pop();
      },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.black),
      color: AppColors.darkerGrey,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return customButtonWithSvg(
      title: 'Submit',
      function: () {
        final bool isCustomValid =
            context.read<FillOutCubit>().prepareSubmit();
        if (_formKey.currentState!.validate() && isCustomValid) {
          context.pop();
        }
      },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  String _getTitle(formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }

    return formHeadModel.title ?? '';
  }
}
