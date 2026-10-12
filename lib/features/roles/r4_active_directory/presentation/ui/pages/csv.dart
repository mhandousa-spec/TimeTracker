/// Module: roles / r4_active_directory / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: csv.dart
/// Purpose: Declares `CsvView`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/9/2026  - PHONES GET A DIFFERENT TAB BODY. Figma draws the
///          Active Directory tab on a phone as the "Export Details" form
///          (MESBAH / ROLE MANAGEMENT, node 6975:11036), not as the desktop
///          data table squeezed into 375 points. `CustomCsvTable` is unchanged
///          and still serves tablet and desktop.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import './ad_mobile_export_details_page.dart';
import './custom_csv_table_page.dart';

class CsvView extends StatelessWidget {
  const CsvView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    // Was `Get.isRegistered` + `Get.put` inline. The locator stays behind the
    // AppControllers seam (GetX standing rule).
    AppControllers.ensureActiveDirectory(
      () => ActiveDirectoryController(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
      ),
    );

    // The controller is registered either way — the phone body reads
    // `usersData` from it exactly as the table does.
    if (context.isPhone) {
      return const Scaffold(
        body: SafeArea(child: AdMobileExportDetailsPage()),
      );
    }

    return const Scaffold(body: SafeArea(child: CustomCsvTable()));
  }
}