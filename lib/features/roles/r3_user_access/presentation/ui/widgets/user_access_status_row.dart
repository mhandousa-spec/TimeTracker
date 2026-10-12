/// Module: roles / r3_user_access / presentation / ui / widgets
///
///************************ FILE INFO ****************************///
/// File Name: user_access_status_row.dart
/// Purpose : Contains the ui for account status row in account status screen.
/// Author: Amr Mesbah
/// Created at : 28/1/2025
///
/// Uses the shared StatusChipFilter from core/custom/8-custom_filter_app.dart
/// instead of hand-rolling a Row of FilterBarItem widgets. StatusChipFilter
/// supplies its own SingleChildScrollView/Row and defaults chipSpacing to
/// 30.sp, which is what this row used before.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/account_status_constants.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/theme/employee_status_style.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_state.dart';

/// The colour a User Access status is painted with — shared by the status
/// chips here and the card border in `user_access_card.dart`.
///
/// Scheduled Activation / Deactivation use fixed brand colours; every other
/// status keeps its own `status.color`. EXTRACTED 21/9/2026: the card read
/// `status.color` directly, so a "Scheduled Activation" card was outlined in a
/// different colour from its own chip (bug report p.13).
Color userAccessStatusColor(EmployeeStatusEnum status) {
  switch (status) {
    case EmployeeStatusEnum.willBeActivated:
      return const Color(0xFFE5B800); // Scheduled Activation
    case EmployeeStatusEnum.willBeDeactivated:
      return const Color(0xFFFF814A); // Scheduled Deactivation
    default:
      return status.color;
  }
}

class UserAccessStatusRow extends StatelessWidget {
  const UserAccessStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen to state changes
    return BlocBuilder<UserAccessCubit, UserAccessState>(
      builder: (context, state) {
        final UserAccessCubit controller =
            context.read<UserAccessCubit>();
        final statuses = AccountStatusConstants.employeeStatus;

        // StatusChipFilter keys on a String, while selection here is an
        // EmployeeStatusEnum - so the enum's `name` is used as the key and
        // mapped back to the enum on tap.
        return StatusChipFilter(
          selectedKey: controller.selectedStatus.name,
          onSelected: (key) {
            controller.selectStatus(
              statuses.firstWhere((status) => status.name == key),
            );
          },
          items: [
            for (final status in statuses)
              StatusChipItem(
                key: status.name,
                label: FormatHelper.capitalize(status.localizedName(context)),
                count: controller.accountStatusEntities[status]?.length ?? 0,
                // Scheduled Activation / Deactivation use fixed brand colors;
                // every other status keeps its own `status.color`.
                labelColor: userAccessStatusColor(status),
              ),
          ],
        );
      },
    );
  }
}
