import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Keep for .tr

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/address_pdf_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/attachment_digital_signature_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/attachment_pdf_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/check_box_pdf_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/date_pdf_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/description_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/drop_down_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/email_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/image_pdf_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/link_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/location_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/phone_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/radio_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/radio_text_field_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/text_field_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/time_selector_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/pdf_review/title_pdf_result_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/terms_preview.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/ui/widgets/water_mark_image_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/title_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';

import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';

class ConvertPdfScreen extends StatefulWidget {
  const ConvertPdfScreen({super.key, required this.formModel});
  final FormEntity formModel;

  @override
  State<ConvertPdfScreen> createState() => _ConvertPdfScreenState();
}

class _ConvertPdfScreenState extends State<ConvertPdfScreen> {
  // ✅ A4 dimensions at 96 DPI (for screen display) - MATCHES PreviewScreen
  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  static const double pdfPortraitWidth = 595.0;
  static const double pdfPortraitHeight = 842.0;
  static const double pdfLandscapeWidth = 842.0;
  static const double pdfLandscapeHeight = 595.0;

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — one header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. Both titles were hard-coded English literals.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).convertToPdf,
        onFirstTap: breadcrumbPop(context, 1),
        child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsetsDirectional.only(
            start: 15.w,
            end: ContextExtension(context).isPhone ? 15.w : 121.w,
          ),
          child: BlocBuilder<PdfCubit, PdfState>(
            builder: (context, state) {
              if (state is! PdfLoaded) {
                return const CircleProgressMaster();
              }

              final cubit = context.read<PdfCubit>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(30),

                  // ✅ Build all pages with proper A4 constraints
                  for (int pageIndex = 0;
                  pageIndex < widget.formModel.pages.length;
                  pageIndex++) ...[
                    if (widget.formModel.pages.length != 1) ...[
                      verticalSpace(20),
                      Text(
                        // CHANGED: was `'${'Page'} ${pageIndex + 1}'` — a
                        // string literal interpolated into a string, which
                        // reads like a translation call but is just the
                        // English word. `page` already existed in both .arb
                        // files ("Page" / "صفحة").
                        '${S.of(context).page} ${pageIndex + 1}',
                        style: StyleText.fontSize14Weight500,
                      ),
                      verticalSpace(10)
                    ],
                    if (state.isExpanded[pageIndex])
                      _buildA4Page(pageIndex, cubit),
                  ],

                  verticalSpace(20),
                  _buildDownloadButton(context, cubit),
                  verticalSpace(90),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  /// ✅ Builds a single A4 page that shows ALL content with proper A4 width
  Widget _buildA4Page(int pageIndex, PdfCubit cubit) {
    final orientation =
        widget.formModel.formHeadModel.orientation?.toLowerCase() ?? 'portrait';
    final isLandscape = orientation.contains('landscape');

    final horizontalPadding =
        widget.formModel.formHeadModel.horizontalPadding ?? 16.0;
    final verticalPadding =
        widget.formModel.formHeadModel.verticalPadding ?? 16.0;

    final a4Width = isLandscape ? a4LandscapeWidth : a4PortraitWidth;
    final a4Height = isLandscape ? a4LandscapeHeight : a4PortraitHeight;

    return RepaintBoundary(
      key: cubit.widgetKeys[pageIndex],
      child: SizedBox(
        width: a4Width, // ✅ Fixed width for A4 (794px portrait / 1123px landscape)
        child: Container(
          constraints: BoxConstraints(
            minHeight: a4Height, // ✅ Minimum height, but can grow to fit content
          ),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Stack(
            children: [
              // Watermark
              if (widget.formModel.formHeadModel.watermark != null)
                Positioned.fill(
                  child: _buildWatermark(),
                ),

              // ✅ Content without height restriction
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: _buildPageContent(pageIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Builds watermark layer
  Widget _buildWatermark() {
    return PdfWaterMarkImagePage(
      model: widget.formModel,
      page: const SizedBox.shrink(), // Empty page, just watermark
    );
  }

  /// ✅ Builds page content (all rows and fields) - CENTERED
  Widget _buildPageContent(int pageIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int rowIndex = 0;
        rowIndex < widget.formModel.pages[pageIndex].rows.length;
        rowIndex++) ...[
          _buildRow(pageIndex, rowIndex),
          if (rowIndex < widget.formModel.pages[pageIndex].rows.length - 1)
            verticalSpace(15),
        ],
      ],
    );
  }

  /// ✅ Builds a single row with its fields
  Widget _buildRow(int pageIndex, int rowIndex) {
    final fields = widget.formModel.pages[pageIndex].rows[rowIndex].fields;
    final hasMultipleColumns = fields.length > 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) ...[
          if (fieldIndex > 0) horizontalSpace(15),
          Expanded(
            child: _buildWidget(
              fields[fieldIndex],
              hasMultipleColumns,
            ),
          ),
        ],
      ],
    );
  }

  /// ✅ Builds download button
  ///
  /// Takes [context] rather than reading `this.context` so the label resolves
  /// against the same Localizations scope as the rest of the page.
  Widget _buildDownloadButton(BuildContext context, PdfCubit cubit) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: customButtonWithSvg(
        // CHANGED: was the literal 'Download AS PDF'. New key, matching the
        // `downloadAsExcel` already in the .arb files.
        title: S.of(context).downloadAsPdf,
        function: () => cubit.onDownloadClicked(
          widget.formModel,
          context,
        ),
        textStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.black),
        color: AppColors.primary,
        image: AppAssets.downloadPdf,
        widthImage: 20,
        heightImage: 20,
        colorBorder: AppColors.transparent,
      ),
    );
  }

  // ✅ FIXED - Line 336 - Added Terms and Conditions case
  /// ✅ Builds individual field widget based on type
  Widget _buildWidget(FieldModel field, bool isExpand) {
    final widgetMap = {
      FormFieldType.dropDown: () => DropDownPdfPreviewWidget(
        model: field as DropDownFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.image: () => ImagePdfPreviewWidget(
        model: field as ImageFieldModel,
      ),
      FormFieldType.textField: () => TextFieldPdfResultWidget(
        model: field as TextFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.email: () => EmailPdfResultWidget(
        model: field as EmailFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.phone: () => PhonePdfResultWidget(
        model: field as PhoneFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.location: () => LocationPdfResultWidget(
        model: field as LocationFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.radio: () => RadioPdfResultWidget(
        model: field as RadioFieldModel,
      ),
      FormFieldType.checkBox: () => CheckBoxPdfPreviewWidget(
        model: field as CheckBoxFieldModel,
      ),
      // ✅ CRITICAL FIX - Added Terms and Conditions case for PDF generation
      FormFieldType.termsAndCondition: () => TermsAndConditionsPdfPreviewWidget(
        model: field as TermsAndConditionsFieldModel,
      ),
      FormFieldType.description: () => DescriptionPdfResultWidget(
        model: field as DescriptionFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.attachment: () => AttachmentPdfPreviewWidget(
        model: field as AttachmentFieldModel,
      ),
      FormFieldType.link: () => LinkPdfResultWidget(
        model: field as LinkFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.digitalSignature: () =>
          AttachmentDigitalSignaturePdfResultWidget(
            model: field as AttachmentDigitalSignatureFieldModel,
          ),
      FormFieldType.dateSelector: () => DatePdfPreviewPdfWidget(
        model: field as DateFieldModel,
        isExpand: isExpand,
      ),
      FormFieldType.address: () => AddressPdfPreviewWidget(
        model: field as AddressFieldModel,
      ),
      FormFieldType.timeSelector: () => TimeSelectorPdfPreviewWidget(
        model: field as TimeSelectorFieldModel,
      ),
      FormFieldType.title: () => TitlePdfResultWidget(
        model: field as TitleFieldModel,
      ),
      FormFieldType.radioTextField: () => RadioTextFieldPdfResultWidget(
        model: field as RadioTextFieldModel,
      ),
    };

    return widgetMap[field.type]!();
  }
}