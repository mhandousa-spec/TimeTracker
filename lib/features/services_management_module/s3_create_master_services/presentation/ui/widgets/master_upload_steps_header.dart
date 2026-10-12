/// Module: services_management_module
/// Description: Two-step progress header ("1: Services Data" ->
///              "2: Service Requests") shown at the top of the master
///              upload screen. Each step is rendered as a bordered chip with
///              an info badge; tapping the badge opens an overlay card that
///              explains what the step does.
/// Author: Knowticed Team
/// Date: 09/08/2026
/// Dependencies: AppColors, StyleText
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from master_upload.dart
///     (fix item 5 — page LOC reduction).
///   - 09/08/2026 (Knowticed Team): Rebuilt to match the Figma spec — step
///     chips with borders/disabled state and a tappable "!" info badge that
///     opens a bulleted overlay card.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MasterUploadStepsHeader extends StatelessWidget {
  final bool step1Completed;

  const MasterUploadStepsHeader({super.key, required this.step1Completed});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StepChip(
          stepNumber: '1',
          title: S.of(context).servicesData,
          isActive: true,
          isCompleted: step1Completed,
          bullets: _MasterUploadStepInfo.step1(isArabic),
          // First chip sits on the leading edge — grow the card the same way.
          anchorToTrailingEdge: false,
        ),
        // ✅ Connector line between the two steps.
        //
        // Only drawn once step 1 is done — it reads as the progress track
        // filling in behind the check mark, so before the first file is
        // uploaded there is nothing to connect and the gap stays empty.
        //
        // [Expanded] rather than a fixed gap so the line stretches to whatever
        // space is left between the chips, and so the space is reserved
        // either way: the chips do not shift when the line appears.
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: step1Completed
                ? Container(
                    height: 1.sp,
                    color: AppColors.grey,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        _StepChip(
          stepNumber: '2',
          title: S.of(context).serviceRequests,
          isActive: step1Completed,
          isCompleted: false,
          bullets: _MasterUploadStepInfo.step2(isArabic),
          // Second chip sits on the trailing edge — keep the card on screen.
          anchorToTrailingEdge: true,
        ),
      ],
    );
  }
}

// ───────────────────────────── Step chip ─────────────────────────────

class _StepChip extends StatelessWidget {
  final String stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final List<String> bullets;
  final bool anchorToTrailingEdge;

  const _StepChip({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.bullets,
    required this.anchorToTrailingEdge,
  });

  @override
  Widget build(BuildContext context) {
    // Active = bordered chip on the card colour. Inactive = flat grey slab,
    // which is how the disabled second step reads in the Figma spec.
    final Color background =
        isActive ? AppColors.card : AppColors.grey.withOpacity(0.25);
    final Color borderColor =
        isActive ? AppColors.primary : Colors.transparent;
    final Color labelColor =
        isActive ? AppColors.text : AppColors.secondaryText;

    return Container(
      constraints: BoxConstraints(minWidth: 220.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 11.sp),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.sp),
              child: Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.green,
              ),
            ),
          Flexible(
            child: Text(
              '$stepNumber: $title',
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(
                color: labelColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.sp),
          _StepInfoBadge(
            bullets: bullets,
            anchorToTrailingEdge: anchorToTrailingEdge,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Info badge + overlay ──────────────────────

/// The dark "!" circle. Tapping it opens [_StepInfoCard] in an [Overlay]
/// anchored to the badge; tapping anywhere else dismisses it.
class _StepInfoBadge extends StatefulWidget {
  final List<String> bullets;
  final bool anchorToTrailingEdge;

  const _StepInfoBadge({
    required this.bullets,
    required this.anchorToTrailingEdge,
  });

  @override
  State<_StepInfoBadge> createState() => _StepInfoBadgeState();
}

class _StepInfoBadgeState extends State<_StepInfoBadge> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  bool get _isOpen => _entry != null;

  @override
  void dispose() {
    // Guard against leaking the entry if the chip is disposed while open.
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void _open() {
    final overlay = Overlay.of(context);
    final bool trailing = widget.anchorToTrailingEdge;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Barrier: any tap outside the card closes it.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor:
                trailing ? Alignment.bottomRight : Alignment.bottomLeft,
            followerAnchor:
                trailing ? Alignment.topRight : Alignment.topLeft,
            offset: Offset(0, 10.sp),
            child: _StepInfoCard(bullets: widget.bullets),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final Color circleColor =
        lightMode ? AppColors.blackButton : AppColors.white;
    final Color glyphColor =
        lightMode ? AppColors.white : AppColors.blackButton;

    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        button: true,
        label: 'Step information',
        child: GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: _isOpen
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.45),
                          blurRadius: 6,
                          spreadRadius: 1.5,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '!',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: glyphColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepInfoCard extends StatelessWidget {
  final List<String> bullets;

  const _StepInfoCard({required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360.sp,
        constraints: BoxConstraints(maxHeight: 320.sp),
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.secondaryText.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < bullets.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == bullets.length - 1 ? 0 : 10.sp,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.sp),
                        child: Container(
                          width: 5.sp,
                          height: 5.sp,
                          decoration: BoxDecoration(
                            color: AppColors.text,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          bullets[i],
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.text,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────── Copy ───────────────────────────────────

/// Info-card copy, kept here rather than in the .arb files so the widget
/// compiles without an intl regeneration step. Move to `S.of(context)` and
/// run the l10n generator when convenient.
class _MasterUploadStepInfo {
  const _MasterUploadStepInfo._();

  static List<String> step1(bool isArabic) => isArabic
      ? const [
          'أنت على وشك رفع عدة خدمات دفعة واحدة باستخدام ملف بصيغة محددة. في هذه الخطوة سوف:',
          'تضيف أسماء الخدمات (بالعربية والإنجليزية)، وتحدد أوصاف الخدمات، ومدة الخدمة ووحدة الوقت، وتعيّن الإدارات المالكة، وتختار مقدمي الخدمة، وتضبط إعدادات الإتاحة والموافقات.',
          'بعد الرفع ستراجع جميع السجلات في وضع المعاينة، وسيتم تمييز أي بيانات ناقصة أو غير صحيحة.',
          'تأكد من أن الملف يتبع الصيغة المطلوبة لتجنب أخطاء التحقق.',
          'بعد إتمام هذه الخطوة بنجاح ستنتقل إلى: طلبات الخدمة.',
        ]
      : const [
          'You are about to upload multiple services at once using a structured file template. In this step, you will:',
          'Add service names (Arabic & English), define service descriptions, set service duration and time unit, assign owning departments, select service fulfillers, and configure availability and approval requirements.',
          'After uploading, you will review all records in preview mode. Any missing or incorrect data will be highlighted.',
          'Make sure the file follows the required format to avoid validation errors.',
          'After successfully completing this step, you will proceed to: Service Requests.',
        ];

  static List<String> step2(bool isArabic) => isArabic
      ? const [
          'أنت على وشك رفع طلبات خدمة مرتبطة بالخدمات التي تم إنشاؤها في الخطوة الأولى.',
          'في هذه الخطوة سوف: تعيّن مقدمي الطلبات والإدارات، وتحدد تواريخ الطلبات وحالاتها، وتعيّن منفذي الطلبات.',
          'سيتحقق النظام من وجود جميع الخدمات والمستخدمين قبل التأكيد.',
          'يجب إكمال الخطوة الأولى بنجاح قبل رفع الطلبات.',
        ]
      : const [
          'You are about to upload service requests linked to the services created in Step 1.',
          'In this step, you will: assign requesters and departments, define request dates and statuses, and assign request fulfillers.',
          'The system will verify that all services and users exist before confirmation.',
          'Step 1 must be completed successfully before uploading requests.',
        ];
}
