/// Module: roles / r5_system_logs / presentation / ui / widgets
///
/// ************************ FILE INFO ******************** ///
/// FILE NAME: custom_table_body.dart
/// PURPOSE: this file contains the custom table body.
/// Author: Amr Mesbah
/// Created At: 2/2/2025
/// Updated: 30/8/2026 - Now the read-mode half of `UserText`
///          (r4_active_directory/.../user_data_widgets/text_widget.dart),
///          so a system logs cell and an Active Directory cell are the same
///          cell. Three things changed and all three were what made the two
///          tables look different:
///            * the fixed `width: 0.2.w / 0.17.w` is gone — it forced every
///              column to one fifth of the screen regardless of content,
///              which is why the logs table had huge columns and needed a
///              hand-guessed scroll width. `DataTable` measures columns now.
///            * the text style is `StyleText.fontSize16Weight600`
///              instead of `AppFontStyle.cairoRegularStyle` at a
///              fraction-of-screen size.
///            * alignment is `centerStart`, not centred, and an empty value
///              renders as `-` rather than a blank cell.
///          Height is pinned to 38.h to match `UserText`, which pins it so a
///          row never changes height; `DefaultDataTable` clamps the row to
///          46.h either way.
/// Updated: 30/8/2026 - Values are centred under their heading and set at
///          12.sp (headings are 14.sp), replacing start-aligned 16.sp text.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Was a StatefulWidget with no mutable state and a non-const constructor
/// missing `key` (§17/§18); the unused `flutter/services.dart` import went too.
class CustomTableBody extends StatelessWidget {
  final String text;
  final Color? textColor;

  const CustomTableBody({super.key, required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return SizedBox(
      height: 38.h,
      // CHANGED 30/8/2026: centred, and 12.sp.
      //
      // `Align` fills the width `DataTable` hands the cell (its width factor is
      // left null on purpose), so `Alignment.center` sets the value under the
      // middle of its heading, which is centred too now. `Alignment`, not
      // `AlignmentDirectional`: dead centre is the same point in both text
      // directions, and the direction-aware variant would only suggest the
      // sides matter here.
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text.isEmpty ? '-' : text,
          // 12.sp against the heading's 14.sp. Was
          // `font16BlackSemiBoldCairo` — a value two steps LARGER than the
          // heading above it.
          style: StyleText.fontSize12Weight600.copyWith(
            color: textColor ??
                (lightMode ? AppColors.black : AppColors.white),
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
