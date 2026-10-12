/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: open_edit_dialog.dart
/// Purpose: Declares `OpenEditDialog`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';

import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class OpenEditDialog {
  show({required BuildContext context, required HomeComponentModel model}) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;
    return showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider<AppHomeCubit>.value(
            value: context.read<AppHomeCubit>(),
            child: Dialog(
                backgroundColor: AppColors.transparent,
                child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 50.sp, horizontal: isTablet ? 100.sp : 20.sp),
                    child:
                        StandardContainer(child: _getChild(model, context)))),
          );
        });
  }

  Widget _getChild(HomeComponentModel model, BuildContext context) {
    switch (model.component) {
      default:
        return const SizedBox();
    }
  }
}
