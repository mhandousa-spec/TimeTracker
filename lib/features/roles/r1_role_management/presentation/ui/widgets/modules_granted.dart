/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: modules_granted.dart
/// Purpose: Declares `ModulesGranted`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class ModulesGranted extends StatefulWidget {
  const ModulesGranted({super.key});

  @override
  State<ModulesGranted> createState() => _ModulesGrantedState();
}

class _ModulesGrantedState extends State<ModulesGranted> {
  bool isHide = false;
  late RoleCubit controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // Get modules directly from selected role
    List<String> moduleStrings = controller.selectedRole?.currentSelectedModules ?? [];


    // Convert to enums. The name -> enum map (and the rule that unknown names
    // are skipped) lives on RoleCubit; this widget used to keep a private copy
    // of the switch plus a try/catch, which §11.2 forbids in widgets.
    final List<Modules> moduleEnums = controller.moduleEnumsFor(moduleStrings);


    return Column(
      spacing: 8.sp,
      children: [
        Row(
          children: [
            Text(
              S.of(context).modules,
              style: StyleText.fontSize16Weight600,
            ),
            Spacer(),
            InkWell(
              splashColor: AppColors.transparent,
              hoverColor: AppColors.transparent,
              onTap: () {
                setState(() {
                  isHide = !isHide;
                });
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).expand : S.of(context).hide,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      height: 1,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        if (!isHide)
          Container(
            // Role QA p.26: less padding around the module grid (was 15).
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: moduleEnums.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Text(
                  S.of(context).noModulesGranted,
                  style: StyleText.fontSize14Weight400,
                ),
              ),
            )
                : GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: moduleEnums.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 14 : 4,
                mainAxisSpacing: 10.sp,
                crossAxisSpacing: 10.sp,
                // FIXED 29/8/2026: a fixed `mainAxisExtent: 55.w` made each
                // grid tile a wide rectangle, and the icon box (forced to fill
                // the tile) stretched with it. A square childAspectRatio keeps
                // every cell — and the tile centred in it — square.
                // Role QA p.26: each tile now carries the module name under
                // the icon, so the cell is taller than it is wide.
                childAspectRatio: isTablet ? 0.8 : 0.72,
              ),
              itemBuilder: (_, index) {
                return _moduleItem(moduleEnums[index]);
              },
            ),
          )
      ],
    );
  }

  Widget _moduleItem(Modules module) {
    // FIXED 29/8/2026: fixed 44.sp SQUARE tile with the full AppColors.primary
    // fill and the AppColors.textButton glyph the design asks for.
    // Role QA p.26 (30/9/2026): the module name is shown under the tile.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.sp,
          height: 44.sp,
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: CustomSvgImage(assetPath:
            module.iconPath,
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              AppColors.textButton,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 4.sp),
        Flexible(
          child: Text(
            module.getModuleName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: StyleText.fontSize11Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  // REMOVED 12/8/2026: private `_stringToModuleEnum` switch — a drifted
  // duplicate of RoleCubit.stringToModuleEnum (it listed 'employees' twice and
  // was missing hr / crm / notification). Use the cubit's map instead.

}