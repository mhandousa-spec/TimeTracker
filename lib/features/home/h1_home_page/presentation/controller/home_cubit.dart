/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_cubit.dart
/// Purpose: Manages the state of the home screen, including components and quotes
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 25/1/2026 - Fixed controller initialization for resize handling
/// Updated: 11/8/2026 - Repository injected, side-effects moved out of the
///          constructor into [init], prints removed, locale no longer read
///          from GetX, save failures now surface through [HomeError].

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';

import 'package:knowticed_plus/core/constants/quotes_list.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/header_icon_item.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_page_layout_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/repository/home_repository.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/app_bar_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

enum PreviewMode { desktop, tablet, mobile }

class AppHomeCubit extends Cubit<HomeState> {
  /// The repository is injected so it can be faked in tests. Callers that do
  /// not care keep using `AppHomeCubit()`.
  AppHomeCubit({HomeBaseRepository? homeRepository})
      : homeRepository = homeRepository ?? HomeRepository(),
        super(HomeInitial());

  final HomeBaseRepository homeRepository;

  bool _initialised = false;

  /// Function Name: [init]
  ///
  /// Purpose: Perform the start-up work that used to run in the constructor.
  ///          Call this once from the widget that provides the cubit; repeated
  ///          calls are ignored so rebuilds do not refetch.
  ///
  /// Returns: [Future<void>] completing when the first layout fetch is done.
  Future<void> init({Locale? locale}) async {
    if (_initialised) return;
    _initialised = true;
    getHomeQuote(locale: locale);
    initModules();
    await getHomeLayout();
  }

  /// Function Name: [initFor]
  ///
  /// Purpose: Convenience entry point for widgets. Runs [init] on the first
  ///          call and, on later calls, re-resolves the quote so it follows a
  ///          language switch. Safe to call from `didChangeDependencies`.
  ///
  /// Parameters:
  /// - [context]: Build context used to read the active locale.
  void initFor(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    if (_initialised) {
      getHomeQuote(locale: locale);
    } else {
      init(locale: locale);
    }
  }

  List<Modules> modules = [];
  String quote = "";
  String author = "";
  List<HomeComponentModel> _editingComponent = [];
  List<HomeComponentModel> _readyToAddComponent = [];
  List<HomeComponentModel> get readyToAddComponent => _readyToAddComponent;
  List<HomeComponentModel> _activeComponents = [];

  // Header icons management
  List<HeaderIconItem> selectedHeaderIcons = [];

  /// The icons as last LOADED or SAVED. `_activeComponents` already plays this
  /// role for the grid; the icon strip had no equivalent, so there was nothing
  /// to diff a picked icon against.
  List<String> _savedHeaderIconPaths = <String>[];

  /// True when the draft differs from what is stored. The Save button is gated
  /// on this (24/8/2026) — it used to be tappable on a page nobody had touched,
  /// which wrote the layout back unchanged and reported success.
  ///
  /// Components are compared by a canonical signature rather than by identity:
  /// `editComponent` / `removeComponent` do `removeWhere` + `add`, so the same
  /// layout can come back in a different list ORDER with fresh instances. The
  /// signature is sorted, so only a real difference in what sits where counts.
  bool get hasChanges {
    final List<String> icons =
        selectedHeaderIcons.map((HeaderIconItem i) => i.svgPath).toList();
    if (icons.length != _savedHeaderIconPaths.length) return true;
    for (int i = 0; i < icons.length; i++) {
      if (icons[i] != _savedHeaderIconPaths[i]) return true;
    }

    final List<String> edited = _componentSignature(_editingComponent);
    final List<String> active = _componentSignature(_activeComponents);
    if (edited.length != active.length) return true;
    for (int i = 0; i < edited.length; i++) {
      if (edited[i] != active[i]) return true;
    }

    return false;
  }

  List<String> _componentSignature(List<HomeComponentModel> components) =>
      components
          .map((HomeComponentModel c) =>
              '${c.rowNumber}:${c.columnNumber}:${c.component.databaseName}')
          .toList()
        ..sort();

  /// Function Name: [addHeaderIcon]
  ///
  /// Purpose: Add a new icon to the header (max 3 icons)
  ///
  /// Parameters:
  /// - [icon]: The HeaderIconItem to be added
  void addHeaderIcon(HeaderIconItem icon) {
    if (selectedHeaderIcons.length < 3) {
      selectedHeaderIcons.add(icon);
      emit(HomeIconsUpdated(List.from(selectedHeaderIcons)));
    }
  }
  PreviewMode currentPreviewMode = PreviewMode.tablet; // Default to tablet

  /// Function Name: [setPreviewMode]
  ///
  /// Purpose: Change the preview mode for home layout preview
  ///
  /// Parameters:
  /// - [mode]: The PreviewMode to switch to
  void setPreviewMode(PreviewMode mode) {
    currentPreviewMode = mode;
    emit(HomePreviewModeChanged(mode));
  }

  /// Function Name: [removeHeaderIcon]
  ///
  /// Purpose: Remove an icon from the header by index
  ///
  /// Parameters:
  /// - [index]: The index of the icon to be removed
  void removeHeaderIcon(int index) {
    if (index >= 0 && index < selectedHeaderIcons.length) {
      selectedHeaderIcons.removeAt(index);
      emit(HomeIconsUpdated(List.from(selectedHeaderIcons)));
    }
  }

  /// Function Name: [getActiveRowComponents]
  ///
  /// Purpose: Get the list of active components in a specific row
  ///
  /// Parameters:
  /// - [rowIndex]: The index of the row to get components for (based 0)
  ///
  /// Returns: [List<HomeComponentModel>]: A list of active components in the specified row
  List<HomeComponentModel> getActiveRowComponents(int rowIndex) {
    List<HomeComponentModel> components = _activeComponents
        .where((component) => component.rowNumber == rowIndex + 1)
        .toList();
    components.sort((a, b) => a.columnNumber.compareTo(b.columnNumber));
    return components;
  }

  /// Function Name: [getEditRowComponents]
  ///
  /// Purpose: Get the list of components being edited in a specific row
  ///
  /// Parameters:
  /// - [rowIndex]: The index of the row to get components for (based 0)
  List<HomeComponentModel> getEditRowComponents(int rowIndex) {
    List<HomeComponentModel> components = _editingComponent
        .where((component) => component.rowNumber == rowIndex + 1)
        .toList();
    components.sort((a, b) => a.columnNumber.compareTo(b.columnNumber));
    return components;
  }

  /// Function Name: [selectComponentToEdit]
  ///
  /// Purpose: Select a component to edit based on its row and column index based 1
  ///
  /// Parameters:
  /// - [rowIndex]: The row index of the component
  /// - [columnIndex]: The column index of the component
  selectComponentToEdit({required int rowIndex, required int columnIndex}) {
    List<HomeComponents> components = HomeComponents.values;
    _readyToAddComponent = [];
    for (var component in components) {
      HomeComponentModel model =
      component.getModel(rowNumber: rowIndex, columnNumber: columnIndex);
      if (component.widget(model) != null) _readyToAddComponent.add(model);
    }
  }

  /// Function Name: [editComponent]
  ///
  /// Purpose: Edit a component in the editing list
  ///
  /// Parameters:
  /// - [HomeComponentModel][component]: The component to be edited
  editComponent(HomeComponentModel component) {
    _editingComponent.removeWhere((c) =>
    c.rowNumber == component.rowNumber &&
        c.columnNumber == component.columnNumber);
    _editingComponent.add(component);

    emit(HomeEditingComponent());
  }

  /// Function Name: [getHomeQuote]
  ///
  /// Purpose: Resolve the quote of the day and split it into quote + author.
  ///
  /// Parameters:
  /// - [locale]: Active app locale. Pass `Localizations.localeOf(context)` from
  ///   the widget layer; when omitted the quote is left uncapitalised, which is
  ///   the correct behaviour for Arabic.
  void getHomeQuote({Locale? locale}) {
    final bool isEnglish = locale?.languageCode == 'en';
    final String quoteAndAuthor = isEnglish
        ? FormatHelper.capitalize(getQuoteForToday())
        : getQuoteForToday();
    final List<String> splitQuote = quoteAndAuthor.split(' - ');
    quote = splitQuote[0];
    author = splitQuote.length > 1 ? splitQuote[1] : "Unknown";
  }

  /// Function Name: [initModules]
  ///
  /// Purpose: Initialize modules from available controllers
  /// Fixed: Properly handles missing controllers during resize/orientation changes
  void initModules() {
    try {
      if (Get.isRegistered<AppDrawerCubit>()) {
        modules = Get.find<AppDrawerCubit>().allowedDrawerModules;
      } else if (Get.isRegistered<NavBarCubit>()) {
        modules = Get.find<NavBarCubit>().navBarModules;
      } else {
        modules = <Modules>[];
      }
    } catch (_) {
      // Neither source is registered yet — happens during resize/orientation
      // rebuilds before the drawer or nav bar has been created.
      modules = <Modules>[];
    }
  }

  /// Function Name: [getEditedComponent]
  ///
  /// Purpose: Get the component being edited based on its row and column index
  ///
  /// Parameters:
  /// - [columnIndex]: The column index of the component
  /// - [rowIndex]: The row index of the component
  HomeComponentModel? getEditedComponent(
      {required int columnIndex, required int rowIndex}) {
    HomeComponentModel? component;
    for (var model in _editingComponent) {
      if (model.columnNumber == columnIndex && model.rowNumber == rowIndex) {
        component = model;
        break;
      }
    }
    return component;
  }

  /// Function Name: [removeComponent]
  ///
  /// Purpose: Remove a component from the editing list
  ///
  /// Parameters:
  /// - [component]: The component to be removed
  removeComponent(HomeComponentModel component) {
    _editingComponent.removeWhere((c) =>
    c.rowNumber == component.rowNumber &&
        c.columnNumber == component.columnNumber);
    emit(HomeEditingComponent());
  }

  /// Function Name: [updateHomeComponents]
  ///
  /// Purpose: Save the edited components and header icons to Firebase.
  ///
  /// On failure this emits [HomeError]. `edit_home_page.dart` listens for that
  /// state with a `BlocListener` and shows a snackbar — without a listener the
  /// user would believe a failed reorder had saved.
  ///
  /// Returns: [Future<bool>] `true` when the layout was persisted.
  Future<bool> updateHomeComponents() async {
    // Convert HeaderIconItem to svg paths for storage.
    final List<String> headerIconPaths =
        selectedHeaderIcons.map((HeaderIconItem icon) => icon.svgPath).toList();

    final String? userEmail =
        Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (userEmail == null || userEmail.isEmpty) {
      emit(HomeError('Your account is still loading. Please try again.'));
      return false;
    }

    final Either<Failure, dynamic> result =
        await homeRepository.updateHomeComponents(
      components: _editingComponent,
      appBarOptions: const <AppBarOptions>[],
      headerIcons: headerIconPaths,
      currentUserEmail: userEmail,
    );

    return result.fold<bool>(
      (Failure failure) {
        emit(HomeError(
          failure is FirebaseFailure
              ? 'Could not save your home layout. Please try again.'
              : 'Something went wrong while saving your home layout.',
        ));
        return false;
      },
      (_) {
        // Update active components immediately, then refresh from the server.
        _activeComponents = List<HomeComponentModel>.from(_editingComponent);
        _savedHeaderIconPaths = headerIconPaths;
        emit(HomeLoaded());
        getHomeLayout();
        return true;
      },
    );
  }

  /// Function Name: [getHomeLayout]
  ///
  ///  Purpose: Fetches the home layout from the repository and updates the state accordingly.
  Future<void> getHomeLayout() async {
    emit(HomeLoading());

    // ✅ FIX: employeeEntity can be null while login init is still running.
    // The old `employeeEntity!.email!` crashed with "Null check operator
    // used on a null value" during the first build and corrupted the
    // widget tree (duplicate GlobalKey cascade).
    final String? userEmail =
        Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (userEmail == null || userEmail.isEmpty) {
      // Login init has not finished yet; the page will refetch once it has.
      emit(HomeLoaded());
      return;
    }

    final Either<Failure, HomePageLayoutModel> result =
        await homeRepository.getHomeLayout(currentUserEmail: userEmail);

    result.fold(
      (Failure _) {
        // A missing layout document is the normal first-run case, so this is
        // not surfaced as an error — the user simply gets the default layout.
      },
      (HomePageLayoutModel layoutModel) {
        _activeComponents =
            List<HomeComponentModel>.from(layoutModel.activeComponents);
        _editingComponent = List<HomeComponentModel>.from(_activeComponents);

        selectedHeaderIcons = layoutModel.headerIcons
            .map<HeaderIconItem?>(HeaderIconItem.fromSvgPath)
            .whereType<HeaderIconItem>()
            .toList();

        // Taken from the mapped list, not from `layoutModel.headerIcons`: a
        // stored path this build no longer knows is dropped by the whereType
        // above, and the baseline has to match what the user can actually see
        // or the page would open already "changed".
        _savedHeaderIconPaths = selectedHeaderIcons
            .map((HeaderIconItem i) => i.svgPath)
            .toList();
      },
    );
    emit(HomeLoaded());
  }
}