/// Module: roles / r1_role_management / domain / enums / settings
///
/******************** FILE INFO ********************/
/// File Name: social_permissions.dart
/// Purpose: Enum for Social Permissions in the application
/// Created by: Mohamed Elrashidy
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum SocialPermissions implements ModulePermissionsSectionsPermission {
  shareSocialInformation,
  shareEmailsAndSocialDataInBio,
  shareCellphonesInSocialDataInBio,
  academicHistory,
  certificates,
  skillsHobbies;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case shareSocialInformation:
        return 'Share_Social_Information';

      case shareEmailsAndSocialDataInBio:
        return 'Share_Emails_And_Social_Data_In_Bio';

      case shareCellphonesInSocialDataInBio:
        return 'Share_Cellphones_In_Social_Data_In_Bio';

      case academicHistory:
        return 'Academic_History';

      case certificates:
        return 'Certificates';

      case skillsHobbies:
        return 'Skills_Hobbies';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case shareSocialInformation:
        return 'Share Social Information'; // ✅ FIXED: Was using takeScreenShot

      case shareEmailsAndSocialDataInBio:
        return 'Share Emails And Social Data In Bio';

      case shareCellphonesInSocialDataInBio:
        return 'Share Cellphones In Social Data In Bio';

      case academicHistory:
        return 'Academic History';

      case certificates:
        return 'Certificates';

      case skillsHobbies:
        return 'Skills Hobbies';
    }
  }
}