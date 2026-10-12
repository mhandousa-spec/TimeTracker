/// Module: messaging / chat / presentation/ui/widgets/user_image.dart
/// Purpose: Circular avatar for a [MemberEntity]. Reads the member's image
///          straight from the entity, falling back to the app's asset image
///          provider when the path isn't a network URL.
///
/// Lives in the messaging feature rather than lib/core because it depends on
/// MemberEntity, a messaging domain type.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

import '../../../../m3_groups/domain/entities/member_entity.dart';

class UserImage extends StatelessWidget {
  final MemberEntity member;
  final double radius;

  const UserImage({
    super.key,
    required this.member,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius.r,
      height: radius.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: member.memberImage.contains('http')
              ? NetworkImage(member.memberImage)
              : appImageProvider(member.memberImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
