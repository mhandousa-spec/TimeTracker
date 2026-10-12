import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';

class HoverableMenuItem extends StatefulWidget {
  final MenuEnum menuEnum;

  const HoverableMenuItem({super.key, required this.menuEnum});

  @override
  _HoverableMenuItemState createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<HoverableMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        height: 45, // Match the height set in PopupMenuItem
        constraints: const BoxConstraints(
          minHeight: 45, // Minimum height
          maxHeight: 45, // Maximum height
        ),
        color: isHovered
            ?AppColors.primary
            : AppColors.transparent,
        alignment: Alignment.center,
        child: Text(
          widget.menuEnum.label,
          style: (!isHovered
                  ? StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack)
                  : StyleText.fontSize14Weight500)
              .copyWith(
                  color: widget.menuEnum == MenuEnum.delete
                      ?AppColors.red
                      : null),
        ),
      ),
    );
  }
}
