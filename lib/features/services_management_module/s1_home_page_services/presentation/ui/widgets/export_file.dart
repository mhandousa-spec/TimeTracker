// ******************* FILE INFO *******************
// File Name: export_file
// Description: Export file.
// Module: services_management_module / presentation/s1_home_page_services/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/services_csv_exporter.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/widgets/home_services_dialog.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ExportDialog extends StatefulWidget {
  final List<dynamic> filteredModel;
  final Map selectedProviders;
  final String Function(dynamic date) formatStartDate;

  const ExportDialog({
    Key? key,
    required this.filteredModel,
    required this.selectedProviders,
    required this.formatStartDate,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final TextEditingController controller = TextEditingController();
  final ServicesCsvExporter _exporter = const ServicesCsvExporter();
  OverlayEntry? _overlayEntry;
  bool _isExporting = false;

  Future<void> _showLoadingIndicator(BuildContext context) async {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: true,
            color: AppColors.black.withOpacity(0.3),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.87),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  CircularProgressIndicator(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// The download button is only live once there is a file name to save to.
  bool get _canExport => !_isExporting && controller.text.trim().isNotEmpty;

  Future<void> _exportToCSVSimple(BuildContext context) async {
    if (_isExporting) return;

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      Get.snackbar(
        'Error',
        S.of(context).pleaseEnterFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    if (widget.filteredModel.isEmpty) {
      Get.snackbar(
        'No Data',
        'No services to export',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });
    // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
    // box stayed on screen behind the phone's Save sheet for as long as the
    // sheet was open. The save sheet (and the Export button's own busy state)
    // is the feedback now, so no overlay is shown.

    // The exporter returns Either and never throws, so the loading overlay and
    // the button state are always reset and a failure is always reported.
    final result = await _exporter.export(
      items: widget.filteredModel,
      selectedProviders: widget.selectedProviders,
      fileName: fileName,
    );
    _hideLoadingIndicator();
    if (mounted) {
      setState(() {
        _isExporting = false;
      });
    }
    if (!mounted) return;

    final String? error = result.fold((l) => l, (_) => null);
    if (error != null) {
      Get.snackbar(
        S.of(context).error,
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }
    // Save sheet dismissed on a phone — nothing written, nothing to report.
    if (result.getOrElse(() => '') == CSVHelper.exportCancelled) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await showSuccessDialogMaster(
      lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_approved.json",
      title: S.of(context).exported,
      subtitle: S.of(context).fileSavedSuccessfully,
      context: context,
    );
  }

  @override
  void dispose() {
    _hideLoadingIndicator();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(8.r),
          ),
          constraints: BoxConstraints(
            maxWidth: 411.sp,
            minWidth: isMobile ? 280.sp : 350.sp,
          ),
          child: Padding(
            // CHANGED 9/9/2026: 20 -> 12 on every side.
            padding: EdgeInsets.all(12.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30.sp,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons_assets/main_icons_assets/export_arrow.svg",
                          width: 16.sp,
                          height: 16.sp,
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
                CustomTextField(
                  controller: controller,
                  height: 36,
                  label: S.of(context).fileName,
                  hint: S.of(context).Texthere,
                  restrictByDirection: true,
                  autoCapitalize: true,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      width: isMobile ? 120.w : 135.w,
                      title: S.of(context).discard,
                      color: AppColors.secondaryAction,
                      height: 38.sp,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      radius: 8.r,
                      function: () {
                        if (!_isExporting) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(width: 15.sp),
                    customButton(
                      width: isMobile ? 120.w : 135.w,
                      title: _isExporting ? "${S.of(context).export}..." : S.of(context).download,
                      // Was always enabled: pressing it with an empty name ran
                      // the export, failed the check inside, and surfaced an
                      // error toast. Disable it up front instead — the field
                      // already calls setState on every keystroke.
                      // CHANGED 9/9/2026 — the disabled pair was `grey` fill
                      // with `mediumGrey` text, two greys close enough that the
                      // word "Download" all but vanished until a file name was
                      // typed. Disabled is now `darkGrey` behind `white`, which
                      // reads at a glance while still saying "not yet".
                      //
                      // The ENABLED pair is untouched: `textButton` resolves to
                      // the on-primary colour, and white on the yellow primary
                      // would be the unreadable case in the other direction.
                      color:
                          _canExport ? AppColors.primary : AppColors.darkGrey,
                      height: 38.sp,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: _canExport
                            ? AppColors.textButton
                            : AppColors.white,
                      ),
                      radius: 8.r,
                      function: () {
                        if (_canExport) {
                          _exportToCSVSimple(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
