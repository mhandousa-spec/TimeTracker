/// Module: services_management_module
/// Description: Comment/attachment thread widget for the s10 employee-action
///              request detail screen. All Firestore/Storage I/O and
///              file/image picking now go through ChatCubit +
///              MediaPickerService — this widget only dispatches cubit
///              methods and renders ChatState (audit fix 1a: hard-reject on
///              cloud_firestore/firebase_storage + try/catch in UI).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, ChatCubit, ChatState, url_launcher
/// Revision History: Rewritten to remove direct cloud_firestore/
///                    firebase_storage usage (was previously a
///                    StatefulWidget owning Firestore reads/writes
///                    directly); pickers already routed through
///                    MediaPickerService prior to this pass.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/chat_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/chat_state.dart';

class EmployeeChatCommentSection extends StatefulWidget {
  const EmployeeChatCommentSection({
    super.key,
    required this.modelId,
  });

  final String modelId;

  @override
  State<EmployeeChatCommentSection> createState() =>
      _EmployeeChatCommentSectionState();
}

class _EmployeeChatCommentSectionState
    extends State<EmployeeChatCommentSection> {
  bool isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  String _getMonth(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return monthNames[month - 1];
  }

  Future<void> _sendMessage(ChatCubit cubit) async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await cubit.sendTextMessage(text);
  }

  void _editMessage(ChatCubit cubit, ChatMessageModel message) {
    if (message.text == null || message.docId == null) return;

    final TextEditingController editController =
        TextEditingController(text: message.text);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(dialogContext).EditMessage),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: S.of(dialogContext).Edityourmessage,
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(dialogContext).Cancel),
          ),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isEmpty) return;
              await cubit.editMessage(
                docId: message.docId!,
                newText: newText,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(S.of(dialogContext).Save),
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildMediaPreview(ChatMessageModel msg) {
    final imageUrl = msg.imagePath!;
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
    ].any((ext) => imageUrl.toLowerCase().contains(ext));
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

  // delete or Edit
  void _showCustomMenu(
    BuildContext context,
    ChatCubit cubit,
    Offset position,
    ChatMessageModel message,
  ) {
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
                        color: Theme.of(dialogContext).brightness ==
                                Brightness.light
                            ? AppColors.white
                            : AppColors.chatBackground,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionItem(
                            dialogContext,
                            label: S.of(dialogContext).edit,
                            iconPath:
                                "assets/icons_assets/main_icons_assets/edit_pencil_square.svg",
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
                            label: S.of(dialogContext).delete,
                            iconPath:
                                "assets/icons_assets/form_builder_assets/delete_trash_red.svg",
                            isSelected: selectedItem == 'delete',
                            onTap: () {
                              setState(() => selectedItem = 'delete');
                              Future.delayed(Duration(milliseconds: 150), () {
                                Navigator.pop(dialogContext);
                                if (message.docId != null) {
                                  cubit.deleteMessage(message.docId!);
                                }
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
              ? (selectedBackground ?? AppColors.lightGrey)
              : Colors.transparent,
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
  /// file_picker/image_picker/cloud_firestore calls happen in this widget.
  Future<void> _pickMedia(ChatCubit cubit) async {
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SimpleDialog(
        title: Text(S.of(dialogContext).selectFileSource),
        children: [
          _buildMediaOption(dialogContext, S.of(dialogContext).camera, 'camera'),
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
        SnackBar(
          content: Text('${S.of(context).uploadFailed}: ${state.message}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).uploadSuccess)));
    }
  }

  Widget _buildMediaOption(
    BuildContext context,
    String title,
    String? returnVal,
  ) {
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

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // InquiriesAndComments & Expand & Hide
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).InquiriesAndComments,
                    style: StyleText.fontSize22Weight600.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Text.rich(
                      TextSpan(
                        text: isExpanded
                            ? S.of(context).Hide
                            : S.of(context).Expand,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blue,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.2,
                          decorationColor: AppColors.blue,
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.sp),

              if (isExpanded)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.white
                        : AppColors.chatBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final messages =
                          state is ChatLoaded ? state.messages : const <ChatMessageModel>[];
                      final isBusy = state is ChatLoaded && state.isBusy;
                      final isLoading = state is ChatLoading;

                      return Column(
                        children: [
                          if (isLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.sp),
                              child: Center(child: CircularProgressIndicator()),
                            ),

                          if (messages.isNotEmpty)
                            ListView.builder(
                              itemCount: messages.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 15.sp,
                                    left: 15.sp,
                                    right: 15.sp,
                                    top: 15.sp,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                msg.senderName,
                                                style: StyleText
                                                    .fontSize14Weight400
                                                    .copyWith(color: AppColors.text),
                                              ),
                                              Text(
                                                msg.senderTitle,
                                                style: StyleText
                                                    .fontSize14Weight400
                                                    .copyWith(
                                                        color: AppColors.secondaryText),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      GestureDetector(
                                        onLongPressStart: (details) {
                                          _showCustomMenu(
                                            context,
                                            cubit,
                                            details.globalPosition,
                                            msg,
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.sp),
                                          child: Container(
                                            padding: msg.text != null
                                                ? EdgeInsets.symmetric(
                                                    horizontal: 14.sp,
                                                    vertical: 12.sp,
                                                  )
                                                : EdgeInsets.all(8.sp),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: msg.imagePath != null
                                                ? _buildMediaPreview(msg)
                                                : Text(msg.text ?? ''),
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.only(top: 8.sp),
                                        child: Text(
                                          "${msg.timestamp.day} ${_getMonth(msg.timestamp.month)} ${msg.timestamp.year} At ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')} PM",
                                          style: StyleText.fontSize10Weight400
                                              .copyWith(
                                            color: Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? AppColors.secondaryText
                                                : AppColors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          /// Input Comment Box
                          Padding(
                            padding: EdgeInsets.only(top: 15.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15.sp),
                                Expanded(
                                  child: Container(
                                    height: 38.sp,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
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
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              color: Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? AppColors.white
                                                  : AppColors.chatBackground,
                                            ),
                                            child: TextField(
                                              controller: _controller,
                                              decoration: InputDecoration(
                                                prefixIcon: Padding(
                                                  padding: EdgeInsets.all(10.sp),
                                                  child: GestureDetector(
                                                    onTap: isBusy
                                                        ? null
                                                        : () => _pickMedia(cubit),
                                                    child: SvgPicture.asset(
                                                      "assets/icons_assets/messaging_assets/camera.svg",
                                                      width: 16.sp,
                                                      height: 16.sp,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? AppColors.secondaryText
                                                          : AppColors.whiteShadow,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                                hintText: S.of(context).WriteaComment,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.r),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.r),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor: AppColors.background,
                                                hoverColor: Colors.transparent,
                                                hintStyle: StyleText
                                                    .fontSize14Weight400
                                                    .copyWith(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? AppColors.secondaryText
                                                      : AppColors.grey,
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
                                  onTap:
                                      isBusy ? null : () async => await _sendMessage(cubit),
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
                          ),

                          SizedBox(height: 15.sp),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
