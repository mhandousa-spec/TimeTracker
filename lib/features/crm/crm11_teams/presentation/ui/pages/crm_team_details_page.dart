// ****************** FILE INFO ******************
// File Name: crm_team_details_page.dart
// Purpose: View CRM Team details with status toggle, Edit/Remove actions, and member contact cards.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';

import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_cubit.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_state.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_team_conditions_section.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_team_member_detail_card.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTeamDetailsPage extends StatefulWidget {
  final CrmTeamModel team;

  const CrmTeamDetailsPage({
    super.key,
    required this.team,
  });

  @override
  State<CrmTeamDetailsPage> createState() => _CrmTeamDetailsPageState();
}

class _CrmTeamDetailsPageState extends State<CrmTeamDetailsPage> {
  late CrmTeamModel _currentTeam;

  @override
  void initState() {
    super.initState();
    _currentTeam = widget.team;
  }

  void _onEditTap() {
    CrmNavigationHelper.navigateToEditTeam(
      context,
      team: _currentTeam,
      existingTeams: context.read<CrmTeamsCubit>().state.teams,
    );
  }

  Future<void> _onRemoveTap() async {
    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Team',
        arabicName: 'حذف الفريق',
      ),
      subtitle: FormatHelper.localizedString(
        englishName:
            'Are you sure you want to remove ${_currentTeam.displayName}?',
        arabicName: 'هل أنت متأكد من رغبتك في إزالة ${_currentTeam.displayName}؟',
      ),
      onConfirm: () async {
        final bool success =
            await context.read<CrmTeamsCubit>().deleteTeam(_currentTeam.id);
        if (success && mounted) {
          Navigator.pop(context); // close details page
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: FormatHelper.localizedString(
              englishName: 'Deleted',
              arabicName: 'تم الحذف',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Team removed successfully',
              arabicName: 'تم حذف الفريق بنجاح',
            ),
          );
        }
      },
    );
  }

  Future<void> _toggleStatus(String? newStatus) async {
    if (newStatus == null) return;
    final CrmTeamStatus status = CrmTeamStatus.fromString(newStatus);
    final CrmTeamModel updated = _currentTeam.copyWith(status: status);
    final bool success =
        await context.read<CrmTeamsCubit>().updateTeam(updated);
    if (success && mounted) {
      setState(() => _currentTeam = updated);
    }
  }

  void _onSendMessage(CrmTeamMemberModel member) {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Message Sent',
        arabicName: 'تم إرسال الرسالة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Opening chat with ${member.name}...',
        arabicName: 'جارٍ فتح المحادثة مع ${member.name}...',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Team',
          arabicName: 'الفريق',
        ),
        onFirstTap: () => Navigator.pop(context),
        thirdTitle: _currentTeam.displayName,
        onSecondTap: () => Navigator.pop(context),
        child: BlocListener<CrmTeamsCubit, CrmTeamsState>(
          listener: (BuildContext context, CrmTeamsState state) {
            final int index =
                state.teams.indexWhere((t) => t.id == _currentTeam.id);
            if (index != -1 && mounted) {
              setState(() => _currentTeam = state.teams[index]);
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Top Controls: Status Dropdown (Left) & Edit/Remove Buttons (Right)
                _buildTopControls(),
                SizedBox(height: 16.sp),

                // 2. Team Details Card
                _buildTeamDetailsSection(),
                SizedBox(height: 16.sp),

                // 3. Conditions Details Card (Read-only)
                CrmTeamConditionsSection(
                  isReadOnly: true,
                  selectedCountry: _currentTeam.getConditionValue('Countries'),
                  countryPriority:
                      _currentTeam.getConditionPriority('Countries'),
                  selectedLanguage:
                      _currentTeam.getConditionValue('Preferred Language'),
                  languagePriority:
                      _currentTeam.getConditionPriority('Preferred Language'),
                  selectedIndustry:
                      _currentTeam.getConditionValue('Industry'),
                  industryPriority:
                      _currentTeam.getConditionPriority('Industry'),
                  selectedSector: _currentTeam.getConditionValue('Sector'),
                  sectorPriority: _currentTeam.getConditionPriority('Sector'),
                ),
                SizedBox(height: 32.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    final bool isActive = _currentTeam.isActive;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Status Dropdown / Badge
        Container(
          height: 38.sp,
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          decoration: BoxDecoration(
            color: isActive ? AppColors.green : AppColors.orange,
            borderRadius: BorderRadius.circular(6.sp),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentTeam.status.code,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.white,
                size: 20.sp,
              ),
              dropdownColor: isActive ? AppColors.green : AppColors.orange,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              onChanged: _toggleStatus,

              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem<String>(
                  value: 'inactive',
                  child: Text('Inactive'),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons: Edit & Remove
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomEditIcon(
              onTap: _onEditTap,
            ),
            SizedBox(width: 8.sp),
            CustomDeleteIcon(
              color: AppColors.red,
              onTap: _onRemoveTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamDetailsSection() {
    final CrmTeamMemberModel? manager = _currentTeam.manager != null
        ? (_currentTeam.manager is CrmTeamMemberModel
            ? _currentTeam.manager as CrmTeamMemberModel
            : CrmTeamMemberModel.fromEntity(_currentTeam.manager!))
        : null;

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Team Details',
        arabicName: 'تفاصيل الفريق',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Team Type (Read only)
          buildResponsiveFields(
            context: context,
            left: CustomDropdown<String>(
              label: FormatHelper.localizedString(
                englishName: 'Team Type',
                arabicName: 'نوع الفريق',
              ),
              value: _currentTeam.teamType,
              items: <DropdownItem<String>>[
                DropdownItem<String>(
                  value: _currentTeam.teamType,
                  label: _currentTeam.teamType,
                ),
              ],
              enabled: false,
            ),
            right: const SizedBox.shrink(),
          ),
          SizedBox(height: 16.sp),

          // Bilingual Names (Read only)
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: TextEditingController(text: _currentTeam.nameEn),
              label: 'Team Name',
              readOnly: true,
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: TextEditingController(text: _currentTeam.nameAr),
                label: 'اسم الفريق',
                textAlign: TextAlign.right,
                readOnly: true,
              ),
            ),
          ),
          SizedBox(height: 16.sp),


          // Team Manager Detail Card
          Text(
            FormatHelper.localizedString(
              englishName: 'Team Manager',
              arabicName: 'مدير الفريق',
            ),
            style: StyleText.fontSize14Weight400,
          ),
          SizedBox(height: 8.sp),
          if (manager != null)
            CrmTeamMemberDetailCard(
              member: manager,
              onMessageTap: () => _onSendMessage(manager),
            )
          else
            Text('—', style: StyleText.fontSize12Weight400),
          SizedBox(height: 16.sp),

          // Team Members Detail Cards
          Text(
            FormatHelper.localizedString(
              englishName: 'Team Members',
              arabicName: 'أعضاء الفريق',
            ),
            style: StyleText.fontSize14Weight400,
          ),
          SizedBox(height: 8.sp),
          if (_currentTeam.members.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentTeam.members.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.sp),
              itemBuilder: (BuildContext context, int index) {
                final dynamic m = _currentTeam.members[index];
                final CrmTeamMemberModel member = m is CrmTeamMemberModel
                    ? m
                    : CrmTeamMemberModel.fromEntity(m);
                return CrmTeamMemberDetailCard(
                  member: member,
                  onMessageTap: () => _onSendMessage(member),
                );
              },
            )
          else
            Text('—', style: StyleText.fontSize12Weight400),
          SizedBox(height: 16.sp),

          // Bilingual Notes (Read only)
          buildResponsiveFields(
            context: context,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Note', style: StyleText.fontSize14Weight400),
                SizedBox(height: 6.sp),
                CustomTextField(
                  controller:
                      TextEditingController(text: _currentTeam.noteEn),
                  hint: 'Description',
                  maxLines: 3,
                  readOnly: true,
                ),
              ],
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ملاحظة',
                      style: StyleText.fontSize14Weight400),
                  SizedBox(height: 6.sp),
                  CustomTextField(
                    controller:
                        TextEditingController(text: _currentTeam.noteAr),
                    hint: 'اكتب هنا',
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),


        ],
      ),
    );
  }
}
