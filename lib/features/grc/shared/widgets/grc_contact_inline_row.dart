import 'package:knowticed_plus/features/grc/shared/helpers/grc_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Compact "Label: [avatar] Name [Message]" row used inline inside the
/// Policy/Control Details cards on both the Assignment Controls and
/// Approvals details pages — deliberately not the full ContactCard widget,
/// which renders as its own bordered/shadowed card and doesn't match the
/// flat inline look these cards need. "Message" is wired as a no-op
/// placeholder (no messaging feature exists yet).
class GrcContactInlineRow extends StatelessWidget {
  final String label;
  final String? email;

  const GrcContactInlineRow({super.key, required this.label, required this.email});

  @override
  Widget build(BuildContext context) {
    final email = this.email;
    if (email == null || email.isEmpty) return const SizedBox.shrink();
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final photo = employee.displayPhoto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: CardStyles.label(12)),
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppColors.barrierColor,
          backgroundImage: photo.startsWith('http') ? NetworkImage(photo) : null,
          child: photo.startsWith('http')
              ? null
              : ClipOval(
                  child: CustomSvgImage(
                    assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
                    width: 16.r * 2,
                    height: 16.r * 2,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(width: 8.w),
        Text(name, style: CardStyles.value(12)),
        SizedBox(width: 16.w),
        customButtonWithSvg(
          title: S.of(context).msg,
          // FIXED 28/9/2026 (GRC bug report p25): this button did nothing.
          function: () => openGrcChat(context, email),
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: CardSvg.message,
          widthImage: 18.r,
          heightImage: 18.r,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        ),
      ],
    );
  }
}
