/// Module: messaging / chat / presentation/ui/widgets/reply_content.dart
part of '../pages/chat_mobile_view.dart';

//Youssef Ashraf
///Reply section inside Bubble
class ReplyContent extends StatelessWidget {
  final MessageEntity model;
  final BoxConstraints? constraints;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  // ── ADDED 2/9/2026 ───────────────────────────────────────────────────────
  // The composer's reply preview needs to be exactly the message field: one
  // line tall, with its own close button INSIDE the box. All three default to
  // the behaviour the in-bubble use already had, so nothing else changes.

  /// Lines of the quoted message to show. 2 in a bubble; pass 1 where the box
  /// is only as tall as a single line, or the text overflows its container.
  final int maxLines;

  /// Pinned at the end of the box, with the text getting the space that is
  /// left. Used for the composer's ✕. A [Stack] would let a long message run
  /// underneath it instead.
  final Widget? trailing;

  /// The 5.h gap this widget adds below itself. On by default because the
  /// bubbles rely on it for spacing.
  final bool showBottomGap;

  const ReplyContent({
    this.constraints,
    super.key,
    required this.model,
    this.color,
    this.padding,
    this.maxLines = 2,
    this.trailing,
    this.showBottomGap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: constraints ??
                BoxConstraints(
                  maxHeight: 60.h,
                  minHeight: 40.h,
                ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: color ?? AppColors.background,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: model.messageType == MessageTypes.cameraImage
                            ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                model.mediaLink!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container()
                          ],
                        )
                            : Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 8.w,
                            top: 4.h,
                          ),
                          child: Text(
                            _getDecryptedContent(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: maxLines,
                            style: StyleText.fontSize14Weight400
                                .copyWith(color: AppColors.text),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: trailing!,
                  ),
              ],
            ),
          ),
          if (showBottomGap)
            SizedBox(
              height: 5.h,
            ),
        ],
      ),
    );
  }

  /// Decrypt the replied message content using MasterChatCubit
  String _getDecryptedContent(BuildContext context) {
    final content = model.messageContent ?? '';
    if (content.isEmpty) return content;
    // Decrypt + error handling live in MasterChatCubit; UI never catches (§11.2).
    return context.read<MasterChatCubit>().decryptMessage(content);
  }
}