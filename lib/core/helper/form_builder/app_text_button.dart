import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../../../features/settings/se1_profile/presentation/ui/pages/personal_info_screen.dart';
import '../../../features/settings/se4_health_insurance/presentation/ui/pages/settings_health_insurance.dart';

class AppTextButton extends StatefulWidget {
  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.borderRadius,
    required this.backgroundColor,
    this.text,
    this.textStyle,
    this.customWidget,
    this.height,
    this.width,
  });

  final Function() onPressed;
  final double? width;
  final double? height;
  final String? text;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final double borderRadius;
  final Widget? customWidget;

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton>
    with SingleTickerProviderStateMixin {
  // ✅ Initialize HapticController

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    // ✅ Trigger haptic feedback
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    // ✅ Play animation
    await _controller.forward();
    widget.onPressed.call();

    // Reset animation after action
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 20.w,
            ),
            child: FittedBox(
              child: Center(
                child: widget.customWidget ??
                    Text(
                      widget.text ?? S.of(context).click,
                      style: widget.textStyle,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}