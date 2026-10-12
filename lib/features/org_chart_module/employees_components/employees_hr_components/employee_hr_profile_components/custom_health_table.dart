import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

class CustomTableWidget extends StatefulWidget {
  final List<List<String>> initialData;
  final String columnName1;
  final String columnName2;
  final String columnName3;
  final String tableName;
  final bool? isHealth;

  const CustomTableWidget({
    super.key,
    required this.initialData,
    required this.columnName1,
    required this.columnName2,
    required this.columnName3,
    required this.tableName,
    this.isHealth = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomTableWidgetState createState() => _CustomTableWidgetState();
}

class _CustomTableWidgetState extends State<CustomTableWidget> {
  List<Map<String, String>> tableData = [];

  @override
  void initState() {
    super.initState();
    for (var rowData in widget.initialData) {
      tableData.add({
        widget.columnName1: rowData.isNotEmpty ? rowData[0] : '',
        widget.columnName2: rowData.length > 1 ? rowData[1] : '',
        widget.columnName3: rowData.length > 2 ? rowData[2] : '',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle customTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: FontConstants.fontSize022.h,
        // ignore: unrelated_type_equality_checks
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorWhiteDark
            : AppColors.colorBlack,
        fontWeight: FontWeight.w400,
        height: 0.002.h);

    TextStyle customDataTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: FontConstants.fontSize022.h,
        // ignore: unrelated_type_equality_checks
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark,
        fontWeight: FontWeight.w400,
        height: 0.002.h);

    return Padding(
      padding: EdgeInsets.only(top: 0.03.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.tableName,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize024.h,
              // ignore: unrelated_type_equality_checks
              color: themeController.currentTheme == AppColors.lightTheme
                  ? AppColors.lightPrimary
                  : AppColors.lightPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 0.03.h,
          ),
          // Header Row
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.01.h),
            decoration: BoxDecoration(
              color: AppColors.colorBlack,
              borderRadius:const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              border: Border.all(
                width: 0.001.h,
                color: AppColors.colorGrey,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.columnName1,
                  style: customTextStyle,
                ),
                Text(
                  widget.columnName2,
                  style: customTextStyle,
                ),
                Text(
                  widget.columnName3,
                  style: customTextStyle,
                ),
              ],
            ),
          ),
          // Table Rows
          Container(
            decoration: BoxDecoration(
              borderRadius:const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              border: Border.all(
                width: 0.001.h,
                color: AppColors.colorGrey,
              ),
            ),
            child: ListView.builder(
padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: tableData.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.01.h, horizontal: 0.01.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 0.27.h,
                              //   color: Colors.amber,
                              child: Flexible(
                                child: Text(
                                  tableData[index][widget.columnName1]!
                                          .capitalize as String,
                                  style: customDataTextStyle,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  widget.isHealth == true ? 0.038.h : 0.029.h,
                            ),
                            SizedBox(
                              width: widget.isHealth == true ? 0.23.h : 0.28.h,
                              //      color: Colors.red,
                              child: Flexible(
                                child: Text(
                                  tableData[index][widget.columnName2]!
                                          .capitalize as String,
                                  style: customDataTextStyle,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: widget.isHealth == true ? 0.045.h : 0.04.h,
                            ),
                            SizedBox(
                              width:
                                  widget.isHealth == true ? 0.153.h : 0.117.h,
                              //    color: Colors.lightBlue,
                              child: Flexible(
                                child: Text(
                                  tableData[index][widget.columnName3]!
                                          .capitalize as String,
                                  style: customDataTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //     if (index != tableData.length - 1) Divider(color: AppColors.colorBlack),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
