/// Module: roles / r4_active_directory / presentation / ui / widgets / tabs
///
///*************************** FILE INFO ****************************///
/// File Name: wrong_data_tab.dart
/// Purpose: Declares `WrongData`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

//Youssef Ashraf — refactored by Amr Mesbah
/// WrongData tab — renders invalid employees table.
/// When [controller.isEditMode] is true, a dedicated actions column appears
/// as the FIRST column (before all data), showing per-row:
///   • pencil icon  → toggles that row into edit mode
///   • red-circle minus → (while NOT editing) delete/remove row
///   • restore/undo icon → (while editing) replaces minus, discards row edits
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/id_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/wrong_data_widgets/editable_text_widget.dart';

import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

/// Was `extends GetView<ActiveDirectoryController>`, whose inherited
/// `controller` getter is a GetX service-locator lookup. Now a plain
/// StatelessWidget resolving the same instance through the DI seam.
class WrongData extends StatelessWidget {
  /// The shared active-directory controller.
  ActiveDirectoryController get controller => AppControllers.activeDirectory;

  final bool isVertical;

  const WrongData(this.isVertical, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
      bloc: AppControllers.activeDirectory,
      builder: (context, state) {
        final controller = AppControllers.activeDirectory;
        // ── Build columns ────────────────────────────────────────────────
        // Skip the last enum value (was previously the actions slot)
        final dataColumnNames = EmployeeDataItems.values
            .take(EmployeeDataItems.values.length - 1)
            .map((e) => e.name)
            .toList();

        final List<DataColumn> columns = [
          // Actions column — first, only when edit mode is active
          if (controller.isEditMode)
            DataColumn(
              label: SizedBox(width: 56.w), // blank header
            ),
          ...dataColumnNames.map(
                (name) => DataColumn(
              label: Text(
                name,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: isVertical
                      ? FontConstants.fontSize022.w
                      : FontConstants.fontSize015.w,
                  fontWeight: FontWeight.w500,
                  color: AppColors.colorWhite,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ];

        // ── Build rows ───────────────────────────────────────────────────
        final List<DataRow> rows = List.generate(
          controller.rowInvalid.length,
              (row) {
            final List<DataCell> cells = [];

            // ── Actions cell — first cell, only in edit mode ─────────────
            if (controller.isEditMode) {
              cells.add(
                DataCell(
                  BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
                    bloc: AppControllers.activeDirectory,
                    builder: (context, state) {
                      final controller = AppControllers.activeDirectory;
                      final bool isRowEditing =
                      controller.isInvalidEditable[row];

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ── Pencil / X icon ──────────────────────────
                          GestureDetector(
                            onTap: () {
                              if (isRowEditing &&
                                  controller.isInvalidChanged[row]) {
                                controller.saveInvalidChanges(rowIndex: row);
                              }
                              controller.toggleRowEditInvalid(row);
                            },
                            child: SvgPicture.asset(
                              isRowEditing
                                  ? 'assets/icons_assets/messaging_assets/close_x_teal.svg'
                                  : 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                              width: 16.w,
                              height: 16.h,
                              colorFilter: ColorFilter.mode(
                                AppColors.text,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // ── Minus (delete) OR Restore icon ───────────
                          // Not editing → red minus circle → remove row
                          // Editing     → restore/undo → discard row edits
                          GestureDetector(
                            onTap: () {
                              if (isRowEditing) {
                                // Restore: discard this single row's changes
                                controller.invalidChangedFields[row] =
                                    List.from(controller.rowInvalid[row]);
                                controller.isInvalidChanged[row] = false;
                                controller.isInvalidEditable[row] = false;
                                controller.refresh();
                              } else {
                                // Remove row confirmation
                                showDialog(
                                  context: context,
                                  builder: (_) => _RemoveConfirmDialog(
                                    onConfirm: () async {
                                      Navigator.pop(context);
                                      await controller
                                          .removeInvalidEmployee(row);
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                          const _SuccessRemoveDialog(),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                            child: isRowEditing
                            // ── Restore icon (orange) ──────────────
                                ? SvgPicture.asset(
                              'assets/icons/restore_row.svg',
                              width: 16.w,
                              height: 16.h,
                              colorFilter:  ColorFilter.mode(
                                AppColors.orange,
                                BlendMode.srcIn,
                              ),
                            )
                            // ── Red minus circle ───────────────────
                                : Container(
                              width: 18.w,
                              height: 18.w,
                              decoration:  BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: AppColors.white,
                                size: 12.w,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }

            // ── Data cells ───────────────────────────────────────────────
            final dataColumnCount = EmployeeDataItems.values.length - 1;
            for (int column = 0; column < dataColumnCount; column++) {
              cells.add(
                DataCell(
                  BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
                    bloc: AppControllers.activeDirectory,
                    builder: (context, state) {
                      final controller = AppControllers.activeDirectory;
                      return EditableTextWidget(
                        text: FormatHelper.capitalize(
                          controller.invalidChangedFields[row][column] ?? '',
                        ),
                        isEditable: controller.isInvalidEditable[row],
                        isOptional: ActiveDirectoryConstants.optionalItems
                            .contains(EmployeeDataItems.values[column]),
                        onChanged: (value) {
                          controller.isInvalidChanged[row] = true;
                          controller.isInvalidSaved[row] = false;
                          controller.invalidChangedFields[row][column] =
                              value.toLowerCase();

                          if (column == 13 || column == 15 || column == 17) {
                            controller.refresh();
                          }
                        },
                        titleValidator: (v) {
                          return column == 14 || column == 16 || column == 18
                              ? EmployeeDataItems.values[column].validateTitle
                              ?.call(
                            '${controller.invalidChangedFields[row][column - 1].toString()}-$v',
                          )
                              : EmployeeDataItems.values[column].validateTitle
                              ?.call(v);
                        },
                        validator: (v) {
                          return column == 14 || column == 16 || column == 18
                              ? EmployeeDataItems.values[column].validate.call(
                            '${controller.invalidChangedFields[row][column - 1].toString()}-$v',
                          )
                              : EmployeeDataItems.values[column].validate
                              .call(v);
                        },
                      );
                    },
                  ),
                ),
              );
            }

            return DataRow(
              color: WidgetStatePropertyAll(
                row % 2 == 0
                    ? themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.evenRowColor
                    : AppColors.darkBackGround
                    : themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorWhite
                    : AppColors.oddRowColor,
              ),
              cells: cells,
            );
          },
        );

        return Expanded(
          child: DefaultDataTable(
            columns: columns,
            rows: rows,
          ),
        );
      },
    );
  }
}

// ─── Confirm remove dialog ────────────────────────────────────────────────────

class _RemoveConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _RemoveConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        S.of(context).removingEmployee,
        textAlign: TextAlign.center,
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: FontConstants.fontSize018.w,
        ),
      ),
      content: Text(
        S.of(context).areYouSureYouWantToRemoveThisEmployee,
        textAlign: TextAlign.center,
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: FontConstants.fontSize014.w,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            S.of(context).no,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: FontConstants.fontSize014.w,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.delete,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onConfirm,
          child: Text(
            S.of(context).yes,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: FontConstants.fontSize014.w,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Success remove dialog ────────────────────────────────────────────────────

class _SuccessRemoveDialog extends StatelessWidget {
  const _SuccessRemoveDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        S.of(context).employeeRemoved,
        textAlign: TextAlign.center,
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: FontConstants.fontSize018.w,
        ),
      ),
      content: Text(
        S.of(context).youSuccessfullyRemovedEmployee,
        textAlign: TextAlign.center,
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: FontConstants.fontSize014.w,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.signOut,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            S.of(context).ok,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: FontConstants.fontSize014.w,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}