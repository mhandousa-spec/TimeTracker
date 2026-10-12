// ******************* FILE INFO *******************
// File Name: sla_screen_mobile_sections
// Description: SLA section builders extracted from sla_screen_mobile (§17).
// Module: services_management_module / presentation / s12_create_notification_mobile / ui / services_management_module
// *************************************************
part of 'sla_screen_mobile.dart';

extension SlaSections on _SlaScreenMobileState {
  Widget _buildSectionTwo({
    required String title,
    required List<String> items,
    bool showSLA = false,
    bool showSwitch = false,
    TextEditingController? controller,
    bool showError = false,
    void Function(String)? onChanged,
    Map<String, bool>? switches,
    required Map<int, bool> switchStates,
    void Function(String, bool)? onToggleSwitch,
    required void Function(int, bool) onToggleIndexSwitch,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isChecked = _sectionCheckboxes[title] ?? true;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _sectionCheckboxes[title] = !isChecked),
          child: Row(
            children: [
              // Services mobile QA p.15: this checkbox was a different SVG
              // (smaller, white tick) from the two sections above it. Same
              // CustomCheckBox, size and gap as "Notify Service Requester".
              CustomCheckBox(
                isSelected: isChecked,
                size: 20.sp,
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  title,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) {
          final itemChecked = switches?[item] ?? false;
          return Padding(
            padding: EdgeInsets.only(left: 30.sp, top: 6.sp, right: 30.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• $item',
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const Spacer(),
                if (switches != null && switches.containsKey(item))
                  GestureDetector(
                    onTap: () => onToggleSwitch?.call(item, !itemChecked),
                    child: SvgPicture.asset(
                      itemChecked
                          ? 'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg'
                          : 'assets/icons_assets/main_icons_assets/checkbox_empty_outline.svg',
                      width: 22.sp,
                      height: 22.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (showSLA) ...[
          Padding(
            padding: EdgeInsets.only(
                left: isArabic ? 0 : 26.sp,
                top: 15.sp,
                right: isArabic ? 26.sp : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FormatHelper.capitalize(
                      S.of(context).WhenServiceRequestedAndApproved),
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      S.of(context).ManagerIfItRequiresApproval,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: () => onToggleSwitch?.call(
                        S.of(context).WhenServiceRequestedAndApproved,
                        !(switches?[S
                                .of(context)
                                .WhenServiceRequestedAndApproved] ??
                            false),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 0.sp),
                        child: FlutterSwitch(
                          activeColor: AppColors.secondaryPrimary,
                          height: 22.sp,
                          padding: 3.sp,
                          width: 38.sp,
                          borderRadius: 20.sp,
                          toggleSize: 16.sp,
                          // QA p.3: the off track was switchOff at 16% — white knob on a
                          // near-white track, so the switch was invisible. Same visible grey
                          // off track as Limit Service Availability / Requires Approvals.
                          inactiveColor: AppColors.lighterGrey,
                          value: switchStates[0] ?? false,
                          onToggle: (val) {
                            setState(() {
                              switchStates[0] = val;
                            });
                            onToggleIndexSwitch(0, val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.only(left: 26.sp, right: 29.sp),
            child: Row(
              children: [
                Text(
                  FormatHelper.capitalize(
                      S.of(context).whenServiceStatusChanges),
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(width: 10.sp),
                GestureDetector(
                  onTap: () => onToggleSwitch?.call(
                    FormatHelper.capitalize(
                        "When Service SLA Is About To Be Breached"),
                    !(switches?[FormatHelper.capitalize(
                            "When Service SLA Is About To Be Breached")] ??
                        false),
                  ),
                  child: FlutterSwitch(
                    activeColor: AppColors.secondaryPrimary,
                    height: 22.sp,
                    padding: 3.sp,
                    width: 38.sp,
                    borderRadius: 20.sp,
                    toggleSize: 16.sp,
                    // QA p.3: the off track was switchOff at 16% — white knob on a
                    // near-white track, so the switch was invisible. Same visible grey
                    // off track as Limit Service Availability / Requires Approvals.
                    inactiveColor: AppColors.lighterGrey,
                    value: switchStates[1] ?? false,
                    onToggle: (val) {
                      setState(() {
                        switchStates[1] = val;
                      });
                      onToggleIndexSwitch(1, val);
                    },
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < dynamicSlaControllers.length; i++)
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                if (i != 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.5.sp),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          dynamicSlaControllers.removeAt(i);
                        });
                      },
                      child: Container(
                        width: 16.sp,
                        height: 16.sp,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Icon(Icons.remove,
                                size: 14.sp, color: AppColors.white)),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      left: isArabic ? 0 : 24.sp,
                      top: 8.h,
                      right: isArabic ? 24.sp : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${S.of(context).whenServiceSlaIsAboutToBeBreached}",
                        style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(
                          fontSize: isArabic ? 10.sp : 8.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      CustomTextField(
                        onlyDigits: true,
                        width: 100.w,
                        hint: S.of(context).EnterPercentage,

                        fillColor:AppColors.background,
                        controller: dynamicSlaControllers[i],
                        onChanged: (_) => setState(() {}),
                        height: 28.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text('%',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.text,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(height: 10.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.sp),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  dynamicSlaControllers.add(TextEditingController());
                });
              },
              child: Container(
                width: 104.sp,
                height: 28.sp,
                padding:
                    EdgeInsets.symmetric(vertical: 6.sp, horizontal: 7.5.sp),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                        "assets/icons_assets/main_icons_assets/plus.svg",
                        width: 12.sp,
                        height: 12.sp,
                        fit: BoxFit.scaleDown,
                        // QA p.3: the "+" was drawn in its own dark grey on
                        // the black button, so it could not be seen.
                        colorFilter: ColorFilter.mode(
                            AppColors.white, BlendMode.srcIn),
                        semanticsLabel: 'Dart Logo',
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      FormatHelper.capitalize(S.of(context).notifications),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    bool showSLA = false,
    TextEditingController? controller,
    bool showError = false,
    void Function(String)? onChanged,
    Map<String, bool>? switches,
    void Function(String, bool)? onToggleSwitch,
  }) {
    final isChecked = _sectionCheckboxes[title] ?? true;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _sectionCheckboxes[title] = !isChecked),
          child: Row(
            children: [
              CustomCheckBox(
                isSelected: isChecked,
                size: 20.sp,
              ),
              // QA p.15: 6 let the box touch the "N" of the title.
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(title),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) {
          final isItemChecked = switches?[item] ?? false;
          return Padding(
            padding: EdgeInsets.only(
                left: isArabic ? 0 : 30.sp,
                top: 0.sp,
                bottom: 7.sp,
                right: isArabic ? 30.sp : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• $item',
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const Spacer(),
                if (switches != null && switches.containsKey(item))
                  GestureDetector(
                    onTap: () => onToggleSwitch?.call(item, !isItemChecked),
                    child: SvgPicture.asset(
                      isItemChecked
                          ? 'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg'
                          : 'assets/icons_assets/main_icons_assets/checkbox_empty_outline.svg',
                      width: 22.w,
                      height: 22.h,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (showSLA) ...[
          for (int i = 0; i < dynamicSlaTwoControllers.length; i++)
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                if (i != 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.5.sp),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          dynamicSlaTwoControllers.removeAt(i);
                        });
                      },
                      child: Container(
                        width: 16.sp,
                        height: 16.sp,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.remove,
                            size: 14.sp, color: AppColors.white),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      left: isArabic ? 0 : 25.sp,
                      top: 8.h,
                      right: isArabic ? 25.sp : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${S.of(context).whenServiceSlaIsAboutToBeBreached}",
                        style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(
                          fontSize: isArabic ? 10.sp : 8.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(width: 4.sp),
                      CustomTextField(
                        onlyDigits: true,
                        hint: S.of(context).EnterPercentage,
                        width: 102.w,
                        valueStyle: StyleText.fontSize14Weight500.copyWith(
                          fontSize: 12.sp
                        ),
                        fillColor: AppColors.background,
                        controller: dynamicSlaTwoControllers[i],
                        onChanged: (_) => setState(() {}),
                        height: 28.sp,
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        '%',
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(height: 10.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.sp),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  dynamicSlaTwoControllers.add(TextEditingController());
                });
              },
              child: Container(
                width: 104.sp,
                height: 28.sp,
                padding:
                    EdgeInsets.symmetric(vertical: 6.sp, horizontal: 7.5.sp),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                        "assets/icons_assets/main_icons_assets/plus.svg",
                        width: 12.sp,
                        height: 12.sp,
                        fit: BoxFit.scaleDown,
                        // QA p.3: the "+" was drawn in its own dark grey on
                        // the black button, so it could not be seen.
                        colorFilter: ColorFilter.mode(
                            AppColors.white, BlendMode.srcIn),
                        semanticsLabel: 'Dart Logo',
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      FormatHelper.capitalize(S.of(context).notifications),
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 20.h),
      ],
    );
  }
}
