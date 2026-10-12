import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';

class AvatarStack extends StatelessWidget {
  final List<String> imageUrls;
  final int maxVisible;
  final double avatarSize;
  final double overlap;

  const AvatarStack({
    super.key,
    required this.imageUrls,
    this.maxVisible = 3,
    this.avatarSize = 40,
    this.overlap = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty list
    if (imageUrls.isEmpty) {
      return SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: AppColors.grey,
          child: Icon(
            Icons.people_outline,
            size: avatarSize * 0.5,
            color: AppColors.grey,
          ),
        ),
      );
    }

    int remainingCount =
    imageUrls.length > maxVisible ? imageUrls.length - maxVisible : 0;
    int visibleCount =
    imageUrls.length > maxVisible ? maxVisible : imageUrls.length;

    return Row(
      children: [
        SizedBox(
          width: (avatarSize * visibleCount) - (overlap * (visibleCount - 1)),
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < visibleCount; i++)
                Positioned(
                  left: i * (avatarSize - overlap),
                  child: _buildAvatar(imageUrls[i]),
                ),
            ],
          ),
        ),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '+${FormDateTimeHelper.formatInt(remainingCount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(String imageUrl) {
    // Check if URL is valid
    final bool hasValidUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    if (hasValidUrl) {
      return CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          
        },
      );
    } else {
      // No valid URL - show icon
      return CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.person,
          size: avatarSize * 0.5,
          color: AppColors.white,
        ),
      );
    }
  }
}