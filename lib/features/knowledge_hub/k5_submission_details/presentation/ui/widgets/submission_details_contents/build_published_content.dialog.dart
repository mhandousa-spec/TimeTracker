part of './build_published_content.dart';
/// Module: knowledge_hub / presentation / s5_submission_details/widgets/submission_details_contents/build_published_content.dialog.dart

/// Reason-for-removing dialog (split from build_published_content.dart, §7).

class ReasonForRemovingDialog extends StatefulWidget {
  final String documentId;
  final String currentUserEmail;

  const ReasonForRemovingDialog({
    Key? key,
    required this.documentId,
    required this.currentUserEmail,
  }) : super(key: key);

  @override
  State<ReasonForRemovingDialog> createState() => _ReasonForRemovingDialogState();
}

class _ReasonForRemovingDialogState extends State<ReasonForRemovingDialog> {
  final TextEditingController _justificationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    debugPrint("documentId is now ${widget.documentId}");
    super.initState();
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }








  Future<void> _handleRemoveStatus() async {
    if (_justificationController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      log('═══════════════════════════════════════', name: 'ReasonForRemoving');
      log('📌 Starting remove process', name: 'ReasonForRemoving');
      log('📌 Knowledge ID (from array): ${widget.documentId}', name: 'ReasonForRemoving');
      log('📌 User Email: ${widget.currentUserEmail}', name: 'ReasonForRemoving');
      log('📌 Justification: ${_justificationController.text.trim()}',
          name: 'ReasonForRemoving');

      // ✅ All Firestore work delegated to the service (CR-KH-S5-04).
      final result =
          await KnowledgeHubFirebaseServices().removeKnowledgeWithReason(
        documentId: widget.documentId,
        currentUserEmail: widget.currentUserEmail,
        justification: _justificationController.text.trim(),
      );

      if (result == null) {
        throw Exception(
            'Document not found with knowledgeId: ${widget.documentId}');
      }

      final creatorEmail = result.creatorEmail;
      final documentNameEnglish = result.documentNameEnglish;
      final documentNameArabic = result.documentNameArabic;

      log('✅ Document updated successfully with removed status',
          name: 'ReasonForRemoving');

      if (creatorEmail.isNotEmpty) {
        await _sendRemovalNotification(
          creatorEmail: creatorEmail,
          documentNameEnglish: documentNameEnglish,
          documentNameArabic: documentNameArabic,
        );
      }

      log('═══════════════════════════════════════', name: 'ReasonForRemoving');

      if (mounted) {
        // ✅ Just close the dialog and return success
        // The parent will handle the refresh
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e, stackTrace) {
      log('❌ ERROR OCCURRED', name: 'ReasonForRemoving');
      log('Error Type: ${e.runtimeType}', name: 'ReasonForRemoving');
      log('Error Message: $e', name: 'ReasonForRemoving');
      log('Stack Trace: $stackTrace', name: 'ReasonForRemoving');
      log('═══════════════════════════════════════', name: 'ReasonForRemoving');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(S.of(context)!.errorOccurred),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  Future<void> _sendRemovalNotification({
    required String creatorEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
  }) async {
    try {
      log('═══════════════════════════════════════', name: 'RemovalNotification');
      log('📧 [REMOVAL NOTIFICATION] Starting notification process',
          name: 'RemovalNotification');
      log('═══════════════════════════════════════', name: 'RemovalNotification');

      if (creatorEmail.isEmpty) {
        log('⚠️ [REMOVAL NOTIFICATION] No creator email - notification skipped',
            name: 'RemovalNotification');
        return;
      }

      log('✅ [REMOVAL NOTIFICATION] Creator: $creatorEmail', name: 'RemovalNotification');
      log('📄 [REMOVAL NOTIFICATION] Document: $documentNameEnglish / $documentNameArabic',
          name: 'RemovalNotification');

      bool isArabic = Get.locale?.languageCode == 'ar';
      log('🌐 [REMOVAL NOTIFICATION] Current language: ${isArabic ? 'Arabic' : 'English'}',
          name: 'RemovalNotification');

      String notificationTitle;
      String notificationBody;
      String documentName;

      if (isArabic) {
        notificationTitle = 'تم سحب المستند';
        documentName = documentNameArabic;
        notificationBody =
        'تم سحب المستند $documentName من الاستخدام، ولم يعد سارياً أو معمولاً به.';
      } else {
        notificationTitle = 'Document Withdrawn';
        documentName = documentNameEnglish;
        notificationBody =
        '$documentName has been withdrawn from active use and is no longer applicable.';
      }

      log('📝 [REMOVAL NOTIFICATION] Title: $notificationTitle',
          name: 'RemovalNotification');
      log('📝 [REMOVAL NOTIFICATION] Body: $notificationBody', name: 'RemovalNotification');

      log('📤 [REMOVAL NOTIFICATION] Sending push notification to creator...',
          name: 'RemovalNotification');
      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        creatorEmail,
      );

      log('✅ [REMOVAL NOTIFICATION] Push notification sent to creator successfully',
          name: 'RemovalNotification');

      try {
        final controller = Get.find<MainCoreEmployeeController>();

        EmployeeEntityPro? creator;
        try {
          creator = controller.allEmployeesEntities?.firstWhere(
                (emp) => emp.email == creatorEmail,
          );
        } catch (e) {
          creator = null;
        }

        if (creator != null &&
            creator.supervisor != null &&
            creator.supervisor!.isNotEmpty) {
          log('✅ [REMOVAL NOTIFICATION] Found supervisor: ${creator.supervisor}',
              name: 'RemovalNotification');

          await NotificationServiceApp.sendNotification(
            notificationTitle,
            notificationBody,
            creator.supervisor!,
          );

          log('✅ [REMOVAL NOTIFICATION] Push notification sent to supervisor successfully',
              name: 'RemovalNotification');
        } else {
          log('⚠️ [REMOVAL NOTIFICATION] No supervisor found for creator',
              name: 'RemovalNotification');
        }
      } catch (e) {
        log('⚠️ [REMOVAL NOTIFICATION] Could not send to supervisor: $e',
            name: 'RemovalNotification');
      }

      log('💾 [REMOVAL NOTIFICATION] Saving notification to Firestore database...',
          name: 'RemovalNotification');

      // ✅ Persist the notification via the service (no Firestore + no
      // hardcoded Demo/Notifications collections in the UI, CR-KH-S5-04 / §15).
      final notificationData = {
        'Name_of_module': 'knowledgeHub',
        'Pin': false,
        'Reciver_Email': creatorEmail,
        'Sender_Email': widget.currentUserEmail,
        'body': notificationBody,
        'isClean': false,
        'isRead': false,
        'name_of_page': 'ViewKnowledgeHub',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'title': notificationTitle,
      };

      await KnowledgeHubFirebaseServices()
          .saveNotificationRecord(notificationData);
      log('✅ [REMOVAL NOTIFICATION] Notification record saved',
          name: 'RemovalNotification');

      log('═══════════════════════════════════════', name: 'RemovalNotification');
      log('🎉 [REMOVAL NOTIFICATION] Process completed successfully',
          name: 'RemovalNotification');
      log('═══════════════════════════════════════', name: 'RemovalNotification');
    } catch (e, stackTrace) {
      log('❌ [REMOVAL NOTIFICATION] Error sending notification: $e',
          name: 'RemovalNotification');
      log('❌ Stack trace: $stackTrace', name: 'RemovalNotification');
    }
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Center(
      child: Material(
        color: AppColors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 539,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode ? AppColors.white : AppColors.chatBackground,
          ),
          padding: EdgeInsets.all(20.r),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomSvgImage(
                        assetPath: "assets/icons_assets/knowledge_hub_assets/images_minus_circle.svg",
                        color: AppColors.textButton,
                        width: 18.w,
                        height: 18.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    S.of(context)!.reasonOfRemoving,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context)!.justifications,style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  CustomValidatedTextField(
                    label: '',
                    hint: S.of(context)!.textHere,
                    controller: _justificationController,
                    textDirection: !context.isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
                    fillColor: lightMode ? AppColors.background : AppColors.background,
                    height: 72.sp,
                    showCharCount: true,
                    maxLines: 3,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isLoading
                      ? SizedBox(
                    width: 150.w,
                    height: 38.h,
                    child: Center(
                        child: CircleProgressMaster()
                    ),
                  )
                      : customButton(
                      title: S.of(context)!.submit,
                      width: 150.w,
                      height: 38.h,
                      function: _handleRemoveStatus
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
