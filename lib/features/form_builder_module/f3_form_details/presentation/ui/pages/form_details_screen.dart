import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/orientation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/share_screen.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/helper/form_builder/submitted_page_viewer.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f3_form_details/presentation/ui/widgets/form_details_actions.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';

class FormDetailsScreen extends StatefulWidget {
  const FormDetailsScreen({super.key, required this.model});
  final FormEntity model;

  @override
  State<FormDetailsScreen> createState() => _FormDetailsScreenState();
}

class _FormDetailsScreenState extends State<FormDetailsScreen>
    with SingleTickerProviderStateMixin {
  // ✅ Local PdfCubit instance for this screen
  late final PdfCubit _localPdfCubit;

  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  @override
  void initState() {
    super.initState();

    // ✅ Create and initialize local PdfCubit
    _localPdfCubit = PdfCubit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        
        _localPdfCubit.initialize(widget.model.pages.length);
      }
    });
  }

  @override
  void dispose() {
    // ✅ Clean up local cubit
    
    _localPdfCubit.close();
    super.dispose();
  }

  // ✅ Calculate A4 width based on orientation
  double _getA4Width() {
    final orientation = widget.model.formHeadModel.orientation?.toLowerCase() ?? 'portrait';
    final isLandscape = orientation.contains('landscape');
    return isLandscape ? a4LandscapeWidth : a4PortraitWidth;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Provide local PdfCubit to this screen's widget tree
    return BlocProvider<PdfCubit>.value(
      value: _localPdfCubit,
      // CHANGED 19/8/2026 — one header for both form factors, drawn by
      // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
      // pair.
      child: Scaffold(
        body: SideFrameMasterServices(
          titlePadding: formBuilderTitlePadding,
          titleText: S.of(context).services_app,
          secondTitle: S.of(context)
              .detailsOfTitle(_getTitle(widget.model.formHeadModel, context)),
          onFirstTap: breadcrumbPop(context, 1),
          child: _buildScrollableContent(context),
        ),
      ),
    );
  }

  /// The frame scrolls the content itself on mobile; on tablet it hands the
  /// child a bounded height, so the scroll view stays here.
  Widget _buildScrollableContent(BuildContext context) {
    final Widget content = Padding(
          padding: EdgeInsetsDirectional.only(
            start: 15.w,
            end: 15.w,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(15),
                FormDetailsActions(model: widget.model, vsync: this),
                verticalSpace(15),
                Container(
                  padding: EdgeInsets.only(
                      top: 15.h, bottom: 15.h, right: 15.w, left: 15.w),
                  decoration: ShapeDecoration(
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.background,
                            radius: 32.5,
                            backgroundImage: widget.model.formHeadModel.cover != null &&
                                widget.model.formHeadModel.cover!.isNotEmpty
                                ? NetworkImage(widget.model.formHeadModel.cover!)
                                : null,
                            child: widget.model.formHeadModel.cover != null &&
                                widget.model.formHeadModel.cover!.isNotEmpty
                                ? null
                                : Transform.scale(
                              scale: ContextExtension(context).isTablett ? 1.5 : ContextExtension(context).isTablett ? 1.2 : 1,
                              child: SvgPicture.asset(
                                "assets/icons_assets/roles_assets/form_document.svg",
                                colorFilter: ColorFilter.mode(
                                  AppColors.text,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpace(10),
                          Text(
                            _getTitle(widget.model.formHeadModel, context),
                            style: StyleText.fontSize23Weight400.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(15),
                      _getDescriptionWidget(
                          widget.model.formHeadModel, context),
                      verticalSpace(15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropDown(context),
                          verticalSpace(5.h),
                          buildPadding(context),
                        ],
                      ),
                    ],
                  ),
                ),
                verticalSpace(15),
                // ✅ FIXED: Added A4 width to SubmittedPageViewer
                Align(
                  alignment: Alignment.center,
                  child: SubmittedPageViewer(
                    model: widget.model,
                    isReadOnly: true,
                    isSubmitted: false,
                    pages: List.generate(
                      widget.model.pages.length,
                          (index) => widget.model.pages[index].toController(),
                    ),
                    // ✅ CRITICAL: Pass A4 width based on orientation
                    width: _getA4Width(),
                  ),
                ),
              ],
            ),
        );

    return ContextExtension(context).isTablett
        ? SingleChildScrollView(child: content)
        : content;
  }

  Widget buildPadding(BuildContext context) {
    return ContextExtension(context).isTablett
        ? Row(
      children: [
        Expanded(
          child: _buildHorizontalPadding(),
        ),
        horizontalSpace(15),
        Expanded(
          child: _buildVerticalPadding(),
        ),
      ],
    )
        : Column(
      children: [
        _buildHorizontalPadding(),
        verticalSpace(15),
        _buildVerticalPadding()
      ],
    );
  }

  CustomTextField _buildVerticalPadding() {
    return CustomTextField(
        height: 36,
        label: S.of(context).verticalPadding,
        hint: FormDateTimeHelper.formatInt(
          widget.model.formHeadModel.verticalPadding?.toInt() ?? 0),
        readOnly: true,
      );
  }

  CustomTextField _buildHorizontalPadding() {
    return CustomTextField(
        height: 36,
        label: S.of(context).horizontalPadding,
        hint: FormDateTimeHelper.formatInt(
          widget.model.formHeadModel.horizontalPadding?.toInt() ?? 0),
        readOnly: true,
      );
  }

  Widget _buildDropDown(BuildContext context) {
    return ContextExtension(context).isTablett
        ? Row(
      children: [
        Expanded(
          child: _buildAccessManagement(),
        ),
        horizontalSpace(15),
        Expanded(
          child: _buildOrientation(),
        ),
      ],
    )
        : Column(
      children: [
        _buildAccessManagement(),
        verticalSpace(10),
        _buildOrientation(),
      ],
    );
  }

  CustomTextField _buildOrientation() {
    // FIXED 19/8/2026 — the old body branched on 'Portrait' / 'Landscape' and
    // then assigned the SAME English word back, so `translatedOrientation` was
    // never translated at all. `labelFor` does the real lookup.
    final translatedOrientation = OrientationExtension.labelFor(
      widget.model.formHeadModel.orientation,
    );

    return CustomTextField(
        height: 36,
        hint: translatedOrientation,
        label: S.of(context).orientation,
        readOnly: true,
      );
  }

  CustomTextField _buildAccessManagement() {
    // FIXED 19/8/2026 — same no-op as _buildOrientation: every branch handed
    // back the English string it had just matched on.
    final translatedAccess = AccessManagementExtension.labelFor(
      widget.model.formHeadModel.accessManagement,
    );

    return CustomTextField(
        height: 36,
        hint: translatedAccess,
        label: S.of(context).accessManagement,
        readOnly: true,
      );
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }

    return formHeadModel.title ?? '';
  }

  Widget _getDescriptionWidget(
      FormHeadData formHeadModel, BuildContext context) {
    // The LABEL follows the app locale either way; only the CONTENT depends on
    // whether an Arabic description was authored. It used to hard-code 'الوصف'
    // here and 'Description' below, so an English UI with an Arabic description
    // showed an Arabic label.
    if (context.isArabic && formHeadModel.arDescription != null) {
      return CustomTextField(
        minLines: 4,
        maxLines: 10,
        readOnly: true,
        label: S.of(context).description,
        hint: _getDescriptionTextForArabic(formHeadModel),
      );
    }
    return CustomTextField(
        minLines: 4,
        maxLines: 10,
        readOnly: true,
        label: S.of(context).description,
        hint: widget.model.formHeadModel.description,
      );
  }

  String _getDescriptionTextForArabic(FormHeadData formHeadModel) {
    if (formHeadModel.arDescription != null &&
        formHeadModel.arDescription!.isNotEmpty) {
      return formHeadModel.arDescription!;
    }
    return formHeadModel.description ?? '';
  }
}