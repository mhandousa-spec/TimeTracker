/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: forms_actions.dart
/// Purpose: Declares `FormActions`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_shortcut.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Opens the Form Builder module, optionally landing on [shortcut].
///
/// ADDED 29/9/2026 (bug report p.2 — the Home "Forms" buttons had empty
/// onTap handlers). Tablet/desktop switches the side-rail module; phone pushes
/// the module page. Same routing as the "Forms Submission" card uses.
void openFormBuilderFromHome(
  BuildContext context, {
  FormBuilderShortcut? shortcut,
}) {
  FormBuilderShortcuts.pending = shortcut;
  if (MediaQuery.of(context).size.width >= 600) {
    final drawer = NotificationRouting.drawerCubit();
    final index = drawer.allowedDrawerModules.indexOf(Modules.formBuilder);
    if (index == -1) {
      // The user has no Form Builder access — nothing to open.
      FormBuilderShortcuts.pending = null;
      return;
    }
    drawer.updateSelectedIndex(index);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => Modules.formBuilder.widget),
    );
  }
}

class FormActions extends StatelessWidget {
  FormActions({super.key, required this.model});
  HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return StandardContainer(
        child: SizedBox(
      width: 140.sp,
      child: Column(
        // 13/9/2026 — hug the content. HomeCardMetrics.fitBox constrains only
        // the MINIMUM height now, so a Column left on MainAxisSize.max would
        // stretch to whatever bound it is handed.
        mainAxisSize: MainAxisSize.min,
        spacing: 5.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).forms,
                style: StyleText.fontSize14Weight500
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/icons_assets/roles_assets/form_document.svg',
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
            label: S.of(context).createForm,
            icon: 'assets/icons_assets/roles_assets/form_document.svg',
            onTap: () => openFormBuilderFromHome(context,
                shortcut: FormBuilderShortcut.createForm),
          ),
          HomeCardButton(
            label: S.of(context).viewDraftForm,
            onTap: () => openFormBuilderFromHome(context,
                shortcut: FormBuilderShortcut.drafts),
          ),
          HomeCardButton(
            label: S.of(context).viewRequestedForm,
            onTap: () => openFormBuilderFromHome(context,
                shortcut: FormBuilderShortcut.requestedForms),
          ),
        ],
      ),
    ));
  }
}
