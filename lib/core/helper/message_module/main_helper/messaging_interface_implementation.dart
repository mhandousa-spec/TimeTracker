/// Module: core / message_module / main_helper
/// ************************* FILE INFO *************************** ///
/// File Name: messaging_interface_implementation.dart
/// Purpose: Bootstraps the messaging module.
///
///   The messaging feature was copied into this project as files only (see
///   MESSAGING_MIGRATION_NOTES.md) — this file, which actually *wires it up*,
///   was never ported. Without it `MessagingInitController` is never
///   constructed, so `Dependency().init()` never runs, no messaging cubit is
///   ever registered with GetX, and the Messages tab renders empty.
///
///   Ported from Knowticed_plus:
///   `lib/features/messaging/interface/messaging_interface_implementation.dart`
///   with the types remapped to this project:
///     DepartmentModel      -> DepartmentModelPro
///     EmployeeController   -> OrgChartEmployeeController
///
/// Usage (both steps are required, in this order):
///   1. `MessagingInterfaceImplementation().initMessagingModule();`
///      once the signed-in employee + permissions are loaded.
///   2. `await MessagingInterfaceImplementation()
///          .useGroupAndSingleMessaging(context, employee);`
///      before navigating to the Messages tab.

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_more_permissions.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_permissions.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';

import '../interface/controller/messaging_init_controller.dart';
import '../interface/entity/group_chat_interface_parameters.dart';
import '../interface/entity/messaging_configurations.dart';
import '../interface/entity/user_category.dart';
import '../interface/entity/user_connection_interface_parameters.dart';
import '../interface/entity/user_preferred_color.dart';

class MessagingInterfaceImplementation {
  /// Default "All" pseudo-category. The id is arbitrary but must be stable —
  /// `useGroupAndSingleMessaging` inserts it at index 0 keyed on this id.
  static final UserCategory allCategory = UserCategory(
    primaryLanguageName: "All",
    secondaryLanguageName: "كل",
    categoryId: "2343",
  );

  /// Registers [MessagingInitController], whose constructor runs
  /// `Dependency().init()` and puts every messaging cubit into GetX.
  ///
  /// Safe to call more than once — re-registering is skipped.
  void initMessagingModule() {
    if (Get.isRegistered<MessagingInitController>()) return;

    final employeeController = Get.find<MainCoreEmployeeController>();

    bool can(dynamic permission, MessagesPermissionsSections section) =>
        employeeController.isHasPermission(
          module: Modules.messages,
          permission: permission,
          section: section,
        );

    // permanent: this runs during login, and GetX disposes non-permanent
    // instances when the login route is popped.
    Get.put(
      permanent: true,
      MessagingInitController(
        configurations: MessagingConfigurations(
          createGroup: can(MessagesPermissions.createGroup,
              MessagesPermissionsSections.messagesPermissions),
          seenAndUnseen: can(MessagesPermissions.seenAndUnseen,
              MessagesPermissionsSections.messagesPermissions),
          editMessage: can(MessagesPermissions.editMessage,
              MessagesPermissionsSections.messagesPermissions),
          deleteMessage: can(MessagesPermissions.deleteMessage,
              MessagesPermissionsSections.messagesPermissions),
          reactions: can(MessagesPermissions.reactions,
              MessagesPermissionsSections.messagesPermissions),
          forwardMessages: can(MessagesPermissions.forwardMessage,
              MessagesPermissionsSections.messagesPermissions),
          contact: can(MessagesMorePermissions.contact,
              MessagesPermissionsSections.morePermissions),
          location: can(MessagesMorePermissions.location,
              MessagesPermissionsSections.morePermissions),
          photo: can(MessagesMorePermissions.photo,
              MessagesPermissionsSections.morePermissions),
          documents: can(MessagesMorePermissions.documents,
              MessagesPermissionsSections.morePermissions),
          poll: can(MessagesMorePermissions.poll,
              MessagesPermissionsSections.morePermissions),
          muteNotifications: can(MessagesMorePermissions.muteNotifications,
              MessagesPermissionsSections.morePermissions),
          disappearingMessages: can(MessagesMorePermissions.disappearingMessages,
              MessagesPermissionsSections.morePermissions),
          scheduleMessages: can(MessagesMorePermissions.scheduleMessages,
              MessagesPermissionsSections.morePermissions),
          scaffoldBackgroundColor: UserPreferredColor(
            light: Colors.white,
            dark: Colors.black,
          ),
          primaryColor:
              UserPreferredColor(light: Colors.blue, dark: Colors.purple),
          secondaryColor: UserPreferredColor(
            light: Colors.lightBlueAccent,
            dark: Colors.deepPurpleAccent,
          ),
          isSecondaryLanguage: () => Get.locale?.languageCode == 'ar',
          // Messaging push notifications are not wired to a sender yet; the
          // module only needs the callback to exist.
          sendNotification: ({
            required List<String> targetAudienceIds,
            required String englishBody,
            required String englishTitle,
            required String arabicBody,
            required String arabicTitle,
            required Map<String, String> payload,
          }) {},
          baseUri: () => ApiConstants.baseUri,
        ),
      ),
    );
  }

  /// Departments -> messaging categories.
  Future<List<UserCategory>> getCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(ApiConstants.departments)
        .get();

    return snapshot.docs
        .map((e) => DepartmentModelPro.fromMap(e.data()))
        .map((d) => UserCategory(
              primaryLanguageName: d.departmentName ?? '',
              secondaryLanguageName: d.departmentNameInArabic,
              categoryId: d.departmentID ?? '',
            ))
        .toList();
  }

  Timestamp convertDate(String date) =>
      Timestamp.fromDate(DateTime.parse(date));

  /// Last entry of a history list as a trimmed string ('' when absent).
  static String _lastOf(List<dynamic>? values) {
    if (values == null || values.isEmpty) return '';
    final dynamic last = values.last;
    return last == null ? '' : last.toString().trim();
  }

  static String _joinName(String first, String last, String fallback) {
    final String name = '$first $last'.trim();
    return name.isEmpty ? fallback : name;
  }

  /// `firstLogin` is null for an account that has never signed in; such a
  /// colleague must still be reachable, so fall back to the epoch (it only
  /// orders the no-message-yet connections).
  Timestamp _activationTime(String? firstLogin) {
    final DateTime? parsed =
        firstLogin == null ? null : DateTime.tryParse(firstLogin);
    return Timestamp.fromDate(parsed ?? DateTime(2000));
  }

  /// Every employee, shaped as a messaging connection.
  ///
  /// Employees whose record is missing a field the module requires are skipped
  /// rather than aborting the whole list — matches the original behaviour.
  Future<List<UserConnectionInterfaceParameters>> getAllUsersData() async {
    final categories = await getCategories();
    final snapshot = await FirebaseFirestore.instance
        .collection(ApiConstants.employeesProfile)
        .get();

    final users = <UserConnectionInterfaceParameters>[];
    for (final doc in snapshot.docs) {
      try {
        final employee = NewEmployeeModelHistory.fromMap(doc.data());
        // FIXED 29/9/2026 (bug report p.10 / p.11 — "This user has no
        // messaging profile", and a new account's chat never appearing in
        // the list). Every field below used to be force-unwrapped inside one
        // try/catch, so an employee with NO PHOTO (`_photoOf` → null), no
        // Arabic name/title, or who had NEVER SIGNED IN (`firstLogin` null)
        // threw and was silently dropped from the whole messaging module.
        // Only the email (the messaging user id) is truly required now;
        // everything else falls back to an empty value.
        final String email = _lastOf(employee.email);
        if (email.isEmpty) continue;
        final String departmentId = _lastOf(employee.departmentId);
        users.add(
          UserConnectionInterfaceParameters(
            primaryLanguageName: _joinName(
                _lastOf(employee.firstName), _lastOf(employee.lastName), email),
            secondaryLanguageName: _joinName(_lastOf(employee.firstNameInArabic),
                _lastOf(employee.lastNameInArabic), ''),
            primaryLanguageSubInfo: _lastOf(employee.title),
            secondaryLanguageSubInfo: _lastOf(employee.titleInArabic),
            imageUri: _photoOf(employee) ?? '',
            userId: email,
            phone: "",
            userCategory: categories.firstWhere(
              (c) => c.categoryId == departmentId,
              orElse: () => allCategory,
            ),
            userAccountActivationTime: _activationTime(employee.firstLogin),
          ),
        );
      } catch (e) {
        // A record that cannot even be parsed — skip it, but say so.
        log('[getAllUsersData] skipped employee ${doc.id}: $e');
      }
    }
    return users;
  }

  /// Hands the signed-in user + category list to the messaging module.
  /// Must run before the Messages tab is opened.
  Future<void> useGroupAndSingleMessaging(
    BuildContext context,
    NewEmployeeModelHistory employee,
  ) async {
    initMessagingModule();

    final categories = await getCategories();
    if (!context.mounted) return;

    // Same null-safety as getAllUsersData (29/9/2026): a signed-in user with
    // no photo or no Arabic name used to throw here, so Messages never
    // initialised for them at all.
    final String myEmail = _lastOf(employee.email);
    final groupChatParameters = GroupChatInterfaceParameters(
      primaryLanguageName: _joinName(
          _lastOf(employee.firstName), _lastOf(employee.lastName), myEmail),
      secondaryLanguageName: _joinName(_lastOf(employee.firstNameInArabic),
          _lastOf(employee.lastNameInArabic), ''),
      primaryLanguageSubInfo: _lastOf(employee.title),
      secondaryLanguageSubInfo: _lastOf(employee.titleInArabic),
      imageUri: _photoOf(employee) ?? '',
      userId: myEmail,
      phone: "",
      userCategory: categories.firstWhere(
        (c) => c.categoryId == _lastOf(employee.departmentId),
        orElse: () => allCategory,
      ),
      categories: categories,
    );

    Get.find<MessagingInitController>().useGroupAndSingleMessaging(
      context: context,
      groupChatParameters: groupChatParameters,
      defaultCategory: allCategory,
      getAllUsersDate: getAllUsersData,
    );
  }

  /// Function Name: [openChatWithUser]
  ///
  /// Purpose: Open the one-to-one chat with a colleague from ANY screen in the
  ///          app, creating the connection first if the two have never spoken.
  ///
  /// ADDED 25/8/2026 for the "Message" button on the user-management request
  /// details page. The module already had
  /// `MessagingInitController.showSpecificSingleChat`, but that finishes
  /// through `ConnectionsCubit.selectConnection`, which does
  /// `context.read<SingleChatCubit>()` — and outside the messaging subtree
  /// that provider does not exist, so it throws. This entry point resolves the
  /// same cubits from GetX (where `Dependency().init()` actually registered
  /// them) and pushes the chat as its own route, which works from anywhere.
  ///
  /// Parameters:
  /// - [context]: any navigable context. The chat goes on the ROOT navigator so
  ///   it covers the module frame it was opened from instead of being trapped
  ///   inside a nested one (the roles module owns its own Navigator).
  /// - [userEmail]: the colleague's email. Email IS the messaging user id — see
  ///   [getAllUsersData] above, which builds every connection with
  ///   `userId: employee.email`.
  ///
  /// Returns: [Future<bool>] false when the chat could not be opened —
  /// messaging never initialised this session, or no employee record matches
  /// that email — so the caller can say so rather than dead-tapping.
  Future<bool> openChatWithUser({
    required BuildContext context,
    required String userEmail,
    VoidCallback? beforeNavigate,
  }) async =>
      await tryOpenChatWithUser(
        context: context,
        userEmail: userEmail,
        beforeNavigate: beforeNavigate,
      ) ==
      OpenChatResult.opened;

  /// Same as [openChatWithUser], but says WHY a chat could not be opened.
  ///
  /// ADDED 21/9/2026 — every caller showed one generic "could not open the
  /// chat" whatever went wrong, so tapping Message on your own form looked
  /// identical to a real failure. Pair it with [showOpenChatFailure].
  ///
  /// [beforeNavigate] runs right before the chat is pushed — close a loading
  /// dialog there, or it sits over the chat until the chat is closed.
  Future<OpenChatResult> tryOpenChatWithUser({
    required BuildContext context,
    required String userEmail,
    VoidCallback? beforeNavigate,
  }) async {
    final OpenChatResult prepared =
        await selectChatWithUser(userEmail: userEmail);
    if (prepared != OpenChatResult.opened) return prepared;

    if (!context.mounted) {
      log('[openChatWithUser] ✗ context unmounted before the push');
      return OpenChatResult.failed;
    }
    log('[openChatWithUser] ✓ opening chat with "${userEmail.trim()}"');
    beforeNavigate?.call();

    // ChatMobileView takes its cubits as constructor arguments and provides
    // every other one itself, so it needs nothing from the context above it —
    // which is exactly what lets it be pushed from a non-messaging screen. It
    // is the full-screen chat on every form factor here; the inline tablet
    // panel only exists inside the messaging home layout.
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatMobileView(
          masterChatCubit: Get.find<SingleChatCubit>(),
          connectionsCubit: Get.find<ConnectionsCubit>(),
        ),
      ),
    );

    return OpenChatResult.opened;
  }

  /// Everything [tryOpenChatWithUser] does EXCEPT the push: finds (or
  /// creates) the connection, selects it on ConnectionsCubit and starts the
  /// chat on SingleChatCubit. [OpenChatResult.opened] here means "selected".
  ///
  /// ADDED 21/9/2026 for the notification Message button on desktop / tablet:
  /// it selects the chat this way and then switches the drawer to Messages,
  /// whose tablet layout (tablet_body.dart) renders the selected connection
  /// inline, inside the app frame.
  Future<OpenChatResult> selectChatWithUser({
    required String userEmail,
  }) async {
    final String otherUserId = userEmail.trim();
    // ADDED 1/9/2026 — every failure path below used to `return false`
    // silently, so the caller could only say "could not open the chat" with no
    // way to tell WHICH of the five reasons it was. Each one now logs under
    // [openChatWithUser].
    log('[openChatWithUser] requested for "$otherUserId"');
    if (otherUserId.isEmpty) {
      log('[openChatWithUser] ✗ empty email passed in');
      return OpenChatResult.userNotFound;
    }

    // `Dependency().init()` runs in MessagingInitController's constructor, so
    // no controller means no messaging cubit is registered at all.
    if (!Get.isRegistered<MessagingInitController>()) {
      log('[openChatWithUser] ✗ MessagingInitController not registered — '
          'initMessagingModule() never ran this session');
      return OpenChatResult.notReady;
    }

    final ConnectionsCubit connectionsCubit = Get.find<ConnectionsCubit>();

    // `currentUser` and `categories` are set by useGroupAndSingleMessaging()
    // during login; without them the loader below throws on a late field.
    if (!connectionsCubit.isCurrentUserInitialized ||
        connectionsCubit.categories == null) {
      log('[openChatWithUser] ✗ ConnectionsCubit not ready — '
          'currentUserInitialized=${connectionsCubit.isCurrentUserInitialized}, '
          'categories=${connectionsCubit.categories?.length}. '
          'useGroupAndSingleMessaging() has not run this session.');
      return OpenChatResult.notReady;
    }

    // Your own email is NEVER in the connections list — it is built from every
    // OTHER app user — so a self-chat can only ever fall through to the lookup
    // below and fail there. ADDED 1/9/2026, after the form-builder "Message
    // Form Owner" button hit exactly this: the signed-in user was the form's
    // owner.
    if (otherUserId.toLowerCase() ==
        connectionsCubit.currentUser.userId.toLowerCase()) {
      log('[openChatWithUser] ✗ "$otherUserId" is the signed-in user — '
          'there is no chat with yourself');
      return OpenChatResult.self;
    }

    // Never opened Messages this session? The connection list stays empty until
    // something subscribes to it — same wait-for-first-batch approach
    // `showSpecificSingleChat` uses.
    if (connectionsCubit.connections.isEmpty) {
      await connectionsCubit.getAllAppUsersInConnectionForm();

      int retries = 0;
      while (connectionsCubit.connections.isEmpty && retries < 20) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        retries++;
      }
      if (connectionsCubit.connections.isEmpty) {
        log('[openChatWithUser] ✗ connections still empty after '
            '${retries * 200}ms — the connections stream delivered nothing');
        return OpenChatResult.notReady;
      }
    }
    log('[openChatWithUser] ${connectionsCubit.connections.length} connections '
        'loaded; currentUser=${connectionsCubit.currentUser.userId}');

    SingleConnectionEntity? connection;
    for (final SingleConnectionEntity candidate
        in connectionsCubit.connections) {
      // Case-insensitive: emails are, and a stored id that differs only in
      // case would otherwise read as "no such user".
      if (candidate.userId.toLowerCase() == otherUserId.toLowerCase()) {
        connection = candidate;
        break;
      }
    }

    // No match means this email has no employee profile the messaging module
    // could shape into a connection — a deactivated or never-onboarded user.
    if (connection == null) {
      final String sample = connectionsCubit.connections
          .take(10)
          .map((SingleConnectionEntity c) => c.userId)
          .join(', ');
      log('[openChatWithUser] ✗ no connection whose userId == "$otherUserId" '
          '(ids are emails; matched case-insensitively). '
          'First ids loaded: [$sample]');
      return OpenChatResult.userNotFound;
    }

    // Writing the connection document is what makes the pair addressable. It is
    // skipped when they already have one, so a repeat tap costs nothing.
    final bool alreadyConnected = connectionsCubit.filteredConnections.any(
        (SingleConnectionEntity c) =>
            c.userId.toLowerCase() == otherUserId.toLowerCase());
    if (!alreadyConnected) {
      await connectionsCubit.createNewConnection(
        currentUser: connectionsCubit.currentUser,
        newConnectionUser: connection.toBaseMessagingInterface(),
      );
    }

    // The tail of `ConnectionsCubit.selectConnection`, minus its
    // `context.read<SingleChatCubit>()`.
    final SingleChatCubit singleChatCubit = Get.find<SingleChatCubit>();

    connectionsCubit.selectSingleConnection(connection);
    await singleChatCubit.startChat(
      otherSideData: connection,
      currentUserData: connectionsCubit.currentUser,
    );
    singleChatCubit.getFirstUnreadIndex();

    return OpenChatResult.opened;
  }

  /// Photo straight off the record, falling back to the org-chart lookup.
  String? _photoOf(NewEmployeeModelHistory employee) {
    try {
      return employee.photo!.last!;
    } catch (_) {
      try {
        return Get.find<OrgChartEmployeeController>()
            .getEmployeePhoto(employee.email!.last!);
      } catch (_) {
        return null;
      }
    }
  }
}

/// Outcome of [MessagingInterfaceImplementation.tryOpenChatWithUser].
enum OpenChatResult {
  opened,

  /// The email is the signed-in user's own — there is no chat with yourself.
  self,

  /// Messaging has not finished initialising this session.
  notReady,

  /// No employee / messaging profile matches that email.
  userNotFound,

  /// Anything else (the screen closed mid-way).
  failed,
}

/// Tells the user, in their language, why [OpenChatResult] was not
/// [OpenChatResult.opened]. No OK button: it closes itself after 3 seconds.
Future<void> showOpenChatFailure(
    BuildContext context, OpenChatResult result) async {
  if (result == OpenChatResult.opened || !context.mounted) return;
  final S l = S.of(context);
  final String message = switch (result) {
    OpenChatResult.self => l.cannotMessageYourself,
    OpenChatResult.notReady => l.chatNotReady,
    OpenChatResult.userNotFound => l.chatUserNotFound,
    _ => l.couldNotOpenChat,
  };
  await CustomDialogManager.showMessage(
    context: context,
    lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
    title: message,
    closeAfter: const Duration(seconds: 3),
  );
}
