/// Module: messaging / chat / presentation/ui/pages/all_chat_view_tablet.dart
// by : mohamed ashraf
// date : 19/9/2024

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/chat/chat_model.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/models/message/message_model.dart';
import '../widgets/all_chats_tile.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class AllChatViewTablet extends StatelessWidget {
  final List<MessageModel> message;

  const AllChatViewTablet({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablet;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<CommunityCubit>().resetSelectedChats();
        }
      },
      child: SizedBox(
        width: isTablet ? 0.8.sw : double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        child: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final cubit = context.read<CommunityCubit>();

            // Extract state values
            final frequentlyContacted = state is CommunityLoaded
                ? state.frequentlyContacted
                : <ChatModel>[];
            final allChats = state is CommunityLoaded
                ? state.allChats
                : <ChatModel>[];
            final isSelectedChat = state is CommunityLoaded
                ? state.isSelectedChat
                : false;

            return Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    verticalSpace(26.h),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 24,
                              )),
                          horizontalSpace(8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.of(context).forwardTo,
                                    style: StyleText.fontSize18Weight500),
                                GestureDetector(
                                  onTap: () {
                                    if (isSelectedChat) {
                                      cubit.forwardMessage(message, context);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.forward,
                                    width: 24.w,
                                    height: 24.h,
                                    color: isSelectedChat
                                        ? AppColors.secondaryPrimary
                                        : AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(17.h),
                    CustomTextField(
                      hint: S.of(context).search,
                      fillColor: AppColors.background,
                      hintStyle: isTablet
                          ? StyleText.fontSize23Weight500.copyWith(color: AppColors.lightGrey)
                          : StyleText.fontSize16Weight500.copyWith(color: AppColors.lightGrey),
                      controller: cubit.searchController,
                      prefixIcon: SvgPicture.asset(
                        AppAssets.search,
                      ),),
                    verticalSpace(16.h),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        S.of(context).frequentlyContacted,
                        style: StyleText.fontSize14Weight500,
                      ),
                    ),
                    verticalSpace(8.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.isDark ?? false
                            ? AppColors.field
                            : AppColors.background,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: frequentlyContacted.length,
                        itemBuilder: (context, index) {
                          return AllChatsTile(
                            chat: frequentlyContacted[index],
                          );
                        },
                      ),
                    ),
                    verticalSpace(isTablet ? 24 : 16),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'Recently Contacted',
                        style: StyleText.fontSize14Weight500,
                      ),
                    ),
                    verticalSpace(8.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.isDark ?? false
                            ? AppColors.field
                            : AppColors.background,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allChats.length,
                        itemBuilder: (context, index) {
                          return AllChatsTile(
                            chat: allChats[index],
                          );
                        },
                      ),
                    ),
                    verticalSpace(24.h),
                    // BLoC version of the commented button code:
                    // AppDefaultButton(
                    //   width: double.infinity,
                    //   textColor: isSelectedChat
                    //       ? AppColors.base
                    //       : AppColors.darkGrey,
                    //   color: isSelectedChat
                    //       ? AppColors.primary
                    //       : AppColors.moreLightGrey,
                    //   text: 'Send',
                    //   style: StyleText.fontSize18Weight500,
                    //   onPressed: () {
                    //     if (isSelectedChat) {
                    //       cubit.forwardMessage(message, context);
                    //       Navigator.of(context).pop();
                    //     }
                    //   },
                    // ,),
                    // verticalSpace(16.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}