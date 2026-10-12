/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_deep_link.dart
/// Purpose: Turn the two strings a stored notification carries —
///          `Name_of_module` and `name_of_page` — into "which module, and
///          which SECTION of it" so tapping View lands on the screen the
///          notification is actually about.
/// Author: Knowticed Plus team
/// Created at: 12/9/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Every notification has been storing `name_of_page` since the module page
/// enums were written, and nothing has ever read it. `_handleViewNotification`
/// — copied byte-for-byte into all three inbox pages — resolved
/// `nameOfModule` to a drawer entry and stopped there, so a "your change
/// request was approved" alert and a "document pending your review" alert both
/// dropped the reader on their module's landing screen. Four of the page enums
/// say so in their own headers:
///
///     ⚠️ KNOWN GAP: the notification tap handlers … route by MODULE only.
///     They read `nameOfModule` and ignore `nameOfPage`. These keys are
///     stored correctly but not yet acted on. They are what a future
///     deep-link router will switch over.
///
/// This is that router's lookup table.
///
/// WHAT IT DELIBERATELY DOES NOT DO
/// --------------------------------
/// It resolves to a SECTION, never to a record. A notification stores no
/// target id — there is no `entityId` on `NotificationModelSystem` and no
/// parameter for one on `AppNotificationSender` — so "open request #7" is not
/// answerable from a stored document, and most detail screens could not be
/// built from an id anyway: `DatabaseDetailsPage` takes a hydrated
/// `DatabaseModel`, `ViewKnowledgeDetails` takes twelve required fields, and
/// `PreviewChangesPage` takes fifteen `TextEditingController`s. So a key that
/// names a detail screen resolves to the LIST that screen is reached from —
/// the reader lands one tap away instead of nowhere near. Carrying an id is a
/// separate change: a field on the model, a parameter on the sender, and the
/// call sites in the eight module notification services.
///
/// UPDATE 7/10/2026: that change now exists — optional
/// `NotificationModelSystem.requestId` (`Request_Id`) and a `requestId`
/// parameter on `AppNotificationSender` — and To-Do is its first user:
/// `NotificationRouting.todoIdFor` opens the to-do itself. Other modules can
/// adopt it the same way; this table still resolves only to sections.
///
/// ⚠️ RULE: a page key that matches nothing resolves to the module landing —
/// today's behaviour. This router never dead-ends a tap.
library;

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub_module/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services_module/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings_module/settings_notification_pages.dart';

/// Which settings section a notification belongs to.
///
/// [containerIndex] is `SettingsController.selectedContainerIndex`, the value
/// `settings_layout.dart` switches its right-hand pane on. The numbers are not
/// contiguous and are not ours to renumber — they are what that file already
/// tests against, and several are unused gaps.
enum NotificationSettingsSection {
  personalInfo(0),
  commentsAndFeedback(4),
  aboutApp(5),

  /// `hasCompanyInfo` renders `CompanyScreenInfo` at 8. Note the near-miss:
  /// the class literally named `CompanyInfoScreen` is the BRANDING pane at 14.
  /// The enum key `CompanyInfoScreen` documents itself as "Company
  /// information", so 8 is the intent.
  company(8),

  social(12),

  /// The requests screen — both the employee's own submissions and the
  /// reviewer's queue.
  requests(13),

  privacyStatement(16);

  const NotificationSettingsSection(this.containerIndex);

  final int containerIndex;
}

/// Which Knowledge Hub screen to open on top of the module landing.
///
/// Both are pushed from buttons on `ViewKnowledgeHub`, each wrapped in its own
/// `BlocProvider` — see `submissions_button.dart` / `approvals_button.dart`.
enum NotificationKnowledgeHubSection { submissions, approvals }

/// Which Services screen to open on top of the module landing. All three are
/// const, no-argument widgets pushed with `navigateTo` from the services home.
enum NotificationServicesSection { requests, approvals, providerDashboard }

/// Where one notification should land.
class NotificationDeepLink {
  const NotificationDeepLink._(
    this.module, {
    this.rolesTab,
    this.settingsSection,
    this.knowledgeHubSection,
    this.servicesSection,
  });

  /// The drawer entry to select. Always present — a link with no module is
  /// never built; the caller resolves the module first and only then asks for
  /// the section.
  final Modules module;

  /// Tab index inside `RoleScreen`. Mirrors `Constants.tabletRolePageTabs`:
  /// 0 Role Management, 1 User Management, 2 User Access, 3 Active Directory,
  /// 4 System Logs.
  final int? rolesTab;

  final NotificationSettingsSection? settingsSection;
  final NotificationKnowledgeHubSection? knowledgeHubSection;
  final NotificationServicesSection? servicesSection;

  /// Whether this link says anything beyond "open the module".
  bool get hasSection =>
      rolesTab != null ||
      settingsSection != null ||
      knowledgeHubSection != null ||
      servicesSection != null;

  /// Function Name: [resolve]
  ///
  /// Purpose: The lookup. Parameters are the raw stored strings plus the
  /// already-resolved drawer entry, so this file never needs to know how a
  /// module key becomes a [Modules] — that stays in `NotificationRouting`, and
  /// the two files do not import each other.
  ///
  /// Parameters:
  /// - [module]: from `NotificationRouting.moduleForStoredKey`.
  /// - [moduleKey]: the raw `Name_of_module`.
  /// - [pageKey]: the raw `name_of_page`. Frequently empty on documents
  ///   written before a module adopted its page enum.
  ///
  /// Returns: a [NotificationDeepLink] — never null, at worst module-only.
  static NotificationDeepLink resolve({
    required Modules module,
    required String moduleKey,
    required String pageKey,
  }) {
    final String page = pageKey.trim();

    switch (module) {
      case Modules.roles:
        return NotificationDeepLink._(
          module,
          rolesTab: rolesTabFor(moduleKey, page),
        );
      case Modules.settings:
        return NotificationDeepLink._(
          module,
          settingsSection: _settingsSectionFor(page),
        );
      case Modules.knowledgeHub:
        return NotificationDeepLink._(
          module,
          knowledgeHubSection: _knowledgeHubSectionFor(page),
        );
      case Modules.services:
        return NotificationDeepLink._(
          module,
          servicesSection: _servicesSectionFor(page),
        );
      default:
        // Database and Messages land on their module for now: every one of
        // their page keys names a record (one database, one table's access
        // rule, one conversation), and the record is exactly what a stored
        // notification cannot name. See the header.
        return NotificationDeepLink._(module);
    }
  }

  // ── Roles ────────────────────────────────────────────────────────────────
  //
  // `Modules.roles` is one drawer entry hosting five tabs, and the three
  // role-area AppModules map onto three of them. The module key alone answers
  // this — it is the mapping `NotificationRouting.rolesTabForStoredKey` has
  // done since 22/8/2026 — but the page key refines two cases where one module
  // reaches into another's tab.
  /// Public because `NotificationRouting.rolesTabForStoredKey` delegates here
  /// rather than keeping a second copy of the mapping.
  static int? rolesTabFor(String moduleKey, [String pageKey = '']) {
    // `SettingsSwitchesPage` is the per-permission editor, which lives on the
    // Role Management tab even though User Management raises the notification.
    if (pageKey == 'SettingsSwitchesPage') return 0;
    if (pageKey == 'RoleEmployeeDetailsPage') return 1;

    switch (moduleKey.trim().toLowerCase()) {
      case 'role_management':
        return 0;
      case 'user_management':
        return 1;
      // Account locked / unlocked / activated all live here — this is the tab
      // an admin needs in order to actually unlock the account.
      case 'user_access':
        return 2;
      default:
        return null;
    }
  }

  // ── Settings ─────────────────────────────────────────────────────────────
  static NotificationSettingsSection? _settingsSectionFor(String pageKey) {
    final SettingsNotificationPage? page =
        SettingsNotificationPage.fromKey(pageKey);
    if (page == null) return null;

    return switch (page) {
      SettingsNotificationPage.personalInfoScreen =>
        NotificationSettingsSection.personalInfo,
      SettingsNotificationPage.socialScreen =>
        NotificationSettingsSection.social,
      SettingsNotificationPage.companyInfoScreen =>
        NotificationSettingsSection.company,
      SettingsNotificationPage.commentsAndFeedbackScreen =>
        NotificationSettingsSection.commentsAndFeedback,
      SettingsNotificationPage.aboutThisAppScreen =>
        NotificationSettingsSection.aboutApp,
      SettingsNotificationPage.privacyStatementPage =>
        NotificationSettingsSection.privacyStatement,
      SettingsNotificationPage.myRequestPage =>
        NotificationSettingsSection.requests,

      // The two approver previews CANNOT be deep-linked: both take the
      // submitted values as ~15 TextEditingControllers built by the screen
      // that pushes them, so there is no constructing one from a
      // notification. The requests screen is where the reviewer opens the
      // request properly, and it is one tap from the decision — which is the
      // whole point of the notification.
      SettingsNotificationPage.previewChangesPage ||
      SettingsNotificationPage.previewHealthInsuranceChangesPage =>
        NotificationSettingsSection.requests,
    };
  }

  // ── Knowledge Hub ────────────────────────────────────────────────────────
  static NotificationKnowledgeHubSection? _knowledgeHubSectionFor(
    String pageKey,
  ) {
    final KnowledgeHubNotificationPage? page =
        KnowledgeHubNotificationPage.fromKey(pageKey);
    if (page == null) return null;

    return switch (page) {
      // A detail key resolves to the list it is opened from — see the header.
      KnowledgeHubNotificationPage.submissions ||
      KnowledgeHubNotificationPage.submissionDetails =>
        NotificationKnowledgeHubSection.submissions,
      KnowledgeHubNotificationPage.approvals ||
      KnowledgeHubNotificationPage.approvalsDetails =>
        NotificationKnowledgeHubSection.approvals,
      // The module landing already IS the published-documents list.
      KnowledgeHubNotificationPage.viewKnowledgeHub ||
      KnowledgeHubNotificationPage.viewKnowledgeDetails =>
        null,
    };
  }

  // ── Services ─────────────────────────────────────────────────────────────
  //
  // ⚠️ `ServicesNotificationPage` has no `fromKey` of its own (the only page
  // enum that does not), so the match is done here over `values`.
  static NotificationServicesSection? _servicesSectionFor(String pageKey) {
    ServicesNotificationPage? page;
    for (final ServicesNotificationPage candidate
        in ServicesNotificationPage.values) {
      if (candidate.key == pageKey) {
        page = candidate;
        break;
      }
    }
    if (page == null) return null;

    return switch (page) {
      ServicesNotificationPage.requestServicesToggle =>
        NotificationServicesSection.requests,
      // The key names the CARD widget; the screen it sits on is the approvals
      // list (`ApprovalToggle`).
      ServicesNotificationPage.approvalRequestCard =>
        NotificationServicesSection.approvals,
      // No class of this name exists — the provider's screen is
      // `EmployeeLayoutScreenServices`.
      ServicesNotificationPage.serviceProviderDashboard =>
        NotificationServicesSection.providerDashboard,
    };
  }
}
