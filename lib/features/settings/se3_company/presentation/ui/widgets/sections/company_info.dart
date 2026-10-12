/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_info.dart
/// Purpose: The company-information section — the fields plus the update
///          button — rendered inside the settings pane.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N04/N17/N25: renamed from the misspelled
///          `comapny_info.dart`; the four commented-out debug prints and the
///          REMOVED_MODULE import comments deleted; standard header added.
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
// REMOVED: import '../../../../settings_screen/views/owner_screens/company_info_update_dialog/update_company_info_dialog.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/fields/company_information_fields.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class CompanyScreenInfo extends StatefulWidget {
  const CompanyScreenInfo({super.key});

  @override
  State<CompanyScreenInfo> createState() =>
      _CompanyScreenInfoState();
}

class _CompanyScreenInfoState extends State<CompanyScreenInfo> {
  CompanyCubit get companyController => context.read<CompanyCubit>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  // ✅ NEW METHOD: Load company data on screen init
  Future<void> _loadCompanyData() async {

    if (companyController.state.company == null) {
      await companyController.getCompany(shouldRestart: false);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // ✅ Show loading indicator while data is loading
    if (_isLoading) {
      return const CircleProgressMaster();
    }

    // ✅ Show error message if company data failed to load
    if (context.watch<CompanyCubit>().state.company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.signOut,
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).error,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadCompanyData();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return !isMobile ? Column(
      children: [
        // isMobile ? SizedBox(height: 35.h) : SizedBox() ,
        Container(
          height: isMobile ? null: 490.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding:
            EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
            child: Column(
              children: [

                const CompanyInformationFields(),
              ],
            ),
          ),
        ),


        // SizedBox(height: 15.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     customButton(
        //       title: S.of(context).update,
        //       function: () async {
        //
        //         hapticController.triggerHapticFeedback(
        //             vibration: VibrateType.mediumImpact,
        //             hapticFeedback: HapticFeedback.mediumImpact
        //         );
        //
        //         // ✅ Add your update logic here
        //         // For example:
        //         // await companyController.updateCompanyInfo();
        //
        //       },
        //       radius: 4.r,
        //       color: AppColors.primary,
        //       width: 300.w,
        //       height: 36,
        //       textStyle: StyleText.fontSize16Weight500.copyWith(
        //           color: AppColors.textButton
        //       ),
        //     ),
        //   ],
        // ),
      ],
    ) : SideFrameMasterServices(
      titleText: S.of(context).settings,
      secondTitle: S.of(context).company,
      onSecondTap: (){
        Navigator.pop(context);
      },
      onFirstTap: (){
        Navigator.pop(context);
      },
      child: Column(
        children: [
          // isMobile ? SizedBox(height: 35.h) : SizedBox() ,
          // CHANGED 8/9/2026 — no card decoration on this branch.
          //
          // This is the PHONE branch, and CompanyInformationFields now paints a
          // separate card per section (Company / Service / Contact). This
          // wrapper was painting one card around all three, so the section
          // cards would have sat on top of an outer card and the gaps between
          // them would have been filled in — the "everything in one container"
          // look, just with extra lines drawn inside it.
          //
          // CHANGED 8/9/2026 — the HORIZONTAL padding is gone on this branch.
          //
          // It stacked on the 15.sp each section card applies inside itself
          // (`_sectionCard` in company_information_fields.dart), so every label
          // and field sat 30.sp from the page edge while the back chevron in
          // the frame header sat at 15.sp — the whole page read as indented.
          // se1_profile, which this layout follows, has no page padding on
          // phone either: PersonalInformationFields goes straight into
          // SideFrameMasterServices and each section card supplies the inset.
          // `top` stays — that is the gap under the header, not a page inset.
          //
          // The tablet branch above is untouched: it keeps its card, its
          // horizontal padding and the one-slab layout it was designed around.
          Container(
            height: isMobile ? null: 490.h,
            child: Padding(
              padding: EdgeInsets.only(top: 15.sp),
              child: Column(
                children: [

                  const CompanyInformationFields(),
                ],
              ),
            ),
          ),


          // SizedBox(height: 15.h),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     customButton(
          //       title: S.of(context).update,
          //       function: () async {
          //
          //         hapticController.triggerHapticFeedback(
          //             vibration: VibrateType.mediumImpact,
          //             hapticFeedback: HapticFeedback.mediumImpact
          //         );
          //
          //         // ✅ Add your update logic here
          //
          //       },
          //       radius: 4.r,
          //       color: AppColors.primary,
          //       width: isMobile ? 340.w : 300.w,
          //       height: 36,
          //       textStyle: StyleText.fontSize16Weight500.copyWith(
          //           color: AppColors.textButton
          //       ),
          //     ),
          //
          //   ],
          // ),

          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}