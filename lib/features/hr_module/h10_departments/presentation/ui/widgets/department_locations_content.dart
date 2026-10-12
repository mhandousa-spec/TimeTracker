// ***************************** FILE INFO ***************************** //
// File Name: department_locations_content.dart
// Purpose: Renders the real Departments location selector and overview.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/countries.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../controller/department_locations_cubit.dart';
import '../../controller/department_locations_state.dart';
import '../../../domain/entity/department_location_entity.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays loaded Department locations and the selected location overview.
class DepartmentLocationsContent extends StatelessWidget {
  const DepartmentLocationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return BlocBuilder<DepartmentLocationsCubit, DepartmentLocationsState>(
      builder: (context, state) {
        if (state is DepartmentLocationsLoading && state.locations.isEmpty) {
          return const SizedBox(
            height: 260,
            child: CircleProgressMaster(),
          );
        }

        if (state is DepartmentLocationsLoadError && state.locations.isEmpty) {
          return _buildErrorState(context, localization);
        }

        if (state.locations.isEmpty || state.filteredLocations.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedLocation =
            state.selectedLocation ?? state.filteredLocations.first;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850.w;
            final locationsPanel = _buildLocationsPanel(
              context,
              state,
              languageCode,
            );
            final overviewPanel = _buildOverviewPanel(
              selectedLocation,
              languageCode,
              localization,
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  locationsPanel,
                  SizedBox(height: 16.h),
                  overviewPanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280.w, child: locationsPanel),
                SizedBox(width: 16.w),
                Expanded(child: overviewPanel),
              ],
            );
          },
        );
      },
    );
  }

  /// Method Name: [_buildLocationsPanel]
  ///
  /// Purpose: Builds the selectable list of loaded locations.
  ///
  /// Parameters:
  /// - [context]: Provides the location Cubit.
  /// - [state]: Supplies filtered locations and the current selection.
  /// - [languageCode]: Active application language code.
  ///
  /// Returns: A styled location selector panel.
  Widget _buildLocationsPanel(
    BuildContext context,
    DepartmentLocationsState state,
    String languageCode,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).locations.toUpperCase(),
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 12.h),
          ...state.filteredLocations.map(
            (location) => _buildLocationTile(
              context,
              location,
              state.selectedLocationId == location.id,
              languageCode,
            ),
          ),
        ],
      ),
    );
  }

  /// Method Name: [_buildLocationTile]
  ///
  /// Purpose: Renders one selectable location name.
  ///
  /// Parameters:
  /// - [context]: Provides the location Cubit.
  /// - [location]: Location represented by the tile.
  /// - [isSelected]: Whether the tile is currently selected.
  /// - [languageCode]: Active application language code.
  ///
  /// Returns: A selectable location tile.
  Widget _buildLocationTile(
    BuildContext context,
    DepartmentLocationEntity location,
    bool isSelected,
    String languageCode,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () =>
          context.read<DepartmentLocationsCubit>().selectLocation(location.id),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary : AppColors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          location.localizedName(languageCode),
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
      ),
    );
  }

  /// Method Name: [_buildOverviewPanel]
  ///
  /// Purpose: Displays only the selected location values supported today.
  ///
  /// Parameters:
  /// - [location]: Selected location entity.
  /// - [languageCode]: Active application language code.
  /// - [localization]: Localized field labels.
  ///
  /// Returns: The selected-location overview panel.
  Widget _buildOverviewPanel(
    DepartmentLocationEntity location,
    String languageCode,
    S localization,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.localizedName(languageCode),
            style: StyleText.fontSize20Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            localization.country,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _countryName(location.countryCode, languageCode),
            style: StyleText.fontSize15Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  /// Method Name: [_buildErrorState]
  ///
  /// Purpose: Shows a localized read error and allows another load attempt.
  ///
  /// Parameters:
  /// - [context]: Provides the location Cubit.
  /// - [localization]: Localized error and retry text.
  ///
  /// Returns: An error panel with a retry action.
  Widget _buildErrorState(
    BuildContext context,
    S localization,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            localization.errorOccurred,
            textAlign: TextAlign.center,
            style: StyleText.fontSize15Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16.h),
          customButton(
            title: localization.retry,
            function: context.read<DepartmentLocationsCubit>().loadLocations,
            color: AppColors.primary,
            textStyle: StyleText.fontSize15Weight400.copyWith(
              color: AppColors.textButton,
            ),
          ),
        ],
      ),
    );
  }

  /// Method Name: [_countryName]
  ///
  /// Purpose: Resolves a stored ISO country code for display.
  ///
  /// Parameters:
  /// - [countryCode]: Persisted country code.
  /// - [languageCode]: Active application language code.
  ///
  /// Returns: The localized country name, or the stored code when unmatched.
  String _countryName(String countryCode, String languageCode) {
    for (final country in countries) {
      if (country.code == countryCode) {
        return country.localizedName(languageCode);
      }
    }
    return countryCode;
  }
}
