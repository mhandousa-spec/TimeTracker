/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: umdr_methods2.dart
/// Purpose: Declares `UmdrMethods2`.
/// Author: Knowticed Plus team
/// Updated: 23/8/2026 - `_buildCommentsSection` added and hung under the
///          request note card in `_buildContent`.
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - The Message button now opens a chat with the creator.

part of '../pages/user_management_details_request.dart';

extension UmdrMethods2 on _UserManagementDetailsRequestSettingsState {
  /// Open the one-to-one chat with the colleague who filed this request.
  ///
  /// ADDED 25/8/2026. The "Message" button had an empty callback.
  ///
  /// The whole messaging handshake — find the connection, create it if these
  /// two have never spoken, start the chat, push the view — lives in
  /// [MessagingInterfaceImplementation.openChatWithUser]. This page only knows
  /// an email, which is exactly what that method wants, and it stays out of the
  /// messaging module's cubits entirely (they are GetX-registered, and feature
  /// code does not call the locator directly).
  ///
  /// The spinner matters: on the first tap of a session the connection list is
  /// usually empty and the method waits for Firestore's first batch, which can
  /// take a moment.
  Future<void> _openChatWithCreator(
      BuildContext context, String creatorEmail) async {
    showLoadingIndicator();
    bool loading = true;
    void stopLoading() {
      if (!loading) return;
      loading = false;
      hideLoadingIndicator();
    }

    // CHANGED 21/9/2026 — the spinner is closed BEFORE the chat is pushed
    // (`beforeNavigate`); it used to stay up until the chat was closed again.
    // A failure now says why, localized, and closes itself after 3 s (the old
    // title was the raw key "couldNotOpenChatWithThisUser").
    final OpenChatResult result = await MessagingInterfaceImplementation()
        .tryOpenChatWithUser(
      context: context,
      userEmail: creatorEmail,
      beforeNavigate: stopLoading,
    );
    stopLoading();

    if (context.mounted) await showOpenChatFailure(context, result);
  }

  // ─── Status / action button area ─────────────────────────────────────────
  Widget _buildStatusButton() {
    // Already actioned → show read-only badge
    if (status != 'pending') {
      // Role QA p.32 / p.35: on a phone the 200-wide badge sat at the far end
      // of an otherwise empty row. It now spans the card's width there, the
      // same width the Reject + Approve pair took before the decision.
      final bool fullWidth = ContextExtension(context).isPhone;
      final Widget badge = Container(
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _getStatusColor(status)),
        ),
        width: fullWidth ? null : 200.w,
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: _getStatusIcon(status),
              width: 24.w,
              height: 24.h,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(width: 8.w),
            Text(
              _getStatusLabel(status),
              style: StyleText.fontSize16Weight500.copyWith(
                color: _getStatusColor(status),
              ),
            ),
          ],
        ),
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (fullWidth) Expanded(child: badge) else badge,
        ],
      );
    }

    // Role QA p.16: this used to be a tiny 24px spinner next to the note
    // counter. The decision flow now covers the whole page with the app's
    // loading indicator while it saves, so this slot just keeps its height.
    if (isProcessing) {
      return SizedBox(height: 38.h);
    }

    // ── Pending, but not mine to decide (ADDED 9/10/2026) ───────────────────
    // Owner decision: a request is approved by ANOTHER Users_Requests holder,
    // never by the requester. Approve / Reject are not shown on your own
    // request (or when you cannot be identified); the repository checks the
    // same rule again before any write.
    final SelfApprovalVerdict verdict = SelfApprovalRule.check(
      requesterEmail: createdByEmail,
      requesterId: createdByID,
      deciderEmail: AppControllers.employee.employeeEntity?.email ?? '',
      deciderId: AppControllers.employee.employeeEntity?.id ?? '',
    );
    if (!verdict.isAllowed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              verdict == SelfApprovalVerdict.ownRequest
                  ? S.of(context).ownRequestReviewNote
                  : S.of(context).requestDecisionUnverifiable,
              textAlign: TextAlign.end,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          ),
        ],
      );
    }

    // ── Pending → Approve + Reject buttons ───────────────────────────────────
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Reject
        GestureDetector(
          onTap: () => _showConfirmDialog(action: 'rejected'),
          child: Container(
            width: 150.w,
            height: 38.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.red, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgImage(
                    assetPath: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                    width: 18.w,
                    height: 18.h,
                    fit: BoxFit.scaleDown),
                SizedBox(width: 6.w),
                Text(
                  S.of(context).reject,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.red),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Approve
        GestureDetector(
          onTap: () => _showConfirmDialog(action: 'approved'),
          child: Container(
            width: 150.w,
            height: 38.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.statusApproved, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgImage(
                    assetPath: "assets/icons_assets/main_icons_assets/status_approved_check_green.svg",
                    width: 18.w,
                    height: 18.h,
                    fit: BoxFit.scaleDown),
                SizedBox(width: 6.w),
                Text(
                  S.of(context).approve,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.statusApproved),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildContent(
      bool lightMode,
      bool isMobile,
      bool isArabic,
      String creatorName,
      String creatorTitle,
      String creatorDepartment,
      String creatorPhone,
      String creatorEmail,
      String creatorPhoto,
      bool isNetworkPhoto,
      ) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // EDIT 29/8/2026: expanding the thread now takes over the screen.
    //
    // "Expand" used to grow the comment box to full screen height while the
    // submitter card, the changes card and the note stayed above it — so the
    // expanded thread started a screen and a half down the page and the reviewer
    // had to scroll past everything to reach it, which defeats the point of
    // expanding. While expanded, this returns the thread alone; collapsing puts
    // the rest of the page straight back.
    //
    // The flag lives on the page state, not in `UniversalCommentSection` — the
    // widget owns whether it is expanded and reports it through
    // `onExpandChanged`, and the page owns what the rest of the screen does
    // about it. Other screens using the same widget are unaffected.
    if (commentsExpanded) {
      return _buildCommentsSection(isMobile);
    }

    // An empty request still gets the submitter card, the note and the comment
    // thread — a reviewer looking at one may well be asking what happened to
    // it. Only the changes card itself is swapped for the empty message.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(lightMode),
        // SPACING 8/9/2026: the gaps between the cards on this page are 15.sp —
        // the same value as the page's horizontal padding — so the space above
        // a section reads the same as the space beside it. They were a mix of
        // 8.h / 15.h / 16.h, all measured on a different scale from the
        // horizontal padding, so every section sat closer to the card above it
        // than to the screen edge.
        SizedBox(height: 15.sp),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.card,
              ),
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.sp,
                      height: 80.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.moreLightGrey,
                      ),
                      child: ClipOval(
                        child: !isNetworkPhoto
                            ? Image.network(
                          creatorPhoto,
                          width: 80.sp,
                          height: 80.sp,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CustomSvgImage(
                              assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",
                              width: 80.sp,
                              height: 80.sp,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : CustomSvgImage(
                          assetPath: creatorPhoto,
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(creatorName),
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16.sp),
                          isMobile
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  lightMode,
                                  "assets/icons_assets/main_icons_assets/Case.svg",
                                  S.of(context).title,
                                  creatorTitle),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/icons_assets/services_assets/department_hierarchy_people.svg",
                                  S.of(context).department,
                                  creatorDepartment),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/icons_assets/services_assets/phone_handset.svg",
                                  S.of(context).phoneNumber,
                                  creatorPhone),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/icons_assets/main_icons_assets/email_envelope.svg",
                                  S.of(context).email,
                                  creatorEmail),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/icons_assets/main_icons_assets/Case.svg",
                                        S.of(context).title,
                                        creatorTitle),
                                    SizedBox(height: 18.h),
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/icons_assets/services_assets/department_hierarchy_people.svg",
                                        S.of(context).department,
                                        creatorDepartment),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24.sp),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/icons_assets/services_assets/phone_handset.svg",
                                        S.of(context).phoneNumber,
                                        creatorPhone),
                                    SizedBox(height: 18.h),
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/icons_assets/main_icons_assets/email_envelope.svg",
                                        S.of(context).email,
                                        creatorEmail),
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
            ),
            Positioned(
              top: 10.sp,
              left: isArabic ? 10.sp : null,
              right: isArabic ? null : 10.sp,
              child: customButtonWithSvg(
                title: isMobile ? "" : S.current.message,
                // WIRED 25/8/2026: this was `() {}` — the button rendered and
                // did nothing. It now opens the one-to-one chat with the person
                // who filed the request. `creatorEmail` is the right argument
                // because email IS the messaging user id (see
                // `MessagingInterfaceImplementation.getAllUsersData`, which
                // builds every connection with `userId: employee.email`).
                function: () => _openChatWithCreator(context, creatorEmail),
                color: AppColors.primary,
                space: 8.sp,
                heightImage: 25.sp,
                colorBorder: AppColors.transparent,
                widthImage: 25.sp,
                image: 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg',
                svgColor: AppColors.textButton,
                textStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.textButton),),
            ),
          ],
        ),
        SizedBox(height: 15.sp),
        if (changes.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(50.sp),
              child: Text(
                'No changes found in this request',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
        else
          // One card for the whole request. Every changed field is a row inside
          // it, rather than each change getting its own container with the
          // section header repeated.
          _buildChangesCard(lightMode: lightMode, isMobile: isMobile),
        SizedBox(height: 15.sp),
        _buildRequestNoteSection(lightMode),
        SizedBox(height: 15.sp),
        _buildCommentsSection(isMobile),
        SizedBox(height: 15.sp),
      ],
    );
  }

  /// Function Name: [_buildCommentsSection]
  ///
  /// Purpose: The inquiries-and-comments thread for this request, so a reviewer
  ///          can ask the submitter about a change instead of rejecting it and
  ///          leaving them to guess why.
  ///
  /// Reuses `UniversalCommentSection` (core/custom/36) and the SAME collection
  /// and filter field as the employee's own request details screen
  /// (settings/se6_requests): both screens read one request document out of
  /// `Employees_Request` by the same id, so both must land on one thread — a
  /// reply written here is the reply the submitter reads there.
  ///
  /// Hidden entirely without a request id: there would be nothing to attach a
  /// comment to, and every id-less request would otherwise share one thread.
  ///
  /// Parameters:
  /// - [isMobile]: Phone layout, which gets a shorter collapsed thread.
  ///
  /// Returns: [Widget] the card, or an empty box when there is no request id.
  Widget _buildCommentsSection(bool isMobile) {
    final String requestId = widget.requestId ?? '';
    if (requestId.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: UniversalCommentSection(
        collectionPath: RequestCollectionPaths.requestCommentsCollection,
        // Written onto every new comment as well as filtering the stream —
        // `UniversalCommentSection` spreads these fields into the document.
        filterFields: <String, dynamic>{
          RequestCollectionPaths.commentRequestIdField: requestId,
        },
        currentUserId: _currentUserEmail,
        collapsedHeight: isMobile ? 320.h : 400.h,
        // The widget tells the page it expanded; the page hides everything else.
        // See the note in `_buildContent`.
        onExpandChanged: (bool expanded) {
          if (!mounted) return;
          setState(() => commentsExpanded = expanded);
        },
      ),
    );
  }

  /// Who is writing. Comments are attributed by email — the identifier
  /// `MainCoreEmployeeController` resolves names, photos and departments from.
  String get _currentUserEmail => AppControllers.isEmployeeRegistered
      ? (AppControllers.employee.employeeEntity?.email ?? '')
      : '';
  Widget _buildDetailRow(
      bool lightMode, String iconPath, String label, String value) {
    return Row(
      children: [
        CustomSvgImage(
            assetPath: iconPath, width: 15.w, height: 15.h, fit: BoxFit.fill,color: AppColors.secondaryText,),
        SizedBox(width: 8.sp),
        Text(
          "$label: ",
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        Expanded(
          child: Text(
            FormatHelper.capitalize(value),
            style:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
  Widget _buildHeader(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        Spacer(),
        Text(
          "${S.of(context).requestedDate}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        Text(
          _formatDate(requestTime),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }
}
