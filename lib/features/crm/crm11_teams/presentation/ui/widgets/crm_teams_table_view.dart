// ****************** FILE INFO ******************
// File Name: crm_teams_table_view.dart
// Purpose: Table view for CRM Teams matching Figma header & data columns with proper column spacing.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';

class CrmTeamsTableView extends StatelessWidget {
  final List<CrmTeamModel> teams;
  final ValueChanged<CrmTeamModel> onTeamTap;

  const CrmTeamsTableView({
    super.key,
    required this.teams,
    required this.onTeamTap,
  });

  static const double _colNo = 55;
  static const double _colType = 120;
  static const double _colNameEn = 160;
  static const double _colNameAr = 160;
  static const double _colManager = 150;
  static const double _colMembers = 130;
  static const double _colNoteEn = 160;
  static const double _colNoteAr = 160;
  static const double _colCountry = 120;
  static const double _colCountryPriority = 90;
  static const double _colLang = 150;
  static const double _colLangPriority = 90;
  static const double _colIndustry = 120;
  static const double _colIndustryPriority = 90;
  static const double _colSector = 120;
  static const double _colSectorPriority = 90;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.card, width: 1.sp),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 1965.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeaderRow(),
              if (teams.isEmpty)
                _buildEmptyRow()
              else
                ...teams.asMap().entries.map(
                      (MapEntry<int, CrmTeamModel> entry) =>
                          _buildDataRow(entry.key + 1, entry.value),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 44.sp,
      color: AppColors.text,
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Row(
        children: <Widget>[
          _buildHeaderCell('NO', width: _colNo.sp),
          _buildHeaderCell('Team Type', width: _colType.sp),
          _buildHeaderCell('Team Name', width: _colNameEn.sp),
          _buildHeaderCell('اسم الفريق', width: _colNameAr.sp),
          _buildHeaderCell('Team Manager', width: _colManager.sp),
          _buildHeaderCell('Team Members', width: _colMembers.sp),
          _buildHeaderCell('Note', width: _colNoteEn.sp),
          _buildHeaderCell('ملاحظة', width: _colNoteAr.sp),
          _buildHeaderCell('Countries', width: _colCountry.sp),
          _buildHeaderCell('Priority', width: _colCountryPriority.sp),
          _buildHeaderCell('Preferred Language', width: _colLang.sp),
          _buildHeaderCell('Priority', width: _colLangPriority.sp),
          _buildHeaderCell('Industry', width: _colIndustry.sp),
          _buildHeaderCell('Priority', width: _colIndustryPriority.sp),
          _buildHeaderCell('Sector', width: _colSector.sp),
          _buildHeaderCell('Priority', width: _colSectorPriority.sp),
          SizedBox(width: 16.sp),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.only(right: 8.sp),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.white,
          fontSize: 13.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataRow(int index, CrmTeamModel team) {
    return InkWell(
      onTap: () => onTeamTap(team),
      child: Container(
        height: 48.sp,
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        decoration: BoxDecoration(
          color: index.isEven ? AppColors.background : AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.card, width: 1.sp),
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildDataCell(index.toString(), width: _colNo.sp),
            _buildDataCell(team.teamType, width: _colType.sp),
            _buildDataCell(team.nameEn, width: _colNameEn.sp),
            _buildDataCell(team.nameAr, width: _colNameAr.sp),
            _buildDataCell(team.manager?.name ?? '—', width: _colManager.sp),
            _buildDataCell('${team.membersCount} Members', width: _colMembers.sp),
            _buildDataCell(team.noteEn.isNotEmpty ? team.noteEn : '—',
                width: _colNoteEn.sp),
            _buildDataCell(team.noteAr.isNotEmpty ? team.noteAr : '—',
                width: _colNoteAr.sp),
            _buildDataCell(team.getConditionValue('Countries'), width: _colCountry.sp),
            _buildDataCell(team.getConditionPriority('Countries'), width: _colCountryPriority.sp),
            _buildDataCell(team.getConditionValue('Preferred Language'),
                width: _colLang.sp),
            _buildDataCell(team.getConditionPriority('Preferred Language'),
                width: _colLangPriority.sp),
            _buildDataCell(team.getConditionValue('Industry'), width: _colIndustry.sp),
            _buildDataCell(team.getConditionPriority('Industry'), width: _colIndustryPriority.sp),
            _buildDataCell(team.getConditionValue('Sector'), width: _colSector.sp),
            _buildDataCell(team.getConditionPriority('Sector'), width: _colSectorPriority.sp),
            SizedBox(width: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.only(right: 8.sp),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: StyleText.fontSize12Weight400,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyRow() {
    return Container(
      height: 100.sp,
      alignment: Alignment.center,
      child: Text(
        FormatHelper.localizedString(
          englishName: 'No teams available',
          arabicName: 'لا توجد فرق متاحة',
        ),
        style: StyleText.fontSize14Weight600.copyWith(color: AppColors.darkGrey),
      ),
    );
  }
}
