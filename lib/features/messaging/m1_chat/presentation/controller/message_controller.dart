// Date: 6/8/2024
// By: Nada Mohammed , Youssef Ashraf
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a cubit for the messages in the direct messaging screen.

import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/reacts.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/services/message_module/audio_record_service.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/share_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../data/models/message/audio_message_model.dart';
import '../../data/models/message/doc_message_model.dart';
import '../../data/models/message/message_model.dart';
import '../../data/models/message/poll_message_model.dart';
import '../../data/models/message/video_message_model.dart';
import '../../domain/entity/message_entity.dart';
import '../ui/pages/chat_mobile_view.dart';
import '../../../../../core/helper/message_module/main_helper/update_ui_ids.dart';
import '../../../m3_groups/presentation/ui/pages/tablet/tablet_group_chat_profile_view.dart';
import '../../../m2_connections/data/models/member_model.dart';
import '../../../m2_connections/presentation/controller/community_controller.dart';
import '../../../m3_groups/data/models/legacy_group_model.dart';
import '../../data/models/location_message_model.dart';
import '../../data/models/chat/chat_model.dart';
import '../../data/models/chat_enums.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/services/image_picker_cubit.dart';

// State classes
abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoaded extends MessageState {
  final ChatModel? chatModel;
  final int? firstUnreadIndex;
  final bool isEmojiPickerVisible;
  final bool isRecording;
  final int ellapsedSeconds;
  final int ellapsedMinutes;
  final AudioMessageModel? currentlyPlayingAudioModel;
  final DurationValues? duration;
  final List<bool> clearOption;
  final bool? reportContact;
  final bool? blockContact;
  final bool multibleChoices;
  final List<TextEditingController> pollOptions;
  final List<TextEditingController> captionControllers;
  final int swiperIndex;
  final double bufferedVideo;
  final bool isPlaying;
  final String videoDuration;
  final bool progressShown;
  final bool slideChanging;
  final MessageEntity? editMessageModel;
  final MessageModel? replyMessageModel;
  final int? replyScrollIndex;
  final bool reactVisible;
  final List<bool> forwardCheckBoxes;
  final List<MessageModel> selectedForwardMessages;
  final bool selectMessages;
  final LocationMessageModel? pickedLocation;
  final String selectedAllTab;
  final Map<int, String> selectedRole;

  MessageLoaded({
    this.chatModel,
    this.firstUnreadIndex,
    required this.isEmojiPickerVisible,
    required this.isRecording,
    required this.ellapsedSeconds,
    required this.ellapsedMinutes,
    this.currentlyPlayingAudioModel,
    this.duration,
    required this.clearOption,
    this.reportContact,
    this.blockContact,
    required this.multibleChoices,
    required this.pollOptions,
    required this.captionControllers,
    required this.swiperIndex,
    required this.bufferedVideo,
    required this.isPlaying,
    required this.videoDuration,
    required this.progressShown,
    required this.slideChanging,
    this.editMessageModel,
    this.replyMessageModel,
    this.replyScrollIndex,
    required this.reactVisible,
    required this.forwardCheckBoxes,
    required this.selectedForwardMessages,
    required this.selectMessages,
    this.pickedLocation,
    required this.selectedAllTab,
    required this.selectedRole,
  });

  MessageLoaded copyWith({
    ChatModel? chatModel,
    int? firstUnreadIndex,
    bool? isEmojiPickerVisible,
    bool? isRecording,
    int? ellapsedSeconds,
    int? ellapsedMinutes,
    AudioMessageModel? currentlyPlayingAudioModel,
    DurationValues? duration,
    List<bool>? clearOption,
    bool? reportContact,
    bool? blockContact,
    bool? multibleChoices,
    List<TextEditingController>? pollOptions,
    List<TextEditingController>? captionControllers,
    int? swiperIndex,
    double? bufferedVideo,
    bool? isPlaying,
    String? videoDuration,
    bool? progressShown,
    bool? slideChanging,
    MessageEntity? editMessageModel,
    MessageModel? replyMessageModel,
    int? replyScrollIndex,
    bool? reactVisible,
    List<bool>? forwardCheckBoxes,
    List<MessageModel>? selectedForwardMessages,
    bool? selectMessages,
    LocationMessageModel? pickedLocation,
    String? selectedAllTab,
    Map<int, String>? selectedRole,
    bool clearFirstUnreadIndex = false,
    bool clearCurrentlyPlayingAudioModel = false,
    bool clearDuration = false,
    bool clearReportContact = false,
    bool clearBlockContact = false,
    bool clearEditMessageModel = false,
    bool clearReplyMessageModel = false,
    bool clearReplyScrollIndex = false,
    bool clearPickedLocation = false,
  }) {
    return MessageLoaded(
      chatModel: chatModel ?? this.chatModel,
      firstUnreadIndex: clearFirstUnreadIndex ? null : (firstUnreadIndex ?? this.firstUnreadIndex),
      isEmojiPickerVisible: isEmojiPickerVisible ?? this.isEmojiPickerVisible,
      isRecording: isRecording ?? this.isRecording,
      ellapsedSeconds: ellapsedSeconds ?? this.ellapsedSeconds,
      ellapsedMinutes: ellapsedMinutes ?? this.ellapsedMinutes,
      currentlyPlayingAudioModel: clearCurrentlyPlayingAudioModel ? null : (currentlyPlayingAudioModel ?? this.currentlyPlayingAudioModel),
      duration: clearDuration ? null : (duration ?? this.duration),
      clearOption: clearOption ?? this.clearOption,
      reportContact: clearReportContact ? null : (reportContact ?? this.reportContact),
      blockContact: clearBlockContact ? null : (blockContact ?? this.blockContact),
      multibleChoices: multibleChoices ?? this.multibleChoices,
      pollOptions: pollOptions ?? this.pollOptions,
      captionControllers: captionControllers ?? this.captionControllers,
      swiperIndex: swiperIndex ?? this.swiperIndex,
      bufferedVideo: bufferedVideo ?? this.bufferedVideo,
      isPlaying: isPlaying ?? this.isPlaying,
      videoDuration: videoDuration ?? this.videoDuration,
      progressShown: progressShown ?? this.progressShown,
      slideChanging: slideChanging ?? this.slideChanging,
      editMessageModel: clearEditMessageModel ? null : (editMessageModel ?? this.editMessageModel),
      replyMessageModel: clearReplyMessageModel ? null : (replyMessageModel ?? this.replyMessageModel),
      replyScrollIndex: clearReplyScrollIndex ? null : (replyScrollIndex ?? this.replyScrollIndex),
      reactVisible: reactVisible ?? this.reactVisible,
      forwardCheckBoxes: forwardCheckBoxes ?? this.forwardCheckBoxes,
      selectedForwardMessages: selectedForwardMessages ?? this.selectedForwardMessages,
      selectMessages: selectMessages ?? this.selectMessages,
      pickedLocation: clearPickedLocation ? null : (pickedLocation ?? this.pickedLocation),
      selectedAllTab: selectedAllTab ?? this.selectedAllTab,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

// Cubit
class MessageCubit extends Cubit<MessageState> {
  MessageCubit() : super(MessageInitial());

  OverlayEntry? overlayEntry;
  late TabController tabController;
  late TabController tabGroupController;

  final scrollController = ItemScrollController();
  final scrollPositionsListener = ItemPositionsListener.create();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final msgMenuScrollController = ScrollController();
  final messageFocusNode = FocusNode();
  final searchMemberController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController(text: '');
  final TextEditingController groupNameController = TextEditingController(text: '');
  final TextEditingController questionController = TextEditingController();

  final stopwatch = Stopwatch();
  final SwiperController swiperController = SwiperController();
  final MapController mapController = MapController();

  Duration newRecordDuration = Duration.zero;
  int firstVisibleIndex = 0;
  int speedIndex = 0;

  List<String> groupInfoTabs = [S.current.member];
  List<String> communityTabs = [S.current.all, S.current.design, S.current.department_marketing];

  final muteNotificationsDurationValues = [
    DurationValues.hours_8,
    DurationValues.week_1,
    DurationValues.always,
  ];

  final disappearingMessagingDurationValues = [
    DurationValues.hours_24,
    DurationValues.days_7,
    DurationValues.days_90,
    DurationValues.always,
    DurationValues.off,
  ];

  List<Speeds> speeds = [
    Speeds.speed_1,
    Speeds.speed_1_0_5,
    Speeds.speed_2,
  ];

  ChatModel? _chatModel;
  ChatModel? get chatModel => _chatModel;

  int? _firstUnreadIndex;
  int? get firstUnreadIndex => _firstUnreadIndex;

  bool _isEmojiPickerVisible = false;
  bool _isRecording = false;
  int _ellapsedSeconds = 0;
  int _ellapsedMinutes = 0;
  AudioMessageModel? _currentlyPlayingAudioModel;
  DurationValues? _duration;
  List<bool> _clearOption = [false, false];
  bool? _reportContact;
  bool? _blockContact;
  bool _multibleChoices = false;
  List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> _captionControllers = [];
  int _swiperIndex = 0;
  double _bufferedVideo = 0.0;
  bool _isPlaying = false;
  String _videoDuration = '';
  bool _progressShown = true;
  bool _slideChanging = false;
  MessageEntity? _editMessageModel;
  MessageModel? _replyMessageModel;
  int? _replyScrollIndex = -1;
  bool _reactVisible = false;
  List<bool> _forwardCheckBoxes = [];
  List<MessageModel> _selectedForwardMessages = [];
  bool _selectMessages = false;
  LocationMessageModel? _pickedLocation;
  String _selectedAllTab = S.current.about;
  Map<int, String> _selectedRole = {};

  void initialize(TickerProvider vsync) async {
    tabGroupController = TabController(vsync: vsync, length: groupInfoTabs.length);
    tabGroupController.addListener(() {
      _selectedAllTab = groupInfoTabs[tabGroupController.index];
      _emitLoadedState();
    });

    await AudioRecordService.initializeController();
    tabController = TabController(
      length: communityTabs.length,
      vsync: vsync,
    );

    _emitLoadedState();
  }

  void setChatModel(ChatModel chat) {
    _chatModel = chat;
    _emitLoadedState();
  }

  ///called when user exit the messages view
  void resetResources() {
    if (_firstUnreadIndex != null) {
      _firstUnreadIndex = null;
    }
    stopAudios();
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry!.remove();
      overlayEntry!.dispose();
    }
  }

  void setRole(int index, String role) {
    _selectedRole[index] = role;
    _emitLoadedState();
  }

  void getFirstUnreadIndex() {
    if (_chatModel == null) return;

    final firstUnread = _chatModel!.messages.indexWhere(
          (element) => element.isRead == false,
    );

    if (firstUnread == -1) {
      _firstUnreadIndex = null;
      _emitLoadedState();
      return;
    }

    _firstUnreadIndex = firstUnread;
    _emitLoadedState();
  }

  int getLastUnreadMessage() {
    if (_chatModel == null) return -1;
    return _chatModel!.messages.lastIndexWhere(
          (element) => element.isRead == false,
    );
  }

  void scrollToLatest(int index, {int? milliseconds, BuildContext? context}) {
    bool indexVisible = false;

    if (!indexVisible) {
      scrollController.scrollTo(
        index: index,
        duration: Duration(milliseconds: milliseconds ?? 400),
        curve: Curves.decelerate,
      );

      if (_firstUnreadIndex != null) {
        setAllMessagesRead();
        _firstUnreadIndex = null;
        _emitLoadedState();

        if (context != null && _chatModel != null) {
          context.read<CommunityCubit>().refreshCommunity();
        }
      }
    }
  }

  void setAllMessagesRead() {
    if (_chatModel == null || _firstUnreadIndex == null) return;

    for (int i = _firstUnreadIndex!; i < _chatModel!.messages.length; i++) {
      // §10 — isRead is final; reassign via copyWith.
      _chatModel!.messages[i] = _chatModel!.messages[i].copyWith(isRead: true);
    }
  }

  void selectDuration(DurationValues value) {
    _duration = value;
    _emitLoadedState();
  }

  void selectClearOption(bool value, {required int index}) {
    _clearOption[index] = value;
    _emitLoadedState();
  }

  void toggleReportContact(bool value) {
    _reportContact = value;
    _emitLoadedState();
  }

  void toggleBlockContact(bool value) {
    _blockContact = value;
    _emitLoadedState();
  }

  String getMediaTitle() {
    if (_chatModel == null) return '';

    if (_chatModel!.otherUser != null) {
      return _chatModel!.otherUser!.firstName;
    }
    if (_chatModel!.groupModel != null) {
      return _chatModel!.groupModel!.groupName;
    }
    return '';
  }

  void resetScheduleMessage() {
    messageController.clear();
    dateController.clear();
    timeController.clear();
  }

  Future<void> menuSelectAndNavigate(
      String value,
      String title, {
        required BuildContext context,
      }) async {
    if (value == S.of(context).viewContact) {
      if (ContextExtension(context).isTablett) {
        final communityCubit = context.read<CommunityCubit>();
        communityCubit.toggleShowAdditionalInfo(true);
        // Set specific view flags if needed
      } else {
        Navigator.pushNamed(context, Routes.singleChatProfile);
      }
    } else if (value == S.of(context).viewGroup) {
      GetDialogHelper.generalDialog(
        child: TabletGroupChatProfileView(),
        context: context,
      );
    } else if (value == S.of(context).mediaLinksAndDocs) {
      if (ContextExtension(context).isTablett) {
        final communityCubit = context.read<CommunityCubit>();
        communityCubit.toggleShowAdditionalInfo(true);
      } else {
        if (_chatModel != null) {
          Navigator.pushNamed(
            context,
            Routes.media,
            arguments: {
              'media': _chatModel!.mediaModel,
              'recieverName': title,
            },
          );
        }
      }
    } else if (value == S.of(context).scheduleAMessage) {
      // Was Mobile/TabletScheduleMessageDialog. Those were thin wrappers around
      // showDatePicker/showTimePicker whose Done button only called
      // resetScheduleMessage(), so the pickers now run inline and the result is
      // confirmed through CustomDialogManager.
      final pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: DateTime.now(),
      );
      if (pickedDate == null || !context.mounted) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: AppTheme.lightTheme,
          child: child!,
        ),
      );
      if (pickedTime == null || !context.mounted) return;

      dateController.text = DateTimeHelper.formatDate(pickedDate);
      timeController.text = pickedTime.format(context);

      await CustomDialogManager.showDialogFlow(
        context: context,
        confirmWidth: 411, // narrower confirm dialog (bug report #7)
        confirmLottie: AppAssets.media,
        confirmTitle: S.of(context).scheduleAMessage,
        confirmSubtitle: '${dateController.text} ${timeController.text}',
        confirmYesText: S.of(context).status_done,
        confirmNoText: S.of(context).Cancel,
        onNoPressed: resetScheduleMessage,
        onConfirm: () async {
          resetScheduleMessage();
          return true;
        },
        successLottie: AppAssets.media,
        successTitle: S.of(context).scheduleAMessage,
        successSubtitle: '${dateController.text} ${timeController.text}',
      );
    }
  }

  List<MessageModel> getStarredMessages() {
    if (_chatModel == null) return [];
    return _chatModel!.messages.where((element) => element.isStarred).toList();
  }

  void toggleStar(MessageModel message) {
    final wasStarred = message.isStarred;
    // §10 — isStarred is final; reassign the element in the list via copyWith.
    final starIndex =
        _chatModel?.messages.indexWhere((element) => element == message) ?? -1;
    if (starIndex != -1) {
      _chatModel!.messages[starIndex] =
          message.copyWith(isStarred: !wasStarred);
    }

    Fluttertoast.showToast(
      msg: wasStarred
          ? S.current.messageRemovedFromStarredMessages
          : S.current.messageAddedToStarredMessages,
      backgroundColor: AppColors.primary,
      textColor: AppTheme.contrastColor(),
    );

    _emitLoadedState();
  }

  void deleteMessage(MessageModel model) {
    if (_chatModel == null) return;

    // §10 — isDeleted is final; reassign the matching element via copyWith.
    final delIndex =
        _chatModel!.messages.indexWhere((element) => element == model);
    if (delIndex != -1) {
      _chatModel!.messages[delIndex] =
          _chatModel!.messages[delIndex].copyWith(isDeleted: true);
    }
    _emitLoadedState();
  }

  Future<void> addMessage({
    String? audio,
    String? caption,
    File? video,
    File? doc,
    File? image,
    LocationMessageModel? location,
    BuildContext? context,
  }) async {
    if (_chatModel == null) return;

    messageFocusNode.unfocus();

    if (audio != null) {
      var playerController = PlayerController();
      playerController.preparePlayer(
        volume: 1,
        shouldExtractWaveform: true,
        path: audio,
        noOfSamples: playerController
            .getNumOfSamples(AudioRecordService.audioWavesSpacing),
      );
    }

    var newMessage = MessageModel(
      sentUserID: '1',
      image: image,
      replyMessageModel: _replyMessageModel,
      sentDate: DateTime.now(),
      docModel: doc != null ? DocMessageModel(docPath: doc.path) : null,
      audioModel: audio != null
          ? AudioMessageModel(
        audioPath: audio,
        duration: newRecordDuration,
      )
          : null,
      videoModel: null,
      message: caption,
      locationModel: location,
      isMeLastMessage: true,
    );

    if (doc != null) {
      await docUploadListener(newMessage.docModel!);
    }

    newRecordDuration = Duration.zero;
    _chatModel!.messages.add(newMessage);
    _isEmojiPickerVisible = false;
    _replyMessageModel = null;
    _editMessageModel = null;

    _emitLoadedState();

    scrollToLatest(_chatModel!.messages.length - 1, context: context);

    if (context != null) {
      context.read<CommunityCubit>().refreshCommunity();
    }
  }

  void toggleEmojiPicker() {
    _isEmojiPickerVisible = !_isEmojiPickerVisible;
    _emitLoadedState();
  }

  Member? getSentUserByID(String id, MessageModel message) {
    if (_chatModel == null) return null;

    final loggedInUser = Member(
      id: id,
      lastName: 'Ahmed',
      firstName: 'You',
      phoneNumber: '+20 1234567890',
      avatarUrl: AppAssets.profile2,
    );

    if (_chatModel!.otherUser != null) {
      var otherID = _chatModel!.otherUser!.id;
      if (id == otherID) {
        return _chatModel!.otherUser!;
      } else {
        return loggedInUser;
      }
    }

    if (_chatModel!.groupModel != null) {
      var groupMemberID = _chatModel!.groupModel!.groupMembers
          .firstWhere((element) => element.id == message.sentUserID)
          .id;
      if (id == groupMemberID) {
        return _chatModel!.groupModel!.groupMembers
            .firstWhere((element) => element.id == message.sentUserID);
      } else {
        return loggedInUser;
      }
    }

    return null;
  }

  void updateGroupDescription(String groupId, String description, GroupModel group) {
    group.groupDescription = description;
    _emitLoadedState();
  }

  Future<void> startPlayingAudio(AudioMessageModel model) async {
    model.playerController.addListener(() {
      model.playerController.playerState == PlayerState.playing
          ? model.isCurrentPlaying = true
          : model.isCurrentPlaying = false;
      _emitLoadedState();
    });

    model.playerController.onCompletion.listen((event) {
      model.isCurrentPlaying = false;
      _emitLoadedState();
    });

    if (_currentlyPlayingAudioModel != null &&
        !identical(_currentlyPlayingAudioModel, model) &&
        _currentlyPlayingAudioModel!.isCurrentPlaying) {
      await _currentlyPlayingAudioModel!.playerController.pausePlayer();
    }

    final isPlaying = model.playerController.playerState == PlayerState.playing;
    final isInitialized =
        model.playerController.playerState == PlayerState.initialized;
    final isPaused = model.playerController.playerState == PlayerState.paused;

    _currentlyPlayingAudioModel = model;

    if (isInitialized || isPaused) {
      model.isCurrentPlaying = true;
    } else if (isPlaying) {
      _currentlyPlayingAudioModel = model;
      await model.playerController.pausePlayer();
    }

    _emitLoadedState();
  }

  Future<void> startRecording() async {
    final res = await Permission.microphone.status;
    if (res == PermissionStatus.granted) {
      if (_currentlyPlayingAudioModel != null) {
        await _currentlyPlayingAudioModel!.playerController.pausePlayer();
        _currentlyPlayingAudioModel!.isCurrentPlaying = false;
        _emitLoadedState();
      }

      stopwatch.start();
      Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          _ellapsedSeconds = stopwatch.elapsed.inSeconds % 60;
          _ellapsedMinutes = stopwatch.elapsed.inMinutes;
          _emitLoadedState();
        },
      );

      final result = await AudioRecordService.startRecording();
      result.fold(
            (l) {
          Fluttertoast.showToast(
              msg: S.current.errorOccuredPleaseTryAgain,
              backgroundColor: AppColors.primary,
              textColor: AppTheme.contrastColor());
        },
            (r) {
          _isRecording = true;
          _emitLoadedState();
        },
      );
    } else {
      if (res == PermissionStatus.denied) {
        Fluttertoast.showToast(
          msg: S.current.pleaseEnableMicrophoneService,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        return;
      }

      await Permission.microphone.request();
    }
  }

  Future<void> stopRecording({bool? cancel, BuildContext? context}) async {
    stopwatch.stop();

    newRecordDuration = stopwatch.elapsed;

    stopwatch.reset();
    _ellapsedSeconds = 0;
    _ellapsedMinutes = 0;

    final result = await AudioRecordService.stopAndSave(cancel);

    result.fold(
          (l) {
        Fluttertoast.showToast(
            msg: S.current.errorOccuredPleaseTryAgain,
            backgroundColor: AppColors.primary,
            textColor: AppTheme.contrastColor());
      },
          (r) {
        _isRecording = false;
        _emitLoadedState();

        if (r != null) {
          addMessage(audio: r, context: context);
        }
      },
    );
  }

  void stopAudios() {
    if (_currentlyPlayingAudioModel != null) {
      _currentlyPlayingAudioModel!.playerController.pausePlayer();
      _currentlyPlayingAudioModel!.isCurrentPlaying = false;
      _currentlyPlayingAudioModel!.playerController.stopPlayer();
      _emitLoadedState();
    }
  }

  Future<void> uploadAudio(AudioMessageModel model) async {
    File(model.audioPath);
    await rootBundle.load(model.audioPath);
  }

  Future<void> updateAudioSpeed({required AudioMessageModel audio}) async {
    if (speedIndex == speeds.length) {
      speedIndex = 0;
    } else {
      speedIndex++;
    }

    if (speeds[speedIndex].rate.toInt() == 2) {
      audio.speedUpDuration = audio.duration ~/ 2;
    } else {
      audio.speedUpDuration =
          audio.duration ~/ (speeds[speedIndex].rate.toInt() + 1);
    }

    audio.rate = speeds[speedIndex].name;
    await audio.playerController.setRate(speeds[speedIndex].rate);

    _emitLoadedState();
  }

  Future<void> pickFile({
    bool? audio,
    bool? doc,
    required BuildContext context,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: audio ?? false
          ? FileType.custom
          : doc ?? false
          ? FileType.custom
          : FileType.media,
      allowMultiple: true,
      allowedExtensions: doc ?? false
          ? ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx']
          : audio ?? false
          ? ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'wma', 'aiff', 'alac', 'mpeg']
          : null,
    );

    if (context.mounted) Navigator.of(context).pop();

    if (result != null && context.mounted) {
      if ((audio ?? false) || (doc ?? false)) {
        await CustomDialogManager.showDialogFlow(
          context: context,
          confirmWidth: 411, // narrower confirm dialog (bug report #7)
          confirmLottie: AppAssets.media,
          confirmTitle: S.of(context).totalPickedFiles,
          confirmSubtitle: result.files.length.toString(),
          confirmYesText: S.of(context).send,
          confirmNoText: S.of(context).Cancel,
          onConfirm: () async {
            for (var file in result.files) {
              if (audio ?? false) {
                await addMessage(audio: file.path!, context: context);
              } else {
                await addMessage(doc: File(file.path!), context: context);
              }
            }
            return true;
          },
          successLottie: AppAssets.media,
          successTitle: S.of(context).send,
          successSubtitle: S.of(context).totalPickedFiles,
        );
      } else {
        generateFormFields(result.files.length);
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            Routes.confirmCaptionScreen,
            arguments: {
              'files': result.files,
              'chatModel': _chatModel,
            },
          );
        }
      }
    }
  }

  Future<void> sendImageCamera(BuildContext context, ImagePickerCubit imagePickerController) async {
    await imagePickerController.takeImage();
    if (imagePickerController.state.pickedFile != null) {
      final files = [
        PlatformFile(
          name: 'takenImage',
          path: imagePickerController.state.pickedFile!.path,
          size: 0,
        ),
      ];
      generateFormFields(files.length);

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.confirmCaptionScreen,
          arguments: {
            'files': files,
            'chatModel': _chatModel,
          },
        );
      }

      imagePickerController.clearPickedImage();
    }
  }

  Future<void> pickContact(BuildContext context) async {
    final granted = await Permission.contacts.request();
    if (granted.isGranted) {
      Contact? contact = await FlutterContacts.native.showPicker();
      if (contact != null && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<List<String>> getAddress(latLng.LatLng point) async {
    try {
      List<Placemark> placeMark = await Geocoding().placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      String country = placeMark[0].country!;
      String state = placeMark[0].administrativeArea!;
      String city = state.split(" ")[0];
      String street = placeMark[0].street!;

      return [street, "$city, $country"];
    } catch (e) {
      return Future.value([e.toString()]);
    }
  }

  Future<void> setCurrentLocation(
      bool isSelecting, {
        LocationMessageModel? location,
        BuildContext? context,
      }) async {
    if (isSelecting) {
      bool isLocationServiceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        Fluttertoast.showToast(
          msg: S.current.pleaseEnableLocationServices,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        return;
      }

      final permission = await Permission.location.request();

      if (permission.isGranted) {
        Position? currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );

        final address = await getAddress(
          latLng.LatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
        );

        _pickedLocation = LocationMessageModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          address: '${address[0]}-${address[1]}',
        );
      } else {
        _pickedLocation = const LocationMessageModel(
          latitude: 30.033333,
          longitude: 31.233334,
          address: 'Tahrir Square-Cairo, Egypt',
        );
      }
    } else {
      _pickedLocation = location;
    }

    if (isSelecting && context != null && context.mounted) {
      Navigator.pushNamed(
        context,
        Routes.maps,
        arguments: {'isSelecting': true},
      );
    }

    _emitLoadedState();
  }

  Future<void> setPickedLocation(dynamic point, Uint8List? bytes) async {
    final address = await getAddress(point);

    _pickedLocation = LocationMessageModel(
      latitude: point.latitude,
      longitude: point.longitude,
      address: '${address[0]}-${address[1]}',
      locationImagePngBytes: bytes,
    );
    _emitLoadedState();
  }

  void updateMultibleChoices(bool val) {
    _multibleChoices = val;
    _emitLoadedState();
  }

  void addPollOption() {
    _pollOptions.add(TextEditingController());
    _emitLoadedState();
  }

  bool validatePoll() {
    if (questionController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: S.current.pleaseAddAQuestion,
        backgroundColor: AppColors.primary,
        textColor: AppTheme.contrastColor(),
      );
      return false;
    }

    for (int i = 0; i <= 1; i++) {
      if (_pollOptions[i].text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: S.current.fillAtLeastTwoOptions,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        return false;
      }
    }

    Set<String> uniqueStrings = {};
    for (int i = 0; i < _pollOptions.length; i++) {
      if (_pollOptions[i].text.isNotEmpty) {
        if (!uniqueStrings.add(_pollOptions[i].text.trim())) {
          Fluttertoast.showToast(
              msg: S.current.optionsMustBeUnique,
              backgroundColor: AppColors.primary,
              textColor: AppTheme.contrastColor());
          return false;
        }
      }
    }
    return true;
  }

  void confirmPoll(BuildContext context) {
    if (_chatModel == null) return;

    if (validatePoll()) {
      List<bool> pollValues = [];
      List<String> options = [];
      List<int> votes = [];

      for (int i = 0; i < _pollOptions.length; i++) {
        pollValues.add(false);
        votes.add(0);
        if (_pollOptions[i].text.trim().isNotEmpty) {
          options.add(_pollOptions[i].text);
        }
      }

      _pollOptions = [];
      _chatModel!.messages.add(
        MessageModel(
          sentUserID: '1',
          isMeLastMessage: true,
          sentDate: DateTime.now(),
          pollModel: PollMessageModel(
            question: questionController.text,
            pollValues: pollValues,
            options: options,
            votes: votes,
          )..isMultible = _multibleChoices,
        ),
      );

      if (context.mounted) {
        if (ContextExtension(context).isTablett || ContextExtension(context).isLandscape) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).popUntil(
                (route) => route.settings.name == Routes.message,
          );
        }
      }

      resetPollData();
      _emitLoadedState();

      scrollToLatest(_chatModel!.messages.length - 1, context: context);
    }
  }

  void updatePollOption({
    bool? option,
    required int index,
    required PollMessageModel model,
  }) {
    if (model.isMultible) {
      model.pollValues[index] = option ?? false;
      if (option ?? false) {
        model.votes[index] += 1;
        model.voters[model.options[index]]!.add(
          Member(
              id: '1',
              lastName: 'Ahmed',
              firstName: 'Aya Ahmed',
              phoneNumber: '',
              avatarUrl: AppAssets.profile),
        );
      } else {
        if (model.votes[index] > 0) {
          model.votes[index] -= 1;
          model.voters[model.options[index]]!.removeLast();
        }
      }
    } else {
      if (index == model.selectedOptionIndex) {
        if (model.votes[index] > 0) {
          model.votes[index] -= 1;
          model.voters[model.options[index]]!.removeLast();
          model.selectedOptionIndex = null;
        }
      } else {
        model.votes[index] += 1;
        model.voters[model.options[index]]!.add(
          Member(
            id: '1',
            lastName: 'Ahmed',
            firstName: 'Aya Ahmed',
            phoneNumber: '',
            avatarUrl: AppAssets.profile2,
          ),
        );

        if (model.selectedOptionIndex != null &&
            model.votes[model.selectedOptionIndex!] > 0) {
          model.votes[model.selectedOptionIndex!] -= 1;
          model.voters[model.options[model.selectedOptionIndex!]]!.removeLast();
        }

        model.selectedOptionIndex = index;
      }
    }
    _emitLoadedState();
  }

  void resetPollData() {
    questionController.clear();
    _pollOptions = [
      TextEditingController(),
      TextEditingController(),
    ];
    _multibleChoices = false;
  }

  Future<void> docUploadListener(DocMessageModel model) async {
    final doc = await PdfDocument.openFile(model.docPath);

    model.totalPages = doc.pagesCount;
    final page = await doc.getPage(1);
    final pdfImage = await page.render(
      width: page.width,
      height: page.height,
    );
    page.close();
  }

  void generateFormFields(int count) {
    _captionControllers = List.generate(
      count,
          (index) => TextEditingController(),
    );
    _emitLoadedState();
  }

  Future<void> videoListener(VideoMessageModel model, [String? id]) async {
    model.playerController.addListener(() async {
      _isPlaying = model.isCurrentPlaying;
      if (model.isCurrentPlaying) {
        _bufferedVideo =
            model.playerController.value.position.inMilliseconds.toDouble();
        _videoDuration =
            model.formatDuration(model.playerController.value.position);
        if (_progressShown) {
          if (!_slideChanging) {
            await Future.delayed(
              const Duration(seconds: 2),
                  () {
                _progressShown = false;
                _emitLoadedState();
              },
            );
          }
        }
      }
      _emitLoadedState();
    });
  }

  void showProgress() {
    _progressShown = true;
    _emitLoadedState();
  }

  void playVideo(VideoMessageModel model) {
    if (model.playerController.value.isPlaying) {
      model.playerController.pause();
    } else {
      model.playerController.play();
    }
  }

  void shareMessage(MessageModel messageModel) {
    if (messageModel.videoModel != null) {
      // ShareHelper.shareFile
    } else if (messageModel.image != null) {
      ShareHelper.shareFile(
        messageModel.image!,
        text: messageModel.message,
      );
    } else if (messageModel.audioModel != null) {
      ShareHelper.shareFile(
        File(messageModel.audioModel!.audioPath),
      );
    } else if (messageModel.docModel != null) {
      // ShareHelper.shareFile
    } else if (messageModel.locationModel != null) {
      ShareHelper.shareText(
        'https://www.openstreetmap.org/?mlat=${messageModel.locationModel!.latitude}&mlon=${messageModel.locationModel!.longitude}#map=15/${messageModel.locationModel!.latitude}/${messageModel.locationModel!.longitude}',
      );
    } else {
      ShareHelper.shareText(messageModel.message!);
    }
  }

  void toggleEditMessage(MessageEntity model) {
    if (_replyMessageModel != null) {
      _replyMessageModel = null;
    }
    _editMessageModel = model;
    messageFocusNode.requestFocus();
    _emitLoadedState();
  }

  void cancelEdit() {
    _editMessageModel = null;
    _emitLoadedState();
  }

  void submitEditMessage() {
    // Implementation needed
    _emitLoadedState();
  }

  void toggleReplyMessage({required MessageModel model, required int index}) {
    if (_editMessageModel != null) {
      _editMessageModel = null;
    }
    // §10 — index is final; pass it through copyWith instead of a cascade.
    _replyMessageModel = model.copyWith(
      docModel: model.docModel,
      locationModel: model.locationModel,
      audioModel: model.audioModel,
      image: model.image,
      message: model.message,
      index: index,
    );
    messageFocusNode.requestFocus();
    _emitLoadedState();
  }

  Future<void> scrollAndHighlight(int index) async {
    await scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.decelerate,
    );
    _replyScrollIndex = index;
    _emitLoadedState();

    Future.delayed(
      const Duration(seconds: 1),
          () {
        _replyScrollIndex = index;
        _emitLoadedState();
      },
    );
  }

  void cancelReply() {
    _replyMessageModel = null;
    _emitLoadedState();
  }

  void showReactions() {
    _reactVisible = true;
    _emitLoadedState();
  }

  void showMessageOverlay({
    required BuildContext context,
    required MessageEntity messageModel,
    required int index,
    required Widget content,
    required bool isGroup,
  }) {
    final RenderBox bubbleBox = context.findRenderObject() as RenderBox;
    final Offset position = bubbleBox.localToGlobal(Offset.zero);
    if (messageModel.isDeleted == null) {
      overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              overlayEntry!.remove();
              overlayEntry!.dispose();
            },
            child: Container()),
      );
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  void generateForwardCheckboxes(int index) {
    if (_chatModel == null) return;

    _forwardCheckBoxes = List.generate(
      _chatModel!.messages.length,
          (index) => false,
    );
    _forwardCheckBoxes[index] = true;
    _selectedForwardMessages.add(_chatModel!.messages[index]);
    _emitLoadedState();
  }

  void toggleSelectMessages(bool val) {
    _selectMessages = val;
    if (!val) {
      _forwardCheckBoxes = [];
      _selectedForwardMessages = [];
    }
    _emitLoadedState();
  }

  void selectForwardMessage({required bool val, required int messageIndex}) {
    if (_chatModel == null) return;

    _forwardCheckBoxes[messageIndex] = val;
    if (val) {
      _selectedForwardMessages.add(_chatModel!.messages[messageIndex]);
    } else {
      _selectedForwardMessages.removeWhere(
              (e) => e.hashCode == _chatModel!.messages[messageIndex].hashCode);
    }
    _emitLoadedState();
  }

  /// Set — not append — the reaction on a message.
  ///
  /// FIXED 2/9/2026. This was `reacts: [...reactMsg.reacts, react]`, a plain
  /// append, so reacting a second time stacked a second emoji on the bubble
  /// and a third tap a third. One person holds ONE reaction, so:
  ///
  ///   - tapping the reaction that is already there removes it (toggle off);
  ///   - tapping a different one replaces whatever was there.
  ///
  /// Replacing the whole list is safe here because [MessageEntity.reacts] is
  /// local, single-user state: nothing in data/ reads or writes it (no model
  /// maps a `reacts` field, and it defaults to `const []`), so the list only
  /// ever holds what this device added. If reactions are later persisted per
  /// member, this must key off the current user's id instead of clearing the
  /// list, or one person's tap will wipe everyone else's.
  void reactToMessage({required Reacts react, required int messageIndex}) {
    if (_chatModel == null) return;
    if (messageIndex < 0 || messageIndex >= _chatModel!.messages.length) return;

    // §10 — reacts field is final; rebuild the list and reassign via copyWith.
    final reactMsg = _chatModel!.messages[messageIndex];
    final bool isSameReact = reactMsg.reacts.contains(react);

    _chatModel!.messages[messageIndex] = reactMsg.copyWith(
      reacts: isSameReact ? const <Reacts>[] : <Reacts>[react],
    );
    _emitLoadedState();
  }

  void _emitLoadedState() {
    if (state is MessageLoaded) {
      emit((state as MessageLoaded).copyWith(
        chatModel: _chatModel,
        firstUnreadIndex: _firstUnreadIndex,
        isEmojiPickerVisible: _isEmojiPickerVisible,
        isRecording: _isRecording,
        ellapsedSeconds: _ellapsedSeconds,
        ellapsedMinutes: _ellapsedMinutes,
        currentlyPlayingAudioModel: _currentlyPlayingAudioModel,
        duration: _duration,
        clearOption: _clearOption,
        reportContact: _reportContact,
        blockContact: _blockContact,
        multibleChoices: _multibleChoices,
        pollOptions: _pollOptions,
        captionControllers: _captionControllers,
        swiperIndex: _swiperIndex,
        bufferedVideo: _bufferedVideo,
        isPlaying: _isPlaying,
        videoDuration: _videoDuration,
        progressShown: _progressShown,
        slideChanging: _slideChanging,
        editMessageModel: _editMessageModel,
        replyMessageModel: _replyMessageModel,
        replyScrollIndex: _replyScrollIndex,
        reactVisible: _reactVisible,
        forwardCheckBoxes: _forwardCheckBoxes,
        selectedForwardMessages: _selectedForwardMessages,
        selectMessages: _selectMessages,
        pickedLocation: _pickedLocation,
        selectedAllTab: _selectedAllTab,
        selectedRole: _selectedRole,
      ));
    } else {
      emit(MessageLoaded(
        chatModel: _chatModel,
        firstUnreadIndex: _firstUnreadIndex,
        isEmojiPickerVisible: _isEmojiPickerVisible,
        isRecording: _isRecording,
        ellapsedSeconds: _ellapsedSeconds,
        ellapsedMinutes: _ellapsedMinutes,
        currentlyPlayingAudioModel: _currentlyPlayingAudioModel,
        duration: _duration,
        clearOption: _clearOption,
        reportContact: _reportContact,
        blockContact: _blockContact,
        multibleChoices: _multibleChoices,
        pollOptions: _pollOptions,
        captionControllers: _captionControllers,
        swiperIndex: _swiperIndex,
        bufferedVideo: _bufferedVideo,
        isPlaying: _isPlaying,
        videoDuration: _videoDuration,
        progressShown: _progressShown,
        slideChanging: _slideChanging,
        editMessageModel: _editMessageModel,
        replyMessageModel: _replyMessageModel,
        replyScrollIndex: _replyScrollIndex,
        reactVisible: _reactVisible,
        forwardCheckBoxes: _forwardCheckBoxes,
        selectedForwardMessages: _selectedForwardMessages,
        selectMessages: _selectMessages,
        pickedLocation: _pickedLocation,
        selectedAllTab: _selectedAllTab,
        selectedRole: _selectedRole,
      ));
    }
  }

  @override
  Future<void> close() {
    messageFocusNode.dispose();
    searchMemberController.dispose();
    messageController.dispose();
    dateController.dispose();
    timeController.dispose();
    groupDescriptionController.dispose();
    groupNameController.dispose();
    questionController.dispose();
    msgMenuScrollController.dispose();
    tabController.dispose();
    tabGroupController.dispose();

    for (var controller in _pollOptions) {
      controller.dispose();
    }
    for (var controller in _captionControllers) {
      controller.dispose();
    }

    return super.close();
  }
}