// ****************** FILE INFO ******************
// File Name: crm_add_deal_step3_progress.dart
// Purpose: Step 3 (Progress Per Stage with Edit Mode) of the Add Deal wizard
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class StageProgressConfig {
  final String stageKey;
  final String titleEn;
  final String titleAr;
  String? selectedRequirement;
  final TextEditingController reqEnController = TextEditingController();
  final TextEditingController reqArController = TextEditingController();
  bool showCustomField;

  StageProgressConfig({
    required this.stageKey,
    required this.titleEn,
    required this.titleAr,
    this.selectedRequirement,
    this.showCustomField = false,
  });

  void dispose() {
    reqEnController.dispose();
    reqArController.dispose();
  }
}

class CrmAddDealStep3Progress extends StatefulWidget {
  final bool editMode;
  final ValueChanged<bool> onEditModeChanged;

  const CrmAddDealStep3Progress({
    super.key,
    required this.editMode,
    required this.onEditModeChanged,
  });

  @override
  State<CrmAddDealStep3Progress> createState() =>
      _CrmAddDealStep3ProgressState();
}

class _CrmAddDealStep3ProgressState extends State<CrmAddDealStep3Progress> {
  static const List<String> _requirementOptions = <String>[
    'Client Needs Assessment',
    'Budget Confirmation',
    'Technical Proposal Sent',
    'Stakeholder Approval',
    'Contract Draft Review',
    'Final Signature',
  ];

  late final List<StageProgressConfig> _stageConfigs;

  @override
  void initState() {
    super.initState();
    _stageConfigs = <StageProgressConfig>[
      StageProgressConfig(
        stageKey: 'new',
        titleEn: 'Stage New',
        titleAr: 'المرحلة: جديدة',
        showCustomField: true,
      ),
      StageProgressConfig(
        stageKey: 'discovery',
        titleEn: 'Stage Discovery',
        titleAr: 'المرحلة: استكشاف',
      ),
      StageProgressConfig(
        stageKey: 'qualified',
        titleEn: 'Stage Qualified',
        titleAr: 'المرحلة: مؤهلة',
      ),
      StageProgressConfig(
        stageKey: 'proposal',
        titleEn: 'Stage Proposal',
        titleAr: 'المرحلة: العرض',
      ),
    ];
  }

  @override
  void dispose() {
    for (final StageProgressConfig config in _stageConfigs) {
      config.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Settings Card: Edit Mode ──────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Settings',
            arabicName: 'الإعدادات',
          ),
          showHideToggle: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Edit Mode',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              DefaultSwitchButton(
                value: widget.editMode,
                onChanged: widget.onEditModeChanged,
              ),
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // ── Stage Sections ───────────────────────────────────────────────────
        for (int i = 0; i < _stageConfigs.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 24.sp),
          _buildStageSection(context, _stageConfigs[i]),
        ],
      ],
    );
  }

  Widget _buildStageSection(
    BuildContext context,
    StageProgressConfig config,
  ) {
    final String title = FormatHelper.localizedString(
      englishName: config.titleEn,
      arabicName: config.titleAr,
    );

    return CrmSectionCard(
      title: title,
      showHideToggle: true,
      child: widget.editMode
          ? _buildEditModeContent(context, config)
          : _buildViewModeContent(context),
    );
  }

  /// View Mode: Displays a clean 5-column bulleted grid of "Required" items (Screenshot 1)
  Widget _buildViewModeContent(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 800
            ? 5
            : (constraints.maxWidth > 500 ? 3 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 32.sp,
            crossAxisSpacing: 8.sp,
            mainAxisSpacing: 8.sp,
          ),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 4.sp,
                  height: 4.sp,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    shape: BoxShape.rectangle,
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  'Required',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Edit Mode: Displays requirement dropdown, optional textfields, and + Required button (Screenshots 2 & 3)
  Widget _buildEditModeContent(
    BuildContext context,
    StageProgressConfig config,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Required Dropdown in half-row
        buildResponsiveFields(
          context: context,
          left: CustomDropdown<String>(
            label: 'Required',
            hint: 'Choose',
            value: config.selectedRequirement,
            items: _requirementOptions
                .map((String r) => DropdownItem<String>(value: r, label: r))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) =>
                setState(() => config.selectedRequirement = val),
          ),
          right: const SizedBox.shrink(),
        ),

        // Optional Bilingual Textfields Pair (when + Required is clicked / active)
        if (config.showCustomField) ...<Widget>[
          SizedBox(height: 16.sp),
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              label: 'Required',
              hint: 'Text Here',
              controller: config.reqEnController,
              fillColor: AppColors.background,
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                label: 'مطلوب',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                controller: config.reqArController,
                fillColor: AppColors.background,
              ),
            ),
          ),
        ],

        SizedBox(height: 16.sp),

        // + Required Button
        InkWell(
          onTap: () {
            setState(() {
              config.showCustomField = !config.showCustomField;
            });
          },
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '+ Required',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
