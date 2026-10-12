// ******************* FILE INFO *******************
// File Name: selected_provider_details
// Description: Selected provider details.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/select_employee_field.dart';

class SelectedProviderDetails extends StatelessWidget {
  const SelectedProviderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      // buildWhen: (previous, current) =>
      // current is ProviderSelectionLoaded &&
      //     (previous is! ProviderSelectionLoaded ||
      //         previous.data.selectedEmployeeEmails != current.data.selectedEmployeeEmails),
      builder: (context, state) {
        if (state is! ProviderSelectionLoaded) return const SizedBox.shrink();

        final cubit = context.read<ProviderSelectionCubit>();
        final data = state.data;

        if (data.selectedEmployeeEmails.isEmpty) return const SizedBox.shrink();

        final sortedSelected = data.selectedEmployeeEmails.toList()..sort();
        final languageCode = Localizations.localeOf(context).languageCode;
        final isArabic = languageCode == 'ar';

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: sortedSelected.map((email) {
              // ✅ FIX: Find index first, then check if valid
              final employeeIndex = state.allEmployees.indexWhere(
                    (e) => cubit.normalizeEmail(e.email) == cubit.normalizeEmail(email),
              );

              // ✅ FIX: Skip if employee not found (-1 means not found)
              if (employeeIndex == -1) {
                return const SizedBox.shrink();
              }

              // ✅ FIX: Now safely get the employee
              final employee = state.allEmployees[employeeIndex];

              final index = sortedSelected.indexOf(email);
              final titleText = isArabic
                  ? "${cubit.getOrdinal(index + 1, isArabic)} ${S.of(context).serviceProviderDetails}"
                  : "${cubit.getOrdinal(index + 1, isArabic)} ${S.of(context).serviceProviderDetails}";

              return Padding(
                padding: EdgeInsets.only(bottom: 20.sp),
                child: buildFormSection(
                  context: context,
                  title: titleText,
                  name: _getDisplayName(employee, isArabic),
                  job: _getDisplayJob(employee, isArabic),
                  email: employee.email ?? '',
                  phone: cubit.formatPhoneNumber(employee.mobilePhone),
                  avatar: employee.photo ?? '',
                  gender: employee.gender ?? '',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getDisplayName(dynamic employee, bool isArabic) {
    final nameEn = [employee.firstName, employee.lastName]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();

    final nameAr = [employee.firstNameInArabic, employee.lastNameInArabic]
        .where((x) => (x ?? '').trim().isNotEmpty)
        .join(' ')
        .trim();

    return isArabic
        ? (nameAr.isNotEmpty ? nameAr : nameEn)
        : (nameEn.isNotEmpty ? nameEn : nameAr);
  }

  String _getDisplayJob(dynamic employee, bool isArabic) {
    final jobEn = (employee.title ?? '').trim();
    final jobAr = (employee.titleInArabic ?? '').trim();

    return isArabic
        ? (jobAr.isNotEmpty ? jobAr : jobEn)
        : jobEn;
  }
}
