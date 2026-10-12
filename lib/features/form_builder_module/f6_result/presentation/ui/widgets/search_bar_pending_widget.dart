import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// CHANGED: was `45-custom_app_dropdown.dart` (`AppDropdown`, built on the
// `dropdown_button2` package). The department filter now renders through the
// app's own CustomDropdown, so it matches the AppSearchTextField beside it
// instead of coming from a second dropdown implementation.
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
class SearchBarPendingWidget extends StatelessWidget {
  const SearchBarPendingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            _buildSearchBar(context, widthScreen, cubit, state),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              _buildDropDown(context, cubit, state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(
      BuildContext context,
      double widthScreen,
      ResultCubit cubit,
      ResultLoaded state,
      ) {
    return AppSearchTextField(
      controller: state.searchController,
      onChanged: (value) {
        cubit.search();
      },
    );
  }

  Widget _buildDropDown(
    BuildContext context,
    ResultCubit cubit,
    ResultLoaded state,
  ) {
    // CHANGED: was `Get.locale?.languageCode == 'en'`. `Get.locale` is GetX's
    // own copy of the language and is empty until something calls
    // `Get.updateLocale`, so on a cold start into Arabic this test read as
    // "not en" only by accident. `ContextExtension.isArabic` reads the
    // Localizations the rest of the widget tree resolves against, so this
    // list can no longer disagree with the labels around it.
    final bool isArabic = ContextExtension(context).isArabic;

    String labelFor(dynamic department) => isArabic
        ? (department.departmentNameInArabic ?? '')
        : FormatHelper.capitalize(department.departmentName ?? '');

    final List<DropdownItem<String>> items = <DropdownItem<String>>[
      // CHANGED: was `S.current.all` — the static, which resolves against
      // whatever locale was last loaded rather than this subtree's.
      DropdownItem<String>(
        value: S.of(context).all,
        label: S.of(context).all,
      ),
      ...Get.find<MainCoreDepartmentCubit>().departmentModels.map(
            (e) => DropdownItem<String>(
              value: labelFor(e),
              label: labelFor(e),
            ),
          ),
    ];

    return SizedBox(
      // Height moved onto CustomDropdown.height, which sizes the TRIGGER only.
      // Keeping it on the SizedBox would pin the whole column and clip
      // anything the widget draws under the trigger.
      width: 150.sp,
      child: CustomDropdown<String>(
        height: 38,
        fillColor: AppColors.card,
        // `itemHeight` is used raw by CustomDropdown (`itemHeight ?? 36.sp`),
        // so it is passed pre-scaled — same as AppDropdown's menuItemHeight.
        itemHeight: 38,
        // This is a toolbar FILTER, not a form field, and AppDropdown rendered
        // `textButton` unconditionally: the button read "Department" whatever
        // was selected. `alwaysShowHint` is CustomDropdown's name for exactly
        // that behaviour — the label keeps naming what the button does, and
        // the current choice is shown by the highlighted row in the open menu.
        alwaysShowHint: true,
        // CHANGED: was the literal 'Department'.
        hint: S.of(context).department,
        // False for the same reason `CustomSortButton` sets it false: the
        // 14sp-label / 12sp-hint rule is about form fields sitting next to a
        // CustomTextField. Here the hint IS the button label, and enforcing
        // the form scale would resize it against the search field beside it.
        enforceTypeScale: false,
        triggerPadding: EdgeInsets.symmetric(horizontal: 12.sp,vertical: 12.sp),
        itemStyle: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryBlack),
        value: state.selectedDepartmentFilter,
        borderRadius: BorderRadius.circular(8.r),
        items: items,
        onChanged: (String value) {
          cubit.updateSelectedDepartmentFilter(value);
        },
      ),
    );
  }
}