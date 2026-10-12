/// Module: messaging / groups / presentation/controller/groups_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: groups_controller.dart
/// Purpose: Groups controller — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
// Date: 3/9/2024
// By:Mohamed Ashraf
// Last update: 3/9/2024
// Objectives: This file is responsible for providing the groups controller used in the community feature.

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import '../../../../../core/helper/message_module/interface/entity/group_chat_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../../../m4_messaging_home/domain/enums/sort_enum.dart';
import '../../data/models/group_admin_model.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/base_repository/base_group_repository.dart';
import '../../domain/usecases/create_group_use_case.dart';
import '../../domain/usecases/get_groups_use_case.dart';
// ADDED 2/9/2026 — spec section 2.4.
import 'package:knowticed_plus/features/messaging/main_controller/notifications/messages_notification_service.dart';
// ADDED 2/9/2026 — the Messages role switches.
import 'package:knowticed_plus/features/messaging/main_controller/helper/messages_permissions.dart';

// State classes
abstract class GroupsState {}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<GroupEntity> groups;
  final GroupEntity? selectedGroup;
  final List<MemberEntity> members;
  final List<MemberEntity> selectedMembers;
  final bool isMemberSelected;
  final File? groupImage;
  final String searchText;
  final String userCategoryId;
  final bool isMakePrivateEnabled;
  final bool isAdminEnabled;
  final bool isDisappearingMessagesEnabled;
  final bool isMuteEnabled;
  final Map<int, String> selectedRole;

  GroupsLoaded({
    required this.groups,
    this.selectedGroup,
    required this.members,
    required this.selectedMembers,
    required this.isMemberSelected,
    this.groupImage,
    required this.searchText,
    required this.userCategoryId,
    required this.isMakePrivateEnabled,
    required this.isAdminEnabled,
    required this.isDisappearingMessagesEnabled,
    required this.isMuteEnabled,
    required this.selectedRole,
  });

  GroupsLoaded copyWith({
    List<GroupEntity>? groups,
    GroupEntity? selectedGroup,
    List<MemberEntity>? members,
    List<MemberEntity>? selectedMembers,
    bool? isMemberSelected,
    File? groupImage,
    String? searchText,
    String? userCategoryId,
    bool? isMakePrivateEnabled,
    bool? isAdminEnabled,
    bool? isDisappearingMessagesEnabled,
    bool? isMuteEnabled,
    Map<int, String>? selectedRole,
    bool clearGroupImage = false,
    bool clearSelectedGroup = false,
  }) {
    return GroupsLoaded(
      groups: groups ?? this.groups,
      selectedGroup:
      clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      members: members ?? this.members,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      isMemberSelected: isMemberSelected ?? this.isMemberSelected,
      groupImage: clearGroupImage ? null : (groupImage ?? this.groupImage),
      searchText: searchText ?? this.searchText,
      userCategoryId: userCategoryId ?? this.userCategoryId,
      isMakePrivateEnabled: isMakePrivateEnabled ?? this.isMakePrivateEnabled,
      isAdminEnabled: isAdminEnabled ?? this.isAdminEnabled,
      isDisappearingMessagesEnabled:
      isDisappearingMessagesEnabled ?? this.isDisappearingMessagesEnabled,
      isMuteEnabled: isMuteEnabled ?? this.isMuteEnabled,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

class GroupsError extends GroupsState {
  final String message;

  GroupsError(this.message);
}

// Cubit
class GroupsCubit extends Cubit<GroupsState> {
  final BaseGroupsRepository repository;
  late GroupChatInterfaceParameters currentUser;
  late Future<List<UserConnectionInterfaceParameters>> Function()
  getAllUsersDate;

  TextEditingController searchController = TextEditingController();
  final TextEditingController membersSearchTextField = TextEditingController();

  GroupsCubit({required this.repository}) : super(GroupsInitial());

  bool isCreateGroup = false;

  /// ********************** CREATE GROUP CONTROLLERS ***********************
  List<MemberEntity> _members = [];
  List<MemberEntity> get members => _members;

  List<MemberEntity> _selectedMembers = [];
  List<MemberEntity> get selectedMembers => _selectedMembers;

  String _searchText = '';
  String get searchText => _searchText;

  String _userCategoryId = '';
  String get userCategoryId => _userCategoryId;
  set userCategoryId(String value) {
    _userCategoryId = value;
    _emitLoadedState();
  }

  bool _isMemberSelected = false;
  bool get isMemberSelected => _isMemberSelected;

  void searchMembers(String value) {
    _searchText = value;
    _emitLoadedState();
  }

  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupNameArController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController groupDescriptionArController = TextEditingController();
  GlobalKey<FormState> newGroupFormKey = GlobalKey<FormState>();
  File? _groupImage;
  File? get groupImage => _groupImage;

  void initialize({required TextEditingController searchController}) {
    this.searchController = searchController;
    _selectedMembers = [];
    emit(GroupsLoaded(
      groups: [],
      members: [],
      selectedMembers: [],
      isMemberSelected: false,
      searchText: '',
      userCategoryId: '',
      isMakePrivateEnabled: true,
      isAdminEnabled: true,
      isDisappearingMessagesEnabled: true,
      isMuteEnabled: true,
      selectedRole: {},
    ));
  }

  /// Categories used to resolve member departments — supplied by ConnectionsCubit
  /// so the domain entity never reaches into presentation via GetX (§3).
  List<UserCategory>? _categories;

  /// Rebuild [_members] from the current connections, KEEPING whatever was
  /// already ticked.
  ///
  /// FIXED 2/9/2026 — this used to start with `_selectedMembers = []`, and
  /// [searchMembersToAddToGroup] calls it on every department change and every
  /// search keystroke. So picking someone from Finance and then switching to
  /// Marketing silently threw the Finance pick away.
  ///
  /// Two things have to be carried across the rebuild, not one:
  ///
  ///  1. `isSelected` on the NEW entities — `fromSingleConnectionEntity`
  ///     always constructs them false, so the tick would vanish from the card
  ///     even if the id survived somewhere.
  ///  2. `_selectedMembers` must hold those SAME new instances. MemberEntity
  ///     does not override `==`, so `toggleSelection`'s
  ///     `_selectedMembers.remove(member)` is an identity check — leaving the
  ///     old objects in there would make un-ticking silently do nothing.
  ///
  /// Selection is matched by [MemberEntity.memberId] and deliberately survives
  /// the department filter: `searchMembersToAddToGroup` narrows `_members`
  /// afterwards, so a person picked under one department is no longer in the
  /// grid under another — but they are still selected, and the chip row above
  /// the grid still shows them.
  ///
  /// A genuine reset is the job of [initialize] / [resetCreateGroupControllers],
  /// which clear the list explicitly.
  void getMembers({required ConnectionsCubit connectionsCubit}) {
    _categories = connectionsCubit.categories;

    final Set<String> previouslySelectedIds =
        _selectedMembers.map((m) => m.memberId).toSet();

    _members = [];
    final List<MemberEntity> reselected = [];

    connectionsCubit.connections.forEach((connection) {
      log('👤 [getMembers] ${connection.primaryLanguageName} | userCategory: ${connection.userCategory?.primaryLanguageName ?? "NULL"} | categoryId: ${connection.userCategory?.categoryId ?? "NULL"}');
      final member = MemberEntity.fromSingleConnectionEntity(connection);
      if (previouslySelectedIds.contains(member.memberId)) {
        member.isSelected = true;
        reselected.add(member);
      }
      _members.add(member);
    });

    _selectedMembers = reselected;
    _isMemberSelected = _selectedMembers.isNotEmpty;

    log("getMembers called - members count: ${_members.length}, "
        "kept ${_selectedMembers.length} selected");
    _emitLoadedState();
  }

  void _enrichMembersWithCategories() {
    if (_selectedGroup == null) return;

    // Categories are stored on this cubit (set from ConnectionsCubit) — no GetX.
    final categories = _categories;

    log('🔧 [enrichMembers] categories available: ${categories?.length ?? "NULL"}');

    if (categories == null || categories.isEmpty) {
      log('❌ [enrichMembers] No categories to enrich with');
      return;
    }

    for (final member in _selectedGroup!.members) {
      if (member.category != null) continue; // already resolved

      // Try to match via categoryId stored on the member
      // Since categoryId may be null, try matching via departmentId from employee data
      log('🔧 [enrichMembers] member: ${member.primaryLanguageName} | categoryId: ${member.category?.categoryId ?? "NULL"}');
    }
  }




  // ✅ Updated to support comma-separated multi-select category ids
  void searchMembersToAddToGroup(
      String value,
      ConnectionsCubit connectionsCubit,
      MessagingHomeCubit homeCubit) {
    getMembers(connectionsCubit: connectionsCubit);
    try
    {
      log("selected category ids: $_userCategoryId");

      // ✅ Split comma-separated ids into a list
      final selectedIds = _userCategoryId.isEmpty
          ? <String>[]
          : _userCategoryId.split(',').where((id) => id.isNotEmpty).toList();

      _members = _members.where((member) {
        final matchesSearch = member.primaryLanguageName
            .toLowerCase()
            .contains(value.toLowerCase()) ||
            (member.secondaryLanguageName?.contains(value) ?? false);

        // ✅ If no categories selected → show all; else match any selected id
        final matchesCategory = selectedIds.isEmpty ||
            selectedIds.contains(member.category?.categoryId);

        bool result = matchesSearch && matchesCategory;
        log("member: ${member.category?.primaryLanguageName} - $result");
        return result;
      }).toList();
    } catch (e) {
      log("error in searchMembersToAddToGroup: $e");
    }

    // remove members already in the group
    if (state is GroupsLoaded &&
        (state as GroupsLoaded).selectedGroup != null) {
      for (var member in (state as GroupsLoaded).selectedGroup!.members) {
        _members.removeWhere((element) => element.memberId == member.memberId);
      }
    }
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  void toggleSelection(MemberEntity member) {
    if (member.isSelected) {
      _selectedMembers.remove(member);
    } else {
      _selectedMembers.add(member);
    }
    member.isSelected = !member.isSelected;
    _isMemberSelected = _selectedMembers.isNotEmpty;
    _emitLoadedState();
  }

  void removeSelectedMember(MemberEntity member) {
    member.isSelected = false;
    _selectedMembers.remove(member);
    _isMemberSelected = _selectedMembers.isNotEmpty;
    _emitLoadedState();
  }

  /// Sets the picked group image. Picking itself happens in the page via
  /// MediaPickerService — the cubit no longer touches the picker (§16/§20).
  void setGroupImage(File? image) {
    _groupImage = image;
    _emitLoadedState();
  }

  // ✅ Updated filteredMembers to support multi-select comma-separated ids
  List<MemberEntity> get filteredMembers {
    final selectedIds = _userCategoryId.isEmpty
        ? <String>[]
        : _userCategoryId.split(',').where((id) => id.isNotEmpty).toList();

    final List<MemberEntity> matched;

    if (_searchText.isEmpty && selectedIds.isEmpty) {
      matched = _members;
    } else {
      final List<MemberEntity> result = [];
      for (var member in _members) {
        final matchesSearch = member.primaryLanguageName
            .toLowerCase()
            .contains(_searchText.trim().toLowerCase()) ||
            (member.secondaryLanguageName?.contains(_searchText.trim()) ??
                false);

        final matchesCategory = selectedIds.isEmpty ||
            selectedIds.contains(member.category?.categoryId);

        if (matchesSearch && matchesCategory) {
          result.add(member);
        }
      }
      matched = result;
    }

    return _selectedFirst(matched);
  }

  /// Ticked members float to the top of the grid, everything else keeps the
  /// order it already had.
  ///
  /// ADDED 2/9/2026. On a long employee list the person you just ticked
  /// scrolled away and there was no way to see what was selected without
  /// hunting for it. A STABLE partition, not a sort — a sort with a boolean
  /// comparator would also reshuffle the members that share a value.
  ///
  /// Returns a NEW list, so [_members] itself is never reordered.
  List<MemberEntity> _selectedFirst(List<MemberEntity> members) {
    final List<MemberEntity> selected = [];
    final List<MemberEntity> rest = [];
    for (final member in members) {
      (member.isSelected ? selected : rest).add(member);
    }
    return [...selected, ...rest];
  }

  /// Create the group. Returns whether it was actually written.
  ///
  /// CHANGED 2/9/2026 — was `Future<void>` that popped the page itself. The
  /// Create button now runs through `CustomDialogManager.showDialogFlow`,
  /// whose `onConfirm` is a `Future<bool>`: it only shows the success step if
  /// the work really succeeded. Returning void meant every outcome — a
  /// permission denial, a failed validation, a repository error — looked
  /// identical to a success.
  ///
  /// [popOnSuccess] keeps the old behaviour for any caller that is not
  /// driving its own dialog; the dialog flow passes false and pops from
  /// `onSuccessComplete`, so the page does not disappear out from under the
  /// success dialog.
  Future<bool> createGroup(
    BuildContext context, {
    bool popOnSuccess = true,
  }) async {
    // GATED 2/9/2026 — Figma "Adding New Role" → Messages → Create Group.
    //
    // Guarded HERE rather than only on the button that opens the form. This is
    // the method that actually writes the group, so a stale form, a deep link
    // or a widget built before a role change all hit the same check. Hiding
    // the entry point as well is right, but it is not enforcement — the same
    // lesson the Knowledge Hub permissions pass produced.
    //
    // Silent return: the form's own validation failure path is also silent, so
    // an error dialog here would be the only one in the method.
    if (!MessagesAccess.canCreateGroup) {
      log('⛔ createGroup denied: section on=${MessagesAccess.canUseMessagesPermissions}, '
          'stored=${MessagesAccess.storedForDebug}',
          name: 'MessagesPermissions');
      return false;
    }

    if (newGroupFormKey.currentState!.validate() && _isMemberSelected) {
      GroupAdminModel admin = GroupAdminModel(
          adminId: currentUser.userId,
          isAdmin: [true],
          timestamps: [Timestamp.now()]);
      _selectedMembers.add(MemberEntity(
          memberId: currentUser.userId,
          isAdmin: true,
          primaryLanguageName: currentUser.primaryLanguageName,
          secondaryLanguageName: currentUser.secondaryLanguageName,
          primaryLanguageSubInfo: currentUser.primaryLanguageSubInfo,
          secondaryLanguageSubInfo: currentUser.secondaryLanguageSubInfo,
          memberPhone: currentUser.phone,
          numOfUnreadMessages: 0,
          memberImage: currentUser.imageUri,
          addedTime: null));

      var response =
      await CreateGroupUseCase(groupRepository: repository).execute(
        groupName: groupNameController.text,
        groupNameAr: groupNameArController.text.trim().isEmpty
            ? null
            : groupNameArController.text.trim(),
        groupDescription: groupDescriptionController.text,
        groupDescriptionAr: groupDescriptionArController.text.trim().isEmpty
            ? null
            : groupDescriptionArController.text.trim(),
        groupImage: _groupImage?.path,
        groupMembers: _selectedMembers,
        // Two more role switches applied at the point of WRITING rather than
        // at the toggle that sets them. A role without
        // `Disappearing_Messages` cannot create a group with them on even if
        // the toggle was somehow left enabled — the stored value is the thing
        // that matters, and this is the last place before it is stored.
        isDisappearingMessages: MessagesAccess.canUseDisappearingMessages &&
            _isDisappearingMessagesEnabled,
        isOnlyAdminsCanSend: _isAdminEnabled,
        isPublic: !_isMakePrivateEnabled,
        // `isUnMuted` is the INVERSE of muted, so denying the mute permission
        // means forcing this true, not false. Reading it the other way round
        // would silently mute every group a restricted role creates.
        isUnMuted: MessagesAccess.canMuteNotifications ? !_isMuteEnabled : true,
        createdBy: currentUser.userId,
        groupAdmins: [admin],
      );
      if (response.isRight()) {
        if (popOnSuccess && context.mounted) {
          Navigator.of(context).pop();
        }
        return true;
        // GetDialogHelper.generalDialog(
        //   context: context,
        //   child: DefaultDialog(
        //     title: "Creating New Group",
        //     subTitle: "You Successfully Created New Group",
        //     autoClose: true,
        //     lottieAsset: "assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json",
        //     showButtons: false,
        //   ),
        // );
      }
    }
    return false;
  }

  void clearGroupData() {
    groupNameController.clear();
    groupNameArController.clear();
    groupDescriptionController.clear();
    groupDescriptionArController.clear();
    _groupImage = null;
    for (var member in _selectedMembers) {
      member.isSelected = false;
    }
    _selectedMembers = [];
    newGroupFormKey.currentState?.reset();
    _isMemberSelected = false;
    _emitLoadedState();
  }

  ///********************** SWITCHES CONTROLLERS ***********************
  bool _isMakePrivateEnabled = true;
  bool get isMakePrivateEnabled => _isMakePrivateEnabled;

  onChangedMakePrivate(bool value) {
    _isMakePrivateEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isAdminEnabled = true;
  bool get isAdminEnabled => _isAdminEnabled;

  onChangedAdmin(bool value) {
    _isAdminEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isDisappearingMessagesEnabled = true;
  bool get isDisappearingMessagesEnabled => _isDisappearingMessagesEnabled;

  onChangedDisappearingMessages(bool value) {
    _isDisappearingMessagesEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isMuteEnabled = true;
  bool get isMuteEnabled => _isMuteEnabled;

  onChangMuteMessages(bool value) {
    _isMuteEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  /// ********************** GROUPS LIST CONTROLLERS ***********************
  List<GroupEntity> allGroups = [];
  List<GroupEntity> _groups = [];
  List<GroupEntity> get groups => _groups;

  /// Groups where both [otherUserId] and [currentUserId] are members.
  /// Error handling lives here (C1) so the UI never wraps this in try/catch
  /// (§11.2).
  List<GroupEntity> commonGroupsWith(String otherUserId, String currentUserId) {
    if (otherUserId.isEmpty || currentUserId.isEmpty) return [];
    try {
      return _groups.where((group) {
        final memberIds = group.members.map((m) => m.memberId).toSet();
        return memberIds.contains(otherUserId) &&
            memberIds.contains(currentUserId);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  GroupEntity? _selectedGroup;
  GroupEntity? get selectedGroup => _selectedGroup;

  StreamSubscription? groupsSubscription;

  // FIXED 24/9/2026 — realtime groups list: a Left used to cancel the
  // subscription for good (groups froze until restart). It now reconnects.
  Timer? _groupsRetryTimer;
  int _groupsRetryAttempt = 0;

  void _scheduleGroupsResubscribe() {
    if (isClosed) return;
    _groupsRetryTimer?.cancel();
    final int seconds =
        1 << (_groupsRetryAttempt < 4 ? _groupsRetryAttempt : 4);
    _groupsRetryAttempt++;
    _groupsRetryTimer = Timer(Duration(seconds: seconds), () {
      if (!isClosed) getGroups();
    });
  }

  getGroups() {
    closeGetGroupsSubscription();
    groupsSubscription = GetGroupsUseCase(groupRepository: repository)
        .execute(userId: currentUser.userId, categories: _categories)
        .listen((Either<Failure, dynamic> groupsEither) {
      if (isClosed) return;
      if (groupsEither.isLeft()) {
        _scheduleGroupsResubscribe();
        return;
      }
      if (groupsEither.isRight()) {
        _groupsRetryAttempt = 0;
        allGroups = groupsEither.getOrElse(() => []);
        log(" all groups: ${allGroups.length}");
        filterGroups();
        if (_selectedGroup != null) {
          // `.first` threw (and killed the stream) when the selected group
          // was no longer in the filtered list.
          final match = _groups
              .where((group) => group.groupId == _selectedGroup!.groupId);
          if (match.isNotEmpty) _selectedGroup = match.first;
          _selectedRole.clear();
        }
        _emitLoadedState();
      }
    },
        onError: (Object _, StackTrace __) => _scheduleGroupsResubscribe(),
        onDone: _scheduleGroupsResubscribe,
        cancelOnError: false);
  }

  void closeGetGroupsSubscription() {
    _groupsRetryTimer?.cancel();
    groupsSubscription?.cancel();
  }

  void resetCreateGroupControllers() {
    isCreateGroup = true;
    groupNameController.clear();
    groupNameArController.clear();
    groupDescriptionController.clear();
    groupDescriptionArController.clear();
    _groupImage = null;
    _isMakePrivateEnabled = true;
    _isAdminEnabled = true;
    _isDisappearingMessagesEnabled = true;
    _isMuteEnabled = true;
    _selectedMembers = [];
    membersSearchTextField.clear();
    newGroupFormKey.currentState?.reset();
    _isMemberSelected = false;
    _emitLoadedState();
  }

  /// Called when a direct message is opened, so the group is no longer
  /// treated as the active chat.
  void clearSelectedGroup() {
    if (_selectedGroup == null) return;
    _selectedGroup = null;
    _emitLoadedState(clearSelectedGroup: true);
  }

  void selectGroup(GroupEntity groupEntity) {
    log('🟢 selectGroup called for: ${groupEntity.primaryLanguageName}');
    log('🟢 groupEntity.groupNameAr: "${groupEntity.groupNameAr}"');
    log('🟢 groupEntity.groupDescriptionAr: "${groupEntity.groupDescriptionAr}"');
    isCreateGroup = false;
    _selectedGroup = groupEntity;
    log("selected group: ${_selectedGroup!.primaryLanguageName}");
    groupNameController.text = _selectedGroup!.primaryLanguageName ?? '';
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription ?? '';
    groupDescriptionArController.text =
        _selectedGroup!.groupDescriptionAr ?? '';
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _isAdminEnabled = _selectedGroup!.isOnlyAdminsCanSend;
    _isDisappearingMessagesEnabled = _selectedGroup!.isDisappearingMessages;
    _isMuteEnabled = !_selectedGroup!.isUnMuted;
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _groupImage = null;
    _selectedRole.clear();
    _emitLoadedState();
  }

  void filterGroups() {
    _groups = allGroups;
    if (searchController.text.isNotEmpty) {
      _groups = _groups
          .where((group) => group.primaryLanguageName
          .toLowerCase()
          .contains(searchController.text.toLowerCase()))
          .toList();
    }
    sortGroups();
    _emitLoadedState();
  }

  Map<int, String> _selectedRole = {};
  Map<int, String> get selectedRole => _selectedRole;

  void setRole(int index, String role) {
    _selectedRole[index] = role;
    _emitLoadedState();
  }

  updateGroupData() async {
    await repository.updateGroupData(
      image: _groupImage?.path,
      groupName: groupNameController.text.trim() !=
          (_selectedGroup!.primaryLanguageName)
          ? groupNameController.text.trim()
          : null,
      groupNameAr: groupNameArController.text.trim() !=
          (_selectedGroup!.groupNameAr ?? '')
          ? groupNameArController.text.trim()
          : null,
      groupDescription: groupDescriptionController.text.trim() !=
          (_selectedGroup!.groupDescription)
          ? groupDescriptionController.text.trim()
          : null,
      groupDescriptionAr: groupDescriptionArController.text.trim() !=
          (_selectedGroup!.groupDescriptionAr ?? '')
          ? groupDescriptionArController.text.trim()
          : null,
      isPublic: (!_isMakePrivateEnabled != (_selectedGroup!.isPublic))
          ? !_isMakePrivateEnabled
          : null,
      isOnlyAdminsCanSend:
      (_isAdminEnabled != (_selectedGroup!.isOnlyAdminsCanSend))
          ? _isAdminEnabled
          : null,
      isDisappearingMessages: (_isDisappearingMessagesEnabled !=
          (_selectedGroup!.isDisappearingMessages))
          ? _isDisappearingMessagesEnabled
          : null,
      isUnMuted: (!_isMuteEnabled != (_selectedGroup!.isUnMuted))
          ? !_isMuteEnabled
          : null,
      groupEntity: _selectedGroup!,
    );
    await saveMembersState();
  }

  Future<void> saveMembersState() async {
    await saveRemovedMembers();
    await saveAddedAdmins();
    await removeAdmin();
  }

  saveRemovedMembers() async {
    List<String> removedMembers = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Remove') {
        removedMembers.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (removedMembers.isNotEmpty) {
      await repository.removeGroupMembers(
          groupId: _selectedGroup!.groupId, members: removedMembers);
    }
  }

  addGroupMember(MemberEntity member) async {
    await repository.addGroupMembers(
        groupId: _selectedGroup!.groupId, member: member);
    membersSearchTextField.clear();
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  saveAddedAdmins() {
    List<String> addedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Admin' &&
          _selectedGroup!.members[key].isAdmin == false) {
        addedAdmins.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (addedAdmins.isNotEmpty) {
      repository.addGroupAdmins(
          groupId: _selectedGroup!.groupId, admins: addedAdmins);
    }
  }

  removeAdmin() {
    List<String> removedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Member' &&
          _selectedGroup!.members[key].isAdmin == true) {
        removedAdmins.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (removedAdmins.isNotEmpty) {
      repository.removeGroupAdmins(
          groupId: _selectedGroup!.groupId, admins: removedAdmins);
    }
  }

  void initGroupProfileController() {
    log('🟡 initGroupProfileController called');

    if (_selectedGroup == null) {
      log('🔴 selectedGroup is null — skipping');
      return;
    }

    // ── Populate controllers from selectedGroup ──
    groupNameController.text = _selectedGroup!.primaryLanguageName ?? '';
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription ?? '';
    groupDescriptionArController.text = _selectedGroup!.groupDescriptionAr ?? '';

    // ── Populate switches ──
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _isAdminEnabled = _selectedGroup!.isOnlyAdminsCanSend;
    _isDisappearingMessagesEnabled = _selectedGroup!.isDisappearingMessages;
    _isMuteEnabled = !_selectedGroup!.isUnMuted;
    _groupImage = null;
    _selectedRole.clear();

    log('🟢 Controllers populated:');
    log('🟢 name EN: "${groupNameController.text}"');
    log('🟢 name AR: "${groupNameArController.text}"');
    log('🟢 desc EN: "${groupDescriptionController.text}"');
    log('🟢 desc AR: "${groupDescriptionArController.text}"');

    _emitLoadedState();
  }

  filteredMentionsMembers(String memberName) {
    return _selectedGroup!.members
        .where((member) =>
    member.primaryLanguageName
        .toLowerCase()
        .contains(memberName.toLowerCase()) ||
        (member.secondaryLanguageName?.contains(memberName) ?? false))
        .toList();
  }

  void sortGroups({SortEnum? sortType}) {
    if (sortType == null) return;
    switch (sortType) {
      case SortEnum.ReadMessages:
        _groups.sort(
                (a, b) => b.myNumUnreadMessage.compareTo(a.myNumUnreadMessage));
        break;
      case SortEnum.UnRead:
        _groups.sort(
                (a, b) => a.myNumUnreadMessage.compareTo(b.myNumUnreadMessage));
        break;
    }
  }

  void deleteGroup() {
    // ADDED 2/9/2026 — spec section 2.4, "Group Deleted".
    //
    // ⚠️ RAISED BEFORE THE DELETE, and that ordering is the whole point: the
    // recipients ARE the group's members, and once the document is gone there
    // is no membership list left to read. Every other trigger fires after its
    // write; this one cannot.
    //
    // Not awaited, and it cannot throw — the delete must not be held up by,
    // or fail because of, a notification.
    final GroupEntity deleted = _selectedGroup!;
    unawaited(
      MessagesNotificationService.notifyGroupDeleted(
        memberUserIds:
            deleted.members.map((MemberEntity m) => m.memberId).toList(),
        groupName: deleted.primaryLanguageName,
        deletedByName: MessagesNotificationService.currentUserName,
      ),
    );

    repository.deleteGroup(groupId: deleted.groupId);
    _selectedGroup = null;
    _emitLoadedState(clearSelectedGroup: true);
  }

  void _emitLoadedState(
      {String? updateId,
        bool clearGroupImage = false,
        bool clearSelectedGroup = false}) {
    if (state is GroupsLoaded) {
      emit((state as GroupsLoaded).copyWith(
        groups: _groups,
        selectedGroup: _selectedGroup,
        members: _members,
        selectedMembers: _selectedMembers,
        isMemberSelected: _isMemberSelected,
        groupImage: _groupImage,
        searchText: _searchText,
        userCategoryId: _userCategoryId,
        isMakePrivateEnabled: _isMakePrivateEnabled,
        isAdminEnabled: _isAdminEnabled,
        isDisappearingMessagesEnabled: _isDisappearingMessagesEnabled,
        isMuteEnabled: _isMuteEnabled,
        selectedRole: _selectedRole,
        clearGroupImage: clearGroupImage,
        clearSelectedGroup: clearSelectedGroup,
      ));
    } else {
      emit(GroupsLoaded(
        groups: _groups,
        selectedGroup: clearSelectedGroup ? null : _selectedGroup,
        members: _members,
        selectedMembers: _selectedMembers,
        isMemberSelected: _isMemberSelected,
        groupImage: clearGroupImage ? null : _groupImage,
        searchText: _searchText,
        userCategoryId: _userCategoryId,
        isMakePrivateEnabled: _isMakePrivateEnabled,
        isAdminEnabled: _isAdminEnabled,
        isDisappearingMessagesEnabled: _isDisappearingMessagesEnabled,
        isMuteEnabled: _isMuteEnabled,
        selectedRole: _selectedRole,
      ));
    }
  }

  @override
  Future<void> close() {
    closeGetGroupsSubscription();
    searchController.dispose();  // ← add this
    groupNameController.dispose();
    groupNameArController.dispose();
    groupDescriptionController.dispose();
    groupDescriptionArController.dispose();
    membersSearchTextField.dispose();
    return super.close();
  }
}