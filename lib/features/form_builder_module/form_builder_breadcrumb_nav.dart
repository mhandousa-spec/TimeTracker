/// Module: form_builder_module
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_breadcrumb_nav.dart
/// Purpose: Breadcrumb tap callbacks for `SideFrameMasterServices`.
/// Author: Knowticed Plus team
/// Added: 19/8/2026
///
/// Every page in this module now draws its header with
/// `SideFrameMasterServices` (core/custom/50-custom_side_frame_master.dart)
/// instead of `CustomAppBar` / `PaginationAppBar`.
///
/// `PaginationAppBar` used to make its crumbs tappable for free — tapping the
/// n-th crumb popped `titles.length - (n + 1)` routes. `SideFrameMasterServices`
/// takes explicit `onFirstTap` / `onSecondTap` / `onThirdTap` / `onFourthTap`
/// callbacks instead, so without this the crumbs would go dead on every
/// converted page. [breadcrumbPop] reproduces the old arithmetic in one place
/// rather than in ~25 inline closures.

import 'package:flutter/material.dart';

/// A callback that pops [times] routes — the crumb-tap behaviour
/// `PaginationAppBar` had built in.
///
/// Returns null for `times <= 0`, which is the LAST crumb: it is the page you
/// are already on, so `SideFrameMasterServices` should render it inert rather
/// than as something tappable that does nothing.
VoidCallback? breadcrumbPop(BuildContext context, int times) {
  if (times <= 0) return null;
  return () {
    final navigator = Navigator.of(context);
    for (var i = 0; i < times; i++) {
      if (!navigator.canPop()) return;
      navigator.pop();
    }
  };
}
