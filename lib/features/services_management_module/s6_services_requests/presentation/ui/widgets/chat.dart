/// Module: services_management_module
/// Description: Comment/attachment thread widget for a single service
///              request. All Firestore/Storage I/O and file/image picking
///              now go through ChatCubit + MediaPickerService — this widget
///              only dispatches cubit methods and renders ChatState (audit
///              fix #2 hard-reject on file_picker/image_picker in UI, #3 on
///              try/catch + .collection( in UI).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, ChatCubit, ChatState, url_launcher
/// Revision History: Rewritten to remove direct file_picker/image_picker/
///                    cloud_firestore usage and to route all I/O through
///                    ChatCubit (was previously a StatefulWidget owning
///                    Firestore reads/writes and pickers directly).

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/chat_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/chat_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/chat_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Kept for backwards-compat call sites that constructed a display model
/// directly (none remain in-repo, but the type stayed public in case other
/// modules referenced it).
class MessageModel {
  final String senderName;
  final String senderTitle;
  final String avatarPath;
  final String? text;
  final String? imagePath;
  final DateTime timestamp;
  final String? docId;

  MessageModel({
    required this.senderName,
    required this.senderTitle,
    required this.avatarPath,
    this.text,
    this.imagePath,
    required this.timestamp,
    this.docId,
  });
}

class ChatCommentSectionRequest extends StatefulWidget {
  const ChatCommentSectionRequest({
    super.key,
    required this.modelId,
  });

  final String modelId;

  @override
  State<ChatCommentSectionRequest> createState() => _ChatCommentSectionRequestState();
}

class _ChatCommentSectionRequestState extends State<ChatCommentSectionRequest> {
  bool isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _commentSectionKey = GlobalKey();

  String _getMonth(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  void _scrollToCommentSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _commentSectionKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final scrollController = Scrollable.of(context);
        scrollController.position.ensureVisible(
          renderBox,
          alignment: 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _sendMessage(ChatCubit cubit) async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await cubit.sendTextMessage(text);
  }

  void _editMessage(ChatCubit cubit, ChatMessageData message) {
    if (message.text == null) return;

    final TextEditingController editController = TextEditingController(text: message.text);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(dialogContext).EditMessage),
        content: CustomTextField(
          controller: editController,
          hint: S.of(dialogContext).Edityourmessage,
          maxLines: null,
        ),
        actions: [
          customButton(
            title: S.of(dialogContext).Cancel,
            function: () => Navigator.pop(dialogContext),
            width: 90.sp,
            height: 36.sp,
            color: AppColors.card,
            textColor: AppColors.text,
          ),
          customButton(
            title: S.of(dialogContext).Save,
            width: 90.sp,
            height: 36.sp,
            color: AppColors.primary,
            textColor: AppColors.textButton,
            function: () async {
              await cubit.editMessage(docId: message.docId, newText: editController.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildMediaPreview(ChatMessageData msg) {
    final imageUrl = msg.imagePath!;
    final isImage = ['.jpg', '.jpeg', '.png', '.gif']
        .any((ext) => imageUrl.toLowerCase().contains(ext));
    final isPDF = imageUrl.toLowerCase().contains('.pdf');

    final iconAsset = isImage
        ? 'assets/icons_assets/main_icons_assets/image_placeholder_large.svg'
        : 'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
    final fallbackLabel = isImage
        ? 'Image'
        : isPDF
            ? 'PDF Document'
            : 'Document';

    return GestureDetector(
      onTap: () => _launchExternal(imageUrl),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 35.sp,
            height: 35.sp,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              msg.text ?? fallbackLabel,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomMenu(BuildContext context, ChatCubit cubit, Offset position, ChatMessageData message) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        String? selectedItem;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      decoration: BoxDecoration(
                        color: Theme.of(dialogContext).brightness == Brightness.light
                            ? AppColors.white
                            : AppColors.chatBackground,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionItem(
                            dialogContext,
                            label: 'Edit',
                            iconPath: "assets/icons_assets/main_icons_assets/edit_pencil_square.svg",
                            isSelected: selectedItem == 'edit',
                            onTap: () {
                              setState(() => selectedItem = 'edit');
                              Future.delayed(Duration(milliseconds: 150), () {
                                Navigator.pop(dialogContext);
                                _editMessage(cubit, message);
                              });
                            },
                            selectedColor: AppColors.red,
                            selectedBackground: AppColors.primary,
                          ),
                          _buildOptionItem(
                            dialogContext,
                            label: 'Delete',
                            iconPath: "assets/icons_assets/form_builder_assets/delete_trash_red.svg",
                            isSelected: selectedItem == 'delete',
                            onTap: () {
                              setState(() => selectedItem = 'delete');
                              Future.delayed(Duration(milliseconds: 150), () {
                                Navigator.pop(dialogContext);
                                cubit.deleteMessage(message.docId);
                              });
                            },
                            selectedColor: AppColors.red,
                            selectedBackground: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
    Color? selectedBackground,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.sp,
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedBackground
              : Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              fit: BoxFit.scaleDown,
              color: isSelected ? selectedColor : AppColors.secondaryText,
              width: 14.sp,
              height: 14.sp,
            ),
            SizedBox(width: 10.sp),
            Text(
              label,
              style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the source-selection dialog, then routes to the cubit — no
  /// file_picker/image_picker calls happen in this widget (audit fix #2).
  Future<void> _pickMedia(ChatCubit cubit) async {
    final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SimpleDialog(
        title: Text(S.of(dialogContext).selectFileSource),
        children: [
          if (!isDesktop) _buildMediaOption(dialogContext, S.of(dialogContext).camera, 'camera'),
          _buildMediaOption(dialogContext, S.of(dialogContext).gallery, 'gallery'),
          _buildMediaOption(dialogContext, S.of(dialogContext).document, 'document'),
          _buildMediaOption(dialogContext, S.of(dialogContext).cancel, null),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == 'camera' || choice == 'gallery') {
      await cubit.sendImageMessage(fromCamera: choice == 'camera');
    } else if (choice == 'document') {
      await cubit.sendDocumentMessage();
    }

    if (!mounted) return;
    final state = cubit.state;
    if (state is ChatError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).uploadFailed}: ${state.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).uploadSuccess)),
      );
    }
  }

  Widget _buildMediaOption(BuildContext context, String title, String? returnVal) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SimpleDialogOption(
            onPressed: () => Navigator.pop(context, returnVal),
            child: Text(
              title,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(modelId: widget.modelId)..loadComments(),
      child: Builder(builder: (context) {
        final cubit = context.read<ChatCubit>();
        var isMobile = ContextExtension(context).isPhone;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.sp),
          child: Column(
            key: _commentSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).InquiriesAndComments,
                    style: isMobile
                        ? StyleText.fontSize16Weight500.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white)
                        : StyleText.fontSize22Weight600.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                      if (isExpanded) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollToCommentSection();
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          isExpanded ? S.of(context).Hide : S.of(context).Expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.blue,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1.2,
                            decorationColor: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.sp),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: isExpanded
                    ? AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 15.sp),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.white
                          : AppColors.chatBackground,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        final messages = state is ChatLoaded ? state.messages : const <ChatMessageData>[];
                        final isBusy = state is ChatLoaded && state.isBusy;

                        return Column(
                          children: [
                            if (state is ChatLoading)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.sp),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            if (messages.isNotEmpty)
                              ListView.builder(
                                itemCount: messages.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 300 + (index * 50)),
                                    curve: Curves.easeOutCubic,
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 15.sp,
                                        left: 15.sp,
                                        right: 15.sp,
                                        top: index == 0 ? 15.sp : 0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipOval(
                                                child: SvgPicture.asset(
                                                  "assets/icons_assets/main_icons_assets/male_avatar.svg",
                                                  width: 35.sp,
                                                  height: 35.sp,
                                                  fit: BoxFit.scaleDown,
                                                  semanticsLabel: 'Dart Logo',
                                                ),
                                              ),
                                              SizedBox(width: 10.sp),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    msg.senderName,
                                                    style: StyleText.fontSize14Weight500.copyWith(
                                                      color: Theme.of(context).brightness == Brightness.light
                                                          ? AppColors.blackButton
                                                          : AppColors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    msg.senderTitle,
                                                    style: StyleText.fontSize12Weight500.copyWith(
                                                      color: Theme.of(context).brightness == Brightness.light
                                                          ? AppColors.secondaryText
                                                          : AppColors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onLongPressStart: (details) {
                                              _showCustomMenu(context, cubit, details.globalPosition, msg);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 10.sp),
                                              child: Container(
                                                padding: msg.text != null
                                                    ? EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp)
                                                    : EdgeInsets.all(8.sp),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: msg.imagePath != null
                                                    ? _buildMediaPreview(msg)
                                                    : Text(
                                                  msg.text ?? '',
                                                  style: StyleText.fontSize12Weight400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.sp),
                                            child: Text(
                                              "${msg.timestamp.day} ${_getMonth(msg.timestamp.month)} ${msg.timestamp.year} At ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')} PM",
                                              style: StyleText.fontSize10Weight400.copyWith(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.secondaryText
                                                    : AppColors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: 15.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15.sp),
                                Expanded(
                                  child: Container(
                                    height: 38.sp,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? AppColors.background
                                          : AppColors.chatBackground,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 38.sp,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.r),
                                              color: Theme.of(context).brightness == Brightness.light
                                                  ? AppColors.white
                                                  : AppColors.chatBackground,
                                            ),
                                            child: CustomTextField(
                                              controller: _controller,
                                              hint: S.of(context).WriteaComment,
                                              fillColor: AppColors.background,
                                              borderRadius: BorderRadius.circular(8.r),
                                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.w),
                                              valueStyle: StyleText.fontSize14Weight500.copyWith(
                                                height: 1.4,
                                              ),
                                              hintStyle: StyleText.fontSize14Weight500.copyWith(
                                                color: Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.secondaryText
                                                    : AppColors.grey,
                                              ),
                                              prefixIcon: Padding(
                                                padding: EdgeInsets.all(10.sp),
                                                child: GestureDetector(
                                                  onTap: isBusy ? null : () => _pickMedia(cubit),
                                                  child: SvgPicture.asset(
                                                    "assets/icons_assets/messaging_assets/camera.svg",
                                                    width: 16.sp,
                                                    height: 16.sp,
                                                    color: Theme.of(context).brightness == Brightness.light
                                                        ? AppColors.secondaryText
                                                        : AppColors.whiteShadow,
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15.sp),
                                GestureDetector(
                                  onTap: () async => await _sendMessage(cubit),
                                  child: Container(
                                    width: 35.sp,
                                    height: 35.sp,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryPrimary,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/icons_assets/main_icons_assets/send_paper_plane_white.svg",
                                      width: 20.sp,
                                      height: 20.sp,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15.sp),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
