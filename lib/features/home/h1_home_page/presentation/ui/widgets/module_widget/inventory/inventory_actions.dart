/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_actions.dart
/// Purpose: Declares `InventoryActions`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
class InventoryActions extends StatelessWidget {
  InventoryActions({super.key, required this.model});
  HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return StandardContainer(
        child: SizedBox(
      width: 140.sp,
      child: Column(
        spacing: 5.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).inventory,
                style: StyleText.fontSize14Weight500
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/icons_assets/roles_assets/inventory_warehouse.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          Container(),
          // CHANGED 12/9/2026 — the action buttons are `HomeCardButton`, not
          // `customButton` / `customButtonWithSvg`.
          //
          // Those two enforce the app-wide ButtonSizing rule: 135.sp on tablet, 38.sp on
          // mobile, or — when the label does not fit that — no width at all, in which
          // case the button hugs its own text. So every button in a card came out a
          // different width from the one above it, and narrower than the card holding
          // them. `HomeCardButton` is the component the newer home cards already use
          // (home_widget_shell.dart); it is full-width by default, which is what Figma
          // draws for stacked card actions and what makes every card agree.
          HomeCardButton(
            label: S.of(context).addProduct,
            icon: 'assets/icons_assets/roles_assets/inventory_warehouse.svg',
            onTap: () {},
          ),
          HomeCardButton(
            label: S.of(context).order,
            onTap: () {},
          ),
          HomeCardButton(
            label: S.of(context).approvals,
            onTap: () {},
          ),
        ],
      ),
    ));
  }
}
