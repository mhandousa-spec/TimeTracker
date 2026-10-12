
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/address_analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/address_analytics_table_builder.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/text_field_analytics.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/column_chart.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class AddressAnalyticsWidget extends StatefulWidget {
  const AddressAnalyticsWidget({required this.data, super.key});
  final AddressAnalyticsEntity data;

  @override
  State<AddressAnalyticsWidget> createState() =>
      _AddressAnalyticsWidgetState();
}

class _AddressAnalyticsWidgetState extends State<AddressAnalyticsWidget> {
  bool isShowAggregated = false;
  bool isShowTabulated = false;

  @override
  Widget build(BuildContext context) {
    if (isShowAggregated) {
      return Column(
        spacing: 10.h,
        children: [
          for (int chartIndex = 0;
          chartIndex < widget.data.addressItems!.length;
          chartIndex++)
            _buildChartGraph(chartIndex),
        ],
      );
    } else if (isShowTabulated) {
      return _tableWidget();
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            verticalSpace(10),
            TextFieldAnalytics(entity: widget.data)
          ],
        ),
      );
    }
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
              spacing: 10.w,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          widget.data.type.icon,
                          height: 16.sp,
                          width: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      horizontalSpace(5),
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize('${widget.data.title}'),
                          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
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
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                      ),
                      Text(
                        '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                        style: StyleText.fontSize14Weight600,
                      )
                    ],
                  ),
                ),
                if (isTablet) _buildHeaderActions()
              ],
            ),
            if (!isTablet) verticalSpace(10),
            if (!isTablet) _buildHeaderActions()
          ],
        );
      },
    );
  }

  Row _buildHeaderActions() {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customButton(
          function: () {
            setState(() {
              isShowAggregated = true;
              isShowTabulated = false;
              widget.data.isAggregated = !widget.data.isAggregated!;
            });
          },
          title: S.of(context).aggregated,
        ),
        if (isTablet) horizontalSpace(10),
        if (isTablet)
          customButton(
            function: () {
              setState(() {
                isShowAggregated = false;
                isShowTabulated = !isShowTabulated;
              });
            },
            title: (isShowTabulated) ? S.of(context).untabulated : S.of(context).tabulated,
          )
      ],
    );
  }

  Widget _buildChartGraph(int chartIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(chartIndex),
          verticalSpace(10),
          ColumnChart(data: widget.data.addressChartData![chartIndex])
        ],
      ),
    );
  }

  Widget _buildChartHeader(int chartIndex) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              spacing: 10.w,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          widget.data.type.icon,
                          height: 16.sp,
                          width: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      horizontalSpace(5),
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize(
                              '${widget.data.addressItems![chartIndex]}'),
                          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                      ),
                      Text(
                        '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                        style: StyleText.fontSize14Weight600,
                      )
                    ],
                  ),
                ),
                if (isTablet) _buildChartActions(chartIndex)
              ],
            ),
            if (!isTablet) verticalSpace(10),
            if (!isTablet) _buildChartActions(chartIndex),
          ],
        );
      },
    );
  }

  Widget _tableWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          verticalSpace(10),
          DefaultDataTable(
            columns: widget.data.DataColumns(),
            rows: widget.data.DataCells(),
          )
        ],
      ),
    );
  }

  Widget _buildChartActions(int chartIndex) {
    if (chartIndex == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          customButton(
            function: () {
              setState(() {
                isShowAggregated = false;
                widget.data.isAggregated = !widget.data.isAggregated!;
              });
            },
            title: S.of(context).unaggregated,
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}