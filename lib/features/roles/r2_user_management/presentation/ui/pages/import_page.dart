/// Module: roles / r2_user_management / presentation / ui / pages
///
/// ******************* FILE INFO *******************
/// File Name: upload_file.dart
/// Description: can make bulk upload of file by drag and drop here
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'dart:io';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/upload_file_details.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:desktop_drop/desktop_drop.dart'; // Add this dependency


import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
part '../widgets/import_page_methods1.dart';
part '../widgets/import_page_methods2.dart';

// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/data_upload/upload_file_details_toggle.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart' show SideFrameMasterServices;
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';


class UploadFileTabletRoles extends StatefulWidget {
  const UploadFileTabletRoles({super.key});
  ////
  @override
  State<UploadFileTabletRoles> createState() => _UploadFileTabletRolesState();
}

class _UploadFileTabletRolesState extends State<UploadFileTabletRoles> {
  // Add drag and drop state variables
  bool _isDragging = false;
  // REMOVED 12/8/2026: `_isHovering` — assigned in the two drag handlers but
  // never read, so the flag drove nothing (analyzer: unused_field).









  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, TextEditingController>> filteredData = [];
  List<Map<String, String>> validationErrors = [];
  int currentPage = 0;

  final List<String> expectedHeaders = [
    'Employee ID',
    'Current Role Type',
    'Desired Role Type',
    'Access Granted',
    'Access Revoked',
    'Status',
  ];

  String? selectedFileName;




  // File picker method (your existing method but simplified)
  Future<void> pickAndParseExcel() async {
    try {
      bool hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        _showErrorDialog('Storage permission denied. Please grant permission to access files.');
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      PlatformFile file = result.files.single;

      List<int> bytes;
      if (file.path != null) {
        File actualFile = File(file.path!);
        if (!await actualFile.exists()) {
          _showErrorDialog('Selected file does not exist.');
          return;
        }
        bytes = await actualFile.readAsBytes();
      } else if (file.bytes != null) {
        bytes = file.bytes!;
      } else {
        _showErrorDialog('Unable to read the selected file.');
        return;
      }

      await processFile(bytes, file.name);

    } catch (e) {
      _showErrorDialog('Failed to pick file: ${e.toString()}');
    }
  }



  void _onDragUpdate(DropEventDetails details) {
    // Intentionally empty: this used to set the unused `_isHovering` flag.
    // Kept so the DropRegion callback contract is unchanged.
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() {
      _isDragging = false;
    });

    if (details.files.isEmpty) {
      _showErrorDialog('No files were dropped.');
      return;
    }

    final file = details.files.first;
    final fileName = file.name.toLowerCase();

    // Check file extension
    if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
      _showErrorDialog('Please drop only Excel files (.xlsx or .xls)');
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      await processFile(bytes, file.name);
    } catch (e) {
      _showErrorDialog('Failed to read dropped file: ${e.toString()}');
    }
  }








  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return SideFrameMasterServices(
      titleText: S.of(context).service,
      onFirstTap: (){
        Navigator.pop(context);
      },
      secondTitle: S.of(context).bulkUpload,
      child: Padding(
        padding: EdgeInsets.only(right: 7.sp),
        child: Column(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Enhanced Upload box with drag and drop
                  DropTarget(
                    onDragEntered: (_) => _onDragEntered(),
                    onDragExited: (_) => _onDragExited(),
                    onDragUpdated: _onDragUpdate,
                    onDragDone: _onDragDone,
                    child: GestureDetector(
                      onTap: pickAndParseExcel,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? (lightMode
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.2))
                              : (AppColors.card),
                          borderRadius: BorderRadius.circular(8.r),

                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 60.sp),

                            // Animated icon based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _isDragging
                                  ? Icon(
                                Icons.cloud_upload_outlined,
                                key: ValueKey('dragging'),
                                size: 100.sp,
                                color: AppColors.primary,
                              )
                                  : CustomSvgImage(assetPath: 
                                "assets/icons_assets/form_builder_assets/upload_arrow_rounded.svg",
                                key: ValueKey('normal'),
                                width: 100.sp,
                                height: 100.sp,
                                fit: BoxFit.scaleDown,
                                semanticsLabel: 'Upload Icon',
                              ),
                            ),

                            SizedBox(height: 27.sp),

                            // Dynamic text based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Text(
                                _isDragging
                                    ?  "Drop your Excel file here"
                                    : S.of(context).dragDropFilesHere,
                                key: ValueKey(_isDragging ? 'drop' : 'drag'),
                                style: StyleText.fontSize20Weight500.copyWith(
                                  color: _isDragging
                                      ? AppColors.primary
                                      : (AppColors.text),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 25.sp),



                            SizedBox(height: 60.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 26.sp),

            // Discard And Browse buttons
            Row(
              children: [
                customButton(
                  title: S.of(context).discard,
                  function: () {
                    setState(() {
                      selectedFileName = null;
                      formData.clear();
                      validationErrors.clear();
                    });
                  },
                  textStyle: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.text,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.secondaryText,
                ),

                Spacer(),

                customButton(
                  title: S.of(context).browseFiles,
                  function: pickAndParseExcel,
                  textStyle: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),

            // Show selected file name if any
            if (selectedFileName != null) ...[
              SizedBox(height: 16.sp),
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: Text(
                        selectedFileName!,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedFileName = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
