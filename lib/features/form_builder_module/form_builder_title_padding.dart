/// Module: form_builder_module
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_title_padding.dart
/// Purpose: The single page-title padding every Form Builder page uses.
/// Author: Knowticed Plus team
/// Added: 18/8/2026

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 20.sp on all four sides, applied to the breadcrumb / page title of EVERY
/// page in `form_builder_module`.
///
/// ADDED 18/8/2026. The breadcrumb widgets ship other defaults —
/// `PaginationAppBar` had 30.sp vertical and **no horizontal padding at all**
/// (which is why the title sat flush against the page edge), and
/// `SideFrameMasterServices` uses 15.sp — and both are shared with other
/// modules, so their defaults are deliberately left alone. This value is
/// passed in explicitly at each Form Builder call site instead.
///
/// Change it here, not at a call site: the point of the constant is that the
/// title cannot drift page to page, which is exactly what it did before.
/// Not `const` because `.sp` needs ScreenUtil initialised at call time.
EdgeInsets get formBuilderTitlePadding =>
    EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp);
