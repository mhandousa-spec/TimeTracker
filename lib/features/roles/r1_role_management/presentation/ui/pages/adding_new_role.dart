/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: adding_new_role.dart
/// Purpose: Declares `AddingNewRole`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// FRAME 8/9/2026: `pagination_app_bar.dart` replaced by the shared side frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/role_image_editor.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/dialog.dart';
import './role_permission_switches.dart';
import 'package:flutter/services.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

part '../widgets/adding_new_role_methods1.dart';

class AddingNewRole extends StatefulWidget {
  AddingNewRole({super.key});

  @override
  State<AddingNewRole> createState() => _AddingNewRoleState();
}

class _AddingNewRoleState extends State<AddingNewRole> {
  late RoleCubit controller;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final controller = context.read<RoleCubit>();

      if (!controller.isEditing && controller.selectedRole == null) {
        controller.initAddingRoleController();
      }
    });
    RoleLogService.log(RoleLogService.pageAddNewRole);
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();







  final HapticController hapticController = AppControllers.haptic;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isArabic = context.isArabic;
    controller = context.read<RoleCubit>();
    var isMobile = ContextExtension(context).isPhone;
    // A draft role opens straight into this screen (see role_overview.dart's
    // onTap), so this is where its Delete action belongs. Creating a brand-new
    // role (selectedRole == null) or editing an existing non-draft role shows
    // no Delete button.
    final bool isDraft =
        controller.selectedRole?.currentStatus == RoleStatus.draft;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: formKey,
          // FRAME 8/9/2026: header and horizontal padding come from
          // SideFrameMasterServices now, replacing PaginationAppBar and this
          // page's own Padding. SideFrameBoundedBody bounds the `Expanded`
          // below on the frame's phone (scrolling) branch.
          child: SideFrameMasterServices(
            titleText: S.of(context).platformControlsAndManagement,
            onFirstTap: () =>
                popFrameRoutes(context, controller.isEditing ? 2 : 1),
            secondTitle: controller.isEditing
                ? S.of(context).roleDetails
                : S.of(context).addingNewRole,
            onSecondTap: controller.isEditing
                ? () => popFrameRoutes(context, 1)
                : null,
            thirdTitle:
                controller.isEditing ? S.of(context).editingRole : null,
            child: SideFrameBoundedBody(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── DELETE (draft only) ────────────────────────────────
                // A draft role opens straight into this screen (see
                // role_overview.dart), so its Delete action sits top-right
                // under the breadcrumb — the same place RoleDetailsPage puts
                // edit/delete — rather than in the bottom bar. Confirm →
                // delete → success → home, all in the shared RoleDialogs flow.
                // isDraft and isEditing are mutually exclusive, so this and the
                // status switch below never show together.
                if (isDraft) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomDeleteIcon(
                        title: S.of(context).delete,
                        color: AppColors.red,
                        onTap: () => RoleDialogs.showDeleteRoleDialog(
                          context: context,
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                ],

                // ── STATUS SWITCH ──────────────────────────────────────
                // Edit mode only: a role that doesn't exist yet has no
                // status to toggle, so it stays hidden while creating.
                // Lives outside the form container, under the app bar.
                if (controller.isEditing) ...[
                  BlocBuilder<RoleCubit, RoleState>(
                    buildWhen: (_, state) =>
                        state is RoleModuleSelected || state is RoleSelected,
                    builder: (context, state) {
                      // ADDED 29/8/2026: the row was a label and a switch, so
                      // the role's state had to be read off the toggle's
                      // position. It now names the state in words —
                      // Active/Inactive, نشط/غير نشط — through
                      // RoleStatus.getLocalizedName, the same table the role
                      // list and the details screen use.
                      final RoleStatus shownStatus = controller.isActive
                          ? RoleStatus.active
                          : RoleStatus.inactive;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Role QA p.30: icon in front of the Status label.
                          CustomSvgImage(
                            assetPath:
                                'assets/icons_assets/main_icons_assets/status_pulse_line.svg',
                            width: 16.sp,
                            height: 16.sp,
                            fit: BoxFit.scaleDown,
                            color: AppColors.text,
                          ),
                          SizedBox(width: 6.sp),
                          Text(
                            S.of(context).status,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(width: 10.sp),
                          Transform(
                            alignment: Alignment.center,
                            transform: isArabic
                                ? Matrix4.rotationY(3.14159)
                                : Matrix4.identity(),
                            child: FlutterSwitch(
                              width: 38.sp,
                              height: 22.sp,
                              padding: 3.sp,
                              borderRadius: 20.sp,
                              toggleSize: 16.sp,
                              activeColor: AppColors.secondaryPrimary,
                              inactiveColor: AppColors.grey.withOpacity(.16),
                              // ✅ reads from cubit
                              value: controller.isActive,
                              onToggle: (newValue) async {
                                // Confirm → apply → success, all handled
                                // by the shared CustomDialogManager flow.
                                await _showStatusConfirmDialog(
                                    context, newValue);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10.sp),
                ],

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoleImageEditor(),
                          // SPACING 8/9/2026: every gap inside the form card is
                          // 10.sp. They used to be 15.sp with one 0 in the
                          // middle (phones got no gap at all between the name
                          // and description blocks), so the fields sat at three
                          // different distances from each other.
                          SizedBox(height: 10.sp),

                          // ── NAME FIELDS ────────────────────────────────
                          if (isMobile)
                            Column(
                              children: isArabic
                                  ? [
                                _buildArabicNameField(),
                                SizedBox(height: 10.sp),
                                _buildEnglishNameField(),
                              ]
                                  : [
                                _buildEnglishNameField(),
                                SizedBox(height: 10.sp),
                                _buildArabicNameField(),
                              ],
                            )
                          else
                            Row(
                              children: isArabic
                                  ? [
                                Expanded(child: _buildArabicNameField()),
                                SizedBox(width: 20.sp),
                                Expanded(child: _buildEnglishNameField()),
                              ]
                                  : [
                                Expanded(child: _buildEnglishNameField()),
                                SizedBox(width: 20.sp),
                                Expanded(child: _buildArabicNameField()),
                              ],
                            ),


                          SizedBox(height: 10.sp),

                          // ── DESCRIPTION FIELDS ─────────────────────────
                          if (isArabic) ...[
                            _buildArabicDescriptionField(),
                            SizedBox(height: 10.sp),
                            _buildEnglishDescriptionField(),
                          ] else ...[
                            _buildEnglishDescriptionField(),
                            SizedBox(height: 10.sp),
                            _buildArabicDescriptionField(),
                          ],

                          SizedBox(height: 10.sp),

                          Text(
                            S.of(context).selectModules,
                            style: StyleText.fontSize16Weight400,
                          ),

                          SizedBox(height: 10.sp),

                          // ── MODULE GRID ────────────────────────────────
                          FutureBuilder<List<String>>(
                            future: _getAllowedModulesForRoleCreation(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircleProgressMaster(),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    "Error loading modules: ${snapshot.error}",
                                    style:  TextStyle(
                                        color: AppColors.red, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              List<String> allowedModuleNames =
                                  snapshot.data ?? [];

                              if (allowedModuleNames.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child:  Text(
                                    "No modules available. Please contact your administrator.",
                                    style: TextStyle(
                                        color: AppColors.orange, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              // Unknown-module skipping moved to RoleCubit —
                              // §11.2 forbids try/catch in pages.
                              final List<Modules> activeModules =
                                  controller.moduleEnumsFor(allowedModuleNames);

                              return BlocBuilder<RoleCubit, RoleState>(
                                buildWhen: (_, state) =>
                                state is RoleModuleSelected,
                                builder: (context, state) {
                                  return GridView.builder(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: activeModules.length,
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isTablet ? 14 : 4,
                                      mainAxisSpacing: 10.sp,
                                      crossAxisSpacing: 10.sp,
                                      // Fixed 48.sp square tile + 6.sp gap +
                                      // a label box that is always two lines
                                      // tall. Defined beside the cell itself
                                      // (adding_new_role_methods1.dart) so the
                                      // row height and what the row draws can
                                      // never disagree.
                                      mainAxisExtent: kModuleCellExtent,
                                    ),
                                    itemBuilder: (_, index) {
                                      return _moduleItem(
                                          activeModules[index], context);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

                BlocBuilder<RoleCubit, RoleState>(
                  // Module selection arrives as a cubit state; the four text
                  // fields notify through their own controllers, hence the
                  // ListenableBuilder nested below. Both feed the same gate.
                  buildWhen: (_, state) => state is RoleModuleSelected,
                  builder: (context, state) {
                    return ListenableBuilder(
                      listenable: Listenable.merge(<Listenable>[
                        controller.roleNameController,
                        controller.roleNameControllerAr,
                        controller.roleDescriptionController,
                        controller.roleDescriptionControllerAr,
                      ]),
                      builder: (BuildContext context, Widget? _) {
                        final bool canProceed = _canProceedToPermissions;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customButton(
                              width: isTablet ? 150 : 120,
                              function: () => Navigator.of(context).pop(),
                              title: S.of(context).discard,
                              color: AppColors.secondaryButton,
                              textStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.text),
                            ),
                            customButton(
                              width: isTablet ? 150 : 120,
                              // A no-op rather than a null callback:
                              // customButton takes a non-nullable VoidCallback.
                              // The colour is what tells the user it is off.
                              function: canProceed
                                  ? () => _onNextPressed(context)
                                  : () {},
                              title: S.of(context).next,
                              color: canProceed
                                  ? AppColors.primary
                                  : AppColors.darkGrey,
                              textStyle: canProceed
                                  ? null
                                  : StyleText.fontSize16Weight400.copyWith(color: AppColors.text.withOpacity(0.45))
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 20.sp),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }








}

// ════════════════════════════════════════════════════════════════
// DIALOG — matches StatusChangeDialog from services exactly
// ════════════════════════════════════════════════════════════════

