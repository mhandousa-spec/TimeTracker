/// Module: services_management_module
/// Description: Approval-details page — requester-details section,
///              description widget, provider section and service-header row
///              builders. No Firestore access (the provider-assignment tap
///              refreshes via the cubit-backed `_refreshModelFromFirestore`).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: none beyond the shared state class
/// Revision History: 2026-07-02 — renamed from
///                    approval_request_details.body_helpers.dart (audit fix
///                    item 5d).
part of 'approval_request_details.dart';

// Auto-extracted to keep files under 600 lines.
extension _ApprovalBodyHelpers on _ApprovalDetailsScreenState {
  Widget buildRequesterDetailsSection(
      BuildContext context, {
        required String? firstName,
        required String? lastName,
        required String? jobTitle,
        required String? department,
      })
  {
    final requesterName =
        "${FormatHelper.capitalize(firstName ?? '-')} ${FormatHelper.capitalize(lastName ?? '-')}";
    final isMobile = ContextExtension(context).isPhone;
    final isTabletCheck = MediaQuery.sizeOf(context).width >= 600 &&
        MediaQuery.sizeOf(context).width < 900;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomRowDetailsMaster(
            data: requesterName,
            image: "assets/icons_assets/main_icons_assets/person_outline.svg",
            title: "${S.of(context).Requestedby}: ",
          ),
          SizedBox(height: 5.sp),
          CustomRowDetailsMaster(
            data: department ?? '-',
            image: "assets/icons_assets/main_icons_assets/Case.svg",
            title: "${S.of(context).Department}: ",
          ),
          SizedBox(height: 10.sp),
          CustomRowDetailsMaster(
            data: FormatHelper.capitalize(jobTitle ?? '-'),
            image: "assets/icons_assets/main_icons_assets/Case.svg",
            title: "${S.of(context).jobTitle}: ",
          ),
        ],
      );
    }

    if (isTabletCheck) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRowDetailsMaster(
                data: requesterName,
                image: "assets/icons_assets/main_icons_assets/person_outline.svg",
                title: "${S.of(context).Requestedby}: ",
              ),
              SizedBox(height: 5.sp),
              CustomRowDetailsMaster(
                data: department ?? '-',
                image: "assets/icons_assets/main_icons_assets/hierarchy_nodes.svg",
                title: "${S.of(context).Department}: ",
              ),
            ],
          ),
          SizedBox(width: MediaQuery.sizeOf(context).width * .15),
          Column(
            children: [
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(jobTitle ?? '-'),
                image: "assets/icons_assets/main_icons_assets/Case.svg",
                title: "${S.of(context).jobTitle}: ",
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomRowDetailsMaster(
            data: requesterName,
            image: "assets/icons_assets/main_icons_assets/person_outline.svg",
            title: "${S.of(context).Requestedby}: ",
          ),
        ),
        SizedBox(height: 5.sp),
        Expanded(
          child: CustomRowDetailsMaster(
            data: department ?? '-',
            image: "assets/icons_assets/main_icons_assets/hierarchy_nodes.svg",
            title: "${S.of(context).Department}: ",
          ),
        ),
        Expanded(
          child: CustomRowDetailsMaster(
            data: FormatHelper.capitalize(jobTitle ?? '-'),
            image: "assets/icons_assets/main_icons_assets/Case.svg",
            title: "${S.of(context).jobTitle}: ",
          ),
        ),
      ],
    );
  }

  Widget descriptionWidget(String description) {
    var isMobile = ContextExtension(context).isPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              child: SvgPicture.asset(
                // Services mobile QA p.32: the three-lines glyph read as a menu /
              // sort icon. Same document-description icon Knowledge Hub uses;
              // QA p.27: the label now ends with ":" like every other row.
              "assets/icons_assets/knowledge_hub_assets/document_description_icon.svg",
                width: 16.w,
                height: 16.h,
                color: AppColors.secondaryText.withOpacity(.5),
                fit: BoxFit.scaleDown,
                semanticsLabel: 'Description Icon',
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              "${S.of(context).serviceDescription}:",
              style: isMobile
                  ? StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              )
                  : StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.sp),
        Text(
          FormatHelper.capitalize(description),
          style: isMobile
              ? StyleText.fontSize10Weight400.copyWith(
            wordSpacing: -1.sp,
            color: AppColors.text,
          )
              : StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: AppColors.text,
          ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    return Builder(
                              builder: (context) {
                                List<EmployeeEntityModell> providersList;

                                try {
                                  providersList = _currentModel.currentProviderServices;
                                } catch (e) {
                                  providersList = [];
                                }

                                if (providersList.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.h),
                                    child: Container(
                                      padding: EdgeInsets.all(16.sp),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: AppColors.secondaryText
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: AppColors.secondaryText,
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 8.sp),
                                              Expanded(
                                                child: Text(
                                                  'No service provider assigned to this request',
                                                  style: StyleText
                                                      .fontSize14Weight400
                                                      .copyWith(
                                                    color:
                                                    AppColors.secondaryText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (widget.fromTable) ...[
                                            SizedBox(height: 12.sp),
                                            GestureDetector(
                                              onTap: () async {
                                                navigateTo(
                                                  context,
                                                  ServicesProviderLayout(
                                                    editingModel: _currentModel,
                                                    docId: _currentModel.currentId,
                                                    editProvider: _currentModel,
                                                  ),
                                                );
                                                if (mounted) {
                                                  await _refreshModelFromFirestore();
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.sp,
                                                  vertical: 8.sp,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4.r),
                                                  border: Border.all(color: AppColors.primary),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.add, color: AppColors.primary, size: 16.sp),
                                                    SizedBox(width: 4.sp),
                                                    Text(
                                                      'Assign Provider',
                                                      style: StyleText.fontSize14Weight500.copyWith(
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final assignedEmail = _currentModel
                                    .currentAssignedProviderEmail
                                    ?.toLowerCase()
                                    .trim() ?? '';

                                EmployeeEntityModell? assignedProvider;

                                if (assignedEmail.isNotEmpty) {
                                  for (int i = 0; i < providersList.length; i++) {
                                    final provider = providersList[i];
                                    final providerEmail =
                                        provider.email?.toLowerCase().trim() ??
                                            '';

                                    if (providerEmail == assignedEmail) {
                                      assignedProvider = provider;
                                      break;
                                    }
                                  }
                                }

                                if (assignedProvider == null) {
                                  assignedProvider = providersList.first;
                                }

                                return buildProviderDetailsSectionMaster(
                                  onTap: () {
                                    navigateTo(
                                      context,
                                      ServicesProviderLayout(
                                        editingModel: widget.approvalModel,
                                        docId: widget.approvalModel.currentId,
                                        editProvider: widget.approvalModel,
                                      ),
                                    );
                                  },
                                  table: widget.fromTable,
                                  context: context,
                                  duration: serviceDuration ?? widget.approvalModel.currentDurationOfServices ?? '',
                                  durationUnit: serviceDurationUnit ?? widget.approvalModel.currentSelectedDurationUnit ?? '',
                                  durationTimeStamp: widget.approvalModel.currentDurationOfServicesTimestamp,
                                  approvalCycle: widget.approvalModel.currentApprovalCycle,
                                  model: assignedProvider,
                                  state: currentState ?? 'pending',
                                );
                              },
                            );
  }

  Widget _buildServiceHeaderRow(BuildContext context, {required bool isMobile, required bool isArabic, required String displayServiceNameAr, required String displayServiceNameEn, required String displayServiceDesc}) {
    return Row(
                              crossAxisAlignment: isMobile
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                // image column
                                Column(
                                  children: [
                                    Container(
                                      width: isMobile ? 40.sp : !this.isTabletLandscape(context) ? 80.sp : 100.sp,
                                      height: isMobile ? 40.sp : !this.isTabletLandscape(context) ? 80.sp : 100.sp,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        color: AppColors.background,
                                      ),
                                      child: Center(
                                        child: (widget.approvalModel.currentImageUrl != null &&
                                            widget.approvalModel.currentImageUrl.isNotEmpty)
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(4.r),
                                          child: FractionallySizedBox(
                                            widthFactor: 0.6,
                                            heightFactor: 0.6,
                                            child: CachedNetworkImage(
                                              imageUrl: widget.approvalModel.currentImageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        )
                                            : FractionallySizedBox(
                                          widthFactor: 0.6,
                                          heightFactor: 0.6,
                                          child: SvgPicture.asset(
                                            "assets/icons_assets/services_assets/headset_support.svg",
                                            color: AppColors.secondaryText,
                                            fit: BoxFit.scaleDown,
                                            semanticsLabel: 'Service Icon',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(width: 10.w),

                                isMobile ? Text(isArabic ? displayServiceNameAr : displayServiceNameEn, style: StyleText.fontSize14Weight500.copyWith(
                                    color: AppColors.text
                                ),) : SizedBox(),

                                // details text
                                isMobile ? SizedBox() : Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CustomSvgImage(assetPath: "assets/icons_assets/services_assets/building_office.svg", width: 20.w, height: 20.h, fit: BoxFit.fill,),
                                          SizedBox(width: 8.w),
                                          Text(S.of(context).serviceDescription, style: StyleText.fontSize14Weight500.copyWith(
                                            color: AppColors.secondaryText,
                                          ),),
                                        ],
                                      ),
                                      isMobile ? SizedBox() : SizedBox(height: 10.h),
                                      isMobile ? SizedBox() : Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              displayServiceDesc,
                                              style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack)
                                                  .copyWith(color: AppColors.text),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
  }
}
