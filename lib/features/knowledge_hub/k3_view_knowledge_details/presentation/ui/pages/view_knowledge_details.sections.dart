part of './view_knowledge_details.dart';
/// Module: knowledge_hub / presentation / s3_view_knowledge_details/master_page/view_knowledge_details.sections.dart

/// Builder methods + view state for [ViewKnowledgeDetails], split out of
/// the master page to keep each file under the 800-LOC limit (§7).
mixin _ViewKnowledgeDetailsSections on State<ViewKnowledgeDetails> {
  bool showFullComments = false;
  late bool isOwner;
  TabController? _tabController;
  final TextEditingController _searchStatisticsController = TextEditingController();
  int _selectedSectionIndex = 0; // 0: Analytics, 1: Statistics, 2: Comments

  /// ✅ Check if current user is the document owner
  bool _checkIfOwner() {
    try {
      final controller = Get.find<MainCoreEmployeeController>();
      final employeeEntity = controller.employeeEntity;

      if (employeeEntity?.email == null) {
        log('⚠️ No user email found', name: 'ViewKnowledgeDetails');
        return false;
      }

      final currentUserEmail = employeeEntity!.email!.toLowerCase().trim();
      final creatorEmail = widget.emailUser.toLowerCase().trim();

      log('🔍 Comparing emails:', name: 'ViewKnowledgeDetails');
      log('   Current: "$currentUserEmail"', name: 'ViewKnowledgeDetails');
      log('   Creator: "$creatorEmail"', name: 'ViewKnowledgeDetails');

      return currentUserEmail == creatorEmail;
    } catch (e) {
      log('❌ Error checking ownership: $e', name: 'ViewKnowledgeDetails');
      return false;
    }
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  /// ✅ Build tabs view for OWNER (Analytics, Statistics, Comments)
  /// ✅ Build section selector and content for OWNER (Analytics, Statistics, Comments)
  /// ✅ Build section selector and content for OWNER (Analytics, Statistics, Comments)
  Widget _buildOwnerTabsView(BuildContext context, bool lightMode) {
    final controller = Get.find<MainCoreEmployeeController>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        // ✅ Section Selector (matching submission details style)
        Row(
          children: [

            if (controller.isHasPermission(
              module: Modules.knowledgeHub,
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.analytics,
            ))

            // ✅ Analytics Button
              GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSectionIndex = 0;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).analytics,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: _selectedSectionIndex == 0
                          ? AppColors.primary
                          : AppColors.secondaryText
                    ),
                  ),
                  SizedBox(height: 2),
                  if (_selectedSectionIndex == 0)
                    Container(
                      height: 2,
                      width: _getTextWidth(
                        S.of(context).analytics, // ✅ Same text as displayed
                        StyleText.fontSize20Weight500, // ✅ Same style as displayed
                      ),
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),

            if (controller.isHasPermission(
              module: Modules.knowledgeHub,
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.analytics,
            ))
            SizedBox(width: 39.w),

            if (controller.isHasPermission(
              module: Modules.knowledgeHub,
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.statistics,
            ))
            // Statistics Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSectionIndex = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).statistics,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: _selectedSectionIndex == 1
                          ? AppColors.primary
                          : AppColors.secondaryText
                    ),
                  ),
                  SizedBox(height: 2),
                  if (_selectedSectionIndex == 1)
                    Container(
                      height: 2,
                      width: _getTextWidth(
                        S.of(context).statistics, // ✅ Same text as displayed
                        StyleText.fontSize20Weight500, // ✅ Same style as displayed
                      ),
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
            if (controller.isHasPermission(
              module: Modules.knowledgeHub,
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.statistics,
            ))
            SizedBox(width: 39.w),

            if (controller.isHasPermission(
              module: Modules.knowledgeHub,
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.inquiriesAndComments,
            ))
            // ✅ Comments Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSectionIndex = 2;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).comments,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: _selectedSectionIndex == 2
                          ? AppColors.primary
                          : AppColors.secondaryText
                    ),
                  ),
                  SizedBox(height: 2),
                  if (_selectedSectionIndex == 2)
                    Container(
                      height: 2,
                      width: _getTextWidth(
                        S.of(context).comments, // ✅ Changed from inquiries_and_comments
                        StyleText.fontSize20Weight500, // ✅ Changed from fontSize14Weight500
                      ),
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 15.h),

        // ✅ Display selected section content
        _buildSelectedSectionContent(context, lightMode),
      ],
    );
  }

  /// ✅ Build content based on selected section
  /// ✅ Build content based on selected section
  Widget _buildSelectedSectionContent(BuildContext context, bool lightMode) {
    switch (_selectedSectionIndex) {
      case 0:
      // Analytics Section
        return buildAnalyticsTab(
          context,
          lightMode,
          widget.knowledgeId,
        );
      case 1:
      // Statistics Section
        return buildStatisticsTab(
          context,
          lightMode: lightMode,
          searchStatisticsController: _searchStatisticsController,
        );
      case 2:
      // Comments Section
        return _buildCommentsSection(context);
      default:
        return SizedBox.shrink();
    }
  }



  /// ✅ Build simple comments view for CONTRIBUTOR (No tabs)
  Widget _buildContributorCommentsView(BuildContext context, bool lightMode) {
    return Column(
      children: [
        // ✅ Comments Header with Expand/Collapse
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).inquiries_and_comments,
              style: StyleText.fontSize18Weight500.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => showFullComments = !showFullComments),
              child: Column(
                children: [
                  Text(
                    showFullComments
                        ? S.of(context).collapse
                        : S.of(context).expand,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.lightBlue,
                    ),
                  ),
                  Container(
                    height: 1,
                    color: AppColors.lightBlue,
                    width: showFullComments
                        ? _getTextWidth(
                      S.of(context).collapse,
                      StyleText.fontSize12Weight500,
                    )
                        : _getTextWidth(
                      S.of(context).expand,
                      StyleText.fontSize12Weight500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // ✅ Comments Section
        _buildCommentsSection(context),
      ],
    );
  }

  /// ✅ Comments Section Widget (Reusable) - Updated with new UI
  Widget _buildCommentsSection(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final ScrollController _scrollController = ScrollController();

    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        if (state is CommentsLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is CommentsLoadedFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.red),
                SizedBox(height: 16),
                Text(
                  "errorLoadingComments",
                  style: StyleText.fontSize16Weight500,
                ),
                SizedBox(height: 8),
                Text(
                  state.error,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ✅ Get comments from cubit
        final cubit = context.read<CommentsCubit>();
        final comments = cubit.commentsList;

        // ✅ Scroll to bottom when new comments are added
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && comments.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return Column(
          children: [
            // ✅ Comments Container with new UI style
            Container(
              width: double.infinity,
              height: showFullComments ? 570.h : 300.h,
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                color: lightMode ? AppColors.field : AppColors.chatBackground,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    if (comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: Column(
                            children: [
                              Lottie.asset(
                                'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
                                height: 200.h,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...comments.map((comment) {
                        final userData = cubit.usersCache[comment.currentCreatedById];
                        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

                        return Padding(
                          padding: EdgeInsets.only(bottom: 30.sp),
                          child: _buildCommentWidget(
                            context,
                            lightMode: lightMode,
                            comment: comment,
                            userData: userData,
                            isArabic: isArabic,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.sp),

            // ✅ Add new comment section with new UI
            _buildAddCommentSection(context, cubit),

            SizedBox(height: 20.sp),

          ],
        );
      },
    );
  }

  /// ✅ Build individual comment widget with new UI style
  Widget _buildCommentWidget(
      BuildContext context, {
        required bool lightMode,
        required dynamic comment,
        required dynamic userData,
        required bool isArabic,
      }) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: lightMode ? AppColors.white : AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: lightMode
              ? AppColors.secondaryText.withOpacity(0.2)
              : AppColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Comment header with user info
          Row(
            children: [
              // User Avatar
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: userData?.currentemployeePhoto != null &&
                      userData!.currentemployeePhoto!.isNotEmpty
                      ? Image.network(
                    userData.currentemployeePhoto!,
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?.currentemployeeName ?? 'Unknown User',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatCommentTimestamp(comment.currentTimestamp),
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ✅ Comment text
          Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: lightMode
                  ? AppColors.field.withOpacity(0.5)
                  : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              comment.currentCommentText,
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
          ),

          // ✅ Attachment indicator (if exists)
          if (comment.currentAttachmentExtension.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Attachment (${comment.currentAttachmentExtension})',
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Add Comment Input Section with new UI style
  /// ✅ Add Comment Input Section - Updated with reference UI style
  Widget _buildAddCommentSection(BuildContext context, CommentsCubit cubit) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final commentController = TextEditingController();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      children: [
        // ✅ Text field — app-wide CustomTextField (lib/core/custom).
        Expanded(
          child: CustomTextField(
            hint: S.of(context).writeAComment,
            borderRadius: BorderRadius.circular(8.sp),
            maxLines: 1,
            // ✅ Attachment Icon (Prefix) - You can enable file upload if needed
            prefixIcon: InkWell(
              onTap: () {
                // Handle file attachment here
              },
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/qiyas_attachement_icon.svg',
                fit: BoxFit.contain,
                color: AppColors.secondaryText,
              ),
            ),
            hintStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
            fillColor: AppColors.card,
            width: double.infinity,
            controller: commentController,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 10.h,
            ),
          ),
        ),

        SizedBox(width: 10.w),

        // ✅ Send Button
        InkWell(
          onTap: () async {
            if (commentController.text.trim().isEmpty) return;
            await _submitComment(context, cubit, commentController);
          },
          hoverColor: AppColors.transparent,
          focusColor: AppColors.transparent,
          splashColor: AppColors.transparent,
          child: Container(
            height: 34  .sp,
            width: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child:  SvgPicture.asset(
              'assets/icons_assets/main_icons_assets/qiyas_comment_icon.svg',
              width: 20.sp,
              height: 20.sp,
              color: AppColors.textButton,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Helper method to submit comment (extracted for reusability)
  Future<void> _submitComment(
      BuildContext context,
      CommentsCubit cubit,
      TextEditingController commentController,
      ) async {
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employee = employeeController.employeeEntity;

      if (employee?.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to get user information'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      // ✅ Create comment
      await cubit.createComment(
        knowledgeId: widget.knowledgeId,
        commentText: commentController.text.trim(),
        createdById: employee!.email!,
        createdByEmail: employee.email!,
      );

      // ✅ Clear input
      commentController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }


  /// ✅ Format comment timestamp
  String _formatCommentTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';

    try {
      // Parse timestamp (format: "yyyy-MM-dd HH:mm:ss")
      final dateTime = DateTime.parse(timestamp);

      // Calculate time ago
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  /// ✅ Show error dialog
  void _showErrorDialog(BuildContext context, String error) {
    BuildContext? dialogCtx;

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx;
        final lightMode = Theme.of(ctx).brightness == Brightness.light;

        return Dialog(
          backgroundColor: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: false,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    "failed_to_add_comment",
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (dialogCtx != null) {
        final nav = Navigator.of(dialogCtx!, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    });
  }
}

// ✅ DocumentTypeHelper class (keep existing)
class DocumentTypeHelper {
  static final Map<String, Map<String, String>> documentTypes = {
    'presentation': {'en': 'Presentation', 'ar': 'عرض تقديمي'},
    'form': {'en': 'Form', 'ar': 'نموذج'},
    'report': {'en': 'Report', 'ar': 'تقرير'},
    'booklet': {'en': 'Booklet', 'ar': 'كتيب'},
    'video_recording': {'en': 'Video Recording', 'ar': 'تسجيل فيديو'},
    'letter': {'en': 'Letter', 'ar': 'خطاب'},
    'mandate': {'en': 'Mandate', 'ar': 'تفويض'},
    'policy': {'en': 'Policy', 'ar': 'سياسة'},
    'frame_work': {'en': 'Frame Work', 'ar': 'إطار عمل'},
    'workshop': {'en': 'Workshop', 'ar': 'ورشة عمل'},
    'guidelines': {'en': 'Guidelines', 'ar': 'إرشادات'},
    'other': {'en': 'Other', 'ar': 'أخرى'},
  };

  static String getLocalizedType(String typeKey, bool isArabic) {
    final typeMap = documentTypes[typeKey.toLowerCase().replaceAll(' ', '_')];
    if (typeMap == null) return typeKey;
    return isArabic ? (typeMap['ar'] ?? typeKey) : (typeMap['en'] ?? typeKey);
  }

  static String? getTypeKey(String typeName) {
    for (var entry in documentTypes.entries) {
      if (entry.value['en']?.toLowerCase() == typeName.toLowerCase() ||
          entry.value['ar'] == typeName) {
        return entry.key;
      }
    }
    return null;
  }
}
