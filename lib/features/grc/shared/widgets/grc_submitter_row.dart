import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';

/// Avatar + name + job title, stacked, for whoever last touched a
/// submission — used on both the Assignment Controls and Approvals details
/// pages' Submissions section.
class GrcSubmitterRow extends StatelessWidget {
  final String email;

  const GrcSubmitterRow({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final role = employee.localizedJobTitle(context);
    final photo = employee.displayPhoto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.barrierColor,
          backgroundImage: photo.startsWith('http') ? NetworkImage(photo) : null,
          child: photo.startsWith('http')
              ? null
              : ClipOval(
                  child: CustomSvgImage(
                    assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
                    width: 20.r * 2,
                    height: 20.r * 2,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: CardStyles.value(14)),
            if (role.isNotEmpty) Text(role, style: CardStyles.label(12)),
          ],
        ),
      ],
    );
  }
}
