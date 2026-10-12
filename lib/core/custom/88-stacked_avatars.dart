/// Module: Core · Custom · Stacked Avatars
/// Description: Row of overlapping circular avatars with a "+N" surplus badge
///              once there are more than four. Accepts asset paths, svg paths
///              or network URLs and falls back to a person icon on error.
/// Author: Knowticed Team

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

//By: Youssef Ashraf
class StackedAvatars extends StatelessWidget {
  const StackedAvatars({
    super.key,
    this.height,
    this.width,
    this.fontSize,
    required this.images,
    this.avatarColor,
    this.avatarTextColor,
  });

  final List<String> images;
  final double? height;
  final Color? avatarColor;
  final Color? avatarTextColor;
  final double? width;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = height ?? 24.sp;
    final double totalWidth = width ?? 70.sp;
    final List<String> displayImages = images.take(4).toList();
    final int surplus = images.length - displayImages.length;
    final double overlap = avatarSize * 0.6;

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatars
          ...displayImages.asMap().entries.map((entry) {
            final int index = entry.key;
            final String imagePath = entry.value;
            return Positioned(
              left: index * overlap,
              child: _buildAvatar(imagePath, avatarSize),
            );
          }),

          // Surplus badge "+N"
          if (surplus > 0)
            Positioned(
              left: displayImages.length * overlap,
              child: _buildSurplusAvatar(surplus, avatarSize),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imagePath, double size) {
    return ClipOval(
      child: _isSvg(imagePath)
          ? SvgPicture.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : _isNetwork(imagePath)
              ? Image.network(
                  imagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(size),
                )
              : Image.asset(
                  imagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(size),
                ),
    );
  }

  Widget _buildSurplusAvatar(int surplus, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColor ?? AppColors.primary,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '+$surplus',
          style: GoogleFonts.roboto(
            fontSize: fontSize ?? 10.sp,
            fontWeight: FontWeight.w700,
            color: avatarTextColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(double size) {
    return Container(
      width: size,
      height: size,
      color: avatarColor ?? AppColors.primary,
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: avatarTextColor ?? Colors.white,
      ),
    );
  }

  bool _isSvg(String path) => path.toLowerCase().endsWith('.svg');
  bool _isNetwork(String path) => path.startsWith('http');
}
