/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_assets.dart
/// Purpose: Declares `AppAssets`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 6/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 4/9/2024
// Objectives: This file is responsible for providing the app assets.

// assets
abstract class AppAssets {
  //***************************** IMAGES ***************************************
  // --------------------- General ---------------------

  static const String pdf = 'assets/png_assets/pdf.png';
  static const String xls = 'assets/png_assets/xls.png';
  static const String blackGallery = 'assets/png_assets/blackGallery.png';

  // --------------------- Wallpaper ---------------------
  static const String bright = 'assets/png_assets/bright.png';
  static const String solidColor = 'assets/png_assets/solid.png';
  static const String gradient = 'assets/png_assets/gradient.png';
  static const String nature = 'assets/png_assets/nature.png';
  static const String dark = 'assets/png_assets/dark.png';

  //--------------------- Community ---------------------
  static const String user = 'assets/png_assets/user.png';
  static const String user2 = 'assets/png_assets/user2.png';
  static const String user3 = 'assets/png_assets/user3.png';
  static const String user4 = 'assets/png_assets/user4.png';
  static const String user5 = 'assets/png_assets/user5.png';
  static const String profile = 'assets/png_assets/profile.jpg';
  static const String profile2 = 'assets/png_assets/profile2.jpg';
  static const String management = 'assets/png_assets/management.jpg';
  static const String groupProfile = 'assets/png_assets/groupProfile.png';

  //****************************************************************************

//******************************* VECTORS ************************************

  static const String add = 'assets/icons_assets/main_icons_assets/vectors_add.svg';
  static const String minusCircle = 'assets/icons_assets/main_icons_assets/minus_circle.svg';
  static const String filter = 'assets/icons_assets/messaging_assets/assets_vectors_filter.svg';
  static const String arrowDown = 'assets/icons_assets/main_icons_assets/icons_arrow_down.svg';
  static const String arrowForward = 'assets/icons_assets/main_icons_assets/vectors_arrowForward.svg';
  static const String mobileArrowBack = 'assets/icons_assets/main_icons_assets/mobile_arrow_back.svg';
  static const String tabletArrowBack = 'assets/vectors/tablet_arrow_back.svg';

  static const String clock = 'assets/icons_assets/messaging_assets/vectors_clock.svg';
  static const String date = 'assets/icons_assets/messaging_assets/date.svg';

  static const String audio = 'assets/icons_assets/messaging_assets/audio.svg';

  static const String report = 'assets/icons_assets/main_icons_assets/report.svg';
  static const String link = 'assets/icons_assets/messaging_assets/vectors_link.svg';
  static const String play = 'assets/icons_assets/messaging_assets/play.svg';
  static const String pause = 'assets/icons_assets/messaging_assets/pause.svg';
  static const String video = 'assets/icons_assets/messaging_assets/vectors_video.svg';

  static const String camera = 'assets/icons_assets/messaging_assets/assets_vectors_camera.svg';

  /// ADDED 2/9/2026. The composer icons in the MESBAH Figma (MESSAGES page)
  /// come from the watermark set, not the messaging set — [camera] and [mic]
  /// above are the older, heavier glyphs and stay where they are used.
  static const String cameraWatermark = 'assets/icons_assets/watermark/Camera.svg';
  static const String micWatermark = 'assets/icons_assets/watermark/Mic.svg';
  static const String cameraCircle = 'assets/icons_assets/messaging_assets/camera_circle.svg';
  static const String galleryCircle = 'assets/icons_assets/messaging_assets/gallery_circle.svg';
  static const String galleryWhite = 'assets/icons_assets/messaging_assets/gallery_white.svg';

  static const String close = 'assets/icons_assets/messaging_assets/vectors_close.svg';
  static const String document = 'assets/icons_assets/messaging_assets/vectors_document.svg';
  static const String galleryImage = 'assets/icons_assets/messaging_assets/image_svg.svg';
  static const String audioMsg = 'assets/icons_assets/messaging_assets/audio_msg.svg';
  static const String locationMsg = 'assets/icons_assets/messaging_assets/location_msg.svg';


  static const String contactImage = 'assets/icons_assets/messaging_assets/contact_svg.svg';
  static const String poolImage = 'assets/icons_assets/messaging_assets/pool_msg.svg';

  static const String copy = 'assets/icons_assets/messaging_assets/vectors_copy.svg';
  static const String forward = 'assets/icons_assets/messaging_assets/forward.svg';
  static const String reply = 'assets/icons_assets/main_icons_assets/edit_icon.svg';
  static const String star = 'assets/icons_assets/messaging_assets/vectors_star.svg';
  static const String pin = 'assets/icons_assets/messaging_assets/vectors_pin.svg';
  static const String trash = 'assets/icons_assets/main_icons_assets/icon _trash.svg';
  static const String search2 = 'assets/icons_assets/messaging_assets/search2.svg';
  static const String member = 'assets/icons_assets/messaging_assets/community_member.svg';
  static const String reminder = 'assets/icons_assets/messaging_assets/carbon_reminder.svg';

  static const String group = 'assets/icons_assets/messaging_assets/vectors_group.svg';
  static const String people = 'assets/icons_assets/messaging_assets/people.svg';
  static const String person = 'assets/icons_assets/messaging_assets/vectors_person.svg';

  static const String emptyNotification =
      'assets/vectors/emptyNotification.svg';
  static const String location = 'assets/icons_assets/messaging_assets/vectors_location.svg';
  static const String message = 'assets/icons_assets/main_icons_assets/message_new_icon.svg';
  static const String mic = 'assets/icons_assets/messaging_assets/mic.svg';
  static const String more = 'assets/icons_assets/main_icons_assets/vectors_more.svg';
  static const String poll = 'assets/icons_assets/messaging_assets/poll.svg';
  static const String scroll = 'assets/icons_assets/messaging_assets/scroll.svg';
  static const String search = 'assets/icons_assets/main_icons_assets/assets_vectors_search.svg';

  static const String send = 'assets/icons_assets/messaging_assets/vectors_send.svg';
  static const String happyFace = 'assets/icons_assets/messaging_assets/happy_face.svg';
  static const String sort = 'assets/icons_assets/main_icons_assets/sort_filter.svg';

// --------------------- Emotions ----------------------------------

  static const Map<String, String> emotions = {
    'clap': 'assets/icons_assets/messaging_assets/clap.svg',
    'like': 'assets/icons_assets/messaging_assets/like.svg',
    'love': 'assets/icons_assets/messaging_assets/love.svg',
    'sad': 'assets/icons_assets/messaging_assets/sad.svg',
    'wow': 'assets/icons_assets/messaging_assets/wow.svg',
    'xd': 'assets/icons_assets/messaging_assets/xd.svg',
  };

  //****************************************************************************

  //***************************** LOTTIE FILES *********************************
  static const String trashGif = 'assets/lottie_assets/main_lottie_assets/assets_lottie_trash.json';
  static const String media = 'assets/lottie_assets/main_lottie_assets/lottie_media.json';
  static const String links = 'assets/lottie_assets/messaging_lottie_assets/lottie_links.json';
  static const String docs = 'assets/lottie_assets/messaging_lottie_assets/lottie_docs.json';
  static const String directMessages = 'assets/lottie_assets/messaging_lottie_assets/lottie_direct_messages.json';
  static const String groups = 'assets/lottie_assets/messaging_lottie_assets/lottie_groups.json';

  //****************************************************************************
}
