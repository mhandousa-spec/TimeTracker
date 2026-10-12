/// Module: messaging / chat / presentation/ui/widgets/bubbles/shared_location_contact_bubbles.dart
/// Purpose: Bubbles for shared LOCATION and CONTACT messages (bug report #23).
///          Both payloads travel as JSON in Message_Content — see
///          LocationPayload / ContactPayload in new_message_content_entity.dart.

part of '../../pages/chat_mobile_view.dart';

/// WhatsApp-style location card: pin, address, coordinates; tap opens the
/// spot in Google Maps (browser on desktop, Maps app on phones).
class SharedLocationBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const SharedLocationBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final LocationPayload? location =
        LocationPayload.tryDecode(messageModel.messageContent);
    final bool isMe = messageModel.isMe;
    final bool isAr = context.isArabic;
    final Color textColor = isMe ? AppColors.textButton : AppColors.text;

    return DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: location == null
          ? Text(isAr ? 'موقع غير صالح' : 'Invalid location',
              style: StyleText.fontSize14Weight400.copyWith(color: textColor))
          : InkWell(
              onTap: () async {
                final Uri uri = Uri.parse(location.googleMapsUrl);
                debugPrint('[LocationBubble] opening $uri');
                final bool ok = await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
                if (!ok) debugPrint('[LocationBubble] ✗ could not open $uri');
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 110.h,
                      width: 220.w,
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons_assets/messaging_assets/location_svg.svg',
                        width: 40.sp,
                        height: 40.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      (location.address?.isNotEmpty ?? false)
                          ? location.address!
                          : (isAr ? 'الموقع المشترك' : 'Shared location'),
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: textColor),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${location.latitude.toStringAsFixed(5)}, '
                      '${location.longitude.toStringAsFixed(5)}',
                      textDirection: TextDirection.ltr,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: textColor.withOpacity(0.7)),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isAr ? 'فتح في الخرائط' : 'Open in Maps',
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: isMe ? AppColors.textButton : AppColors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Contact card for a colleague shared from the app directory, with a
/// "Message" button that opens a chat with them.
class SharedContactBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const SharedContactBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ContactPayload? contact =
        ContactPayload.tryDecode(messageModel.messageContent);
    final bool isMe = messageModel.isMe;
    final bool isAr = context.isArabic;
    final Color textColor = isMe ? AppColors.textButton : AppColors.text;

    if (contact == null) {
      return DefaultBubble(
        index: index,
        isGroup: isGroup,
        messageModel: messageModel,
        content: Text(isAr ? 'جهة اتصال غير صالحة' : 'Invalid contact',
            style: StyleText.fontSize14Weight400.copyWith(color: textColor)),
      );
    }

    // Bug report p.19: the full name, capitalised ("ibrahim al-shamm…" →
    // "Ibrahim Al-shammari"), wrapping instead of being cut with an ellipsis.
    final String name = FormatHelper.capitalize(
        isAr && (contact.nameAr?.isNotEmpty ?? false)
            ? contact.nameAr!
            : contact.name);
    final String? rawJob = isAr && (contact.jobTitleAr?.isNotEmpty ?? false)
        ? contact.jobTitleAr
        : contact.jobTitle;
    final String? job = rawJob == null ? null : FormatHelper.capitalize(rawJob);
    final String image = contact.imageUri ?? '';

    return DefaultBubble(
      index: index,
      isGroup: isGroup,
      messageModel: messageModel,
      content: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: image.startsWith('http')
                      ? Image.network(image,
                          width: 36.r,
                          height: 36.r,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _maleAvatar())
                      : _maleAvatar(),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          softWrap: true,
                          style: StyleText.fontSize14Weight600
                              .copyWith(color: textColor)),
                      if (job != null && job.isNotEmpty)
                        Text(job,
                            softWrap: true,
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: textColor.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () => _openChat(context, contact.userId),
              child: Text(
                isAr ? 'مراسلة' : 'Message',
                style: StyleText.fontSize12Weight500.copyWith(
                  color: isMe ? AppColors.textButton : AppColors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maleAvatar() => CustomSvgImage(
        assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
        width: 36.r,
        height: 36.r,
        fit: BoxFit.fill,
      );

  Future<void> _openChat(BuildContext context, String userId) async {
    debugPrint('[ContactBubble] open chat with $userId');
    final MessagingInterfaceImplementation messaging =
        MessagingInterfaceImplementation();
    // Tablet / desktop: select it so the inline chat panel switches.
    // Phone: push the chat screen.
    final OpenChatResult result = ContextExtension(context).isTablett
        ? await messaging.selectChatWithUser(userEmail: userId)
        : await messaging.tryOpenChatWithUser(
            context: context, userEmail: userId);
    debugPrint('[ContactBubble] result = ${result.name}');
    if (context.mounted) await showOpenChatFailure(context, result);
  }
}
