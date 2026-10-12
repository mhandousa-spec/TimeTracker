
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/analytics_helper.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/column_chart.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/doughnut_chart.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/text_field_analytics.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/color_generator.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';

class AnalyticsMainWidget extends StatefulWidget {
  const AnalyticsMainWidget({required this.data, super.key});
  final AnalyticsEntity data;

  @override
  State<AnalyticsMainWidget> createState() => _AnalyticsMainWidgetState();
}

class _AnalyticsMainWidgetState extends State<AnalyticsMainWidget> {
  @override
  Widget build(BuildContext context) {
    // Form bug report #33/#34/#38: chart questions render the app's shared
    // chart cards (core/custom/27 donut, core/custom/26 bar) instead of the
    // local Syncfusion charts. Text answers keep the original card.
    if (AnalyticsHelper.doughnutChartAnalytics(widget.data.type)) {
      return _buildDonutCard();
    }
    if (AnalyticsHelper.barChartAnalytics(widget.data.type) &&
        widget.data.isAggregated != false) {
      return _buildBarCard();
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), verticalSpace(16), _buildBody()],
      ),
    );
  }

  Widget _buildHeader() {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              spacing: 10.h,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          widget.data.type.icon,
                          height: 12.sp,
                          width: 12.sp,
                          color: AppColors.black,
                        ),
                      ),
                      horizontalSpace(5),
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize('${widget.data.title}'),
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryBlack)
                              .copyWith(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: Row(
                    children: [
                      Text(
                        isTablet ? S.of(context).totalResponse : S.of(context).total2,
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      ),
                      Text(
                        '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                        style: StyleText.fontSize14Weight600,
                      )
                    ],
                  ),
                ),
                if (isTablet) _aggregationButtonBuilder()
              ],
            ),
            if (!isTablet) verticalSpace(10),
            if (!isTablet) _aggregationButtonBuilder()
          ],
        );
      },
    );
  }

  /// Palette for chart segments / bars, one colour per option.
  List<Color> _chartColors(int count) {
    final colors = ColorGenerator.generateColors(count);
    while (colors.length < count) {
      colors.add(AppColors.grey);
    }
    return colors;
  }

  /// "Total response x/y" badge + the aggregation toggle, shown in the chart
  /// card header (ChartCard.trailing).
  Widget _buildChartTrailing() {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.w,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTablet
                        ? S.of(context).totalResponse
                        : S.of(context).total2,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryBlack),
                  ),
                  Text(
                    '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                    style: StyleText.fontSize14Weight600,
                  ),
                ],
              ),
            ),
            if (widget.data.isAggregated != null) _aggregationButtonBuilder(),
          ],
        );
      },
    );
  }

  /// #33/#38: donut via core DonutChartCard. Only options that were actually
  /// picked become ring segments, so no "0%" labels are drawn outside the
  /// ring and a single answer fills the ring at 100%, centred.
  Widget _buildDonutCard() {
    final data = widget.data.chartData ?? const <FormChartData>[];
    final colors = _chartColors(data.length);
    final sections = <ChartData>[
      for (int i = 0; i < data.length; i++)
        if (data[i].values > 0)
          ChartData(label: data[i].text, value: data[i].values, color: colors[i]),
    ];
    return DonutChartCard(
      title: FormatHelper.capitalize(widget.data.title),
      dotIcon: widget.data.type.icon,
      trailing: _buildChartTrailing(),
      width: double.infinity,
      sections: sections,
      centerValue: widget.data.getTotalChartSubmissions.formatNumber(),
      centerLabel: S.of(context).total,
      chartSize: 160,
      // Bug report p.5: keep each count next to its label, not by the ring.
      compactLegend: true,
    );
  }

  /// #34: vertical bars via core BarChartCard.
  Widget _buildBarCard() {
    final data = widget.data.chartData ?? const <FormChartData>[];
    return BarChartCard(
      title: FormatHelper.capitalize(widget.data.title),
      dotIcon: widget.data.type.icon,
      trailing: _buildChartTrailing(),
      width: double.infinity,
      bars: [
        for (final d in data) ChartData(label: d.text, value: d.values),
      ],
    );
  }

  Row _aggregationButtonBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.data.isAggregated != null)
          customButton(
            function: () {
              setState(() {
                widget.data.isAggregated = !widget.data.isAggregated!;
              });
            },
            title: (widget.data.isAggregated == false)
                ? S.of(context).aggregated
                : S.of(context).unaggregated,
          )
      ],
    );
  }

  Widget _buildBody() {
    if (AnalyticsHelper.doughnutChartAnalytics(widget.data.type)) {
      return DoughnutChart(
        data: widget.data.chartData!,
        total: widget.data.getTotalChartSubmissions,
      );
    }
    if (AnalyticsHelper.answerAnalytics(widget.data.type) &&
        widget.data.isAggregated != true) {
      return TextFieldAnalytics(entity: widget.data);
    }
    if (AnalyticsHelper.barChartAnalytics(widget.data.type) &&
        widget.data.isAggregated != false) {
      return ColumnChart(data: widget.data.chartData!);
    }

    return Container();
  }
}