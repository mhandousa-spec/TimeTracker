/// Module: roles / r5_system_logs / presentation / ui / pages
///
/// *************************** FILE INFO ******************** ///
/// FILE NAME: system_logs_table.dart
/// PURPOSE: this file contains the system logs tab content.
/// Author: Amr Mesbah
/// Created At: 2/2/2025
/// Updated: 9/10/2026 - Time Tracker phase 6: the Module column shows the
///          module's display name ("Time Tracker"), not its enum id.
/// Updated: 30/8/2026 - The table is now r4's `DefaultDataTable`, assembled
///          exactly the way `UserData` (r4_active_directory/.../tabs/
///          user_data_tab.dart) assembles it: `Expanded` > `ClipRRect(10.sp)`
///          > `DefaultDataTable`, with the same `DataRow.color` striping.
///          What was here before was a `SingleChildScrollView` wrapping a
///          hand-measured `SizedBox` (2.55 / 2.1 / 2.3 screen widths, chosen
///          per tablet/orientation) around a `ListView` holding a header
///          widget and a second, nested `ListView.builder` of `Row`s. The
///          width had to be guessed because nothing measured the columns, and
///          the header and the rows padded themselves independently.
///          `DefaultDataTable` owns the scrolling in both axes, so the guessed
///          width and both scroll wrappers are gone, and `height: 0.55.h`
///          became `Expanded`.
/// Updated: 30/8/2026 - The Module column is capitalised through
///          `FormatHelper.capitalize`; it was printing the raw enum name.
/// Updated: 30/8/2026 - Cell values centred under their headings (see also
///          `system_logs_table_header.dart` and `custom_table_body.dart`, which
///          carry the heading alignment and the 14.sp / 12.sp type sizes), and
///          the Date column now reads "30 Aug 2026" rather than
///          "Aug 30, 2026".
/// Updated: 9/9/2026 - PHONES GET A DIFFERENT TAB BODY. Figma draws the System
///          Logs tab on a phone as the "Export Details" form (MESBAH / ROLE
///          MANAGEMENT, node 6976:24621), not as the desktop data table
///          squeezed into 375 points. `initState` still loads the logs and
///          builds the filter lists, because that form's dropdowns are built
///          from them; only the body below changes.
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/widgets/custom_table_body.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/widgets/system_logs_appbar.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/widgets/system_logs_table_header.dart';

// The shared table style, owned by r4_active_directory. Imported across
// features on purpose: it is the app's one table look, and copying it here
// would be the third place the same DataTable metrics are written down.
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/domain/constants/system_logs_constants.dart';
// ADDED 30/8/2026 for the Module column's casing — see `_cellText`.
import 'package:knowticed_plus/features/roles/r5_system_logs/domain/enums/system_logs_items.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
// ADDED 9/10/2026 — the Module column shows `Modules.getModuleName`.
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/logs_mobile_export_details_page.dart';

class SystemLogsTable extends StatefulWidget {
  const SystemLogsTable({super.key});

  @override
  State<SystemLogsTable> createState() => _SystemLogsTableState();
}

class _SystemLogsTableState extends State<SystemLogsTable> {
  SystemLogsController systemLogsController = AppControllers.systemLogs;
  EmployeeController addEmployeeController = AppControllers.employeeDirectory;
  @override
  void initState() {
    systemLogsController.getSystemLogs().then((value) {
      systemLogsController.initFiltersLists();
      systemLogsController.resetFilter();
    });
    super.initState();
  }


  /// Presents the outcomes the cubit publishes.
  ///
  /// These used to run inside `SystemLogsController` against `Get.context!`.
  Future<void> _handleSystemLogsState(
      BuildContext context, SystemLogsState state) async {
    if (state is SystemLogsExporting) {
      showLoadingIndicator();
      return;
    }

    if (state is SystemLogsNoFilterSelected) {
      await CustomDialogManager.showMessage(
        context: context,
        title: S.of(context).warning,
        // TODO(knowticed, 12/8/2026): needs an ARB key; kept as the original
        // literal rather than inventing generated-l10n entries by hand.
        subtitle: 'Please select at least one filter.',
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      );
      return;
    }

    if (state is SystemLogsExportFinished) {
      hideLoadingIndicator();
      if (!context.mounted) return;

      // REMOVED 21/9/2026: the pop that closed the "download" dialog here.
      // The dialog now closes itself before the export starts, so a pop at
      // this point would close the Systems Logs page instead.

      // CHANGED 21/9/2026 — success is the auto-closing dialog (no OK
      // button, gone after 3 s). A failure still uses showMessage, so the
      // error stays on screen until the user dismisses it.
      if (state.succeeded) {
        await CustomDialogManager.showSuccess(
          context: context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/approved.json',
          title: S.of(context).success,
          // TODO(knowticed, 12/8/2026): needs an ARB key.
          subtitle: 'Your data has been saved to the Download folder.',
          closeAfter: const Duration(seconds: 3),
        );
        return;
      }

      await CustomDialogManager.showMessage(
        context: context,
        title: S.of(context).error,
        // TODO(knowticed, 12/8/2026): needs an ARB key.
        subtitle: 'Could not save the file.',
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The cubit renders CSV rows and matches search terms outside any widget,
    // so it needs the active language. Was `Get.locale` read from inside the
    // cubit and the domain enum; the page supplies it from Localizations.
    systemLogsController.exportInArabic = context.isArabic;

    // REMOVED 30/8/2026: `isTablet`. It only fed the hand-picked table width
    // that `DefaultDataTable` now measures for itself.
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      // BlocConsumer, not BlocBuilder: the cubit no longer opens dialogs or
      // toggles the loading overlay itself (§16), so this page presents the
      // outcomes it publishes.
      body: BlocConsumer<SystemLogsController, SystemLogsState>(
          bloc: AppControllers.systemLogs,
          listenWhen: (_, current) =>
              current is SystemLogsNoFilterSelected ||
              current is SystemLogsExporting ||
              current is SystemLogsExportFinished,
          listener: (context, state) => _handleSystemLogsState(context, state),
          builder: (context, state) {
        final controller = AppControllers.systemLogs;

        // Phone: the Figma tab body. It reads `systemLogsData`, `accessNames`,
        // `actions`, `countries` and `cities` off this same controller, all of
        // which `initState` above has already asked for, and it rebuilds with
        // this BlocConsumer as they arrive.
        if (context.isPhone) {
          return const LogsMobileExportDetailsPage();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SystemLogsAppBar(),
            SizedBox(height: 20.h),
            controller.systemLogsData.isEmpty
                ? controller.logsLoaded
                    ? Expanded(
                        child: Center(
                          child: Text(
                            S.of(context).noSystemLogsFound,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: .26.h),
                          child: SizedBox(
                              height: isPortrait ? 0.055.h : 0.07.h,
                              child: const CircleProgressMaster()),
                        ),
                      )
                : Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.sp),
                      child: DefaultDataTable(
                        columns: SystemLogsTableHeader.columns(),
                        rows:
                            _tableRows(context, controller.finalSystemLogsList),
                      ),
                    ),
                  )
          ],
        );
      }),
    );
  }

  /// The log rows, as `DataRow`s.
  ///
  /// The striping is `UserData._buildRow`'s, colour for colour: even rows take
  /// `evenRowColor` in light and `oddRowColor` in dark, odd rows take `white`
  /// in light and `black` in dark. The old logs table used a different pair
  /// (`darkBackGround` / `oddRowColor` against `colorWhite`), which is why its
  /// rows read as mid-grey next to Active Directory's near-black ones.
  ///
  /// It also rides on `DataRow.color` rather than a `Container` decoration:
  /// `DataTable` paints the row itself, and a nested coloured box would sit
  /// inside the cell padding instead of behind the whole row.
  List<DataRow> _tableRows(
      BuildContext context, List<SystemLogsModel> systemLogs) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final bool isArabic = context.isArabic;

    return [
      for (int index = 0; index < systemLogs.length; index++)
        DataRow(
          color: WidgetStatePropertyAll(
            index % 2 == 0
                ? (isLightMode ? AppColors.evenRowColor : AppColors.oddRowColor)
                : (isLightMode ? AppColors.white : AppColors.black),
          ),
          cells: [
            for (final item in SystemLogsConstants.systemLogsItems)
              // CENTRED 30/8/2026: this outer `Align` was `centerStart`, which
              // pinned the cell to the leading edge before `CustomTableBody`
              // ever got to place its text. It fills the cell width now and
              // lets the body centre itself under the heading.
              DataCell(
                Align(
                  alignment: Alignment.center,
                  child: CustomTableBody(
                    text: _cellText(systemLogs[index], item, isArabic),
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  /// One cell's text.
  ///
  /// ADDED 30/8/2026 for the Module column, which is the only value in this
  /// table that arrives as an identifier rather than as prose: it is
  /// `Modules.roles.name` — the enum's own Dart name — so it printed lowercase
  /// ("roles", "more") in a row where every neighbour is capitalised.
  ///
  /// [FormatHelper.capitalize] rather than a local `toUpperCase` on the first
  /// letter: it is what the User Management table uses on the same kind of
  /// value, and it also carries the app's abbreviation list, so a module whose
  /// name is an initialism ("grc") comes out "GRC" and not "Grc".
  ///
  /// Applied HERE and not in `SystemLogsItems.itemValue`, which also feeds the
  /// CSV export — an export is data, and its Module column should keep the
  /// stored identifier.
  String _cellText(
    SystemLogsModel log,
    SystemLogsItems item,
    bool isArabic,
  ) {
    final String value = item.itemValue(log, isArabic: isArabic);

    // CHANGED 9/10/2026 (Time Tracker phase 6): the module's display name
    // ("Time Tracker", "Knowledge Hub") instead of its capitalised enum id
    // ("TimeTracker", "KnowledgeHub"); an unknown module keeps the old text.
    final Modules? module = log.module;
    if (item == SystemLogsItems.module && module != null) {
      return module.getModuleName;
    }
    return item == SystemLogsItems.module
        ? FormatHelper.capitalize(value)
        : value;
  }
}
