import 'dart:async'; // Timer — debounces the live-preview re-emit.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // ✅ ADD THIS
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/preview_screen.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:provider/provider.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/helper/form_builder/form_navigator_service.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/open_access_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/restricted_access_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/department.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/row_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit_base.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

class CreateFormDataCubit extends CreateFormDataCubitBase {
  CreateFormDataCubit({
    required super.mainCoreEmployeeController,
    required super.addDepartmentController,
    required super.createFormHeadCubit,
  });

  // ── Live preview ──────────────────────────────────────────────────────────
  //
  // ADDED 19/8/2026 — "changes to Add Title / Limitation must show immediately,
  // not after a delay or a refresh".
  //
  // Every field's editable text is a TextEditingController living inside the
  // FieldController in `state.pages`. A CustomTextField mutates it IN PLACE, so
  // after a keystroke `pages` still holds the same objects, Equatable sees an
  // identical state, nothing is emitted, and the preview — which reads `.text`
  // at build time — never rebuilds. It only caught up when an unrelated action
  // (add a row, toggle Required) emitted for its own reasons. Hence the delay.
  //
  // The cubit now watches those controllers and re-emits itself. Doing it here
  // rather than in a widget means it holds for all 18 field types, including
  // the ones whose widgets live under `type_field_widgets/`.

  /// Controllers currently subscribed to, so they can be unsubscribed when the
  /// form's shape changes.
  final Set<TextEditingController> _previewWatched = {};

  /// Coalesces a burst of keystrokes into a single emit.
  ///
  /// 80ms is below the ~100ms mark where a UI stops feeling instant, so this
  /// still reads as immediate — but it is not cosmetic. A controller notifies
  /// listeners synchronously, which can land mid-build; emitting straight from
  /// the callback would risk "setState() called during build". Hopping to a
  /// timer moves the emit to a safe point and collapses one emit per character
  /// into one per pause.
  Timer? _previewDebounce;

  void _onWatchedTextChanged() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 80), () {
      if (isClosed) return;
      final current = state;
      if (current is CreateFormDataLoaded) {
        // copyWith() with no arguments still bumps `version`, which is the only
        // thing in props that can differ here — every other field is the same
        // instance it already was.
        emit(current.copyWith());
      }
    });
  }

  /// Re-points the subscription set at whatever controllers the state now has.
  ///
  /// Driven from [onChange], so it runs after EVERY emit and no mutating method
  /// has to remember to call it.
  void _syncPreviewListeners(CreateFormDataState next) {
    final wanted = <TextEditingController>{};

    if (next is CreateFormDataLoaded) {
      for (final page in next.pages) {
        for (final row in page.rows) {
          final columns = row.numOfColumn;
          if (columns != null) wanted.add(columns);
          for (final field in row.controllers) {
            wanted.addAll(field.textControllers);
          }
        }
      }
    }

    for (final controller in _previewWatched.difference(wanted)) {
      // A row that was just deleted has already had its controllers disposed,
      // and touching a disposed ChangeNotifier throws. Nothing to clean up in
      // that case — the object is going away either way.
      try {
        controller.removeListener(_onWatchedTextChanged);
      } catch (_) {}
    }

    for (final controller in wanted.difference(_previewWatched)) {
      controller.addListener(_onWatchedTextChanged);
    }

    _previewWatched
      ..clear()
      ..addAll(wanted);
  }

  @override
  void onChange(Change<CreateFormDataState> change) {
    super.onChange(change);
    _syncPreviewListeners(change.nextState);
  }

  void changeDropDownResultValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    String? value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is DropDownFieldController) {
      controller.currentValue = value!;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void changeRadioResultValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    String? value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is RadioFieldController) {
      controller.selectedRadio = value!;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void duplicateColumn({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].numOfColumn!.text =
        FormDateTimeHelper.formatInt((pages[pageIndex]
            .rows[rowIndex]
            .numOfColumn!
            .text
            .toEnglishNumber() +
            1));

    final duplicated = pages[pageIndex].rows[rowIndex].controllers[columnIndex].duplicate();
    if (duplicated != null) {
      pages[pageIndex].rows[rowIndex].controllers.add(duplicated);
    }

    emit(currentState.copyWith(pages: pages));
  }

  void duplicateRow({required int pageIndex, required int indexRow}) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final duplicated = pages[pageIndex].rows[indexRow].duplicate();
    if (duplicated != null) {
      pages.last.rows.add(duplicated);
    }

    emit(currentState.copyWith(pages: pages));
  }

  void onRequiredSwitchChanged({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    required bool value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex]
        .changeIsRequired(value);

    emit(currentState.copyWith(pages: pages));
  }

  void addPage() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    List<RowControllerModel> rowModel = [];
    rowModel.add(RowControllerModel(
      controllers: [TextFieldController()],
    ));
    pages.add(PageControllerModel(rows: rowModel));

    emit(currentState.copyWith(pages: pages));
  }

  void addPageWithRow(int pageIndex) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    if (pageIndex + 1 < pages.length) {
      pages[pageIndex + 1].rows.add(pages[pageIndex].rows.last);
    } else {
      pages.add(PageControllerModel(rows: [pages[pageIndex].rows.last]));
    }
    pages[pageIndex].rows.removeLast();

    emit(currentState.copyWith(pages: pages));
  }

  void expandedPage(int pageIndex) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].isPageExpanded = pages[pageIndex].isPageExpanded.toggle();

    int? newExpandedPageIndex;
    for (int i = 0; i < pages.length; i++) {
      var element = pages[i];
      if (element.isPageExpanded) {
        newExpandedPageIndex = i;
        break;
      }
    }

    emit(currentState.copyWith(
      pages: pages,
      expandedPageIndex: newExpandedPageIndex,
    ));
  }

  FormEntity createFormHomeModel() {
    if (state is! CreateFormDataLoaded) throw Exception('State not loaded');
    final currentState = state as CreateFormDataLoaded;

    try {

      if (mainCoreEmployeeController.employeeEntity == null) {
        
        throw Exception('Employee entity is not initialized');
      }

      FormHeadData formCreateModel = createFormHeadCubit.createFormHeadModel();
      PersonEntity personEntity = PersonEntity.fromEmployeeEntity(
          mainCoreEmployeeController.employeeEntity!);

      // ✅ CRITICAL FIX: Use existing form ID if available, otherwise generate new one
      String formId;
      DateTime createDate;

      if (currentState.existingFormId != null && currentState.existingFormId!.isNotEmpty) {
        // ✅ EDITING MODE: Use original ID and date
        formId = currentState.existingFormId!;
        createDate = currentState.existingCreateDate ?? DateTime.now();

      } else {
        // ✅ NEW FORM MODE: Generate new ID and date
        formId = '${mainCoreEmployeeController.employeeEntity!.id}_${DateTime.now().toString()}';
        createDate = DateTime.now();

      }

      FormEntity formModel = FormEntity(
          personEntity: personEntity,
          pages: [],
          id: formId, // ✅ Use the determined ID
          status: FormStatus.publish,
          formHeadModel: formCreateModel,
          createDate: createDate); // ✅ Use the determined create date

      for (var i = 0; i < currentState.pages.length; i++) {
        formModel.pages.add(currentState.pages[i].toModel());
      }

      if (formCreateModel.accessManagement == 'Restricted Access') {
        formModel.restrictedAccessModel = RestrictedAccessModel(
            isEdit: currentState.isEdit,
            timeBegin: currentState.timeBegin,
            timeEnd: currentState.timeEnd,
            selectedPersons: currentState.selectedPersonList);
      } else if (formCreateModel.accessManagement == 'Open Access') {
        formModel.openAccessModel = OpenAccessModel(
          selectedDepartments: currentState.departmentsShown,
          isEdit: currentState.isEdit,
          timeBegin: currentState.timeBegin,
          timeEnd: currentState.timeEnd,
        );
      }

      
      return formModel;

    } catch (e, stackTrace) {

      
      rethrow;
    }
  }

  void onDropDownOpenAccess(String? value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    DepartmentModelPro? model = addDepartmentController.departmentModels
        .firstWhereOrNull((element) => element.departmentID == value); // ✅ NOW WORKS

    if (model == null) return;

    DepartmentEntity departmentEntity = DepartmentEntity(
        id: model.departmentID!,
        name: model.departmentName!,
        nameAr: model.departmentNameInArabic!);

    if (value != null &&
        !currentState.departmentsShown.map((e) => e.id).contains(departmentEntity.id)) {
      final newDepartmentsShown = List<DepartmentEntity>.from(currentState.departmentsShown)
        ..add(departmentEntity);

      emit(currentState.copyWith(
        selectedDepartment: value,
        departmentsShown: newDepartmentsShown,
      ));
    }
  }

  void onCancelDepartmentOpenAccess(int index) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final newDepartmentsShown = List<DepartmentEntity>.from(currentState.departmentsShown)
      ..removeAt(index);

    emit(currentState.copyWith(departmentsShown: newDepartmentsShown));
  }

  void addToSavedColors(Color color) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    if (!currentState.savedColors.contains(color)) {
      final newSavedColors = List<Color>.from(currentState.savedColors)..add(color);
      emit(currentState.copyWith(savedColors: newSavedColors));
    }
  }

  void selectPerson(PersonEntity person) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final newPersonList = List<PersonEntity>.from(currentState.personList);
    final newSelectedPersonList = List<PersonEntity>.from(currentState.selectedPersonList);

    final personIndex = newPersonList.indexWhere((p) => p.id == person.id);
    if (personIndex != -1) {
      if (newPersonList[personIndex].isSelected) {
        newPersonList[personIndex].isSelected = false;
        newSelectedPersonList.remove(newPersonList[personIndex]);
      } else {
        newPersonList[personIndex].isSelected = true;
        newSelectedPersonList.add(newPersonList[personIndex]);
      }
    }

    emit(currentState.copyWith(
      personList: newPersonList,
      selectedPersonList: newSelectedPersonList,
    ));
  }

  void selectPresonDepartment(String? value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    emit(currentState.copyWith(currentPersonDepartment: value));
    filterPerson();
  }

  void search(String value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    emit(currentState.copyWith(textSearch: value));
    filterPerson();
  }

  void updateTimeBegin(DateTime? date) {

    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      

      emit(currentState.copyWith(
        timeBegin: date,
        incrementVersion: true,
      ));

      final newState = state as CreateFormDataLoaded;

      
    } else {
      
    }
  }

  /// ✅ Update time end
  void updateTimeEnd(DateTime? date) {

    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      

      emit(currentState.copyWith(
        timeEnd: date,
        incrementVersion: true,
      ));

      final newState = state as CreateFormDataLoaded;

      
    } else {
      
    }
  }

  /// ✅ ADD THIS METHOD - Update edit permission
  void updateIsEdit(bool value) {

    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      emit(currentState.copyWith(
        isEdit: value,
        incrementVersion: true,
      ));

      final newState = state as CreateFormDataLoaded;
      
    } else {
      
    }
  }

  FormEntity addOpenAccessData(FormEntity form) {
    if (state is! CreateFormDataLoaded) return form;
    final currentState = state as CreateFormDataLoaded;

    form.openAccessModel = OpenAccessModel(
      selectedDepartments: currentState.departmentsShown,
      isEdit: currentState.isEdit,
      timeBegin: currentState.timeBegin,
      timeEnd: currentState.timeEnd,
    );
    return form;
  }

  FormEntity addRestrictedAccessData(FormEntity form) {
    if (state is! CreateFormDataLoaded) return form;
    final currentState = state as CreateFormDataLoaded;

    form.restrictedAccessModel = RestrictedAccessModel(
        isEdit: currentState.isEdit,
        timeBegin: currentState.timeBegin,
        timeEnd: currentState.timeEnd,
        selectedPersons: currentState.selectedPersonList);
    return form;
  }

  void resetController() {
    emit(CreateFormDataLoaded(
      pages: [],
      expandedPageIndex: 0,
      departmentsShown: [],
      personList: [],
      shownPersonList: [],
      selectedPersonList: [],
      isEdit: false,
      savedColors: [AppColors.white, AppColors.black],
    ));
  }

  @override
  Future<void> close() {
    // Unsubscribe BEFORE the dispose loop below: removing a listener from an
    // already-disposed controller throws, and a pending debounce would try to
    // emit on a closed cubit.
    _previewDebounce?.cancel();
    _previewDebounce = null;
    for (final controller in _previewWatched) {
      try {
        controller.removeListener(_onWatchedTextChanged);
      } catch (_) {}
    }
    _previewWatched.clear();

    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;
      for (var page in currentState.pages) {
        for (var row in page.rows) {
          row.numOfColumn!.dispose();
          for (var controllerModel in row.controllers) {
            controllerModel.dispose();
          }
        }
      }
    }
    return super.close();
  }

  void changeCheckBoxValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    required int indexOption,
    required bool value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is CheckBoxFieldController) {
      if (value == false) {
        controller.options[indexOption].value = false;
        emit(currentState.copyWith(pages: pages));
        return;
      }

      var maximumSelection = controller.maximumSelection;
      if (maximumSelection!.text == '') {
        controller.options[indexOption].value = value;
        emit(currentState.copyWith(pages: pages));
        return;
      } else {
        int numOfSelection = 0;
        var options = controller.options;
        for (var element in options) {
          numOfSelection = element.value ? numOfSelection + 1 : numOfSelection;
        }
        if (numOfSelection < maximumSelection.text.toEnglishNumber()) {
          controller.options[indexOption].value = value;
          emit(currentState.copyWith(pages: pages));
        }
      }
    }
  }
}
