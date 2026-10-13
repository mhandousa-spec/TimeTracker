/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_assets.dart
/// Purpose: Declares `AppAssets`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Objectives: This file is responsible for providing the app assets.

// assets
abstract class AppAssets {
  //***************************** IMAGES ***************************************

  //****************************************************************************

//******************************* VECTORS ************************************
  /// Brand marks used by the splash screen. Were literals in
  /// `splash_screen.dart` (§15, CR-SKEL-O1-N07).
  static const String logo =
      'assets/icons_assets/main_icons_assets/knowticed_logo.svg';
  static const String logoDark =
      'assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg';

  /// Calendar-with-star mark for the day view's "Up Comings" header
  /// (Figma MESBAH 4717-39883).
  static const String upcome =
      'assets/icons_assets/home_assets/calendar_event_star_white.svg';

  static const String add = 'assets/icons_assets/main_icons_assets/plus.svg';
  static const String sort = 'assets/icons_assets/main_icons_assets/sort_lines.svg';
  static const String arrowDown = 'assets/icons_assets/main_icons_assets/chevron_down.svg';
  static const String arrowLeft = 'assets/icons_assets/main_icons_assets/chevron_left.svg';
  static const String calendar = 'assets/icons_assets/roles_assets/calendar.svg';
  static const String camera = 'assets/icons_assets/messaging_assets/camera.svg';
  static const String cancel = 'assets/icons_assets/main_icons_assets/cancel_minus_circle.svg';
  static const String chat = 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg';
  static const String close = 'assets/icons_assets/form_builder_assets/close_circle_red.svg';
  static const String copy = 'assets/icons_assets/form_builder_assets/copy_duplicate.svg';
  static const String defaultIcon = 'assets/icons_assets/form_builder_assets/create_form.svg';
  static const String delete = 'assets/icons_assets/form_builder_assets/delete_trash_red.svg';
  static const String department = 'assets/icons_assets/services_assets/department_hierarchy_people.svg';
  static const String download = 'assets/icons_assets/form_builder_assets/download_arrow.svg';

  static const String edit = 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg';
  static const String email = 'assets/icons_assets/main_icons_assets/email_envelope.svg';
  static const String fillOut = 'assets/icons_assets/form_builder_assets/results_checklist_clipboard.svg';
  static const String filter = 'assets/icons_assets/main_icons_assets/filter_sliders.svg';
  static const String grid = 'assets/icons_assets/main_icons_assets/grid_four_squares.svg';
  static const String image = 'assets/icons_assets/main_icons_assets/image_photo_rounded.png';
  static const String imageWatermark =
      'assets/icons_assets/main_icons_assets/image_placeholder_large.svg';
  static const String link = 'assets/icons_assets/form_builder_assets/link_chain.svg';
  static const String listView = 'assets/icons_assets/main_icons_assets/list_lines.svg';
  static const String menu = 'assets/icons_assets/roles_assets/menu_lines_bold.svg';

  /// Three-dot "more" glyph. ADDED 19/8/2026 for the Form Builder home cards,
  /// which were falling back to [menu] — a hamburger, not three dots.
  ///
  /// The artwork draws the dots VERTICALLY in a square 24×24 viewBox. Callers
  /// that want the horizontal ⋯ (the card menus, per Figma node 7444-37332)
  /// wrap it in `RotatedBox(quarterTurns: 1)`; because the viewBox is square,
  /// that rotation neither clips nor changes the icon's footprint.
  static const String more = 'assets/icons_assets/main_icons_assets/vectors_more.svg';

  static const String network = 'assets/icons_assets/form_builder_assets/network_people_nodes.svg';
  static const String phone = 'assets/icons_assets/services_assets/phone_handset.svg';
  static const String results = 'assets/icons_assets/form_builder_assets/results_checklist_clipboard.svg';
  static const String ring = 'assets/icons_assets/knowledge_hub_assets/send_reminder_icon.svg';
  static const String search = 'assets/icons_assets/main_icons_assets/search_magnifier_alt.svg';
  static const String selectAll = 'assets/icons_assets/form_builder_assets/select_all_group_check.svg';
  static const String share = 'assets/icons_assets/form_builder_assets/share_arrow.svg';
  static const String success = 'assets/icons_assets/main_icons_assets/check_circle_green.svg';
  static const String text = 'assets/icons_assets/form_builder_assets/text_letter_t.svg';
  static const String title = 'assets/icons_assets/form_builder_assets/text_letter_t.svg';
  static const String upload = 'assets/icons_assets/form_builder_assets/upload_arrow.svg';
  static const String warning = 'assets/icons_assets/main_icons_assets/warning_triangle_red.svg';
  static const String addressIcon =
      'assets/icons_assets/form_builder_assets/location_pin.svg';
  static const String attachedDigitalSignatureIcon =
      'assets/icons_assets/form_builder_assets/digital_signature.svg';
  static const String attachmentIcon =
      'assets/icons_assets/form_builder_assets/attachment_paperclip.svg';
  static const String checkBoxIcon =
      'assets/icons_assets/main_icons_assets/checkbox_empty_outline.svg';
  static const String descriptionIcon =
      'assets/icons_assets/form_builder_assets/description_text_lines.svg';
  static const String dropDownIcon =
      'assets/icons_assets/main_icons_assets/chevron_down.svg';
  static const String downloadPdf =
      'assets/icons_assets/form_builder_assets/cloud_download.svg';
  static const String emailIcon = 'assets/icons_assets/main_icons_assets/email_envelope.svg';
  static const String imageIcon = 'assets/icons_assets/form_builder_assets/image_add.svg';
  static const String linkIcon = 'assets/icons_assets/form_builder_assets/link_chain.svg';
  static const String locationIcon =
      'assets/icons_assets/form_builder_assets/location_pin.svg';
  static const String phoneIcon = 'assets/icons_assets/services_assets/phone_handset.svg';
  static const String radioIcon = 'assets/icons_assets/form_builder_assets/radio_unselected.svg';
  static const String timeSelectorIcon =
      'assets/icons_assets/main_icons_assets/clock_circle.svg';
  static const String downloadLinear =
      'assets/icons_assets/form_builder_assets/cloud_download.svg';
  static const String bold = 'assets/icons_assets/form_builder_assets/text_bold.svg';
  static const String italic = 'assets/icons_assets/form_builder_assets/text_italic.svg';
  static const String underLine = 'assets/icons_assets/form_builder_assets/text_underline.svg';
  static const String colorIcon = 'assets/icons_assets/settings_assets/branding_theme_badge.svg';
  static const String arrowDownBold =
      'assets/icons_assets/main_icons_assets/chevron_down_gray.svg';
  static const String minus = 'assets/icons_assets/main_icons_assets/minus_circle_red.svg';
  static const String addOption = 'assets/icons_assets/main_icons_assets/plus.svg';
  static const String radioOption =
      'assets/icons_assets/form_builder_assets/radio_circle_empty.svg';
  static const String arrowUp = 'assets/icons_assets/main_icons_assets/chevron_down.svg';
  static const String save = 'assets/icons_assets/form_builder_assets/bookmark_save_circle.svg';
  static const String message = 'assets/icons_assets/main_icons_assets/chat_bubble_dots.svg';
  static const String radio = 'assets/icons_assets/form_builder_assets/radio_circle_empty.svg';
  static const String radioSelected =
      'assets/icons_assets/form_builder_assets/radio_selected_filled.svg';
  static const String checkbox = 'assets/icons_assets/main_icons_assets/checkbox_empty_outline.svg';
  static const String checkboxSelected =
      'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg';
  static const String summary = 'assets/icons_assets/form_builder_assets/summary_document_list.svg';
  static const String export = 'assets/icons_assets/main_icons_assets/export_arrow.svg';
  static const String group = 'assets/icons_assets/form_builder_assets/group_people_network.svg';
  static const String checkboxFill =
      'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg';
  static const String pdf = 'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
  static const String excel = 'assets/icons_assets/form_builder_assets/excel_logo.svg';
  static const String powerPoint = 'assets/icons_assets/form_builder_assets/powerpoint_logo.svg';
  static const String vedio = 'assets/icons_assets/form_builder_assets/video_player_film.svg';
  static const String word = 'assets/icons_assets/form_builder_assets/word_doc_logo.svg';
  static const String attachmentPdf =
      'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
  static const String female = "assets/icons_assets/main_icons_assets/female_avatar.png";
  static const String male = "assets/icons_assets/main_icons_assets/male_avatar.png";
  static const String minusCircle =
      'assets/icons_assets/main_icons_assets/minus_circle_red.svg';

  //****************************************************************************

  //***************************** LOTTIE FILES *********************************

  static const String successful = 'assets/lottie_assets/main_lottie_assets/successful.json';

  /// The confirm step of `CustomDialogManager.showDialogFlow`. ADDED
  /// 26/8/2026 — the file was already in assets/, just never named here.
  static const String lottieConfirmation =
      'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json';
  static const String trash = 'assets/lottie_assets/main_lottie_assets/trash.json';

  /// Green tick that draws in — the "Approve …?" confirm step. ADDED
  /// 13/10/2026 (Time Tracker owner I6: [lottieConfirmation] starts as a
  /// small "+" dot and is a "create document" animation).
  static const String lottieApproved = 'assets/lottie_assets/main_lottie_assets/approved.json';

  /// The "editing an existing record" confirm step. ADDED 13/9/2026; the file
  /// was already in assets/ and already inlined as a raw path string by
  /// app_dialogs.dart and two services screens — named here so the GRC module
  /// does not add a fourth copy of it.
  ///
  /// The SPACE and the capital E in the filename are real. Do not "tidy" them
  /// without renaming the asset itself.
  static const String lottieEditDocument =
      'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json';

  /// The "restoring a removed record" confirm step. ADDED 13/9/2026.
  static const String restore =
      'assets/lottie_assets/main_lottie_assets/restore.json';

  /// The To-Do "Restoring To Do" confirm step: a yellow circular arrow that
  /// draws in and turns once (120 x 120, 60 frames). ADDED 7/10/2026 — the
  /// owner rejected both [restore] (e-commerce returns box) and
  /// [lottieConfirmation] (document + plus = "create") for restoring.
  static const String todoRestore =
      'assets/lottie_assets/todo_assets/lottie_restore.json';
  static const String noData = 'assets/lottie_assets/main_lottie_assets/noData.json';

  /// The empty state used by `CustomEmptyState` — every list, table and
  /// filter result with nothing in it. ADDED 16/8/2026.
  ///
  /// NOT [noData], which is a different file in the same folder. Go through
  /// the widget rather than this constant: the point of having one animation
  /// is that no screen gets to size or caption it differently.
  static const String lottieEmpty =
      'assets/lottie_assets/main_lottie_assets/lottie_empty.json';

  /// Failure/warning step of `CustomDialogManager.showMessage` — used by the
  /// form-builder submit flow when the response could not be sent. ADDED
  /// 1/9/2026; the file was already in assets/, just never named here.
  static const String lottieWarning =
      'assets/lottie_assets/main_lottie_assets/lottie_warning.json';

//****************************************************************************


  /// champion/owner/request detail pages.
  static const String defaultEmployeeAvatar =
      'assets/icons_assets/main_icons_assets/assets_male.svg';



  // CRM

  static const String crmBlacklist =
      'assets/icons_assets/crm_icons_assets/blacklist.svg';
  static const String crmDeal =
      'assets/icons_assets/crm_icons_assets/deals.svg';
  static const String crmClients =
      'assets/icons_assets/crm_icons_assets/clients.svg';
  static const String crmGroup =
      'assets/icons_assets/crm_icons_assets/iconoir_group.svg';
  static const String crmMerge =
      'assets/icons_assets/crm_icons_assets/merge.svg';
  static const String crmProducts =
      'assets/icons_assets/crm_icons_assets/products.svg';
  static const String crmQuotes =
      'assets/icons_assets/crm_icons_assets/quotes.svg';
  static const String crmQuote =
      'assets/icons_assets/crm_icons_assets/quote.svg';
  static const String crmCompare =
      'assets/icons_assets/crm_icons_assets/compare.svg';
  static const String crmVersion =
      'assets/icons_assets/crm_icons_assets/version.svg';
  static const String crmRequestQuote =
      'assets/icons_assets/crm_icons_assets/request-quote.svg';
  static const String crmServices =
      'assets/icons_assets/crm_icons_assets/services.svg';
  static const String crmTablerContract =
      'assets/icons_assets/crm_icons_assets/tabler_contract.svg';
  static const String crmGovernment =
      'assets/icons_assets/crm_icons_assets/government.svg';
  static const String crmPerson =
      'assets/icons_assets/crm_icons_assets/person.svg';
  static const String crmCompanies =
      'assets/icons_assets/crm_icons_assets/companies.svg';
  static const String crmTemplate =
      'assets/icons_assets/crm_icons_assets/template.svg';
  static const String crmTemplateEmpty =
      'assets/icons_assets/crm_icons_assets/templet_empty.svg';
  static const String crmPlusBold =
      'assets/icons_assets/crm_icons_assets/plus_bold.svg';
  static const String crmInfo = 'assets/icons_assets/crm_icons_assets/info.svg';
  static const String crmWarning =
      'assets/icons_assets/crm_icons_assets/warning.svg';
  static const String crmMinus =
      'assets/icons_assets/crm_icons_assets/minus.svg';
  static const String crmArrowRight =
      'assets/icons_assets/main_icons_assets/chevron_right.svg';
  static const String crmArrowLeft =
      'assets/icons_assets/main_icons_assets/chevron_left.svg';
  static const String crmControl =
      'assets/icons_assets/crm_icons_assets/control.svg';
  static const String crmGuide =
      'assets/icons_assets/crm_icons_assets/guide.svg';
  static const String crmClientsType =
      'assets/icons_assets/crm_icons_assets/clients_type.svg';
  static const String crmDiscount =
      'assets/icons_assets/crm_icons_assets/discount.svg';
  static const String crmPermissions =
      'assets/icons_assets/crm_icons_assets/permissions.svg';
  static const String crmRelationship =
      'assets/icons_assets/crm_icons_assets/relationship.svg';
  static const String crmTrush =
      'assets/icons_assets/crm_icons_assets/trush.svg';
  static const String crmSaveSvgDialog =
      'assets/icons_assets/crm_icons_assets/save_svg_dialog.svg';
  static const String crmSuccessfulSvgDialog =
      'assets/icons_assets/crm_icons_assets/successful_svg_dialog.svg';
  static const String crmMinusSolid =
      'assets/icons_assets/crm_icons_assets/minus-solid.svg';
  static const String crmCheckBoxField =
      'assets/icons_assets/crm_icons_assets/check_box_filed.svg';
  static const String crmCompanySizeField =
      'assets/icons_assets/crm_icons_assets/compony_size.svg';
  static const String crmDescriptionField =
      'assets/icons_assets/crm_icons_assets/description_filed.svg';
  static const String crmImageField =
      'assets/icons_assets/crm_icons_assets/image_filed.svg';
  static const String crmIndustryField =
      'assets/icons_assets/crm_icons_assets/industory_filed.svg';
  static const String crmLinkField =
      'assets/icons_assets/crm_icons_assets/link_filed.svg';
  static const String crmRadioField =
      'assets/icons_assets/crm_icons_assets/radio_fied.svg';
  static const String crmSectorField =
      'assets/icons_assets/crm_icons_assets/sector_filed.svg';
  static const String crmSignatureField =
      'assets/icons_assets/crm_icons_assets/signature_filed.svg';
  static const String crmSwitchField =
      'assets/icons_assets/crm_icons_assets/switch_filed.svg';
  static const String crmTagField =
      'assets/icons_assets/crm_icons_assets/tag_filed.svg';
  static const String crmTextField =
      'assets/icons_assets/crm_icons_assets/text_filed.svg';
  static const String crmDropdownField =
      'assets/icons_assets/crm_icons_assets/dropdown-field-type.svg';
  static const String crmSections =
      'assets/icons_assets/crm_icons_assets/sections.svg';
  static const String crmStatus =
      'assets/icons_assets/crm_icons_assets/status.svg';

  static const String crmHint = 'assets/icons_assets/crm_icons_assets/hint.svg';
  static const String crmAddView =
      'assets/icons_assets/crm_icons_assets/add_view.svg';

  static const String crmRelationshipEmpty =
      'assets/icons_assets/crm_icons_assets/relationship_empty_svg.svg';

  static const String crmHash = 'assets/icons_assets/crm_icons_assets/hash.svg';
  static const String crmPrice =
      'assets/icons_assets/crm_icons_assets/price.svg';
  static const String crmCategoryIcon =
      'assets/icons_assets/crm_icons_assets/category_icon.svg';
  static const String crmTax = 'assets/icons_assets/crm_icons_assets/tax.svg';
  static const String crmTeamsEmpty =
      'assets/icons_assets/crm_icons_assets/teams_empty.svg';

  static const String crmMergeEmptyPage =
      'assets/icons_assets/crm_icons_assets/merge-empty-page.svg';
  static const String crmConfidence =
      'assets/icons_assets/crm_icons_assets/confidence.svg';
  static const String crmHistory =
      'assets/icons_assets/crm_icons_assets/history.svg';
  static const String crmHowItWork =
      'assets/icons_assets/crm_icons_assets/how-it-work.svg';
  static const String crmRecord =
      'assets/icons_assets/crm_icons_assets/record.svg';
  static const String crmUndo = 'assets/icons_assets/crm_icons_assets/undo.svg';






}
