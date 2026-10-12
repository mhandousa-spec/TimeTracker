/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: get_pages.dart
/// Purpose: Declares `AppPages`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 5/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing the get pages for the app.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/poll_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/all_chat_view_tablet.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/all_chats_view_mobile.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/confirm_caption_view.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/doc_view.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/image_interact_view.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/widgets/poll_details_view.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/pages/mobile/mobile_group_chat_profile_view.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/pages/mobile/mobile_single_chat_profile_view.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/pages/tablet/create_group_page_tablet.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_binding.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/messages_bindings.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/starred_messages_view.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/maps_view.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/media/media_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/media_binding.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/mobile_media_view.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/edit_home_page.dart';
import 'package:knowticed_plus/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/pages/personal_info_screen.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/pages/social_screen.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/pages/company_info_screen.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/sections/company_info.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/settings_health_insurance.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_page.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/about_this_app_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/comments_and_feedback_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/language_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/privacy_Statement.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/terms_and_conditions.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/pages/watermark_screen.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

abstract class AppPages {
  static const initial = Routes.tabBar;

  static final routes = [
    // Routes.message removed — mobile chat is now opened via Navigator.push
    // with ChatMobileView receiving its cubits by constructor (pure Bloc, §3).
    GetPage(
        name: Routes.groupChatProfile,
        page: () => const MobileGroupChatProfileView(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(
          milliseconds: 400,
        ),
        binding: MessagesBindings()),
    GetPage(
      name: Routes.singleChatProfile,
      page: () => const MobileSingleChatProfileView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.starredMessages,
      page: () => StarredMessagesView(
        title: Get.arguments?['title'] as String,
        imageUrl: Get.arguments?['imageUrl'] as String?,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: MessagesBindings(),
    ),
    GetPage(
      name: Routes.confirmCaptionScreen,
      page: () => ConfirmCaptionView(
        files: Get.arguments?['files'] as List<PlatformFile>,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.media,
      page: () => MobileMediaView(
        model: Get.arguments!['media'] as MediaModel,
        recieverName: Get.arguments!['recieverName'] as String,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: MediaBindings(),
    ),

    GetPage(
      name: Routes.maps,
      page: () => MapsView(
        isSelecting: Get.arguments['isSelecting'] as bool,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 350,
      ),
    ),
    GetPage(
      name: Routes.imageInteract,
      page: () => ImageInteractView(
        image: Get.arguments['image'] as File,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 430,
      ),
    ),
    GetPage(
      name: Routes.pollDetails,
      page: () => PollDetailsView(
        model: Get.arguments['pollModel'] as PollMessageModel,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.docView,
      page: () => DocView(
        model: Get.arguments['docMessageModel'] as DocMessageModel,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.allChatsViewMobile,
      page: () => AllChatsViewMobile(
        message: Get.arguments['forwardMessage'] as List<MessageModel>,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: Routes.allChatsViewTablet,
      page: () => AllChatViewTablet(
        message: Get.arguments['forwardMessage'] as List<MessageModel>,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    //***************** Group ****************
    GetPage(
      name: Routes.createGroupPageMobile,
      page: () => CreateGroupPageTablet(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: Routes.createGroupPageTablet,
      page: () => CreateGroupPageTablet(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),

    //***************** Onboarding ****************
    GetPage(
      name: Routes.onboardingIntro,
      page: () => const WelcomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.onboardingSignIn,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    //***************** Settings ****************
    // CR-SKEL-SEMAIN-N16. settings_layout.dart used to build these routes
    // inline. Each destination was pushed wrapped in a bare `Scaffold` (the
    // AppBar branch there was unreachable — every call site was guarded by
    // `isMobile`), so the wrapper is reproduced exactly here.
    ...<MapEntry<String, Widget Function()>>[
      MapEntry(Routes.settingsPersonalInfo, () => const PersonalInfoScreen()),
      MapEntry(Routes.settingsHealthInsurance,
          () => const SettingsHealthInsurance()),
      MapEntry(Routes.settingsSocial, () => const SocialScreen()),
      MapEntry(Routes.settingsRequests, () => const MyRequestPage()),
      // Branding opens CompanyInfoScreen and "Company Information" opens
      // CompanyScreenInfo — confusingly named, but that is what the menu did.
      MapEntry(Routes.settingsBrandingAndTheme, () => CompanyInfoScreen()),
      MapEntry(Routes.settingsCompanyInfo, () => const CompanyScreenInfo()),
      MapEntry(Routes.settingsLanguage, () => const LanguageScreen()),
      MapEntry(Routes.settingsCommentsAndFeedback,
          () => const CommentsAndFeedbackScreen()),
      MapEntry(Routes.settingsAboutThisApp, () => const AboutThisAppScreen()),
      MapEntry(
          Routes.settingsTermsAndConditions, () => const TermsConditions()),
      MapEntry(
          Routes.settingsPrivacyStatement, () => const PrivacyStatementPage()),
    ].map((MapEntry<String, Widget Function()> entry) => GetPage(
          name: entry.key,
          // WatermarkLayer wraps the Scaffold BODY, not the Scaffold: the stamp
          // belongs over the page's content, and wrapping the Scaffold itself
          // would put it over the system chrome too.
          //
          // This one `.map` is every pushed settings destination, so a page
          // added to the list above is watermarked without touching this line.
          //
          // `module: Modules.settings` ADDED 2/9/2026 — these are all settings
          // pages, and the grid's Settings tile has to reach them.
          page: () => Scaffold(
            body: WatermarkLayer(
              module: Modules.settings,
              child: entry.value(),
            ),
          ),
          transition: Transition.rightToLeftWithFade,
          transitionDuration: const Duration(milliseconds: 300),
        )),

    // Pushed without the Scaffold wrapper — EditHomePage builds its own.
    GetPage(
      name: Routes.settingsHomeLayout,
      page: () => WatermarkLayer(
        module: Modules.settings,
        child: EditHomePage(),
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Settings > Home Layout > Watermark.
    //
    // CHANGED 31/8/2026 — this comment used to say the screen "works identically
    // pushed here or embedded as the right-hand panel in SettingsLayout". The
    // panel is gone: this route is now the ONLY way in, exactly as it is for
    // settingsHomeLayout directly above.
    //
    // Pushed without a Scaffold wrapper — WatermarkScreen builds its own, the
    // same as EditHomePage, so both siblings render an identical page frame and
    // breadcrumb.
    GetPage(
      name: Routes.settingsWatermark,
      // NOT WRAPPED, EVER — 2/9/2026.
      //
      // This used to be `WatermarkLayer(child: WatermarkScreen())`, on the
      // reasoning that the editor should be stamped like every other page or it
      // would "lie about what the setting does". In practice it does the
      // opposite: the stamp is drawn from the SAVED settings, so it sat over
      // the controls at whatever the last save said while the admin was busy
      // choosing something else — a second, stale watermark competing with the
      // live one in the preview pane right next to it, over the very sliders
      // being dragged.
      //
      // The preview pane IS this screen's watermark, and it shows the DRAFT.
      // That is the honest rendering; a stamp over the chrome adds nothing and
      // obscures the thing being edited.
      //
      // Deliberately not `module: Modules.settings` either: the Settings tile
      // must not be able to switch this back on. If a future change wraps this
      // route again, it undoes a decision, not an oversight.
      page: () => const WatermarkScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  /// Function Name: [route]
  ///
  /// Purpose: Resolve a name from [routes] into a pushable [Route].
  ///
  /// Why this exists: the app does not pass `getPages` to `GetMaterialApp`, so
  /// `pushNamed` has no generator to resolve against, and the tablet settings
  /// pane runs its own nested `Navigator`. This lets a call site push by name —
  /// `Navigator.of(context).push(AppPages.route(Routes.settingsSocial))` —
  /// with the page builders still declared here rather than inline in the UI
  /// (§14).
  ///
  /// Parameters:
  /// - [name]: a constant from [Routes].
  ///
  /// Returns: [Route<dynamic>].
  ///
  /// Throws: [ArgumentError] when [name] is not registered — a wiring mistake
  /// that should fail loudly in development, not navigate somewhere arbitrary.
  static Route<dynamic> route(String name) {
    final Route<dynamic>? resolved = maybeRoute(RouteSettings(name: name));
    if (resolved == null) {
      throw ArgumentError.value(name, 'name', 'No GetPage registered for it');
    }
    return resolved;
  }

  /// Function Name: [maybeRoute]
  ///
  /// Purpose: `onGenerateRoute` helper for nested navigators.
  ///
  /// Returns: [Route<dynamic>?] — `null` when the name is unknown, so the
  ///          caller can fall back to its own default page.
  static Route<dynamic>? maybeRoute(RouteSettings settings) {
    for (final GetPage<dynamic> page in routes) {
      if (page.name == settings.name) {
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => page.page(),
        );
      }
    }
    return null;
  }
}
