/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_routes.dart
/// Purpose: App routes.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 6/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing the routes of the app.

        abstract class Routes {
  // Home
  static const tabBar = '/tabBar';

  static const home = '/home';



  // Message
  static const message = '/message';
  static const pollDetails = '/message/pollDetails';
  static const docView = '/message/docView';

  static const managementChatProfile = '/message/managementChatProfile';
  static const groupChatProfile = '/message/groupChatProfile';
  static const singleChatProfile = '/message/singleChatProfile';
  static const starredMessages = '/message/starredMessages';

  static const confirmCaptionScreen = '/message/confirmCaptionScreen';
  static const imageInteract = '/message/imageInteract';

  static const media = '/message/chatProfile/media';
  static const directMessage = '/directMessage';
  static const wallpaperCategory = '/wallpaperCategory';
  static const wallpaperDetails = '/wallpaper/wallpaperDetails';
  static const maps = '/maps';
  static const allChatsViewMobile = '/message/allChatsViewMobile';
  static const allChatsViewTablet = '/message/allChatsViewTablet';

  // emergency contact
  static const emergencyContact = '/profileMenuPage/emergencyContact';
  static const editEmergencyContact =
      '/profileMenuPage/emergencyContact/editEmergencyContact';

  // Sort
  static const sortPage = '/sortPage';

  // image picker
  static const imageOptionsDialog = '/imageOptionsDialog';


  //Customer Support
  static const customerSupport = '/customerSupport';
  static const history = '/history';

  // community - filter
  static const communityFilterPage = '/communityFilterPage';

  // community - groups
  static const createGroupPageMobile = '/createGroupPageMobile';
  static const createGroupPageTablet = '/createGroupPageTablet';


  // community - sort
  static const communitySortPage = '/communitySortPage';

  // Onboarding
  //
  // Added 12/8/2026 for CR-SKEL-O1-N06 / CR-SKEL-O2-N08: the splash screen
  // pushed an inline MaterialPageRoute and the intro carousel called
  // PersistentNavBarNavigator.pushNewScreen directly.
  static const onboardingIntro = '/onboarding/intro';
  static const onboardingSignIn = '/onboarding/signIn';

  // Settings
  //
  // Added 11/8/2026 for CR-SKEL-SEMAIN-N16: settings_layout.dart built
  // MaterialPageRoutes inline at four call sites. The destinations are declared
  // here and resolved through AppPages instead (§14).
  static const settingsPersonalInfo = '/settings/personalInfo';
  static const settingsHealthInsurance = '/settings/healthInsurance';
  static const settingsSocial = '/settings/social';
  static const settingsRequests = '/settings/requests';
  static const settingsBrandingAndTheme = '/settings/brandingAndTheme';
  static const settingsHomeLayout = '/settings/homeLayout';
  /// Settings > Home Layout > Watermark. ADDED 25/8/2026.
  static const settingsWatermark = '/settings/watermark';
  static const settingsCompanyInfo = '/settings/companyInfo';
  static const settingsLanguage = '/settings/language';
  static const settingsCommentsAndFeedback = '/settings/commentsAndFeedback';
  static const settingsAboutThisApp = '/settings/aboutThisApp';
  static const settingsTermsAndConditions = '/settings/termsAndConditions';
  static const settingsPrivacyStatement = '/settings/privacyStatement';




}
