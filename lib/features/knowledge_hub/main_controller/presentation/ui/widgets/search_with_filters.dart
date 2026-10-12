/// ************************* FILE INFO *************************** ///
/// File Name: search_with_filters.dart
/// Purpose: Contains the bar of search and filtering in home page.
/// Author: Youssef Khaled
/// Created At: 3/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/services/knowledge_hub_firebase_services.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../k1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import './filter_search_dialog.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

// ========== ANIMATED BUTTON STATE ==========
class _AnimatedButtonState extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButtonState({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedButtonState> createState() => __AnimatedButtonStateState();
}

class __AnimatedButtonStateState extends State<_AnimatedButtonState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    widget.onTap();
    // Reset animation after navigation for when user comes back
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// ========== SEARCH WITH FILTERS WIDGET ==========
Widget searchWithFilters(
    BuildContext context, {
      required TextEditingController searchController,
      required Function(String) onSearchChanged,
      required List<DepartmentModelPro> departments,
    }) {
  final bool isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final controller = Get.find<MainCoreEmployeeController>();

  // Whether any filter from the FilterSearchDialog is currently applied
  // (document type / status / department / publish date). When active, the
  // filter button is highlighted: primary background with textButton-colored
  // icon and label.
  // This widget is rebuilt by the outer BlocBuilder<CreateKnowledgeCubit> in
  // view_knowledge_hub, so applyFilters()/resetFilters() emits refresh it.
  final knowledgeCubit = context.read<CreateKnowledgeCubit>();
  final String? _dept = knowledgeCubit.selectedOwningDepartment;
  final bool isFilterActive =
      (knowledgeCubit.selectedDocumentType?.isNotEmpty ?? false) ||
          (knowledgeCubit.selectedOwningStatus?.isNotEmpty ?? false) ||
          // ADDED 28/8/2026 — a publish-date range on its own is a real filter
          // and has to light the button too, otherwise a user who narrowed the
          // list by date alone sees a plain button and no clue why documents
          // are missing.
          knowledgeCubit.selectedPublishFromDate != null ||
          knowledgeCubit.selectedPublishToDate != null ||
          (_dept != null &&
              _dept.isNotEmpty &&
              _dept != 'All' &&
              _dept != 'الكل');

  final Color filterBg = isFilterActive ? AppColors.primary : AppColors.card;
  final Color filterFg =
      isFilterActive ? AppColors.textButton : AppColors.secondaryText;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // ✅ Filter Button with animation
      _AnimatedButtonState(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => Center(
              child: BlocProvider.value(
                value: context.read<CreateKnowledgeCubit>(),
                child: FilterSearchDialog(
                  departments: departments,
                  isAdmin: true,
                ),
              ),
            ),
          );
        },
        child: Container(
          height: 38.h,
          width: isMobile ? 38 : 100.w, // ✅ Wider for desktop/tablet
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: filterBg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Filter Icon
              Center(
                child: CustomSvgImage(
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
                  height: 20.h,
                  color: filterFg,
                  width: 20.w,
                  fit: BoxFit.fill,
                ),
              ),
              // ✅ Show "Filter" text only on desktop/tablet
              if (!isMobile) ...[
                SizedBox(width: 8.w),
                Text(
                  S.of(context).filter ?? 'Filter',
                  style: StyleText.fontSize16Weight500.copyWith(
                color: filterFg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Spacing before Create button
      if (controller.isHasPermission(
        module: Modules.knowledgeHub,
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: KnowledgeHubPermissions.createKnowledgeHub,
      ))
        SizedBox(width: 10.w),

      // Create Knowledge Button with animation
      if (controller.isHasPermission(
        module: Modules.knowledgeHub,
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: KnowledgeHubPermissions.createKnowledgeHub,
      ))
        _AnimatedButtonState(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) =>
                      CreateKnowledgeCubit(KnowledgeHubFirebaseServices()),
                  child: CreatingKnowledgeHub(),
                ),
              ),
            );
          },
          child: Container(
            height: 38.h,
            width: isMobile ? 38.w : 220.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CustomSvgImage(
                    assetPath: 'assets/icons_assets/knowledge_hub_assets/create_knowledge_icon.svg',
                    height: 20.h,
                    width: 20.w,
                    fit: BoxFit.cover,
                    color: AppColors.textButton,
                  ),
                ),
                if (!isMobile)
                  Row(
                    children: [
                      SizedBox(width: 5.w),
                      Text(
                        S.of(context).create_new_knowledge,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        )
    ],
  );
}