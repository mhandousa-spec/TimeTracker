// Date: 28/8/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing a cubit for the Media in the Media screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../data/models/media/media_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// State classes
abstract class MediaState {}

class MediaInitial extends MediaState {}

class MediaLoaded extends MediaState {
  final String selectedMediaTab;

  MediaLoaded({
    required this.selectedMediaTab,
  });

  MediaLoaded copyWith({
    String? selectedMediaTab,
  }) {
    return MediaLoaded(
      selectedMediaTab: selectedMediaTab ?? this.selectedMediaTab,
    );
  }
}

// Cubit
class MediaCubit extends Cubit<MediaState> {
  MediaCubit() : super(MediaInitial());

  final List<String> tabs = ['Media', 'Links', 'Documents'];

  late final TabController tabController;

  String _selectedMediaTab = S.current.media;
  String get selectedMediaTab => _selectedMediaTab;

  void initialize(TickerProvider vsync) {
    tabController = TabController(
      length: tabs.length,
      vsync: vsync,
    );

    tabController.addListener(() {
      updateMediaTabs(tabController.index);
    });

    _emitLoadedState();
  }

  void updateMediaTabs(int index) {
    _selectedMediaTab = tabs[index];
    _emitLoadedState();
  }

  /// Get all available sorted dates based on current tab
  Set<String>? filterDates({required MediaModel model, required String tab}) {
    if (tab == S.current.media) {
      return model.imageSortedDates;
    } else if (tab == S.current.documents) {
      return model.pdfsSortedDates;
    }
    return model.linksSortedDates;
  }

  /// Filter tabbar view based on current tab and current sorted label date
  List<dynamic>? filterTabs({
    required MediaModel model,
    required String tab,
    required String sortedDateLabel,
  }) {
    if (tab == S.current.media) {
      return model.images
          ?.where(
            (element) => element.sortedCategory == sortedDateLabel,
      )
          .toList();
    } else if (tab == S.current.documents) {
      return model.pdfs
          ?.where(
            (element) => element.sortedCategory == sortedDateLabel,
      )
          .toList();
    }
    return model.links
        ?.where(
          (element) => element.sortedCategory == sortedDateLabel,
    )
        .toList();
  }

  void _emitLoadedState() {
    if (state is MediaLoaded) {
      emit((state as MediaLoaded).copyWith(
        selectedMediaTab: _selectedMediaTab,
      ));
    } else {
      emit(MediaLoaded(
        selectedMediaTab: _selectedMediaTab,
      ));
    }
  }

  @override
  Future<void> close() {
    tabController.dispose();
    return super.close();
  }
}