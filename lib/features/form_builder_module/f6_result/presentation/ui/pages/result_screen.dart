import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/analytics_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/user_screen.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/switch_card_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initialize the ResultCubit with the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultCubit>().initialize(widget.form, this);
    });
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — one header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The phone title was also wrong: it said "Fill Out Form" on the
    // Result screen. The crumbs move out of the ResultLoaded branch so the
    // header survives the loading and error states.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context)
            .detailsOfTitle(_getTitle(widget.form.formHeadModel, context)),
        thirdTitle: S.of(context).result,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        child: SingleChildScrollView(
        child: Container(
          child: BlocBuilder<ResultCubit, ResultState>(
            builder: (context, state) {
              if (state is ResultLoading) {
                return const CircleProgressMaster();
              }

              if (state is ResultError) {
                return Center(child: Text(state.message));
              }

              if (state is! ResultLoaded) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(15),
                  const SwitchCardWidget(),
                  _getCardScreen(state),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }
    return formHeadModel.title ?? '';
  }

  Widget _getCardScreen(ResultLoaded state) {
    if (state.isUser) {
      return UserScreen(form: widget.form);
    } else {
      return AnalyticsScreen();
    }
  }
}