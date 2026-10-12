/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_build_page.dart
/// Purpose: Declares `UploadBuildPage`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension UploadBuildPage on _UploadFileDetailsTabletRolesState {
  Widget _buildPage(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return SideFrameMasterServices(
      titleText: S.of(context).service,
      onFirstTap: (){

      },
      secondTitle: S.of(context).bulkUpload,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ..._uploadChildrenA(context, lightMode),
              ..._uploadChildrenB(context, lightMode),
              ..._uploadChildrenC(context, lightMode),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _uploadChildrenA(BuildContext context, bool lightMode) {
    return [
              // File Name
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${widget.selectedFileName}',
                    style: StyleText.fontSize24Weight600.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              //space
              SizedBox(height: 23.sp),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Error Counter with WORKING navigation
                  Container(
                    height: 30.sp,
                    width: 138.sp,
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(4.r)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ⬅️ Previous Error
                        GestureDetector(
                          onTap: () {
                            if (errorLocations.isEmpty) {
                              updateErrorLocations();
                            }
                            if (errorLocations.isNotEmpty) {
                              focusErrorField(false); // Navigate to previous error
                              setState(() {}); // Trigger rebuild to update counter
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            child: Transform.rotate(
                              angle: Localizations.localeOf(context).languageCode == 'ar' ? 3.14159 : 0, // 180 degrees in radians for RTL
                              child: CustomSvgImage(assetPath: 
                                "assets/icons_assets/main_icons_assets/chevron_left.svg",
                                width: 15.sp,
                                height: 15.sp,
                                color: errorLocations.isEmpty
                                    ? AppColors.lightGrey
                                    : (AppColors.text),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 9.sp),
                        Text(
                          "${S.of(context).error}: ",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          getTotalErrorCount() > 0
                              ? "${currentErrorIndex + 1}/${getTotalErrorCount()}"
                              : "${getTotalErrorCount()}",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        SizedBox(width: 9.sp),
                        // ➡️ Next Error
                        GestureDetector(
                          onTap: () {
                            if (errorLocations.isEmpty) {
                              updateErrorLocations();
                            }
                            if (errorLocations.isNotEmpty) {
                              focusErrorField(true); // Navigate to next error
                              setState(() {}); // Trigger rebuild to update counter
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            child: Transform.rotate(
                              angle: Localizations.localeOf(context).languageCode == 'ar' ? 3.14159 : 0, // 180 degrees in radians for RTL
                              child: CustomSvgImage(assetPath: 
                                "assets/icons_assets/main_icons_assets/chevron_right.svg",
                                width: 15.sp,
                                height: 15.sp,
                                color: errorLocations.isEmpty
                                    ? AppColors.lightGrey
                                    : (AppColors.text),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),

                  Spacer(),

                  customButtonWithSvg(
                      title: S.of(context).removeSelection,
                      function: () {
                        if (selectedRows.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select at least one row to remove.")),
                          );
                          return;
                        }

                        setState(() {
                          // Sort descending to avoid index shifting
                          final sortedRows = selectedRows.toList()..sort((a, b) => b.compareTo(a));
                          for (final index in sortedRows) {
                            formData.removeAt(index);
                            validationErrors.removeAt(index);
                            focusNodes.removeAt(index);
                            fieldKeys.removeAt(index);
                          }
                          selectedRows.clear();
                          filteredData = List.from(formData);
                          // Update error locations after removing rows
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            updateErrorLocations();
                          });
                        });
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.white
                      ),
                      space: 8.sp,
                      color: AppColors.black,
                      image: "assets/icons_assets/main_icons_assets/minus_circle_red.svg",
                      svgColor: AppColors.white,
                      widthImage: 12.sp,
                      heightImage: 1.5.sp,
                      colorBorder: AppColors.transparent
                  ),
                  SizedBox(width: 10.sp,),
                  customButton(
                    title: S.of(context).duplication,
                    function: () {
                      if (selectedRows.length != 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select exactly one row to duplicate.")),
                        );
                        return;
                      }

                      final indexToDuplicate = selectedRows.first;
                      final original = formData[indexToDuplicate];
                      final originalErrors = validationErrors[indexToDuplicate];

                      // 🔁 Deep copy controllers
                      final newRow = <String, TextEditingController>{};
                      for (final entry in original.entries) {
                        newRow[entry.key] = TextEditingController(text: entry.value.text);
                      }

                      // 🔁 Deep copy errors
                      final newErrors = Map<String, String>.from(originalErrors);

                      // ✅ Create matching focus nodes for the new row
                      final newFocusMap = <String, FocusNode>{};
                      final newKeyMap = <String, GlobalKey>{};
                      for (final key in expectedHeaders) {
                        newFocusMap[key] = FocusNode();
                        newKeyMap[key] = GlobalKey();
                      }

                      setState(() {
                        formData.add(newRow);
                        focusNodes.add(newFocusMap);
                        fieldKeys.add(newKeyMap);
                        validationErrors.add({});
                        filteredData = List.from(formData);

                        // 🔁 Run validation after duplication
                        int newIndex = formData.length - 1;
                        final newRowData = formData[newIndex];
                        final newErrorMap = <String, String>{};
                        for (final header in expectedHeaders) {
                          final value = newRowData[header]?.text ?? '';
                          final error = validateCell(header, value, rowData: newRowData);
                          if (error != null) newErrorMap[header] = error;
                        }
                        validationErrors[newIndex] = newErrorMap;

                        // Update error locations after duplication
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          updateErrorLocations();
                        });
                      });
                    },
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.white
                    ),
                    width: 103.sp,
                    height: 30.sp,
                    radius: 4.r,
                    color: AppColors.black,
                  ),
                  SizedBox(width: 10.sp,),
                  customButtonWithSvg(
                      title: S.of(context).row,
                      function: () {
                        Map<String, TextEditingController> newRow = {};
                        Map<String, FocusNode> newFocusMap = {};
                        Map<String, GlobalKey> newKeyMap = {};

                        for (var header in expectedHeaders) {
                          newRow[header] = TextEditingController();
                          newFocusMap[header] = FocusNode();
                          newKeyMap[header] = GlobalKey();
                        }

                        setState(() {
                          formData.add(newRow);
                          validationErrors.add({});
                          focusNodes.add(newFocusMap);
                          fieldKeys.add(newKeyMap);
                          filteredData = List.from(formData);

                          // Update error locations after adding row
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            updateErrorLocations();
                          });
                        });
                      },

                      textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.white
                      ),
                      space: 8.sp,
                      color: AppColors.black,
                      image: "assets/icons_assets/main_icons_assets/plus.svg",
                      svgColor: AppColors.white,
                      widthImage: 12.sp,
                      heightImage: 12.sp,
                      colorBorder: AppColors.transparent
                  ),

                ],
              ),

    ];
  }
}
