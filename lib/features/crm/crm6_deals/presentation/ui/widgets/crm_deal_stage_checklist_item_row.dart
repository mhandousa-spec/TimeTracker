// ****************** FILE INFO ******************
// File Name: crm_deal_stage_checklist_item_row.dart
// Purpose: Responsive bilingual checklist item row for Deal Stages page
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

class CrmDealStageChecklistItemRow extends StatefulWidget {
  final int index;
  final String initialNameEn;
  final String initialNameAr;
  final ValueChanged<String>? onNameEnChanged;
  final ValueChanged<String>? onNameArChanged;
  final VoidCallback? onDelete;
  final bool isReadOnly;
  final bool canDelete;

  const CrmDealStageChecklistItemRow({
    super.key,
    required this.index,
    this.initialNameEn = '',
    this.initialNameAr = '',
    this.onNameEnChanged,
    this.onNameArChanged,
    this.onDelete,
    this.isReadOnly = false,
    this.canDelete = true,
  });

  @override
  State<CrmDealStageChecklistItemRow> createState() =>
      _CrmDealStageChecklistItemRowState();
}

class _CrmDealStageChecklistItemRowState
    extends State<CrmDealStageChecklistItemRow> {
  late final TextEditingController _controllerEn;
  late final TextEditingController _controllerAr;

  @override
  void initState() {
    super.initState();
    _controllerEn = TextEditingController(text: widget.initialNameEn);
    _controllerAr = TextEditingController(text: widget.initialNameAr);
  }

  @override
  void dispose() {
    _controllerEn.dispose();
    _controllerAr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // English field
            CustomTextField(
              controller: _controllerEn,
              hint: 'Text Here',
              readOnly: widget.isReadOnly,
              onChanged: widget.onNameEnChanged,
              textDirection: TextDirection.ltr,
            ),
            SizedBox(height: 8.sp),

            // Arabic field + Delete icon row
            Row(
              children: <Widget>[
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomTextField(
                      controller: _controllerAr,
                      hint: 'اكتب هنا',
                      readOnly: widget.isReadOnly,
                      onChanged: widget.onNameArChanged,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                if (!widget.isReadOnly &&
                    widget.canDelete &&
                    widget.onDelete != null) ...<Widget>[
                  SizedBox(width: 8.sp),
                  GestureDetector(
                    onTap: widget.onDelete!,
                    behavior: HitTestBehavior.opaque,
                    child: CustomSvgImage(
                      assetPath: AppAssets.minusCircle,
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    // Tablet / Desktop Layout: side-by-side with aligned columns
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // English field
          Expanded(
            child: CustomTextField(
              controller: _controllerEn,
              hint: 'Text Here',
              readOnly: widget.isReadOnly,
              onChanged: widget.onNameEnChanged,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(width: 16.sp),

          // Arabic field
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomTextField(
                      controller: _controllerAr,
                      hint: 'اكتب هنا',
                      readOnly: widget.isReadOnly,
                      onChanged: widget.onNameArChanged,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                if (!widget.isReadOnly &&
                    widget.canDelete &&
                    widget.onDelete != null) ...<Widget>[
                  SizedBox(width: 8.sp),
                  GestureDetector(
                    onTap: widget.onDelete!,
                    behavior: HitTestBehavior.opaque,
                    child: CustomSvgImage(
                      assetPath: AppAssets.minusCircle,
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
