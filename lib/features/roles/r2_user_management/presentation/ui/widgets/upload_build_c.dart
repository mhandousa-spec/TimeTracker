/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_build_c.dart
/// Purpose: Declares `UploadBuildC`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension UploadBuildC on _UploadFileDetailsTabletRolesState {
  List<Widget> _uploadChildrenC(BuildContext context, bool lightMode) {
    return [
              SizedBox(height: 20.sp),

              Row(
                children: [
                  customButton(
                    title: S.of(context).discard,
                    function: (){},
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.black
                    ),
                    width: 150.sp,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.grey,
                  ),

                  Spacer(),

                  customButton(
                    title: S.of(context).activate,
                    function: () {
                      if (getTotalErrorCount() > 0) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            contentPadding: EdgeInsets.all(20.sp),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lottie_assets/roles_lottie_assets/rejected.json',
                                  width: 90.sp,
                                  height: 90.sp,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 20.sp),
                                Text(
                                  "You must correct all errors before uploading",
                                  style: StyleText.fontSize18Weight500.copyWith(
                                    color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                        return;
                      }
                      else
                      {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            contentPadding: EdgeInsets.all(20.sp),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lottie_assets/roles_lottie_assets/createServices.json',
                                  width: 90.sp,
                                  height: 90.sp,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 15.sp),
                                Text(
                                  S.of(context).activatingRoles,
                                  style: StyleText.fontSize20Weight500.copyWith(
                                    color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 18.sp),
                                Text(
                                  S.of(context).confirmActivateRoles,
                                  style: StyleText.fontSize18Weight500.copyWith(
                                    color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15.sp),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    customButton(
                                        title: S.of(context).no,
                                        function: (){
                                          Navigator.pop(context);
                                        },
                                        textStyle: StyleText.fontSize18Weight500.copyWith(
                                          color: AppColors.black
                                        ),
                                        width: 135.sp,
                                        height: 38.sp,
                                        radius: 4.r,
                                        color: AppColors.secondaryText
                                    ),

                                    SizedBox(width: 28.sp),

                                    customButton(
                                        title: S.of(context).yes,
                                        function: () async {
                                          // ✅ Store the current context BEFORE async operations
                                          final scaffoldContext = context;

                                          // Close the confirmation dialog
                                          Navigator.pop(scaffoldContext);

                                          // Perform the upload
                                          await uploadToFirebase();

                                          // ✅ Check if widget is still mounted before showing success dialog
                                          if (!mounted) return;

                                          // Show success dialog
                                          customButton(
                                            title: "Activate ",
                                            function: () {
                                              // ✅ Capture the widget's context HERE (outside all dialogs)
                                              final widgetContext = context;

                                              if (getTotalErrorCount() > 0) {
                                                showDialog(
                                                  context: widgetContext,
                                                  barrierDismissible: true,
                                                  builder: (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                    contentPadding: EdgeInsets.all(20.sp),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Lottie.asset(
                                                          'assets/lottie_assets/roles_lottie_assets/rejected.json',
                                                          width: 90.sp,
                                                          height: 90.sp,
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(height: 20.sp),
                                                        Text(
                                                          "You must correct all errors before uploading",
                                                          style: StyleText.fontSize18Weight500.copyWith(
                                                            color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              else
                                              {
                                                showDialog(
                                                  context: widgetContext,
                                                  barrierDismissible: true,
                                                  builder: (dialogContext) => AlertDialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                                    contentPadding: EdgeInsets.all(20.sp),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Lottie.asset(
                                                          'assets/lottie_assets/roles_lottie_assets/createServices.json',
                                                          width: 90.sp,
                                                          height: 90.sp,
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(height: 15.sp),
                                                        Text(
                                                          "Activating Roles",
                                                          style: StyleText.fontSize20Weight500.copyWith(
                                                            color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        SizedBox(height: 18.sp),
                                                        Text(
                                                          "Are You Sure You Want To Activate These Roles ?",
                                                          style: StyleText.fontSize18Weight500.copyWith(
                                                            color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        SizedBox(height: 15.sp),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            customButton(
                                                                title: S.of(dialogContext).no,
                                                                function: (){
                                                                  Navigator.pop(dialogContext);
                                                                },
                                                                textStyle: StyleText.fontSize18Weight500.copyWith(
                                                                    color: AppColors.black
                                                                ),
                                                                width: 135.sp,
                                                                height: 38.sp,
                                                                radius: 4.r,
                                                                color: AppColors.secondaryText
                                                            ),

                                                            SizedBox(width: 28.sp),

                                                            customButton(
                                                                title: S.of(dialogContext).yes,
                                                                function: () async {
                                                                  // Close the confirmation dialog
                                                                  Navigator.pop(dialogContext);

                                                                  // Perform the upload
                                                                  await uploadToFirebase();

                                                                  // ✅ Check if widget is still mounted
                                                                  if (!mounted) return;

                                                                  // ✅ Use widgetContext (not dialogContext or scaffoldContext)
                                                                  showDialog(
                                                                      context: widgetContext,
                                                                      barrierDismissible: true,
                                                                      builder: (context) => AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(12.r)
                                                                        ),
                                                                        contentPadding: EdgeInsets.all(20.sp),
                                                                        content: Container(
                                                                          width: 400.sp,
                                                                          height: 180.sp,
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Lottie.asset(
                                                                                'assets/lottie_assets/main_lottie_assets/approved.json',
                                                                                width: 90.sp,
                                                                                height: 90.sp,
                                                                                fit: BoxFit.contain,
                                                                              ),
                                                                              SizedBox(height: 15.sp),
                                                                              Text(
                                                                                "Activated",
                                                                                style: StyleText.fontSize20Weight500.copyWith(
                                                                                  color: lightMode
                                                                                      ? AppColors.secondaryText
                                                                                      : AppColors.grey,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(height: 18.sp),
                                                                              Text(
                                                                                "You Successfully Activated These Roles",
                                                                                style: StyleText.fontSize18Weight500.copyWith(
                                                                                  color: lightMode
                                                                                      ? AppColors.secondaryText
                                                                                      : AppColors.grey,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                  );
                                                                },
                                                                textStyle: StyleText.fontSize18Weight500.copyWith(
                                                                    color: AppColors.textButton
                                                                ),
                                                                width: 135.sp,
                                                                height: 38.sp,
                                                                radius: 4.r,
                                                                color: AppColors.primary
                                                            ),
                                                          ],
                                                        )

                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

                                            },
                                            textStyle: StyleText.fontSize16Weight500.copyWith(
                                              color: getTotalErrorCount() > 0 ? AppColors.black  : AppColors.textButton ,
                                            ),
                                            width: 150.sp,
                                            height: 38.sp,
                                            radius: 8.r,
                                            color: getTotalErrorCount() > 0
                                                ? AppColors.secondaryText
                                                : AppColors.primary,
                                          );
                                        },
                                        textStyle: StyleText.fontSize18Weight500.copyWith(
                                            color: AppColors.textButton
                                        ),
                                        width: 135.sp,
                                        height: 38.sp,
                                        radius: 4.r,
                                        color: AppColors.primary
                                    ),
                                  ],
                                )

                              ],
                            ),
                          ),
                        );
                      }

                    },
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: getTotalErrorCount() > 0 ? AppColors.black  : AppColors.textButton ,
                    ),
                    width: 150.sp,
                    height: 38.sp,
                    radius: 8.r,
                    color: getTotalErrorCount() > 0
                        ? AppColors.secondaryText
                        : AppColors.primary,
                  ),

                ],
              ),
              SizedBox(height: 20.sp),
    ];
  }
}
