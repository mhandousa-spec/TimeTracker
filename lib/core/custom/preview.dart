/// Module: Core · Custom · Preview All Custom
/// Description: Single scrollable gallery page that instantiates every
///              reusable widget/helper found in lib/core/custom/, grouped
///              into labeled sections (one per source file) so the whole
///              custom widget library can be eyeballed in one place.
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: every file in lib/core/custom/
/// Revision History:
///   - 01/07/2026: Initial creation.
library;

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/models/calendar_date_picker2_config.dart'
    as local_cal;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';



import './1-custom_dropdown.dart';
import './2-custom_textfield.dart';
import './3-custom_dropdown_calander.dart';
import './4-custom_dropdown_range_calander.dart';
import './5-custom_button.dart';
import './6-custom_button_with_svg.dart';
import './7-custom_button_with_icon.dart';
import './8-custom_filter_app.dart';
import './9-filter_tab_with_container.dart';
import './10-custom_tabs.dart';
import './52-custom_upload_document.dart';
// 11's own showUploadDialog is a near-duplicate of 10's — hidden here to
// avoid an ambiguous-import error; section 10 already demos the dedicated one.
import './11-custom_confirm_diaolog.dart' hide showUploadDialog;
import './12-custom_delete_icon.dart';
import './13-custom_edit_icon.dart';
import './14-custom_filter_icon.dart';
import './15-custom_sort_icon.dart';
import './16-custom_card_styles.dart';
import './17-custom_service_summary_card.dart';
import './18-custom_service_request_card.dart';
import './19-Custom_Employee_Card.dart';
import './20-custom_personal_info_card.dart';
import './21-custom_contact_card.dart';
import './22-custom_uploaded_document_card.dart';
import './23-custom_check_box.dart';
import './24-custom_chart_card.dart';
import './25-custom_overall_stats_card.dart';
import './26-custom_bar_chart_card.dart';
import './27-custom_donut_chart_card.dart';
import './28-custom_horizontal_bar_chart_card.dart';
import './29-custom_grouped_bar_chart_card.dart';
import './30-custom_attendance_tiles_card.dart';
import './31-custom_multi_select_dropdown.dart';
import './32-custom_svg.dart';
import './33-custom_haptic.dart';
import './34-custom_gridview_with_animation.dart';
import './53-custom_date_pic.dart';
import './35-custom_search_widget_custom.dart';
import './36-custom_comment_widget.dart';
import './37-custom_navigate.dart';
import './38-custom_responsive.dart';
import './42-custom_approval_cycle.dart';
import './43-custom_module_info_card.dart';
import './39-custom_grid_button.dart';
import './40-custom_table_button.dart';
import './41-custom_button_sizing.dart';
import './44-custom_validated_textfield.dart';
import './45-custom_app_dropdown.dart';
import './46-custom_image_picker.dart';
import './47-custom_sort_button.dart';
import './48-custom_approval_shape.dart';
import './49-custom_view_multi_select_dropdown.dart';
import './50-custom_side_frame_master.dart';
import './51-custom_pop_up.dart';
import './54-custom_grid_view.dart';
import './55-custom_responsive_fields.dart';
import './56-custom_services_multi_select.dart';
import './57-custom_dialog_manager.dart';
import './58-default_switch_button.dart';
import './59-custom_intl_phone_field.dart';
import './60-custom_country_picker.dart';
import './61-custom_color_picker.dart';
import './62-custom_date_time_helper.dart';
import './63-custom_main_button.dart';
import './64-custom_response_dialog.dart';
import './65-custom_dropdown_button2.dart';
import './67-column_request_data.dart';
import './68-confirm_dialog.dart';
import './69-cross_axis_count_helper.dart';
import './70-custom_appbar.dart';
import './71-custom_appbar_mobile.dart';
import './72-custom_calendar_picker.dart';
import './73-custom_logout_dialog.dart';
import './74-custom_stacked_avatars.dart';
import './75-custom_title_value_widget.dart';
import './76-date_time_in_arabic.dart';
import './77-default_dialog.dart';
import './78-expanded_content.dart';
import './79-filter_bar_item.dart';
import './80-filters_appbar.dart';
import './81-hover_example.dart';
import './82-image_grid_card.dart';
import './84-messaging_custom_button.dart' as msg;
import './85-module_page_stubs.dart' as stubs;
import './86-removed_module_placeholder.dart';
import './87-responsive_card_grid.dart';
import './88-stacked_avatars.dart';

///*************************** FILE INFO ****************************///
/// File Name: preview_all_custom.dart
/// Purpose: Gallery page demoing every widget in lib/core/custom/.

class PreviewAllCustomPage extends StatefulWidget {
  const PreviewAllCustomPage({super.key});

  @override
  State<PreviewAllCustomPage> createState() => _PreviewAllCustomPageState();
}

class _PreviewAllCustomPageState extends State<PreviewAllCustomPage> {
  // --- Demo state for the interactive widgets below ---
  String? _dropdownValue;
  int _langIndex = 1;
  DateTime? _dobValue;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<int> _multiSelectValues = [];
  bool _checkboxSelected = false;
  bool _checkboxSelected2 = true;
  String _filterSelectedKey = 'all';
  int _segmentedIndex = 0;
  int _pageTabIndex = 0;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // --- state for the extended sections ---
  bool _switchOn = false;
  String? _dd2Value;
  String? _sortValue = 'name';
  List<String> _multiSel = [];
  List<String> _multiSelMaster = [];
  List<DateTime?> _calendarDates = [];
  Color _pickedColor = AppColors.primary;
  bool _filterBarSelected = true;
  final TextEditingController _validatedCtrl = TextEditingController();


  @override
  void dispose() {
    _textFieldController.dispose();
    _searchController.dispose();
    _validatedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Custom Widgets Preview'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          _section(
            '1 · CustomDropdown',
            CustomDropdown<String>(
              label: 'Department',
              hint: 'Select a department',
              value: _dropdownValue,
              items: const [
                DropdownItem(value: 'eng', label: 'Engineering'),
                DropdownItem(value: 'sales', label: 'Sales'),
                DropdownItem(value: 'hr', label: 'Human Resources'),
              ],
              onChanged: (v) => setState(() => _dropdownValue = v),
            ),
          ),
          _section(
            '2 · CustomTextField',
            Column(
              children: [
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter your name',
                  controller: _textFieldController,
                ),
                SizedBox(height: 12.h),
                const CustomTextField(
                  label: 'Read-only',
                  hint: 'Cannot edit this',
                  readOnly: true,
                  initialValue: 'Fixed value',
                ),
              ],
            ),
          ),
          _section(
            '3 · CustomDropdownCalendar',
            CustomDropdownCalendar(
              label: 'Date of birth',
              hint: 'Select a date',
              value: _dobValue,
              onChanged: (v) => setState(() => _dobValue = v),
            ),
          ),
          _section(
            '4 · CustomDropdownRangeCalendar',
            CustomDropdownRangeCalendar(
              label: 'Date range',
              startDate: _rangeStart,
              endDate: _rangeEnd,
              onChanged: (start, end) => setState(() {
                _rangeStart = start;
                _rangeEnd = end;
              }),
            ),
          ),
          _section(
            '5 · customButton',
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                customButton(title: 'Save', function: () {}, width: 140, height: 40, color: AppColors.primary,
                  textColor: AppColors.textButton,),
                customButton(
                  title: 'Cancel',
                  function: () {},
                  width: 140,
                  height: 40,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                ),
              ],
            ),
          ),
          _section(
            '6 · customButtonWithSvg',
            customButtonWithSvg(
              title: 'Add',
              function: () {},
              textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
              height: 44,
              space: 8,
              radius: 8,
              color: AppColors.primary,
              image: 'assets/icons_assets/main_icons_assets/plus.svg',
              widthImage: 20,
              heightImage: 20,
              colorBorder: Colors.transparent,
            ),
          ),
          _section(
            '7 · customButtonWithIcon',
            customButtonWithIcon(
              title: 'Add item',
              function: () {},
              textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
              width: 160,
              height: 44,
              space: 8,
              radius: 8,
              color: AppColors.primary,
              icon: Icons.add,
              iconColor: AppColors.textButton,
              iconSize: 20,
            ),
          ),
          _section(
            '8 · StatusChipFilter',
            StatusChipFilter(
              selectedKey: _filterSelectedKey,
              onSelected: (key) => setState(() => _filterSelectedKey = key),
              items: const [
                StatusChipItem(key: 'all', label: 'All', count: 12),
                StatusChipItem(key: 'pending', label: 'Pending', count: 5),
                StatusChipItem(key: 'approved', label: 'Approved', count: 7),
              ],
            ),
          ),
          _section(
            '9 · CustomSegmentedTabs',
            SizedBox(
              width: 130.sp,
              child: CustomSegmentedTabs(
                tabs: const ['Chart', 'Table'],
                selectedIndex: _segmentedIndex,
                onTabSelected: (i) => setState(() => _segmentedIndex = i),
              ),
            ),
          ),
          _section(
            '10 · CustomTabs (underlined page tabs)',
            CustomTabs(
              tabs: const [
                'Role Management',
                'User Management',
                'User Access',
                'Active Directory',
                'System Logs',
              ],
              selectedValue: _pageTabIndex,
              onChanged: (v) => setState(() => _pageTabIndex = v),
            ),
          ),
          _section(
            '10 · showUploadDialog',
            customButton(
              textStyle: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.textButton
              ),
              title: 'Open upload dialog',
              width: 220,

              height: 40,
              function: () => showUploadDialog(context: context, onSubmit: (file, title) {},headerIconAsset: "assets/icons_assets/main_icons_assets/cloud_upload.svg"),
            ),
          ),
          _section(
            '11 · showConfirmDialog / showSuccessDialog / showCommentDialog',
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                customButton(
                  title: 'Confirm dialog',
                  width: 150,
                  height: 36,
                  function: () => showConfirmDialog(context: context),
                ),
                customButton(
                  title: 'Success dialog',
                  width: 150,
                  height: 36,
                  function: () => showSuccessDialog(context: context),
                ),
                customButton(
                  title: 'Comment dialog',
                  width: 150,
                  height: 36,
                  function: () => showCommentDialog(context: context, onSubmit: (comment) {}),
                ),
              ],
            ),
          ),
          _section(
            '12-15 · Delete / Edit / Filter / Sort icons',
            Wrap(
              spacing: 16.w,
              runSpacing: 8.h,
              children: [
                CustomDeleteIcon(onTap: () {}),
                CustomEditIcon(onTap: () {}),
                CustomFilterIcon(onTap: () {}),
                CustomSortIcon(onTap: () {}),
              ],
            ),
          ),
          _section(
            '16 · CardInfoRow (CardStyles/CardSvg tokens)',
            const CardInfoRow(
              info: CardInfo(label: 'Job Title:', value: 'Marketing Manager'),
            ),
          ),
          _section(
            '17 · ServiceSummaryCard',
            const ServiceSummaryCard(
              title: 'Laptop Repair',
              infoRows: [
                CardInfo(label: 'Service Provider:', value: 'Ahmed Mohammed'),
                CardInfo(label: 'Duration:', value: '2 days'),
              ],
              footerLabel: 'Status:',
              footerValue: 'In progress',
            ),
          ),
          _section(
            '18 · ServiceRequestCard',
            ServiceRequestCard(
              title: 'Market Research Service',
              icon: CardSvg.icon(CardSvg.services),
              infoRows: [
                CardInfo(
                  label: 'Service Provider:',
                  value: 'Ahmed Mohammed',
                  icon: CardSvg.icon(CardSvg.serviceProvider),
                ),
                CardInfo(
                  label: 'Job Title:',
                  value: 'Marketing Manager',
                  icon: CardSvg.icon(CardSvg.jobTitle),
                ),
                CardInfo(
                  label: 'Duration of Service:',
                  value: '1 Week',
                  icon: CardSvg.icon(CardSvg.duration),
                ),
                CardInfo(
                  label: 'Approval:',
                  value: 'Needs Approval',
                  icon: CardSvg.icon(CardSvg.approval),
                ),
              ],
              buttonText: 'Request',
              onPressed: () {},
            ),
          ),
          _section(
            '19 · PersonChipCard',
            const PersonChipCard(
              name: 'Sara Ali',
              subtitle1: 'Product Designer',
              subtitle2: 'sara.ali@company.com',
            ),
          ),
          _section(
            '20 · PersonalInfoCard',
            const PersonalInfoCard(
              title: 'Change Request',
              requestedByName: 'Mona Hassan',
              jobTitle: 'HR Specialist',
              department: 'Human Resources',
            ),
          ),
          _section(
            '21 · ContactCard',
            const ContactCard(
              name: 'Omar Khaled',
              jobTitle: 'Backend Engineer',
              department: 'Engineering',
              email: 'omar.khaled@company.com',
              phone: '+20 100 000 0000',
            ),
          ),
          _section(
            '22 · ProductWarrantyCard',
            const ProductWarrantyCard(
              title: 'Warranty Document',
              fileName: 'warranty.pdf',
              fileSize: '1.2 MB',
              date: '01 Jul 2026',
            ),
          ),
          _section(
            '23 · CustomCheckBox',
            Wrap(
              spacing: 16.w,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _checkboxSelected = !_checkboxSelected),
                  child: CustomCheckBox(isSelected: _checkboxSelected),
                ),
                GestureDetector(
                  onTap: () => setState(() => _checkboxSelected2 = !_checkboxSelected2),
                  child: CustomCheckBox(isSelected: _checkboxSelected2),
                ),
              ],
            ),
          ),
          _section(
            '24 · ChartCard + legend helpers',
            ChartCard(
              title: 'Requests overview',
              child: Column(
                children: [
                  ChartLegendRow(name: 'Approved', amount: '24', color: AppColors.green),
                  ChartLegendRow(name: 'Pending', amount: '6', color: AppColors.yellow),
                ],
              ),
            ),
          ),
          _section(
            '25 · OverallStatsCard',
            OverallStatsCard(
              items: [
                StatItem(
                  label: 'Products',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.products),
                ),
                StatItem(
                  label: 'Orders',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.orders),
                ),
                StatItem(
                  label: 'Warehouses',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.warehouse),
                ),
                StatItem(
                  label: 'Low Stocks',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.lowStock),
                ),
                StatItem(
                  label: 'Suppliers',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.supplier),
                ),
                StatItem(
                  label: 'Requests',
                  value: '11',
                  icon: CardSvg.icon(ChartSvg.request),
                ),
              ],
            ),
          ),
          _section(
            '26 · BarChartCard',
            BarChartCard(
              title: 'Monthly requests',
              bars: [
                ChartData(label: 'Jan', value: 12, color: AppColors.primary),
                ChartData(label: 'Feb', value: 20, color: AppColors.green),
                ChartData(label: 'Mar', value: 8, color: AppColors.orange),
              ],
            ),
          ),
          _section(
            '27 · DonutChartCard',
            DonutChartCard(
              title: 'Demands',
              centerValue: '9K',
              centerLabel: 'Total Product',
              sections: [
                ChartData(
                    label: 'Assets', value: 513, color: AppColors.primary),
                ChartData(
                    label: 'Consumables',
                    value: 320,
                    color: AppColors.colorDarkGrey),
              ],
            ),
          ),
          _section(
            '28 · HorizontalBarChartCard',
            HorizontalBarChartCard(
              title: 'Requests by department',
              bars: [
                ChartData(label: 'Engineering', value: 14, color: AppColors.primary),
                ChartData(label: 'Sales', value: 9, color: AppColors.green),
              ],
            ),
          ),
          _section(
            '29 · GroupedBarChartCard',
            GroupedBarChartCard(
              title: 'Asset condition',
              series: [
                ChartData(label: 'New', value: 0, color: AppColors.green),
                ChartData(label: 'Used', value: 0, color: AppColors.orange),
              ],
              groups: const [
                GroupedBarData(label: 'Laptops', values: [12, 4]),
                GroupedBarData(label: 'Phones', values: [8, 2]),
              ],
            ),
          ),
          _section(
            '30 · AttendanceTilesCard',
            AttendanceTilesCard(
              itemsPerCard: 2,
              items: [
                AttendanceItem(label: 'Present', count: '03', color: AppColors.green),
                AttendanceItem(label: 'Absent', count: '05', color: AppColors.red),
                AttendanceItem(label: 'Late', count: '02', color: AppColors.yellow),
              ],
            ),
          ),
          _section(
            '31 · CustomMultiSelectDropdown',
            CustomMultiSelectDropdown<int>(
              label: 'Skills',
              hint: 'Select skills',
              values: _multiSelectValues,
              items: const [
                MultiSelectDropdownItem(value: 1, label: 'Flutter'),
                MultiSelectDropdownItem(value: 2, label: 'Dart'),
                MultiSelectDropdownItem(value: 3, label: 'Firebase'),
              ],
              onChanged: (values) => setState(() => _multiSelectValues = values),
            ),
          ),
          _section(
            '32 · CustomSvgImage',
            const CustomSvgImage(
              assetPath: 'assets/icons_assets/form_builder_assets/delete_trash_red.svg',
              width: 28,
              height: 28,
            ),
          ),
          _section(
            '33 · hapticController',
            customButton(
              title: 'Trigger haptic feedback',
              width: 220,
              height: 40,
              function: () => hapticController.triggerHapticFeedback(),
            ),
          ),
          _section(
            '34 · AnimatedCustomGridView',
            AnimatedCustomGridView(
              itemCount: 6,
              crossAxisCount: 3,
              mainAxisExtent: 70,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}'),
              ),
            ),
          ),
          _section(
            '35 · DatePicker (single) + AppSearchTextField',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customButton(
                  title: 'Open calendar picker',
                  width: 220,
                  height: 40,
                  function: () => DatePicker().showDatePicker(
                    context,
                    [],
                    DateTime.now(),
                    CalendarDatePicker2Type.single,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    AppSearchTextField(
                      controller: _searchController,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            '36 · UniversalCommentSection',
            SizedBox(
              height: 260.h,
              child: UniversalCommentSection(
                collectionPath: 'preview_comments',
                filterFields: const {},
                currentUserId: 'preview_user',
                collapsedHeight: 260,
              ),
            ),
          ),
          _section(
            '37 · navigateTo / navigateAndFinish',
            customButton(
              title: 'navigateTo demo page',
              width: 220,
              height: 40,
              function: () => navigateTo(
                context,
                Scaffold(
                  appBar: AppBar(title: const Text('Pushed via navigateTo')),
                  body: const Center(child: Text('Hello from navigateTo()')),
                ),
              ),
            ),
          ),
          _section(
            '38 · ResponsiveHelper',
            SizedBox(
              height: 60.h,
              child: ResponsiveHelper(
                mobileWidget: Container(
                  color: AppColors.primary.withOpacity(0.15),
                  alignment: Alignment.center,
                  child: const Text('Mobile layout'),
                ),
                tabletWidget: Container(
                  color: AppColors.green.withOpacity(0.15),
                  alignment: Alignment.center,
                  child: const Text('Tablet layout'),
                ),
              ),
            ),
          ),
          _section(
            '42 · CustomApprovalCycle',
            const CustomApprovalCycle(
              steps: [
                ApprovalStep(
                    name: 'Ahmed Mohammed', title: 'Marketing Manager'),
                ApprovalStep(name: 'Sara Ali', title: 'HR Specialist'),
                ApprovalStep(name: 'Omar Khaled', title: 'Backend Engineer'),
                ApprovalStep(name: 'Mona Hassan', title: 'HR Manager'),
                ApprovalStep(name: 'Youssef Ashraf', title: 'CTO'),
              ],
            ),
          ),
          _section(
            '43 · ModuleInfoCard',
            ModuleInfoCard(
              title: 'Data Management',
              infoRows: const [
                CardInfo(label: 'Owner :', value: 'Amro Handousa'),
                CardInfo(label: 'Creation Date:', value: '28 May 2020'),
              ],
              complianceScore: '-',
              footerLabel: 'Last Update:',
              footerValue: '28 May 2020',
              onMenuTap: () {},
            ),
          ),
          _section(
            '43 · RemovableAvatarChip + LanguageToggle',
            Row(
              children: [
                RemovableAvatarChip(onRemove: () {}),
                SizedBox(width: 8.w),
                RemovableAvatarChip(onRemove: () {}),
                SizedBox(width: 24.w),
                LanguageToggle(
                  selectedIndex: _langIndex,
                  onChanged: (i) => setState(() => _langIndex = i),
                ),
              ],
            ),
          ),
          _section(
            'circle_progress · CircleProgressMaster',
            const SizedBox(height: 60, child: CircleProgressMaster()),
          ),
          // _section(
          //   'loading · showLoadingIndicator / hideLoadingIndicator',
          //   customButton(
          //     title: 'Show loading overlay (2s)',
          //     width: 240,
          //     height: 40,
          //     function: () async {
          //       showLoadingIndicator();
          //       await Future.delayed(const Duration(seconds: 2));
          //       hideLoadingIndicator();
          //     },
          //   ),
          // ),
          _section('39 · customGridButton',
              customGridButton(function: () {}, isSelected: true)),
          _section('40 · customTableButton',
              customTableButton(function: () {}, isSelected: false)),
          _section('41 · ButtonSizing (helper)',
              Text('isMobile: ${ButtonSizing.isMobile(context)} · '
                  'width("Save"): ${ButtonSizing.width(context, title: 'Save')}')),
          _section('44 · CustomValidatedTextFieldMaster',
              CustomValidatedTextFieldMaster(
                  label: 'Email', hint: 'name@company.com', controller: _validatedCtrl)),
          _section('45 · AppDropdown',
              AppDropdown(
                textButton: 'Choose',
                items: const [
                  DropdownMenuItem(value: 'a', child: Text('Option A')),
                  DropdownMenuItem(value: 'b', child: Text('Option B')),
                ],
                onChanged: (v) {},
              )),
          _section('46 · CustomImagePicker',
              CustomImagePicker(onImagePicked: (file) {})),
          _section('47 · CustomSortButton',
              CustomSortButton<String>(
                value: _sortValue,
                items: const ['name', 'date', 'status'],
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _sortValue = v),
              )),
          _section('48 · CurvedArrowPainter',
              SizedBox(
                height: 60,
                child: CustomPaint(
                  painter: CurvedArrowPainter(
                      color: AppColors.primary, isArabic: false),
                  child: const SizedBox(width: double.infinity),
                ),
              )),
          _section('49 · AppMultiSelectDropdownMaster',
              AppMultiSelectDropdownMaster(
                textButton: 'Select many',
                items: const ['Alpha', 'Beta', 'Gamma'],
                selectedItems: _multiSelMaster,
                onChanged: (v) => setState(
                    () => _multiSelMaster = List<String>.from(v as List)),
              )),
          _section('50 · SideFrameMasterServices',
              SizedBox(
                height: 180,
                child: SideFrameMasterServices(
                  titleText: 'Services',
                  secondTitle: 'Details',
                  child: const Center(child: Text('Framed content')),
                ),
              )),
          _section('51 · CustomPopupMenuButton',
              CustomPopupMenuButton(
                title: 'Actions',
                iconPath: 'assets/icons_assets/main_icons_assets/more.svg',
                options: [
                  PopupOption(value: 'edit', label: 'Edit'),
                  PopupOption(value: 'delete', label: 'Delete'),
                ],
                onSelected: (v) {},
                backgroundColor: AppColors.card,
                iconColor: AppColors.text,
              )),
          _section('54 · CrossAxisCountHelperResponsive (helper)',
              Text('columns: '
                  '${CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context)}')),
          _section('55 · buildResponsiveFields',
              buildResponsiveFields(
                context: context,
                left: const Text('Left field'),
                right: const Text('Right field'),
              )),
          _section('56 · AppMultiSelectDropdown',
              AppMultiSelectDropdown(
                textButton: 'Services',
                items: const ['Laptop', 'Badge', 'Parking'],
                selectedItems: _multiSel,
                onChanged: (v) =>
                    setState(() => _multiSel = List<String>.from(v as List)),
              )),
          _section('57 · CustomDialogManager',
              customButton(
                title: 'Show message dialog',
                function: () => CustomDialogManager.showMessage(
                  context: context,
                  lottiePath: 'assets/lottie/success.json',
                  title: 'Saved',
                  subtitle: 'Your changes were stored.',
                ),
              )),
          _section('58 · DefaultSwitchButton',
              DefaultSwitchButton(
                  value: _switchOn,
                  onChanged: (v) => setState(() => _switchOn = v))),
          _section('59 · IntlPhoneField', const IntlPhoneField()),
          _section('60 · showCountryPickerDialog',
              customButton(
                title: 'Pick a country',
                function: () => showCountryPickerDialog(context),
              )),
          _section('61 · CustomColorPickerField',
              CustomColorPickerField(
                label: 'Brand colour',
                color: _pickedColor,
                onColorSelected: (c) => setState(() => _pickedColor = c),
              )),
          _section('62 · FormDateTimeHelper (helper)',
              Text('formatDate: ${FormDateTimeHelper.formatDate(DateTime.now())}\n'
                  'formatTime: ${FormDateTimeHelper.formatTime(DateTime.now())}\n'
                  'getMonthName(3): ${FormDateTimeHelper.getMonthName(3)}')),
          _section('63 · MainCustomButton',
              MainCustomButton(buttonText: 'Continue', onPressed: () {})),
          _section('64 · ResponseDialog',
              customButton(
                title: 'Show response dialog',
                function: () => showDialog(
                  context: context,
                  builder: (_) => const ResponseDialog(
                    title: 'Done',
                    subtitle: 'The request was submitted.',
                    lottieAsset: 'assets/lottie/success.json',
                  ),
                ),
              )),
          _section('65 · CustomDropdownButton2',
              CustomDropdownButton2(
                hint: 'Pick one',
                value: _dd2Value,
                dropdownItems: const ['First', 'Second', 'Third'],
                onChanged: (v) => setState(() => _dd2Value = v),
              )),
          _section('67 · ColumnRequestData',
               ColumnRequestData(
                title: 'Reason',
                isTextField: true,
                hint: 'Why do you need this?',
                isOptional: false,
                isExpanded: false,
              )),
          _section('68 · ConfirmDialog',
              customButton(
                title: 'Show confirm dialog',
                function: () => ConfirmDialog().show(
                  context,
                  title: 'Delete item?',
                  subtitle: 'This cannot be undone.',
                  icon: 'assets/icons_assets/main_icons_assets/delete.svg',
                  onConfirm: () {},
                  onCancel: () {},
                ),
              )),
          _section('69 · CrossAxisCountHelper (helper)',
              Text('columns: '
                  '${CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context)}')),
          _section('70 · CustomAppBar',
              const Text('CustomAppBar — live Firebase-backed app bar; '
                  'not instantiated here to keep the gallery offline.')),
          _section('71 · CustomAppBarMobile',
              SizedBox(
                height: 70,
                child: CustomAppBarMobile(title: 'Profile', showIcon: true),
              )),
          _section('72 · CustomCalendarPicker',
              CustomCalendarPicker(
                calendarType: local_cal.CalendarDatePicker2Type.single,
                selectedDate: _calendarDates,
                selectedDateState: (v) => setState(() => _calendarDates = v),
              )),
          _section('73 · CustomLogOutDialogBox',
              CustomLogOutDialogBox(
                title: 'Sign out?',
                subtitle: 'You will need to log in again.',
                imagePath: 'assets/icons_assets/main_icons_assets/logout.svg',
                backgroundColor: AppColors.card,
                showButtons: true,
              )),
          _section('74 · CustomStackedAvatars',
              const CustomStackedAvatars(
                  avatars: ['Amr Mesbah', 'Sara Ali', 'Omar Hany'])),
          _section('75 · CustomTitleValueWidget',
              const CustomTitleValueWidget(
                  title: 'Department', value: 'Engineering')),
          _section('76 · date_time_in_arabic (helpers)',
              Text('convertToArabicDate: ${convertToArabicDate('12/08/2026')}\n'
                  'formatTimeToArabic: ${formatTimeToArabic('09:30 AM')}\n'
                  'convertNumberToEnglish: ${convertNumberToEnglish('١٢٣')}')),
          _section('77 · DefaultDialog',
              const DefaultDialog(
                  title: 'Heads up', subTitle: 'A default dialog body.')),
          _section('78 · ExpandedContent',
              ExpandedContent(
                  title: 'More details',
                  content: const Text('Hidden content revealed on expand.'))),
          _section('79 · FilterBarItem',
              FilterBarItem(
                isSelected: _filterBarSelected,
                title: 'Pending',
                numberOfItems: 12,
                onTap: () =>
                    setState(() => _filterBarSelected = !_filterBarSelected),
              )),
          _section('80 · FiltersAppBar',
              const FiltersAppBar(imageUrl: '', title: 'Filters')),
          _section('81 · HoverExample',
              const HoverExample(subtitle: 'Hover to reveal a tooltip')),
          _section('82 · ImageGridCard',
              const SizedBox(
                  height: 120,
                  child: ImageGridCard(
                      image: 'assets/images/placeholder.png'))),
          _section('84 · messaging CustomButton',
              msg.CustomButton(buttonText: 'Send', onTap: () {})),
          _section('85 · module page stubs',
              Text('Stub pages: ${stubs.GrcResponsivePage}, '
                  '${stubs.FormResponsivePage}, ${stubs.TasksResponsivePage}, '
                  '${stubs.TrackerPageResponsivePageRefactor}, ${stubs.Settings}')),
          _section('86 · RemovedModulePage',
              const SizedBox(
                  height: 200, child: RemovedModulePage(moduleName: 'Tasks'))),
          _section('87 · ResponsiveCardContent',
              SizedBox(
                height: 80,
                child: ResponsiveCardContent(
                  child: Text('Scales with text size · '
                      'forListCard: ${ResponsiveCardHeight.forListCard(context).toStringAsFixed(1)}'),
                ),
              )),
          _section('88 · StackedAvatars',
              const StackedAvatars(
                  images: ['Amr Mesbah', 'Sara Ali', 'Omar Hany'])),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  /// Shared section wrapper: title + a bordered card holding the demo widget.
  Widget _section(String title, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),

            child: child,
          ),
        ],
      ),
    );
  }
}