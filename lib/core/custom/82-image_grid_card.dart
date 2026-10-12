/// Module: Core · Custom · Image Grid Card
/// Description: Rounded, clipped image tile used in media grids.
/// Author: Knowticed Team
///
/// Originally messaging/core/widgets/image_grid_card.dart. Restored here
/// because it has no messaging dependencies.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageGridCard extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final double? radius;

  const ImageGridCard({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius ?? 8.r,
        ),
      ),
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
