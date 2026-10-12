import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/base_repository/result_base_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/table_row_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/result_constants.dart';
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/notification_controller_cubit_main_core.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/csv_helper.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/use_cases/get_users_responses_results_use_cases.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_table_builder.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
class ResultCubit extends Cubit<ResultState> {
  final ResultBaseRepository resultRepository;

  ResultCubit({required this.resultRepository}) : super(ResultInitial());

  Future<void> initialize(FormEntity formEntity, TickerProvider vsync) async {
    emit(ResultLoading());

    final tabController = TabController(length: 2, vsync: vsync);
    tabController.addListener(() => onChangeTab(tabController.index));

    emit(ResultLoaded(
      formEntity: formEntity,
      tabController: tabController,
      searchController: TextEditingController(),
      textEditingController: TextEditingController(),
      pendingUsers: [],
      filteredPendingUsers: [],
      submittedUsers: [],
      filteredSubmittedUsers: [],
      analyticsData: [],
      isPendingScreen: true,
      isGridView: true,
      isUser: true,
      pages: [],
    ));

    await getUsersResponses();
  }

  Future<void> getUsersResponses() async {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    // ✅ Ensure departments are loaded FIRST
    try {
      MainCoreDepartmentCubit deptController =
      Get.find<MainCoreDepartmentCubit>();
      if (deptController.departmentModels.isEmpty) {
        
        await deptController.getAllDepartments();
        
      }
    } catch (e) {
      
    }

    List<String> activeUsers = await _getActiveUsers();

    Either<Failure, dynamic> result =
    await GetUsersResponsesUseCases(resultRepository: resultRepository)
        .execute(
      formId: currentState.formEntity!.id,
      userIds: activeUsers,
    );

    if (result.isLeft()) {
      emit(ResultError("Failed to load user responses"));
      return;
    }

    Map<String, List<UserGridItem>> usersResponses =
    result.getOrElse(() => {});
    final pendingUsers =
        usersResponses[ResultConstants.pendingGridItemModel] ?? [];
    final submittedUsers =
        usersResponses[ResultConstants.submittedGridItemModel] ?? [];

    emit(currentState.copyWith(
      pendingUsers: pendingUsers,
      filteredPendingUsers: pendingUsers,
      submittedUsers: submittedUsers,
      filteredSubmittedUsers: submittedUsers,
    ));
  }

  Future<List<String>> _getActiveUsers() async {
    if (state is! ResultLoaded) return [];
    final currentState = state as ResultLoaded;

    Either<Failure, dynamic> result =
    await resultRepository.getFormPrivacy(currentState.formEntity!.id);
    if (result.isLeft()) return [];

    FormPrivacyModel? formPrivacyModel = result.getOrElse(() => null);
    if (formPrivacyModel == null) return [];

    List<String> activeUsersEmails = [];
    for (int index = 0;
    index < formPrivacyModel.usersModel!.emails!.length;
    index++) {
      if (formPrivacyModel.usersModel!.status![index] == "active") {
        activeUsersEmails.add(formPrivacyModel.usersModel!.emails![index]);
      }
    }
    return activeUsersEmails;
  }

  void onChangeTab(int value) {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    final isPendingScreen = value == 0;
    currentState.tabController.index = value;

    emit(currentState.copyWith(isPendingScreen: isPendingScreen));
  }

  /// Returns true when the reminder was recorded (form bug report #20 — the
  /// screen shows a success dialog off this).
  Future<bool> remindClicked(UserGridItem model) async {
    if (state is! ResultLoaded) return false;
    final currentState = state as ResultLoaded;

    NotificationControllerCubit().sendNotification(
      title:
      "Reminder: Please Complete the Form ${currentState.formEntity!.formHeadModel.title}",
      arabicTitle:
      "تذكير: يرجى إكمال نموذج ${currentState.formEntity!.formHeadModel.arTitle}",
      body:
      "This is a gentle reminder to complete the form ${currentState.formEntity!.formHeadModel.title}, which is still pending your submission.",
      arabicBody:
      "هذا تذكير لطيف لإكمال النموذج ${currentState.formEntity!.formHeadModel.arTitle}، الذي لا يزال في انتظار تقديمك.",
      type: "formBuilder",
      emails: [model.person.id],
    );

    Either<Failure, dynamic> result = await resultRepository.remindUser(
      userId: model.person.id,
      formId: currentState.formEntity!.id,
    );

    if (result.isRight()) {
      model.lastReminderTime = DateTime.now();
      model.reminderCounter++;
      emit(currentState.copyWith());
      return true;
    }
    return false;
  }

  /// Sends every due reminder and returns how many went out (form bug report
  /// #20: the screen shows "Reminder Sent Successfully" when it is > 0).
  Future<int> remindAllClicked() async {
    if (state is! ResultLoaded) return 0;
    final currentState = state as ResultLoaded;

    final due = currentState.filteredPendingUsers
        .where((element) => isMoreThan24Hours(element.lastReminderTime))
        .toList();
    final results = await Future.wait(due.map(remindClicked));
    return results.where((ok) => ok).length;
  }

  bool isMoreThan24Hours(DateTime? dateTime) {
    if (dateTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(dateTime).inHours;
    return difference > 24;
  }

  String getRemainingTimeText(DateTime reminderSentTime) {
    final now = DateTime.now();
    final reminderSentDuration = now.difference(reminderSentTime);
    final hoursRemaining = 24 - reminderSentDuration.inHours;
    final minutesRemaining = (24 * 60 - reminderSentDuration.inMinutes) % 60;

    if (hoursRemaining <= 0 && minutesRemaining <= 0) {
      return 'Resend Now';
    } else if (hoursRemaining < 1) {
      return ' $minutesRemaining ${'Minutes'}';
    } else {
      return '${'Resend In'} ${FormDateTimeHelper.formatInt(hoursRemaining)} ${'Hours'}';
    }
  }

  void changeDataView(bool value) {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    if (value == currentState.isGridView) return;
    emit(currentState.copyWith(isGridView: value));
  }

  void onChangeSwitch(bool value) {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    if (value == currentState.isUser) return;

    // Add a small delay to let chart animations complete
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!isClosed && state is ResultLoaded) {
        emit(currentState.copyWith(isUser: value));
      }
    });
  }

  Future<void> exportToExcel() async {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add column headers
    List<CellValue?> columnHeaders =
    buildResultTableColumns(currentState).map((column) {
      return TextCellValue((column.label as Text).data!);
    }).toList();
    sheetObject.appendRow(columnHeaders);

    // Add rows
    for (DataRow row in buildResultTableRows(currentState)) {
      List<CellValue?> rowData = row.cells.map((cell) {
        return TextCellValue((cell.child as Text).data!);
      }).toList();
      sheetObject.appendRow(rowData);
    }

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      downloadsDir = await getDownloadsDirectory();
    }

    String stringFileName = currentState.textEditingController.text;
    final file = File('${downloadsDir?.path}/$stringFileName.xlsx');

    file.writeAsBytesSync(excel.encode()!);
    
  }

  void search() {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    String value = currentState.searchController.text;
    applyDepartmentFilter();

    if (state is! ResultLoaded) return;
    final updatedState = state as ResultLoaded;

    final filteredPendingUsers =
    List<UserGridItem>.from(updatedState.filteredPendingUsers)
      ..removeWhere((element) =>
      !element.person.name.toLowerCase().contains(value.toLowerCase()));

    final filteredSubmittedUsers =
    List<UserGridItem>.from(updatedState.filteredSubmittedUsers)
      ..removeWhere((element) =>
      !element.person.name.toLowerCase().contains(value.toLowerCase()));

    emit(updatedState.copyWith(
      filteredPendingUsers: filteredPendingUsers,
      filteredSubmittedUsers: filteredSubmittedUsers,
    ));
  }

  void applyDepartmentFilter() {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    List<UserGridItem> filteredPendingUsers = [];
    List<UserGridItem> filteredSubmittedUsers = [];

    if (currentState.selectedDepartmentFilter == null ||
        currentState.selectedDepartmentFilter!.toLowerCase() ==
            S.current.all.toLowerCase()) {
      filteredPendingUsers = currentState.pendingUsers;
      filteredSubmittedUsers = currentState.submittedUsers;
    } else {
      filteredSubmittedUsers = currentState.submittedUsers
          .where((element) =>
      element.person.departmentName ==
          currentState.selectedDepartmentFilter!.toLowerCase())
          .toList();
      filteredPendingUsers = currentState.pendingUsers
          .where((element) =>
      element.person.departmentName ==
          currentState.selectedDepartmentFilter!.toLowerCase())
          .toList();
    }

    emit(currentState.copyWith(
      filteredPendingUsers: filteredPendingUsers,
      filteredSubmittedUsers: filteredSubmittedUsers,
    ));
  }

  void updateSelectedDepartmentFilter(String? department) {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    emit(currentState.copyWith(
      selectedDepartmentFilter: department,
      clearDepartmentFilter: department == null,
    ));
    applyDepartmentFilter();
  }

  void selectUser(UserGridItem user) {
    if (state is! ResultLoaded) return;
    final currentState = state as ResultLoaded;

    final pages = <PageControllerModel>[];
    for (var element in user.page!) {
      pages.add(element.toController(isSetData: true));
    }

    emit(currentState.copyWith(
      selectedUser: user,
      pages: pages,
      isSubmitted: true,
      isReadOnly: true,
    ));
  }

  Future<List<List>> _getExportData() async {
    if (state is! ResultLoaded) return [];
    final currentState = state as ResultLoaded;

    List<List> rows = [];
    List headers = [];
    headers.addAll(buildResultTableHeaders(currentState));
    rows.add(headers);

    for (int userIndex = 0;
    userIndex < currentState.filteredSubmittedUsers.length;
    userIndex++) {
      List<String> rowData = [];
      TableRowData tableRowData =
      TableRowData.fromUserGridItem(currentState.filteredSubmittedUsers[userIndex]);
      for (var answer in tableRowData.getTableList()) {
        rowData.add(answer);
      }
      rows.add(rowData);
    }

    return rows;
  }

  Future<void> exportToCSV(String fileName) async {
    showLoadingIndicator();
    try {
      List<List> rows = await _getExportData();
      await CSVHelper().exportToCSV(rows, fileName);
      hideLoadingIndicator();
      AppDialogs.downloadingExcelSuccessfully(Get.context!);
    } catch (e) {
      hideLoadingIndicator();
    }
  }

  @override
  Future<void> close() {
    if (state is ResultLoaded) {
      final currentState = state as ResultLoaded;
      currentState.tabController.dispose();
      currentState.searchController.dispose();
      currentState.textEditingController.dispose();
    }
    return super.close();
  }
}