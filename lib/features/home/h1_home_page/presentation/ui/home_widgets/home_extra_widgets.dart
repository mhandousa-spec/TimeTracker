/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_extra_widgets.dart
/// Purpose: The four Adding Widget cards Figma shows that had no
///          `HomeComponents` value at all — `EmployeeMessagesWidget`,
///          `GroupMessagesWidget`, `FormsSubmission` and `LowStocks`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// Source: Figma file BuJXLizpGcK5eHVBqQomXc, Settings > Home Layout >
/// Adding Widget, iPad Horizontal View (node 4717:68984). Figures are the
/// placeholder values from the Figma frames, like the rest of the picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_responsive_page.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/forms_submission_summary.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/forms/forms_actions.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_shortcut.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Placeholder employee name shown in the preview rows.
const String _kSampleEmployee = 'Moataz Handousa';

/// One avatar + name + Messages button, repeated across the contacts card.
class _MessageContact extends StatelessWidget {
  final String name;

  /// Null renders the plain grey placeholder circle Figma uses for a group.
  final String? avatar;

  const _MessageContact({required this.name, this.avatar});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: avatar == null
              ? null
              : CustomSvgImage(
                  assetPath: avatar!,
                  width: 32.r,
                  height: 32.r,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(height: 4.h),
        Text(
          name,
          style: CardStyles.label(8),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        HomeCardButton(label: l.messages),
      ],
    );
  }
}

/// Figma: the four-employee contacts card, three grid columns wide.
class EmployeeMessagesWidget extends StatelessWidget {
  /// Carried for parity with every other component widget.
  final HomeComponentModel model;

  const EmployeeMessagesWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.employeeMessages,
      icon: HomeWidgetSvg.messages,
      width: kHomeWidgetWideWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < 4; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 8.w),
            const Expanded(
              child: _MessageContact(
                name: _kSampleEmployee,
                avatar: HomeWidgetSvg.avatar,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Figma: the single-group messages card, one grid column wide.
class GroupMessagesWidget extends StatelessWidget {
  final HomeComponentModel model;

  const GroupMessagesWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.groupMessages,
      icon: HomeWidgetSvg.messages,
      width: kHomeWidgetNarrowWidth,
      child: _MessageContact(name: l.groupName),
    );
  }
}

/// Figma: "Forms Submission" — a completion ring plus the two form actions.
///
/// CHANGED 26/9/2026 (form bug report #25): was a static Figma placeholder
/// (75%, "Form Name", buttons with no onTap). It now shows the user's latest
/// published form with its real submitted / sent ratio; "View Submissions"
/// opens that form's Results inside the Form Builder module and "Remind All"
/// sends the reminders exactly like the Pending tab does.
class FormsSubmission extends StatefulWidget {
  final HomeComponentModel model;

  const FormsSubmission({super.key, required this.model});

  @override
  State<FormsSubmission> createState() => _FormsSubmissionState();
}

class _FormsSubmissionState extends State<FormsSubmission>
    with TickerProviderStateMixin {
  final FormsSubmissionSummary _summary = FormsSubmissionSummary();
  bool _loading = true;
  bool _hasForm = false;

  @override
  void initState() {
    super.initState();
    _summary.load(this).then((ok) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasForm = ok;
      });
    });
  }

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  void _viewSubmissions() {
    final form = _summary.form;
    if (form == null) {
      // Bug report p.2: with no published form both buttons used to be
      // disabled (onTap: null), which read as "not working". Open the Form
      // Builder on its Publish tab instead.
      openFormBuilderFromHome(context, shortcut: FormBuilderShortcut.publish);
      return;
    }
    FormResponsivePageLayout.pendingResultForm = form;

    if (MediaQuery.of(context).size.width >= 600) {
      final drawer = NotificationRouting.drawerCubit();
      final index = drawer.allowedDrawerModules.indexOf(Modules.formBuilder);
      if (index == -1) {
        FormResponsivePageLayout.pendingResultForm = null;
        return;
      }
      drawer.updateSelectedIndex(index);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => Modules.formBuilder.widget),
      );
    }
  }

  Future<void> _remindAll() async {
    if (_summary.form == null) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: Directionality.of(context) == TextDirection.rtl
            ? 'لا توجد نماذج منشورة'
            : 'No Published Forms',
        subtitle: Directionality.of(context) == TextDirection.rtl
            ? 'انشر نموذجًا أولًا لإرسال التذكيرات.'
            : 'Publish a form first to send reminders.',
      );
      return;
    }
    final sent = await _summary.remindAll();
    if (!mounted) return;
    setState(() {});
    if (sent > 0) {
      CustomDialogManager.showSuccess(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
        title: Directionality.of(context) == TextDirection.rtl
            ? 'تم إرسال التذكير بنجاح'
            : 'Reminder Sent Successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final double completion = _summary.completion;
    final String formTitle = _loading
        ? '...'
        : (_hasForm ? (_summary.form?.getTitle ?? l.formName) : l.formName);

    return HomeWidgetCard(
      title: l.formsSubmission,
      icon: HomeWidgetSvg.serviceRequest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formTitle,
                      style: CardStyles.value(11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasForm)
                      Text(
                        '${_summary.submitted}/${_summary.submitted + _summary.pending}',
                        style: CardStyles.label(9),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 38.r,
                height: 38.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: _loading ? null : completion,
                      strokeWidth: 4,
                      backgroundColor: AppColors.background,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.green),
                    ),
                    if (!_loading)
                      Text(
                        '${(completion * 100).round()}%',
                        style: CardStyles.value(9),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Expanded(
                child: HomeCardButton(
                  label: l.viewSubmissions,
                  onTap: _loading ? null : _viewSubmissions,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: HomeCardButton(
                  label: l.remindAll,
                  icon: HomeWidgetSvg.bell,
                  onTap: _loading ? null : _remindAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Figma: "Low Stocks" — reorder thresholds, a remaining-stock bar, and the
/// products currently under their reorder level.
class LowStocks extends StatelessWidget {
  final HomeComponentModel model;

  const LowStocks({super.key, required this.model});

  /// Units left against the reorder quantity, as Figma labels them.
  static const int _left = 30;
  static const int _reorderLevel = 40;
  static const int _reorderQuantity = 100;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.lowStocks,
      icon: HomeWidgetSvg.lowStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l.reorderLevel} $_reorderLevel',
                  style: CardStyles.label(8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${l.reorderQuantity} $_reorderQuantity',
                  style: CardStyles.label(8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: <Widget>[
              Text(
                '$_left ${l.left}',
                style: CardStyles.value(9).copyWith(color: AppColors.red),
              ),
              const Spacer(),
              Text('$_reorderQuantity', style: CardStyles.label(9)),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: <Widget>[
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _left / _reorderQuantity,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Products under the threshold. The first reads as selected, the
          // rest as plain chips, exactly as Figma draws the row.
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 4.w),
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l.productName,
                      style: CardStyles.label(8).copyWith(
                        color: i == 0 ? AppColors.textButton : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
