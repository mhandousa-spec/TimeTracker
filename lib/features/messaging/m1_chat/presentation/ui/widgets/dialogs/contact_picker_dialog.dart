/// Module: messaging / chat / presentation/ui/widgets/dialogs/contact_picker_dialog.dart
/// Purpose: Contact dialog (Figma 6799:5402): search, department filter and a
///          2-column grid of colleagues with checkboxes. Send shares one
///          contact card per selected colleague.
/// Created At: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/23-custom_check_box.dart';
import '../../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../../../core/helper/message_module/main_helper/localized_text_helper.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../m2_connections/domain/entities/single_connection_entity.dart';
import 'chat_dialog_widgets.dart';

/// Shows the picker and returns the selected colleagues (empty = cancelled).
Future<List<SingleConnectionEntity>> showContactPickerDialog(
  BuildContext context, {
  required List<SingleConnectionEntity> people,
}) async {
  final List<SingleConnectionEntity>? picked =
      await showChatDialog<List<SingleConnectionEntity>>(
    context: context,
    width: 622.w,
    child: _ContactPickerDialog(people: people),
  );
  return picked ?? const <SingleConnectionEntity>[];
}

class _ContactPickerDialog extends StatefulWidget {
  const _ContactPickerDialog({required this.people});
  final List<SingleConnectionEntity> people;

  @override
  State<_ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<_ContactPickerDialog> {
  final TextEditingController _search = TextEditingController();
  final Set<String> _selected = <String>{};
  String? _departmentId; // null = all departments

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<UserCategory> get _departments {
    final Map<String, UserCategory> byId = <String, UserCategory>{};
    for (final p in widget.people) {
      final UserCategory? c = p.userCategory;
      if (c != null && c.categoryId.isNotEmpty) byId[c.categoryId] = c;
    }
    final List<UserCategory> list = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  List<SingleConnectionEntity> get _shown {
    final String q = _search.text.trim().toLowerCase();
    return widget.people.where((p) {
      if (_departmentId != null &&
          p.userCategory?.categoryId != _departmentId) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.primaryLanguageName.toLowerCase().contains(q) ||
          (p.secondaryLanguageName?.toLowerCase().contains(q) ?? false) ||
          p.userId.toLowerCase().contains(q) ||
          (p.primaryLanguageSubInfo?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _toggle(SingleConnectionEntity p) => setState(() {
        if (!_selected.remove(p.userId)) _selected.add(p.userId);
      });

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    final List<SingleConnectionEntity> shown = _shown;
    final List<UserCategory> departments = _departments;

    return SizedBox(
      height: 600.h,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChatDialogBadgeHeader(
              icon: 'assets/icons_assets/messaging_assets/contact_book.svg',
              title: isAr ? 'جهة اتصال' : 'Contact',
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ChatTextField(
                    controller: _search,
                    hint: isAr ? 'بحث' : 'Search',
                    radius: 4,
                    onChanged: (_) => setState(() {}),
                    prefix: Padding(
                      padding: EdgeInsetsDirectional.only(start: 10.w, end: 6.w),
                      child: CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/search_magnifier_alt.svg',
                        width: 16.r,
                        height: 16.r,
                        fit: BoxFit.contain,
                        color: AppColors.secondaryBlack,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 155.w,
                  child: _DepartmentDropdown(
                    departments: departments,
                    value: _departmentId,
                    onChanged: (v) => setState(() => _departmentId = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Text(isAr ? 'لا يوجد نتائج' : 'No results',
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.secondaryBlack)),
                    )
                  : LayoutBuilder(builder: (context, box) {
                      final int columns = box.maxWidth >= 480 ? 2 : 1;
                      return GridView.builder(
                        itemCount: shown.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 10.h,
                          crossAxisSpacing: 10.w,
                          mainAxisExtent: 65.h,
                        ),
                        itemBuilder: (_, i) {
                          final SingleConnectionEntity p = shown[i];
                          return _ContactCard(
                            person: p,
                            selected: _selected.contains(p.userId),
                            onTap: () => _toggle(p),
                          );
                        },
                      );
                    }),
            ),
            SizedBox(height: 16.h),
            ChatDialogButtons(
              primaryLabel: isAr ? 'إرسال' : 'Send',
              onPrimary: () {
                if (_selected.isEmpty) {
                  chatDialogToast(isAr
                      ? 'اختر جهة اتصال واحدة على الأقل'
                      : 'Select at least one contact');
                  return;
                }
                Navigator.of(context).pop(widget.people
                    .where((p) => _selected.contains(p.userId))
                    .toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentDropdown extends StatelessWidget {
  const _DepartmentDropdown({
    required this.departments,
    required this.value,
    required this.onChanged,
  });

  final List<UserCategory> departments;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    final TextStyle style =
        StyleText.fontSize12Weight400.copyWith(color: AppColors.text);
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          dropdownColor: AppColors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18.r, color: AppColors.secondaryBlack),
          hint: Text(isAr ? 'القسم' : 'Department',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryBlack)),
          items: <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(
              value: null,
              child: Text(isAr ? 'كل الأقسام' : 'All Departments',
                  style: style),
            ),
            for (final UserCategory d in departments)
              DropdownMenuItem<String?>(
                value: d.categoryId,
                child: Text(d.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final SingleConnectionEntity person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String image = person.imageUri;
    final String? department = person.userCategory?.name;
    final String? title = (person.primaryLanguageSubInfo?.isNotEmpty ?? false)
        ? LocalizedTextHelper.formatString(
            primaryLanguageText: person.primaryLanguageSubInfo!,
            secondaryLanguageText: person.secondaryLanguageSubInfo,
          )
        : null;
    final TextStyle grey = StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryBlack, letterSpacing: -0.8224, height: 1.2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            ClipOval(
              child: image.startsWith('http')
                  ? Image.network(image,
                      width: 40.r,
                      height: 40.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizedTextHelper.formatString(
                      primaryLanguageText: person.primaryLanguageName,
                      secondaryLanguageText: person.secondaryLanguageName,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.text, letterSpacing: -0.8224),
                  ),
                  if (department != null && department.isNotEmpty)
                    Text(department,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: grey),
                  if (title != null)
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: grey),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: CustomCheckBox(isSelected: selected, size: 16.r),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => CustomSvgImage(
        assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
        width: 40.r,
        height: 40.r,
        fit: BoxFit.fill,
      );
}
