import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_state.dart';
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
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart' show LocationFieldController;
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
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
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
class SubmittedPageDetailsViewer extends StatefulWidget {
  const SubmittedPageDetailsViewer({
    required this.model,
    required this.pages,
    required this.isReadOnly,
    this.isSubmitted = true,
    this.width,
    super.key,
  });

  final double? width;
  final List<PageControllerModel> pages;
  final FormEntity model;
  final bool isReadOnly;
  final bool isSubmitted;

  @override
  State<SubmittedPageDetailsViewer> createState() => _SubmittedPageDetailsViewerState();
}

class _SubmittedPageDetailsViewerState extends State<SubmittedPageDetailsViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PdfCubit, PdfState>(
      builder: (context, pdfState) {
        if (pdfState is! PdfLoaded) {
          // ✅ If PdfCubit is not loaded yet, initialize it now
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<PdfCubit>().initialize(widget.pages.length);
            }
          });
          return const CircleProgressMaster();
        }

        // ✅ Safety check: Ensure widgetKeys match services_management_module length
        if (pdfState.isExpanded.length != widget.pages.length) {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<PdfCubit>().initialize(widget.pages.length);
            }
          });
          return const CircleProgressMaster();
        }

        final pdfCubit = context.read<PdfCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int pageIndex = 0;
            pageIndex < widget.pages.length;
            pageIndex++) ...[
              if (widget.pages.length != 1) ...[
                verticalSpace(10),
                Text(
                  '${'Page'} ${pageIndex + 1}',
                  style: StyleText.fontSize14Weight500,
                ),
                verticalSpace(10),
              ],

              Container(
                width: widget.width,
                constraints: BoxConstraints(minHeight: 323.h),
                decoration: ShapeDecoration(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: RepaintBoundary(
                  key: pdfCubit.widgetKeys[pageIndex],
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Transform.scale(
                          scale: (widget.model.formHeadModel.watermarkSize! /
                              100),
                          child: Opacity(
                            opacity:
                            (widget.model.formHeadModel.watermarkOpacity! /
                                100),
                            child: widget.model.formHeadModel.watermark == null
                                ? null
                                : Image.network(
                              widget.model.formHeadModel.watermark!,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          widget.model.formHeadModel.horizontalPadding ?? 16,
                          vertical: widget.model.formHeadModel.verticalPadding ?? 16,
                        ),
                        child: Column(
                          children: [
                            _buildPageRows(pageIndex, context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPageRows(int pageIndex, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int indexRow = 0;
        indexRow < widget.pages[pageIndex].rows.length;
        indexRow++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRowWidgets(pageIndex, indexRow),
            ),
          )
        ]
      ],
    );
  }

  List<Widget> _buildRowWidgets(int pageIndex, int rowIndex) {
    final rowControllers = widget.pages[pageIndex].rows[rowIndex].controllers;

    return List.generate(
      rowControllers.length,
          (index) => [
        if (index != 0) horizontalSpace(15),
        Expanded(
          child: _buildWidget(
            rowControllers[index].type,
            rowControllers[index],
            rowControllers.length > 1,
          ),
        )
      ],
    ).expand((element) => element).toList();
  }

  Widget _buildWidget(
      FormFieldType type,
      FieldController controller,
      bool isExpand,
      ) {
    final widgetMap = {
      FormFieldType.dropDown: () => DropDownResultWidget(
        fieldController: controller as DropDownFieldController,
        isValidated: true,
        value: controller.currentValue,
        isExpand: isExpand,
        isReadOnly: true,
        onChanged: _isOnChange()
            ? (value) {
          controller.currentValue = value;
          setState(() {});
        }
            : null,
      ),
      FormFieldType.image: () {
        return ImagePreviewWidget(
          fieldController: controller as ImageFieldController,
          isValidated: true,
          isShownError: widget.isSubmitted,
          isReadOnly: widget.isReadOnly,
        );
      },
      FormFieldType.textField: () => TextFieldResultWidget(
        fieldController: controller as TextFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
          controller.answer = value;
        }
            : null,
      ),
      FormFieldType.email: () => EmailResultWidget(
        fieldController: controller as EmailFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
          controller.answer = value;
        }
            : null,
      ),
      FormFieldType.phone: () => PhoneResultWidget(
        fieldController: controller as PhoneFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onSelectCountry: _isOnChange()
            ? (value) {
          controller.currentCountry = value.countryCode;
          setState(() {});
        }
            : null,
        onChangePhone: _isOnChange()
            ? (value) {
          controller.phoneAnswer = value;
        }
            : null,
      ),
      FormFieldType.radio: () => RadioResultWidget(
        fieldController: controller as RadioFieldController,
        isValidated: true,
        isShownError: true,
        isReadOnly: widget.isReadOnly,
        onTapRadio: _isOnChange()
            ? (String value) {
          controller.selectedRadio = value;
          setState(() {});
        }
            : null,
      ),
      FormFieldType.checkBox: () => CheckBoxResultWidget(
        fieldController: controller as CheckBoxFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.termsAndCondition: () => TermsAndConditionsPreviewWidget(
        fieldController: controller as TermsConditionsFieldController,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.description: () => DescriptionResultWidget(
        fieldController: controller as DescriptionFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.link: () => LinkResultWidget(
        fieldController: controller as LinkFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value) {
          controller.answer = value;
        }
            : null,
      ),
      FormFieldType.title: () => TitleResultWidget(
        fieldController: controller as TitleFieldController,
        isValidated: true,
      ),
      FormFieldType.dateSelector: () => DatePreviewWidget(
        fieldController: controller as DateFieldController,
        isValidated: true,
        isExpand: isExpand,
        isReadOnly: widget.isReadOnly,
        onDateChanged: (value) {
          controller.answerDate = value;
        },
      ),
      FormFieldType.address: () => AddressPreviewWidget(
        fieldController: controller as AddressFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
        onChanged: _isOnChange()
            ? (value, index) {
          if (controller.answers == null ||
              controller.answers!.isEmpty) {
            controller.answers = List.generate(
              controller.hints!.length,
                  (index) => '',
            );
          }
          controller.answers![index] = value;
        }
            : null,
      ),
      FormFieldType.timeSelector: () => TimeSelectorPreviewWidget(
        fieldController: controller as TimeSelectorFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
        onTapZone: _isOnChange()
            ? () {
          if (controller.amOrPM == "AM") {
            controller.amOrPM = 'PM';
            setState(() {});
            return;
          }
          controller.amOrPM = 'AM';
          setState(() {});
        }
            : null,
        onTapTime: _isOnChange()
            ? (value) {
          if (value != null) {
            String formattedTime = FormDateTimeHelper.formatTime(
              FormDateTimeHelper.formatTimeOfDayToDateTime(
                  value, null),
            );
            controller.time = formattedTime.split(" ")[0];
            controller.amOrPM = formattedTime.split(" ")[1];

            setState(() {});
          }
        }
            : null,
      ),
      FormFieldType.attachment: () => AttachmentPreviewWidget(
        fieldController: controller as AttachmentFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.digitalSignature: () =>
          AttachmentDigitalSignatureResultWidget(
            fieldController:
            controller as AttachmentDigitalSignatureFieldController,
            isValidated: true,
            isShownError: widget.isSubmitted,
            isReadOnly: widget.isReadOnly,
          ),
      FormFieldType.location: () => LocationResultWidget(
        fieldController: controller as LocationFieldController,
        isValidated: true,
        isReadOnly: widget.isReadOnly,
      ),
      FormFieldType.radioTextField: () => RadioTextFieldResultWidget(
        fieldController: controller as RadioTextFieldController,
        isValidated: true,
        isShownError: widget.isSubmitted,
        isReadOnly: widget.isReadOnly,
        onTapRadio: _isOnChange()
            ? (String value) {
          controller.selectedRadio = value;
          setState(() {});
        }
            : null,
      ),
    };

    return widgetMap[type]!();
  }

  bool _isOnChange() {
    return widget.model.status != FormStatus.submissions ||
        (widget.model.status == FormStatus.submissions && !widget.isReadOnly);
  }
}