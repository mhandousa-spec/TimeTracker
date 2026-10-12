import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

/// A4Container - Wraps content and detects when it exceeds A4 page height
/// Supports both portrait and landscape orientations
class A4Container extends StatelessWidget {
  final Widget child;
  final Function(bool) onOverflow;
  final double? horizontalPadding;
  final double? verticalPadding;
  final String? watermarkImage;
  final double watermarkSize;
  final double watermarkOpacity;
  final String? orientation;

  // ✅ A4 Paper Heights at 96 DPI
  static const double a4PortraitHeight = 1123.0;  // 297mm in pixels
  static const double a4LandscapeHeight = 794.0;  // 210mm in pixels

  const A4Container({
    super.key,
    required this.child,
    required this.onOverflow,
    this.horizontalPadding,
    this.verticalPadding,
    this.watermarkImage,
    this.watermarkSize = 100,
    this.watermarkOpacity = 100,
    this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Determine A4 height based on orientation
    final bool isLandscape = orientation?.toLowerCase().contains('landscape') ?? false;
    final double a4Height = isLandscape ? a4LandscapeHeight : a4PortraitHeight;

    // ✅ Use actual padding values with proper defaults
    final double actualHorizontalPadding = horizontalPadding ?? 16.0;
    final double actualVerticalPadding = verticalPadding ?? 16.0;

    

    

    

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).width * .41,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Stack(
        children: [
          // Watermark
          if (watermarkImage != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: Transform.scale(
                scale: watermarkSize / 100,
                child: Opacity(
                  opacity: watermarkOpacity / 100,
                  child: (watermarkImage!.contains('http'))
                      ? Image.network(watermarkImage!)
                      : Image.file(File(watermarkImage!)),
                ),
              ),
            ),

          // Content with overflow detection
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: MeasureSize(
                    onChange: (Size size) {
                      final isOverflowing = size.height > a4Height;
                      onOverflow(isOverflowing);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: actualHorizontalPadding,
                        vertical: actualVerticalPadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom widget to measure size
class MeasureSize extends StatefulWidget {
  final Widget child;
  final Function(Size) onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  GlobalKey key = GlobalKey();
  Size? oldSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  void _updateSize() {
    final context = key.currentContext;
    if (context == null) return;

    final newSize = context.size;
    if (oldSize != newSize) {
      oldSize = newSize;
      widget.onChange(newSize!);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: key,
          child: widget.child,
        ),
      ),
    );
  }
}