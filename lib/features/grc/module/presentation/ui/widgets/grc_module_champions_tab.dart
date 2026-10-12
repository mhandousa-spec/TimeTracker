/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_champions_tab.dart
/// Purpose: Control Champions tab body for GrcModuleDetailsPage. Renders the
///          champion request buttons, search, add/bulk-upload action, and the
///          champion list for a single GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notifier.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_page.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_person_card.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_department_filter_button.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcModuleChampionsTab]
///
/// purpose: Control Champions tab for a single [GRCModuleEntity]. Reads the
///          provided [ChampionCubit] from the widget tree and owns its own
///          search state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModuleChampionsTab extends StatefulWidget {
  final GRCModuleEntity module;

  const GrcModuleChampionsTab({super.key, required this.module});

  @override
  State<GrcModuleChampionsTab> createState() => _GrcModuleChampionsTabState();
}

class _GrcModuleChampionsTabState extends State<GrcModuleChampionsTab> {
  final _championSearchController = TextEditingController();
  final GlobalKey _addChampionButtonKey = GlobalKey();
  String _championSearchQuery = '';

  @override
  void dispose() {
    _championSearchController.dispose();
    super.dispose();
  }

  Future<void> _showChampionCreationMenu(BuildContext context) async {
    final buttonBox =
        _addChampionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      color: AppColors.card,
      items: [
        HoverablePopupMenuItem(
            value: 'add', label: S.of(context).addChampion),
        HoverablePopupMenuItem(
            value: 'bulk', label: S.of(context).bulkUpload),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      await _openAddChampion(context);
    } else if (choice == 'bulk') {
      await _openChampionBulkUpload(context);
    }
  }

  Future<void> _openAddChampion(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddChampionPage(
          moduleId: widget.module.moduleId,
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  Future<void> _openChampionBulkUpload(BuildContext context) async {
    final championCubit = context.read<ChampionCubit>();
    final Set<String> bulkAssignees = <String>{};
    AssigningControlEntity? bulkFirstPair;
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
          moduleId: widget.module.moduleId,
          assigneeLabel: S.of(context).controlChampion,
          createAssignee: ({
            required moduleId,
            required email,
            required assigningControls,
            required editorId,
          }) async {
            // notify: false — the batch is announced once, after the page
            // closes (GrcAssigneeNotifier.bulkUploaded below).
            final created = await championCubit.createChampion(
              moduleId: moduleId,
              championEmail: email,
              assigningControls: assigningControls,
              notify: false,
            );
            if (created.isRight()) {
              bulkAssignees.add(email);
              bulkFirstPair ??= assigningControls.isEmpty
                  ? null
                  : assigningControls.first;
            }
            return created;
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (bulkAssignees.isNotEmpty) {
      GrcAssigneeNotifier.bulkUploaded(
        role: GrcAssigneeRole.champion,
        moduleId: widget.module.moduleId,
        assigneeEmails: bulkAssignees,
        first: bulkFirstPair,
      );
    }
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  List<ChampionEntity> _applyChampionSearch(
      BuildContext context, List<ChampionEntity> champions) {
    if (_championSearchQuery.isEmpty) return champions;
    final q = _championSearchQuery.toLowerCase();
    return champions
        .where((c) =>
            employeeDisplayName(context, c.championEmail)
                .toLowerCase()
                .contains(q) ||
            c.championEmail.toLowerCase().contains(q))
        .toList();
  }

  /// Department filter -- only the phone frame draws it (the sliders
  /// button beside search); 768 / 1024 have Export in that slot.
  String? _departmentFilter;

  List<ChampionEntity> _applyDepartmentFilter(
      BuildContext context, List<ChampionEntity> champions) {
    final String? dept = _departmentFilter;
    if (dept == null || dept.isEmpty) return champions;
    return champions
        .where((c) =>
            findEmployeeByEmail(c.championEmail).localizedDepartment(context) ==
            dept)
        .toList();
  }

  void _openRequests(BuildContext context, {required bool mine}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrcRequestsListPage(
          module: widget.module,
          onlyRequestedBy: mine ? currentGrcUserEmail() : null,
          typeFilter: GrcRequestType.reassignChampion,
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, List<ChampionEntity> rows) {
    final S s = S.of(context);
    return exportGrcCsv(
      context: context,
      defaultFileName: 'control_champions',
      header: [s.no, s.name, s.email, s.department, s.jobTitle],
      rows: [
        for (var i = 0; i < rows.length; i++)
          () {
            final employee = findEmployeeByEmail(rows[i].championEmail);
            return <Object?>[
              i + 1,
              employeeDisplayName(context, rows[i].championEmail),
              rows[i].championEmail,
              employee.localizedDepartment(context),
              employee.localizedJobTitle(context),
            ];
          }(),
      ],
    );
  }

  /// Phone height of the Requests buttons and the search / filter / add
  /// row.
  double get _phoneHeight => 36.sp;

  @override
  Widget build(BuildContext context) {
    final ScreenSize size = screenSizeOf(context);
    final bool isMobile = size == ScreenSize.mobile;

    return BlocBuilder<ChampionCubit, ChampionState>(
      builder: (context, state) {
        final champions =
            state is ChampionListLoaded ? state.champions : <ChampionEntity>[];
        final filtered = _applyDepartmentFilter(
            context, _applyChampionSearch(context, champions));

        final Widget addButton = Container(
          key: _addChampionButtonKey,
          child: customButtonWithSvg(
            colorBorder: AppColors.transparent,
            space: 10.w,
            widthImage: 18.sp,
            heightImage: 18.sp,
            function: () => _showChampionCreationMenu(context),
            fixedWidth: isMobile ? _phoneHeight : null,
            fixedHeight: isMobile ? _phoneHeight : null,
            // Icon-only at 375, "+ Add Champion" at 768 / 1024.
            title: isMobile ? '' : S.of(context).addChampion,
            textStyle: StyleText.fontSize16Weight400
                .copyWith(color: AppColors.textButton),
            image: AppAssets.add,
            color: AppColors.primary,
            svgColor: AppColors.textButton,
          ),
        );

        final Widget exportButton = customButtonWithSvg(
          colorBorder: AppColors.transparent,
          space: 10.w,
          widthImage: 20.sp,
          heightImage: 20.sp,
          function: () => _export(context, filtered),
          // 768 draws the icon alone; 1024 labels it.
          title: size == ScreenSize.desktop ? S.of(context).export : '',
          textStyle: StyleText.fontSize16Weight400
              .copyWith(color: AppColors.textButton),
          image: AppAssets.export,
          color: AppColors.primary,
          svgColor: AppColors.textButton,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone: 36.sp tall (customButton draws 38.sp; the box wins).
            SizedBox(
              height: isMobile ? _phoneHeight : null,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                  title: S.of(context).myRequests,
                  function: () => _openRequests(context, mine: true),
                  width: 135.w,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight400
                      .copyWith(color: AppColors.textButton),
                ),
                SizedBox(width: 10.w),
                customButton(
                  title: S.of(context).requests,
                  function: () => _openRequests(context, mine: false),
                  width: 135.w,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight400
                      .copyWith(color: AppColors.textButton),
                ),
              ],
            ),
            ),
            SizedBox(height: 15.h),
            SizedBox(
              height: isMobile ? _phoneHeight : null,
              child: Row(
              spacing: 10.w,
              children: [
                AppSearchTextField(
                  // Raw value — the field applies .sp. 36 on a phone.
                  height: isMobile ? 36.0 : null,
                  onChanged: (v) => setState(() => _championSearchQuery = v),
                  hintText: S.of(context).search,
                  controller: _championSearchController,
                ),
                ...switch (size) {
                  ScreenSize.desktop => [exportButton, addButton],
                  ScreenSize.tablet => [addButton, exportButton],
                  ScreenSize.mobile => [
                      GrcDepartmentFilterButton(
                        size: _phoneHeight,
                        value: _departmentFilter,
                        onChanged: (v) =>
                            setState(() => _departmentFilter = v),
                      ),
                      addButton,
                    ],
                },
              ],
            ),
            ),
            SizedBox(height: 15.h),
            Expanded(child: _buildChampionList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildChampionList(
    BuildContext context,
    ChampionState state,
    List<ChampionEntity> champions,
  ) {
    if (state is ChampionLoading) {
      return Center(child: const CircleProgressMaster());
    }
    if (state is ChampionFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    // The app's one empty state: the lottie_empty animation, centred, no
    // words (see 89-custom_empty_state.dart).
    if (champions.isEmpty) {
      return const Center(child: CustomEmptyState());
    }

    // 1 up at 375, 2 up at 768, 3 up at 1024 -- rows of equal-height
    // tiles, so a longer job title never stretches one tile past its
    // neighbour.
    final int columns =
        responsiveValue(context, mobile: 1, tablet: 2, desktop: 3);
    final int rows = (champions.length / columns).ceil();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: rows,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, row) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List<Widget>.generate(columns * 2 - 1, (slot) {
                if (slot.isOdd) return SizedBox(width: 15.w);
                final int index = row * columns + slot ~/ 2;
                if (index >= champions.length) {
                  return const Expanded(child: SizedBox());
                }
                final champion = champions[index];
                return Expanded(
                  child: GrcModulePersonCard(
                    email: champion.championEmail,
                    onTap: () => _openDetails(context, champion),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDetails(
      BuildContext context, ChampionEntity champion) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlChampionDetailsPage(
          champion: champion,
          module: widget.module,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }
}
