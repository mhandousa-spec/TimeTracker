// Date: 1/9/2024
// By:  Nada Mohammed , Youssef Ashraf
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the community cubit used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../m1_chat/data/models/message/audio_message_model.dart';
import '../../../m1_chat/data/models/message/message_model.dart';
import '../../../m1_chat/data/models/message/poll_message_model.dart';
import '../../../m1_chat/data/models/message/video_message_model.dart';
import '../../../../../core/helper/message_module/main_helper/update_ui_ids.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../m1_chat/data/models/chat/chat_model.dart';
import '../../../m1_chat/data/models/media/doc_info_model.dart';
import '../../../m1_chat/data/models/media/image_model.dart';
import '../../../m1_chat/data/models/media/link_model.dart';
import '../../../m1_chat/data/models/media/media_model.dart';
import '../../../m3_groups/data/models/legacy_group_model.dart';
import '../../data/models/member_model.dart';

// State classes
abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<ChatModel> singleChats;
  final List<ChatModel> groupChats;
  final List<ChatModel> allChats;
  final List<Member> currentContacts;
  final List<GroupModel> groups;
  final List<ChatModel> frequentlyContacted;
  final Map<ChatModel, bool> selectedChats;
  final bool isSelectedChat;
  final AllTabs selectedAllTab;
  final UserCategory? selectedTab;
  final bool? tabletMediaView;
  final bool? viewContactView;
  final bool? showAdditionalInfo;
  final List<ChatModel>? filteredSingleChats;
  final List<ChatModel>? filteredGroupChats;
  final bool isDarkModeEnabled;
  final String selectedLanguage;

  CommunityLoaded({
    required this.singleChats,
    required this.groupChats,
    required this.allChats,
    required this.currentContacts,
    required this.groups,
    required this.frequentlyContacted,
    required this.selectedChats,
    required this.isSelectedChat,
    required this.selectedAllTab,
    this.selectedTab,
    this.tabletMediaView,
    this.viewContactView,
    this.showAdditionalInfo,
    this.filteredSingleChats,
    this.filteredGroupChats,
    required this.isDarkModeEnabled,
    required this.selectedLanguage,
  });

  CommunityLoaded copyWith({
    List<ChatModel>? singleChats,
    List<ChatModel>? groupChats,
    List<ChatModel>? allChats,
    List<Member>? currentContacts,
    List<GroupModel>? groups,
    List<ChatModel>? frequentlyContacted,
    Map<ChatModel, bool>? selectedChats,
    bool? isSelectedChat,
    AllTabs? selectedAllTab,
    UserCategory? selectedTab,
    bool? tabletMediaView,
    bool? viewContactView,
    bool? showAdditionalInfo,
    List<ChatModel>? filteredSingleChats,
    List<ChatModel>? filteredGroupChats,
    bool? isDarkModeEnabled,
    String? selectedLanguage,
    bool clearTabletMediaView = false,
    bool clearViewContactView = false,
    bool clearShowAdditionalInfo = false,
    bool clearFilteredSingleChats = false,
    bool clearFilteredGroupChats = false,
  }) {
    return CommunityLoaded(
      singleChats: singleChats ?? this.singleChats,
      groupChats: groupChats ?? this.groupChats,
      allChats: allChats ?? this.allChats,
      currentContacts: currentContacts ?? this.currentContacts,
      groups: groups ?? this.groups,
      frequentlyContacted: frequentlyContacted ?? this.frequentlyContacted,
      selectedChats: selectedChats ?? this.selectedChats,
      isSelectedChat: isSelectedChat ?? this.isSelectedChat,
      selectedAllTab: selectedAllTab ?? this.selectedAllTab,
      selectedTab: selectedTab ?? this.selectedTab,
      tabletMediaView: clearTabletMediaView ? null : (tabletMediaView ?? this.tabletMediaView),
      viewContactView: clearViewContactView ? null : (viewContactView ?? this.viewContactView),
      showAdditionalInfo: clearShowAdditionalInfo ? null : (showAdditionalInfo ?? this.showAdditionalInfo),
      filteredSingleChats: clearFilteredSingleChats ? null : (filteredSingleChats ?? this.filteredSingleChats),
      filteredGroupChats: clearFilteredGroupChats ? null : (filteredGroupChats ?? this.filteredGroupChats),
      isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

// Cubit
class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit() : super(CommunityInitial());

  late TabController tabController;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController chatSearchController = TextEditingController();

  bool? _tabletMediaView;
  bool? _viewContactView;
  bool? _showAdditionalInfo;

  bool _isDarkModeEnabled = false;
  String _selectedLanguage = 'ENG';
  bool get isArabic => _selectedLanguage == 'AR';

  List<String> communityTabs = [
    'All',
    'Design',
    'Marketing',
    'Software Developing',
  ];


// Add this getter
  bool get isTabControllerInitialized {
    try {
      final _ = tabController;
      return true;
    } catch (_) {
      return false;
    }
  }

  UserCategory? _selectedTab;
  UserCategory? get selectedTab => _selectedTab;

  List<AllTabs> allTabs = [
    AllTabs.directMessages,
    AllTabs.groups,
  ];

  AllTabs _selectedAllTab = AllTabs.directMessages;
  AllTabs get selectedAllTab => _selectedAllTab;

  List<GroupModel> _groups = [];
  List<ChatModel> _groupChats = [];
  List<ChatModel> _singleChats = [];
  List<Member> _currentContacts = [];
  List<ChatModel> _allChats = [];
  Map<ChatModel, bool> _selectedChats = {};
  bool _isSelectedChat = false;
  List<ChatModel> _frequentlyContacted = [];
  List<ChatModel>? _filteredSingleChats;
  List<ChatModel>? _filteredGroupChats;

  // Getters
  List<ChatModel> get singleChats => _singleChats;
  List<ChatModel> get groupChats => _groupChats;
  List<GroupModel> get groups => _groups;

  void initialize(BuildContext context) {

    // Fetch data first
    fetchSingleChats();
    fetchCurrentContacts();
    fetchGroups();
    setAllChats();
    fetchFrequencyContacted();

    // Safe initialization with null check
    try {
      final connectionsCubit = context.read<ConnectionsCubit>();
      final categoriesLength = connectionsCubit.categories?.length ?? 1;


      // Note: TabController needs TickerProvider from StatefulWidget
      // You'll need to pass this from a StatefulWidget
      // For now, this is a placeholder

      // Set initial selected tab if categories exist
      if (connectionsCubit.categories != null &&
          connectionsCubit.categories!.isNotEmpty) {
        _selectedTab = connectionsCubit.categories![0];
      }

      _emitLoadedState();

    } catch (e, stackTrace) {
    }
  }

  void initializeTabController(TickerProvider vsync, int length) {
    tabController = TabController(length: length, vsync: vsync);
    tabController.addListener(() {
      // You'll need to pass ConnectionsCubit or categories
      // This is a placeholder
      _emitLoadedState();
    });
  }

  void toggleDarkMode() {
    _isDarkModeEnabled = !_isDarkModeEnabled;
    AppTheme.toggleTheme();
    _emitLoadedState();
  }

  void toggleLanguage() {
    if (_selectedLanguage == 'ENG') {
      // Update locale through your app's locale management
      _selectedLanguage = 'AR';
    } else {
      _selectedLanguage = 'ENG';
    }
    _emitLoadedState();
  }

  void toggleShowAdditionalInfo(bool val) {
    _showAdditionalInfo = !val ? null : val;

    if (!val) {
      _viewContactView = null;
      _tabletMediaView = null;
    }

    _emitLoadedState();
  }

  void updateAllTabs(int index) {
    _selectedAllTab = allTabs[index];
    _emitLoadedState();
  }

  void fetchFrequencyContacted() {
    _frequentlyContacted.clear();
    for (final chat in _allChats) {
      if (chat.messages.isNotEmpty && _frequentlyContacted.length < 5) {
        _frequentlyContacted.add(chat);
      }
    }
    _frequentlyContacted.shuffle();
  }

  void forwardMessage(List<MessageModel> messages, BuildContext context) {
    messages.sort((a, b) => a.sentDate.compareTo(b.sentDate));

    for (final chat in _selectedChats.entries) {
      for (final message in messages) {
        final isSelected = chat.value;
        if (isSelected) {
          PollMessageModel? newPoll;
          AudioMessageModel? newAudio;
          VideoMessageModel? newVideo;

          if (message.pollModel != null) {
            newPoll = message.pollModel!.copyWith(
              options: message.pollModel!.options,
              question: message.pollModel!.question,
              isMultiple: message.pollModel!.isMultible,
              pollValues: [for (var _ in message.pollModel!.options) false],
              votes: [for (var _ in message.pollModel!.options) 0],
              voters: {
                for (var option in message.pollModel!.options) option: [],
              },
            );
          } else if (message.audioModel != null) {
            newAudio = AudioMessageModel(
              audioPath: message.audioModel!.audioPath,
              duration: message.audioModel!.duration,
              isCurrentPlaying: false,
              rate: '1.0x',
              speedUpDuration: null,
            );
          } else if (message.videoModel != null) {
            // newVideo = VideoMessageModel(...)
          }

          final newMessage = message.copyWith(
            isMeLastMessage: true,
            isStarred: false,
            isDelivered: false,
            isRead: false,
            pollModel: newPoll,
            sentUserID: '1',
            sentUserImage: null,
            audioModel: newAudio,
            videoModel: newVideo,
          );
          chat.key.messages.add(newMessage);

          // // Scroll to latest message
          // context.read<MessageCubit>().scrollToLatest(chat.key.messages.length - 1);
          //
          // // Reset checkboxes and hide selecting sheet
          // context.read<MessageCubit>().toggleSelectMessages(false);
        }
      }
    }

    resetSelectedChats();
    _emitLoadedState();
  }

  void toggleSelectedChat(ChatModel chat) {
    _selectedChats[chat] = !_selectedChats[chat]!;
    _isSelectedChat = _selectedChats.values.any((element) => element == true);
    _emitLoadedState();
  }

  void resetSelectedChats() {
    for (final chat in _selectedChats.keys) {
      _selectedChats[chat] = false;
    }
    _isSelectedChat = false;
    _emitLoadedState();
  }

  void setAllChats() {
    _allChats = _singleChats + _groupChats;
    _allChats.shuffle();
    for (final chat in _allChats) {
      _selectedChats[chat] = false;
    }
  }

  void addGroup(GroupModel group) {
    _groups.add(group);
    _groupChats.add(
      ChatModel(
        messages: [],
        mediaModel: dummyMedia,
        groupModel: group,
      ),
    );
    _emitLoadedState();
  }

  void addChat(int index) {
    bool isInChats = _singleChats.any((chat) {
      return chat.otherUser!.id == _currentContacts[index].id;
    });

    if (!isInChats) {
      var newChat = ChatModel(
        messages: [],
        mediaModel: dummyMedia,
        otherUser: _currentContacts[index],
        createdAt: DateTime.now(),
      );

      _singleChats.add(newChat);
      _emitLoadedState();
    }
  }

  void filterAllChats() {
    filterGroupChats();
    filterSingleChats();
  }

  void filterGroupChats() {
    if (searchController.text.isEmpty) {
      _filteredGroupChats = null;
    } else {
      _filteredGroupChats = _groupChats
          .where((element) =>
          element.groupModel!.groupName.trim().toLowerCase().contains(
            searchController.text.trim().toLowerCase(),
          ))
          .toList();
    }
    _emitLoadedState();
  }

  void filterSingleChats() {
    if (searchController.text.isEmpty) {
      _filteredSingleChats = null;
    } else {
      _filteredSingleChats = _singleChats
          .where(
            (element) =>
            element.otherUser!.firstName.trim().toLowerCase().contains(
              searchController.text.trim().toLowerCase(),
            ),
      )
          .toList();
    }
    _emitLoadedState();
  }

  void refreshCommunity() {
    _emitLoadedState();
  }

  // Helper method to emit loaded state
  void _emitLoadedState() {
    emit(CommunityLoaded(
      singleChats: _singleChats,
      groupChats: _groupChats,
      allChats: _allChats,
      currentContacts: _currentContacts,
      groups: _groups,
      frequentlyContacted: _frequentlyContacted,
      selectedChats: _selectedChats,
      isSelectedChat: _isSelectedChat,
      selectedAllTab: _selectedAllTab,
      selectedTab: _selectedTab,
      tabletMediaView: _tabletMediaView,
      viewContactView: _viewContactView,
      showAdditionalInfo: _showAdditionalInfo,
      filteredSingleChats: _filteredSingleChats,
      filteredGroupChats: _filteredGroupChats,
      isDarkModeEnabled: _isDarkModeEnabled,
      selectedLanguage: _selectedLanguage,
    ));
  }

  // ************** DUMMY DATA **************

  void fetchCurrentContacts() {
    _currentContacts = [
      Member(
          firstName: 'Aya Magdy',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user,
          id: '1',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Sara',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user2,
          id: '2',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Ahmed',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user3,
          id: '3',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Ali',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user4,
          id: '4',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Maya',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user5,
          id: '5',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Sara',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.user,
          id: '6',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Maria',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.profile,
          id: '7',
          phoneNumber: '+20 1022199451'),
      Member(
          firstName: 'Sara',
          lastName: 'Ahmed',
          avatarUrl: AppAssets.profile2,
          id: '8',
          phoneNumber: '+20 1022199451'),
    ];
  }

  void fetchGroups() {
    _groups = [
      // ... (keep all your dummy group data here - same as original)
      GroupModel(
        id: '1',
        groupName: 'Owners Owners Owners Owners Owners Owners Owners',
        groupImage: AppAssets.groupProfile,
        groupAdmin: Member(
            firstName: 'Aya',
            lastName: 'Ahmed',
            avatarUrl: AppAssets.user,
            id: '1',
            phoneNumber: '+20 1022199451'),
        groupMembers: [
          // ... members
        ],
      ),
      // ... rest of groups
    ];

    fetchGroupChats();
  }

  final dummyMedia = MediaModel(
    images: [
      ImageModel(
        date: DateTime.parse('2020-08-30'),
        img: AppAssets.profile2,
      ),
      // ... rest of images
    ],
    pdfs: [
      DocInfoModel(
        date: DateTime.parse('2024-08-20'),
        fileName: 'Employee .pdf',
        fileInfo: '2 pages .  87KB . Pdf',
      ),
      // ... rest of pdfs
    ],
    links: [
      LinkModel(
          date: DateTime.parse('2024-08-20'),
          link:
          "https://www.flaticon.com/free-icon/pdf_4726010?term=pdf&page=1&position=6&origin=search&related_id=4726010"),
      // ... rest of links
    ],
  )
    ..sortImageDates()
    ..sortPdfDates()
    ..sortLinksDates()
    ..calcTotalMediaItems();

  void fetchGroupChats() {
    _groupChats.clear();
    for (final group in _groups) {
      _groupChats.add(
        ChatModel(
          messages: [
            // ... messages
          ],
          mediaModel: MediaModel(),
          groupModel: group,
        ),
      );
    }
  }

  void fetchSingleChats() {
    _singleChats = [
      // ... (keep all your dummy single chat data here - same as original)
    ];
  }

  @override
  Future<void> close() {
    searchController.dispose();
    chatSearchController.dispose();
    tabController.dispose();
    return super.close();
  }
}

enum AllTabs {
  directMessages,
  groups,
}

extension AllTabsExtension on AllTabs {
  String get getName {
    switch (this) {
      case AllTabs.directMessages:
        return 'Direct Messages';
      case AllTabs.groups:
        return 'Groups';
    }
  }
}