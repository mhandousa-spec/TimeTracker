// ******************* FILE INFO *******************
// File Name: select_services_provider.dart
// Description: Main provider selection page - combines all widgets
// Created by: Amr Mesbah
// Last Update: 6/2/2026
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/details_switch_screen_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/select_provider_action_buttons_row.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/edit_mode_banner.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/provider_grid.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/save_for_later_button.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/search_header.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/selected_provider_details.dart';

class SelectServicesProviderPage extends StatefulWidget {
  final ServicesHistoryModel? editingModel;
  final String? docId;
  final ServicesHistoryModel? editProvider;

  const SelectServicesProviderPage({
    super.key,
    this.editingModel,
    this.docId,
    this.editProvider,
  });

  @override
  State<SelectServicesProviderPage> createState() =>
      _SelectServicesProviderPageState();
}

class _SelectServicesProviderPageState
    extends State<SelectServicesProviderPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(from: SlideFrom.bottom, child: BlocProvider(
      create: (context) => ProviderSelectionCubit(
        employeeController: AppControllers.employee,
        departmentController: context.read<MainCoreDepartmentCubit>(),
        servicesManagerCubit: ServicesManagerCubit.get(context),
      )..initialize(
          editingModel: widget.editingModel,
          docId: widget.docId,
          editProvider: widget.editProvider,
        ),
      // ✅ FIXED: Added missing 'child:' parameter
      child: BlocConsumer<ProviderSelectionCubit, ProviderSelectionState>(
        listenWhen: (previous, current) {
          // ✅ FIX: Don't re-fire listener if we're restoring back to loaded
          // Only listen when transitioning TO a nav/action state
          if (current is ProviderSelectionLoaded && previous is ProviderSelectionLoaded) {
            return false; // Normal UI update, don't trigger listener
          }
          return current is ProviderSelectionNavigateBack ||
              current is ProviderSelectionNavigateToDetails ||
              current is ProviderSelectionProviderUpdated ||
              current is ProviderSelectionSaved ||
              current is ProviderSelectionSavedToFirebase ||
              current is ProviderSelectionShowWarning ||
              current is ProviderSelectionError;
        },
        listener: _handleStateChanges,
        builder: (context, state) {
          // Handle initial and loading states
          if (state is ProviderSelectionInitial ||
              state is ProviderSelectionLoading) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Handle saving state - show loading with text
          if (state is ProviderSelectionSaving) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(S.of(context).savingDraft),
                  ],
                ),
              ),
            );
          }

          // ✅ FIXED: This state is handled in listener, show loading while navigating
          // Don't show static screen - let listener handle navigation
          if (state is ProviderSelectionSavedToFirebase) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green, size: 64),
                    SizedBox(height: 16),
                    Text(S.of(context).draftSavedSuccessfully),
                    SizedBox(height: 16),
                    CircularProgressIndicator(), // Show navigating indicator
                    SizedBox(height: 8),
                    Text(S.of(context).redirecting),
                  ],
                ),
              ),
            );
          }

          // Handle error state
          if (state is ProviderSelectionError) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.red, size: 64),
                    SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    SizedBox(height: 16),
                    customButton(
                      title: 'Go Back',
                      function: () {
                        // Retry or go back
                        Navigator.pop(context);
                      },
                      width: 120.sp,
                      height: 40.sp,
                      color: AppColors.primary,
                      textColor: AppColors.textButton,
                    ),
                  ],
                ),
              ),
            );
          }

          // Only show main UI for loaded state
          if (state is! ProviderSelectionLoaded) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final cubit = context.read<ProviderSelectionCubit>();
          final data = state.data;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: S.of(context).service,
                onFirstTap: () => _navigateToHome(context),
                secondTitle: cubit.getScreenTitle(context),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Section Header
                      _buildSectionHeader(context),
                      SizedBox(height: 8.sp),

                      // Edit Mode Banner (only in edit mode)
                  //    if (data.isEditMode) const EditModeBanner(),

                      // Main Card with Provider Grid
                      _buildProviderCard(context),

                      SizedBox(height: 20.sp),

                      // Action Buttons (Back & Next/Save)
                      const ActionButtonsRow(),

                      SizedBox(height: 10.sp),

// ✅          Save For Later Button — hidden in editProvider mode
                      if (data.editProvider == null)
                        const SaveForLaterButton(),

                      SizedBox(height: 20.sp),

                      SizedBox(height: 20.sp),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ));
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(S.of(context).serviceProvider),
          style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildProviderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // Search Header
          SearchHeader(controller: _searchController),
          SizedBox(height: 15.sp),

          // Provider Grid
          const ProviderGrid(),
          SizedBox(height: 15.sp),

          // Selected Provider Details (appears when providers selected)
          const SelectedProviderDetails(),
        ],
      ),
    );
  }

  void _handleStateChanges(BuildContext context, ProviderSelectionState state) {
    if (state is ProviderSelectionShowWarning) {
      _showWarningDialog(context);
    } else if (state is ProviderSelectionNavigateBack) {
      // ✅ FIX: Check we're still mounted before popping
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else if (state is ProviderSelectionProviderUpdated) {
      // ✅ Await the dialog before navigating. It used to be fired and
      // immediately followed by navigateTo, so the page swapped out from under
      // the dialog and the success message was never really seen.
      // CustomDialogManager.showSuccess auto-closes after 1.5s and completes.
      _showSuccessChangeProviderDialog(context).then((_) {
        if (!mounted) return;
        navigateTo(context, LayoutScreenServices());
      });
    } else if (state is ProviderSelectionSaved) {
      // 🚫 SNACKBAR REMOVED — this raised "Draft saved successfully!", a
      // hardcoded English string that never went through S.of(context), on a
      // screen where every other message is a localized dialog. The save is
      // already confirmed by the Save For Later dialog the user just accepted,
      // so the state now needs no announcement of its own.
    } else if (state is ProviderSelectionSavedToFirebase) {
      // 🚫 SNACKBAR REMOVED — same as above ("Draft saved to Firebase!", which
      // also named our backend to the user). The navigation below is the
      // feedback: the screen closes back to the services list.
      Future.delayed(Duration(milliseconds: 500), () {
        navigateAndFinish(context, LayoutScreenServices());
      });
    } else if (state is ProviderSelectionNavigateToDetails) {
      _navigateToDetails(context, state);
    } else if (state is ProviderSelectionError) {
      // 🚫 SNACKBAR REMOVED — but not the message itself. Dropping a failure
      // silently would leave the user believing a save worked when it did not,
      // so this now uses CustomDialogManager.showMessage, which is documented
      // for exactly this and stays up until dismissed rather than timing out
      // after two seconds like the snackbar did.
      _showErrorDialog(context, state.message);
    }
  }

  // ✅ Both dialogs below now come from CustomDialogManager
  // (core/custom/57-custom_dialog_manager.dart).
  //
  // They used to be built inline here: a bare AlertDialog for the warning
  // (which sizes itself to its text, so it came out much narrower than
  // everything else) and a hand-rolled Dialog for the success message. Every
  // other dialog in the app is 500.sp wide with 24.r padding, so these two were
  // the odd ones out. Routing them through the manager means the width, the
  // padding, the corner radius, the dark-mode background and the lottie sizing
  // are all decided in one place.

  void _showWarningDialog(BuildContext context) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_attension.json',
      title: S.of(context).warning,
      subtitle: S.of(context).pleaseSelectOneProviderAtLeast,
    );
  }

  Future<void> _showSuccessChangeProviderDialog(BuildContext context) {
    return CustomDialogManager.showSuccess(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      title: S.of(context).changingServiceProvider,
      subtitle: S.of(context).successChangeServiceProvider,
    );
  }
  void _showErrorDialog(BuildContext context, String message) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      title: S.of(context).error,
      subtitle: message,
    );
  }

  void _navigateToHome(BuildContext context) {
    navigateTo(context, const LayoutScreenServices());
  }

  void _navigateToDetails(
      BuildContext context, ProviderSelectionNavigateToDetails state) {
    if (state.docId != null && widget.editingModel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailsToggleScreen(
            editingModel: state.completeModel,
            docId: state.docId,
          ),
          maintainState: true,
        ),
      );
    } else {
      navigateTo(
        context,
        DetailsToggleScreen(
          editingModel:
              widget.editingModel != null ? state.completeModel : null,
          docId: state.docId,
        ),
      );
    }
  }
}
