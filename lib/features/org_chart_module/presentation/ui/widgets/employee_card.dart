// Date Created :15/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :15/November/2023
// Objectives: this is a widget to customize the card of the employee in the org chart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_detailed_info/employee_detailed_info_screen.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employees_hr_view/employees_profile/employee_profile_mobile/employee_profile_screen_employee_view_mobile.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_helper.dart';

class EmployeeCard extends StatelessWidget {
  EmployeeCard({
    super.key,
    required this.employee,
    required this.cardColor,
    required this.isLeader,
    required this.textColor,
  });
  final NewEmployeeModelHistory employee;
  final Color textColor;
  final Color cardColor;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    List<Widget> contentCard = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
        isPortrait ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          userImage(isTablet, isPortrait),
        ],
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPortrait) SizedBox(height: 8.h),
            // ✅ Name with Marquee
            SizedBox(
              width: isTablet
                  ? isPortrait
                  ? 240.w
                  : 160.w
                  : 100.w,
              height: isTablet ? 20.h : 16.h,
              child: MarqueeText(
                text: EmployeeHelper.getEmployeeFirstAndLastNames(employee: employee),
                style: (isTablet
                    ? StyleText.fontSize16Weight600
                    : StyleText.fontSize12Weight600)
                    .copyWith(color: textColor),
              ),
            ),
            SizedBox(height: 4.h),
            // ✅ Job Title with Marquee
            SizedBox(
              width: isTablet
                  ? isPortrait
                  ? 240.w
                  : 160.w
                  : 100.w,
              height: isTablet ? 20.h : 16.h,
              child: MarqueeText(
                text: EmployeeHelper.getEmployeeJobTitle(employee: employee),
                style: (isTablet
                    ? StyleText.fontSize16Weight600
                    : StyleText.fontSize12Weight600)
                    .copyWith(color: textColor),
              ),
            ),
          ],
        ),
      )
    ];

    return GestureDetector(
      onTap: () {
        if (isTablet) {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: EmployeeDetailedInfo(employee: employee)),
          );
        } else {
          PersistentNavBarNavigator.pushNewScreen(context,
              withNavBar: false,
              screen: EmployeeProfileScreenMobileEmployeeViewScreen(
                  employee: employee));
        }
      },
      child: Container(
        width: isTablet
            ? isPortrait
            ? 300.w
            : 230.w
            : 130.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: cardColor),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: isTablet
              ? isPortrait
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: contentCard,
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: contentCard,
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: contentCard,
          ),
        ),
      ),
    );
  }

  Widget userImage(bool isTablet, bool isPortrait) {
    return ClipOval(
      child: Container(
        width: isTablet
            ? isPortrait
            ? 80.w
            : 40.w
            : 40.w,
        height: isTablet
            ? isPortrait
            ? 80.w
            : 40.w
            : 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: CustomSvgImage(
          assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Marquee Text Widget for horizontal scrolling animation - Single line only
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
    this.velocity = 30.0,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  ScrollController? _scrollController;
  AnimationController? _animationController;
  VoidCallback? _animationListener;
  void Function(AnimationStatus)? _statusListener;

  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsScrolling = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _calculateWidthAndAnimate();
      }
    });
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _cleanupAnimation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          _calculateWidthAndAnimate();
        }
      });
    }
  }

  void _cleanupAnimation() {
    if (_animationListener != null && _animationController != null) {
      _animationController!.removeListener(_animationListener!);
      _animationListener = null;
    }
    if (_statusListener != null && _animationController != null) {
      _animationController!.removeStatusListener(_statusListener!);
      _statusListener = null;
    }
    _animationController?.stop();
    if (_scrollController?.hasClients == true) {
      try {
        _scrollController?.jumpTo(0);
      } catch (e) {
        // Ignore errors
      }
    }
  }

  void _calculateWidthAndAnimate() {
    if (_isDisposed || !mounted) return;

    // Detect RTL text (Arabic, Hebrew, etc.)
    bool isRTL = false;
    if (widget.text.isNotEmpty) {
      final firstChar = widget.text.codeUnitAt(0);
      isRTL = (firstChar >= 0x0590 && firstChar <= 0x06FF);
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    if (_isDisposed || !mounted) return;

    setState(() {
      _textWidth = textPainter.width;
      _containerWidth = context.size?.width ?? 0;
      _needsScrolling = _textWidth > (_containerWidth - 5);
    });

    if (_needsScrolling && !_isDisposed && mounted) {
      _startScrolling();
    }
  }

  void _startScrolling() {
    if (_isDisposed || !mounted || _animationController == null || _scrollController == null) {
      return;
    }

    final double totalDistance = _textWidth + _containerWidth;
    final double duration = totalDistance / widget.velocity;

    _animationController!.duration = Duration(
      milliseconds: (duration * 1000).toInt(),
    );

    // Create and store the listener so we can remove it later
    _animationListener = () {
      if (_isDisposed || !mounted || _scrollController?.hasClients != true) {
        return;
      }
      try {
        final double offset = _animationController!.value * (_textWidth + _containerWidth);
        _scrollController!.jumpTo(offset);
      } catch (e) {
        // Silently ignore errors
      }
    };

    _statusListener = (AnimationStatus status) {
      if (_isDisposed || !mounted) return;

      if (status == AnimationStatus.completed) {
        if (_scrollController?.hasClients == true) {
          try {
            _scrollController!.jumpTo(0);
          } catch (e) {
            // Silently ignore errors
          }
        }

        Future.delayed(Duration(milliseconds: 500), () {
          if (!_isDisposed && mounted && _animationController != null) {
            try {
              _animationController!.forward(from: 0);
            } catch (e) {
              // Silently ignore errors
            }
          }
        });
      }
    };

    _animationController!.addListener(_animationListener!);
    _animationController!.addStatusListener(_statusListener!);

    if (!_isDisposed && mounted) {
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupAnimation();
    _animationController?.dispose();
    _scrollController?.dispose();
    _animationController = null;
    _scrollController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return SizedBox.shrink();
    }

    if (!_needsScrolling && _containerWidth > 0) {
      return Center(
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    }

    if (_scrollController == null) {
      return SizedBox.shrink();
    }

    return ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
            SizedBox(width: _containerWidth),
            Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}