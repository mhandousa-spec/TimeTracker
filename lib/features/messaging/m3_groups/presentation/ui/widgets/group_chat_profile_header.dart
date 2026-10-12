// Date: 5/9/2024
// By: Mohamed Ashraf
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a widget that contains the chat profile header used in the chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../../m1_chat/presentation/controller/message_controller.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class GroupChatProfileHeader extends StatelessWidget {
  final String title;
  final String countMember;
  const GroupChatProfileHeader({
    super.key,
    required this.title,
    required this.countMember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ContextExtension(context).isTablett ? 24.w : 16.w,
      ),
      child: Expanded(
        child: Row(
          children: [
            Hero(
              tag: 'profileChat',
              child: Container(
                height: 60.h,
                width: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: getChatProfileImage(context) != null
                      ? DecorationImage(
                    fit: BoxFit.cover,
                    image: appImageProvider(
                      getChatProfileImage(context),
                    ),
                  )
                      : DecorationImage(
                      fit: BoxFit.cover,
                      image: getChatProfileImage(context) != null
                          ? appImageProvider(
                        getChatProfileImage(context),
                      )
                          : appImageProvider(AppAssets.profile)),
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ContextExtension(context).isTablett
                        ? StyleText.fontSize23Weight500
                        : StyleText.fontSize18Weight600,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          //alignment: AlignmentDirectional.s,
                          children: [
                            CircleAvatar(
                              backgroundImage: appImageProvider(AppAssets.user),
                              radius: 15,
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 20),
                              child: CircleAvatar(
                                backgroundImage: appImageProvider(AppAssets.user3),
                                radius: 15,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 40),
                              child: CircleAvatar(
                                  backgroundImage: appImageProvider(AppAssets.user2),
                                  radius: 15),
                            ),
                            Padding(
                              padding:
                              const EdgeInsetsDirectional.only(start: 60),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 15,
                                child: Text(
                                  countMember,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                    fontSize: ContextExtension(context).isTablett ? 13 : 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getChatProfileImage(BuildContext context) {
    // Access otherConnectionSide through state (DI via Bloc — §3).
    return context.read<MasterChatCubit>().state.otherConnectionSide?.imageUri;
  }
}