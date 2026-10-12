// ****************** FILE INFO ******************
// File Name: crm_teams_grid_view.dart
// Purpose: Responsive Grid view rendering list of CRM Team cards (2 in a row on desktop/tablet).
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_team_card.dart';

class CrmTeamsGridView extends StatelessWidget {
  final List<CrmTeamModel> teams;
  final ValueChanged<CrmTeamModel> onTeamTap;

  const CrmTeamsGridView({
    super.key,
    required this.teams,
    required this.onTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    final int crossAxisCount = isMobile ? 1 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 98.sp,
        crossAxisSpacing: 14.sp,
        mainAxisSpacing: 14.sp,
      ),
      itemCount: teams.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmTeamModel team = teams[index];
        return CrmTeamCard(
          team: team,
          onTap: () => onTeamTap(team),
        );
      },
    );
  }
}
