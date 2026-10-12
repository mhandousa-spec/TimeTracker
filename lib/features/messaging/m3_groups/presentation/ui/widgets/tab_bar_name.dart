import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m1_chat/presentation/controller/message_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

// Mohamed Ashraf work
class TabBarNameGroupProfile extends StatelessWidget {
  const TabBarNameGroupProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded) {
          return const SizedBox();
        }

        final messageCubit = context.read<MessageCubit>();

        return TabBar(
            padding: EdgeInsetsDirectional.only(
              start: ContextExtension(context).isTablett ? 24.w : 16.w,
            ),
            indicatorPadding: EdgeInsetsDirectional.only(end: 67.w),
            labelPadding: EdgeInsetsDirectional.only(
              end: ContextExtension(context).isTablett ? 68.5.w : 25.w,
            ),
            isScrollable: true,
            splashFactory: NoSplash.splashFactory,
            indicatorColor: AppColors.secondaryPrimary,
            tabAlignment: TabAlignment.center,
            unselectedLabelStyle: (ContextExtension(context).isTablet
                ? StyleText.fontSize18Weight500.copyWith(color: AppColors.secondaryBlack)
                : StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack)),
            labelStyle: (ContextExtension(context).isTablet
                ? StyleText.fontSize18Weight500.copyWith(color: AppColors.secondaryPrimary)
                : StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryPrimary)),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent,
            controller: messageCubit.tabGroupController,
            tabs: messageCubit.groupInfoTabs.map((text) {
              return Tab(text: text);
            }).toList(),
          );
      },
    );
  }
}