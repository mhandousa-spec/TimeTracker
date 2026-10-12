/// Module: messaging / connections / presentation/ui/widgets/connectionless_tile.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connectionless_tile.dart
/// Purpose: Connectionless tile — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Nada Mohammed
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the community new chats tile used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../domain/entities/single_connection_entity.dart';
import '../../controller/connections_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ConnectionlessTile extends StatelessWidget {
  final SingleConnectionEntity chatModel;

  const ConnectionlessTile({
    super.key,
    required this.chatModel,
  });

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return GestureDetector(
      onTap: () async {
        // DI via Bloc (team decision) — read the cubit from the widget tree
        // instead of GetX service-location (§3/§17).
        final connectionsCubit = context.read<ConnectionsCubit>();
        await connectionsCubit.createNewConnection(
            currentUser: connectionsCubit.currentUser,
            newConnectionUser: chatModel.toBaseMessagingInterface());
        connectionsCubit.selectConnection(chatModel, context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(4.r), // bug report #3: cards use 4.r
        ),
        padding: EdgeInsetsDirectional.all(8.sp),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateTimeHelper.formatTime(
                      chatModel.lastMessageTime!.toDate()),
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.inputColor)
                      .copyWith(fontSize: 10.sp, height: 1.3),
                ),
              ],
            ),
            Row(
              children: [
                // Bug report #9: a user with no photo showed a blank white
                // circle. Same rule as ConnectionTile — network photo when
                // there is one, otherwise the default male.svg.
                ClipOval(
                  child: chatModel.imageUri.contains('http')
                      ? Image.network(
                          chatModel.imageUri,
                          fit: BoxFit.cover,
                          width: 40.r,
                          height: 40.r,
                          errorBuilder: (_, __, ___) => CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/assets_male.svg",
                            width: 40.r,
                            height: 40.r,
                            fit: BoxFit.fill,
                          ),
                        )
                      : CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/assets_male.svg",
                          width: 40.r,
                          height: 40.r,
                          fit: BoxFit.fill,
                        ),
                ),
                horizontalSpace(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocalizedTextHelper.formatString(
                          secondaryLanguageText:
                              chatModel.secondaryLanguageName,
                          primaryLanguageText: chatModel.primaryLanguageName,
                        ),
                        style: StyleText.fontSize14Weight500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Bug report #9: was a hard-coded "Leader" for
                      // everyone — show the person's real job title.
                      Text(
                        (chatModel.primaryLanguageSubInfo?.isNotEmpty ?? false)
                            ? LocalizedTextHelper.formatString(
                                secondaryLanguageText:
                                    chatModel.secondaryLanguageSubInfo,
                                primaryLanguageText:
                                    chatModel.primaryLanguageSubInfo!,
                              )
                            : '-',
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
