import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/presentation/ui/widgets/filter_search_dialog_widgets/header.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import './filter_search_dialog_widgets/action_buttons.dart';
import './filter_search_dialog_widgets/dropdowns.dart';
import './filter_publish_date_range.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class FilterSearchDialog extends StatefulWidget {
  final List<DepartmentModelPro> departments;
  final bool isAdmin;

  const FilterSearchDialog({
    super.key,
    required this.departments,
    this.isAdmin = false,
  });

  @override
  State<FilterSearchDialog> createState() => _FilterSearchDialogState();
}

class _FilterSearchDialogState extends State<FilterSearchDialog> {
  String? owningDepartmentText;
  String? docType;
  String? owningStatusText;

  // ADDED 28/8/2026 — publish-date range, shown under the dropdowns. Both ends
  // are optional and independent; see FilterPublishDateRange.
  DateTime? publishFromDate;
  DateTime? publishToDate;

  List<Map<String, String>> departmentItems = const [];

  // ✅ FIXED: Document type keys match your database exactly
  List<Map<String, String>> get docTypeItems {
    final items = [
      {'key': 'presentation', 'value': S.of(context).presentation},
      {'key': 'form', 'value': S.of(context).form},
      {'key': 'report', 'value': S.of(context).report},
      {'key': 'booklet', 'value': S.of(context).booklet},
      {'key': 'video_recording', 'value': S.of(context).video_recording},
      {'key': 'letter', 'value': S.of(context).letter},
      {'key': 'mandate', 'value': S.of(context).mandate},
      {'key': 'policy', 'value': S.of(context).policy},
      {'key': 'frame_work', 'value': S.of(context).framework},
      {'key': 'workshop', 'value': S.of(context).workshop},
      {'key': 'guidelines', 'value': S.of(context).guidelines},
      {'key': 'other', 'value': S.of(context).other},
    ];

    log('📋 [FILTER DIALOG] Document type items: ${items.map((e) => e['key']).toList()}');
    return items;
  }

  List<Map<String, String>> get owningStatusItems => [
    {'key': 'Owner', 'value': S.of(context).owner},
    {'key': 'Contributor', 'value': S.of(context).contributor},
  ];

  @override
  void initState() {
    super.initState();

    log('═══════════════════════════════════════');
    log('🔍 [FILTER DIALOG] Initializing');
    log('═══════════════════════════════════════');

    final cubit = context.read<CreateKnowledgeCubit>();

    // ✅ Get current filter values
    owningDepartmentText = cubit.selectedOwningDepartment;
    docType = cubit.selectedDocumentType;
    owningStatusText = cubit.selectedOwningStatus;
    // Reopening the dialog shows the range that is actually applied, like the
    // three dropdowns above it.
    publishFromDate = cubit.selectedPublishFromDate;
    publishToDate = cubit.selectedPublishToDate;

    log('📌 Initial Document Type: $docType');
    log('📌 Initial Department: $owningDepartmentText');
    log('📌 Initial Owning Status: $owningStatusText');
    log('📌 Initial Publish Date: $publishFromDate → $publishToDate');

    log('═══════════════════════════════════════');
  }

  /// FIXED 12/9/2026 — `Localizations.localeOf(context)` inside
  /// [_buildDepartmentItems] is an inherited-widget lookup, and doing one in
  /// `initState` throws ("dependOnInheritedWidgetOfExactType… was called
  /// before initState completed"). The throw was swallowed by the try/catch in
  /// [_buildDepartmentItems], which returned `[]` — so the Owning Department
  /// dropdown silently came up EMPTY on every open.
  ///
  /// `didChangeDependencies` runs right after `initState` with the inherited
  /// widgets available, and again whenever the locale changes — which is also
  /// what the department names need in order to follow an in-app language
  /// switch. Guarded so a rebuild for any other dependency does not rebuild
  /// the list for nothing.
  bool _departmentItemsBuilt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_departmentItemsBuilt) return;
    _departmentItemsBuilt = true;

    departmentItems = _buildDepartmentItems();

    log('📊 Department Items Count: ${departmentItems.length}');
    log('📋 Department Items: $departmentItems');
    log('═══════════════════════════════════════');
  }

  List<Map<String, String>> _buildDepartmentItems() {
    try {
      log('🔍 [BUILD DEPT ITEMS] Starting...');
      log('🔍 [BUILD DEPT ITEMS] Widget departments count: ${widget.departments.length}');

      final departmentController = Get.find<MainCoreDepartmentCubit>();
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';

      log('🌐 [BUILD DEPT ITEMS] Language: ${isArabic ? "Arabic" : "English"}');

      final items = widget.departments.map((dept) {
        // ✅ Use department name as stored in database (consistent case)
        final key = dept.departmentName ?? '';

        log('🏢 [BUILD DEPT ITEMS] Processing: name="${dept.departmentName}", id="${dept.departmentID}"');

        // Get localized display name
        String displayValue = key;
        if (dept.departmentID != null && dept.departmentID!.isNotEmpty) {
          try {
            if (isArabic) {
              displayValue = departmentController
                  .getArabicDepartmentNameFromDepartmentId(
                departmentId: dept.departmentID!,
              ) ??
                  key;
              log('   📝 Arabic name retrieved: $displayValue');
            } else {
              displayValue = departmentController
                  .getEnglishDepartmentNameFromDepartmentId(
                departmentId: dept.departmentID!,
              ) ??
                  key;
              log('   📝 English name retrieved: $displayValue');
            }
          } catch (e) {
            log('⚠️ [BUILD DEPT ITEMS] Error getting department name: $e');
            displayValue = key;
          }
        } else {
          log('⚠️ [BUILD DEPT ITEMS] Department ID is null or empty');
        }

        log('✅ [BUILD DEPT ITEMS] Final mapping: key="$key", value="$displayValue"');
        return {'key': key, 'value': displayValue};
      }).toList();

      log('✅ [BUILD DEPT ITEMS] Complete! Total items: ${items.length}');
      for (var i = 0; i < items.length; i++) {
        log('   [$i] ${items[i]}');
      }

      return items;
    } catch (e, stackTrace) {
      log('❌ [BUILD DEPT ITEMS] Error: $e');
      log('❌ [BUILD DEPT ITEMS] Stack trace: $stackTrace');
      return [];
    }
  }

  void _resetFilters() {
    log('🔄 [FILTER DIALOG] Reset filters');

    setState(() {
      owningDepartmentText = null;
      docType = null;
      owningStatusText = null;
      publishFromDate = null;
      publishToDate = null;
    });

    context.read<CreateKnowledgeCubit>().resetFilters();
    Navigator.of(context).pop();

    log('✅ [FILTER DIALOG] Filters reset and dialog closed');
  }

  void _applyFilters() {
    log('═══════════════════════════════════════');
    log('✅ [FILTER DIALOG] Applying filters');
    log('📌 Document Type: $docType');
    log('📌 Department: $owningDepartmentText');
    log('📌 Owning Status: $owningStatusText');
    log('📌 Publish Date: $publishFromDate → $publishToDate');
    log('═══════════════════════════════════════');

    context.read<CreateKnowledgeCubit>().applyFilters(
      documentType: docType,
      owningDepartment: owningDepartmentText,
      owningStatus: owningStatusText,
      publishFrom: publishFromDate,
      publishTo: publishToDate,
    );

    Navigator.of(context).pop();

    log('✅ [FILTER DIALOG] Filters applied and dialog closed');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    log('🎨 [FILTER DIALOG] Building UI - isMobile: $isMobile, lightMode: $lightMode');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: isMobile ? 350.w : 655.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        // CHANGED 12/9/2026 — phones get 24.sp of breathing room on the
        // left/right so the dropdowns and the date fields stop running into
        // the dialog edge. Vertical padding and the tablet/desktop case are
        // unchanged.
        padding: isMobile
            ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.w)
            : EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(context, lightMode),
            SizedBox(height: 15.h),
            buildDropdowns(
              context,
              isMobile: isMobile,
              lightMode: lightMode,
              departmentItems: departmentItems,
              docType: docType,
              docTypeItems: docTypeItems,
              owningDepartmentText: owningDepartmentText,
              onChanged: (val) {
                log('═══════════════════════════════════════');
                log('🏢 [FILTER DIALOG] Department dropdown changed!');
                log('   Previous value: $owningDepartmentText');
                log('   New value: $val');
                log('═══════════════════════════════════════');
                setState(() => owningDepartmentText = val);
              },
              onDocTypeChanged: (val) {
                log('═══════════════════════════════════════');
                log('📄 [FILTER DIALOG] Document type dropdown changed!');
                log('   Previous value: $docType');
                log('   New value: $val');
                log('═══════════════════════════════════════');
                setState(() => docType = val);
              },
              isAdmin: widget.isAdmin,
              onOwningStatusChanged: (val) {
                log('═══════════════════════════════════════');
                log('👤 [FILTER DIALOG] Owning status dropdown changed!');
                log('   Previous value: $owningStatusText');
                log('   New value: $val');
                log('═══════════════════════════════════════');
                setState(() => owningStatusText = val);
              },
              owningStatusItems: owningStatusItems,
              owningStatusText: owningStatusText,
            ),
            // ADDED 28/8/2026 — publish-date range, directly under the
            // dropdowns and above Reset/Apply.
            SizedBox(height: 15.h),
            FilterPublishDateRange(
              isMobile: isMobile,
              lightMode: lightMode,
              fromDate: publishFromDate,
              toDate: publishToDate,
              onFromChanged: (val) {
                log('📅 [FILTER DIALOG] Publish "from" changed: $publishFromDate → $val');
                setState(() => publishFromDate = val);
              },
              onToChanged: (val) {
                log('📅 [FILTER DIALOG] Publish "to" changed: $publishToDate → $val');
                setState(() => publishToDate = val);
              },
            ),
            SizedBox(height: 20.h),
            buildActionButtons(
              context,
              isMobile: isMobile,
              function: _resetFilters,
              onApplyClicked: _applyFilters,
            ),
          ],
        ),
      ),
    );
  }
}