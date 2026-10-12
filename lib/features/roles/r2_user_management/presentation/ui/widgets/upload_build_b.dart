/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_build_b.dart
/// Purpose: Declares `UploadBuildB`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension UploadBuildB on _UploadFileDetailsTabletRolesState {
  List<Widget> _uploadChildrenB(BuildContext context, bool lightMode) {
    return [
              SizedBox(height: 10.sp),
              if (formData.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                      color: lightMode ? AppColors.white : AppColors.chatBackground,
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: (expectedHeaders.length * 265) + 90, // Extra for checkbox column
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total Services Text
                            Padding(
                              padding: EdgeInsets.only(left: 10.sp, top: 10.sp,right: 10),
                              child: Container(
                                width: 124.sp,
                                height: 25.sp,
                                decoration: BoxDecoration(
                                    color: lightMode
                                        ? AppColors.background
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(4.r)
                                ),
                                child: Center(
                                  child: Text(
                                    "${S.of(context).totalRoles}: ${formData.length}",
                                    style: StyleText.fontSize14Weight500.copyWith(
                                      color: lightMode
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10.sp),

                            // Table
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                height: 400.sp,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: formData.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 33.sp),
                                        child: Row(

                                          children: [
                                            ...expectedHeaders.map((header) {
                                              final isMixedLang = RegExp(r'[a-zA-Z]').hasMatch(header) && RegExp(r'[\u0600-\u06FF]').hasMatch(header);
                                              final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(header);
                                              final isEnglish = RegExp(r'[a-zA-Z]').hasMatch(header);

                                              // Split Arabic and English words if mixed
                                              String arabicPart = '';
                                              String englishPart = '';

                                              if (isMixedLang) {
                                                arabicPart = header.replaceAll(RegExp(r'[a-zA-Z0-9]'), '').trim();
                                                englishPart = header.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();
                                              }

                                              return Container(
                                                width: 250,
                                                margin: const EdgeInsets.only(right: 12),
                                                alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                                                child: isMixedLang
                                                    ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      arabicPart,
                                                      textAlign: TextAlign.right,
                                                      style: StyleText.fontSize16Weight500.copyWith(
                                                        color: lightMode ? AppColors.blackButton : AppColors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6), // spacing between Arabic and English
                                                    Text(
                                                      englishPart,
                                                      textAlign: TextAlign.left,
                                                      style: StyleText.fontSize16Weight500.copyWith(
                                                        color: lightMode ? AppColors.blackButton : AppColors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                    : Text(
                                                  header,
                                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                                  style: StyleText.fontSize16Weight500.copyWith(
                                                    color: lightMode ? AppColors.blackButton : AppColors.white,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      );
                                    }

                                    final rowIndex = index - 1;
                                    final row = formData[rowIndex];
                                    final isSelected = selectedRows.contains(rowIndex);

                                    return Padding(
                                      padding:  EdgeInsets.only(top: 10.h,bottom: 10.h,right: 10.w) ,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  selectedRows.remove(rowIndex);
                                                } else {
                                                  selectedRows.add(rowIndex);
                                                }
                                              });
                                            },
                                            child: CustomCheckBox(
                                              isSelected: isSelected,
                                              size: 24.sp,
                                              borderColor: lightMode
                                                  ? AppColors.grey
                                                  : AppColors.lightGrey,
                                            ),
                                          ),
                                          SizedBox(width: 10.sp),
                                          ...expectedHeaders.map((header) {
                                            return Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: KeyedSubtree(
                                                  key: fieldKeys[rowIndex][header],
                                                  child: CustomExcelTextField(
                                                    controller: row[header]!,
                                                    focusNode: focusNodes[rowIndex][header],
                                                    placeholder: header,
                                                    width: 250,
                                                    height: 36,
                                                    showHeader: false,
                                                    headerLabel: '',
                                                    errorText: validationErrors.length > rowIndex ? validationErrors[rowIndex][header] : null,
                                                    rowIndex: rowIndex,
                                                    validator: (key, index) {
                                                      final value = formData[index][key]?.text ?? '';
                                                      final error = validateCell(key, value, rowData: formData[index]);
                                                      if (error != null) {
                                                        validationErrors[index][key] = error;
                                                      } else {
                                                        validationErrors[index].remove(key);
                                                      }

                                                      // No conditional re-validation needed since Status is independent

                                                      // Update error locations after validation changes
                                                      setState(() {
                                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                          updateErrorLocations();
                                                        });
                                                      });
                                                    },
                                                  ),
                                                )

                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    );
                                  },

                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

    ];
  }
}
