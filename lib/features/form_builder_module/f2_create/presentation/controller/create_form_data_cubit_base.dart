import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // ✅ ADD THIS
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:provider/provider.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
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
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/preview_screen.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';


class CreateFormDataCubitBase extends Cubit<CreateFormDataState> {
  final MainCoreEmployeeController mainCoreEmployeeController;
  final MainCoreDepartmentCubit addDepartmentController;
  final CreateFormHeadCubit createFormHeadCubit;
  late GlobalKey<FormState> formCreateDataKey;
  List<PersonEntity> _personList = [];
  List<PersonEntity> _shownPersonList = [];

  CreateFormDataCubitBase({
    required this.mainCoreEmployeeController,
    required this.addDepartmentController,
    required this.createFormHeadCubit,
  }) : super(CreateFormDataInitial());

  Future<void> init({FormEntity? editFormModel}) async {
    emit(CreateFormDataLoading());

    formCreateDataKey = GlobalKey<FormState>();
    List<PageControllerModel> pages = [];

    // ✅ CRITICAL: Capture existing form data if editing
    String? existingFormId;
    DateTime? existingCreateDate;

    if (editFormModel == null) {
      
      List<RowControllerModel> rowModel = [];
      rowModel.add(RowControllerModel(
        controllers: [TextFieldController()],
      ));
      pages.add(PageControllerModel(rows: rowModel));
    } else {
      // ✅ CRITICAL: Store the original form ID and create date
      existingFormId = editFormModel.id;
      existingCreateDate = editFormModel.createDate;

      

      for (var element in editFormModel.pages) {
        pages.add(element.toController());
      }
    }

    await setUsers();

    emit(CreateFormDataLoaded(
      pages: pages,
      expandedPageIndex: 0,
      departmentsShown: [],
      personList: _personList,
      shownPersonList: _shownPersonList,
      selectedPersonList: [],
      isEdit: false,
      savedColors: [AppColors.white, AppColors.black],
      existingFormId: existingFormId, // ✅ CRITICAL: Store original ID
      existingCreateDate: existingCreateDate, // ✅ CRITICAL: Store original date
    ));

  }

  Future<void> setUsers() async {
    if (mainCoreEmployeeController.allEmployeesEntities == null ||
        mainCoreEmployeeController.allEmployeesEntities!.isEmpty) {
      await mainCoreEmployeeController.getAllNewEmployees();
    }
    _personList = mainCoreEmployeeController.allEmployeesEntities!
        .map((e) => PersonEntity.fromEmployeeEntity(e) as PersonEntity)
        .toList();
    _shownPersonList = _personList;
  }

  void deleteRow({required int pageIndex, required int rowIndex}) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows.removeAt(rowIndex);
    if (pages[pageIndex].rows.isEmpty) {
      deletePage(pageIndex);
      return;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void deletePage(int pageIndex) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages.removeAt(pageIndex);
    if (pages.length == 1) {
      pages[0].isPageExpanded = true;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void filterPerson() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    List<PersonEntity> filtered = List.from(currentState.personList);

    if (currentState.currentPersonDepartment != null) {
      filtered = filtered
          .where((element) => element.department == currentState.currentPersonDepartment)
          .toList();
    }
    if (currentState.textSearch != null && currentState.textSearch!.isNotEmpty) {
      filtered = filtered
          .where((element) => mainCoreEmployeeController
          .getEmployeeName(element.id)
          .toLowerCase()
          .contains(currentState.textSearch!))
          .toList();
    }

    emit(currentState.copyWith(shownPersonList: filtered));
  }

  void changeNumberOfColumn({
    required int value,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final currentLength = pages[pageIndex].rows[rowIndex].controllers.length;

    if (currentLength > value) {
      pages[pageIndex].rows[rowIndex].controllers.removeRange(value, currentLength);
    } else if (currentLength < value) {
      int addCount = value - currentLength;
      for (var i = 0; i < addCount; i++) {
        pages[pageIndex].rows[rowIndex].controllers.add(TextFieldController());
      }
    }

    // Version will auto-increment, forcing rebuild
    emit(currentState.copyWith(pages: pages));
  }

  void changeAlignmentValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex]
        .changeAlignmentValue(value);

    emit(currentState.copyWith(pages: pages));
  }

  void changeArrangementValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex]
        .changeArrangementValue(value);

    emit(currentState.copyWith(pages: pages));
  }

  void changeLocationTypeValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is LocationFieldController) {
      controller.locationType = value;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void setTitleTextSize({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required bool isAdd,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      int result;
      if (isAdd) {
        result = controller.textSize!.text.toEnglishNumber();
        result = result < 99 ? (++result) : (result);
      } else {
        result = controller.textSize!.text.toEnglishNumber();
        result = result > 0 ? (--result) : (result);
      }
      controller.textSize!.text = FormDateTimeHelper.formatInt(result).doubleDigit;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void setTitleColor({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required Color color,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      controller.titleColor = color;
    }

    emit(currentState.copyWith(pages: pages));
  }

  void changeTitleStyle({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required String style,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      if (style == 'bold') {
        controller.isBold = controller.isBold!.toggle();
      } else if (style == 'underLine') {
        controller.isUnderLine = controller.isUnderLine!.toggle();
      } else {
        controller.isItalic = controller.isItalic!.toggle();
      }
    }

    emit(currentState.copyWith(pages: pages));
  }

  void changeFieldTypeValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);

    // Get the new field type
    final newFieldType = FieldTypeExtension.fromName(value)!;
    final tempController = FieldController(newFieldType);
    final newController = tempController.initialize();

    // Replace controller
    pages[pageIndex].rows[rowIndex].controllers[columnIndex] = newController;

    // Version will auto-increment, forcing rebuild
    emit(currentState.copyWith(pages: pages));
  }

  void addOption({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex].addOption();

    emit(currentState.copyWith(pages: pages));
  }

  void removeOption({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required int optionIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex]
        .removeOption(optionIndex);

    emit(currentState.copyWith(pages: pages));
  }

  void onExpanded({required int pageIndex, required int rowIndex}) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].isRowExpanded =
        pages[pageIndex].rows[rowIndex].isRowExpanded.toggle();

    emit(currentState.copyWith(pages: pages));
  }

  void updateFieldText({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    // Just emit a new state with incremented version to trigger rebuild
    emit(currentState.copyWith(incrementVersion: true));
  }

  void deleteColumn({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);

    if (pages[pageIndex].rows[rowIndex].controllers.length > 1) {
      // Update the number of columns
      pages[pageIndex].rows[rowIndex].numOfColumn!.text =
          FormDateTimeHelper.formatInt((pages[pageIndex]
              .rows[rowIndex]
              .numOfColumn!
              .text
              .toEnglishNumber() -
              1));

      // Store controller to dispose
      final controllerToDispose = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

      // Remove from list
      pages[pageIndex].rows[rowIndex].controllers.removeAt(columnIndex);

      // Emit state FIRST
      emit(currentState.copyWith(pages: pages));

      // Dispose AFTER frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllerToDispose.dispose();
      });
    } else {
      deleteRow(pageIndex: pageIndex, rowIndex: rowIndex);
      return;
    }
  }

  void preview(BuildContext context) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    for (var element in pages) {
      element.isPageExpanded = true;
    }

    emit(currentState.copyWith(pages: pages));

    // ✅ Use MultiProvider for mixing Bloc and regular providers
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            // BLoC providers
            BlocProvider.value(value: this), // CreateFormDataCubit
            BlocProvider.value(value: createFormHeadCubit), // CreateFormHeadCubit// MainCoreDepartmentCubit
          ],
          child: PreviewScreen(),
        ),
      ),
    );
  }

  void addRow() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    if (pages.isEmpty) {
      init();
      return;
    }
    pages.last.rows.add(RowControllerModel(
      controllers: [TextFieldController()],
    ));

    emit(currentState.copyWith(pages: pages));
  }
}
