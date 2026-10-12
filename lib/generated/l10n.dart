// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `About This App`
  String get aboutThisApp {
    return Intl.message(
      'About This App',
      name: 'aboutThisApp',
      desc: '',
      args: [],
    );
  }

  /// `About this platform`
  String get aboutThisPlatform {
    return Intl.message(
      'About this platform',
      name: 'aboutThisPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Above Baseline Color`
  String get aboveBaselineColor {
    return Intl.message(
      'Above Baseline Color',
      name: 'aboveBaselineColor',
      desc: '',
      args: [],
    );
  }

  /// `Absence`
  String get absence {
    return Intl.message('Absence', name: 'absence', desc: '', args: []);
  }

  /// `Absent`
  String get absent {
    return Intl.message('Absent', name: 'absent', desc: '', args: []);
  }

  /// `Academic History`
  String get academicHistory {
    return Intl.message(
      'Academic History',
      name: 'academicHistory',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message('Accepted', name: 'accepted', desc: '', args: []);
  }

  /// `Access`
  String get access {
    return Intl.message('Access', name: 'access', desc: '', args: []);
  }

  /// `Access Granted`
  String get access_granted {
    return Intl.message(
      'Access Granted',
      name: 'access_granted',
      desc: '',
      args: [],
    );
  }

  /// `Access Grantor`
  String get access_grantor {
    return Intl.message(
      'Access Grantor',
      name: 'access_grantor',
      desc: '',
      args: [],
    );
  }

  /// `Access Removed`
  String get access_removed {
    return Intl.message(
      'Access Removed',
      name: 'access_removed',
      desc: '',
      args: [],
    );
  }

  /// `User access has been successfully removed. Status changed to inactive and role cleared.`
  String get access_removed_success {
    return Intl.message(
      'User access has been successfully removed. Status changed to inactive and role cleared.',
      name: 'access_removed_success',
      desc: '',
      args: [],
    );
  }

  /// `Access Revoked`
  String get access_revoked {
    return Intl.message(
      'Access Revoked',
      name: 'access_revoked',
      desc: '',
      args: [],
    );
  }

  /// `Access Blocked`
  String get accessBlocked {
    return Intl.message(
      'Access Blocked',
      name: 'accessBlocked',
      desc: '',
      args: [],
    );
  }

  /// `Access Denied`
  String get accessDenied {
    return Intl.message(
      'Access Denied',
      name: 'accessDenied',
      desc: '',
      args: [],
    );
  }

  /// `Access Details`
  String get accessDetails {
    return Intl.message(
      'Access Details',
      name: 'accessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Access Level`
  String get accessLevel {
    return Intl.message(
      'Access Level',
      name: 'accessLevel',
      desc: '',
      args: [],
    );
  }

  /// `Access Level is required`
  String get accessLevelRequired {
    return Intl.message(
      'Access Level is required',
      name: 'accessLevelRequired',
      desc: '',
      args: [],
    );
  }

  /// `Accessories Returned`
  String get accessoriesReturned {
    return Intl.message(
      'Accessories Returned',
      name: 'accessoriesReturned',
      desc: '',
      args: [],
    );
  }

  /// `Access Updated`
  String get accessUpdated {
    return Intl.message(
      'Access Updated',
      name: 'accessUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Account Locked`
  String get accountLocked {
    return Intl.message(
      'Account Locked',
      name: 'accountLocked',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been locked due to multiple unsuccessful login attempts. Please contact the administrator.`
  String get accountLockedMessage {
    return Intl.message(
      'Your account has been locked due to multiple unsuccessful login attempts. Please contact the administrator.',
      name: 'accountLockedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `Action Failed`
  String get actionFailed {
    return Intl.message(
      'Action Failed',
      name: 'actionFailed',
      desc: '',
      args: [],
    );
  }

  /// `Action Taken`
  String get actionTaken {
    return Intl.message(
      'Action Taken',
      name: 'actionTaken',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get activate {
    return Intl.message('Activate', name: 'activate', desc: '', args: []);
  }

  /// `Activated`
  String get activated {
    return Intl.message('Activated', name: 'activated', desc: '', args: []);
  }

  /// `Activate Policies`
  String get activatePolicies {
    return Intl.message(
      'Activate Policies',
      name: 'activatePolicies',
      desc: '',
      args: [],
    );
  }

  /// `Activating Requests`
  String get activatingRequests {
    return Intl.message(
      'Activating Requests',
      name: 'activatingRequests',
      desc: '',
      args: [],
    );
  }

  /// `Activating Roles`
  String get activatingRoles {
    return Intl.message(
      'Activating Roles',
      name: 'activatingRoles',
      desc: '',
      args: [],
    );
  }

  /// `Activating Service`
  String get activatingService {
    return Intl.message(
      'Activating Service',
      name: 'activatingService',
      desc: '',
      args: [],
    );
  }

  /// `Activating User Account`
  String get activatingUserAccount {
    return Intl.message(
      'Activating User Account',
      name: 'activatingUserAccount',
      desc: '',
      args: [],
    );
  }

  /// `Activation Date`
  String get activationDate {
    return Intl.message(
      'Activation Date',
      name: 'activationDate',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Arabic Name`
  String get arabicName {
    return Intl.message('Arabic Name', name: 'arabicName', desc: '', args: []);
  }

  /// `Are You Sure You Want To Create This Form ?`
  String get areYouSureCreateForm {
    return Intl.message(
      'Are You Sure You Want To Create This Form ?',
      name: 'areYouSureCreateForm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Put This Form In The Draft?`
  String get areYouSureDraftForm {
    return Intl.message(
      'Are You Sure You Want To Put This Form In The Draft?',
      name: 'areYouSureDraftForm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Form ?`
  String get areYouSureEditForm {
    return Intl.message(
      'Are You Sure You Want To Edit This Form ?',
      name: 'areYouSureEditForm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Restore The Form?`
  String get areYouSureRestoreForm {
    return Intl.message(
      'Are You Sure You Want To Restore The Form?',
      name: 'areYouSureRestoreForm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Submit This Form ?`
  String get areYouSureSubmitForm {
    return Intl.message(
      'Are You Sure You Want To Submit This Form ?',
      name: 'areYouSureSubmitForm',
      desc: '',
      args: [],
    );
  }

  /// `You Can't Edit This Form Because It Has Been Submitted`
  String get cantEditFormBecauseSubmitted {
    return Intl.message(
      'You Can\'t Edit This Form Because It Has Been Submitted',
      name: 'cantEditFormBecauseSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Download As Excel`
  String get downloadAsExcel {
    return Intl.message(
      'Download As Excel',
      name: 'downloadAsExcel',
      desc: '',
      args: [],
    );
  }

  /// `Download As PDF`
  String get downloadAsPdf {
    return Intl.message(
      'Download As PDF',
      name: 'downloadAsPdf',
      desc: '',
      args: [],
    );
  }

  /// `Download Form`
  String get downloadForm {
    return Intl.message(
      'Download Form',
      name: 'downloadForm',
      desc: '',
      args: [],
    );
  }

  /// `Draft Form`
  String get draftForm {
    return Intl.message('Draft Form', name: 'draftForm', desc: '', args: []);
  }

  /// `Duplicating Form`
  String get duplicatingForm {
    return Intl.message(
      'Duplicating Form',
      name: 'duplicatingForm',
      desc: '',
      args: [],
    );
  }

  /// `English Name`
  String get englishName {
    return Intl.message(
      'English Name',
      name: 'englishName',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get feedbackClosed {
    return Intl.message('Closed', name: 'feedbackClosed', desc: '', args: []);
  }

  /// `Fixed`
  String get feedbackFixed {
    return Intl.message('Fixed', name: 'feedbackFixed', desc: '', args: []);
  }

  /// `Form Created`
  String get formCreated {
    return Intl.message(
      'Form Created',
      name: 'formCreated',
      desc: '',
      args: [],
    );
  }

  /// `Form Download As PDF`
  String get formDownloadAsPdf {
    return Intl.message(
      'Form Download As PDF',
      name: 'formDownloadAsPdf',
      desc: '',
      args: [],
    );
  }

  /// `Grant Access Successfully`
  String get grantAccessSuccessfully {
    return Intl.message(
      'Grant Access Successfully',
      name: 'grantAccessSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Group Created Successfully`
  String get groupCreatedSuccessfully {
    return Intl.message(
      'Group Created Successfully',
      name: 'groupCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Improvements To Existing Feature`
  String get improvementsToExistingFeature {
    return Intl.message(
      'Improvements To Existing Feature',
      name: 'improvementsToExistingFeature',
      desc: '',
      args: [],
    );
  }

  /// `Role Status`
  String get roleStatus {
    return Intl.message('Role Status', name: 'roleStatus', desc: '', args: []);
  }

  /// `Active Roles`
  String get activeRoles {
    return Intl.message(
      'Active Roles',
      name: 'activeRoles',
      desc: '',
      args: [],
    );
  }

  /// `Active Permissions`
  String get active_permissions {
    return Intl.message(
      'Active Permissions',
      name: 'active_permissions',
      desc: '',
      args: [],
    );
  }

  /// `Active Directory`
  String get activeDirectory {
    return Intl.message(
      'Active Directory',
      name: 'activeDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Active Directory Module`
  String get activeDirectoryModule {
    return Intl.message(
      'Active Directory Module',
      name: 'activeDirectoryModule',
      desc: '',
      args: [],
    );
  }

  /// `Active For Now`
  String get activeForNow {
    return Intl.message(
      'Active For Now',
      name: 'activeForNow',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Add Department`
  String get add_department {
    return Intl.message(
      'Add Department',
      name: 'add_department',
      desc: '',
      args: [],
    );
  }

  /// `Add New Item`
  String get add_New_Item {
    return Intl.message(
      'Add New Item',
      name: 'add_New_Item',
      desc: '',
      args: [],
    );
  }

  /// `Add Access`
  String get addAccess {
    return Intl.message('Add Access', name: 'addAccess', desc: '', args: []);
  }

  /// `Add Approvals`
  String get addApprovals {
    return Intl.message(
      'Add Approvals',
      name: 'addApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Add Asset`
  String get addAsset {
    return Intl.message('Add Asset', name: 'addAsset', desc: '', args: []);
  }

  /// `Add at least one row`
  String get addAtLeastOneRow {
    return Intl.message(
      'Add at least one row',
      name: 'addAtLeastOneRow',
      desc: '',
      args: [],
    );
  }

  /// `Add Baseline`
  String get addBaseline {
    return Intl.message(
      'Add Baseline',
      name: 'addBaseline',
      desc: '',
      args: [],
    );
  }

  /// `Add Caption`
  String get addCaption {
    return Intl.message('Add Caption', name: 'addCaption', desc: '', args: []);
  }

  /// `Add Champion`
  String get addChampion {
    return Intl.message(
      'Add Champion',
      name: 'addChampion',
      desc: '',
      args: [],
    );
  }

  /// `Add Control`
  String get addControl {
    return Intl.message('Add Control', name: 'addControl', desc: '', args: []);
  }

  /// `Add Control Champion`
  String get addControlChampion {
    return Intl.message(
      'Add Control Champion',
      name: 'addControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Add Controller`
  String get addController {
    return Intl.message(
      'Add Controller',
      name: 'addController',
      desc: '',
      args: [],
    );
  }

  /// `Add Control Owner`
  String get addControlOwner {
    return Intl.message(
      'Add Control Owner',
      name: 'addControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Add departments or switch off limit department availability`
  String get addDepartmentsOrSwitchOffLimitAvailability {
    return Intl.message(
      'Add departments or switch off limit department availability',
      name: 'addDepartmentsOrSwitchOffLimitAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Added By`
  String get addedBy {
    return Intl.message('Added By', name: 'addedBy', desc: '', args: []);
  }

  /// `Added On`
  String get addedOn {
    return Intl.message('Added On', name: 'addedOn', desc: '', args: []);
  }

  /// `Add Employee`
  String get addEmployee {
    return Intl.message(
      'Add Employee',
      name: 'addEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Adding Asset`
  String get addingAsset {
    return Intl.message(
      'Adding Asset',
      name: 'addingAsset',
      desc: '',
      args: [],
    );
  }

  /// `Adding Attachment`
  String get addingAttachment {
    return Intl.message(
      'Adding Attachment',
      name: 'addingAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Access`
  String get addingNewAccess {
    return Intl.message(
      'Adding New Access',
      name: 'addingNewAccess',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Control Champion`
  String get addingNewControlChampion {
    return Intl.message(
      'Adding New Control Champion',
      name: 'addingNewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Control Owner`
  String get addingNewControlOwner {
    return Intl.message(
      'Adding New Control Owner',
      name: 'addingNewControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Location`
  String get addingNewLocation {
    return Intl.message(
      'Adding New Location',
      name: 'addingNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Order`
  String get addingNewOrder {
    return Intl.message(
      'Adding New Order',
      name: 'addingNewOrder',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Product`
  String get addingNewProduct {
    return Intl.message(
      'Adding New Product',
      name: 'addingNewProduct',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Role`
  String get addingNewRole {
    return Intl.message(
      'Adding New Role',
      name: 'addingNewRole',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Role Permissions`
  String get addingNewRolePermissions {
    return Intl.message(
      'Adding New Role Permissions',
      name: 'addingNewRolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Storage Location`
  String get addingNewStorageLocation {
    return Intl.message(
      'Adding New Storage Location',
      name: 'addingNewStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Adding New Supplier`
  String get addingNewSupplier {
    return Intl.message(
      'Adding New Supplier',
      name: 'addingNewSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Order added successfully`
  String get addingOrderSuccessfully {
    return Intl.message(
      'Order added successfully',
      name: 'addingOrderSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Adding Transaction`
  String get addingTransaction {
    return Intl.message(
      'Adding Transaction',
      name: 'addingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Adding Widget`
  String get addingWidget {
    return Intl.message(
      'Adding Widget',
      name: 'addingWidget',
      desc: '',
      args: [],
    );
  }

  /// `Additional Information`
  String get additionalInformation {
    return Intl.message(
      'Additional Information',
      name: 'additionalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Additional Note`
  String get additionalNote {
    return Intl.message(
      'Additional Note',
      name: 'additionalNote',
      desc: '',
      args: [],
    );
  }

  /// `Add Location`
  String get addLocation {
    return Intl.message(
      'Add Location',
      name: 'addLocation',
      desc: '',
      args: [],
    );
  }

  /// `Add Member`
  String get addMember {
    return Intl.message('Add Member', name: 'addMember', desc: '', args: []);
  }

  /// `Add New Control Champion`
  String get addNewControlChampion {
    return Intl.message(
      'Add New Control Champion',
      name: 'addNewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Add New Employees`
  String get addNewEmployees {
    return Intl.message(
      'Add New Employees',
      name: 'addNewEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Add new item`
  String get addNewItem {
    return Intl.message('Add new item', name: 'addNewItem', desc: '', args: []);
  }

  /// `Add New Storage`
  String get addNewStorage {
    return Intl.message(
      'Add New Storage',
      name: 'addNewStorage',
      desc: '',
      args: [],
    );
  }

  /// `Add option`
  String get addOption {
    return Intl.message('Add option', name: 'addOption', desc: '', args: []);
  }

  /// `Adding Order`
  String get addOrder {
    return Intl.message('Adding Order', name: 'addOrder', desc: '', args: []);
  }

  /// `Add Owner`
  String get addOwner {
    return Intl.message('Add Owner', name: 'addOwner', desc: '', args: []);
  }

  /// `Add Photo`
  String get addPhoto {
    return Intl.message('Add Photo', name: 'addPhoto', desc: '', args: []);
  }

  /// `Add Policy`
  String get addPolicy {
    return Intl.message('Add Policy', name: 'addPolicy', desc: '', args: []);
  }

  /// `Add Policy Controls`
  String get addPolicyControls {
    return Intl.message(
      'Add Policy Controls',
      name: 'addPolicyControls',
      desc: '',
      args: [],
    );
  }

  /// `Add Product`
  String get addProduct {
    return Intl.message('Add Product', name: 'addProduct', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Address Details`
  String get addressDetails {
    return Intl.message(
      'Address Details',
      name: 'addressDetails',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: City is required`
  String get addressNumberCity {
    return Intl.message(
      'Address {0}: City is required',
      name: 'addressNumberCity',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: Country is required`
  String get addressNumberCountry {
    return Intl.message(
      'Address {0}: Country is required',
      name: 'addressNumberCountry',
      desc: '',
      args: [],
    );
  }

  /// `Address {0}: Postal Code is required`
  String get addressNumberPostalCode {
    return Intl.message(
      'Address {0}: Postal Code is required',
      name: 'addressNumberPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Address #{n}: state/province is required.`
  String addressNumberState(Object n) {
    return Intl.message(
      'Address #$n: state/province is required.',
      name: 'addressNumberState',
      desc: '',
      args: [n],
    );
  }

  /// `Address {0}: Street Name is required`
  String get addressNumberStreetName {
    return Intl.message(
      'Address {0}: Street Name is required',
      name: 'addressNumberStreetName',
      desc: '',
      args: [],
    );
  }

  /// `Add Service`
  String get addService {
    return Intl.message('Add Service', name: 'addService', desc: '', args: []);
  }

  /// `Add start date or switch off Schedule Publishing`
  String get addStartDateOrSwitchOffSchedulePublishing {
    return Intl.message(
      'Add start date or switch off Schedule Publishing',
      name: 'addStartDateOrSwitchOffSchedulePublishing',
      desc: '',
      args: [],
    );
  }

  /// `+ Storage`
  String get addStorage {
    return Intl.message('+ Storage', name: 'addStorage', desc: '', args: []);
  }

  /// `Add Supplier`
  String get addSupplier {
    return Intl.message(
      'Add Supplier',
      name: 'addSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Admin Dashboard`
  String get adminDashboard {
    return Intl.message(
      'Admin Dashboard',
      name: 'adminDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Admin Only`
  String get adminOnly {
    return Intl.message('Admin Only', name: 'adminOnly', desc: '', args: []);
  }

  /// `Admin-Only Access`
  String get adminOnlyAccess {
    return Intl.message(
      'Admin-Only Access',
      name: 'adminOnlyAccess',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Deposit`
  String get advancedDeposit {
    return Intl.message(
      'Advanced Deposit',
      name: 'advancedDeposit',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Payment`
  String get advancedPayment {
    return Intl.message(
      'Advanced Payment',
      name: 'advancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Afghan`
  String get afghan {
    return Intl.message('Afghan', name: 'afghan', desc: '', args: []);
  }

  /// `Aggregated`
  String get aggregated {
    return Intl.message('Aggregated', name: 'aggregated', desc: '', args: []);
  }

  /// `Ahmed`
  String get ahmed {
    return Intl.message('Ahmed', name: 'ahmed', desc: '', args: []);
  }

  /// `Ahmed Wael`
  String get ahmedWael {
    return Intl.message('Ahmed Wael', name: 'ahmedWael', desc: '', args: []);
  }

  /// `Airflow Inspection`
  String get airflowInspection {
    return Intl.message(
      'Airflow Inspection',
      name: 'airflowInspection',
      desc: '',
      args: [],
    );
  }

  /// `Albanian`
  String get albanian {
    return Intl.message('Albanian', name: 'albanian', desc: '', args: []);
  }

  /// `Algerian`
  String get algerian {
    return Intl.message('Algerian', name: 'algerian', desc: '', args: []);
  }

  /// `Ali`
  String get ali {
    return Intl.message('Ali', name: 'ali', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `All Departments`
  String get all_departments {
    return Intl.message(
      'All Departments',
      name: 'all_departments',
      desc: '',
      args: [],
    );
  }

  /// `All Services`
  String get all_services {
    return Intl.message(
      'All Services',
      name: 'all_services',
      desc: '',
      args: [],
    );
  }

  /// `All Day`
  String get allDay {
    return Intl.message('All Day', name: 'allDay', desc: '', args: []);
  }

  /// `All Departments`
  String get allDepartmentsLong {
    return Intl.message(
      'All Departments',
      name: 'allDepartmentsLong',
      desc: '',
      args: [],
    );
  }

  /// `All Notifications Cleared`
  String get allNotificationsCleared {
    return Intl.message(
      'All Notifications Cleared',
      name: 'allNotificationsCleared',
      desc: '',
      args: [],
    );
  }

  /// `All Notifications Deleted`
  String get allNotificationsDeleted {
    return Intl.message(
      'All Notifications Deleted',
      name: 'allNotificationsDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Allocated`
  String get allocated {
    return Intl.message('Allocated', name: 'allocated', desc: '', args: []);
  }

  /// `Allow Breaks in Attendance`
  String get allowBreaksInAttendance {
    return Intl.message(
      'Allow Breaks in Attendance',
      name: 'allowBreaksInAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Allow Different Work Locations`
  String get allowDifferentWorkLocations {
    return Intl.message(
      'Allow Different Work Locations',
      name: 'allowDifferentWorkLocations',
      desc: '',
      args: [],
    );
  }

  /// `Allow Geofence`
  String get allowGeofence {
    return Intl.message(
      'Allow Geofence',
      name: 'allowGeofence',
      desc: '',
      args: [],
    );
  }

  /// `Allow Multiple Answers`
  String get allowMultipleAnswers {
    return Intl.message(
      'Allow Multiple Answers',
      name: 'allowMultipleAnswers',
      desc: '',
      args: [],
    );
  }

  /// `Allow Pause`
  String get allowPause {
    return Intl.message('Allow Pause', name: 'allowPause', desc: '', args: []);
  }

  /// `Allows Removing Documents Owned By Anyone`
  String get allowsRemovingDocumentsOwnedByAnyone {
    return Intl.message(
      'Allows Removing Documents Owned By Anyone',
      name: 'allowsRemovingDocumentsOwnedByAnyone',
      desc: '',
      args: [],
    );
  }

  /// `ALL RIGHTS RESERVED`
  String get allRIGHTSRESERVED {
    return Intl.message(
      'ALL RIGHTS RESERVED',
      name: 'allRIGHTSRESERVED',
      desc: '',
      args: [],
    );
  }

  /// `Already exists and selected`
  String get alreadyExistsAndSelected {
    return Intl.message(
      'Already exists and selected',
      name: 'alreadyExistsAndSelected',
      desc: '',
      args: [],
    );
  }

  /// `Also delete media received in this chat from the device gallery`
  String get alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery {
    return Intl.message(
      'Also delete media received in this chat from the device gallery',
      name: 'alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery',
      desc: '',
      args: [],
    );
  }

  /// `AM`
  String get am {
    return Intl.message('AM', name: 'am', desc: '', args: []);
  }

  /// `Ambient Storage`
  String get ambientStorage {
    return Intl.message(
      'Ambient Storage',
      name: 'ambientStorage',
      desc: '',
      args: [],
    );
  }

  /// `American`
  String get american {
    return Intl.message('American', name: 'american', desc: '', args: []);
  }

  /// `Amro Handousa`
  String get amroHandousa {
    return Intl.message(
      'Amro Handousa',
      name: 'amroHandousa',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get analytics {
    return Intl.message('Analytics', name: 'analytics', desc: '', args: []);
  }

  /// `And`
  String get and {
    return Intl.message('And', name: 'and', desc: '', args: []);
  }

  /// `Andorran`
  String get andorran {
    return Intl.message('Andorran', name: 'andorran', desc: '', args: []);
  }

  /// `An error occurred while processing your request.`
  String get anErrorOccurred {
    return Intl.message(
      'An error occurred while processing your request.',
      name: 'anErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during login. Please try again.`
  String get anErrorOccurredDuringLoginPleaseTryAgain {
    return Intl.message(
      'An error occurred during login. Please try again.',
      name: 'anErrorOccurredDuringLoginPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Angle`
  String get angle {
    return Intl.message('Angle', name: 'angle', desc: '', args: []);
  }

  /// `Angolan`
  String get angolan {
    return Intl.message('Angolan', name: 'angolan', desc: '', args: []);
  }

  /// `Animation`
  String get animation {
    return Intl.message('Animation', name: 'animation', desc: '', args: []);
  }

  /// `Annually`
  String get annually {
    return Intl.message('Annually', name: 'annually', desc: '', args: []);
  }

  /// `Annual Vacation`
  String get annualVacation {
    return Intl.message(
      'Annual Vacation',
      name: 'annualVacation',
      desc: '',
      args: [],
    );
  }

  /// `Antiguans`
  String get antiguans {
    return Intl.message('Antiguans', name: 'antiguans', desc: '', args: []);
  }

  /// `Applied Controls`
  String get appliedControls {
    return Intl.message(
      'Applied Controls',
      name: 'appliedControls',
      desc: '',
      args: [],
    );
  }

  /// `Applied Policies`
  String get appliedPolicies {
    return Intl.message(
      'Applied Policies',
      name: 'appliedPolicies',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get Apply {
    return Intl.message('Apply', name: 'Apply', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Apply Changes`
  String get applyChanges {
    return Intl.message(
      'Apply Changes',
      name: 'applyChanges',
      desc: '',
      args: [],
    );
  }

  /// `Approval`
  String get Approval {
    return Intl.message('Approval', name: 'Approval', desc: '', args: []);
  }

  /// `Approval`
  String get approval {
    return Intl.message('Approval', name: 'approval', desc: '', args: []);
  }

  /// `Approval Request Details`
  String get approval_request_details {
    return Intl.message(
      'Approval Request Details',
      name: 'approval_request_details',
      desc: '',
      args: [],
    );
  }

  /// `Approval Cycle`
  String get approvalCycle {
    return Intl.message(
      'Approval Cycle',
      name: 'approvalCycle',
      desc: '',
      args: [],
    );
  }

  /// `Approval Justification`
  String get approvalJustification {
    return Intl.message(
      'Approval Justification',
      name: 'approvalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Approval Permissions`
  String get approvalPermissions {
    return Intl.message(
      'Approval Permissions',
      name: 'approvalPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Approval Permissions Module`
  String get approvalPermissionsModule {
    return Intl.message(
      'Approval Permissions Module',
      name: 'approvalPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Approvals`
  String get approvals {
    return Intl.message('Approvals', name: 'approvals', desc: '', args: []);
  }

  /// `Approve`
  String get Approve {
    return Intl.message('Approve', name: 'Approve', desc: '', args: []);
  }

  /// `Approve`
  String get approve {
    return Intl.message('Approve', name: 'approve', desc: '', args: []);
  }

  /// `Approve And Reject`
  String get approveAndReject {
    return Intl.message(
      'Approve And Reject',
      name: 'approveAndReject',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get Approved {
    return Intl.message('Approved', name: 'Approved', desc: '', args: []);
  }

  /// `Approved`
  String get approved {
    return Intl.message('Approved', name: 'approved', desc: '', args: []);
  }

  /// `Approved And Rejected`
  String get approvedAndRejected {
    return Intl.message(
      'Approved And Rejected',
      name: 'approvedAndRejected',
      desc: '',
      args: [],
    );
  }

  /// `Approved And Rejected Request`
  String get approvedAndRejectedRequest {
    return Intl.message(
      'Approved And Rejected Request',
      name: 'approvedAndRejectedRequest',
      desc: '',
      args: [],
    );
  }

  /// `Approved Evidence`
  String get approvedEvidence {
    return Intl.message(
      'Approved Evidence',
      name: 'approvedEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Approved Only`
  String get approvedOnly {
    return Intl.message(
      'Approved Only',
      name: 'approvedOnly',
      desc: '',
      args: [],
    );
  }

  /// `Approve Evidence`
  String get approveEvidence {
    return Intl.message(
      'Approve Evidence',
      name: 'approveEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Approve Leave Requests`
  String get approveLeaveRequests {
    return Intl.message(
      'Approve Leave Requests',
      name: 'approveLeaveRequests',
      desc: '',
      args: [],
    );
  }

  /// `Approve Request`
  String get ApproveRequest {
    return Intl.message(
      'Approve Request',
      name: 'ApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Approve Request`
  String get approveRequest {
    return Intl.message(
      'Approve Request',
      name: 'approveRequest',
      desc: '',
      args: [],
    );
  }

  /// `App Theme`
  String get appTheme {
    return Intl.message('App Theme', name: 'appTheme', desc: '', args: []);
  }

  /// `Apr`
  String get apr {
    return Intl.message('Apr', name: 'apr', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `Arabic Department Name Missing`
  String get arabicDepartmentNameMissing {
    return Intl.message(
      'Arabic Department Name Missing',
      name: 'arabicDepartmentNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic First Name Missing`
  String get arabicFirstNameMissing {
    return Intl.message(
      'Arabic First Name Missing',
      name: 'arabicFirstNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Job Title Required`
  String get arabicJobTitleRequired {
    return Intl.message(
      'Arabic Job Title Required',
      name: 'arabicJobTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Language Mandatory`
  String get arabicLanguageMandatory {
    return Intl.message(
      'Arabic Language Mandatory',
      name: 'arabicLanguageMandatory',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Last Name Missing`
  String get arabicLastNameMissing {
    return Intl.message(
      'Arabic Last Name Missing',
      name: 'arabicLastNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Middle Name Missing`
  String get arabicMiddleNameMissing {
    return Intl.message(
      'Arabic Middle Name Missing',
      name: 'arabicMiddleNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic not allowed`
  String get arabicNotAllowed {
    return Intl.message(
      'Arabic not allowed',
      name: 'arabicNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Arabic letters only`
  String get arabicOnly {
    return Intl.message(
      'Arabic letters only',
      name: 'arabicOnly',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get archive {
    return Intl.message('Archived', name: 'archive', desc: '', args: []);
  }

  /// `Archived`
  String get archived {
    return Intl.message('Archived', name: 'archived', desc: '', args: []);
  }

  /// `Archive Date`
  String get archiveDate {
    return Intl.message(
      'Archive Date',
      name: 'archiveDate',
      desc: '',
      args: [],
    );
  }

  /// `Archive Room`
  String get archiveRoom {
    return Intl.message(
      'Archive Room',
      name: 'archiveRoom',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Submit For Approval?`
  String get are_you_sure_submit {
    return Intl.message(
      'Are You Sure You Want To Submit For Approval?',
      name: 'are_you_sure_submit',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Submit This Request?`
  String get are_you_sure_submit_request {
    return Intl.message(
      'Are You Sure You Want To Submit This Request?',
      name: 'are_you_sure_submit_request',
      desc: '',
      args: [],
    );
  }

  /// `Area`
  String get area {
    return Intl.message('Area', name: 'area', desc: '', args: []);
  }

  /// `Area is required`
  String get areaRequired {
    return Intl.message(
      'Area is required',
      name: 'areaRequired',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate These Services?`
  String get areYouSureActivate {
    return Intl.message(
      'Are You Sure You Want To Activate These Services?',
      name: 'areYouSureActivate',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these requests?`
  String get areYouSureActivateRequests {
    return Intl.message(
      'Are you sure you want to activate these requests?',
      name: 'areYouSureActivateRequests',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this order`
  String get areYouSureAddingOrder {
    return Intl.message(
      'Are you sure you want to add this order',
      name: 'areYouSureAddingOrder',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Add This Supplier?`
  String get areYouSureAddSupplier {
    return Intl.message(
      'Are You Sure You Want To Add This Supplier?',
      name: 'areYouSureAddSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Approve This Request?`
  String get areYouSureApproveRequest {
    return Intl.message(
      'Are You Sure You Want To Approve This Request?',
      name: 'areYouSureApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want to Cancel This Request ?`
  String get areYouSureCancelRequest {
    return Intl.message(
      'Are You Sure You Want to Cancel This Request ?',
      name: 'areYouSureCancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Inactive The Request Type?`
  String get areYouSureChangeStatus {
    return Intl.message(
      'Are You Sure You Want To Inactive The Request Type?',
      name: 'areYouSureChangeStatus',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to complete this draft role?`
  String get areYouSureCompleteDraftRole {
    return Intl.message(
      'Are you sure you want to complete this draft role?',
      name: 'areYouSureCompleteDraftRole',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Module?`
  String get areYouSureCreate {
    return Intl.message(
      'Are You Sure You Want To Create This Module?',
      name: 'areYouSureCreate',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Location ?`
  String get areYouSureCreateLocation {
    return Intl.message(
      'Are You Sure You Want To Create This Location ?',
      name: 'areYouSureCreateLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this role?`
  String get areYouSureCreateRole {
    return Intl.message(
      'Are you sure you want to create this role?',
      name: 'areYouSureCreateRole',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Service?`
  String get areYouSureCreateService {
    return Intl.message(
      'Are You Sure You Want To Create This Service?',
      name: 'areYouSureCreateService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request ?`
  String get areYouSureCreatingRequest {
    return Intl.message(
      'Are You Sure You Want To Create This Request ?',
      name: 'areYouSureCreatingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request ?`
  String get areYouSureCreatingRequestType {
    return Intl.message(
      'Are You Sure You Want To Create This Request ?',
      name: 'areYouSureCreatingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Transaction ?`
  String get areYouSureCreatingTransaction {
    return Intl.message(
      'Are You Sure You Want To Create This Transaction ?',
      name: 'areYouSureCreatingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This GRC Module?`
  String get areYouSureDelete {
    return Intl.message(
      'Are You Sure You Want To Delete This GRC Module?',
      name: 'areYouSureDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete all cleared notifications? This cannot be undone.`
  String get areYouSureDeleteAllCleared {
    return Intl.message(
      'Are you sure you want to permanently delete all cleared notifications? This cannot be undone.',
      name: 'areYouSureDeleteAllCleared',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Control?`
  String get areYouSureDeleteControl {
    return Intl.message(
      'Are You Sure You Want To Delete This Control?',
      name: 'areYouSureDeleteControl',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Form?`
  String get areYouSureDeleteForm {
    return Intl.message(
      'Are You Sure You Want To Delete This Form?',
      name: 'areYouSureDeleteForm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Group?`
  String get areYouSureDeleteGroup {
    return Intl.message(
      'Are You Sure You Want To Delete This Group?',
      name: 'areYouSureDeleteGroup',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this knowledge?`
  String get areYouSureDeleteKnowledge {
    return Intl.message(
      'Are you sure you want to delete this knowledge?',
      name: 'areYouSureDeleteKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Location ?`
  String get areYouSureDeleteLocation {
    return Intl.message(
      'Are You Sure You Want To Delete This Location ?',
      name: 'areYouSureDeleteLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Request Type ?`
  String get areYouSureDeleteRequestType {
    return Intl.message(
      'Are You Sure You Want To Delete This Request Type ?',
      name: 'areYouSureDeleteRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this row?`
  String get areYouSureDeleteRow {
    return Intl.message(
      'Are you sure you want to delete this row?',
      name: 'areYouSureDeleteRow',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure Delete This Service`
  String get AreYouSureDeleteThisService {
    return Intl.message(
      'Are You Sure Delete This Service',
      name: 'AreYouSureDeleteThisService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Disable The Module?`
  String get areYouSureDisable {
    return Intl.message(
      'Are You Sure You Want To Disable The Module?',
      name: 'areYouSureDisable',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to download this page`
  String get areYouSureDownloadPage {
    return Intl.message(
      'Are you sure you want to download this page',
      name: 'areYouSureDownloadPage',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Module?`
  String get areYouSureEdit {
    return Intl.message(
      'Are You Sure You Want To Edit This Module?',
      name: 'areYouSureEdit',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Group ?`
  String get areYouSureEditGroup {
    return Intl.message(
      'Are You Sure You Want To Edit This Group ?',
      name: 'areYouSureEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Location ?`
  String get areYouSureEditLocation {
    return Intl.message(
      'Are You Sure You Want To Edit This Location ?',
      name: 'areYouSureEditLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this product?`
  String get areYouSureEditProduct {
    return Intl.message(
      'Are you sure you want to edit this product?',
      name: 'areYouSureEditProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Request Type ?`
  String get areYouSureEditRequestType {
    return Intl.message(
      'Are You Sure You Want To Edit This Request Type ?',
      name: 'areYouSureEditRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this role?`
  String get areYouSureEditRole {
    return Intl.message(
      'Are you sure you want to edit this role?',
      name: 'areYouSureEditRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this service?`
  String get areYouSureEditService {
    return Intl.message(
      'Are you sure you want to edit this service?',
      name: 'areYouSureEditService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Restore The Module?`
  String get areYouSureRestore {
    return Intl.message(
      'Are You Sure You Want To Restore The Module?',
      name: 'areYouSureRestore',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the image?`
  String get areYouSureToDeleteImage {
    return Intl.message(
      'Are you sure you want to delete the image?',
      name: 'areYouSureToDeleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disable the service?`
  String get areYouSureToDisableService {
    return Intl.message(
      'Are you sure you want to disable the service?',
      name: 'areYouSureToDisableService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure To Proceed`
  String get areYouSureToProceed {
    return Intl.message(
      'Are You Sure To Proceed',
      name: 'areYouSureToProceed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to request this asset?`
  String get areYouSureToRequestAsset {
    return Intl.message(
      'Are you sure you want to request this asset?',
      name: 'areYouSureToRequestAsset',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these assignments?`
  String get areYouSureYouWantToActivateTheseAssignments {
    return Intl.message(
      'Are you sure you want to activate these assignments?',
      name: 'areYouSureYouWantToActivateTheseAssignments',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate these policies?`
  String get areYouSureYouWantToActivateThesePolicies {
    return Intl.message(
      'Are you sure you want to activate these policies?',
      name: 'areYouSureYouWantToActivateThesePolicies',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate These Services?`
  String get areYouSureYouWantToActivateTheseServices {
    return Intl.message(
      'Are You Sure You Want To Activate These Services?',
      name: 'areYouSureYouWantToActivateTheseServices',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate This Account?`
  String get areYouSureYouWantToActivateThisAccount {
    return Intl.message(
      'Are You Sure You Want To Activate This Account?',
      name: 'areYouSureYouWantToActivateThisAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate this role?`
  String get areYouSureYouWantToActivateThisRole {
    return Intl.message(
      'Are you sure you want to activate this role?',
      name: 'areYouSureYouWantToActivateThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this control champion?`
  String get areYouSureYouWantToAddThisControlChampion {
    return Intl.message(
      'Are you sure you want to add this control champion?',
      name: 'areYouSureYouWantToAddThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this control owner?`
  String get areYouSureYouWantToAddThisControlOwner {
    return Intl.message(
      'Are you sure you want to add this control owner?',
      name: 'areYouSureYouWantToAddThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add this product?`
  String get areYouSureYouWantToAddThisProduct {
    return Intl.message(
      'Are you sure you want to add this product?',
      name: 'areYouSureYouWantToAddThisProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get areYouSureYouWantToApproveRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'areYouSureYouWantToApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this evidence?`
  String get areYouSureYouWantToApproveThisEvidence {
    return Intl.message(
      'Are you sure you want to approve this evidence?',
      name: 'areYouSureYouWantToApproveThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get AreYouSureYouWantToApproveThisRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'AreYouSureYouWantToApproveThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to approve this request?`
  String get areYouSureYouWantToApproveThisRequest {
    return Intl.message(
      'Are you sure you want to approve this request?',
      name: 'areYouSureYouWantToApproveThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this request?`
  String get AreYousureYouWanttoCancelThisRequest {
    return Intl.message(
      'Are you sure you want to cancel this request?',
      name: 'AreYousureYouWanttoCancelThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change the status of this module?`
  String get areYouSureYouWantToChangeTheStatusOfThisModule {
    return Intl.message(
      'Are you sure you want to change the status of this module?',
      name: 'areYouSureYouWantToChangeTheStatusOfThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change this status`
  String get Areyousureyouwanttochangethisstatus {
    return Intl.message(
      'Are you sure you want to change this status',
      name: 'Areyousureyouwanttochangethisstatus',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Clean All ?`
  String get areYouSureYouWantToCleanAll {
    return Intl.message(
      'Are You Sure You Want To Clean All ?',
      name: 'areYouSureYouWantToCleanAll',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this control?`
  String get areYouSureYouWantToCreateThisControl {
    return Intl.message(
      'Are you sure you want to create this control?',
      name: 'areYouSureYouWantToCreateThisControl',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this module?`
  String get areYouSureYouWantToCreateThisModule {
    return Intl.message(
      'Are you sure you want to create this module?',
      name: 'areYouSureYouWantToCreateThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this policy?`
  String get areYouSureYouWantToCreateThisPolicy {
    return Intl.message(
      'Are you sure you want to create this policy?',
      name: 'areYouSureYouWantToCreateThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request Type?`
  String get areYouSureYouWantToCreateThisRequestType {
    return Intl.message(
      'Are You Sure You Want To Create This Request Type?',
      name: 'areYouSureYouWantToCreateThisRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Deactivate This Account?`
  String get areYouSureYouWantToDeactivateThisAccount {
    return Intl.message(
      'Are You Sure You Want To Deactivate This Account?',
      name: 'areYouSureYouWantToDeactivateThisAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to deactivate this role?`
  String get areYouSureYouWantToDeactivateThisRole {
    return Intl.message(
      'Are you sure you want to deactivate this role?',
      name: 'areYouSureYouWantToDeactivateThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this GRC module?`
  String get areYouSureYouWantToDeleteThisGrcModule {
    return Intl.message(
      'Are you sure you want to delete this GRC module?',
      name: 'areYouSureYouWantToDeleteThisGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this message?`
  String get AreYousureYouWanttoDeleteThisMessage {
    return Intl.message(
      'Are you sure you want to delete this message?',
      name: 'AreYousureYouWanttoDeleteThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this role?`
  String get areYouSureYouWantToDeleteThisRole {
    return Intl.message(
      'Are you sure you want to delete this role?',
      name: 'areYouSureYouWantToDeleteThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this row?`
  String get areYouSureYouWantToDeleteThisRow {
    return Intl.message(
      'Are you sure you want to delete this row?',
      name: 'areYouSureYouWantToDeleteThisRow',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to discard this policy?`
  String get areYouSureYouWantToDiscardThisPolicy {
    return Intl.message(
      'Are you sure you want to discard this policy?',
      name: 'areYouSureYouWantToDiscardThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit controls weight?`
  String get areYouSureYouWantToEditControlsWeight {
    return Intl.message(
      'Are you sure you want to edit controls weight?',
      name: 'areYouSureYouWantToEditControlsWeight',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit policies weight?`
  String get areYouSureYouWantToEditPoliciesWeight {
    return Intl.message(
      'Are you sure you want to edit policies weight?',
      name: 'areYouSureYouWantToEditPoliciesWeight',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this control?`
  String get areYouSureYouWantToEditThisControl {
    return Intl.message(
      'Are you sure you want to edit this control?',
      name: 'areYouSureYouWantToEditThisControl',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this module?`
  String get areYouSureYouWantToEditThisModule {
    return Intl.message(
      'Are you sure you want to edit this module?',
      name: 'areYouSureYouWantToEditThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this policy?`
  String get areYouSureYouWantToEditThisPolicy {
    return Intl.message(
      'Are you sure you want to edit this policy?',
      name: 'areYouSureYouWantToEditThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to proceed with assigning equal weight to all controls?`
  String get areYouSureYouWantToProceedWithAssigningEqualWeightToAllControls {
    return Intl.message(
      'Are you sure you want to proceed with assigning equal weight to all controls?',
      name: 'areYouSureYouWantToProceedWithAssigningEqualWeightToAllControls',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to publish this policy?`
  String get areYouSureYouWantToPublishThisPolicy {
    return Intl.message(
      'Are you sure you want to publish this policy?',
      name: 'areYouSureYouWantToPublishThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get areYouSureYouWantToRejectRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'areYouSureYouWantToRejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this document?`
  String get areYouSureYouWantToRejectThisDocument {
    return Intl.message(
      'Are you sure you want to reject this document?',
      name: 'areYouSureYouWantToRejectThisDocument',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this evidence?`
  String get areYouSureYouWantToRejectThisEvidence {
    return Intl.message(
      'Are you sure you want to reject this evidence?',
      name: 'areYouSureYouWantToRejectThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get AreYouSureYouWantToRejectThisRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'AreYouSureYouWantToRejectThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reject this request?`
  String get areYouSureYouWantToRejectThisRequest {
    return Intl.message(
      'Are you sure you want to reject this request?',
      name: 'areYouSureYouWantToRejectThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this document?`
  String get areYouSureYouWantToRemoveDocument {
    return Intl.message(
      'Are you sure you want to remove this document?',
      name: 'areYouSureYouWantToRemoveDocument',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this access?`
  String get areYouSureYouWantToRemoveThisAccess {
    return Intl.message(
      'Are you sure you want to remove this access?',
      name: 'areYouSureYouWantToRemoveThisAccess',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this control champion?`
  String get areYouSureYouWantToRemoveThisControlChampion {
    return Intl.message(
      'Are you sure you want to remove this control champion?',
      name: 'areYouSureYouWantToRemoveThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this control owner?`
  String get areYouSureYouWantToRemoveThisControlOwner {
    return Intl.message(
      'Are you sure you want to remove this control owner?',
      name: 'areYouSureYouWantToRemoveThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Remove This Employee?`
  String get areYouSureYouWantToRemoveThisEmployee {
    return Intl.message(
      'Are You Sure You Want To Remove This Employee?',
      name: 'areYouSureYouWantToRemoveThisEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to request this service?`
  String get AreYouSureYouWantToRequestThisService {
    return Intl.message(
      'Are you sure you want to request this service?',
      name: 'AreYouSureYouWantToRequestThisService',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reset The Company Branding?`
  String get areYouSureYouWantToResetTheCompanyBranding {
    return Intl.message(
      'Are You Sure You Want To Reset The Company Branding?',
      name: 'areYouSureYouWantToResetTheCompanyBranding',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reset Your Personal Branding To Company Defaults?`
  String get areYouSureYouWantToResetYourPersonalBrandingToCo {
    return Intl.message(
      'Are You Sure You Want To Reset Your Personal Branding To Company Defaults?',
      name: 'areYouSureYouWantToResetYourPersonalBrandingToCo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restore this module?`
  String get areYouSureYouWantToRestoreThisModule {
    return Intl.message(
      'Are you sure you want to restore this module?',
      name: 'areYouSureYouWantToRestoreThisModule',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to resubmit this document?`
  String get areYouSureYouWantToResubmit {
    return Intl.message(
      'Are you sure you want to resubmit this document?',
      name: 'areYouSureYouWantToResubmit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save as draft?`
  String get areYouSureYouWantToSaveAsDraft {
    return Intl.message(
      'Are you sure you want to save as draft?',
      name: 'areYouSureYouWantToSaveAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save these changes?`
  String get areYouSureYouWantToSaveTheseChanges {
    return Intl.message(
      'Are you sure you want to save these changes?',
      name: 'areYouSureYouWantToSaveTheseChanges',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this control as a draft?`
  String get areYouSureYouWantToSaveThisControlAsADraft {
    return Intl.message(
      'Are you sure you want to save this control as a draft?',
      name: 'areYouSureYouWantToSaveThisControlAsADraft',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this policy as a draft?`
  String get areYouSureYouWantToSaveThisPolicyAsADraft {
    return Intl.message(
      'Are you sure you want to save this policy as a draft?',
      name: 'areYouSureYouWantToSaveThisPolicyAsADraft',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to submit this evidence?`
  String get areYouSureYouWantToSubmitThisEvidence {
    return Intl.message(
      'Are you sure you want to submit this evidence?',
      name: 'areYouSureYouWantToSubmitThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to submit this reassignment request?`
  String get areYouSureYouWantToSubmitThisReassignmentRequest {
    return Intl.message(
      'Are you sure you want to submit this reassignment request?',
      name: 'areYouSureYouWantToSubmitThisReassignmentRequest',
      desc: '',
      args: [],
    );
  }

  /// `Argentinean`
  String get argentinean {
    return Intl.message('Argentinean', name: 'argentinean', desc: '', args: []);
  }

  /// `Armenian`
  String get armenian {
    return Intl.message('Armenian', name: 'armenian', desc: '', args: []);
  }

  /// `ASC`
  String get asc {
    return Intl.message('ASC', name: 'asc', desc: '', args: []);
  }

  /// `Ascending`
  String get ascending {
    return Intl.message('Ascending', name: 'ascending', desc: '', args: []);
  }

  /// `Ask a Question`
  String get askAQuestion {
    return Intl.message(
      'Ask a Question',
      name: 'askAQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Asset`
  String get asset {
    return Intl.message('Asset', name: 'asset', desc: '', args: []);
  }

  /// `Asset Conditions`
  String get assetConditions {
    return Intl.message(
      'Asset Conditions',
      name: 'assetConditions',
      desc: '',
      args: [],
    );
  }

  /// `Asset Details`
  String get assetDetails {
    return Intl.message(
      'Asset Details',
      name: 'assetDetails',
      desc: '',
      args: [],
    );
  }

  /// `Asset Id`
  String get assetId {
    return Intl.message('Asset Id', name: 'assetId', desc: '', args: []);
  }

  /// `Asset Missing`
  String get assetMissing {
    return Intl.message(
      'Asset Missing',
      name: 'assetMissing',
      desc: '',
      args: [],
    );
  }

  /// `Asset Repair`
  String get assetRepair {
    return Intl.message(
      'Asset Repair',
      name: 'assetRepair',
      desc: '',
      args: [],
    );
  }

  /// `Asset Request`
  String get assetRequest {
    return Intl.message(
      'Asset Request',
      name: 'assetRequest',
      desc: '',
      args: [],
    );
  }

  /// `Asset Requested`
  String get assetRequested {
    return Intl.message(
      'Asset Requested',
      name: 'assetRequested',
      desc: '',
      args: [],
    );
  }

  /// `Asset Return`
  String get assetReturn {
    return Intl.message(
      'Asset Return',
      name: 'assetReturn',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get assets {
    return Intl.message('Assets', name: 'assets', desc: '', args: []);
  }

  /// `Assets Assigned`
  String get assetsAssigned {
    return Intl.message(
      'Assets Assigned',
      name: 'assetsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Assets Name`
  String get assetsName {
    return Intl.message('Assets Name', name: 'assetsName', desc: '', args: []);
  }

  /// `Assets Name Details`
  String get assetsNameDetails {
    return Intl.message(
      'Assets Name Details',
      name: 'assetsNameDetails',
      desc: '',
      args: [],
    );
  }

  /// `Asset Stolen`
  String get assetStolen {
    return Intl.message(
      'Asset Stolen',
      name: 'assetStolen',
      desc: '',
      args: [],
    );
  }

  /// `Assets Under Maintenance`
  String get assetsUnderMaintenance {
    return Intl.message(
      'Assets Under Maintenance',
      name: 'assetsUnderMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Assign`
  String get assign {
    return Intl.message('Assign', name: 'assign', desc: '', args: []);
  }

  /// `Assign Control`
  String get assignControl {
    return Intl.message(
      'Assign Control',
      name: 'assignControl',
      desc: '',
      args: [],
    );
  }

  /// `Assign Date`
  String get assignDate {
    return Intl.message('Assign Date', name: 'assignDate', desc: '', args: []);
  }

  /// `Assigned`
  String get assigned {
    return Intl.message('Assigned', name: 'assigned', desc: '', args: []);
  }

  /// `Assigned By`
  String get assignedBy {
    return Intl.message('Assigned By', name: 'assignedBy', desc: '', args: []);
  }

  /// `Assigned Controls`
  String get assignedControls {
    return Intl.message(
      'Assigned Controls',
      name: 'assignedControls',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Date`
  String get assignedDate {
    return Intl.message(
      'Assigned Date',
      name: 'assignedDate',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Department`
  String get assignedDepartment {
    return Intl.message(
      'Assigned Department',
      name: 'assignedDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Department is required`
  String get assignedDepartmentRequired {
    return Intl.message(
      'Assigned Department is required',
      name: 'assignedDepartmentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Employees`
  String get assignedEmployees {
    return Intl.message(
      'Assigned Employees',
      name: 'assignedEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Assigned To`
  String get assignedTo {
    return Intl.message('Assigned To', name: 'assignedTo', desc: '', args: []);
  }

  /// `Assignees Created`
  String get assigneesCreated {
    return Intl.message(
      'Assignees Created',
      name: 'assigneesCreated',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Asset`
  String get assigningAsset {
    return Intl.message(
      'Assigning Asset',
      name: 'assigningAsset',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Assets`
  String get assigningAssets {
    return Intl.message(
      'Assigning Assets',
      name: 'assigningAssets',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Control`
  String get assigningControl {
    return Intl.message(
      'Assigning Control',
      name: 'assigningControl',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Controls`
  String get assigningControls {
    return Intl.message(
      'Assigning Controls',
      name: 'assigningControls',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Details`
  String get assigningDetails {
    return Intl.message(
      'Assigning Details',
      name: 'assigningDetails',
      desc: '',
      args: [],
    );
  }

  /// `Assigning History`
  String get assigningHistory {
    return Intl.message(
      'Assigning History',
      name: 'assigningHistory',
      desc: '',
      args: [],
    );
  }

  /// `Assigning Product`
  String get assigningProduct {
    return Intl.message(
      'Assigning Product',
      name: 'assigningProduct',
      desc: '',
      args: [],
    );
  }

  /// `Assign Lead`
  String get assignLead {
    return Intl.message('Assign Lead', name: 'assignLead', desc: '', args: []);
  }

  /// `Assignment Controls`
  String get assignmentControls {
    return Intl.message(
      'Assignment Controls',
      name: 'assignmentControls',
      desc: '',
      args: [],
    );
  }

  /// `Assignment Date`
  String get assignmentDate {
    return Intl.message(
      'Assignment Date',
      name: 'assignmentDate',
      desc: '',
      args: [],
    );
  }

  /// `At`
  String get at {
    return Intl.message('At', name: 'at', desc: '', args: []);
  }

  /// `Please select at least one employee`
  String get atLeastOneEmployeeRequired {
    return Intl.message(
      'Please select at least one employee',
      name: 'atLeastOneEmployeeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Attach Document`
  String get attach_document {
    return Intl.message(
      'Attach Document',
      name: 'attach_document',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachments {
    return Intl.message('Attachments', name: 'attachments', desc: '', args: []);
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `Attendance Date`
  String get attendanceDate {
    return Intl.message(
      'Attendance Date',
      name: 'attendanceDate',
      desc: '',
      args: [],
    );
  }

  /// `Attention`
  String get attention {
    return Intl.message('Attention', name: 'attention', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `Aug`
  String get aug {
    return Intl.message('Aug', name: 'aug', desc: '', args: []);
  }

  /// `Australian`
  String get australian {
    return Intl.message('Australian', name: 'australian', desc: '', args: []);
  }

  /// `Austrian`
  String get austrian {
    return Intl.message('Austrian', name: 'austrian', desc: '', args: []);
  }

  /// `Authentication Error`
  String get authenticationError {
    return Intl.message(
      'Authentication Error',
      name: 'authenticationError',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Failed`
  String get authenticationFailed {
    return Intl.message(
      'Authentication Failed',
      name: 'authenticationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Authorized Personnel Only`
  String get authorizedPersonnelOnly {
    return Intl.message(
      'Authorized Personnel Only',
      name: 'authorizedPersonnelOnly',
      desc: '',
      args: [],
    );
  }

  /// `Automatic IDs`
  String get automaticIDs {
    return Intl.message(
      'Automatic IDs',
      name: 'automaticIDs',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message('Available', name: 'available', desc: '', args: []);
  }

  /// `Azerbaijani`
  String get azerbaijani {
    return Intl.message('Azerbaijani', name: 'azerbaijani', desc: '', args: []);
  }

  /// `Bachelor's Degree`
  String get bachelorDegree {
    return Intl.message(
      'Bachelor\'s Degree',
      name: 'bachelorDegree',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Bahamian`
  String get bahamian {
    return Intl.message('Bahamian', name: 'bahamian', desc: '', args: []);
  }

  /// `Bahraini`
  String get bahraini {
    return Intl.message('Bahraini', name: 'bahraini', desc: '', args: []);
  }

  /// `Bangladeshi`
  String get bangladeshi {
    return Intl.message('Bangladeshi', name: 'bangladeshi', desc: '', args: []);
  }

  /// `Bank Address`
  String get bankAddress {
    return Intl.message(
      'Bank Address',
      name: 'bankAddress',
      desc: '',
      args: [],
    );
  }

  /// `Bank Address is required`
  String get bankAddressRequired {
    return Intl.message(
      'Bank Address is required',
      name: 'bankAddressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Bank Transfer Details`
  String get bankTransferDetails {
    return Intl.message(
      'Bank Transfer Details',
      name: 'bankTransferDetails',
      desc: '',
      args: [],
    );
  }

  /// `Barbadian`
  String get barbadian {
    return Intl.message('Barbadian', name: 'barbadian', desc: '', args: []);
  }

  /// `Barbudans`
  String get barbudans {
    return Intl.message('Barbudans', name: 'barbudans', desc: '', args: []);
  }

  /// `Baseline`
  String get baseline {
    return Intl.message('Baseline', name: 'baseline', desc: '', args: []);
  }

  /// `Baseline Color`
  String get baselineColor {
    return Intl.message(
      'Baseline Color',
      name: 'baselineColor',
      desc: '',
      args: [],
    );
  }

  /// `Baseline`
  String get basline {
    return Intl.message('Baseline', name: 'basline', desc: '', args: []);
  }

  /// `Batch`
  String get batch {
    return Intl.message('Batch', name: 'batch', desc: '', args: []);
  }

  /// `Batch created`
  String get batchCreated {
    return Intl.message(
      'Batch created',
      name: 'batchCreated',
      desc: '',
      args: [],
    );
  }

  /// `Batch created successfully`
  String get batchCreatedSuccess {
    return Intl.message(
      'Batch created successfully',
      name: 'batchCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Batch ID`
  String get batchId {
    return Intl.message('Batch ID', name: 'batchId', desc: '', args: []);
  }

  /// `Batswana`
  String get batswana {
    return Intl.message('Batswana', name: 'batswana', desc: '', args: []);
  }

  /// `Beginner`
  String get beginner {
    return Intl.message('Beginner', name: 'beginner', desc: '', args: []);
  }

  /// `Begins in 30m`
  String get beginsIn30m {
    return Intl.message(
      'Begins in 30m',
      name: 'beginsIn30m',
      desc: '',
      args: [],
    );
  }

  /// `Belarusian`
  String get belarusian {
    return Intl.message('Belarusian', name: 'belarusian', desc: '', args: []);
  }

  /// `Belgian`
  String get belgian {
    return Intl.message('Belgian', name: 'belgian', desc: '', args: []);
  }

  /// `Belizean`
  String get belizean {
    return Intl.message('Belizean', name: 'belizean', desc: '', args: []);
  }

  /// `Below Baseline Color`
  String get belowBaselineColor {
    return Intl.message(
      'Below Baseline Color',
      name: 'belowBaselineColor',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Bank Name`
  String get beneficiaryBankName {
    return Intl.message(
      'Beneficiary Bank Name',
      name: 'beneficiaryBankName',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Bank Name is required`
  String get beneficiaryBankNameRequired {
    return Intl.message(
      'Beneficiary Bank Name is required',
      name: 'beneficiaryBankNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Name`
  String get beneficiaryName {
    return Intl.message(
      'Beneficiary Name',
      name: 'beneficiaryName',
      desc: '',
      args: [],
    );
  }

  /// `Beneficiary Name is required`
  String get beneficiaryNameRequired {
    return Intl.message(
      'Beneficiary Name is required',
      name: 'beneficiaryNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Beninese`
  String get beninese {
    return Intl.message('Beninese', name: 'beninese', desc: '', args: []);
  }

  /// `Bhutanese`
  String get bhutanese {
    return Intl.message('Bhutanese', name: 'bhutanese', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Biometrics`
  String get biometrics {
    return Intl.message('Biometrics', name: 'biometrics', desc: '', args: []);
  }

  /// `Biometrics For Login`
  String get biometricsForLogin {
    return Intl.message(
      'Biometrics For Login',
      name: 'biometricsForLogin',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Birth Vacation`
  String get birthVacation {
    return Intl.message(
      'Birth Vacation',
      name: 'birthVacation',
      desc: '',
      args: [],
    );
  }

  /// `Bi weekly`
  String get biWeekly {
    return Intl.message('Bi weekly', name: 'biWeekly', desc: '', args: []);
  }

  /// `Blue`
  String get blue {
    return Intl.message('Blue', name: 'blue', desc: '', args: []);
  }

  /// `Body`
  String get body {
    return Intl.message('Body', name: 'body', desc: '', args: []);
  }

  /// `Bolivian`
  String get bolivian {
    return Intl.message('Bolivian', name: 'bolivian', desc: '', args: []);
  }

  /// `Booklet`
  String get booklet {
    return Intl.message('Booklet', name: 'booklet', desc: '', args: []);
  }

  /// `Bosnian`
  String get bosnian {
    return Intl.message('Bosnian', name: 'bosnian', desc: '', args: []);
  }

  /// `Branch`
  String get branch {
    return Intl.message('Branch', name: 'branch', desc: '', args: []);
  }

  /// `Branch Name`
  String get branchName {
    return Intl.message('Branch Name', name: 'branchName', desc: '', args: []);
  }

  /// `Branch Name is required`
  String get branchNameRequired {
    return Intl.message(
      'Branch Name is required',
      name: 'branchNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get brand {
    return Intl.message('Brand', name: 'brand', desc: '', args: []);
  }

  /// `Branding & Theme`
  String get brandingAndTheme {
    return Intl.message(
      'Branding & Theme',
      name: 'brandingAndTheme',
      desc: '',
      args: [],
    );
  }

  /// `Branding`
  String get brandingPermission {
    return Intl.message(
      'Branding',
      name: 'brandingPermission',
      desc: '',
      args: [],
    );
  }

  /// `Brazilian`
  String get brazilian {
    return Intl.message('Brazilian', name: 'brazilian', desc: '', args: []);
  }

  /// `Breached SLA`
  String get BreachedSLA {
    return Intl.message(
      'Breached SLA',
      name: 'BreachedSLA',
      desc: '',
      args: [],
    );
  }

  /// `Break`
  String get breakKey {
    return Intl.message('Break', name: 'breakKey', desc: '', args: []);
  }

  /// `Break Time`
  String get breakTime {
    return Intl.message('Break Time', name: 'breakTime', desc: '', args: []);
  }

  /// `British`
  String get british {
    return Intl.message('British', name: 'british', desc: '', args: []);
  }

  /// `Browse Files`
  String get browseFiles {
    return Intl.message(
      'Browse Files',
      name: 'browseFiles',
      desc: '',
      args: [],
    );
  }

  /// `Bruneian`
  String get bruneian {
    return Intl.message('Bruneian', name: 'bruneian', desc: '', args: []);
  }

  /// `Building / Apartment`
  String get buildingApartment {
    return Intl.message(
      'Building / Apartment',
      name: 'buildingApartment',
      desc: '',
      args: [],
    );
  }

  /// `Bulgarian`
  String get bulgarian {
    return Intl.message('Bulgarian', name: 'bulgarian', desc: '', args: []);
  }

  /// `Bulk Upload`
  String get bulkUpload {
    return Intl.message('Bulk Upload', name: 'bulkUpload', desc: '', args: []);
  }

  /// `Bulk Upload Employees`
  String get bulkUploadEmployees {
    return Intl.message(
      'Bulk Upload Employees',
      name: 'bulkUploadEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Bulk Upload Preview`
  String get bulkUploadPreview {
    return Intl.message(
      'Bulk Upload Preview',
      name: 'bulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Burkinabe`
  String get burkinabe {
    return Intl.message('Burkinabe', name: 'burkinabe', desc: '', args: []);
  }

  /// `Burmese`
  String get burmese {
    return Intl.message('Burmese', name: 'burmese', desc: '', args: []);
  }

  /// `Burundian`
  String get burundian {
    return Intl.message('Burundian', name: 'burundian', desc: '', args: []);
  }

  /// `Business Mission`
  String get businessMission {
    return Intl.message(
      'Business Mission',
      name: 'businessMission',
      desc: '',
      args: [],
    );
  }

  /// `Business Registration Number`
  String get businessRegistrationNumber {
    return Intl.message(
      'Business Registration Number',
      name: 'businessRegistrationNumber',
      desc: '',
      args: [],
    );
  }

  /// `Business Registration Number is required`
  String get businessRegistrationRequired {
    return Intl.message(
      'Business Registration Number is required',
      name: 'businessRegistrationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Business Type`
  String get businessType {
    return Intl.message(
      'Business Type',
      name: 'businessType',
      desc: '',
      args: [],
    );
  }

  /// `Business Type is required`
  String get businessTypeRequired {
    return Intl.message(
      'Business Type is required',
      name: 'businessTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `By Type`
  String get byType {
    return Intl.message('By Type', name: 'byType', desc: '', args: []);
  }

  /// `Cabinet`
  String get cabinet {
    return Intl.message('Cabinet', name: 'cabinet', desc: '', args: []);
  }

  /// `Cairo`
  String get cairo {
    return Intl.message('Cairo', name: 'cairo', desc: '', args: []);
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Cambodian`
  String get cambodian {
    return Intl.message('Cambodian', name: 'cambodian', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Cameroonian`
  String get cameroonian {
    return Intl.message('Cameroonian', name: 'cameroonian', desc: '', args: []);
  }

  /// `Canadian`
  String get canadian {
    return Intl.message('Canadian', name: 'canadian', desc: '', args: []);
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message('Cancel', name: 'Cancel', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Are you sure you want to cancel this request?`
  String get cancelConfirmation {
    return Intl.message(
      'Are you sure you want to cancel this request?',
      name: 'cancelConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get Canceled {
    return Intl.message('Canceled', name: 'Canceled', desc: '', args: []);
  }

  /// `Canceled`
  String get canceled {
    return Intl.message('Canceled', name: 'canceled', desc: '', args: []);
  }

  /// `Canceled By HR`
  String get canceledByHr {
    return Intl.message(
      'Canceled By HR',
      name: 'canceledByHr',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Cancel Meeting`
  String get cancelMeeting {
    return Intl.message(
      'Cancel Meeting',
      name: 'cancelMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request`
  String get CancelRequest {
    return Intl.message(
      'Cancel Request',
      name: 'CancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request`
  String get cancelRequest {
    return Intl.message(
      'Cancel Request',
      name: 'cancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Service`
  String get cancelService {
    return Intl.message(
      'Cancel Service',
      name: 'cancelService',
      desc: '',
      args: [],
    );
  }

  /// `You successfully canceled this request.`
  String get cancelSuccessMessage {
    return Intl.message(
      'You successfully canceled this request.',
      name: 'cancelSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cannot be "null"`
  String get cannotBeNull {
    return Intl.message(
      'Cannot be "null"',
      name: 'cannotBeNull',
      desc: '',
      args: [],
    );
  }

  /// `Can't Connect .. Check Internet`
  String get canTConnectCheckInternet {
    return Intl.message(
      'Can\'t Connect .. Check Internet',
      name: 'canTConnectCheckInternet',
      desc: '',
      args: [],
    );
  }

  /// `Capacity`
  String get capacity {
    return Intl.message('Capacity', name: 'capacity', desc: '', args: []);
  }

  /// `Cape Verdean`
  String get capeVerdean {
    return Intl.message(
      'Cape Verdean',
      name: 'capeVerdean',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Category / Subcategory`
  String get categorySubcategory {
    return Intl.message(
      'Category / Subcategory',
      name: 'categorySubcategory',
      desc: '',
      args: [],
    );
  }

  /// `Central African`
  String get centralAfrican {
    return Intl.message(
      'Central African',
      name: 'centralAfrican',
      desc: '',
      args: [],
    );
  }

  /// `CEO`
  String get cEO {
    return Intl.message('CEO', name: 'cEO', desc: '', args: []);
  }

  /// `Certificate`
  String get certificate {
    return Intl.message('Certificate', name: 'certificate', desc: '', args: []);
  }

  /// `Certificates`
  String get certificatesPermission {
    return Intl.message(
      'Certificates',
      name: 'certificatesPermission',
      desc: '',
      args: [],
    );
  }

  /// `Chadian`
  String get chadian {
    return Intl.message('Chadian', name: 'chadian', desc: '', args: []);
  }

  /// `Changed By`
  String get changedBy {
    return Intl.message('Changed By', name: 'changedBy', desc: '', args: []);
  }

  /// `Change Deal Stage`
  String get changeDealStage {
    return Intl.message(
      'Change Deal Stage',
      name: 'changeDealStage',
      desc: '',
      args: [],
    );
  }

  /// `Change Default Password`
  String get changeDefaultPassword {
    return Intl.message(
      'Change Default Password',
      name: 'changeDefaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Changed Status`
  String get changedStatus {
    return Intl.message(
      'Changed Status',
      name: 'changedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Change Expiration Date`
  String get changeExpirationDate {
    return Intl.message(
      'Change Expiration Date',
      name: 'changeExpirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Change Role Status`
  String get changeRoleStatus {
    return Intl.message(
      'Change Role Status',
      name: 'changeRoleStatus',
      desc: '',
      args: [],
    );
  }

  /// `Change Service Status`
  String get changeServiceStatus {
    return Intl.message(
      'Change Service Status',
      name: 'changeServiceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Changing Service Provider`
  String get changingServiceProvider {
    return Intl.message(
      'Changing Service Provider',
      name: 'changingServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Changing Status`
  String get changingStatus {
    return Intl.message(
      'Changing Status',
      name: 'changingStatus',
      desc: '',
      args: [],
    );
  }

  /// `Chart Examples`
  String get chartExamples {
    return Intl.message(
      'Chart Examples',
      name: 'chartExamples',
      desc: '',
      args: [],
    );
  }

  /// `Chart & Graph`
  String get chartGraph {
    return Intl.message(
      'Chart & Graph',
      name: 'chartGraph',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Check air circulation in storage area.`
  String get checkAirCirculationInStorageArea {
    return Intl.message(
      'Check air circulation in storage area.',
      name: 'checkAirCirculationInStorageArea',
      desc: '',
      args: [],
    );
  }

  /// `Check all lighting fixtures.`
  String get checkAllLightingFixtures {
    return Intl.message(
      'Check all lighting fixtures.',
      name: 'checkAllLightingFixtures',
      desc: '',
      args: [],
    );
  }

  /// `Check for cleanliness and hygiene standards.`
  String get checkForCleanlinessAndHygieneStandards {
    return Intl.message(
      'Check for cleanliness and hygiene standards.',
      name: 'checkForCleanlinessAndHygieneStandards',
      desc: '',
      args: [],
    );
  }

  /// `Check In`
  String get checkIn {
    return Intl.message('Check In', name: 'checkIn', desc: '', args: []);
  }

  /// `Check In Date`
  String get checkInDate {
    return Intl.message(
      'Check In Date',
      name: 'checkInDate',
      desc: '',
      args: [],
    );
  }

  /// `Check In-Out`
  String get checkInOut {
    return Intl.message('Check In-Out', name: 'checkInOut', desc: '', args: []);
  }

  /// `Check In Time`
  String get checkInTime {
    return Intl.message(
      'Check In Time',
      name: 'checkInTime',
      desc: '',
      args: [],
    );
  }

  /// `Check Out`
  String get checkOut {
    return Intl.message('Check Out', name: 'checkOut', desc: '', args: []);
  }

  /// `Check Out Date`
  String get checkOutDate {
    return Intl.message(
      'Check Out Date',
      name: 'checkOutDate',
      desc: '',
      args: [],
    );
  }

  /// `Check Out Time`
  String get checkOutTime {
    return Intl.message(
      'Check Out Time',
      name: 'checkOutTime',
      desc: '',
      args: [],
    );
  }

  /// `Please disable all notification switches before unchecking this section.`
  String get checkValidation {
    return Intl.message(
      'Please disable all notification switches before unchecking this section.',
      name: 'checkValidation',
      desc: '',
      args: [],
    );
  }

  /// `Chilean`
  String get chilean {
    return Intl.message('Chilean', name: 'chilean', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `Choose Type`
  String get choose_type {
    return Intl.message('Choose Type', name: 'choose_type', desc: '', args: []);
  }

  /// `Choose Baseline`
  String get chooseBaseline {
    return Intl.message(
      'Choose Baseline',
      name: 'chooseBaseline',
      desc: '',
      args: [],
    );
  }

  /// `Choose Control`
  String get chooseControl {
    return Intl.message(
      'Choose Control',
      name: 'chooseControl',
      desc: '',
      args: [],
    );
  }

  /// `Choose Date`
  String get chooseDate {
    return Intl.message('Choose Date', name: 'chooseDate', desc: '', args: []);
  }

  /// `Choose Degree`
  String get chooseDegree {
    return Intl.message(
      'Choose Degree',
      name: 'chooseDegree',
      desc: '',
      args: [],
    );
  }

  /// `Choose Department`
  String get chooseDepartment {
    return Intl.message(
      'Choose Department',
      name: 'chooseDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Choose Here`
  String get chooseHere {
    return Intl.message('Choose Here', name: 'chooseHere', desc: '', args: []);
  }

  /// `Choose here`
  String get chooseHere2 {
    return Intl.message('Choose here', name: 'chooseHere2', desc: '', args: []);
  }

  /// `Choose Module Mode`
  String get chooseModuleMode {
    return Intl.message(
      'Choose Module Mode',
      name: 'chooseModuleMode',
      desc: '',
      args: [],
    );
  }

  /// `Choose Policy`
  String get choosePolicy {
    return Intl.message(
      'Choose Policy',
      name: 'choosePolicy',
      desc: '',
      args: [],
    );
  }

  /// `Choose Request Type`
  String get chooseRequestType {
    return Intl.message(
      'Choose Request Type',
      name: 'chooseRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Please choose a storage location for all added rows.`
  String get chooseStorageLocation {
    return Intl.message(
      'Please choose a storage location for all added rows.',
      name: 'chooseStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose the date`
  String get chooseTheDate {
    return Intl.message(
      'Choose the date',
      name: 'chooseTheDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose Time`
  String get chooseTime {
    return Intl.message('Choose Time', name: 'chooseTime', desc: '', args: []);
  }

  /// `Choose which backup you want to restore`
  String get chooseWhichBackupYouWantToRestore {
    return Intl.message(
      'Choose which backup you want to restore',
      name: 'chooseWhichBackupYouWantToRestore',
      desc: '',
      args: [],
    );
  }

  /// `Choose work location`
  String get chooseWorkLocation {
    return Intl.message(
      'Choose work location',
      name: 'chooseWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `City is required`
  String get cityRequired {
    return Intl.message(
      'City is required',
      name: 'cityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Clean All`
  String get cleanAll {
    return Intl.message('Clean All', name: 'cleanAll', desc: '', args: []);
  }

  /// `Cleaning Notifications`
  String get cleaningNotifications {
    return Intl.message(
      'Cleaning Notifications',
      name: 'cleaningNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Cleanliness Audit`
  String get cleanlinessAudit {
    return Intl.message(
      'Cleanliness Audit',
      name: 'cleanlinessAudit',
      desc: '',
      args: [],
    );
  }

  /// `Cleared`
  String get cleared {
    return Intl.message('Cleared', name: 'cleared', desc: '', args: []);
  }

  /// `Clear Filter`
  String get clearFilter {
    return Intl.message(
      'Clear Filter',
      name: 'clearFilter',
      desc: '',
      args: [],
    );
  }

  /// `Clear Organization Chart`
  String get clearOrganizationChart {
    return Intl.message(
      'Clear Organization Chart',
      name: 'clearOrganizationChart',
      desc: '',
      args: [],
    );
  }

  /// `Visualize your company's structure effortlessly with our dynamic organization chart. Easily navigate through departments and roles to understand reporting lines and team relationships.`
  String get clearOrganizationChartBody {
    return Intl.message(
      'Visualize your company\'s structure effortlessly with our dynamic organization chart. Easily navigate through departments and roles to understand reporting lines and team relationships.',
      name: 'clearOrganizationChartBody',
      desc: '',
      args: [],
    );
  }

  /// `Click`
  String get click {
    return Intl.message('Click', name: 'click', desc: '', args: []);
  }

  /// `If you wish to add approval cycles for the remaining request types, click 'Add Different Approval Cycle for Other Request Types' and select the additional requests as needed.`
  String get clickAddDifferentApprovalCycle {
    return Intl.message(
      'If you wish to add approval cycles for the remaining request types, click \'Add Different Approval Cycle for Other Request Types\' and select the additional requests as needed.',
      name: 'clickAddDifferentApprovalCycle',
      desc: '',
      args: [],
    );
  }

  /// `Click Next to continue to Settings.`
  String get clickNextToContinue {
    return Intl.message(
      'Click Next to continue to Settings.',
      name: 'clickNextToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Client Site`
  String get clientSite {
    return Intl.message('Client Site', name: 'clientSite', desc: '', args: []);
  }

  /// `Closure Status`
  String get closureStatus {
    return Intl.message(
      'Closure Status',
      name: 'closureStatus',
      desc: '',
      args: [],
    );
  }

  /// `Cold Chain Logistics`
  String get coldChainLogistics {
    return Intl.message(
      'Cold Chain Logistics',
      name: 'coldChainLogistics',
      desc: '',
      args: [],
    );
  }

  /// `Cold Storage`
  String get coldStorage {
    return Intl.message(
      'Cold Storage',
      name: 'coldStorage',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message('Collapse', name: 'collapse', desc: '', args: []);
  }

  /// `Hide Toggle Panel`
  String get collapseTools {
    return Intl.message(
      'Hide Toggle Panel',
      name: 'collapseTools',
      desc: '',
      args: [],
    );
  }

  /// `Colombian`
  String get colombian {
    return Intl.message('Colombian', name: 'colombian', desc: '', args: []);
  }

  /// `Color Coding`
  String get colorCoding {
    return Intl.message(
      'Color Coding',
      name: 'colorCoding',
      desc: '',
      args: [],
    );
  }

  /// `Colors`
  String get colors {
    return Intl.message('Colors', name: 'colors', desc: '', args: []);
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Comma cannot be at start or end`
  String get commaAtStartOrEnd {
    return Intl.message(
      'Comma cannot be at start or end',
      name: 'commaAtStartOrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Comma cannot be at start or end`
  String get commaCannotBeAtStartOrEnd {
    return Intl.message(
      'Comma cannot be at start or end',
      name: 'commaCannotBeAtStartOrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Comment and Feedback`
  String get commentAndFeedback {
    return Intl.message(
      'Comment and Feedback',
      name: 'commentAndFeedback',
      desc: '',
      args: [],
    );
  }

  /// `No Comment uploaded yet`
  String get commentNotFound {
    return Intl.message(
      'No Comment uploaded yet',
      name: 'commentNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `Comments And Feedback`
  String get commentsAndFeedback {
    return Intl.message(
      'Comments And Feedback',
      name: 'commentsAndFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Comments And Feedbacks`
  String get commentsAndFeedbacks {
    return Intl.message(
      'Comments And Feedbacks',
      name: 'commentsAndFeedbacks',
      desc: '',
      args: [],
    );
  }

  /// `Comoran`
  String get comoran {
    return Intl.message('Comoran', name: 'comoran', desc: '', args: []);
  }

  /// `Company`
  String get company {
    return Intl.message('Company', name: 'company', desc: '', args: []);
  }

  /// `Company Industry`
  String get companyIndustry {
    return Intl.message(
      'Company Industry',
      name: 'companyIndustry',
      desc: '',
      args: [],
    );
  }

  /// `Company Information`
  String get companyInformation {
    return Intl.message(
      'Company Information',
      name: 'companyInformation',
      desc: '',
      args: [],
    );
  }

  /// `Company Name`
  String get companyName {
    return Intl.message(
      'Company Name',
      name: 'companyName',
      desc: '',
      args: [],
    );
  }

  /// `Company Services`
  String get companyServices {
    return Intl.message(
      'Company Services',
      name: 'companyServices',
      desc: '',
      args: [],
    );
  }

  /// `Company Size`
  String get companySize {
    return Intl.message(
      'Company Size',
      name: 'companySize',
      desc: '',
      args: [],
    );
  }

  /// `Compensation`
  String get compensation {
    return Intl.message(
      'Compensation',
      name: 'compensation',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Please complete all required fields before continuing.`
  String get completeRequiredFields {
    return Intl.message(
      'Please complete all required fields before continuing.',
      name: 'completeRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all required fields before submitting.`
  String get completeRequiredFieldsBeforeSubmitting {
    return Intl.message(
      'Please complete all required fields before submitting.',
      name: 'completeRequiredFieldsBeforeSubmitting',
      desc: '',
      args: [],
    );
  }

  /// `Completing Draft Role`
  String get completingDraftRole {
    return Intl.message(
      'Completing Draft Role',
      name: 'completingDraftRole',
      desc: '',
      args: [],
    );
  }

  /// `Compliance & Legal`
  String get complianceAndLegal {
    return Intl.message(
      'Compliance & Legal',
      name: 'complianceAndLegal',
      desc: '',
      args: [],
    );
  }

  /// `Compliance & Legal`
  String get ComplianceLegal {
    return Intl.message(
      'Compliance & Legal',
      name: 'ComplianceLegal',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Officer`
  String get complianceOfficer {
    return Intl.message(
      'Compliance Officer',
      name: 'complianceOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Score`
  String get complianceScore {
    return Intl.message(
      'Compliance Score',
      name: 'complianceScore',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Timeline`
  String get complianceTimeline {
    return Intl.message(
      'Compliance Timeline',
      name: 'complianceTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Comprehensive Service Management`
  String get comprehensiveServiceManagement {
    return Intl.message(
      'Comprehensive Service Management',
      name: 'comprehensiveServiceManagement',
      desc: '',
      args: [],
    );
  }

  /// `Manage inter-departmental service requests effortlessly with our all-in-one platform. Any department can request services from others, with the ability to approve, reject, and track the progress of these requests.`
  String get comprehensiveServiceManagementBody {
    return Intl.message(
      'Manage inter-departmental service requests effortlessly with our all-in-one platform. Any department can request services from others, with the ability to approve, reject, and track the progress of these requests.',
      name: 'comprehensiveServiceManagementBody',
      desc: '',
      args: [],
    );
  }

  /// `Computer Terminal / Inventory Access Point`
  String get computerTerminal {
    return Intl.message(
      'Computer Terminal / Inventory Access Point',
      name: 'computerTerminal',
      desc: '',
      args: [],
    );
  }

  /// `Condition`
  String get condition {
    return Intl.message('Condition', name: 'condition', desc: '', args: []);
  }

  /// `Condition Of Storage`
  String get conditionOfStorage {
    return Intl.message(
      'Condition Of Storage',
      name: 'conditionOfStorage',
      desc: '',
      args: [],
    );
  }

  /// `Condition of Storage is required`
  String get conditionOfStorageRequired {
    return Intl.message(
      'Condition of Storage is required',
      name: 'conditionOfStorageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Conduct Performance Reviews`
  String get conductPerformanceReviews {
    return Intl.message(
      'Conduct Performance Reviews',
      name: 'conductPerformanceReviews',
      desc: '',
      args: [],
    );
  }

  /// `Confidential / Secure Access`
  String get confidentialSecureAccess {
    return Intl.message(
      'Confidential / Secure Access',
      name: 'confidentialSecureAccess',
      desc: '',
      args: [],
    );
  }

  /// `Configure CRM Settings`
  String get configureCRMSettings {
    return Intl.message(
      'Configure CRM Settings',
      name: 'configureCRMSettings',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Are you sure you want to activate these roles?`
  String get confirmActivateRoles {
    return Intl.message(
      'Are you sure you want to activate these roles?',
      name: 'confirmActivateRoles',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Add This Asset ?`
  String get confirmAddAsset {
    return Intl.message(
      'Are You Sure You Want To Add This Asset ?',
      name: 'confirmAddAsset',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Add This Location?`
  String get confirmAddLocation {
    return Intl.message(
      'Are You Sure You Want To Add This Location?',
      name: 'confirmAddLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to add these users access?`
  String get confirmAddUsersAccess {
    return Intl.message(
      'Are you sure you want to add these users access?',
      name: 'confirmAddUsersAccess',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to assign this asset?`
  String get confirmAssignAsset {
    return Intl.message(
      'Are you sure you want to assign this asset?',
      name: 'confirmAssignAsset',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to assign this product to the selected employee?`
  String get confirmAssignProduct {
    return Intl.message(
      'Are you sure you want to assign this product to the selected employee?',
      name: 'confirmAssignProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Change Service Provider?`
  String get confirmChangeServiceProvider {
    return Intl.message(
      'Are You Sure You Want To Change Service Provider?',
      name: 'confirmChangeServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create a new batch?`
  String get confirmCreateNewBatch {
    return Intl.message(
      'Are you sure you want to create a new batch?',
      name: 'confirmCreateNewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this request?`
  String get confirmCreateRequest {
    return Intl.message(
      'Are you sure you want to create this request?',
      name: 'confirmCreateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this supplier?`
  String get confirmDeleteSupplier {
    return Intl.message(
      'Are you sure you want to delete this supplier?',
      name: 'confirmDeleteSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Deletion`
  String get confirmDeletion {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get confirmed {
    return Intl.message('Confirmed', name: 'confirmed', desc: '', args: []);
  }

  /// `Are you sure you want to edit this supplier?`
  String get confirmEditSupplier {
    return Intl.message(
      'Are you sure you want to edit this supplier?',
      name: 'confirmEditSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure that all email and password fields are filled in correctly.`
  String get confirmEmailAndPassword {
    return Intl.message(
      'Please ensure that all email and password fields are filled in correctly.',
      name: 'confirmEmailAndPassword',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Proceed With Assigning Equal Weight To All Controls?`
  String get confirmEqualWeight {
    return Intl.message(
      'Are You Sure You Want To Proceed With Assigning Equal Weight To All Controls?',
      name: 'confirmEqualWeight',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get confirmLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'confirmLogout',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm New Password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restock this product?`
  String get confirmRestockProduct {
    return Intl.message(
      'Are you sure you want to restock this product?',
      name: 'confirmRestockProduct',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to retrieve this product?`
  String get confirmRetrieveProduct {
    return Intl.message(
      'Are you sure you want to retrieve this product?',
      name: 'confirmRetrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Congolese`
  String get congolese {
    return Intl.message('Congolese', name: 'congolese', desc: '', args: []);
  }

  /// `Consumable`
  String get consumable {
    return Intl.message('Consumable', name: 'consumable', desc: '', args: []);
  }

  /// `Consumable Details`
  String get consumableDetails {
    return Intl.message(
      'Consumable Details',
      name: 'consumableDetails',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Expired`
  String get consumableExpired {
    return Intl.message(
      'Consumable Expired',
      name: 'consumableExpired',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Missing`
  String get consumableMissing {
    return Intl.message(
      'Consumable Missing',
      name: 'consumableMissing',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Return`
  String get consumableReturn {
    return Intl.message(
      'Consumable Return',
      name: 'consumableReturn',
      desc: '',
      args: [],
    );
  }

  /// `Consumables`
  String get consumables {
    return Intl.message('Consumables', name: 'consumables', desc: '', args: []);
  }

  /// `Consumables Assigned`
  String get consumablesAssigned {
    return Intl.message(
      'Consumables Assigned',
      name: 'consumablesAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Consumable Stolen`
  String get consumableStolen {
    return Intl.message(
      'Consumable Stolen',
      name: 'consumableStolen',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `Contact Info`
  String get contactInfo {
    return Intl.message(
      'Contact Info',
      name: 'contactInfo',
      desc: '',
      args: [],
    );
  }

  /// `Contact Information`
  String get contactInformation {
    return Intl.message(
      'Contact Information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Contact Manager`
  String get contactManager {
    return Intl.message(
      'Contact Manager',
      name: 'contactManager',
      desc: '',
      args: [],
    );
  }

  /// `Contact {number}: Email is required`
  String contactNumberEmail(Object number) {
    return Intl.message(
      'Contact $number: Email is required',
      name: 'contactNumberEmail',
      desc: '',
      args: [number],
    );
  }

  /// `Contact #{n}: fax number is required.`
  String contactNumberFaxNumber(Object n) {
    return Intl.message(
      'Contact #$n: fax number is required.',
      name: 'contactNumberFaxNumber',
      desc: '',
      args: [n],
    );
  }

  /// `Contact {number}: First Name is required`
  String contactNumberFirstName(Object number) {
    return Intl.message(
      'Contact $number: First Name is required',
      name: 'contactNumberFirstName',
      desc: '',
      args: [number],
    );
  }

  /// `Contact {number}: Last Name is required`
  String contactNumberLastName(Object number) {
    return Intl.message(
      'Contact $number: Last Name is required',
      name: 'contactNumberLastName',
      desc: '',
      args: [number],
    );
  }

  /// `Contact #{n}: middle name is required.`
  String contactNumberMiddleName(Object n) {
    return Intl.message(
      'Contact #$n: middle name is required.',
      name: 'contactNumberMiddleName',
      desc: '',
      args: [n],
    );
  }

  /// `Contact {number}: Phone Number is required`
  String contactNumberPhoneNumber(Object number) {
    return Intl.message(
      'Contact $number: Phone Number is required',
      name: 'contactNumberPhoneNumber',
      desc: '',
      args: [number],
    );
  }

  /// `Contact #{n}: preferred language is required.`
  String contactNumberPreferredLanguage(Object n) {
    return Intl.message(
      'Contact #$n: preferred language is required.',
      name: 'contactNumberPreferredLanguage',
      desc: '',
      args: [n],
    );
  }

  /// `Contact #{n}: title is required.`
  String contactNumberTitle(Object n) {
    return Intl.message(
      'Contact #$n: title is required.',
      name: 'contactNumberTitle',
      desc: '',
      args: [n],
    );
  }

  /// `Contact {number}: Please enter a valid email`
  String contactNumberValidEmail(Object number) {
    return Intl.message(
      'Contact $number: Please enter a valid email',
      name: 'contactNumberValidEmail',
      desc: '',
      args: [number],
    );
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Continue to Next Product`
  String get continueToNextProduct {
    return Intl.message(
      'Continue to Next Product',
      name: 'continueToNextProduct',
      desc: '',
      args: [],
    );
  }

  /// `Contract`
  String get contract {
    return Intl.message('Contract', name: 'contract', desc: '', args: []);
  }

  /// `Contract Date Range`
  String get contractDateRange {
    return Intl.message(
      'Contract Date Range',
      name: 'contractDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Contract Details`
  String get contractDetails {
    return Intl.message(
      'Contract Details',
      name: 'contractDetails',
      desc: '',
      args: [],
    );
  }

  /// `Contract Document`
  String get contractDocument {
    return Intl.message(
      'Contract Document',
      name: 'contractDocument',
      desc: '',
      args: [],
    );
  }

  /// `Contract End Date`
  String get contractEndDate {
    return Intl.message(
      'Contract End Date',
      name: 'contractEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Contract End Date is required`
  String get contractEndDateRequired {
    return Intl.message(
      'Contract End Date is required',
      name: 'contractEndDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Contract Start Date`
  String get contractStartDate {
    return Intl.message(
      'Contract Start Date',
      name: 'contractStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Contract Start Date is required`
  String get contractStartDateRequired {
    return Intl.message(
      'Contract Start Date is required',
      name: 'contractStartDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Contributor`
  String get contributor {
    return Intl.message('Contributor', name: 'contributor', desc: '', args: []);
  }

  /// `Control`
  String get control {
    return Intl.message('Control', name: 'control', desc: '', args: []);
  }

  /// `Control Average Weight`
  String get controlAverageWeight {
    return Intl.message(
      'Control Average Weight',
      name: 'controlAverageWeight',
      desc: '',
      args: [],
    );
  }

  /// `Control Bulk Upload`
  String get controlBulkUpload {
    return Intl.message(
      'Control Bulk Upload',
      name: 'controlBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Control Bulk Upload Preview`
  String get controlBulkUploadPreview {
    return Intl.message(
      'Control Bulk Upload Preview',
      name: 'controlBulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion`
  String get controlChampion {
    return Intl.message(
      'Control Champion',
      name: 'controlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion Added`
  String get controlChampionAdded {
    return Intl.message(
      'Control Champion Added',
      name: 'controlChampionAdded',
      desc: '',
      args: [],
    );
  }

  /// `Control Champion Removed`
  String get controlChampionRemoved {
    return Intl.message(
      'Control Champion Removed',
      name: 'controlChampionRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Control champion removed successfully`
  String get controlChampionRemovedSuccessfully {
    return Intl.message(
      'Control champion removed successfully',
      name: 'controlChampionRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control Champions`
  String get controlChampions {
    return Intl.message(
      'Control Champions',
      name: 'controlChampions',
      desc: '',
      args: [],
    );
  }

  /// `Control Changes`
  String get controlChanges {
    return Intl.message(
      'Control Changes',
      name: 'controlChanges',
      desc: '',
      args: [],
    );
  }

  /// `Control Created`
  String get controlCreated {
    return Intl.message(
      'Control Created',
      name: 'controlCreated',
      desc: '',
      args: [],
    );
  }

  /// `Control Deleted`
  String get controlDeleted {
    return Intl.message(
      'Control Deleted',
      name: 'controlDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Control Description`
  String get controlDescription {
    return Intl.message(
      'Control Description',
      name: 'controlDescription',
      desc: '',
      args: [],
    );
  }

  /// `Control description must be written in Arabic`
  String get controlDescriptionMustBeWrittenInArabic {
    return Intl.message(
      'Control description must be written in Arabic',
      name: 'controlDescriptionMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control description must be written in English`
  String get controlDescriptionMustBeWrittenInEnglish {
    return Intl.message(
      'Control description must be written in English',
      name: 'controlDescriptionMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control Details`
  String get controlDetails {
    return Intl.message(
      'Control Details',
      name: 'controlDetails',
      desc: '',
      args: [],
    );
  }

  /// `Control Document`
  String get controlDocument {
    return Intl.message(
      'Control Document',
      name: 'controlDocument',
      desc: '',
      args: [],
    );
  }

  /// `Control Document (Arabic)`
  String get controlDocumentAr {
    return Intl.message(
      'Control Document (Arabic)',
      name: 'controlDocumentAr',
      desc: '',
      args: [],
    );
  }

  /// `Control Document (English)`
  String get controlDocumentEng {
    return Intl.message(
      'Control Document (English)',
      name: 'controlDocumentEng',
      desc: '',
      args: [],
    );
  }

  /// `Control Name`
  String get controlName {
    return Intl.message(
      'Control Name',
      name: 'controlName',
      desc: '',
      args: [],
    );
  }

  /// `Control Name cannot be empty`
  String get controlNameCannotBeEmpty {
    return Intl.message(
      'Control Name cannot be empty',
      name: 'controlNameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Control name must be written in Arabic`
  String get controlNameMustBeWrittenInArabic {
    return Intl.message(
      'Control name must be written in Arabic',
      name: 'controlNameMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control name must be written in English`
  String get controlNameMustBeWrittenInEnglish {
    return Intl.message(
      'Control name must be written in English',
      name: 'controlNameMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control Number`
  String get controlNumber {
    return Intl.message(
      'Control Number',
      name: 'controlNumber',
      desc: '',
      args: [],
    );
  }

  /// `Control number must be written in Arabic`
  String get controlNumberMustBeWrittenInArabic {
    return Intl.message(
      'Control number must be written in Arabic',
      name: 'controlNumberMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Control number must be written in English`
  String get controlNumberMustBeWrittenInEnglish {
    return Intl.message(
      'Control number must be written in English',
      name: 'controlNumberMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner`
  String get controlOwner {
    return Intl.message(
      'Control Owner',
      name: 'controlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner Added`
  String get controlOwnerAdded {
    return Intl.message(
      'Control Owner Added',
      name: 'controlOwnerAdded',
      desc: '',
      args: [],
    );
  }

  /// `Control Owner Removed`
  String get controlOwnerRemoved {
    return Intl.message(
      'Control Owner Removed',
      name: 'controlOwnerRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Control owner removed successfully`
  String get controlOwnerRemovedSuccessfully {
    return Intl.message(
      'Control owner removed successfully',
      name: 'controlOwnerRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control Owners`
  String get controlOwners {
    return Intl.message(
      'Control Owners',
      name: 'controlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Control owners history screen not implemented yet`
  String get controlOwnersHistoryScreenNotImplemented {
    return Intl.message(
      'Control owners history screen not implemented yet',
      name: 'controlOwnersHistoryScreenNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Controls`
  String get controls {
    return Intl.message('Controls', name: 'controls', desc: '', args: []);
  }

  /// `Control saved as draft successfully`
  String get controlSavedAsDraftSuccessfully {
    return Intl.message(
      'Control saved as draft successfully',
      name: 'controlSavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control(s) Created`
  String get controlSCreated {
    return Intl.message(
      'Control(s) Created',
      name: 'controlSCreated',
      desc: '',
      args: [],
    );
  }

  /// `Control Status`
  String get controlStatus {
    return Intl.message(
      'Control Status',
      name: 'controlStatus',
      desc: '',
      args: [],
    );
  }

  /// `Controls Updated`
  String get controlsUpdated {
    return Intl.message(
      'Controls Updated',
      name: 'controlsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Controls updated successfully`
  String get controlsUpdatedSuccessfully {
    return Intl.message(
      'Controls updated successfully',
      name: 'controlsUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Control Updated`
  String get controlUpdated {
    return Intl.message(
      'Control Updated',
      name: 'controlUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight`
  String get controlWeight {
    return Intl.message(
      'Control Weight',
      name: 'controlWeight',
      desc: '',
      args: [],
    );
  }

  /// `Control weight cannot be more than 100`
  String get controlWeightCannotBeMoreThan100 {
    return Intl.message(
      'Control weight cannot be more than 100',
      name: 'controlWeightCannotBeMoreThan100',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Current`
  String get controlWeightCurrent {
    return Intl.message(
      'Control Weight Current',
      name: 'controlWeightCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Issue`
  String get controlWeightIssue {
    return Intl.message(
      'Control Weight Issue',
      name: 'controlWeightIssue',
      desc: '',
      args: [],
    );
  }

  /// `Control weight must be a positive number`
  String get controlWeightMustBeAPositiveNumber {
    return Intl.message(
      'Control weight must be a positive number',
      name: 'controlWeightMustBeAPositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Control weight must be a valid number`
  String get controlWeightMustBeAValidNumber {
    return Intl.message(
      'Control weight must be a valid number',
      name: 'controlWeightMustBeAValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Control Weight Previous`
  String get controlWeightPrevious {
    return Intl.message(
      'Control Weight Previous',
      name: 'controlWeightPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Convert Lead`
  String get convertLead {
    return Intl.message(
      'Convert Lead',
      name: 'convertLead',
      desc: '',
      args: [],
    );
  }

  /// `Convert to PDF`
  String get convertToPdf {
    return Intl.message(
      'Convert to PDF',
      name: 'convertToPdf',
      desc: '',
      args: [],
    );
  }

  /// `Conveyor System`
  String get conveyorSystem {
    return Intl.message(
      'Conveyor System',
      name: 'conveyorSystem',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Copy Done`
  String get copyDone {
    return Intl.message('Copy Done', name: 'copyDone', desc: '', args: []);
  }

  /// `Copyright`
  String get copyright {
    return Intl.message('Copyright', name: 'copyright', desc: '', args: []);
  }

  /// `Costa Rican`
  String get costaRican {
    return Intl.message('Costa Rican', name: 'costaRican', desc: '', args: []);
  }

  /// `You can't send a message to yourself`
  String get cannotMessageYourself {
    return Intl.message(
      'You can\'t send a message to yourself',
      name: 'cannotMessageYourself',
      desc: '',
      args: [],
    );
  }

  /// `Messaging is still loading. Please try again in a moment.`
  String get chatNotReady {
    return Intl.message(
      'Messaging is still loading. Please try again in a moment.',
      name: 'chatNotReady',
      desc: '',
      args: [],
    );
  }

  /// `This user has no messaging profile`
  String get chatUserNotFound {
    return Intl.message(
      'This user has no messaging profile',
      name: 'chatUserNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Could not open the chat`
  String get couldNotOpenChat {
    return Intl.message(
      'Could not open the chat',
      name: 'couldNotOpenChat',
      desc: '',
      args: [],
    );
  }

  /// `CouldNotOpenFile`
  String get couldNotOpenFile {
    return Intl.message(
      'CouldNotOpenFile',
      name: 'couldNotOpenFile',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the selected file. Please try again.`
  String get couldNotReadTheSelectedFilePleaseTryAgain {
    return Intl.message(
      'Could not read the selected file. Please try again.',
      name: 'couldNotReadTheSelectedFilePleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Count items and verify stock levels.`
  String get countItemsAndVerifyStockLevels {
    return Intl.message(
      'Count items and verify stock levels.',
      name: 'countItemsAndVerifyStockLevels',
      desc: '',
      args: [],
    );
  }

  /// `countries`
  String get countries {
    return Intl.message('countries', name: 'countries', desc: '', args: []);
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Country is required`
  String get countryRequired {
    return Intl.message(
      'Country is required',
      name: 'countryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Counts`
  String get counts {
    return Intl.message('Counts', name: 'counts', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Create New Knowledge`
  String get create_new_knowledge {
    return Intl.message(
      'Create New Knowledge',
      name: 'create_new_knowledge',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create a new group with`
  String get createANewGroupWith {
    return Intl.message(
      'Create a new group with',
      name: 'createANewGroupWith',
      desc: '',
      args: [],
    );
  }

  /// `Create Arabic Version`
  String get createArabicVersion {
    return Intl.message(
      'Create Arabic Version',
      name: 'createArabicVersion',
      desc: '',
      args: [],
    );
  }

  /// `Create Automatic IDs`
  String get createAutomaticIDs {
    return Intl.message(
      'Create Automatic IDs',
      name: 'createAutomaticIDs',
      desc: '',
      args: [],
    );
  }

  /// `Create Barcode`
  String get createBarcode {
    return Intl.message(
      'Create Barcode',
      name: 'createBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Create Board`
  String get createBoard {
    return Intl.message(
      'Create Board',
      name: 'createBoard',
      desc: '',
      args: [],
    );
  }

  /// `Create Contact`
  String get createContact {
    return Intl.message(
      'Create Contact',
      name: 'createContact',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get created {
    return Intl.message('Created', name: 'created', desc: '', args: []);
  }

  /// `Created At`
  String get created_at {
    return Intl.message('Created At', name: 'created_at', desc: '', args: []);
  }

  /// `Created By`
  String get created_by {
    return Intl.message('Created By', name: 'created_by', desc: '', args: []);
  }

  /// `Created At`
  String get createdAt {
    return Intl.message('Created At', name: 'createdAt', desc: '', args: []);
  }

  /// `Created By`
  String get createdBy {
    return Intl.message('Created By', name: 'createdBy', desc: '', args: []);
  }

  /// `Created Date`
  String get createdDate {
    return Intl.message(
      'Created Date',
      name: 'createdDate',
      desc: '',
      args: [],
    );
  }

  /// `Created Date Range`
  String get createdDateRange {
    return Intl.message(
      'Created Date Range',
      name: 'createdDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Create Deal`
  String get createDeal {
    return Intl.message('Create Deal', name: 'createDeal', desc: '', args: []);
  }

  /// `Created Modules`
  String get createdModules {
    return Intl.message(
      'Created Modules',
      name: 'createdModules',
      desc: '',
      args: [],
    );
  }

  /// `Create Form`
  String get createForm {
    return Intl.message('Create Form', name: 'createForm', desc: '', args: []);
  }

  /// `Create GRC Module`
  String get createGrcModule {
    return Intl.message(
      'Create GRC Module',
      name: 'createGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get createGroup {
    return Intl.message(
      'Create Group',
      name: 'createGroup',
      desc: '',
      args: [],
    );
  }

  /// `Create Group Permissions`
  String get createGroupPermissions {
    return Intl.message(
      'Create Group Permissions',
      name: 'createGroupPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Create Group Permissions Module`
  String get createGroupPermissionsModule {
    return Intl.message(
      'Create Group Permissions Module',
      name: 'createGroupPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Create Hub`
  String get createHub {
    return Intl.message('Create Hub', name: 'createHub', desc: '', args: []);
  }

  /// `Create Knowledge Hub`
  String get createKnowledgeHub {
    return Intl.message(
      'Create Knowledge Hub',
      name: 'createKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Create Lead`
  String get createLead {
    return Intl.message('Create Lead', name: 'createLead', desc: '', args: []);
  }

  /// `Create Meeting`
  String get createMeeting {
    return Intl.message(
      'Create Meeting',
      name: 'createMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Create Meeting from Home Page`
  String get createMeetingFromHomePage {
    return Intl.message(
      'Create Meeting from Home Page',
      name: 'createMeetingFromHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Create Module`
  String get createModule {
    return Intl.message(
      'Create Module',
      name: 'createModule',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get createNew {
    return Intl.message('Create New', name: 'createNew', desc: '', args: []);
  }

  /// `Create new batch`
  String get createNewBatch {
    return Intl.message(
      'Create new batch',
      name: 'createNewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Create New Form`
  String get createNewForm {
    return Intl.message(
      'Create New Form',
      name: 'createNewForm',
      desc: '',
      args: [],
    );
  }

  /// `Create New GRC Module`
  String get createNewGrcModule {
    return Intl.message(
      'Create New GRC Module',
      name: 'createNewGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Create New Group`
  String get createNewGroup {
    return Intl.message(
      'Create New Group',
      name: 'createNewGroup',
      desc: '',
      args: [],
    );
  }

  /// `Create New Policy`
  String get createNewPolicy {
    return Intl.message(
      'Create New Policy',
      name: 'createNewPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Create New Request`
  String get createNewRequest {
    return Intl.message(
      'Create New Request',
      name: 'createNewRequest',
      desc: '',
      args: [],
    );
  }

  /// `Create Order`
  String get createOrder {
    return Intl.message(
      'Create Order',
      name: 'createOrder',
      desc: '',
      args: [],
    );
  }

  /// `Create Poll`
  String get createPoll {
    return Intl.message('Create Poll', name: 'createPoll', desc: '', args: []);
  }

  /// `Create Role Management`
  String get createRoleManagement {
    return Intl.message(
      'Create Role Management',
      name: 'createRoleManagement',
      desc: '',
      args: [],
    );
  }

  /// `Create Service`
  String get createService {
    return Intl.message(
      'Create Service',
      name: 'createService',
      desc: '',
      args: [],
    );
  }

  /// `Creating Success`
  String get createSuccess {
    return Intl.message(
      'Creating Success',
      name: 'createSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Create Task`
  String get createTask {
    return Intl.message('Create Task', name: 'createTask', desc: '', args: []);
  }

  /// `Create Task from Home Page`
  String get createTaskFromHomePage {
    return Intl.message(
      'Create Task from Home Page',
      name: 'createTaskFromHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get createTitle {
    return Intl.message('Create', name: 'createTitle', desc: '', args: []);
  }

  /// `Creating Knowledge Hub`
  String get creating_knowledge_hub {
    return Intl.message(
      'Creating Knowledge Hub',
      name: 'creating_knowledge_hub',
      desc: '',
      args: [],
    );
  }

  /// `Creating Modules`
  String get creatingModules {
    return Intl.message(
      'Creating Modules',
      name: 'creatingModules',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Location`
  String get creatingNewLocation {
    return Intl.message(
      'Creating New Location',
      name: 'creatingNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Request Type`
  String get creatingNewRequestType {
    return Intl.message(
      'Creating New Request Type',
      name: 'creatingNewRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Service`
  String get creatingNewService {
    return Intl.message(
      'Creating New Service',
      name: 'creatingNewService',
      desc: '',
      args: [],
    );
  }

  /// `Creating policy`
  String get creatingPolicy {
    return Intl.message(
      'Creating policy',
      name: 'creatingPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Creating Request`
  String get creatingRequest {
    return Intl.message(
      'Creating Request',
      name: 'creatingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Creating Request Type`
  String get creatingRequestType {
    return Intl.message(
      'Creating Request Type',
      name: 'creatingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Creating Role`
  String get creatingRole {
    return Intl.message(
      'Creating Role',
      name: 'creatingRole',
      desc: '',
      args: [],
    );
  }

  /// `Creating Service`
  String get creatingService {
    return Intl.message(
      'Creating Service',
      name: 'creatingService',
      desc: '',
      args: [],
    );
  }

  /// `Creating Transaction`
  String get creatingTransaction {
    return Intl.message(
      'Creating Transaction',
      name: 'creatingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `CREATION_DATE`
  String get CREATION_DATE {
    return Intl.message(
      'CREATION_DATE',
      name: 'CREATION_DATE',
      desc: '',
      args: [],
    );
  }

  /// `Creation Date`
  String get creationDate {
    return Intl.message(
      'Creation Date',
      name: 'creationDate',
      desc: '',
      args: [],
    );
  }

  /// `Critical`
  String get critical {
    return Intl.message('Critical', name: 'critical', desc: '', args: []);
  }

  /// `CRM Module`
  String get crmModule {
    return Intl.message('CRM Module', name: 'crmModule', desc: '', args: []);
  }

  /// `Croatian`
  String get croatian {
    return Intl.message('Croatian', name: 'croatian', desc: '', args: []);
  }

  /// `Your CSV file has been saved`
  String get csvFileSaved {
    return Intl.message(
      'Your CSV file has been saved',
      name: 'csvFileSaved',
      desc: '',
      args: [],
    );
  }

  /// `CSV Import`
  String get csvImport {
    return Intl.message('CSV Import', name: 'csvImport', desc: '', args: []);
  }

  /// `Cuban`
  String get cuban {
    return Intl.message('Cuban', name: 'cuban', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  // skipped getter for the 'current' key

  /// `Current Details`
  String get current_details {
    return Intl.message(
      'Current Details',
      name: 'current_details',
      desc: '',
      args: [],
    );
  }

  /// `Current Control Champion`
  String get currentControlChampion {
    return Intl.message(
      'Current Control Champion',
      name: 'currentControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Current Control Owner`
  String get currentControlOwner {
    return Intl.message(
      'Current Control Owner',
      name: 'currentControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currentLabel {
    return Intl.message('Current', name: 'currentLabel', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Customer Support`
  String get CustomerSupport {
    return Intl.message(
      'Customer Support',
      name: 'CustomerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Customer Support`
  String get customerSupport {
    return Intl.message(
      'Customer Support',
      name: 'customerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Customize your personal branding. These settings will override company branding for your account only.`
  String get customizeYourPersonalBrandingTheseSettingsWillOv {
    return Intl.message(
      'Customize your personal branding. These settings will override company branding for your account only.',
      name: 'customizeYourPersonalBrandingTheseSettingsWillOv',
      desc: '',
      args: [],
    );
  }

  /// `Custom Table`
  String get customTable {
    return Intl.message(
      'Custom Table',
      name: 'customTable',
      desc: '',
      args: [],
    );
  }

  /// `Cyber Security`
  String get cyberSecurity {
    return Intl.message(
      'Cyber Security',
      name: 'cyberSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Cypriot`
  String get cypriot {
    return Intl.message('Cypriot', name: 'cypriot', desc: '', args: []);
  }

  /// `Czech`
  String get czech {
    return Intl.message('Czech', name: 'czech', desc: '', args: []);
  }

  /// `Damaged`
  String get damaged {
    return Intl.message('Damaged', name: 'damaged', desc: '', args: []);
  }

  /// `Damage Type`
  String get damageType {
    return Intl.message('Damage Type', name: 'damageType', desc: '', args: []);
  }

  /// `Danish`
  String get danish {
    return Intl.message('Danish', name: 'danish', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Dashboard Permissions`
  String get dashboardPermissions {
    return Intl.message(
      'Dashboard Permissions',
      name: 'dashboardPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard Permissions Module`
  String get dashboardPermissionsModule {
    return Intl.message(
      'Dashboard Permissions Module',
      name: 'dashboardPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Database Builder`
  String get database_builder {
    return Intl.message(
      'Database Builder',
      name: 'database_builder',
      desc: '',
      args: [],
    );
  }

  /// `Data has been saved successfully`
  String get dataHasBeenSavedSuccessfully {
    return Intl.message(
      'Data has been saved successfully',
      name: 'dataHasBeenSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Data Management`
  String get DataManagement {
    return Intl.message(
      'Data Management',
      name: 'DataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Data Management`
  String get dataManagement {
    return Intl.message(
      'Data Management',
      name: 'dataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Data saved locally.`
  String get dataSavedLocally {
    return Intl.message(
      'Data saved locally.',
      name: 'dataSavedLocally',
      desc: '',
      args: [],
    );
  }

  /// `Data will appear once users interact with this document`
  String get dataWillAppearOnceUsersInteract {
    return Intl.message(
      'Data will appear once users interact with this document',
      name: 'dataWillAppearOnceUsersInteract',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Date Added`
  String get dateAdded {
    return Intl.message('Date Added', name: 'dateAdded', desc: '', args: []);
  }

  /// `Date Of Action`
  String get dateOfAction {
    return Intl.message(
      'Date Of Action',
      name: 'dateOfAction',
      desc: '',
      args: [],
    );
  }

  /// `Date Received`
  String get dateReceived {
    return Intl.message(
      'Date Received',
      name: 'dateReceived',
      desc: '',
      args: [],
    );
  }

  /// `Date Requested`
  String get DateRequested {
    return Intl.message(
      'Date Requested',
      name: 'DateRequested',
      desc: '',
      args: [],
    );
  }

  /// `Date Requested`
  String get dateRequested {
    return Intl.message(
      'Date Requested',
      name: 'dateRequested',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Days`
  String get days {
    return Intl.message('Days', name: 'days', desc: '', args: []);
  }

  /// `Days Ago`
  String get daysAgo {
    return Intl.message('Days Ago', name: 'daysAgo', desc: '', args: []);
  }

  /// `Days Off`
  String get daysOff {
    return Intl.message('Days Off', name: 'daysOff', desc: '', args: []);
  }

  /// `Deactivated For Now`
  String get deactivatedForNow {
    return Intl.message(
      'Deactivated For Now',
      name: 'deactivatedForNow',
      desc: '',
      args: [],
    );
  }

  /// `Deactivate User`
  String get deactivateUser {
    return Intl.message(
      'Deactivate User',
      name: 'deactivateUser',
      desc: '',
      args: [],
    );
  }

  /// `Deactivating User Account`
  String get deactivatingUserAccount {
    return Intl.message(
      'Deactivating User Account',
      name: 'deactivatingUserAccount',
      desc: '',
      args: [],
    );
  }

  /// `Death Vacation`
  String get deathVacation {
    return Intl.message(
      'Death Vacation',
      name: 'deathVacation',
      desc: '',
      args: [],
    );
  }

  /// `Dec`
  String get dec {
    return Intl.message('Dec', name: 'dec', desc: '', args: []);
  }

  /// `Default Password`
  String get defaultPassword {
    return Intl.message(
      'Default Password',
      name: 'defaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Degree or Certification`
  String get degreeOrCertification {
    return Intl.message(
      'Degree or Certification',
      name: 'degreeOrCertification',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message('Delete', name: 'Delete', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message('Delete All', name: 'deleteAll', desc: '', args: []);
  }

  /// `Delete All Notifications`
  String get deleteAllNotifications {
    return Intl.message(
      'Delete All Notifications',
      name: 'deleteAllNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Delete Attachment`
  String get deleteAttachment {
    return Intl.message(
      'Delete Attachment',
      name: 'deleteAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Delete Contact`
  String get deleteContact {
    return Intl.message(
      'Delete Contact',
      name: 'deleteContact',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get deleted {
    return Intl.message('Deleted', name: 'deleted', desc: '', args: []);
  }

  /// `Delete Deal`
  String get deleteDeal {
    return Intl.message('Delete Deal', name: 'deleteDeal', desc: '', args: []);
  }

  /// `Deleted GRC Module`
  String get deletedGrcModule {
    return Intl.message(
      'Deleted GRC Module',
      name: 'deletedGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Deleted Message`
  String get deletedMessage {
    return Intl.message(
      'Deleted Message',
      name: 'deletedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Employee`
  String get deleteEmployee {
    return Intl.message(
      'Delete Employee',
      name: 'deleteEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Delete Form`
  String get deleteForm {
    return Intl.message('Delete Form', name: 'deleteForm', desc: '', args: []);
  }

  /// `Deleting Form`
  String get deletingForm {
    return Intl.message(
      'Deleting Form',
      name: 'deletingForm',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get deleteImage {
    return Intl.message(
      'Delete Image',
      name: 'deleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Lead`
  String get deleteLead {
    return Intl.message('Delete Lead', name: 'deleteLead', desc: '', args: []);
  }

  /// `Delete Message`
  String get DeleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'DeleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Message`
  String get deleteMessage {
    return Intl.message(
      'Delete Message',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Qiyas`
  String get deleteQiyas {
    return Intl.message(
      'Delete Qiyas',
      name: 'deleteQiyas',
      desc: '',
      args: [],
    );
  }

  /// `Delete Role`
  String get deleteRole {
    return Intl.message('Delete Role', name: 'deleteRole', desc: '', args: []);
  }

  /// `Delete Service`
  String get deleteService {
    return Intl.message(
      'Delete Service',
      name: 'deleteService',
      desc: '',
      args: [],
    );
  }

  /// `Delete Service`
  String get deleteServices {
    return Intl.message(
      'Delete Service',
      name: 'deleteServices',
      desc: '',
      args: [],
    );
  }

  /// `Delete starred messages`
  String get deleteStarredMessages {
    return Intl.message(
      'Delete starred messages',
      name: 'deleteStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Delete Supplier`
  String get deleteSupplier {
    return Intl.message(
      'Delete Supplier',
      name: 'deleteSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Controls`
  String get deletingControls {
    return Intl.message(
      'Deleting Controls',
      name: 'deletingControls',
      desc: '',
      args: [],
    );
  }

  /// `Deleting GRC Module`
  String get deletingGrcModule {
    return Intl.message(
      'Deleting GRC Module',
      name: 'deletingGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Groups`
  String get deletingGroups {
    return Intl.message(
      'Deleting Groups',
      name: 'deletingGroups',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Location`
  String get deletingLocation {
    return Intl.message(
      'Deleting Location',
      name: 'deletingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Request Type`
  String get deletingRequestType {
    return Intl.message(
      'Deleting Request Type',
      name: 'deletingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Delivery Method`
  String get deliveryMethod {
    return Intl.message(
      'Delivery Method',
      name: 'deliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Payment`
  String get deliveryMethodAdvancedPayment {
    return Intl.message(
      'Advanced Payment',
      name: 'deliveryMethodAdvancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Bank Transfer`
  String get deliveryMethodBankTransfer {
    return Intl.message(
      'Bank Transfer',
      name: 'deliveryMethodBankTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get deliveryMethodCash {
    return Intl.message('Cash', name: 'deliveryMethodCash', desc: '', args: []);
  }

  /// `Cash On Delivery`
  String get deliveryMethodCashOnDelivery {
    return Intl.message(
      'Cash On Delivery',
      name: 'deliveryMethodCashOnDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Cheque`
  String get deliveryMethodCheque {
    return Intl.message(
      'Cheque',
      name: 'deliveryMethodCheque',
      desc: '',
      args: [],
    );
  }

  /// `Credit Card`
  String get deliveryMethodCreditCard {
    return Intl.message(
      'Credit Card',
      name: 'deliveryMethodCreditCard',
      desc: '',
      args: [],
    );
  }

  /// `Installments`
  String get deliveryMethodInstallments {
    return Intl.message(
      'Installments',
      name: 'deliveryMethodInstallments',
      desc: '',
      args: [],
    );
  }

  /// `On Account`
  String get deliveryMethodOnAccount {
    return Intl.message(
      'On Account',
      name: 'deliveryMethodOnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Demands`
  String get demands {
    return Intl.message('Demands', name: 'demands', desc: '', args: []);
  }

  /// `Knowticed Plus`
  String get demoAppPlus {
    return Intl.message(
      'Knowticed Plus',
      name: 'demoAppPlus',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message('Department', name: 'department', desc: '', args: []);
  }

  /// `Requests by Department`
  String get requestsByDepartment {
    return Intl.message(
      'Requests by Department',
      name: 'requestsByDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get Department {
    return Intl.message('Department', name: 'Department', desc: '', args: []);
  }

  /// `Customer Support`
  String get department_customer_support {
    return Intl.message(
      'Customer Support',
      name: 'department_customer_support',
      desc: '',
      args: [],
    );
  }

  /// `Executive`
  String get department_executive {
    return Intl.message(
      'Executive',
      name: 'department_executive',
      desc: '',
      args: [],
    );
  }

  /// `Finance`
  String get department_finance {
    return Intl.message(
      'Finance',
      name: 'department_finance',
      desc: '',
      args: [],
    );
  }

  /// `HR`
  String get department_hr {
    return Intl.message('HR', name: 'department_hr', desc: '', args: []);
  }

  /// `Human Resources`
  String get department_human_resources {
    return Intl.message(
      'Human Resources',
      name: 'department_human_resources',
      desc: '',
      args: [],
    );
  }

  /// `Information Technology`
  String get department_it {
    return Intl.message(
      'Information Technology',
      name: 'department_it',
      desc: '',
      args: [],
    );
  }

  /// `Marketing`
  String get department_marketing {
    return Intl.message(
      'Marketing',
      name: 'department_marketing',
      desc: '',
      args: [],
    );
  }

  /// `Operations`
  String get department_operations {
    return Intl.message(
      'Operations',
      name: 'department_operations',
      desc: '',
      args: [],
    );
  }

  /// `Sales`
  String get department_sales {
    return Intl.message('Sales', name: 'department_sales', desc: '', args: []);
  }

  /// `Department Availability`
  String get departmentAvailability {
    return Intl.message(
      'Department Availability',
      name: 'departmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Department cannot be empty`
  String get departmentCannotBeEmpty {
    return Intl.message(
      'Department cannot be empty',
      name: 'departmentCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Department Dashboard`
  String get departmentDashboard {
    return Intl.message(
      'Department Dashboard',
      name: 'departmentDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Department does not exist`
  String get departmentDoesNotExist {
    return Intl.message(
      'Department does not exist',
      name: 'departmentDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Department Manager`
  String get departmentManager {
    return Intl.message(
      'Department Manager',
      name: 'departmentManager',
      desc: '',
      args: [],
    );
  }

  /// `Department name must be at least 2 characters`
  String get departmentMinLength {
    return Intl.message(
      'Department name must be at least 2 characters',
      name: 'departmentMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Department Name Required.`
  String get departmentNameRequired {
    return Intl.message(
      'Department Name Required.',
      name: 'departmentNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Department Performance`
  String get departmentPerformance {
    return Intl.message(
      'Department Performance',
      name: 'departmentPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Department required when limit is enabled`
  String get departmentRequired {
    return Intl.message(
      'Department required when limit is enabled',
      name: 'departmentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Department-Restricted`
  String get departmentRestricted {
    return Intl.message(
      'Department-Restricted',
      name: 'departmentRestricted',
      desc: '',
      args: [],
    );
  }

  /// `Departments`
  String get departments {
    return Intl.message('Departments', name: 'departments', desc: '', args: []);
  }

  /// `Department Score`
  String get departmentScore {
    return Intl.message(
      'Department Score',
      name: 'departmentScore',
      desc: '',
      args: [],
    );
  }

  /// `Department Score`
  String get departmentScores {
    return Intl.message(
      'Department Score',
      name: 'departmentScores',
      desc: '',
      args: [],
    );
  }

  /// `Departments Score`
  String get departmentsScore {
    return Intl.message(
      'Departments Score',
      name: 'departmentsScore',
      desc: '',
      args: [],
    );
  }

  /// `Departments Weight`
  String get departmentsWeight {
    return Intl.message(
      'Departments Weight',
      name: 'departmentsWeight',
      desc: '',
      args: [],
    );
  }

  /// `DES`
  String get des {
    return Intl.message('DES', name: 'des', desc: '', args: []);
  }

  /// `Descending`
  String get descending {
    return Intl.message('Descending', name: 'descending', desc: '', args: []);
  }

  /// `Describe the feature`
  String get describe_the_feature {
    return Intl.message(
      'Describe the feature',
      name: 'describe_the_feature',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Description (Arabic)`
  String get descriptionAr {
    return Intl.message(
      'Description (Arabic)',
      name: 'descriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Description (Arabic)`
  String get descriptionArabic {
    return Intl.message(
      'Description (Arabic)',
      name: 'descriptionArabic',
      desc: '',
      args: [],
    );
  }

  /// `Description (English)`
  String get descriptionEn {
    return Intl.message(
      'Description (English)',
      name: 'descriptionEn',
      desc: '',
      args: [],
    );
  }

  /// `Description is required`
  String get descriptionIsRequired {
    return Intl.message(
      'Description is required',
      name: 'descriptionIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Description must be written in Arabic`
  String get descriptionMustBeWrittenInArabic {
    return Intl.message(
      'Description must be written in Arabic',
      name: 'descriptionMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Description of Incident`
  String get descriptionOfIncident {
    return Intl.message(
      'Description of Incident',
      name: 'descriptionOfIncident',
      desc: '',
      args: [],
    );
  }

  /// `Description of Issue/Service Needed`
  String get descriptionOfIssue {
    return Intl.message(
      'Description of Issue/Service Needed',
      name: 'descriptionOfIssue',
      desc: '',
      args: [],
    );
  }

  /// `Only . : " , special characters are allowed`
  String get descriptionSpecialChars {
    return Intl.message(
      'Only . : " , special characters are allowed',
      name: 'descriptionSpecialChars',
      desc: '',
      args: [],
    );
  }

  /// `Design`
  String get design {
    return Intl.message('Design', name: 'design', desc: '', args: []);
  }

  /// `Desktop View`
  String get desktopView {
    return Intl.message(
      'Desktop View',
      name: 'desktopView',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `To Do Details`
  String get detailsPageTitle {
    return Intl.message(
      'To Do Details',
      name: 'detailsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Development`
  String get development {
    return Intl.message('Development', name: 'development', desc: '', args: []);
  }

  /// `Development Team`
  String get developmentTeam {
    return Intl.message(
      'Development Team',
      name: 'developmentTeam',
      desc: '',
      args: [],
    );
  }

  /// `Different Approval Cycle For The Other Request Types`
  String get differentApprovalCycleForTheOtherRequestTypes {
    return Intl.message(
      'Different Approval Cycle For The Other Request Types',
      name: 'differentApprovalCycleForTheOtherRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Diploma`
  String get diploma {
    return Intl.message('Diploma', name: 'diploma', desc: '', args: []);
  }

  /// `Direct Message`
  String get directMessage {
    return Intl.message(
      'Direct Message',
      name: 'directMessage',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `Disappearing Messages`
  String get disappearingMessages {
    return Intl.message(
      'Disappearing Messages',
      name: 'disappearingMessages',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discard {
    return Intl.message('Discard', name: 'discard', desc: '', args: []);
  }

  /// `Discard Changes`
  String get discardChange {
    return Intl.message(
      'Discard Changes',
      name: 'discardChange',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get discardChanges {
    return Intl.message(
      'Discard Changes',
      name: 'discardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Discard Policy`
  String get discardPolicy {
    return Intl.message(
      'Discard Policy',
      name: 'discardPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discardTitle {
    return Intl.message('Discard', name: 'discardTitle', desc: '', args: []);
  }

  /// `Discount Percentage`
  String get discountPercentage {
    return Intl.message(
      'Discount Percentage',
      name: 'discountPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Dispatch Zone`
  String get dispatchZone {
    return Intl.message(
      'Dispatch Zone',
      name: 'dispatchZone',
      desc: '',
      args: [],
    );
  }

  /// `Display With`
  String get displayWith {
    return Intl.message(
      'Display With',
      name: 'displayWith',
      desc: '',
      args: [],
    );
  }

  /// `Divorced`
  String get divorced {
    return Intl.message('Divorced', name: 'divorced', desc: '', args: []);
  }

  /// `Djibouti`
  String get djibouti {
    return Intl.message('Djibouti', name: 'djibouti', desc: '', args: []);
  }

  /// `Document`
  String get document {
    return Intl.message('Document', name: 'document', desc: '', args: []);
  }

  /// `Document Description`
  String get document_description {
    return Intl.message(
      'Document Description',
      name: 'document_description',
      desc: '',
      args: [],
    );
  }

  /// `Document Name`
  String get document_name {
    return Intl.message(
      'Document Name',
      name: 'document_name',
      desc: '',
      args: [],
    );
  }

  /// `Document Type`
  String get document_type {
    return Intl.message(
      'Document Type',
      name: 'document_type',
      desc: '',
      args: [],
    );
  }

  /// `Document Utilization`
  String get document_utilization {
    return Intl.message(
      'Document Utilization',
      name: 'document_utilization',
      desc: '',
      args: [],
    );
  }

  /// `Document Details`
  String get documentDetails {
    return Intl.message(
      'Document Details',
      name: 'documentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Document Rejected`
  String get documentFileRejected {
    return Intl.message(
      'Document Rejected',
      name: 'documentFileRejected',
      desc: '',
      args: [],
    );
  }

  /// `Document Management`
  String get documentManagement {
    return Intl.message(
      'Document Management',
      name: 'documentManagement',
      desc: '',
      args: [],
    );
  }

  /// `The document has been rejected successfully`
  String get documentRemoveSuccess {
    return Intl.message(
      'The document has been rejected successfully',
      name: 'documentRemoveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get documents {
    return Intl.message('Documents', name: 'documents', desc: '', args: []);
  }

  /// `Document Title`
  String get documentTitle {
    return Intl.message(
      'Document Title',
      name: 'documentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Document Utilization`
  String get documentUtilization {
    return Intl.message(
      'Document Utilization',
      name: 'documentUtilization',
      desc: '',
      args: [],
    );
  }

  /// `Does each department carry a distinct weighting?`
  String get doesEachDepartmentCarryADistinctWeighting {
    return Intl.message(
      'Does each department carry a distinct weighting?',
      name: 'doesEachDepartmentCarryADistinctWeighting',
      desc: '',
      args: [],
    );
  }

  /// `Dominican`
  String get dominican {
    return Intl.message('Dominican', name: 'dominican', desc: '', args: []);
  }

  /// `Done`
  String get Done {
    return Intl.message('Done', name: 'Done', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Done Projects`
  String get doneProjects {
    return Intl.message(
      'Done Projects',
      name: 'doneProjects',
      desc: '',
      args: [],
    );
  }

  /// `Done Services`
  String get doneServices {
    return Intl.message(
      'Done Services',
      name: 'doneServices',
      desc: '',
      args: [],
    );
  }

  /// `Done Services`
  String get DoneServices {
    return Intl.message(
      'Done Services',
      name: 'DoneServices',
      desc: '',
      args: [],
    );
  }

  /// `Double commas not allowed`
  String get doubleCommas {
    return Intl.message(
      'Double commas not allowed',
      name: 'doubleCommas',
      desc: '',
      args: [],
    );
  }

  /// `Double commas not allowed`
  String get doubleCommasNotAllowed {
    return Intl.message(
      'Double commas not allowed',
      name: 'doubleCommasNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Download as PNG`
  String get downloadAsPng {
    return Intl.message(
      'Download as PNG',
      name: 'downloadAsPng',
      desc: '',
      args: [],
    );
  }

  /// `Download Complete`
  String get downloadComplete {
    return Intl.message(
      'Download Complete',
      name: 'downloadComplete',
      desc: '',
      args: [],
    );
  }

  /// `Download Documents`
  String get downloadDocuments {
    return Intl.message(
      'Download Documents',
      name: 'downloadDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Download Failed`
  String get downloadFailed {
    return Intl.message(
      'Download Failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Download File`
  String get downloadFile {
    return Intl.message(
      'Download File',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Download Form Digital Assets`
  String get downloadFormDigitalAssets {
    return Intl.message(
      'Download Form Digital Assets',
      name: 'downloadFormDigitalAssets',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get downloading {
    return Intl.message('Downloading', name: 'downloading', desc: '', args: []);
  }

  /// `Downloading File`
  String get downloadingFile {
    return Intl.message(
      'Downloading File',
      name: 'downloadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Download Page`
  String get downloadPage {
    return Intl.message(
      'Download Page',
      name: 'downloadPage',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of About This Platform`
  String get downloadPDFofAboutThisApp {
    return Intl.message(
      'Download PDF of About This Platform',
      name: 'downloadPDFofAboutThisApp',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of Privacy And Policy`
  String get downloadPDFofPrivacyAndPolicy {
    return Intl.message(
      'Download PDF of Privacy And Policy',
      name: 'downloadPDFofPrivacyAndPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF of Terms And Condition`
  String get downloadPDFofTermsAndCondition {
    return Intl.message(
      'Download PDF of Terms And Condition',
      name: 'downloadPDFofTermsAndCondition',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get downloads {
    return Intl.message('Downloads', name: 'downloads', desc: '', args: []);
  }

  /// `Download Submissions`
  String get downloadSubmissions {
    return Intl.message(
      'Download Submissions',
      name: 'downloadSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully downloaded this document.`
  String get downloadSuccessMessage {
    return Intl.message(
      'You have successfully downloaded this document.',
      name: 'downloadSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Download Successful`
  String get downloadSuccessTitle {
    return Intl.message(
      'Download Successful',
      name: 'downloadSuccessTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to proceed to the next product?`
  String get doYouWantToProceedToNextProduct {
    return Intl.message(
      'Do you want to proceed to the next product?',
      name: 'doYouWantToProceedToNextProduct',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save this role as draft?`
  String get doYouWantToSaveThisRoleAsDraft {
    return Intl.message(
      'Do you want to save this role as draft?',
      name: 'doYouWantToSaveThisRoleAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get draft {
    return Intl.message('Draft', name: 'draft', desc: '', args: []);
  }

  /// `Draft Roles`
  String get draftRoles {
    return Intl.message('Draft Roles', name: 'draftRoles', desc: '', args: []);
  }

  /// `Draft role completed successfully`
  String get draftRoleCompletedSuccessfully {
    return Intl.message(
      'Draft role completed successfully',
      name: 'draftRoleCompletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Draft Saved`
  String get draftSaved {
    return Intl.message('Draft Saved', name: 'draftSaved', desc: '', args: []);
  }

  /// `Draft saved successfully!`
  String get draftSavedSuccessfully {
    return Intl.message(
      'Draft saved successfully!',
      name: 'draftSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Draft Service`
  String get draftService {
    return Intl.message(
      'Draft Service',
      name: 'draftService',
      desc: '',
      args: [],
    );
  }

  /// `Drag and drop files here`
  String get dragDropFilesHere {
    return Intl.message(
      'Drag and drop files here',
      name: 'dragDropFilesHere',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop files here`
  String get dragDropHere {
    return Intl.message(
      'Drag & Drop files here',
      name: 'dragDropHere',
      desc: '',
      args: [],
    );
  }

  /// `Driving License`
  String get drivingLicense {
    return Intl.message(
      'Driving License',
      name: 'drivingLicense',
      desc: '',
      args: [],
    );
  }

  /// `Dry Storage`
  String get dryStorage {
    return Intl.message('Dry Storage', name: 'dryStorage', desc: '', args: []);
  }

  /// `Dubai`
  String get dubai {
    return Intl.message('Dubai', name: 'dubai', desc: '', args: []);
  }

  /// `Due Date`
  String get dueDate {
    return Intl.message('Due Date', name: 'dueDate', desc: '', args: []);
  }

  /// `Due Date of Return`
  String get dueDateOfReturn {
    return Intl.message(
      'Due Date of Return',
      name: 'dueDateOfReturn',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate emails not allowed`
  String get duplicateEmails {
    return Intl.message(
      'Duplicate emails not allowed',
      name: 'duplicateEmails',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate Form`
  String get duplicateForm {
    return Intl.message(
      'Duplicate Form',
      name: 'duplicateForm',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate Request`
  String get duplicateRequest {
    return Intl.message(
      'Duplicate Request',
      name: 'duplicateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate storage location.`
  String get duplicateStorageLocation {
    return Intl.message(
      'Duplicate storage location.',
      name: 'duplicateStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate value – must be unique`
  String get duplicateValue {
    return Intl.message(
      'Duplicate value – must be unique',
      name: 'duplicateValue',
      desc: '',
      args: [],
    );
  }

  /// `Duplication`
  String get duplication {
    return Intl.message('Duplication', name: 'duplication', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Hours`
  String get duration_unit_hours {
    return Intl.message(
      'Hours',
      name: 'duration_unit_hours',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get duration_unit_minutes {
    return Intl.message(
      'Minutes',
      name: 'duration_unit_minutes',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get duration_unit_seconds {
    return Intl.message(
      'Seconds',
      name: 'duration_unit_seconds',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get duration_unit_week {
    return Intl.message('Week', name: 'duration_unit_week', desc: '', args: []);
  }

  /// `Duration of Service`
  String get durationOfService {
    return Intl.message(
      'Duration of Service',
      name: 'durationOfService',
      desc: '',
      args: [],
    );
  }

  /// `Duration of Service`
  String get DurationofService {
    return Intl.message(
      'Duration of Service',
      name: 'DurationofService',
      desc: '',
      args: [],
    );
  }

  /// `Dutch`
  String get dutch {
    return Intl.message('Dutch', name: 'dutch', desc: '', args: []);
  }

  /// `Earliest Submitted`
  String get earliestSubmitted {
    return Intl.message(
      'Earliest Submitted',
      name: 'earliestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `East Timorese`
  String get eastTimorese {
    return Intl.message(
      'East Timorese',
      name: 'eastTimorese',
      desc: '',
      args: [],
    );
  }

  /// `Ecuadorean`
  String get ecuadorean {
    return Intl.message('Ecuadorean', name: 'ecuadorean', desc: '', args: []);
  }

  /// `Edit`
  String get Edit {
    return Intl.message('Edit', name: 'Edit', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Editable`
  String get editable {
    return Intl.message('Editable', name: 'editable', desc: '', args: []);
  }

  /// `Edit Access`
  String get editAccess {
    return Intl.message('Edit Access', name: 'editAccess', desc: '', args: []);
  }

  /// `Edit Account`
  String get editAccount {
    return Intl.message(
      'Edit Account',
      name: 'editAccount',
      desc: '',
      args: [],
    );
  }

  /// `Edit Contact`
  String get editContact {
    return Intl.message(
      'Edit Contact',
      name: 'editContact',
      desc: '',
      args: [],
    );
  }

  /// `Edit Controls`
  String get editControls {
    return Intl.message(
      'Edit Controls',
      name: 'editControls',
      desc: '',
      args: [],
    );
  }

  /// `Edit control screen not implemented yet`
  String get editControlScreenNotImplemented {
    return Intl.message(
      'Edit control screen not implemented yet',
      name: 'editControlScreenNotImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Edit Deal`
  String get editDeal {
    return Intl.message('Edit Deal', name: 'editDeal', desc: '', args: []);
  }

  /// `Create Without Need Approval`
  String get createWithoutNeedApproval {
    return Intl.message(
      'Create Without Need Approval',
      name: 'createWithoutNeedApproval',
      desc: '',
      args: [],
    );
  }

  /// `Edit Document With Approval`
  String get editDocumentWithApproval {
    return Intl.message(
      'Edit Document With Approval',
      name: 'editDocumentWithApproval',
      desc: '',
      args: [],
    );
  }

  /// `Edit Document Without Approval`
  String get editDocumentWithoutApproval {
    return Intl.message(
      'Edit Document Without Approval',
      name: 'editDocumentWithoutApproval',
      desc: '',
      args: [],
    );
  }

  /// `Edited`
  String get edited {
    return Intl.message('Edited', name: 'edited', desc: '', args: []);
  }

  /// `Edited Group`
  String get editedGroup {
    return Intl.message(
      'Edited Group',
      name: 'editedGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edited Modules`
  String get editedModules {
    return Intl.message(
      'Edited Modules',
      name: 'editedModules',
      desc: '',
      args: [],
    );
  }

  /// `Edited Service`
  String get editedService {
    return Intl.message(
      'Edited Service',
      name: 'editedService',
      desc: '',
      args: [],
    );
  }

  /// `Edit Employee`
  String get editEmployee {
    return Intl.message(
      'Edit Employee',
      name: 'editEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Edit File Name`
  String get editFileName {
    return Intl.message(
      'Edit File Name',
      name: 'editFileName',
      desc: '',
      args: [],
    );
  }

  /// `Edit Form`
  String get editForm {
    return Intl.message('Edit Form', name: 'editForm', desc: '', args: []);
  }

  /// `Edit Group`
  String get editGroup {
    return Intl.message('Edit Group', name: 'editGroup', desc: '', args: []);
  }

  /// `Editing`
  String get Editing {
    return Intl.message('Editing', name: 'Editing', desc: '', args: []);
  }

  /// `Editing Access Details`
  String get editingAccessDetails {
    return Intl.message(
      'Editing Access Details',
      name: 'editingAccessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Editing Control`
  String get editingControl {
    return Intl.message(
      'Editing Control',
      name: 'editingControl',
      desc: '',
      args: [],
    );
  }

  /// `Editing Controls Weight`
  String get editingControlsWeight {
    return Intl.message(
      'Editing Controls Weight',
      name: 'editingControlsWeight',
      desc: '',
      args: [],
    );
  }

  /// `Editing {documentName} Details`
  String editingDocumentDetails(Object documentName) {
    return Intl.message(
      'Editing $documentName Details',
      name: 'editingDocumentDetails',
      desc: '',
      args: [documentName],
    );
  }

  /// `Editing Service Name`
  String get EditingerviceName {
    return Intl.message(
      'Editing Service Name',
      name: 'EditingerviceName',
      desc: '',
      args: [],
    );
  }

  /// `Editing Form`
  String get editingForm {
    return Intl.message(
      'Editing Form',
      name: 'editingForm',
      desc: '',
      args: [],
    );
  }

  /// `Editing GRC Module`
  String get editingGrcModule {
    return Intl.message(
      'Editing GRC Module',
      name: 'editingGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Editing Group Details`
  String get editingGroupDetails {
    return Intl.message(
      'Editing Group Details',
      name: 'editingGroupDetails',
      desc: '',
      args: [],
    );
  }

  /// `Editing Health Insurance`
  String get editingHealthInsurance {
    return Intl.message(
      'Editing Health Insurance',
      name: 'editingHealthInsurance',
      desc: '',
      args: [],
    );
  }

  /// `Editing Location`
  String get editingLocation {
    return Intl.message(
      'Editing Location',
      name: 'editingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Editing Modules`
  String get editingModules {
    return Intl.message(
      'Editing Modules',
      name: 'editingModules',
      desc: '',
      args: [],
    );
  }

  /// `Editing My Personal Data`
  String get editingMyPersonalData {
    return Intl.message(
      'Editing My Personal Data',
      name: 'editingMyPersonalData',
      desc: '',
      args: [],
    );
  }

  /// `Editing Policies Weight`
  String get editingPoliciesWeight {
    return Intl.message(
      'Editing Policies Weight',
      name: 'editingPoliciesWeight',
      desc: '',
      args: [],
    );
  }

  /// `Editing Policy`
  String get editingPolicy {
    return Intl.message(
      'Editing Policy',
      name: 'editingPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Editing Product Details`
  String get editingProductDetails {
    return Intl.message(
      'Editing Product Details',
      name: 'editingProductDetails',
      desc: '',
      args: [],
    );
  }

  /// `Editing Request Type`
  String get editingRequestType {
    return Intl.message(
      'Editing Request Type',
      name: 'editingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Editing Role`
  String get editingRole {
    return Intl.message(
      'Editing Role',
      name: 'editingRole',
      desc: '',
      args: [],
    );
  }

  /// `Editing Service`
  String get editingService {
    return Intl.message(
      'Editing Service',
      name: 'editingService',
      desc: '',
      args: [],
    );
  }

  /// `Editing Supplier Details`
  String get editingSupplierDetails {
    return Intl.message(
      'Editing Supplier Details',
      name: 'editingSupplierDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit Lead`
  String get editLead {
    return Intl.message('Edit Lead', name: 'editLead', desc: '', args: []);
  }

  /// `Edit Meeting`
  String get editMeeting {
    return Intl.message(
      'Edit Meeting',
      name: 'editMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get EditMessage {
    return Intl.message(
      'Edit Message',
      name: 'EditMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Message`
  String get editMessage {
    return Intl.message(
      'Edit Message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Permission`
  String get editPermission {
    return Intl.message(
      'Edit Permission',
      name: 'editPermission',
      desc: '',
      args: [],
    );
  }

  /// `Edit Policy`
  String get editPolicy {
    return Intl.message('Edit Policy', name: 'editPolicy', desc: '', args: []);
  }

  /// `Edit Product Information`
  String get editProductInformation {
    return Intl.message(
      'Edit Product Information',
      name: 'editProductInformation',
      desc: '',
      args: [],
    );
  }

  /// `Edit Qiyas Details`
  String get editQiyasDetails {
    return Intl.message(
      'Edit Qiyas Details',
      name: 'editQiyasDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit Role`
  String get editRole {
    return Intl.message('Edit Role', name: 'editRole', desc: '', args: []);
  }

  /// `Edit Role Permissions`
  String get editRolePermissions {
    return Intl.message(
      'Edit Role Permissions',
      name: 'editRolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Edit Role Settings Permissions`
  String get editRoleSettingsPermissions {
    return Intl.message(
      'Edit Role Settings Permissions',
      name: 'editRoleSettingsPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service`
  String get editService {
    return Intl.message(
      'Edit Service',
      name: 'editService',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service Provider`
  String get editServiceProvider {
    return Intl.message(
      'Edit Service Provider',
      name: 'editServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Editing Success`
  String get editSuccess {
    return Intl.message(
      'Editing Success',
      name: 'editSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Edit Uploaded Document`
  String get editUploadedDocument {
    return Intl.message(
      'Edit Uploaded Document',
      name: 'editUploadedDocument',
      desc: '',
      args: [],
    );
  }

  /// `Edit your message`
  String get Edityourmessage {
    return Intl.message(
      'Edit your message',
      name: 'Edityourmessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit your message`
  String get editYourMessage {
    return Intl.message(
      'Edit your message',
      name: 'editYourMessage',
      desc: '',
      args: [],
    );
  }

  /// `Education Certificate`
  String get educationCertificate {
    return Intl.message(
      'Education Certificate',
      name: 'educationCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Efficient Event Management`
  String get efficientEventManagement {
    return Intl.message(
      'Efficient Event Management',
      name: 'efficientEventManagement',
      desc: '',
      args: [],
    );
  }

  /// `Organize and manage company events seamlessly with the help of our dedicated media team. From sending invitations to gathering feedback, our event management tools ensure every event runs smoothly and successfully.`
  String get efficientEventManagementBody {
    return Intl.message(
      'Organize and manage company events seamlessly with the help of our dedicated media team. From sending invitations to gathering feedback, our event management tools ensure every event runs smoothly and successfully.',
      name: 'efficientEventManagementBody',
      desc: '',
      args: [],
    );
  }

  /// `Effortless Task Management`
  String get effortlessTaskManagement {
    return Intl.message(
      'Effortless Task Management',
      name: 'effortlessTaskManagement',
      desc: '',
      args: [],
    );
  }

  /// `Stay on top of your workload with real-time updates and seamless collaboration. Our task management tools ensure everyone knows what needs to be done and when, fostering accountability and efficiency across your team.`
  String get effortlessTaskManagementBody {
    return Intl.message(
      'Stay on top of your workload with real-time updates and seamless collaboration. Our task management tools ensure everyone knows what needs to be done and when, fostering accountability and efficiency across your team.',
      name: 'effortlessTaskManagementBody',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get eGP {
    return Intl.message('EGP', name: 'eGP', desc: '', args: []);
  }

  /// `Egyptian`
  String get egyptian {
    return Intl.message('Egyptian', name: 'egyptian', desc: '', args: []);
  }

  /// `Electrical`
  String get electrical {
    return Intl.message('Electrical', name: 'electrical', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Email does not exist`
  String get emailDoesNotExist {
    return Intl.message(
      'Email does not exist',
      name: 'emailDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get emailRequired {
    return Intl.message(
      'Email is required',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Email Required`
  String get emailRequired2 {
    return Intl.message(
      'Email Required',
      name: 'emailRequired2',
      desc: '',
      args: [],
    );
  }

  /// `Emails must be comma-separated without spaces or special characters`
  String get emailsCommaSeparated {
    return Intl.message(
      'Emails must be comma-separated without spaces or special characters',
      name: 'emailsCommaSeparated',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Contact`
  String get emergencyContact {
    return Intl.message(
      'Emergency Contact',
      name: 'emergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Contact Information`
  String get emergencyContactInformation {
    return Intl.message(
      'Emergency Contact Information',
      name: 'emergencyContactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Vacation`
  String get emergencyVacation {
    return Intl.message(
      'Emergency Vacation',
      name: 'emergencyVacation',
      desc: '',
      args: [],
    );
  }

  /// `Emirian`
  String get emirian {
    return Intl.message('Emirian', name: 'emirian', desc: '', args: []);
  }

  /// `Employee`
  String get employee {
    return Intl.message('Employee', name: 'employee', desc: '', args: []);
  }

  /// `Employee Assigned Information`
  String get employeeAssignedInformation {
    return Intl.message(
      'Employee Assigned Information',
      name: 'employeeAssignedInformation',
      desc: '',
      args: [],
    );
  }

  /// `Employee Details`
  String get employeeDetails {
    return Intl.message(
      'Employee Details',
      name: 'employeeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Employee Email`
  String get employeeEmail {
    return Intl.message(
      'Employee Email',
      name: 'employeeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Employee Info`
  String get employeeInfo {
    return Intl.message(
      'Employee Info',
      name: 'employeeInfo',
      desc: '',
      args: [],
    );
  }

  /// `Employee Information`
  String get EmployeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'EmployeeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Employee Information`
  String get employeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'employeeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Employee Name`
  String get employeeName {
    return Intl.message(
      'Employee Name',
      name: 'employeeName',
      desc: '',
      args: [],
    );
  }

  /// `Employee Phone`
  String get employeePhone {
    return Intl.message(
      'Employee Phone',
      name: 'employeePhone',
      desc: '',
      args: [],
    );
  }

  /// `Employee Profile`
  String get employeeProfile {
    return Intl.message(
      'Employee Profile',
      name: 'employeeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Employee Removed`
  String get employeeRemoved {
    return Intl.message(
      'Employee Removed',
      name: 'employeeRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get Employees {
    return Intl.message('Employees', name: 'Employees', desc: '', args: []);
  }

  /// `Employees`
  String get employees {
    return Intl.message('Employees', name: 'employees', desc: '', args: []);
  }

  /// `Employees Added`
  String get employeesAdded {
    return Intl.message(
      'Employees Added',
      name: 'employeesAdded',
      desc: '',
      args: [],
    );
  }

  /// `Employees Attendance`
  String get employeesAttendance {
    return Intl.message(
      'Employees Attendance',
      name: 'employeesAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Employee Self Service`
  String get employeeSelfService {
    return Intl.message(
      'Employee Self Service',
      name: 'employeeSelfService',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get employeeStatusActive {
    return Intl.message(
      'Active',
      name: 'employeeStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get employeeStatusAll {
    return Intl.message('All', name: 'employeeStatusAll', desc: '', args: []);
  }

  /// `Deactivated`
  String get employeeStatusDeactivated {
    return Intl.message(
      'Deactivated',
      name: 'employeeStatusDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get employeeStatusInactive {
    return Intl.message(
      'Inactive',
      name: 'employeeStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `Locked`
  String get employeeStatusLocked {
    return Intl.message(
      'Locked',
      name: 'employeeStatusLocked',
      desc: '',
      args: [],
    );
  }

  /// `Locked with Send Request`
  String get employeeStatusLockedWithRequest {
    return Intl.message(
      'Locked with Send Request',
      name: 'employeeStatusLockedWithRequest',
      desc: '',
      args: [],
    );
  }

  /// `Request to Reset Password`
  String get employeeStatusResetPassword {
    return Intl.message(
      'Request to Reset Password',
      name: 'employeeStatusResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Activation`
  String get employeeStatusWillBeActivated {
    return Intl.message(
      'Scheduled Activation',
      name: 'employeeStatusWillBeActivated',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Deactivation`
  String get employeeStatusWillBeDeactivated {
    return Intl.message(
      'Scheduled Deactivation',
      name: 'employeeStatusWillBeDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Employees Terminated`
  String get employeesTerminated {
    return Intl.message(
      'Employees Terminated',
      name: 'employeesTerminated',
      desc: '',
      args: [],
    );
  }

  /// `Empty control name between commas`
  String get emptyControlNameBetweenCommas {
    return Intl.message(
      'Empty control name between commas',
      name: 'emptyControlNameBetweenCommas',
      desc: '',
      args: [],
    );
  }

  /// `Empty department between commas`
  String get emptyDepartment {
    return Intl.message(
      'Empty department between commas',
      name: 'emptyDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Empty email between commas`
  String get emptyEmail {
    return Intl.message(
      'Empty email between commas',
      name: 'emptyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enable Drawer Reordering`
  String get enableDrawerReordering {
    return Intl.message(
      'Enable Drawer Reordering',
      name: 'enableDrawerReordering',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get end_date {
    return Intl.message('End Date', name: 'end_date', desc: '', args: []);
  }

  /// `End Date`
  String get endDate {
    return Intl.message('End Date', name: 'endDate', desc: '', args: []);
  }

  /// `End date cannot be after the policy end date`
  String get endDateCannotBeAfterThePolicyEndDate {
    return Intl.message(
      'End date cannot be after the policy end date',
      name: 'endDateCannotBeAfterThePolicyEndDate',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before start date`
  String get endDateCannotBeBeforeStartDate {
    return Intl.message(
      'End date cannot be before start date',
      name: 'endDateCannotBeBeforeStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before the policy start date`
  String get endDateCannotBeBeforeThePolicyStartDate {
    return Intl.message(
      'End date cannot be before the policy start date',
      name: 'endDateCannotBeBeforeThePolicyStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after start date`
  String get endDateMustBeAfterStartDate {
    return Intl.message(
      'End date must be after start date',
      name: 'endDateMustBeAfterStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End date must be after start date`
  String get enddatemustbeafterstartdate {
    return Intl.message(
      'End date must be after start date',
      name: 'enddatemustbeafterstartdate',
      desc: '',
      args: [],
    );
  }

  /// `End Time`
  String get endTime {
    return Intl.message('End Time', name: 'endTime', desc: '', args: []);
  }

  /// `End time must be after start time`
  String get endtimemustbeafterstarttime {
    return Intl.message(
      'End time must be after start time',
      name: 'endtimemustbeafterstarttime',
      desc: '',
      args: [],
    );
  }

  /// `Engaged`
  String get engaged {
    return Intl.message('Engaged', name: 'engaged', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `English Language Mandatory`
  String get englishLanguageMandatory {
    return Intl.message(
      'English Language Mandatory',
      name: 'englishLanguageMandatory',
      desc: '',
      args: [],
    );
  }

  /// `English not allowed`
  String get englishNotAllowed {
    return Intl.message(
      'English not allowed',
      name: 'englishNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `English letters only`
  String get englishOnly {
    return Intl.message(
      'English letters only',
      name: 'englishOnly',
      desc: '',
      args: [],
    );
  }

  /// `Ensure all equipment is functional.`
  String get ensureAllEquipmentIsFunctional {
    return Intl.message(
      'Ensure all equipment is functional.',
      name: 'ensureAllEquipmentIsFunctional',
      desc: '',
      args: [],
    );
  }

  /// `Ensure all security protocols are followed.`
  String get ensureAllSecurityProtocolsAreFollowed {
    return Intl.message(
      'Ensure all security protocols are followed.',
      name: 'ensureAllSecurityProtocolsAreFollowed',
      desc: '',
      args: [],
    );
  }

  /// `Ensure room temperature remains stable.`
  String get ensureRoomTemperatureRemainsStable {
    return Intl.message(
      'Ensure room temperature remains stable.',
      name: 'ensureRoomTemperatureRemainsStable',
      desc: '',
      args: [],
    );
  }

  /// `Enter bug details`
  String get enter_bug_details {
    return Intl.message(
      'Enter bug details',
      name: 'enter_bug_details',
      desc: '',
      args: [],
    );
  }

  /// `Enter your comments`
  String get enter_your_comments {
    return Intl.message(
      'Enter your comments',
      name: 'enter_your_comments',
      desc: '',
      args: [],
    );
  }

  /// `Enter approval justification here...`
  String get enterApprovalJustification {
    return Intl.message(
      'Enter approval justification here...',
      name: 'enterApprovalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Birth Date`
  String get enterbirthday {
    return Intl.message(
      'Enter Your Birth Date',
      name: 'enterbirthday',
      desc: '',
      args: [],
    );
  }

  /// `Enter City`
  String get enterCity {
    return Intl.message('Enter City', name: 'enterCity', desc: '', args: []);
  }

  /// `Enter Company Name`
  String get enterCompanyName {
    return Intl.message(
      'Enter Company Name',
      name: 'enterCompanyName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Contact Relation`
  String get enterContactRelation {
    return Intl.message(
      'Enter Contact Relation',
      name: 'enterContactRelation',
      desc: '',
      args: [],
    );
  }

  /// `Enter Country`
  String get enterCountry {
    return Intl.message(
      'Enter Country',
      name: 'enterCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter Default Password`
  String get enterDefaultPassword {
    return Intl.message(
      'Enter Default Password',
      name: 'enterDefaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Description`
  String get enterDescription {
    return Intl.message(
      'Enter Description',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email`
  String get enterEmail {
    return Intl.message('Enter Email', name: 'enterEmail', desc: '', args: []);
  }

  /// `Enter Expiration Time`
  String get enterExpirationTime {
    return Intl.message(
      'Enter Expiration Time',
      name: 'enterExpirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Enter file name`
  String get enterFileName {
    return Intl.message(
      'Enter file name',
      name: 'enterFileName',
      desc: '',
      args: [],
    );
  }

  /// `Enter First Name`
  String get enterFirstName {
    return Intl.message(
      'Enter First Name',
      name: 'enterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Hex Code`
  String get enterhexacolor {
    return Intl.message(
      'Enter Hex Code',
      name: 'enterhexacolor',
      desc: '',
      args: [],
    );
  }

  /// `Enter Hobby`
  String get enterHobby {
    return Intl.message('Enter Hobby', name: 'enterHobby', desc: '', args: []);
  }

  /// `Enter Insurance Name`
  String get enterInsuranceName {
    return Intl.message(
      'Enter Insurance Name',
      name: 'enterInsuranceName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Insurance Police Number`
  String get enterInsurancePoliceNumber {
    return Intl.message(
      'Enter Insurance Police Number',
      name: 'enterInsurancePoliceNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Language`
  String get enterLanguage {
    return Intl.message(
      'Enter Language',
      name: 'enterLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Enter Last Name`
  String get enterLastName {
    return Intl.message(
      'Enter Last Name',
      name: 'enterLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Middle Name`
  String get enterMiddleName {
    return Intl.message(
      'Enter Middle Name',
      name: 'enterMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter New Email`
  String get enterNewEmail {
    return Intl.message(
      'Enter New Email',
      name: 'enterNewEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter New Password`
  String get enterNewPassword {
    return Intl.message(
      'Enter New Password',
      name: 'enterNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Old Password`
  String get enterOldPassword {
    return Intl.message(
      'Enter Old Password',
      name: 'enterOldPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Order ID`
  String get enterOrderId {
    return Intl.message(
      'Enter Order ID',
      name: 'enterOrderId',
      desc: '',
      args: [],
    );
  }

  /// `Percentage`
  String get EnterPercentage {
    return Intl.message(
      'Percentage',
      name: 'EnterPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Enter Phone Number`
  String get enterPhoneNumber {
    return Intl.message(
      'Enter Phone Number',
      name: 'enterPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Policy Number`
  String get enterPolicyNumber {
    return Intl.message(
      'Enter Policy Number',
      name: 'enterPolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Postal Code`
  String get enterPostalCode {
    return Intl.message(
      'Enter Postal Code',
      name: 'enterPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter rejection reason here...`
  String get enterRejectionReason {
    return Intl.message(
      'Enter rejection reason here...',
      name: 'enterRejectionReason',
      desc: '',
      args: [],
    );
  }

  /// `Enters Country`
  String get entersCountry {
    return Intl.message(
      'Enters Country',
      name: 'entersCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter Skill`
  String get enterSkill {
    return Intl.message('Enter Skill', name: 'enterSkill', desc: '', args: []);
  }

  /// `Enter State Or Province`
  String get enterStateOrProvince {
    return Intl.message(
      'Enter State Or Province',
      name: 'enterStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter Street Address`
  String get enterStreetAddress {
    return Intl.message(
      'Enter Street Address',
      name: 'enterStreetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter Tax Number`
  String get enterTaxNumber {
    return Intl.message(
      'Enter Tax Number',
      name: 'enterTaxNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic First Name`
  String get enterTheArabicFirstName {
    return Intl.message(
      'Enter The Arabic First Name',
      name: 'enterTheArabicFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic Last Name`
  String get enterTheArabicLastName {
    return Intl.message(
      'Enter The Arabic Last Name',
      name: 'enterTheArabicLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Arabic Middle Name`
  String get enterTheArabicMiddleName {
    return Intl.message(
      'Enter The Arabic Middle Name',
      name: 'enterTheArabicMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The City`
  String get enterTheCity {
    return Intl.message(
      'Enter The City',
      name: 'enterTheCity',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Country`
  String get enterTheCountry {
    return Intl.message(
      'Enter The Country',
      name: 'enterTheCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Email`
  String get enterTheEmail {
    return Intl.message(
      'Enter The Email',
      name: 'enterTheEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter The First Name`
  String get enterTheFirstName {
    return Intl.message(
      'Enter The First Name',
      name: 'enterTheFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Last Name`
  String get enterTheLastName {
    return Intl.message(
      'Enter The Last Name',
      name: 'enterTheLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Middle Name`
  String get enterTheMiddleName {
    return Intl.message(
      'Enter The Middle Name',
      name: 'enterTheMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter The National ID`
  String get enterTheNationalID {
    return Intl.message(
      'Enter The National ID',
      name: 'enterTheNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Enter The National ID Expiration Date`
  String get enterTheNationalIDExpirationDate {
    return Intl.message(
      'Enter The National ID Expiration Date',
      name: 'enterTheNationalIDExpirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Period`
  String get enterThePeriod {
    return Intl.message(
      'Enter The Period',
      name: 'enterThePeriod',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Phone Number`
  String get enterThePhoneNumber {
    return Intl.message(
      'Enter The Phone Number',
      name: 'enterThePhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Postal Code`
  String get enterThePostalCode {
    return Intl.message(
      'Enter The Postal Code',
      name: 'enterThePostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter The State Or Province`
  String get enterTheStateOrProvince {
    return Intl.message(
      'Enter The State Or Province',
      name: 'enterTheStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Work Days`
  String get enterTheWorkDays {
    return Intl.message(
      'Enter The Work Days',
      name: 'enterTheWorkDays',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your City`
  String get enterYourCity {
    return Intl.message(
      'Enter Your City',
      name: 'enterYourCity',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Country`
  String get enterYourCountry {
    return Intl.message(
      'Enter Your Country',
      name: 'enterYourCountry',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Email`
  String get enterYourEmail {
    return Intl.message(
      'Enter Your Email',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your First Name`
  String get enterYourFirstName {
    return Intl.message(
      'Enter Your First Name',
      name: 'enterYourFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Last Name`
  String get enterYourLastName {
    return Intl.message(
      'Enter Your Last Name',
      name: 'enterYourLastName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Middle Name`
  String get enterYourMiddleName {
    return Intl.message(
      'Enter Your Middle Name',
      name: 'enterYourMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Number`
  String get enterYourMobileNumber {
    return Intl.message(
      'Enter Your Mobile Number',
      name: 'enterYourMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Phone`
  String get enterYourMobilePhone {
    return Intl.message(
      'Enter Your Mobile Phone',
      name: 'enterYourMobilePhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Password`
  String get enterYourPassword {
    return Intl.message(
      'Enter Your Password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your State Or Province`
  String get enterYourStateOrProvince {
    return Intl.message(
      'Enter Your State Or Province',
      name: 'enterYourStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Street Address`
  String get enterYourStreetAddress {
    return Intl.message(
      'Enter Your Street Address',
      name: 'enterYourStreetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Entry Date`
  String get entryDate {
    return Intl.message('Entry Date', name: 'entryDate', desc: '', args: []);
  }

  /// `Equal Control Weight`
  String get equalControlWeight {
    return Intl.message(
      'Equal Control Weight',
      name: 'equalControlWeight',
      desc: '',
      args: [],
    );
  }

  /// `Equal Policy Weight`
  String get equalPolicyWeight {
    return Intl.message(
      'Equal Policy Weight',
      name: 'equalPolicyWeight',
      desc: '',
      args: [],
    );
  }

  /// `Equal Weight`
  String get equalWeight {
    return Intl.message(
      'Equal Weight',
      name: 'equalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Equal Weights`
  String get equalWeights {
    return Intl.message(
      'Equal Weights',
      name: 'equalWeights',
      desc: '',
      args: [],
    );
  }

  /// `Equatorial Guinean`
  String get equatorialGuinean {
    return Intl.message(
      'Equatorial Guinean',
      name: 'equatorialGuinean',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Available`
  String get equipmentAvailable {
    return Intl.message(
      'Equipment Available',
      name: 'equipmentAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Available is required`
  String get equipmentAvailableRequired {
    return Intl.message(
      'Equipment Available is required',
      name: 'equipmentAvailableRequired',
      desc: '',
      args: [],
    );
  }

  /// `Equipment Check`
  String get equipmentCheck {
    return Intl.message(
      'Equipment Check',
      name: 'equipmentCheck',
      desc: '',
      args: [],
    );
  }

  /// `Eritrean`
  String get eritrean {
    return Intl.message('Eritrean', name: 'eritrean', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Error Downloading File`
  String get error_downloading_file {
    return Intl.message(
      'Error Downloading File',
      name: 'error_downloading_file',
      desc: '',
      args: [],
    );
  }

  /// `Error loading`
  String get error_loading {
    return Intl.message(
      'Error loading',
      name: 'error_loading',
      desc: '',
      args: [],
    );
  }

  /// `Could not open download link`
  String get error_opening_download_link {
    return Intl.message(
      'Could not open download link',
      name: 'error_opening_download_link',
      desc: '',
      args: [],
    );
  }

  /// `Could not open file`
  String get error_opening_file {
    return Intl.message(
      'Could not open file',
      name: 'error_opening_file',
      desc: '',
      args: [],
    );
  }

  /// `Error Viewing File`
  String get error_viewing_file {
    return Intl.message(
      'Error Viewing File',
      name: 'error_viewing_file',
      desc: '',
      args: [],
    );
  }

  /// `Error approving document`
  String get errorApprovingDocument {
    return Intl.message(
      'Error approving document',
      name: 'errorApprovingDocument',
      desc: '',
      args: [],
    );
  }

  /// `Error loading analytics`
  String get errorLoadingAnalytics {
    return Intl.message(
      'Error loading analytics',
      name: 'errorLoadingAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Error loading approvals`
  String get errorLoadingApprovals {
    return Intl.message(
      'Error loading approvals',
      name: 'errorLoadingApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Error loading dashboard`
  String get errorLoadingDashboard {
    return Intl.message(
      'Error loading dashboard',
      name: 'errorLoadingDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Error loading data`
  String get errorLoadingData {
    return Intl.message(
      'Error loading data',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Error loading notifications`
  String get errorLoadingNotifications {
    return Intl.message(
      'Error loading notifications',
      name: 'errorLoadingNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Error loading services`
  String get errorLoadingServices {
    return Intl.message(
      'Error loading services',
      name: 'errorLoadingServices',
      desc: '',
      args: [],
    );
  }

  /// `Error loading statistics`
  String get errorLoadingStatistics {
    return Intl.message(
      'Error loading statistics',
      name: 'errorLoadingStatistics',
      desc: '',
      args: [],
    );
  }

  /// `Error Loading Submissions`
  String get errorLoadingSubmissions {
    return Intl.message(
      'Error Loading Submissions',
      name: 'errorLoadingSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Error loading tasks`
  String get errorLoadingTasks {
    return Intl.message(
      'Error loading tasks',
      name: 'errorLoadingTasks',
      desc: '',
      args: [],
    );
  }

  /// `Error Occured, Please try again`
  String get errorOccuredPleaseTryAgain {
    return Intl.message(
      'Error Occured, Please try again',
      name: 'errorOccuredPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Error rejecting document`
  String get errorRejectingDocument {
    return Intl.message(
      'Error rejecting document',
      name: 'errorRejectingDocument',
      desc: '',
      args: [],
    );
  }

  /// `Error submitting request`
  String get errorSubmittingRequest {
    return Intl.message(
      'Error submitting request',
      name: 'errorSubmittingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Error submitting to Firebase`
  String get errorSubmittingToFirebase {
    return Intl.message(
      'Error submitting to Firebase',
      name: 'errorSubmittingToFirebase',
      desc: '',
      args: [],
    );
  }

  /// `Escalates`
  String get escalates {
    return Intl.message('Escalates', name: 'escalates', desc: '', args: []);
  }

  /// `Escalate to Supervisor`
  String get escalateToSupervisor {
    return Intl.message(
      'Escalate to Supervisor',
      name: 'escalateToSupervisor',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Completion Date`
  String get estimatedCompletionDate {
    return Intl.message(
      'Estimated Completion Date',
      name: 'estimatedCompletionDate',
      desc: '',
      args: [],
    );
  }

  /// `Estonian`
  String get estonian {
    return Intl.message('Estonian', name: 'estonian', desc: '', args: []);
  }

  /// `Ethiopian`
  String get ethiopian {
    return Intl.message('Ethiopian', name: 'ethiopian', desc: '', args: []);
  }

  /// `EUR`
  String get eUR {
    return Intl.message('EUR', name: 'eUR', desc: '', args: []);
  }

  /// `Events`
  String get events {
    return Intl.message('Events', name: 'events', desc: '', args: []);
  }

  /// `Evidence Submitted`
  String get evidenceSubmitted {
    return Intl.message(
      'Evidence Submitted',
      name: 'evidenceSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `The Excel file is not accepted.`
  String get excelNotAccepted {
    return Intl.message(
      'The Excel file is not accepted.',
      name: 'excelNotAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Excused`
  String get excused {
    return Intl.message('Excused', name: 'excused', desc: '', args: []);
  }

  /// `Excused – Conference`
  String get excusedConference {
    return Intl.message(
      'Excused – Conference',
      name: 'excusedConference',
      desc: '',
      args: [],
    );
  }

  /// `Excused – Urgent Personal`
  String get excusedUrgentPersonal {
    return Intl.message(
      'Excused – Urgent Personal',
      name: 'excusedUrgentPersonal',
      desc: '',
      args: [],
    );
  }

  /// `Excused – Workshop`
  String get excusedWorkshop {
    return Intl.message(
      'Excused – Workshop',
      name: 'excusedWorkshop',
      desc: '',
      args: [],
    );
  }

  /// `Executive`
  String get Executive {
    return Intl.message('Executive', name: 'Executive', desc: '', args: []);
  }

  /// `Executive Management`
  String get executive {
    return Intl.message(
      'Executive Management',
      name: 'executive',
      desc: '',
      args: [],
    );
  }

  /// `Existing Batch`
  String get existingBatch {
    return Intl.message(
      'Existing Batch',
      name: 'existingBatch',
      desc: '',
      args: [],
    );
  }

  /// `Restocking Existing Batch`
  String get existingBatchRestockTitle {
    return Intl.message(
      'Restocking Existing Batch',
      name: 'existingBatchRestockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Existing Product`
  String get existingProduct {
    return Intl.message(
      'Existing Product',
      name: 'existingProduct',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get Expand {
    return Intl.message('Expand', name: 'Expand', desc: '', args: []);
  }

  /// `Expand`
  String get expand {
    return Intl.message('Expand', name: 'expand', desc: '', args: []);
  }

  /// `Expand Calendar`
  String get expandCalendar {
    return Intl.message(
      'Expand Calendar',
      name: 'expandCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Expand Toggle Panel`
  String get expandTools {
    return Intl.message(
      'Expand Toggle Panel',
      name: 'expandTools',
      desc: '',
      args: [],
    );
  }

  /// `Expansion`
  String get expansion {
    return Intl.message('Expansion', name: 'expansion', desc: '', args: []);
  }

  /// `Expected Delivery`
  String get expectedDelivery {
    return Intl.message(
      'Expected Delivery',
      name: 'expectedDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Expected Delivery Date`
  String get expectedDeliveryDate {
    return Intl.message(
      'Expected Delivery Date',
      name: 'expectedDeliveryDate',
      desc: '',
      args: [],
    );
  }

  /// `Expected Lifetime`
  String get expectedLifetime {
    return Intl.message(
      'Expected Lifetime',
      name: 'expectedLifetime',
      desc: '',
      args: [],
    );
  }

  /// `Expected Lifetime Ended`
  String get expectedLifetimeEnded {
    return Intl.message(
      'Expected Lifetime Ended',
      name: 'expectedLifetimeEnded',
      desc: '',
      args: [],
    );
  }

  /// `Expected Pick Up Date`
  String get expectedPickUpDate {
    return Intl.message(
      'Expected Pick Up Date',
      name: 'expectedPickUpDate',
      desc: '',
      args: [],
    );
  }

  /// `Expected Pick Up Time`
  String get expectedPickUpTime {
    return Intl.message(
      'Expected Pick Up Time',
      name: 'expectedPickUpTime',
      desc: '',
      args: [],
    );
  }

  /// `Expected Return`
  String get expectedReturn {
    return Intl.message(
      'Expected Return',
      name: 'expectedReturn',
      desc: '',
      args: [],
    );
  }

  /// `Expected Return Date`
  String get expectedReturnDate {
    return Intl.message(
      'Expected Return Date',
      name: 'expectedReturnDate',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expenses {
    return Intl.message('Expenses', name: 'expenses', desc: '', args: []);
  }

  /// `Expert`
  String get expert {
    return Intl.message('Expert', name: 'expert', desc: '', args: []);
  }

  /// `Expiration Date`
  String get expirationDate {
    return Intl.message(
      'Expiration Date',
      name: 'expirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Time`
  String get expirationTime {
    return Intl.message(
      'Expiration Time',
      name: 'expirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Time of Password`
  String get expirationTimeOfPassword {
    return Intl.message(
      'Expiration Time of Password',
      name: 'expirationTimeOfPassword',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message('Expired', name: 'expired', desc: '', args: []);
  }

  /// `Expiring Soon`
  String get expiringSoon {
    return Intl.message(
      'Expiring Soon',
      name: 'expiringSoon',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date Must Be in the Future`
  String get expiryDateMustBeInTheFuture {
    return Intl.message(
      'Expiry Date Must Be in the Future',
      name: 'expiryDateMustBeInTheFuture',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message('Export', name: 'export', desc: '', args: []);
  }

  /// `Export Analytics Data`
  String get exportAnalyticsData {
    return Intl.message(
      'Export Analytics Data',
      name: 'exportAnalyticsData',
      desc: '',
      args: [],
    );
  }

  /// `Export Contacts`
  String get exportContacts {
    return Intl.message(
      'Export Contacts',
      name: 'exportContacts',
      desc: '',
      args: [],
    );
  }

  /// `Export CRM Reports`
  String get exportCRMReports {
    return Intl.message(
      'Export CRM Reports',
      name: 'exportCRMReports',
      desc: '',
      args: [],
    );
  }

  /// `Export CSV`
  String get exportCsv {
    return Intl.message('Export CSV', name: 'exportCsv', desc: '', args: []);
  }

  /// `Export Data`
  String get exportData {
    return Intl.message('Export Data', name: 'exportData', desc: '', args: []);
  }

  /// `Export Details`
  String get exportDetails {
    return Intl.message(
      'Export Details',
      name: 'exportDetails',
      desc: '',
      args: [],
    );
  }

  /// `Exported`
  String get exported {
    return Intl.message('Exported', name: 'exported', desc: '', args: []);
  }

  /// `Export Employee Data`
  String get exportEmployeeData {
    return Intl.message(
      'Export Employee Data',
      name: 'exportEmployeeData',
      desc: '',
      args: [],
    );
  }

  /// `Export Failed`
  String get exportFailed {
    return Intl.message(
      'Export Failed',
      name: 'exportFailed',
      desc: '',
      args: [],
    );
  }

  /// `Export HR Reports`
  String get exportHRReports {
    return Intl.message(
      'Export HR Reports',
      name: 'exportHRReports',
      desc: '',
      args: [],
    );
  }

  /// `Exporting...`
  String get exporting {
    return Intl.message('Exporting...', name: 'exporting', desc: '', args: []);
  }

  /// `Export Requested Services`
  String get exportRequestedServices {
    return Intl.message(
      'Export Requested Services',
      name: 'exportRequestedServices',
      desc: '',
      args: [],
    );
  }

  /// `Export Role Data`
  String get exportRoleData {
    return Intl.message(
      'Export Role Data',
      name: 'exportRoleData',
      desc: '',
      args: [],
    );
  }

  /// `Export Roles`
  String get exportRoles {
    return Intl.message(
      'Export Roles',
      name: 'exportRoles',
      desc: '',
      args: [],
    );
  }

  /// `Export Service`
  String get exportService {
    return Intl.message(
      'Export Service',
      name: 'exportService',
      desc: '',
      args: [],
    );
  }

  /// `Export Statistics Table`
  String get exportStatisticsTable {
    return Intl.message(
      'Export Statistics Table',
      name: 'exportStatisticsTable',
      desc: '',
      args: [],
    );
  }

  /// `Export Submission Data`
  String get exportSubmissionData {
    return Intl.message(
      'Export Submission Data',
      name: 'exportSubmissionData',
      desc: '',
      args: [],
    );
  }

  /// `Exported successfully. You have successfully exported this file.`
  String get exportSuccess {
    return Intl.message(
      'Exported successfully. You have successfully exported this file.',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Export Successful`
  String get exportSuccessful {
    return Intl.message(
      'Export Successful',
      name: 'exportSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Export User Management`
  String get exportUserManagement {
    return Intl.message(
      'Export User Management',
      name: 'exportUserManagement',
      desc: '',
      args: [],
    );
  }

  /// `Export Users Data`
  String get exportUsersData {
    return Intl.message(
      'Export Users Data',
      name: 'exportUsersData',
      desc: '',
      args: [],
    );
  }

  /// `Extension Required`
  String get extensionRequired {
    return Intl.message(
      'Extension Required',
      name: 'extensionRequired',
      desc: '',
      args: [],
    );
  }

  /// `External`
  String get external {
    return Intl.message('External', name: 'external', desc: '', args: []);
  }

  /// `Only one space allowed between words`
  String get extraSpaces {
    return Intl.message(
      'Only one space allowed between words',
      name: 'extraSpaces',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add comment`
  String get failedToAddComment {
    return Intl.message(
      'Failed to add comment',
      name: 'failedToAddComment',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create knowledge hub`
  String get failedToCreateKnowledgeHub {
    return Intl.message(
      'Failed to create knowledge hub',
      name: 'failedToCreateKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create service request. Please try again.`
  String get failedToCreateServiceRequest {
    return Intl.message(
      'Failed to create service request. Please try again.',
      name: 'failedToCreateServiceRequest',
      desc: '',
      args: [],
    );
  }

  /// `FailedToDownloadFile`
  String get failedToDownloadFile {
    return Intl.message(
      'FailedToDownloadFile',
      name: 'failedToDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load departments`
  String get failedToLoadDepartments {
    return Intl.message(
      'Failed to load departments',
      name: 'failedToLoadDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load service data`
  String get failedToLoadServiceData {
    return Intl.message(
      'Failed to load service data',
      name: 'failedToLoadServiceData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick image`
  String get failedToPickImage {
    return Intl.message(
      'Failed to pick image',
      name: 'failedToPickImage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to remove user access. Please try again.`
  String get failedToRemoveUserAccessPleaseTryAgain {
    return Intl.message(
      'Failed to remove user access. Please try again.',
      name: 'failedToRemoveUserAccessPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save draft. Please try again.`
  String get failedToSaveDraftPleaseTryAgain {
    return Intl.message(
      'Failed to save draft. Please try again.',
      name: 'failedToSaveDraftPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save the role. Please try again.`
  String get failedToSaveRolePleaseTryAgain {
    return Intl.message(
      'Failed to save the role. Please try again.',
      name: 'failedToSaveRolePleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update access`
  String get failedToUpdateAccess {
    return Intl.message(
      'Failed to update access',
      name: 'failedToUpdateAccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update knowledge hub`
  String get failedToUpdateKnowledgeHub {
    return Intl.message(
      'Failed to update knowledge hub',
      name: 'failedToUpdateKnowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update product`
  String get failedToUpdateProduct {
    return Intl.message(
      'Failed to update product',
      name: 'failedToUpdateProduct',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get family {
    return Intl.message('Family', name: 'family', desc: '', args: []);
  }

  /// `Fax Number`
  String get faxNumber {
    return Intl.message('Fax Number', name: 'faxNumber', desc: '', args: []);
  }

  /// `Fax number is required.`
  String get faxNumberRequired {
    return Intl.message(
      'Fax number is required.',
      name: 'faxNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Feb`
  String get feb {
    return Intl.message('Feb', name: 'feb', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Fields`
  String get fields {
    return Intl.message('Fields', name: 'fields', desc: '', args: []);
  }

  /// `Fijian`
  String get fijian {
    return Intl.message('Fijian', name: 'fijian', desc: '', args: []);
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Date`
  String get fileDate {
    return Intl.message('Date', name: 'fileDate', desc: '', args: []);
  }

  /// `File downloaded successfully`
  String get fileDownloadedSuccessfully {
    return Intl.message(
      'File downloaded successfully',
      name: 'fileDownloadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `File Name`
  String get fileName {
    return Intl.message('File Name', name: 'fileName', desc: '', args: []);
  }

  /// `File saved successfully`
  String get fileSavedSuccessfully {
    return Intl.message(
      'File saved successfully',
      name: 'fileSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `File Size`
  String get fileSize {
    return Intl.message('File Size', name: 'fileSize', desc: '', args: []);
  }

  /// `Filipino`
  String get filipino {
    return Intl.message('Filipino', name: 'filipino', desc: '', args: []);
  }

  /// `Please fill all required fields`
  String get fillAllRequiredFields {
    return Intl.message(
      'Please fill all required fields',
      name: 'fillAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Fill at least two options`
  String get fillAtLeastTwoOptions {
    return Intl.message(
      'Fill at least two options',
      name: 'fillAtLeastTwoOptions',
      desc: '',
      args: [],
    );
  }

  /// `Fill Out Form`
  String get fillOutForm {
    return Intl.message(
      'Fill Out Form',
      name: 'fillOutForm',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get Filter {
    return Intl.message('Filter', name: 'Filter', desc: '', args: []);
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Filter by Department`
  String get filter_by_department {
    return Intl.message(
      'Filter by Department',
      name: 'filter_by_department',
      desc: '',
      args: [],
    );
  }

  /// `Final Amount`
  String get finalAmount {
    return Intl.message(
      'Final Amount',
      name: 'finalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Finalizing...`
  String get finalizing {
    return Intl.message(
      'Finalizing...',
      name: 'finalizing',
      desc: '',
      args: [],
    );
  }

  /// `Finance`
  String get Finance {
    return Intl.message('Finance', name: 'Finance', desc: '', args: []);
  }

  /// `Finance`
  String get finance {
    return Intl.message('Finance', name: 'finance', desc: '', args: []);
  }

  /// `Finance Department`
  String get financeDepartment {
    return Intl.message(
      'Finance Department',
      name: 'financeDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Finance Officer`
  String get financeOfficer {
    return Intl.message(
      'Finance Officer',
      name: 'financeOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Financial Service`
  String get financialService {
    return Intl.message(
      'Financial Service',
      name: 'financialService',
      desc: '',
      args: [],
    );
  }

  /// `Finnish`
  String get finnish {
    return Intl.message('Finnish', name: 'finnish', desc: '', args: []);
  }

  /// `Fire Safety`
  String get fireSafety {
    return Intl.message('Fire Safety', name: 'fireSafety', desc: '', args: []);
  }

  /// `First`
  String get First {
    return Intl.message('First', name: 'First', desc: '', args: []);
  }

  /// `First Backup`
  String get firstBackup {
    return Intl.message(
      'First Backup',
      name: 'firstBackup',
      desc: '',
      args: [],
    );
  }

  /// `First Login`
  String get firstLogin {
    return Intl.message('First Login', name: 'firstLogin', desc: '', args: []);
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `First Name Missing`
  String get firstNameMissing {
    return Intl.message(
      'First Name Missing',
      name: 'firstNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `First Name is required`
  String get firstNameRequired {
    return Intl.message(
      'First Name is required',
      name: 'firstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Fixed`
  String get fixed {
    return Intl.message('Fixed', name: 'fixed', desc: '', args: []);
  }

  /// `Fixed + Bonus`
  String get fixedBonus {
    return Intl.message(
      'Fixed + Bonus',
      name: 'fixedBonus',
      desc: '',
      args: [],
    );
  }

  /// `Flammable Storage`
  String get flammableStorage {
    return Intl.message(
      'Flammable Storage',
      name: 'flammableStorage',
      desc: '',
      args: [],
    );
  }

  /// `Flexible Role Management`
  String get flexibleRoleManagement {
    return Intl.message(
      'Flexible Role Management',
      name: 'flexibleRoleManagement',
      desc: '',
      args: [],
    );
  }

  /// `Assign and manage roles within your organization effortlessly. Ensure that every team member has the appropriate access and responsibilities to perform their duties effectively.`
  String get flexibleRoleManagementBody {
    return Intl.message(
      'Assign and manage roles within your organization effortlessly. Ensure that every team member has the appropriate access and responsibilities to perform their duties effectively.',
      name: 'flexibleRoleManagementBody',
      desc: '',
      args: [],
    );
  }

  /// `Fonts`
  String get fonts {
    return Intl.message('Fonts', name: 'fonts', desc: '', args: []);
  }

  /// `Food Service`
  String get foodService {
    return Intl.message(
      'Food Service',
      name: 'foodService',
      desc: '',
      args: [],
    );
  }

  /// `For Direct Message`
  String get forDirectMessage {
    return Intl.message(
      'For Direct Message',
      name: 'forDirectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgotPassword2 {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword2',
      desc: '',
      args: [],
    );
  }

  /// `For Group`
  String get forGroup {
    return Intl.message('For Group', name: 'forGroup', desc: '', args: []);
  }

  /// `Forklift`
  String get forklift {
    return Intl.message('Forklift', name: 'forklift', desc: '', args: []);
  }

  /// `Form`
  String get form {
    return Intl.message('Form', name: 'form', desc: '', args: []);
  }

  /// `Form Name`
  String get formName {
    return Intl.message('Form Name', name: 'formName', desc: '', args: []);
  }

  /// `Form Permissions`
  String get formPermissions {
    return Intl.message(
      'Form Permissions',
      name: 'formPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Form Permissions Module`
  String get formPermissionsModule {
    return Intl.message(
      'Form Permissions Module',
      name: 'formPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `FormResponsivePage`
  String get formresponsivepage {
    return Intl.message(
      'FormResponsivePage',
      name: 'formresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `Forms`
  String get forms {
    return Intl.message('Forms', name: 'forms', desc: '', args: []);
  }

  /// `Form Submissions`
  String get formSubmissions {
    return Intl.message(
      'Form Submissions',
      name: 'formSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Forward Message`
  String get forwardMessage {
    return Intl.message(
      'Forward Message',
      name: 'forwardMessage',
      desc: '',
      args: [],
    );
  }

  /// `Forward Messages`
  String get forwardMessages {
    return Intl.message(
      'Forward Messages',
      name: 'forwardMessages',
      desc: '',
      args: [],
    );
  }

  /// `Forward to`
  String get forwardTo {
    return Intl.message('Forward to', name: 'forwardTo', desc: '', args: []);
  }

  /// `Fourth`
  String get Fourth {
    return Intl.message('Fourth', name: 'Fourth', desc: '', args: []);
  }

  /// `Fragile – Handle with Care`
  String get fragileHandleWithCare {
    return Intl.message(
      'Fragile – Handle with Care',
      name: 'fragileHandleWithCare',
      desc: '',
      args: [],
    );
  }

  /// `Frame Work`
  String get frame_work {
    return Intl.message('Frame Work', name: 'frame_work', desc: '', args: []);
  }

  /// `Framework`
  String get framework {
    return Intl.message('Framework', name: 'framework', desc: '', args: []);
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Freq`
  String get freqAbbreviation {
    return Intl.message('Freq', name: 'freqAbbreviation', desc: '', args: []);
  }

  /// `Frequency`
  String get frequency {
    return Intl.message('Frequency', name: 'frequency', desc: '', args: []);
  }

  /// `Annually`
  String get frequencyAnnually {
    return Intl.message(
      'Annually',
      name: 'frequencyAnnually',
      desc: '',
      args: [],
    );
  }

  /// `Biweekly`
  String get frequencyBiweekly {
    return Intl.message(
      'Biweekly',
      name: 'frequencyBiweekly',
      desc: '',
      args: [],
    );
  }

  /// `Continuous / Real-Time`
  String get frequencyContinuousRealTime {
    return Intl.message(
      'Continuous / Real-Time',
      name: 'frequencyContinuousRealTime',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get frequencyDaily {
    return Intl.message('Daily', name: 'frequencyDaily', desc: '', args: []);
  }

  /// `Monthly`
  String get frequencyMonthly {
    return Intl.message(
      'Monthly',
      name: 'frequencyMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Occasionally`
  String get frequencyOccasionally {
    return Intl.message(
      'Occasionally',
      name: 'frequencyOccasionally',
      desc: '',
      args: [],
    );
  }

  /// `On Demand / As Needed`
  String get frequencyOnDemandAsNeeded {
    return Intl.message(
      'On Demand / As Needed',
      name: 'frequencyOnDemandAsNeeded',
      desc: '',
      args: [],
    );
  }

  /// `One-Time Use`
  String get frequencyOneTimeUse {
    return Intl.message(
      'One-Time Use',
      name: 'frequencyOneTimeUse',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get frequencyQuarterly {
    return Intl.message(
      'Quarterly',
      name: 'frequencyQuarterly',
      desc: '',
      args: [],
    );
  }

  /// `Rarely`
  String get frequencyRarely {
    return Intl.message('Rarely', name: 'frequencyRarely', desc: '', args: []);
  }

  /// `Seasonally`
  String get frequencySeasonally {
    return Intl.message(
      'Seasonally',
      name: 'frequencySeasonally',
      desc: '',
      args: [],
    );
  }

  /// `Shift-Based`
  String get frequencyShiftBased {
    return Intl.message(
      'Shift-Based',
      name: 'frequencyShiftBased',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Contacted`
  String get frequentlyContacted {
    return Intl.message(
      'Frequently Contacted',
      name: 'frequentlyContacted',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message('Friday', name: 'friday', desc: '', args: []);
  }

  /// `Friend`
  String get friend {
    return Intl.message('Friend', name: 'friend', desc: '', args: []);
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `Frozen Storage`
  String get frozenStorage {
    return Intl.message(
      'Frozen Storage',
      name: 'frozenStorage',
      desc: '',
      args: [],
    );
  }

  /// `Full-time`
  String get fullTime {
    return Intl.message('Full-time', name: 'fullTime', desc: '', args: []);
  }

  /// `Gabonese`
  String get gabonese {
    return Intl.message('Gabonese', name: 'gabonese', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Gambian`
  String get gambian {
    return Intl.message('Gambian', name: 'gambian', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Gender field must be either 'male', 'female', or 'other'.`
  String get genderFieldMustBeEitherMaleFemaleOrOther {
    return Intl.message(
      'Gender field must be either \'male\', \'female\', or \'other\'.',
      name: 'genderFieldMustBeEitherMaleFemaleOrOther',
      desc: '',
      args: [],
    );
  }

  /// `General Information`
  String get generalInformation {
    return Intl.message(
      'General Information',
      name: 'generalInformation',
      desc: '',
      args: [],
    );
  }

  /// `General Manager`
  String get generalManager {
    return Intl.message(
      'General Manager',
      name: 'generalManager',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing`
  String get geofencing {
    return Intl.message('Geofencing', name: 'geofencing', desc: '', args: []);
  }

  /// `Geofencing Area`
  String get geofencingArea {
    return Intl.message(
      'Geofencing Area',
      name: 'geofencingArea',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing perimeter`
  String get geofencingPerimeter {
    return Intl.message(
      'Geofencing perimeter',
      name: 'geofencingPerimeter',
      desc: '',
      args: [],
    );
  }

  /// `Georgian`
  String get georgian {
    return Intl.message('Georgian', name: 'georgian', desc: '', args: []);
  }

  /// `German`
  String get german {
    return Intl.message('German', name: 'german', desc: '', args: []);
  }

  /// `Get Start`
  String get getStart {
    return Intl.message('Get Start', name: 'getStart', desc: '', args: []);
  }

  /// `Ghanaian`
  String get ghanaian {
    return Intl.message('Ghanaian', name: 'ghanaian', desc: '', args: []);
  }

  /// `Give Access`
  String get giveAccess {
    return Intl.message('Give Access', name: 'giveAccess', desc: '', args: []);
  }

  /// `Give a Score`
  String get giveAScore {
    return Intl.message('Give a Score', name: 'giveAScore', desc: '', args: []);
  }

  /// `Good Afternoon`
  String get goodAfternoon {
    return Intl.message(
      'Good Afternoon',
      name: 'goodAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good Evening`
  String get goodEvening {
    return Intl.message(
      'Good Evening',
      name: 'goodEvening',
      desc: '',
      args: [],
    );
  }

  /// `Good Morning`
  String get goodMorning {
    return Intl.message(
      'Good Morning',
      name: 'goodMorning',
      desc: '',
      args: [],
    );
  }

  /// `Google Maps`
  String get googleMaps {
    return Intl.message('Google Maps', name: 'googleMaps', desc: '', args: []);
  }

  /// `Got it`
  String get gotIt {
    return Intl.message('Got it', name: 'gotIt', desc: '', args: []);
  }

  /// `Governance, Risk, and Compliance`
  String get governanceRiskCompliance {
    return Intl.message(
      'Governance, Risk, and Compliance',
      name: 'governanceRiskCompliance',
      desc: '',
      args: [],
    );
  }

  /// `Graduation From`
  String get graduationFrom {
    return Intl.message(
      'Graduation From',
      name: 'graduationFrom',
      desc: '',
      args: [],
    );
  }

  /// `Graduation Year`
  String get graduationYear {
    return Intl.message(
      'Graduation Year',
      name: 'graduationYear',
      desc: '',
      args: [],
    );
  }

  /// `Grant Access`
  String get grantAccess {
    return Intl.message(
      'Grant Access',
      name: 'grantAccess',
      desc: '',
      args: [],
    );
  }

  /// `Granted Access`
  String get grantedAccess {
    return Intl.message(
      'Granted Access',
      name: 'grantedAccess',
      desc: '',
      args: [],
    );
  }

  /// `GRC`
  String get grc {
    return Intl.message('GRC', name: 'grc', desc: '', args: []);
  }

  /// `GRC Module Name`
  String get grcModuleName {
    return Intl.message(
      'GRC Module Name',
      name: 'grcModuleName',
      desc: '',
      args: [],
    );
  }

  /// `Governance Framework Title (Arabic)`
  String get grcModuleNameArabic {
    return Intl.message(
      'Governance Framework Title (Arabic)',
      name: 'grcModuleNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `GRC module name is required`
  String get grcModuleNameIsRequired {
    return Intl.message(
      'GRC module name is required',
      name: 'grcModuleNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `GRC module name must be written in Arabic`
  String get grcModuleNameMustBeWrittenInArabic {
    return Intl.message(
      'GRC module name must be written in Arabic',
      name: 'grcModuleNameMustBeWrittenInArabic',
      desc: '',
      args: [],
    );
  }

  /// `GRC Policy Number`
  String get grcPolicyNumber {
    return Intl.message(
      'GRC Policy Number',
      name: 'grcPolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `GrcResponsivePage`
  String get grcresponsivepage {
    return Intl.message(
      'GrcResponsivePage',
      name: 'grcresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `Greek`
  String get greek {
    return Intl.message('Greek', name: 'greek', desc: '', args: []);
  }

  /// `Grenadian`
  String get grenadian {
    return Intl.message('Grenadian', name: 'grenadian', desc: '', args: []);
  }

  /// `Group`
  String get group {
    return Intl.message('Group', name: 'group', desc: '', args: []);
  }

  /// `Group Name`
  String get groupName {
    return Intl.message('Group Name', name: 'groupName', desc: '', args: []);
  }

  /// `Groups`
  String get groups {
    return Intl.message('Groups', name: 'groups', desc: '', args: []);
  }

  /// `Groups Common`
  String get groupsCommon {
    return Intl.message(
      'Groups Common',
      name: 'groupsCommon',
      desc: '',
      args: [],
    );
  }

  /// `Groups in common`
  String get groupsInCommon {
    return Intl.message(
      'Groups in common',
      name: 'groupsInCommon',
      desc: '',
      args: [],
    );
  }

  /// `Guatemalan`
  String get guatemalan {
    return Intl.message('Guatemalan', name: 'guatemalan', desc: '', args: []);
  }

  /// `Guidelines`
  String get guidelines {
    return Intl.message('Guidelines', name: 'guidelines', desc: '', args: []);
  }

  /// `Guinea-Bissauan`
  String get guineaBissauan {
    return Intl.message(
      'Guinea-Bissauan',
      name: 'guineaBissauan',
      desc: '',
      args: [],
    );
  }

  /// `Guinean`
  String get guinean {
    return Intl.message('Guinean', name: 'guinean', desc: '', args: []);
  }

  /// `Guyanese`
  String get guyanese {
    return Intl.message('Guyanese', name: 'guyanese', desc: '', args: []);
  }

  /// `Haitian`
  String get haitian {
    return Intl.message('Haitian', name: 'haitian', desc: '', args: []);
  }

  /// `Hand Delivery`
  String get handDelivery {
    return Intl.message(
      'Hand Delivery',
      name: 'handDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Hand Pallet Truck (Manual Jack)`
  String get handPalletTruck {
    return Intl.message(
      'Hand Pallet Truck (Manual Jack)',
      name: 'handPalletTruck',
      desc: '',
      args: [],
    );
  }

  /// `Haptic Feedback`
  String get hapticFeedback {
    return Intl.message(
      'Haptic Feedback',
      name: 'hapticFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Hazardous Material Handling Kit`
  String get hazardousMaterialHandlingKit {
    return Intl.message(
      'Hazardous Material Handling Kit',
      name: 'hazardousMaterialHandlingKit',
      desc: '',
      args: [],
    );
  }

  /// `Hazardous Material Storage`
  String get hazardousMaterialStorage {
    return Intl.message(
      'Hazardous Material Storage',
      name: 'hazardousMaterialStorage',
      desc: '',
      args: [],
    );
  }

  /// `Header Mismatch`
  String get headerMismatch {
    return Intl.message(
      'Header Mismatch',
      name: 'headerMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Health Insurance`
  String get healthInsurance {
    return Intl.message(
      'Health Insurance',
      name: 'healthInsurance',
      desc: '',
      args: [],
    );
  }

  /// `Health, Safety, and Environment`
  String get healthSafetyEnvironment {
    return Intl.message(
      'Health, Safety, and Environment',
      name: 'healthSafetyEnvironment',
      desc: '',
      args: [],
    );
  }

  /// `Heavy-Duty Storage`
  String get heavyDutyStorage {
    return Intl.message(
      'Heavy-Duty Storage',
      name: 'heavyDutyStorage',
      desc: '',
      args: [],
    );
  }

  /// `Herzegovinian`
  String get herzegovinian {
    return Intl.message(
      'Herzegovinian',
      name: 'herzegovinian',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get Hide {
    return Intl.message('Hide', name: 'Hide', desc: '', args: []);
  }

  /// `Hide`
  String get hide {
    return Intl.message('Hide', name: 'hide', desc: '', args: []);
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Hindi`
  String get hindi {
    return Intl.message('Hindi', name: 'hindi', desc: '', args: []);
  }

  /// `Hired On`
  String get hiredOn {
    return Intl.message('Hired On', name: 'hiredOn', desc: '', args: []);
  }

  /// `History Control Owners`
  String get historyControlOwners {
    return Intl.message(
      'History Control Owners',
      name: 'historyControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `History of Control Owners`
  String get historyOfControlOwners {
    return Intl.message(
      'History of Control Owners',
      name: 'historyOfControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `History Product Storage`
  String get historyProductStorage {
    return Intl.message(
      'History Product Storage',
      name: 'historyProductStorage',
      desc: '',
      args: [],
    );
  }

  /// `Hobbies`
  String get hobbies {
    return Intl.message('Hobbies', name: 'hobbies', desc: '', args: []);
  }

  /// `Hobbys`
  String get hobbys {
    return Intl.message('Hobbys', name: 'hobbys', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Home Layout`
  String get homeLayout {
    return Intl.message('Home Layout', name: 'homeLayout', desc: '', args: []);
  }

  /// `HomePageHelper`
  String get homepagehelper {
    return Intl.message(
      'HomePageHelper',
      name: 'homepagehelper',
      desc: '',
      args: [],
    );
  }

  /// `Home Preview`
  String get homePreview {
    return Intl.message(
      'Home Preview',
      name: 'homePreview',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get homeScreenAllTitle {
    return Intl.message('All', name: 'homeScreenAllTitle', desc: '', args: []);
  }

  /// `Create To-Do`
  String get homeScreenCreateToDoListTitle {
    return Intl.message(
      'Create To-Do',
      name: 'homeScreenCreateToDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get homeScreenEndDateTitle {
    return Intl.message(
      'End Date',
      name: 'homeScreenEndDateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get homeScreenFrequencyTitle {
    return Intl.message(
      'Frequency',
      name: 'homeScreenFrequencyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get homeScreenScheduleTitle {
    return Intl.message(
      'Schedule',
      name: 'homeScreenScheduleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get homeScreenSortTitle {
    return Intl.message(
      'Sort',
      name: 'homeScreenSortTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get homeScreenStartDateTitle {
    return Intl.message(
      'Start Date',
      name: 'homeScreenStartDateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Honduran`
  String get honduran {
    return Intl.message('Honduran', name: 'honduran', desc: '', args: []);
  }

  /// `Hospitality`
  String get hospitality {
    return Intl.message('Hospitality', name: 'hospitality', desc: '', args: []);
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Hourly`
  String get hourly {
    return Intl.message('Hourly', name: 'hourly', desc: '', args: []);
  }

  /// `Hours`
  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  /// `Hours Ago`
  String get hoursAgo {
    return Intl.message('Hours Ago', name: 'hoursAgo', desc: '', args: []);
  }

  /// `HR`
  String get hr {
    return Intl.message('HR', name: 'hr', desc: '', args: []);
  }

  /// `HR Approval`
  String get hrApproval {
    return Intl.message('HR Approval', name: 'hrApproval', desc: '', args: []);
  }

  /// `HR Module`
  String get hrModule {
    return Intl.message('HR Module', name: 'hrModule', desc: '', args: []);
  }

  /// `Health, Safety and Environment`
  String get hse {
    return Intl.message(
      'Health, Safety and Environment',
      name: 'hse',
      desc: '',
      args: [],
    );
  }

  /// `Human Resources`
  String get HumanResources {
    return Intl.message(
      'Human Resources',
      name: 'HumanResources',
      desc: '',
      args: [],
    );
  }

  /// `Human Resources`
  String get humanResources {
    return Intl.message(
      'Human Resources',
      name: 'humanResources',
      desc: '',
      args: [],
    );
  }

  /// `Humidity Check`
  String get humidityCheck {
    return Intl.message(
      'Humidity Check',
      name: 'humidityCheck',
      desc: '',
      args: [],
    );
  }

  /// `Humidity-Controlled`
  String get humidityControlled {
    return Intl.message(
      'Humidity-Controlled',
      name: 'humidityControlled',
      desc: '',
      args: [],
    );
  }

  /// `Hungarian`
  String get hungarian {
    return Intl.message('Hungarian', name: 'hungarian', desc: '', args: []);
  }

  /// `hybrid`
  String get hybrid {
    return Intl.message('hybrid', name: 'hybrid', desc: '', args: []);
  }

  /// `Hybrid`
  String get hybrid2 {
    return Intl.message('Hybrid', name: 'hybrid2', desc: '', args: []);
  }

  /// `Beneficiary Bank Account Number / IBAN`
  String get iban {
    return Intl.message(
      'Beneficiary Bank Account Number / IBAN',
      name: 'iban',
      desc: '',
      args: [],
    );
  }

  /// `IBAN is required`
  String get ibanRequired {
    return Intl.message(
      'IBAN is required',
      name: 'ibanRequired',
      desc: '',
      args: [],
    );
  }

  /// `Icelander`
  String get icelander {
    return Intl.message('Icelander', name: 'icelander', desc: '', args: []);
  }

  /// `Icons`
  String get icons {
    return Intl.message('Icons', name: 'icons', desc: '', args: []);
  }

  /// `ID`
  String get iD {
    return Intl.message('ID', name: 'iD', desc: '', args: []);
  }

  /// `ID Photo`
  String get iDPhoto {
    return Intl.message('ID Photo', name: 'iDPhoto', desc: '', args: []);
  }

  /// `If you select 'All Requests', the approval cycle will be applied to all request types.`
  String get ifYouSelectAllRequests {
    return Intl.message(
      'If you select \'All Requests\', the approval cycle will be applied to all request types.',
      name: 'ifYouSelectAllRequests',
      desc: '',
      args: [],
    );
  }

  /// `I-Kiribati`
  String get iKiribati {
    return Intl.message('I-Kiribati', name: 'iKiribati', desc: '', args: []);
  }

  /// `Image`
  String get image {
    return Intl.message('Image', name: 'image', desc: '', args: []);
  }

  /// `assets/icons_assets/main_icons_assets/check_circle_green.svg`
  String get imageAsset {
    return Intl.message(
      'assets/icons_assets/main_icons_assets/check_circle_green.svg',
      name: 'imageAsset',
      desc: '',
      args: [],
    );
  }

  /// `Image deleted successfully`
  String get imageDeletedSuccessfully {
    return Intl.message(
      'Image deleted successfully',
      name: 'imageDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Image not found`
  String get imageNotFound {
    return Intl.message(
      'Image not found',
      name: 'imageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Image uploaded successfully`
  String get imageUploadedSuccessfully {
    return Intl.message(
      'Image uploaded successfully',
      name: 'imageUploadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Import Contacts`
  String get importContacts {
    return Intl.message(
      'Import Contacts',
      name: 'importContacts',
      desc: '',
      args: [],
    );
  }

  /// `Import Users Data`
  String get importUsersData {
    return Intl.message(
      'Import Users Data',
      name: 'importUsersData',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message('Inactive', name: 'inactive', desc: '', args: []);
  }

  /// `Inactive Roles`
  String get inactiveRoles {
    return Intl.message(
      'Inactive Roles',
      name: 'inactiveRoles',
      desc: '',
      args: [],
    );
  }

  /// `Inactive For Now`
  String get inactiveForNow {
    return Intl.message(
      'Inactive For Now',
      name: 'inactiveForNow',
      desc: '',
      args: [],
    );
  }

  /// `Incident Date`
  String get incidentDate {
    return Intl.message(
      'Incident Date',
      name: 'incidentDate',
      desc: '',
      args: [],
    );
  }

  /// `Incident Location`
  String get incidentLocation {
    return Intl.message(
      'Incident Location',
      name: 'incidentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete Form`
  String get incompleteForm {
    return Intl.message(
      'Incomplete Form',
      name: 'incompleteForm',
      desc: '',
      args: [],
    );
  }

  /// `The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you can reset it using the "Forgot Password" option.`
  String get incorrectPasswordMessage {
    return Intl.message(
      'The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you can reset it using the "Forgot Password" option.',
      name: 'incorrectPasswordMessage',
      desc: '',
      args: [],
    );
  }

  /// `Indian`
  String get indian {
    return Intl.message('Indian', name: 'indian', desc: '', args: []);
  }

  /// `Indicates number in table`
  String get indicatesNumberInTable {
    return Intl.message(
      'Indicates number in table',
      name: 'indicatesNumberInTable',
      desc: '',
      args: [],
    );
  }

  /// `Indonesian`
  String get indonesian {
    return Intl.message('Indonesian', name: 'indonesian', desc: '', args: []);
  }

  /// `Industry`
  String get industry {
    return Intl.message('Industry', name: 'industry', desc: '', args: []);
  }

  /// `We are pleased to place a new purchase order with your company. Please find attached the details of our order, including item descriptions, quantities, pricing, and delivery address. Kindly confirm receipt of this order and provide an estimated delivery date. Should you have any questions or need clarification, please do not hesitate to contact us.`
  String get infoOrder {
    return Intl.message(
      'We are pleased to place a new purchase order with your company. Please find attached the details of our order, including item descriptions, quantities, pricing, and delivery address. Kindly confirm receipt of this order and provide an estimated delivery date. Should you have any questions or need clarification, please do not hesitate to contact us.',
      name: 'infoOrder',
      desc: '',
      args: [],
    );
  }

  /// `Information Technology`
  String get InformationTechnology {
    return Intl.message(
      'Information Technology',
      name: 'InformationTechnology',
      desc: '',
      args: [],
    );
  }

  /// `Information Technology`
  String get informationTechnology {
    return Intl.message(
      'Information Technology',
      name: 'informationTechnology',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get Inprogress {
    return Intl.message('In progress', name: 'Inprogress', desc: '', args: []);
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message('In Progress', name: 'inProgress', desc: '', args: []);
  }

  /// `In Progress Projects`
  String get inProgressProjects {
    return Intl.message(
      'In Progress Projects',
      name: 'inProgressProjects',
      desc: '',
      args: [],
    );
  }

  /// `Inquiries`
  String get inquires {
    return Intl.message('Inquiries', name: 'inquires', desc: '', args: []);
  }

  /// `Inquiries And Comments`
  String get inquiries_and_comments {
    return Intl.message(
      'Inquiries And Comments',
      name: 'inquiries_and_comments',
      desc: '',
      args: [],
    );
  }

  /// `Inquiries and Comments`
  String get InquiriesAndComments {
    return Intl.message(
      'Inquiries and Comments',
      name: 'InquiriesAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Inquiries And Comments`
  String get inquiriesAndComments {
    return Intl.message(
      'Inquiries And Comments',
      name: 'inquiriesAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Inquiries coming soon`
  String get inquiriesComingSoon {
    return Intl.message(
      'Inquiries coming soon',
      name: 'inquiriesComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `In Review`
  String get inReview {
    return Intl.message('In Review', name: 'inReview', desc: '', args: []);
  }

  /// `In-Service Date`
  String get inServiceDate {
    return Intl.message(
      'In-Service Date',
      name: 'inServiceDate',
      desc: '',
      args: [],
    );
  }

  /// `Inspect fire extinguishers and alarms.`
  String get inspectFireExtinguishersAndAlarms {
    return Intl.message(
      'Inspect fire extinguishers and alarms.',
      name: 'inspectFireExtinguishersAndAlarms',
      desc: '',
      args: [],
    );
  }

  /// `Inspect for any signs of pests.`
  String get inspectForAnySignsOfPests {
    return Intl.message(
      'Inspect for any signs of pests.',
      name: 'inspectForAnySignsOfPests',
      desc: '',
      args: [],
    );
  }

  /// `Institution Name`
  String get institutionName {
    return Intl.message(
      'Institution Name',
      name: 'institutionName',
      desc: '',
      args: [],
    );
  }

  /// `InStock`
  String get inStock {
    return Intl.message('InStock', name: 'inStock', desc: '', args: []);
  }

  /// `New`
  String get instock {
    return Intl.message('New', name: 'instock', desc: '', args: []);
  }

  /// `Insurance`
  String get insurance {
    return Intl.message('Insurance', name: 'insurance', desc: '', args: []);
  }

  /// `Insurance Details`
  String get insuranceDetails {
    return Intl.message(
      'Insurance Details',
      name: 'insuranceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Insurance Name`
  String get insuranceName {
    return Intl.message(
      'Insurance Name',
      name: 'insuranceName',
      desc: '',
      args: [],
    );
  }

  /// `Insurance Policy Number`
  String get insurancePolicyNumber {
    return Intl.message(
      'Insurance Policy Number',
      name: 'insurancePolicyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Intermediate`
  String get intermediate {
    return Intl.message(
      'Intermediate',
      name: 'intermediate',
      desc: '',
      args: [],
    );
  }

  /// `Internal Access Only`
  String get internalAccessOnly {
    return Intl.message(
      'Internal Access Only',
      name: 'internalAccessOnly',
      desc: '',
      args: [],
    );
  }

  /// `Internal Audit`
  String get internalAudit {
    return Intl.message(
      'Internal Audit',
      name: 'internalAudit',
      desc: '',
      args: [],
    );
  }

  /// `Internal Search`
  String get internalSearch {
    return Intl.message(
      'Internal Search',
      name: 'internalSearch',
      desc: '',
      args: [],
    );
  }

  /// `In Use`
  String get inUse {
    return Intl.message('In Use', name: 'inUse', desc: '', args: []);
  }

  /// `Invalid Birth Date`
  String get invalidBirthDate {
    return Intl.message(
      'Invalid Birth Date',
      name: 'invalidBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Invalid City`
  String get invalidCity {
    return Intl.message(
      'Invalid City',
      name: 'invalidCity',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Country Name`
  String get invalidCountryName {
    return Intl.message(
      'Invalid Country Name',
      name: 'invalidCountryName',
      desc: '',
      args: [],
    );
  }

  /// `Invalid credentials. Please verify and try again.`
  String get invalidCredentialsPleaseVerifyAndTryAgain {
    return Intl.message(
      'Invalid credentials. Please verify and try again.',
      name: 'invalidCredentialsPleaseVerifyAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Data`
  String get invalidData {
    return Intl.message(
      'Invalid Data',
      name: 'invalidData',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Date`
  String get invalidDate {
    return Intl.message(
      'Invalid Date',
      name: 'invalidDate',
      desc: '',
      args: [],
    );
  }

  /// `Only letters, numbers, spaces, and commas are allowed`
  String get invalidDepartmentChars {
    return Intl.message(
      'Only letters, numbers, spaces, and commas are allowed',
      name: 'invalidDepartmentChars',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Department ID Format`
  String get invalidDepartmentIDFormat {
    return Intl.message(
      'Invalid Department ID Format',
      name: 'invalidDepartmentIDFormat',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Email`
  String get invalidEmail {
    return Intl.message(
      'Invalid Email',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email format`
  String get invalidEmailFormat {
    return Intl.message(
      'Invalid email format',
      name: 'invalidEmailFormat',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Employee ID`
  String get invalidEmployeeID {
    return Intl.message(
      'Invalid Employee ID',
      name: 'invalidEmployeeID',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Expiry Date`
  String get invalidExpiryDate {
    return Intl.message(
      'Invalid Expiry Date',
      name: 'invalidExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Invalid First Name`
  String get invalidFirstName {
    return Intl.message(
      'Invalid First Name',
      name: 'invalidFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Gender`
  String get invalidGender {
    return Intl.message(
      'Invalid Gender',
      name: 'invalidGender',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Language`
  String get invalidLanguage {
    return Intl.message(
      'Invalid Language',
      name: 'invalidLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Last Name`
  String get invalidLastName {
    return Intl.message(
      'Invalid Last Name',
      name: 'invalidLastName',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Middle Name`
  String get invalidMiddleName {
    return Intl.message(
      'Invalid Middle Name',
      name: 'invalidMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Invalid National ID`
  String get invalidNationalID {
    return Intl.message(
      'Invalid National ID',
      name: 'invalidNationalID',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Passport Number`
  String get invalidPassportNumber {
    return Intl.message(
      'Invalid Passport Number',
      name: 'invalidPassportNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Phone Format`
  String get invalidPhoneFormat {
    return Intl.message(
      'Invalid Phone Format',
      name: 'invalidPhoneFormat',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Phone Number`
  String get invalidPhoneNumber {
    return Intl.message(
      'Invalid Phone Number',
      name: 'invalidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Postal Code`
  String get invalidPostalCode {
    return Intl.message(
      'Invalid Postal Code',
      name: 'invalidPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Province`
  String get invalidProvince {
    return Intl.message(
      'Invalid Province',
      name: 'invalidProvince',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Street`
  String get invalidStreet {
    return Intl.message(
      'Invalid Street',
      name: 'invalidStreet',
      desc: '',
      args: [],
    );
  }

  /// `Must be one of: Hours, Days, Seconds, Minutes`
  String get invalidTimeUnit {
    return Intl.message(
      'Must be one of: Hours, Days, Seconds, Minutes',
      name: 'invalidTimeUnit',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Work Location`
  String get invalidWorkLocation {
    return Intl.message(
      'Invalid Work Location',
      name: 'invalidWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Must be "yes" or "no"`
  String get invalidYesNo {
    return Intl.message(
      'Must be "yes" or "no"',
      name: 'invalidYesNo',
      desc: '',
      args: [],
    );
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Inventory Audit`
  String get inventoryAudit {
    return Intl.message(
      'Inventory Audit',
      name: 'inventoryAudit',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Dashboard`
  String get inventoryDashboard {
    return Intl.message(
      'Inventory Dashboard',
      name: 'inventoryDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Inventory Management`
  String get inventoryManagement {
    return Intl.message(
      'Inventory Management',
      name: 'inventoryManagement',
      desc: '',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message('Invoice', name: 'invoice', desc: '', args: []);
  }

  /// `Invoice Details`
  String get invoiceDetails {
    return Intl.message(
      'Invoice Details',
      name: 'invoiceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Iranian`
  String get iranian {
    return Intl.message('Iranian', name: 'iranian', desc: '', args: []);
  }

  /// `Iraqi`
  String get iraqi {
    return Intl.message('Iraqi', name: 'iraqi', desc: '', args: []);
  }

  /// `Irish`
  String get irish {
    return Intl.message('Irish', name: 'irish', desc: '', args: []);
  }

  /// `is not available`
  String get isNotAvailable {
    return Intl.message(
      'is not available',
      name: 'isNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Israeli`
  String get israeli {
    return Intl.message('Israeli', name: 'israeli', desc: '', args: []);
  }

  /// `Issue Type`
  String get issueType {
    return Intl.message('Issue Type', name: 'issueType', desc: '', args: []);
  }

  /// `Italian`
  String get italian {
    return Intl.message('Italian', name: 'italian', desc: '', args: []);
  }

  /// `It can view or Join with invite`
  String get itCanViewOrJoinWithInvite {
    return Intl.message(
      'It can view or Join with invite',
      name: 'itCanViewOrJoinWithInvite',
      desc: '',
      args: [],
    );
  }

  /// `IT Department`
  String get itDepartment {
    return Intl.message(
      'IT Department',
      name: 'itDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Item added successfully`
  String get itemAddSuccessful {
    return Intl.message(
      'Item added successfully',
      name: 'itemAddSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Item Already Assigned`
  String get itemAlreadyAssigned {
    return Intl.message(
      'Item Already Assigned',
      name: 'itemAlreadyAssigned',
      desc: '',
      args: [],
    );
  }

  /// `This item has already been assigned to someone. You cannot select it for assignment.`
  String get itemAssignedMessage {
    return Intl.message(
      'This item has already been assigned to someone. You cannot select it for assignment.',
      name: 'itemAssignedMessage',
      desc: '',
      args: [],
    );
  }

  /// `List Of Items Replaced/Used`
  String get itemsReplacedUsed {
    return Intl.message(
      'List Of Items Replaced/Used',
      name: 'itemsReplacedUsed',
      desc: '',
      args: [],
    );
  }

  /// `Ivorian`
  String get ivorian {
    return Intl.message('Ivorian', name: 'ivorian', desc: '', args: []);
  }

  /// `Jamaican`
  String get jamaican {
    return Intl.message('Jamaican', name: 'jamaican', desc: '', args: []);
  }

  /// `Jan`
  String get jan {
    return Intl.message('Jan', name: 'jan', desc: '', args: []);
  }

  /// `Japanese`
  String get japanese {
    return Intl.message('Japanese', name: 'japanese', desc: '', args: []);
  }

  /// `Job Location`
  String get jobLocation {
    return Intl.message(
      'Job Location',
      name: 'jobLocation',
      desc: '',
      args: [],
    );
  }

  /// `Job Title`
  String get jobTitle {
    return Intl.message('Job Title', name: 'jobTitle', desc: '', args: []);
  }

  /// `Job Title`
  String get JobTitle {
    return Intl.message('Job Title', name: 'JobTitle', desc: '', args: []);
  }

  /// `Job Title Missing`
  String get jobTitleMissing {
    return Intl.message(
      'Job Title Missing',
      name: 'jobTitleMissing',
      desc: '',
      args: [],
    );
  }

  /// `Job Type`
  String get jobType {
    return Intl.message('Job Type', name: 'jobType', desc: '', args: []);
  }

  /// `Jordanian`
  String get jordanian {
    return Intl.message('Jordanian', name: 'jordanian', desc: '', args: []);
  }

  /// `Jul`
  String get jul {
    return Intl.message('Jul', name: 'jul', desc: '', args: []);
  }

  /// `Jun`
  String get jun {
    return Intl.message('Jun', name: 'jun', desc: '', args: []);
  }

  /// `Justification must be at least 10 characters`
  String get justificationMustBeAtLeast10Characters {
    return Intl.message(
      'Justification must be at least 10 characters',
      name: 'justificationMustBeAtLeast10Characters',
      desc: '',
      args: [],
    );
  }

  /// `Justifications`
  String get Justifications {
    return Intl.message(
      'Justifications',
      name: 'Justifications',
      desc: '',
      args: [],
    );
  }

  /// `Justifications`
  String get justifications {
    return Intl.message(
      'Justifications',
      name: 'justifications',
      desc: '',
      args: [],
    );
  }

  /// `K`
  String get k {
    return Intl.message('K', name: 'k', desc: '', args: []);
  }

  /// `1h`
  String get k1h {
    return Intl.message('1h', name: 'k1h', desc: '', args: []);
  }

  /// `1 H Before`
  String get k1HBefore {
    return Intl.message('1 H Before', name: 'k1HBefore', desc: '', args: []);
  }

  /// `+1K`
  String get k1k {
    return Intl.message('+1K', name: 'k1k', desc: '', args: []);
  }

  /// `1st`
  String get k1st {
    return Intl.message('1st', name: 'k1st', desc: '', args: []);
  }

  /// `2 H Before`
  String get k2HBefore {
    return Intl.message('2 H Before', name: 'k2HBefore', desc: '', args: []);
  }

  /// `2nd`
  String get k2nd {
    return Intl.message('2nd', name: 'k2nd', desc: '', args: []);
  }

  /// `3rd`
  String get k3rd {
    return Intl.message('3rd', name: 'k3rd', desc: '', args: []);
  }

  /// `Kazakhstani`
  String get kazakhstani {
    return Intl.message('Kazakhstani', name: 'kazakhstani', desc: '', args: []);
  }

  /// `Kenyan`
  String get kenyan {
    return Intl.message('Kenyan', name: 'kenyan', desc: '', args: []);
  }

  /// `Kindly assign a role to the employee. This is a required field for access permissions.`
  String get kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc {
    return Intl.message(
      'Kindly assign a role to the employee. This is a required field for access permissions.',
      name: 'kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s first name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor {
    return Intl.message(
      'Kindly enter the employee’s first name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s last name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI {
    return Intl.message(
      'Kindly enter the employee’s last name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the employee’s middle name. This field is mandatory for identification`
  String get kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo {
    return Intl.message(
      'Kindly enter the employee’s middle name. This field is mandatory for identification',
      name: 'kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo',
      desc: '',
      args: [],
    );
  }

  /// `Kindly enter the name of the department to complete the assignment.`
  String get kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen {
    return Intl.message(
      'Kindly enter the name of the department to complete the assignment.',
      name: 'kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen',
      desc: '',
      args: [],
    );
  }

  /// `Kindly provide the Arabic translation of the job title for bilingual records`
  String get kindlyProvideTheArabicTranslationOfTheJobTitleForBiling {
    return Intl.message(
      'Kindly provide the Arabic translation of the job title for bilingual records',
      name: 'kindlyProvideTheArabicTranslationOfTheJobTitleForBiling',
      desc: '',
      args: [],
    );
  }

  /// `Kittian and Nevisian`
  String get kittianAndNevisian {
    return Intl.message(
      'Kittian and Nevisian',
      name: 'kittianAndNevisian',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub`
  String get knowledge_hub {
    return Intl.message(
      'Knowledge Hub',
      name: 'knowledge_hub',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Monthly Comparison`
  String get knowledge_monthly_comparison {
    return Intl.message(
      'Knowledge Monthly Comparison',
      name: 'knowledge_monthly_comparison',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub`
  String get knowledgeHub {
    return Intl.message(
      'Knowledge Hub',
      name: 'knowledgeHub',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub Permissions`
  String get knowledgeHubPermissions {
    return Intl.message(
      'Knowledge Hub Permissions',
      name: 'knowledgeHubPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Knowledge Hub Resources`
  String get knowledgeHubResources {
    return Intl.message(
      'Knowledge Hub Resources',
      name: 'knowledgeHubResources',
      desc: '',
      args: [],
    );
  }

  /// `You removed this knowledge successfully`
  String get knowledgeRemovedSuccessfully {
    return Intl.message(
      'You removed this knowledge successfully',
      name: 'knowledgeRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Kuwaiti`
  String get kuwaiti {
    return Intl.message('Kuwaiti', name: 'kuwaiti', desc: '', args: []);
  }

  /// `Kyrgyz`
  String get kyrgyz {
    return Intl.message('Kyrgyz', name: 'kyrgyz', desc: '', args: []);
  }

  /// `Labeling / Scanning Devices`
  String get labelingScanningDevices {
    return Intl.message(
      'Labeling / Scanning Devices',
      name: 'labelingScanningDevices',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Laotian`
  String get laotian {
    return Intl.message('Laotian', name: 'laotian', desc: '', args: []);
  }

  /// `Last Edit`
  String get last_edit {
    return Intl.message('Last Edit', name: 'last_edit', desc: '', args: []);
  }

  /// `Last Login`
  String get last_login {
    return Intl.message('Last Login', name: 'last_login', desc: '', args: []);
  }

  /// `Last Edit`
  String get lastEdit {
    return Intl.message('Last Edit', name: 'lastEdit', desc: '', args: []);
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message('Last Month', name: 'lastMonth', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Last Name Missing`
  String get lastNameMissing {
    return Intl.message(
      'Last Name Missing',
      name: 'lastNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Last Name is required`
  String get lastNameRequired {
    return Intl.message(
      'Last Name is required',
      name: 'lastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Last Seen Date`
  String get lastSeenDate {
    return Intl.message(
      'Last Seen Date',
      name: 'lastSeenDate',
      desc: '',
      args: [],
    );
  }

  /// `Last Seen Location`
  String get lastSeenLocation {
    return Intl.message(
      'Last Seen Location',
      name: 'lastSeenLocation',
      desc: '',
      args: [],
    );
  }

  /// `Last Update`
  String get lastUpdate {
    return Intl.message('Last Update', name: 'lastUpdate', desc: '', args: []);
  }

  /// `Last update`
  String get Lastupdate {
    return Intl.message('Last update', name: 'Lastupdate', desc: '', args: []);
  }

  /// `Last Week`
  String get lastWeek {
    return Intl.message('Last Week', name: 'lastWeek', desc: '', args: []);
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message('Last Year', name: 'lastYear', desc: '', args: []);
  }

  /// `Late`
  String get late {
    return Intl.message('Late', name: 'late', desc: '', args: []);
  }

  /// `Late History`
  String get lateHistory {
    return Intl.message(
      'Late History',
      name: 'lateHistory',
      desc: '',
      args: [],
    );
  }

  /// `Latitude`
  String get latitude {
    return Intl.message('Latitude', name: 'latitude', desc: '', args: []);
  }

  /// `Latitude invalid.`
  String get latitudeInvalid {
    return Intl.message(
      'Latitude invalid.',
      name: 'latitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Latvian`
  String get latvian {
    return Intl.message('Latvian', name: 'latvian', desc: '', args: []);
  }

  /// `Leader`
  String get leader {
    return Intl.message('Leader', name: 'leader', desc: '', args: []);
  }

  /// `Least`
  String get least {
    return Intl.message('Least', name: 'least', desc: '', args: []);
  }

  /// `Leaving Time`
  String get leavingTime {
    return Intl.message(
      'Leaving Time',
      name: 'leavingTime',
      desc: '',
      args: [],
    );
  }

  /// `Lebanese`
  String get lebanese {
    return Intl.message('Lebanese', name: 'lebanese', desc: '', args: []);
  }

  /// `Legal Department`
  String get legalDepartment {
    return Intl.message(
      'Legal Department',
      name: 'legalDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Legal Officer`
  String get legalOfficer {
    return Intl.message(
      'Legal Officer',
      name: 'legalOfficer',
      desc: '',
      args: [],
    );
  }

  /// `Less than 30 minutes`
  String get lessThan30Minutes {
    return Intl.message(
      'Less than 30 minutes',
      name: 'lessThan30Minutes',
      desc: '',
      args: [],
    );
  }

  /// `Letter`
  String get letter {
    return Intl.message('Letter', name: 'letter', desc: '', args: []);
  }

  /// `Liberian`
  String get liberian {
    return Intl.message('Liberian', name: 'liberian', desc: '', args: []);
  }

  /// `Libyan`
  String get libyan {
    return Intl.message('Libyan', name: 'libyan', desc: '', args: []);
  }

  /// `Liechtensteiner`
  String get liechtensteiner {
    return Intl.message(
      'Liechtensteiner',
      name: 'liechtensteiner',
      desc: '',
      args: [],
    );
  }

  /// `Life Insurance Card`
  String get lifeInsuranceCard {
    return Intl.message(
      'Life Insurance Card',
      name: 'lifeInsuranceCard',
      desc: '',
      args: [],
    );
  }

  /// `Lifting Crane / Hoist`
  String get liftingCrane {
    return Intl.message(
      'Lifting Crane / Hoist',
      name: 'liftingCrane',
      desc: '',
      args: [],
    );
  }

  /// `Light/Dark Mode`
  String get lightDarkMode {
    return Intl.message(
      'Light/Dark Mode',
      name: 'lightDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Lighting Inspection`
  String get lightingInspection {
    return Intl.message(
      'Lighting Inspection',
      name: 'lightingInspection',
      desc: '',
      args: [],
    );
  }

  /// `Limit Department Availability`
  String get limit_department_availability {
    return Intl.message(
      'Limit Department Availability',
      name: 'limit_department_availability',
      desc: '',
      args: [],
    );
  }

  /// `Limit Department Availability`
  String get limitDepartmentAvailability {
    return Intl.message(
      'Limit Department Availability',
      name: 'limitDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Limited Department Availability`
  String get limitedDepartmentAvailability {
    return Intl.message(
      'Limited Department Availability',
      name: 'limitedDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Limit Location Availability`
  String get limitLocationAvailability {
    return Intl.message(
      'Limit Location Availability',
      name: 'limitLocationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Limit Service Availability`
  String get limitServiceAvailability {
    return Intl.message(
      'Limit Service Availability',
      name: 'limitServiceAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Link invalid`
  String get linkInvalid {
    return Intl.message(
      'Link invalid',
      name: 'linkInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Links`
  String get links {
    return Intl.message('Links', name: 'links', desc: '', args: []);
  }

  /// `Lithuanian`
  String get lithuanian {
    return Intl.message('Lithuanian', name: 'lithuanian', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Loading dashboard...`
  String get loadingDashboard {
    return Intl.message(
      'Loading dashboard...',
      name: 'loadingDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Loading departments...`
  String get loadingDepartments {
    return Intl.message(
      'Loading departments...',
      name: 'loadingDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Loading employee details`
  String get loadingEmployeeDetails {
    return Intl.message(
      'Loading employee details',
      name: 'loadingEmployeeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get loadMore {
    return Intl.message('Load more', name: 'loadMore', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Location Settings`
  String get location_settings {
    return Intl.message(
      'Location Settings',
      name: 'location_settings',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Added This Location`
  String get locationAddedSuccess {
    return Intl.message(
      'You Successfully Added This Location',
      name: 'locationAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Location at Google Maps`
  String get locationAtGoogleMaps {
    return Intl.message(
      'Location at Google Maps',
      name: 'locationAtGoogleMaps',
      desc: '',
      args: [],
    );
  }

  /// `Location Availability`
  String get locationAvailability {
    return Intl.message(
      'Location Availability',
      name: 'locationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Location Created`
  String get locationCreated {
    return Intl.message(
      'Location Created',
      name: 'locationCreated',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created New Location`
  String get locationCreatedSuccess {
    return Intl.message(
      'You Successfully Created New Location',
      name: 'locationCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Location Deleted`
  String get locationDeleted {
    return Intl.message(
      'Location Deleted',
      name: 'locationDeleted',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Location`
  String get locationDeletedSuccess {
    return Intl.message(
      'You Successfully Deleted This Location',
      name: 'locationDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Location Delivery`
  String get locationDelivery {
    return Intl.message(
      'Location Delivery',
      name: 'locationDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Location Description`
  String get locationDescription {
    return Intl.message(
      'Location Description',
      name: 'locationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Location Details`
  String get locationDetails {
    return Intl.message(
      'Location Details',
      name: 'locationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Location Edited`
  String get locationEdited {
    return Intl.message(
      'Location Edited',
      name: 'locationEdited',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Location`
  String get locationEditedSuccess {
    return Intl.message(
      'You Successfully Edited This Location',
      name: 'locationEditedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Location ID`
  String get locationID {
    return Intl.message('Location ID', name: 'locationID', desc: '', args: []);
  }

  /// `Location Information`
  String get locationInformation {
    return Intl.message(
      'Location Information',
      name: 'locationInformation',
      desc: '',
      args: [],
    );
  }

  /// `Location Name`
  String get locationName {
    return Intl.message(
      'Location Name',
      name: 'locationName',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get locations {
    return Intl.message('Locations', name: 'locations', desc: '', args: []);
  }

  /// `Location Type`
  String get locationType {
    return Intl.message(
      'Location Type',
      name: 'locationType',
      desc: '',
      args: [],
    );
  }

  /// `Location Type is required`
  String get locationTypeRequired {
    return Intl.message(
      'Location Type is required',
      name: 'locationTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Locker`
  String get locker {
    return Intl.message('Locker', name: 'locker', desc: '', args: []);
  }

  /// `Lock Geographical`
  String get lockGeographical {
    return Intl.message(
      'Lock Geographical',
      name: 'lockGeographical',
      desc: '',
      args: [],
    );
  }

  /// `Log Activity`
  String get logActivity {
    return Intl.message(
      'Log Activity',
      name: 'logActivity',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `London`
  String get london {
    return Intl.message('London', name: 'london', desc: '', args: []);
  }

  /// `Longitude`
  String get longitude {
    return Intl.message('Longitude', name: 'longitude', desc: '', args: []);
  }

  /// `Longitude invalid.`
  String get longitudeInvalid {
    return Intl.message(
      'Longitude invalid.',
      name: 'longitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `Low Stock`
  String get lowStock {
    return Intl.message('Low Stock', name: 'lowStock', desc: '', args: []);
  }

  /// `Luxembourger`
  String get luxembourger {
    return Intl.message(
      'Luxembourger',
      name: 'luxembourger',
      desc: '',
      args: [],
    );
  }

  /// `M`
  String get m {
    return Intl.message('M', name: 'm', desc: '', args: []);
  }

  /// `Macedonian`
  String get macedonian {
    return Intl.message('Macedonian', name: 'macedonian', desc: '', args: []);
  }

  /// `Main Office`
  String get mainOffice {
    return Intl.message('Main Office', name: 'mainOffice', desc: '', args: []);
  }

  /// `Main Storage`
  String get mainStorage {
    return Intl.message(
      'Main Storage',
      name: 'mainStorage',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance`
  String get maintenance {
    return Intl.message('Maintenance', name: 'maintenance', desc: '', args: []);
  }

  /// `Maintenance Date`
  String get maintenanceDate {
    return Intl.message(
      'Maintenance Date',
      name: 'maintenanceDate',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Details`
  String get maintenanceDetails {
    return Intl.message(
      'Maintenance Details',
      name: 'maintenanceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Frequency`
  String get maintenanceFrequency {
    return Intl.message(
      'Maintenance Frequency',
      name: 'maintenanceFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance ID`
  String get maintenanceId {
    return Intl.message(
      'Maintenance ID',
      name: 'maintenanceId',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Inspector`
  String get maintenanceInspector {
    return Intl.message(
      'Maintenance Inspector',
      name: 'maintenanceInspector',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Requests`
  String get maintenanceRequests {
    return Intl.message(
      'Maintenance Requests',
      name: 'maintenanceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Schedule`
  String get maintenanceSchedule {
    return Intl.message(
      'Maintenance Schedule',
      name: 'maintenanceSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Service`
  String get maintenanceService {
    return Intl.message(
      'Maintenance Service',
      name: 'maintenanceService',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance Status`
  String get maintenanceStatus {
    return Intl.message(
      'Maintenance Status',
      name: 'maintenanceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Make Private`
  String get makePrivate {
    return Intl.message(
      'Make Private',
      name: 'makePrivate',
      desc: '',
      args: [],
    );
  }

  /// `Malagasy`
  String get malagasy {
    return Intl.message('Malagasy', name: 'malagasy', desc: '', args: []);
  }

  /// `Malawian`
  String get malawian {
    return Intl.message('Malawian', name: 'malawian', desc: '', args: []);
  }

  /// `Malaysian`
  String get malaysian {
    return Intl.message('Malaysian', name: 'malaysian', desc: '', args: []);
  }

  /// `Maldivan`
  String get maldivan {
    return Intl.message('Maldivan', name: 'maldivan', desc: '', args: []);
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Malian`
  String get malian {
    return Intl.message('Malian', name: 'malian', desc: '', args: []);
  }

  /// `Maltese`
  String get maltese {
    return Intl.message('Maltese', name: 'maltese', desc: '', args: []);
  }

  /// `Manage Attendance`
  String get manageAttendance {
    return Intl.message(
      'Manage Attendance',
      name: 'manageAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Manage Benefits`
  String get manageBenefits {
    return Intl.message(
      'Manage Benefits',
      name: 'manageBenefits',
      desc: '',
      args: [],
    );
  }

  /// `Manage Departments`
  String get manageDepartments {
    return Intl.message(
      'Manage Departments',
      name: 'manageDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Manage Job Positions`
  String get manageJobPositions {
    return Intl.message(
      'Manage Job Positions',
      name: 'manageJobPositions',
      desc: '',
      args: [],
    );
  }

  /// `Manage Offboarding`
  String get manageOffboarding {
    return Intl.message(
      'Manage Offboarding',
      name: 'manageOffboarding',
      desc: '',
      args: [],
    );
  }

  /// `Manage Onboarding`
  String get manageOnboarding {
    return Intl.message(
      'Manage Onboarding',
      name: 'manageOnboarding',
      desc: '',
      args: [],
    );
  }

  /// `Manage Payroll`
  String get managePayroll {
    return Intl.message(
      'Manage Payroll',
      name: 'managePayroll',
      desc: '',
      args: [],
    );
  }

  /// `Manage Pipeline`
  String get managePipeline {
    return Intl.message(
      'Manage Pipeline',
      name: 'managePipeline',
      desc: '',
      args: [],
    );
  }

  /// `Manager`
  String get manager {
    return Intl.message('Manager', name: 'manager', desc: '', args: []);
  }

  /// `Manager Approval`
  String get managerApproval {
    return Intl.message(
      'Manager Approval',
      name: 'managerApproval',
      desc: '',
      args: [],
    );
  }

  /// `Managerial Access`
  String get managerialAccess {
    return Intl.message(
      'Managerial Access',
      name: 'managerialAccess',
      desc: '',
      args: [],
    );
  }

  /// ` If It Requires Approval`
  String get ManagerIfItRequiresApproval {
    return Intl.message(
      ' If It Requires Approval',
      name: 'ManagerIfItRequiresApproval',
      desc: '',
      args: [],
    );
  }

  /// `Manage Training`
  String get manageTraining {
    return Intl.message(
      'Manage Training',
      name: 'manageTraining',
      desc: '',
      args: [],
    );
  }

  /// `Mandarin Chinese`
  String get mandarinChinese {
    return Intl.message(
      'Mandarin Chinese',
      name: 'mandarinChinese',
      desc: '',
      args: [],
    );
  }

  /// `Mandate`
  String get mandate {
    return Intl.message('Mandate', name: 'mandate', desc: '', args: []);
  }

  /// `Mar`
  String get mar {
    return Intl.message('Mar', name: 'mar', desc: '', args: []);
  }

  /// `Marital Certificate`
  String get maritalCertificate {
    return Intl.message(
      'Marital Certificate',
      name: 'maritalCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Marital Status`
  String get maritalStatus {
    return Intl.message(
      'Marital Status',
      name: 'maritalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Marketing`
  String get Marketing {
    return Intl.message('Marketing', name: 'Marketing', desc: '', args: []);
  }

  /// `Marketing`
  String get marketing {
    return Intl.message('Marketing', name: 'marketing', desc: '', args: []);
  }

  /// `Marketing lead`
  String get marketingLead {
    return Intl.message(
      'Marketing lead',
      name: 'marketingLead',
      desc: '',
      args: [],
    );
  }

  /// `Marketing Manager`
  String get marketingManager {
    return Intl.message(
      'Marketing Manager',
      name: 'marketingManager',
      desc: '',
      args: [],
    );
  }

  /// `Marketing Team`
  String get marketingTeam {
    return Intl.message(
      'Marketing Team',
      name: 'marketingTeam',
      desc: '',
      args: [],
    );
  }

  /// `Market Research Service`
  String get marketResearchService {
    return Intl.message(
      'Market Research Service',
      name: 'marketResearchService',
      desc: '',
      args: [],
    );
  }

  /// `Marriage Vacation`
  String get marriageVacation {
    return Intl.message(
      'Marriage Vacation',
      name: 'marriageVacation',
      desc: '',
      args: [],
    );
  }

  /// `Married`
  String get married {
    return Intl.message('Married', name: 'married', desc: '', args: []);
  }

  /// `Marshallese`
  String get marshallese {
    return Intl.message('Marshallese', name: 'marshallese', desc: '', args: []);
  }

  /// `Martial Service Proof`
  String get martialServiceProof {
    return Intl.message(
      'Martial Service Proof',
      name: 'martialServiceProof',
      desc: '',
      args: [],
    );
  }

  /// `Master Bulk Upload`
  String get masterBulkUpload {
    return Intl.message(
      'Master Bulk Upload',
      name: 'masterBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Master's Degree`
  String get masterDegree {
    return Intl.message(
      'Master\'s Degree',
      name: 'masterDegree',
      desc: '',
      args: [],
    );
  }

  /// `Master Upload`
  String get masterUpload {
    return Intl.message(
      'Master Upload',
      name: 'masterUpload',
      desc: '',
      args: [],
    );
  }

  /// `matches`
  String get matches {
    return Intl.message('matches', name: 'matches', desc: '', args: []);
  }

  /// `Matches`
  String get matches2 {
    return Intl.message('Matches', name: 'matches2', desc: '', args: []);
  }

  /// `Mauritanian`
  String get mauritanian {
    return Intl.message('Mauritanian', name: 'mauritanian', desc: '', args: []);
  }

  /// `Mauritian`
  String get mauritian {
    return Intl.message('Mauritian', name: 'mauritian', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `Mechanical`
  String get mechanical {
    return Intl.message('Mechanical', name: 'mechanical', desc: '', args: []);
  }

  /// `Media`
  String get media {
    return Intl.message('Media', name: 'media', desc: '', args: []);
  }

  /// `Media, links, and docs`
  String get mediaLinksAndDocs {
    return Intl.message(
      'Media, links, and docs',
      name: 'mediaLinksAndDocs',
      desc: '',
      args: [],
    );
  }

  /// `Media Team`
  String get mediaTeam {
    return Intl.message('Media Team', name: 'mediaTeam', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Meeting`
  String get meeting {
    return Intl.message('Meeting', name: 'meeting', desc: '', args: []);
  }

  /// `Member`
  String get member {
    return Intl.message('Member', name: 'member', desc: '', args: []);
  }

  /// `members voted`
  String get membersVoted {
    return Intl.message(
      'members voted',
      name: 'membersVoted',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Message added to starred messages!`
  String get messageAddedToStarredMessages {
    return Intl.message(
      'Message added to starred messages!',
      name: 'messageAddedToStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Message Form Owner`
  String get messageFormOwner {
    return Intl.message(
      'Message Form Owner',
      name: 'messageFormOwner',
      desc: '',
      args: [],
    );
  }

  /// `Message removed from starred messages!`
  String get messageRemovedFromStarredMessages {
    return Intl.message(
      'Message removed from starred messages!',
      name: 'messageRemovedFromStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Messages Permissions`
  String get messagesPermissions {
    return Intl.message(
      'Messages Permissions',
      name: 'messagesPermissions',
      desc: '',
      args: [],
    );
  }

  /// `meter`
  String get meter {
    return Intl.message('meter', name: 'meter', desc: '', args: []);
  }

  /// `meter2`
  String get meter2 {
    return Intl.message('meter2', name: 'meter2', desc: '', args: []);
  }

  /// `Method of Payment`
  String get methodOfPayment {
    return Intl.message(
      'Method of Payment',
      name: 'methodOfPayment',
      desc: '',
      args: [],
    );
  }

  /// `Mexican`
  String get mexican {
    return Intl.message('Mexican', name: 'mexican', desc: '', args: []);
  }

  /// `Micronesian`
  String get micronesian {
    return Intl.message('Micronesian', name: 'micronesian', desc: '', args: []);
  }

  /// `Middle Name`
  String get middleName {
    return Intl.message('Middle Name', name: 'middleName', desc: '', args: []);
  }

  /// `Middle Name Missing`
  String get middleNameMissing {
    return Intl.message(
      'Middle Name Missing',
      name: 'middleNameMissing',
      desc: '',
      args: [],
    );
  }

  /// `Middle name is required.`
  String get middleNameRequired {
    return Intl.message(
      'Middle name is required.',
      name: 'middleNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Mins`
  String get mins {
    return Intl.message('Mins', name: 'mins', desc: '', args: []);
  }

  /// `Minute`
  String get minute {
    return Intl.message('Minute', name: 'minute', desc: '', args: []);
  }

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Minutes Ago`
  String get minutesAgo {
    return Intl.message('Minutes Ago', name: 'minutesAgo', desc: '', args: []);
  }

  /// `30 Minutes`
  String get minutesShort {
    return Intl.message('30 Minutes', name: 'minutesShort', desc: '', args: []);
  }

  /// `Missing`
  String get missing {
    return Intl.message('Missing', name: 'missing', desc: '', args: []);
  }

  /// `Missing column`
  String get missingColumn {
    return Intl.message(
      'Missing column',
      name: 'missingColumn',
      desc: '',
      args: [],
    );
  }

  /// `Missing columns`
  String get missingColumns {
    return Intl.message(
      'Missing columns',
      name: 'missingColumns',
      desc: '',
      args: [],
    );
  }

  /// `Missing Date`
  String get missingDate {
    return Intl.message(
      'Missing Date',
      name: 'missingDate',
      desc: '',
      args: [],
    );
  }

  /// `Missing Department ID`
  String get missingDepartmentID {
    return Intl.message(
      'Missing Department ID',
      name: 'missingDepartmentID',
      desc: '',
      args: [],
    );
  }

  /// `Missing Information`
  String get missingInformation {
    return Intl.message(
      'Missing Information',
      name: 'missingInformation',
      desc: '',
      args: [],
    );
  }

  /// `Missing required columns`
  String get missingRequiredColumns {
    return Intl.message(
      'Missing required columns',
      name: 'missingRequiredColumns',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Phone`
  String get mobilePhone {
    return Intl.message(
      'Mobile Phone',
      name: 'mobilePhone',
      desc: '',
      args: [],
    );
  }

  /// `Mobile View`
  String get mobileView {
    return Intl.message('Mobile View', name: 'mobileView', desc: '', args: []);
  }

  /// `Model`
  String get model {
    return Intl.message('Model', name: 'model', desc: '', args: []);
  }

  /// `Module Name`
  String get moduleName {
    return Intl.message('Module Name', name: 'moduleName', desc: '', args: []);
  }

  /// `The Module Name Already Exists`
  String get moduleNameAlreadyExists {
    return Intl.message(
      'The Module Name Already Exists',
      name: 'moduleNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Module Owner`
  String get moduleOwner {
    return Intl.message(
      'Module Owner',
      name: 'moduleOwner',
      desc: '',
      args: [],
    );
  }

  /// `Module Owners`
  String get moduleOwners {
    return Intl.message(
      'Module Owners',
      name: 'moduleOwners',
      desc: '',
      args: [],
    );
  }

  /// `Modules`
  String get modules {
    return Intl.message('Modules', name: 'modules', desc: '', args: []);
  }

  /// `Module updated successfully!`
  String get moduleUpdatedSuccessfully {
    return Intl.message(
      'Module updated successfully!',
      name: 'moduleUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Mohamed`
  String get mohamed {
    return Intl.message('Mohamed', name: 'mohamed', desc: '', args: []);
  }

  /// `Moldovan`
  String get moldovan {
    return Intl.message('Moldovan', name: 'moldovan', desc: '', args: []);
  }

  /// `Monacan`
  String get monacan {
    return Intl.message('Monacan', name: 'monacan', desc: '', args: []);
  }

  /// `Monday`
  String get monday {
    return Intl.message('Monday', name: 'monday', desc: '', args: []);
  }

  /// `Mongolian`
  String get mongolian {
    return Intl.message('Mongolian', name: 'mongolian', desc: '', args: []);
  }

  /// `Monitor humidity levels and adjust if necessary.`
  String get monitorHumidityLevelsAndAdjustIfNecessary {
    return Intl.message(
      'Monitor humidity levels and adjust if necessary.',
      name: 'monitorHumidityLevelsAndAdjustIfNecessary',
      desc: '',
      args: [],
    );
  }

  /// `Months`
  String get month {
    return Intl.message('Months', name: 'month', desc: '', args: []);
  }

  /// `Month`
  String get month2 {
    return Intl.message('Month', name: 'month2', desc: '', args: []);
  }

  /// `Monthly Comparison`
  String get monthlyComparison {
    return Intl.message(
      'Monthly Comparison',
      name: 'monthlyComparison',
      desc: '',
      args: [],
    );
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `Months Ago`
  String get monthsAgo {
    return Intl.message('Months Ago', name: 'monthsAgo', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `More Permissions`
  String get morePermissions {
    return Intl.message(
      'More Permissions',
      name: 'morePermissions',
      desc: '',
      args: [],
    );
  }

  /// `More than 30 minutes`
  String get moreThan30Minutes {
    return Intl.message(
      'More than 30 minutes',
      name: 'moreThan30Minutes',
      desc: '',
      args: [],
    );
  }

  /// `Moroccan`
  String get moroccan {
    return Intl.message('Moroccan', name: 'moroccan', desc: '', args: []);
  }

  /// `Mosotho`
  String get mosotho {
    return Intl.message('Mosotho', name: 'mosotho', desc: '', args: []);
  }

  /// `Most Recent`
  String get mostRecent {
    return Intl.message('Most Recent', name: 'mostRecent', desc: '', args: []);
  }

  /// `Motswana`
  String get motswana {
    return Intl.message('Motswana', name: 'motswana', desc: '', args: []);
  }

  /// `Mozambican`
  String get mozambican {
    return Intl.message('Mozambican', name: 'mozambican', desc: '', args: []);
  }

  /// `Message`
  String get msg {
    return Intl.message('Message', name: 'msg', desc: '', args: []);
  }

  /// `Must be a valid email address`
  String get mustBeAValidEmailAddress {
    return Intl.message(
      'Must be a valid email address',
      name: 'mustBeAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Must be > 0`
  String get mustBeGreaterThanZero {
    return Intl.message(
      'Must be > 0',
      name: 'mustBeGreaterThanZero',
      desc: '',
      args: [],
    );
  }

  /// `Must be ≤ 1000`
  String get mustBeLessThanOrEqual {
    return Intl.message(
      'Must be ≤ 1000',
      name: 'mustBeLessThanOrEqual',
      desc: '',
      args: [],
    );
  }

  /// `Must be a number`
  String get mustBeNumber {
    return Intl.message(
      'Must be a number',
      name: 'mustBeNumber',
      desc: '',
      args: [],
    );
  }

  /// `You must correct all errors before uploading`
  String get mustCorrectErrors {
    return Intl.message(
      'You must correct all errors before uploading',
      name: 'mustCorrectErrors',
      desc: '',
      args: [],
    );
  }

  /// `You must select at least one employee for the approval cycle`
  String get mustSelectApprovalEmployees {
    return Intl.message(
      'You must select at least one employee for the approval cycle',
      name: 'mustSelectApprovalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `You must select at least one department when limiting service availability`
  String get mustSelectDepartment {
    return Intl.message(
      'You must select at least one department when limiting service availability',
      name: 'mustSelectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Mute Notification`
  String get muteNotification {
    return Intl.message(
      'Mute Notification',
      name: 'muteNotification',
      desc: '',
      args: [],
    );
  }

  /// `Mute Notifications`
  String get muteNotifications {
    return Intl.message(
      'Mute Notifications',
      name: 'muteNotifications',
      desc: '',
      args: [],
    );
  }

  /// `My Audit`
  String get myAudit {
    return Intl.message('My Audit', name: 'myAudit', desc: '', args: []);
  }

  /// `My Audits`
  String get myAudits {
    return Intl.message('My Audits', name: 'myAudits', desc: '', args: []);
  }

  /// `My Dashboard`
  String get myDashboard {
    return Intl.message(
      'My Dashboard',
      name: 'myDashboard',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `My Request`
  String get myRequest {
    return Intl.message('My Request', name: 'myRequest', desc: '', args: []);
  }

  /// `My Requests`
  String get myRequests {
    return Intl.message('My Requests', name: 'myRequests', desc: '', args: []);
  }

  /// `My Services`
  String get myServices {
    return Intl.message('My Services', name: 'myServices', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Namibian`
  String get namibian {
    return Intl.message('Namibian', name: 'namibian', desc: '', args: []);
  }

  /// `National ID must be exactly 14 digits long.`
  String get nationalIDMustBeExactly14DigitsLong {
    return Intl.message(
      'National ID must be exactly 14 digits long.',
      name: 'nationalIDMustBeExactly14DigitsLong',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message('Nationality', name: 'nationality', desc: '', args: []);
  }

  /// `Nauruan`
  String get nauruan {
    return Intl.message('Nauruan', name: 'nauruan', desc: '', args: []);
  }

  /// `Navigate the Digital Frontier with Ease`
  String get navigateTheDigitalFrontierWithEase {
    return Intl.message(
      'Navigate the Digital Frontier with Ease',
      name: 'navigateTheDigitalFrontierWithEase',
      desc: '',
      args: [],
    );
  }

  /// `Near Breached SLA`
  String get nearBreachedSLA {
    return Intl.message(
      'Near Breached SLA',
      name: 'nearBreachedSLA',
      desc: '',
      args: [],
    );
  }

  /// `Needs Approval`
  String get NeedsApproval {
    return Intl.message(
      'Needs Approval',
      name: 'NeedsApproval',
      desc: '',
      args: [],
    );
  }

  /// `Nepalese`
  String get nepalese {
    return Intl.message('Nepalese', name: 'nepalese', desc: '', args: []);
  }

  /// `New Details`
  String get new_details {
    return Intl.message('New Details', name: 'new_details', desc: '', args: []);
  }

  /// `New Asset`
  String get newAsset {
    return Intl.message('New Asset', name: 'newAsset', desc: '', args: []);
  }

  /// `New Batch`
  String get newBatch {
    return Intl.message('New Batch', name: 'newBatch', desc: '', args: []);
  }

  /// `Restocking New Batch`
  String get newBatchRestockTitle {
    return Intl.message(
      'Restocking New Batch',
      name: 'newBatchRestockTitle',
      desc: '',
      args: [],
    );
  }

  /// `New champion cannot be the current champion`
  String get newChampionCannotBeTheCurrentChampion {
    return Intl.message(
      'New champion cannot be the current champion',
      name: 'newChampionCannotBeTheCurrentChampion',
      desc: '',
      args: [],
    );
  }

  /// `New Control Champion`
  String get newControlChampion {
    return Intl.message(
      'New Control Champion',
      name: 'newControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `New Control Owner`
  String get newControlOwner {
    return Intl.message(
      'New Control Owner',
      name: 'newControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Newest First`
  String get newestFirst {
    return Intl.message(
      'Newest First',
      name: 'newestFirst',
      desc: '',
      args: [],
    );
  }

  /// `New owner cannot be the current owner`
  String get newOwnerCannotBeTheCurrentOwner {
    return Intl.message(
      'New owner cannot be the current owner',
      name: 'newOwnerCannotBeTheCurrentOwner',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password matches the confirm field.`
  String get newPasswordMatchesConfirmField {
    return Intl.message(
      'New password matches the confirm field.',
      name: 'newPasswordMatchesConfirmField',
      desc: '',
      args: [],
    );
  }

  /// `New Product`
  String get newProduct {
    return Intl.message('New Product', name: 'newProduct', desc: '', args: []);
  }

  /// `New Request`
  String get newRequest {
    return Intl.message('New Request', name: 'newRequest', desc: '', args: []);
  }

  /// `New Storage Location Added`
  String get newStorageLocationAdded {
    return Intl.message(
      'New Storage Location Added',
      name: 'newStorageLocationAdded',
      desc: '',
      args: [],
    );
  }

  /// `New Supplier Added`
  String get newSupplierAdded {
    return Intl.message(
      'New Supplier Added',
      name: 'newSupplierAdded',
      desc: '',
      args: [],
    );
  }

  /// `New Zealander`
  String get newZealander {
    return Intl.message(
      'New Zealander',
      name: 'newZealander',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Next Disposition`
  String get nextDisposition {
    return Intl.message(
      'Next Disposition',
      name: 'nextDisposition',
      desc: '',
      args: [],
    );
  }

  /// `Next Scheduled Date`
  String get nextScheduledDate {
    return Intl.message(
      'Next Scheduled Date',
      name: 'nextScheduledDate',
      desc: '',
      args: [],
    );
  }

  /// `Next Scheduled Maintenance`
  String get nextScheduledMaintenance {
    return Intl.message(
      'Next Scheduled Maintenance',
      name: 'nextScheduledMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Nicaraguan`
  String get nicaraguan {
    return Intl.message('Nicaraguan', name: 'nicaraguan', desc: '', args: []);
  }

  /// `Nigerian`
  String get nigerian {
    return Intl.message('Nigerian', name: 'nigerian', desc: '', args: []);
  }

  /// `Nigerien`
  String get nigerien {
    return Intl.message('Nigerien', name: 'nigerien', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `NO`
  String get NO {
    return Intl.message('NO', name: 'NO', desc: '', args: []);
  }

  /// `No canceled or rejected services found`
  String get no_data_available {
    return Intl.message(
      'No canceled or rejected services found',
      name: 'no_data_available',
      desc: '',
      args: [],
    );
  }

  /// `No specific permissions`
  String get no_specific_permissions {
    return Intl.message(
      'No specific permissions',
      name: 'no_specific_permissions',
      desc: '',
      args: [],
    );
  }

  /// `No active tasks`
  String get noActiveTasks {
    return Intl.message(
      'No active tasks',
      name: 'noActiveTasks',
      desc: '',
      args: [],
    );
  }

  /// `No analytics data available yet`
  String get noAnalyticsDataAvailableYet {
    return Intl.message(
      'No analytics data available yet',
      name: 'noAnalyticsDataAvailableYet',
      desc: '',
      args: [],
    );
  }

  /// `No approvals`
  String get noApprovals {
    return Intl.message(
      'No approvals',
      name: 'noApprovals',
      desc: '',
      args: [],
    );
  }

  /// `No approvals found`
  String get noApprovalsFound {
    return Intl.message(
      'No approvals found',
      name: 'noApprovalsFound',
      desc: '',
      args: [],
    );
  }

  /// `No approvals in this status`
  String get noApprovalsInThisStatus {
    return Intl.message(
      'No approvals in this status',
      name: 'noApprovalsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No approvals match your filters`
  String get noApprovalsMatchFilters {
    return Intl.message(
      'No approvals match your filters',
      name: 'noApprovalsMatchFilters',
      desc: '',
      args: [],
    );
  }

  /// `No attachments available`
  String get noAttachmentsAvailable {
    return Intl.message(
      'No attachments available',
      name: 'noAttachmentsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No audits in this status`
  String get noAuditsInThisStatus {
    return Intl.message(
      'No audits in this status',
      name: 'noAuditsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No Change Found`
  String get noChangeFound {
    return Intl.message(
      'No Change Found',
      name: 'noChangeFound',
      desc: '',
      args: [],
    );
  }

  /// `No comments yet`
  String get noCommentsYet {
    return Intl.message(
      'No comments yet',
      name: 'noCommentsYet',
      desc: '',
      args: [],
    );
  }

  /// `No common groups`
  String get noCommonGroups {
    return Intl.message(
      'No common groups',
      name: 'noCommonGroups',
      desc: '',
      args: [],
    );
  }

  /// `No control champions found`
  String get noControlChampionsFound {
    return Intl.message(
      'No control champions found',
      name: 'noControlChampionsFound',
      desc: '',
      args: [],
    );
  }

  /// `No control owners found`
  String get noControlOwnersFound {
    return Intl.message(
      'No control owners found',
      name: 'noControlOwnersFound',
      desc: '',
      args: [],
    );
  }

  /// `No controls assigned`
  String get noControlsAssigned {
    return Intl.message(
      'No controls assigned',
      name: 'noControlsAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No controls found`
  String get noControlsFound {
    return Intl.message(
      'No controls found',
      name: 'noControlsFound',
      desc: '',
      args: [],
    );
  }

  /// `No controls in this status`
  String get noControlsInThisStatus {
    return Intl.message(
      'No controls in this status',
      name: 'noControlsInThisStatus',
      desc: '',
      args: [],
    );
  }

  /// `No countries found`
  String get noCountriesFound {
    return Intl.message(
      'No countries found',
      name: 'noCountriesFound',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get noData {
    return Intl.message('No Data', name: 'noData', desc: '', args: []);
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No data rows found in the Excel file`
  String get noDataRowsFoundInTheExcelFile {
    return Intl.message(
      'No data rows found in the Excel file',
      name: 'noDataRowsFoundInTheExcelFile',
      desc: '',
      args: [],
    );
  }

  /// `No Docs`
  String get noDocs {
    return Intl.message('No Docs', name: 'noDocs', desc: '', args: []);
  }

  /// `No documents found`
  String get noDocumentsFound {
    return Intl.message(
      'No documents found',
      name: 'noDocumentsFound',
      desc: '',
      args: [],
    );
  }

  /// `No employees at this location`
  String get noEmployeesAtLocation {
    return Intl.message(
      'No employees at this location',
      name: 'noEmployeesAtLocation',
      desc: '',
      args: [],
    );
  }

  /// `No employees found`
  String get noEmployeesFound {
    return Intl.message(
      'No employees found',
      name: 'noEmployeesFound',
      desc: '',
      args: [],
    );
  }

  /// `No file selected`
  String get noFileSelected {
    return Intl.message(
      'No file selected',
      name: 'noFileSelected',
      desc: '',
      args: [],
    );
  }

  /// `No GRC modules found`
  String get noGrcModulesFound {
    return Intl.message(
      'No GRC modules found',
      name: 'noGrcModulesFound',
      desc: '',
      args: [],
    );
  }

  /// `No Group Found`
  String get noGroupFound {
    return Intl.message(
      'No Group Found',
      name: 'noGroupFound',
      desc: '',
      args: [],
    );
  }

  /// `No groups in common`
  String get noGroupsInCommon {
    return Intl.message(
      'No groups in common',
      name: 'noGroupsInCommon',
      desc: '',
      args: [],
    );
  }

  /// `No image selected`
  String get noImageSelected {
    return Intl.message(
      'No image selected',
      name: 'noImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `No knowledge documents found`
  String get noKnowledgedocumentsFound {
    return Intl.message(
      'No knowledge documents found',
      name: 'noKnowledgedocumentsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Links`
  String get noLinks {
    return Intl.message('No Links', name: 'noLinks', desc: '', args: []);
  }

  /// `No Locations Found`
  String get noLocationsFound {
    return Intl.message(
      'No Locations Found',
      name: 'noLocationsFound',
      desc: '',
      args: [],
    );
  }

  /// `No matches found`
  String get noMatchesFound {
    return Intl.message(
      'No matches found',
      name: 'noMatchesFound',
      desc: '',
      args: [],
    );
  }

  /// `No Media`
  String get noMedia {
    return Intl.message('No Media', name: 'noMedia', desc: '', args: []);
  }

  /// `No modules granted`
  String get noModulesGranted {
    return Intl.message(
      'No modules granted',
      name: 'noModulesGranted',
      desc: '',
      args: [],
    );
  }

  /// `No more results`
  String get noMoreResults {
    return Intl.message(
      'No more results',
      name: 'noMoreResults',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `No near breached SLA services`
  String get noNearBreachedSLAServices {
    return Intl.message(
      'No near breached SLA services',
      name: 'noNearBreachedSLAServices',
      desc: '',
      args: [],
    );
  }

  /// `Non-Numeric Characters in National ID`
  String get nonNumericCharactersInNationalID {
    return Intl.message(
      'Non-Numeric Characters in National ID',
      name: 'nonNumericCharactersInNationalID',
      desc: '',
      args: [],
    );
  }

  /// `No of Controls`
  String get noOfControls {
    return Intl.message(
      'No of Controls',
      name: 'noOfControls',
      desc: '',
      args: [],
    );
  }

  /// `No of Departments`
  String get noOfDepartments {
    return Intl.message(
      'No of Departments',
      name: 'noOfDepartments',
      desc: '',
      args: [],
    );
  }

  /// `No. of Service`
  String get NoOfService {
    return Intl.message(
      'No. of Service',
      name: 'NoOfService',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get noOrdersFound {
    return Intl.message(
      'No orders found',
      name: 'noOrdersFound',
      desc: '',
      args: [],
    );
  }

  /// `No owners assigned`
  String get noOwnersAssigned {
    return Intl.message(
      'No owners assigned',
      name: 'noOwnersAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No people found`
  String get noPeopleFound {
    return Intl.message(
      'No people found',
      name: 'noPeopleFound',
      desc: '',
      args: [],
    );
  }

  /// `No permission configuration needed for these modules.`
  String get noPermissionNeeded {
    return Intl.message(
      'No permission configuration needed for these modules.',
      name: 'noPermissionNeeded',
      desc: '',
      args: [],
    );
  }

  /// `Your role doesn't allow creating groups`
  String get noPermissionToCreateGroup {
    return Intl.message(
      'Your role doesn\'t allow creating groups',
      name: 'noPermissionToCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `No permissions found`
  String get noPermissionsFound {
    return Intl.message(
      'No permissions found',
      name: 'noPermissionsFound',
      desc: '',
      args: [],
    );
  }

  /// `No policies found`
  String get noPoliciesFound {
    return Intl.message(
      'No policies found',
      name: 'noPoliciesFound',
      desc: '',
      args: [],
    );
  }

  /// `No previous control owners`
  String get noPreviousControlOwners {
    return Intl.message(
      'No previous control owners',
      name: 'noPreviousControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `No previous module owners`
  String get noPreviousModuleOwners {
    return Intl.message(
      'No previous module owners',
      name: 'noPreviousModuleOwners',
      desc: '',
      args: [],
    );
  }

  /// `No provider data found.`
  String get Noproviderdatafound {
    return Intl.message(
      'No provider data found.',
      name: 'Noproviderdatafound',
      desc: '',
      args: [],
    );
  }

  /// `No resources data available`
  String get noResourcesDataAvailable {
    return Intl.message(
      'No resources data available',
      name: 'noResourcesDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get noResults {
    return Intl.message('No results', name: 'noResults', desc: '', args: []);
  }

  /// `No Role`
  String get noRole {
    return Intl.message('No Role', name: 'noRole', desc: '', args: []);
  }

  /// `No roles to export`
  String get noRolesToExport {
    return Intl.message(
      'No roles to export',
      name: 'noRolesToExport',
      desc: '',
      args: [],
    );
  }

  /// `Northern Irish`
  String get northernIrish {
    return Intl.message(
      'Northern Irish',
      name: 'northernIrish',
      desc: '',
      args: [],
    );
  }

  /// `North Korean`
  String get northKorean {
    return Intl.message(
      'North Korean',
      name: 'northKorean',
      desc: '',
      args: [],
    );
  }

  /// `Norwegian`
  String get norwegian {
    return Intl.message('Norwegian', name: 'norwegian', desc: '', args: []);
  }

  /// `No Search Results`
  String get noSearchResults {
    return Intl.message(
      'No Search Results',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `No services found`
  String get noServicesFound {
    return Intl.message(
      'No services found',
      name: 'noServicesFound',
      desc: '',
      args: [],
    );
  }

  /// `No starred messages`
  String get noStarredMessages {
    return Intl.message(
      'No starred messages',
      name: 'noStarredMessages',
      desc: '',
      args: [],
    );
  }

  /// `No statistics available`
  String get noStatisticsAvailable {
    return Intl.message(
      'No statistics available',
      name: 'noStatisticsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No statistics available yet`
  String get noStatisticsAvailableYet {
    return Intl.message(
      'No statistics available yet',
      name: 'noStatisticsAvailableYet',
      desc: '',
      args: [],
    );
  }

  /// `No submissions found`
  String get noSubmissionsFound {
    return Intl.message(
      'No submissions found',
      name: 'noSubmissionsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Submissions Match Filters`
  String get noSubmissionsMatchFilters {
    return Intl.message(
      'No Submissions Match Filters',
      name: 'noSubmissionsMatchFilters',
      desc: '',
      args: [],
    );
  }

  /// `No Submissions Yet`
  String get noSubmissionsYet {
    return Intl.message(
      'No Submissions Yet',
      name: 'noSubmissionsYet',
      desc: '',
      args: [],
    );
  }

  /// `No submission was made before the deadline`
  String get noSubmissionWasMadeBeforeTheDeadline {
    return Intl.message(
      'No submission was made before the deadline',
      name: 'noSubmissionWasMadeBeforeTheDeadline',
      desc: '',
      args: [],
    );
  }

  /// `No system logs found`
  String get noSystemLogsFound {
    return Intl.message(
      'No system logs found',
      name: 'noSystemLogsFound',
      desc: '',
      args: [],
    );
  }

  /// `Not Accepted`
  String get notAccepted {
    return Intl.message(
      'Not Accepted',
      name: 'notAccepted',
      desc: '',
      args: [],
    );
  }

  /// `This is not allowed.`
  String get notAllowed {
    return Intl.message(
      'This is not allowed.',
      name: 'notAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Not Assigned`
  String get notAssigned {
    return Intl.message(
      'Not Assigned',
      name: 'notAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Not Available`
  String get notAvailable {
    return Intl.message(
      'Not Available',
      name: 'notAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Notes & Observations`
  String get notesObservations {
    return Intl.message(
      'Notes & Observations',
      name: 'notesObservations',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get notice {
    return Intl.message('Notice', name: 'notice', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Notification Control`
  String get notificationControl {
    return Intl.message(
      'Notification Control',
      name: 'notificationControl',
      desc: '',
      args: [],
    );
  }

  /// `Notification Module`
  String get notificationModule {
    return Intl.message(
      'Notification Module',
      name: 'notificationModule',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Notifications Type`
  String get notificationsType {
    return Intl.message(
      'Notifications Type',
      name: 'notificationsType',
      desc: '',
      args: [],
    );
  }

  /// `Notified Security Team`
  String get notifiedSecurityTeam {
    return Intl.message(
      'Notified Security Team',
      name: 'notifiedSecurityTeam',
      desc: '',
      args: [],
    );
  }

  /// `Notify Provider Manager`
  String get notifyProviderManager {
    return Intl.message(
      'Notify Provider Manager',
      name: 'notifyProviderManager',
      desc: '',
      args: [],
    );
  }

  /// `Notify Service Provider`
  String get notifyServiceProvider {
    return Intl.message(
      'Notify Service Provider',
      name: 'notifyServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Notify Service Requester`
  String get notifyServiceRequester {
    return Intl.message(
      'Notify Service Requester',
      name: 'notifyServiceRequester',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get noTitleButton {
    return Intl.message('No', name: 'noTitleButton', desc: '', args: []);
  }

  /// `No user permissions to export`
  String get noUserPermissionsToExport {
    return Intl.message(
      'No user permissions to export',
      name: 'noUserPermissionsToExport',
      desc: '',
      args: [],
    );
  }

  /// `Nov`
  String get nov {
    return Intl.message('Nov', name: 'nov', desc: '', args: []);
  }

  /// `No weight changes`
  String get noWeightChanges {
    return Intl.message(
      'No weight changes',
      name: 'noWeightChanges',
      desc: '',
      args: [],
    );
  }

  /// `No Wrong Data Found`
  String get noWrongDataFound {
    return Intl.message(
      'No Wrong Data Found',
      name: 'noWrongDataFound',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get num {
    return Intl.message('No', name: 'num', desc: '', args: []);
  }

  /// `NO`
  String get number {
    return Intl.message('NO', name: 'number', desc: '', args: []);
  }

  /// `Number`
  String get numberLabel {
    return Intl.message('Number', name: 'numberLabel', desc: '', args: []);
  }

  /// `Number of Downloads`
  String get numberOfDownloads {
    return Intl.message(
      'Number of Downloads',
      name: 'numberOfDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Number Of Product`
  String get numberOfProduct {
    return Intl.message(
      'Number Of Product',
      name: 'numberOfProduct',
      desc: '',
      args: [],
    );
  }

  /// `Number Of Services`
  String get numberOfServices {
    return Intl.message(
      'Number Of Services',
      name: 'numberOfServices',
      desc: '',
      args: [],
    );
  }

  /// `Number of Views`
  String get numberOfViews {
    return Intl.message(
      'Number of Views',
      name: 'numberOfViews',
      desc: '',
      args: [],
    );
  }

  /// `Numbers not allowed`
  String get numbersNotAllowed {
    return Intl.message(
      'Numbers not allowed',
      name: 'numbersNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Oct`
  String get oct {
    return Intl.message('Oct', name: 'oct', desc: '', args: []);
  }

  /// `Offered Date`
  String get OfferedDate {
    return Intl.message(
      'Offered Date',
      name: 'OfferedDate',
      desc: '',
      args: [],
    );
  }

  /// `Office`
  String get office {
    return Intl.message('Office', name: 'office', desc: '', args: []);
  }

  /// `Office - 1`
  String get office1 {
    return Intl.message('Office - 1', name: 'office1', desc: '', args: []);
  }

  /// `Office - 2`
  String get office2 {
    return Intl.message('Office - 2', name: 'office2', desc: '', args: []);
  }

  /// `Office Coordinates`
  String get officeCoordinates {
    return Intl.message(
      'Office Coordinates',
      name: 'officeCoordinates',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get ofLabel {
    return Intl.message('of', name: 'ofLabel', desc: '', args: []);
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `OK`
  String get ok2 {
    return Intl.message('OK', name: 'ok2', desc: '', args: []);
  }

  /// `Oldest First`
  String get oldestFirst {
    return Intl.message(
      'Oldest First',
      name: 'oldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Old password matches the saved password.`
  String get oldPasswordMatchesSavedPassword {
    return Intl.message(
      'Old password matches the saved password.',
      name: 'oldPasswordMatchesSavedPassword',
      desc: '',
      args: [],
    );
  }

  /// `Omani`
  String get omani {
    return Intl.message('Omani', name: 'omani', desc: '', args: []);
  }

  /// `Oncoming Time`
  String get oncomingTime {
    return Intl.message(
      'Oncoming Time',
      name: 'oncomingTime',
      desc: '',
      args: [],
    );
  }

  /// `On Hold`
  String get onHold {
    return Intl.message('On Hold', name: 'onHold', desc: '', args: []);
  }

  /// `Online Retail`
  String get onlineRetail {
    return Intl.message(
      'Online Retail',
      name: 'onlineRetail',
      desc: '',
      args: [],
    );
  }

  /// `Only Admins can share content`
  String get onlyAdminsCanShareContent {
    return Intl.message(
      'Only Admins can share content',
      name: 'onlyAdminsCanShareContent',
      desc: '',
      args: [],
    );
  }

  /// `Only digits are allowed. Please remove any letters or symbols.`
  String get onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols {
    return Intl.message(
      'Only digits are allowed. Please remove any letters or symbols.',
      name: 'onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols',
      desc: '',
      args: [],
    );
  }

  /// `Only digits are permitted in the extension field`
  String get onlyDigitsArePermittedInTheExtensionField {
    return Intl.message(
      'Only digits are permitted in the extension field',
      name: 'onlyDigitsArePermittedInTheExtensionField',
      desc: '',
      args: [],
    );
  }

  /// `Only numbers are allowed.`
  String get Onlynumbersareallowed {
    return Intl.message(
      'Only numbers are allowed.',
      name: 'Onlynumbersareallowed',
      desc: '',
      args: [],
    );
  }

  /// `On Site`
  String get onSite {
    return Intl.message('On Site', name: 'onSite', desc: '', args: []);
  }

  /// `On Time`
  String get onTime {
    return Intl.message('On Time', name: 'onTime', desc: '', args: []);
  }

  /// `Opacity`
  String get opacity {
    return Intl.message('Opacity', name: 'opacity', desc: '', args: []);
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `OpeningFile`
  String get openingFile {
    return Intl.message('OpeningFile', name: 'openingFile', desc: '', args: []);
  }

  /// `Operations`
  String get Operations {
    return Intl.message('Operations', name: 'Operations', desc: '', args: []);
  }

  /// `Operations`
  String get operations {
    return Intl.message('Operations', name: 'operations', desc: '', args: []);
  }

  /// `Operations Department`
  String get operationsDepartment {
    return Intl.message(
      'Operations Department',
      name: 'operationsDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Operations Manager`
  String get operationsManager {
    return Intl.message(
      'Operations Manager',
      name: 'operationsManager',
      desc: '',
      args: [],
    );
  }

  /// `Option`
  String get option {
    return Intl.message('Option', name: 'option', desc: '', args: []);
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
  }

  /// `Options must be unique`
  String get optionsMustBeUnique {
    return Intl.message(
      'Options must be unique',
      name: 'optionsMustBeUnique',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message('Or', name: 'or', desc: '', args: []);
  }

  /// `Orange`
  String get orange {
    return Intl.message('Orange', name: 'orange', desc: '', args: []);
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }

  /// `Order & Product Details`
  String get orderAndProductDetails {
    return Intl.message(
      'Order & Product Details',
      name: 'orderAndProductDetails',
      desc: '',
      args: [],
    );
  }

  /// `Order Created By`
  String get orderCreatedBy {
    return Intl.message(
      'Order Created By',
      name: 'orderCreatedBy',
      desc: '',
      args: [],
    );
  }

  /// `Order Date`
  String get orderDate {
    return Intl.message('Order Date', name: 'orderDate', desc: '', args: []);
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Order Fulfillment Status`
  String get orderFulfillmentStatus {
    return Intl.message(
      'Order Fulfillment Status',
      name: 'orderFulfillmentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Order ID`
  String get orderID {
    return Intl.message('Order ID', name: 'orderID', desc: '', args: []);
  }

  /// `Order Note`
  String get orderNote {
    return Intl.message('Order Note', name: 'orderNote', desc: '', args: []);
  }

  /// `Order Request`
  String get orderRequest {
    return Intl.message(
      'Order Request',
      name: 'orderRequest',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Orders History`
  String get ordersHistory {
    return Intl.message(
      'Orders History',
      name: 'ordersHistory',
      desc: '',
      args: [],
    );
  }

  /// `Order Status`
  String get orderStatus {
    return Intl.message(
      'Order Status',
      name: 'orderStatus',
      desc: '',
      args: [],
    );
  }

  /// `Order Type`
  String get orderType {
    return Intl.message('Order Type', name: 'orderType', desc: '', args: []);
  }

  /// `Order Value`
  String get orderValue {
    return Intl.message('Order Value', name: 'orderValue', desc: '', args: []);
  }

  /// `Organization Chart`
  String get organizationChart {
    return Intl.message(
      'Organization Chart',
      name: 'organizationChart',
      desc: '',
      args: [],
    );
  }

  /// `Org Chart`
  String get orgChart {
    return Intl.message('Org Chart', name: 'orgChart', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Outdoor Storage`
  String get outdoorStorage {
    return Intl.message(
      'Outdoor Storage',
      name: 'outdoorStorage',
      desc: '',
      args: [],
    );
  }

  /// `Outdoor Yard`
  String get outdoorYard {
    return Intl.message(
      'Outdoor Yard',
      name: 'outdoorYard',
      desc: '',
      args: [],
    );
  }

  /// `Out Of Stock`
  String get outOfStock {
    return Intl.message('Out Of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `Outstanding`
  String get outstanding {
    return Intl.message('Outstanding', name: 'outstanding', desc: '', args: []);
  }

  /// `Overall`
  String get overall {
    return Intl.message('Overall', name: 'overall', desc: '', args: []);
  }

  /// `Overdue`
  String get overdue {
    return Intl.message('Overdue', name: 'overdue', desc: '', args: []);
  }

  /// `Overdue Return`
  String get overdueReturn {
    return Intl.message(
      'Overdue Return',
      name: 'overdueReturn',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get owner {
    return Intl.message('Owner', name: 'owner', desc: '', args: []);
  }

  /// `OWNER`
  String get OWNER {
    return Intl.message('OWNER', name: 'OWNER', desc: '', args: []);
  }

  /// `Owning Department`
  String get owning_department {
    return Intl.message(
      'Owning Department',
      name: 'owning_department',
      desc: '',
      args: [],
    );
  }

  /// `Owning Department`
  String get OwningDepartment {
    return Intl.message(
      'Owning Department',
      name: 'OwningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Owning Department`
  String get owningDepartment {
    return Intl.message(
      'Owning Department',
      name: 'owningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Owning Status`
  String get owningStatus {
    return Intl.message(
      'Owning Status',
      name: 'owningStatus',
      desc: '',
      args: [],
    );
  }

  /// `Packaging / Unpacking Station`
  String get packagingUnpackingStation {
    return Intl.message(
      'Packaging / Unpacking Station',
      name: 'packagingUnpackingStation',
      desc: '',
      args: [],
    );
  }

  /// `Pages`
  String get pages {
    return Intl.message('Pages', name: 'pages', desc: '', args: []);
  }

  /// `Pakistani`
  String get pakistani {
    return Intl.message('Pakistani', name: 'pakistani', desc: '', args: []);
  }

  /// `Palauan`
  String get palauan {
    return Intl.message('Palauan', name: 'palauan', desc: '', args: []);
  }

  /// `Pallet Space`
  String get palletSpace {
    return Intl.message(
      'Pallet Space',
      name: 'palletSpace',
      desc: '',
      args: [],
    );
  }

  /// `Panamanian`
  String get panamanian {
    return Intl.message('Panamanian', name: 'panamanian', desc: '', args: []);
  }

  /// `Papua New Guinean`
  String get papuaNewGuinean {
    return Intl.message(
      'Papua New Guinean',
      name: 'papuaNewGuinean',
      desc: '',
      args: [],
    );
  }

  /// `Paraguayan`
  String get paraguayan {
    return Intl.message('Paraguayan', name: 'paraguayan', desc: '', args: []);
  }

  /// `Partially Received`
  String get partiallyReceived {
    return Intl.message(
      'Partially Received',
      name: 'partiallyReceived',
      desc: '',
      args: [],
    );
  }

  /// `Part-time`
  String get partTime {
    return Intl.message('Part-time', name: 'partTime', desc: '', args: []);
  }

  /// `Password and Expiration Time Updated Successfully`
  String get passwordAndExpirationTimeUpdatedSuccessfully {
    return Intl.message(
      'Password and Expiration Time Updated Successfully',
      name: 'passwordAndExpirationTimeUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters.`
  String get passwordMustBeAtLeast8Characters {
    return Intl.message(
      'Password must be at least 8 characters.',
      name: 'passwordMustBeAtLeast8Characters',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one number.`
  String get passwordMustContainNumber {
    return Intl.message(
      'Password must contain at least one number.',
      name: 'passwordMustContainNumber',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one symbol.`
  String get passwordMustContainSymbol {
    return Intl.message(
      'Password must contain at least one symbol.',
      name: 'passwordMustContainSymbol',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one uppercase letter.`
  String get passwordMustContainUppercase {
    return Intl.message(
      'Password must contain at least one uppercase letter.',
      name: 'passwordMustContainUppercase',
      desc: '',
      args: [],
    );
  }

  /// `A password reset link has been sent to your email`
  String get passwordResetLinkSent {
    return Intl.message(
      'A password reset link has been sent to your email',
      name: 'passwordResetLinkSent',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been reset successfully. Please log in again with your new credentials.`
  String get passwordResetSuccessMessage {
    return Intl.message(
      'Your password has been reset successfully. Please log in again with your new credentials.',
      name: 'passwordResetSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Paternity Leave`
  String get paternityLeave {
    return Intl.message(
      'Paternity Leave',
      name: 'paternityLeave',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type`
  String get paymentType {
    return Intl.message(
      'Payment Type',
      name: 'paymentType',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get Pending {
    return Intl.message('Pending', name: 'Pending', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Pending Projects`
  String get pendingProjects {
    return Intl.message(
      'Pending Projects',
      name: 'pendingProjects',
      desc: '',
      args: [],
    );
  }

  /// `Pending Submissions`
  String get pendingSubmissions {
    return Intl.message(
      'Pending Submissions',
      name: 'pendingSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get performance {
    return Intl.message('Performance', name: 'performance', desc: '', args: []);
  }

  /// `Permission`
  String get permission {
    return Intl.message('Permission', name: 'permission', desc: '', args: []);
  }

  /// `Permission Controls`
  String get permissionControls {
    return Intl.message(
      'Permission Controls',
      name: 'permissionControls',
      desc: '',
      args: [],
    );
  }

  /// `Permissions`
  String get permissions {
    return Intl.message('Permissions', name: 'permissions', desc: '', args: []);
  }

  /// `Personal Branding`
  String get personalBranding {
    return Intl.message(
      'Personal Branding',
      name: 'personalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Personal Data`
  String get personalData {
    return Intl.message(
      'Personal Data',
      name: 'personalData',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Personalized To-Do Lists`
  String get personalizedToDoLists {
    return Intl.message(
      'Personalized To-Do Lists',
      name: 'personalizedToDoLists',
      desc: '',
      args: [],
    );
  }

  /// `Our to-do list feature helps you manage your workload efficiently, ensuring you never miss a task. Keep your day structured and focused with intuitive tools designed for your convenience.`
  String get personalizedToDoListsBody {
    return Intl.message(
      'Our to-do list feature helps you manage your workload efficiently, ensuring you never miss a task. Keep your day structured and focused with intuitive tools designed for your convenience.',
      name: 'personalizedToDoListsBody',
      desc: '',
      args: [],
    );
  }

  /// `Personal Leave`
  String get personalLeave {
    return Intl.message(
      'Personal Leave',
      name: 'personalLeave',
      desc: '',
      args: [],
    );
  }

  /// `Personal Logo`
  String get personalLogo {
    return Intl.message(
      'Personal Logo',
      name: 'personalLogo',
      desc: '',
      args: [],
    );
  }

  /// `Peruvian`
  String get peruvian {
    return Intl.message('Peruvian', name: 'peruvian', desc: '', args: []);
  }

  /// `Pest Control`
  String get pestControl {
    return Intl.message(
      'Pest Control',
      name: 'pestControl',
      desc: '',
      args: [],
    );
  }

  /// `PhD`
  String get phdDegree {
    return Intl.message('PhD', name: 'phdDegree', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number is required`
  String get phoneNumberRequired {
    return Intl.message(
      'Phone Number is required',
      name: 'phoneNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone Required`
  String get phoneRequired {
    return Intl.message(
      'Phone Required',
      name: 'phoneRequired',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message('Photo', name: 'photo', desc: '', args: []);
  }

  /// `Pick a location`
  String get pickALocation {
    return Intl.message(
      'Pick a location',
      name: 'pickALocation',
      desc: '',
      args: [],
    );
  }

  /// `Pick Up`
  String get pickup {
    return Intl.message('Pick Up', name: 'pickup', desc: '', args: []);
  }

  /// `Pick Up Date`
  String get pickUpDate {
    return Intl.message('Pick Up Date', name: 'pickUpDate', desc: '', args: []);
  }

  /// `Pin`
  String get pin {
    return Intl.message('Pin', name: 'pin', desc: '', args: []);
  }

  /// `Pinned`
  String get pinned {
    return Intl.message('Pinned', name: 'pinned', desc: '', args: []);
  }

  /// `Pin Notification`
  String get pinNotification {
    return Intl.message(
      'Pin Notification',
      name: 'pinNotification',
      desc: '',
      args: [],
    );
  }

  /// `Platform Controls and Management`
  String get platformControlsAndManagement {
    return Intl.message(
      'Platform Controls and Management',
      name: 'platformControlsAndManagement',
      desc: '',
      args: [],
    );
  }

  /// `Platform Roles`
  String get platformRoles {
    return Intl.message(
      'Platform Roles',
      name: 'platformRoles',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a file name`
  String get pleaseEnterFileName {
    return Intl.message(
      'Please enter a file name',
      name: 'pleaseEnterFileName',
      desc: '',
      args: [],
    );
  }

  /// `Please select a document type`
  String get please_select_doc_type {
    return Intl.message(
      'Please select a document type',
      name: 'please_select_doc_type',
      desc: '',
      args: [],
    );
  }

  /// `Please add a question`
  String get pleaseAddAQuestion {
    return Intl.message(
      'Please add a question',
      name: 'pleaseAddAQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Please assign at least one control`
  String get pleaseAssignAtLeastOneControl {
    return Intl.message(
      'Please assign at least one control',
      name: 'pleaseAssignAtLeastOneControl',
      desc: '',
      args: [],
    );
  }

  /// `Please attach a document`
  String get pleaseAttachDocument {
    return Intl.message(
      'Please attach a document',
      name: 'pleaseAttachDocument',
      desc: '',
      args: [],
    );
  }

  /// `Please Check Your Internet Connection`
  String get pleaseCheckYourInternetConnection {
    return Intl.message(
      'Please Check Your Internet Connection',
      name: 'pleaseCheckYourInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please choose a start date`
  String get pleaseChooseAStartDate {
    return Intl.message(
      'Please choose a start date',
      name: 'pleaseChooseAStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Please drop an Excel file (.xlsx or .xls)`
  String get pleaseDropAnExcelFileXlsxOrXls {
    return Intl.message(
      'Please drop an Excel file (.xlsx or .xls)',
      name: 'pleaseDropAnExcelFileXlsxOrXls',
      desc: '',
      args: [],
    );
  }

  /// `Please enable location services!`
  String get pleaseEnableLocationServices {
    return Intl.message(
      'Please enable location services!',
      name: 'pleaseEnableLocationServices',
      desc: '',
      args: [],
    );
  }

  /// `Please enable microphone service!`
  String get pleaseEnableMicrophoneService {
    return Intl.message(
      'Please enable microphone service!',
      name: 'pleaseEnableMicrophoneService',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a file name`
  String get pleaseEnterAFileName {
    return Intl.message(
      'Please enter a file name',
      name: 'pleaseEnterAFileName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter approval justification`
  String get pleaseEnterApprovalJustification {
    return Intl.message(
      'Please enter approval justification',
      name: 'pleaseEnterApprovalJustification',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid date in DD/MM/YYYY format.`
  String get pleaseEnterAValidDateInDDMMYYYYFormat {
    return Intl.message(
      'Please enter a valid date in DD/MM/YYYY format.',
      name: 'pleaseEnterAValidDateInDDMMYYYYFormat',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid date of birth. Future dates are not allowed`
  String get pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed {
    return Intl.message(
      'Please enter a valid date of birth. Future dates are not allowed',
      name: 'pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address for communication`
  String get pleaseEnterAValidEmailAddressForCommunication {
    return Intl.message(
      'Please enter a valid email address for communication',
      name: 'pleaseEnterAValidEmailAddressForCommunication',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid link`
  String get pleaseEnterAValidLink {
    return Intl.message(
      'Please enter a valid link',
      name: 'pleaseEnterAValidLink',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number in the format +[Country Code][Number]`
  String get pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe {
    return Intl.message(
      'Please enter a valid phone number in the format +[Country Code][Number]',
      name: 'pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe',
      desc: '',
      args: [],
    );
  }

  /// `Please enter both email and password to sign in`
  String get pleaseEnterBothEmailAndPasswordToSignIn {
    return Intl.message(
      'Please enter both email and password to sign in',
      name: 'pleaseEnterBothEmailAndPasswordToSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a cancellation reason`
  String get pleaseEnterCancelReason {
    return Intl.message(
      'Please enter a cancellation reason',
      name: 'pleaseEnterCancelReason',
      desc: '',
      args: [],
    );
  }

  /// `Please enter default password`
  String get pleaseEnterDefaultPassword {
    return Intl.message(
      'Please enter default password',
      name: 'pleaseEnterDefaultPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter expiration time`
  String get pleaseEnterExpirationTime {
    return Intl.message(
      'Please enter expiration time',
      name: 'pleaseEnterExpirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Please enter justification`
  String get pleaseEnterJustification {
    return Intl.message(
      'Please enter justification',
      name: 'pleaseEnterJustification',
      desc: '',
      args: [],
    );
  }

  /// `Please enter numbers only more then 0`
  String get pleaseEnterNumbersOnlyMoreThen0 {
    return Intl.message(
      'Please enter numbers only more then 0',
      name: 'pleaseEnterNumbersOnlyMoreThen0',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a rejection reason`
  String get pleaseEnterRejectionReason {
    return Intl.message(
      'Please enter a rejection reason',
      name: 'pleaseEnterRejectionReason',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the employee's job title. It is essential for internal designation`
  String get pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal {
    return Intl.message(
      'Please enter the employee\'s job title. It is essential for internal designation',
      name: 'pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the first name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL {
    return Intl.message(
      'Please enter the first name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the last name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo {
    return Intl.message(
      'Please enter the last name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the middle name in Arabic. This is a required field for localization purposes.`
  String get pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor {
    return Intl.message(
      'Please enter the middle name in Arabic. This is a required field for localization purposes.',
      name: 'pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the office extension number`
  String get pleaseEnterTheOfficeExtensionNumber {
    return Intl.message(
      'Please enter the office extension number',
      name: 'pleaseEnterTheOfficeExtensionNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The Text In Arabic Language`
  String get pleaseEnterTheTextInArabicLanguage {
    return Intl.message(
      'Please Enter The Text In Arabic Language',
      name: 'pleaseEnterTheTextInArabicLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The Text In English Language`
  String get pleaseEnterTheTextInEnglishLanguage {
    return Intl.message(
      'Please Enter The Text In English Language',
      name: 'pleaseEnterTheTextInEnglishLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The valid Email`
  String get pleaseEnterTheValidEmail {
    return Intl.message(
      'Please Enter The valid Email',
      name: 'pleaseEnterTheValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter The valid Phone Number`
  String get pleaseEnterTheValidPhoneNumber {
    return Intl.message(
      'Please Enter The valid Phone Number',
      name: 'pleaseEnterTheValidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all required fields correctly`
  String get pleaseFillAllRequiredFieldsCorrectly {
    return Intl.message(
      'Please fill all required fields correctly',
      name: 'pleaseFillAllRequiredFieldsCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillInAllRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillInAllRequiredFields',
      desc: '',
      args: [],
    );
  }

  /// `Please fix the highlighted errors before continuing`
  String get pleaseFixTheHighlightedErrorsBeforeContinuing {
    return Intl.message(
      'Please fix the highlighted errors before continuing',
      name: 'pleaseFixTheHighlightedErrorsBeforeContinuing',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid department ID. This field is mandatory for organizational structure.`
  String get pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO {
    return Intl.message(
      'Please provide a valid department ID. This field is mandatory for organizational structure.',
      name: 'pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a valid postal code. It must match the city and province.`
  String get pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi {
    return Intl.message(
      'Please provide a valid postal code. It must match the city and province.',
      name: 'pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a justification for approving this document`
  String get pleaseProvideJustificationForApproval {
    return Intl.message(
      'Please provide a justification for approving this document',
      name: 'pleaseProvideJustificationForApproval',
      desc: '',
      args: [],
    );
  }

  /// `Please provide a detailed reason for rejecting this document`
  String get pleaseProvideReasonForRejection {
    return Intl.message(
      'Please provide a detailed reason for rejecting this document',
      name: 'pleaseProvideReasonForRejection',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the department name in Arabic for bilingual consistency.`
  String get pleaseProvideTheDepartmentNameInArabicForBilingualConsi {
    return Intl.message(
      'Please provide the department name in Arabic for bilingual consistency.',
      name: 'pleaseProvideTheDepartmentNameInArabicForBilingualConsi',
      desc: '',
      args: [],
    );
  }

  /// `Please select access granted date`
  String get pleaseSelectAccessGrantedDate {
    return Intl.message(
      'Please select access granted date',
      name: 'pleaseSelectAccessGrantedDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select access revoked date`
  String get pleaseSelectAccessRevokedDate {
    return Intl.message(
      'Please select access revoked date',
      name: 'pleaseSelectAccessRevokedDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a control champion`
  String get pleaseSelectAControlChampion {
    return Intl.message(
      'Please select a control champion',
      name: 'pleaseSelectAControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Please select a control owner`
  String get pleaseSelectAControlOwner {
    return Intl.message(
      'Please select a control owner',
      name: 'pleaseSelectAControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Please select a date`
  String get pleaseSelectADate {
    return Intl.message(
      'Please select a date',
      name: 'pleaseSelectADate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a date later than today for the National ID expiration.`
  String get pleaseSelectADateLaterThanTodayForTheNationalIDExpirati {
    return Intl.message(
      'Please select a date later than today for the National ID expiration.',
      name: 'pleaseSelectADateLaterThanTodayForTheNationalIDExpirati',
      desc: '',
      args: [],
    );
  }

  /// `Please select a duration unit for reminder`
  String get pleaseselectadurationunitforreminder {
    return Intl.message(
      'Please select a duration unit for reminder',
      name: 'pleaseselectadurationunitforreminder',
      desc: '',
      args: [],
    );
  }

  /// `Please select a frequency unit`
  String get pleaseselectafrequencyunit {
    return Intl.message(
      'Please select a frequency unit',
      name: 'pleaseselectafrequencyunit',
      desc: '',
      args: [],
    );
  }

  /// `Please select an employee`
  String get pleaseSelectAnEmployee {
    return Intl.message(
      'Please select an employee',
      name: 'pleaseSelectAnEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Please select a new control champion`
  String get pleaseSelectANewControlChampion {
    return Intl.message(
      'Please select a new control champion',
      name: 'pleaseSelectANewControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Please select a new control owner`
  String get pleaseSelectANewControlOwner {
    return Intl.message(
      'Please select a new control owner',
      name: 'pleaseSelectANewControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Please select a priority`
  String get pleaseselectapriority {
    return Intl.message(
      'Please select a priority',
      name: 'pleaseselectapriority',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role type`
  String get pleaseSelectARoleType {
    return Intl.message(
      'Please select a role type',
      name: 'pleaseSelectARoleType',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one day`
  String get pleaseselectatleastoneday {
    return Intl.message(
      'Please select at least one day',
      name: 'pleaseselectatleastoneday',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one department`
  String get pleaseSelectAtLeastOneDepartment {
    return Intl.message(
      'Please select at least one department',
      name: 'pleaseSelectAtLeastOneDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one employee.`
  String get Pleaseselectatleastoneemployee {
    return Intl.message(
      'Please select at least one employee.',
      name: 'Pleaseselectatleastoneemployee',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one row to remove.`
  String get pleaseSelectAtLeastOneRowToRemove {
    return Intl.message(
      'Please select at least one row to remove.',
      name: 'pleaseSelectAtLeastOneRowToRemove',
      desc: '',
      args: [],
    );
  }

  /// `Please select both start date and start time`
  String get pleaseselectbothstartdateandstarttime {
    return Intl.message(
      'Please select both start date and start time',
      name: 'pleaseselectbothstartdateandstarttime',
      desc: '',
      args: [],
    );
  }

  /// `Please select a document type`
  String get pleaseSelectDocumentType {
    return Intl.message(
      'Please select a document type',
      name: 'pleaseSelectDocumentType',
      desc: '',
      args: [],
    );
  }

  /// `Please select end date`
  String get pleaseSelectEndDate {
    return Intl.message(
      'Please select end date',
      name: 'pleaseSelectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select exactly one row to duplicate.`
  String get pleaseSelectExactlyOneRowToDuplicate {
    return Intl.message(
      'Please select exactly one row to duplicate.',
      name: 'pleaseSelectExactlyOneRowToDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Image In SVG Format`
  String get pleaseSelectImageInSvgFormat {
    return Intl.message(
      'Please Select Image In SVG Format',
      name: 'pleaseSelectImageInSvgFormat',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one provider`
  String get pleaseSelectOneProviderAtLeast {
    return Intl.message(
      'Please select at least one provider',
      name: 'pleaseSelectOneProviderAtLeast',
      desc: '',
      args: [],
    );
  }

  /// `Please select start date`
  String get pleaseSelectStartDate {
    return Intl.message(
      'Please select start date',
      name: 'pleaseSelectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select start date before selecting end date or end time`
  String get pleaseselectstartdatebeforeenddate {
    return Intl.message(
      'Please select start date before selecting end date or end time',
      name: 'pleaseselectstartdatebeforeenddate',
      desc: '',
      args: [],
    );
  }

  /// `! .Please verify the entry`
  String get pleaseVerifyTheEntry {
    return Intl.message(
      '! .Please verify the entry',
      name: 'pleaseVerifyTheEntry',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we save your data`
  String get pleaseWait {
    return Intl.message(
      'Please wait while we save your data',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we save your draft`
  String get pleaseWaitSaving {
    return Intl.message(
      'Please wait while we save your draft',
      name: 'pleaseWaitSaving',
      desc: '',
      args: [],
    );
  }

  /// `PM`
  String get pm {
    return Intl.message('PM', name: 'pm', desc: '', args: []);
  }

  /// `Point of Contact`
  String get PointofContact {
    return Intl.message(
      'Point of Contact',
      name: 'PointofContact',
      desc: '',
      args: [],
    );
  }

  /// `Point Of Contact Details`
  String get pointOfContactDetails {
    return Intl.message(
      'Point Of Contact Details',
      name: 'pointOfContactDetails',
      desc: '',
      args: [],
    );
  }

  /// `Policies`
  String get policies {
    return Intl.message('Policies', name: 'policies', desc: '', args: []);
  }

  /// `Policy`
  String get policy {
    return Intl.message('Policy', name: 'policy', desc: '', args: []);
  }

  /// `Policy Bulk Upload`
  String get policyBulkUpload {
    return Intl.message(
      'Policy Bulk Upload',
      name: 'policyBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Policy Bulk Upload Preview`
  String get policyBulkUploadPreview {
    return Intl.message(
      'Policy Bulk Upload Preview',
      name: 'policyBulkUploadPreview',
      desc: '',
      args: [],
    );
  }

  /// `Policy Compliance`
  String get policyCompliance {
    return Intl.message(
      'Policy Compliance',
      name: 'policyCompliance',
      desc: '',
      args: [],
    );
  }

  /// `Policy Created`
  String get policyCreated {
    return Intl.message(
      'Policy Created',
      name: 'policyCreated',
      desc: '',
      args: [],
    );
  }

  /// `Policy Deleted`
  String get policyDeleted {
    return Intl.message(
      'Policy Deleted',
      name: 'policyDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Policy Description`
  String get policyDescription {
    return Intl.message(
      'Policy Description',
      name: 'policyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Policy description must be written in English`
  String get policyDescriptionMustBeWrittenInEnglish {
    return Intl.message(
      'Policy description must be written in English',
      name: 'policyDescriptionMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Policy Details`
  String get policyDetails {
    return Intl.message(
      'Policy Details',
      name: 'policyDetails',
      desc: '',
      args: [],
    );
  }

  /// `Policy Document`
  String get policyDocument {
    return Intl.message(
      'Policy Document',
      name: 'policyDocument',
      desc: '',
      args: [],
    );
  }

  /// `Policy Document (Arabic)`
  String get policyDocumentAr {
    return Intl.message(
      'Policy Document (Arabic)',
      name: 'policyDocumentAr',
      desc: '',
      args: [],
    );
  }

  /// `Policy Document (English)`
  String get policyDocumentEng {
    return Intl.message(
      'Policy Document (English)',
      name: 'policyDocumentEng',
      desc: '',
      args: [],
    );
  }

  /// `Policy(ies) Created`
  String get policYIesCreated {
    return Intl.message(
      'Policy(ies) Created',
      name: 'policYIesCreated',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name`
  String get policyName {
    return Intl.message('Policy Name', name: 'policyName', desc: '', args: []);
  }

  /// `Policy Name 1`
  String get policyName1 {
    return Intl.message(
      'Policy Name 1',
      name: 'policyName1',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 2`
  String get policyName2 {
    return Intl.message(
      'Policy Name 2',
      name: 'policyName2',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 3`
  String get policyName3 {
    return Intl.message(
      'Policy Name 3',
      name: 'policyName3',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 4`
  String get policyName4 {
    return Intl.message(
      'Policy Name 4',
      name: 'policyName4',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 5`
  String get policyName5 {
    return Intl.message(
      'Policy Name 5',
      name: 'policyName5',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name 6`
  String get policyName6 {
    return Intl.message(
      'Policy Name 6',
      name: 'policyName6',
      desc: '',
      args: [],
    );
  }

  /// `Policy Name cannot be empty`
  String get policyNameCannotBeEmpty {
    return Intl.message(
      'Policy Name cannot be empty',
      name: 'policyNameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Policy Number`
  String get policyNumber {
    return Intl.message(
      'Policy Number',
      name: 'policyNumber',
      desc: '',
      args: [],
    );
  }

  /// `Policy Number Ar`
  String get policyNumberAr {
    return Intl.message(
      'Policy Number Ar',
      name: 'policyNumberAr',
      desc: '',
      args: [],
    );
  }

  /// `Policy number must be written in English`
  String get policyNumberMustBeWrittenInEnglish {
    return Intl.message(
      'Policy number must be written in English',
      name: 'policyNumberMustBeWrittenInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Policy saved as draft successfully`
  String get policySavedAsDraftSuccessfully {
    return Intl.message(
      'Policy saved as draft successfully',
      name: 'policySavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Policy saved, but one or more controls failed to save`
  String get policySavedButOneOrMoreControlsFailedToSave {
    return Intl.message(
      'Policy saved, but one or more controls failed to save',
      name: 'policySavedButOneOrMoreControlsFailedToSave',
      desc: '',
      args: [],
    );
  }

  /// `Policy Updated`
  String get policyUpdated {
    return Intl.message(
      'Policy Updated',
      name: 'policyUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight`
  String get policyWeight {
    return Intl.message(
      'Policy Weight',
      name: 'policyWeight',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight cannot be more than 100`
  String get policyWeightCannotBeMoreThan100 {
    return Intl.message(
      'Policy weight cannot be more than 100',
      name: 'policyWeightCannotBeMoreThan100',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Current`
  String get policyWeightCurrent {
    return Intl.message(
      'Policy Weight Current',
      name: 'policyWeightCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Issue`
  String get policyWeightIssue {
    return Intl.message(
      'Policy Weight Issue',
      name: 'policyWeightIssue',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight must be a positive number`
  String get policyWeightMustBeAPositiveNumber {
    return Intl.message(
      'Policy weight must be a positive number',
      name: 'policyWeightMustBeAPositiveNumber',
      desc: '',
      args: [],
    );
  }

  /// `Policy weight must be a valid number`
  String get policyWeightMustBeAValidNumber {
    return Intl.message(
      'Policy weight must be a valid number',
      name: 'policyWeightMustBeAValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Policy Weight Previous`
  String get policyWeightPrevious {
    return Intl.message(
      'Policy Weight Previous',
      name: 'policyWeightPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Polish`
  String get polish {
    return Intl.message('Polish', name: 'polish', desc: '', args: []);
  }

  /// `Poll`
  String get poll {
    return Intl.message('Poll', name: 'poll', desc: '', args: []);
  }

  /// `Poll Details`
  String get pollDetails {
    return Intl.message(
      'Poll Details',
      name: 'pollDetails',
      desc: '',
      args: [],
    );
  }

  /// `Portuguese`
  String get portuguese {
    return Intl.message('Portuguese', name: 'portuguese', desc: '', args: []);
  }

  /// `Please enter a positive quantity for the default storage location.`
  String get positiveQuantityDefaultLocation {
    return Intl.message(
      'Please enter a positive quantity for the default storage location.',
      name: 'positiveQuantityDefaultLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a positive quantity for location.`
  String get positiveQuantityLocation {
    return Intl.message(
      'Please enter a positive quantity for location.',
      name: 'positiveQuantityLocation',
      desc: '',
      args: [],
    );
  }

  /// `Position Details`
  String get positionDetails {
    return Intl.message(
      'Position Details',
      name: 'positionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Postal Code`
  String get postalCode {
    return Intl.message('Postal Code', name: 'postalCode', desc: '', args: []);
  }

  /// `Postal Code is required`
  String get postalCodeRequired {
    return Intl.message(
      'Postal Code is required',
      name: 'postalCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Preferred Language`
  String get preferredLanguage {
    return Intl.message(
      'Preferred Language',
      name: 'preferredLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Preferred language is required.`
  String get preferredLanguageRequired {
    return Intl.message(
      'Preferred language is required.',
      name: 'preferredLanguageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Preparing data...`
  String get preparingData {
    return Intl.message(
      'Preparing data...',
      name: 'preparingData',
      desc: '',
      args: [],
    );
  }

  /// `Preparing data structure...`
  String get preparingDataStructure {
    return Intl.message(
      'Preparing data structure...',
      name: 'preparingDataStructure',
      desc: '',
      args: [],
    );
  }

  /// `Present`
  String get present {
    return Intl.message('Present', name: 'present', desc: '', args: []);
  }

  /// `Presentation`
  String get presentation {
    return Intl.message(
      'Presentation',
      name: 'presentation',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Preview Health Insurance`
  String get previewHealthInsuranceChanges {
    return Intl.message(
      'Preview Health Insurance',
      name: 'previewHealthInsuranceChanges',
      desc: '',
      args: [],
    );
  }

  /// `Previewing Policy & Controls`
  String get previewingPolicyAndControls {
    return Intl.message(
      'Previewing Policy & Controls',
      name: 'previewingPolicyAndControls',
      desc: '',
      args: [],
    );
  }

  /// `Previous Control Owners`
  String get previousControlOwners {
    return Intl.message(
      'Previous Control Owners',
      name: 'previousControlOwners',
      desc: '',
      args: [],
    );
  }

  /// `Previous Module Owners`
  String get previousModuleOwners {
    return Intl.message(
      'Previous Module Owners',
      name: 'previousModuleOwners',
      desc: '',
      args: [],
    );
  }

  /// `Previous Owner`
  String get previousOwner {
    return Intl.message(
      'Previous Owner',
      name: 'previousOwner',
      desc: '',
      args: [],
    );
  }

  /// `Primary Color`
  String get primaryColor {
    return Intl.message(
      'Primary Color',
      name: 'primaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message('Priority', name: 'priority', desc: '', args: []);
  }

  /// `High`
  String get priorityHigh {
    return Intl.message('High', name: 'priorityHigh', desc: '', args: []);
  }

  /// `Low`
  String get priorityLow {
    return Intl.message('Low', name: 'priorityLow', desc: '', args: []);
  }

  /// `Medium`
  String get priorityMedium {
    return Intl.message('Medium', name: 'priorityMedium', desc: '', args: []);
  }

  /// `Urgent`
  String get priorityUrgent {
    return Intl.message('Urgent', name: 'priorityUrgent', desc: '', args: []);
  }

  /// `Privacy Statement`
  String get privacyStatement {
    return Intl.message(
      'Privacy Statement',
      name: 'privacyStatement',
      desc: '',
      args: [],
    );
  }

  /// `Proceed`
  String get proceed {
    return Intl.message('Proceed', name: 'proceed', desc: '', args: []);
  }

  /// `Processing your data, please wait`
  String get processingData {
    return Intl.message(
      'Processing your data, please wait',
      name: 'processingData',
      desc: '',
      args: [],
    );
  }

  /// `Processing file...`
  String get processingFile {
    return Intl.message(
      'Processing file...',
      name: 'processingFile',
      desc: '',
      args: [],
    );
  }

  /// `Processing request...`
  String get processingRequest {
    return Intl.message(
      'Processing request...',
      name: 'processingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Process Payroll`
  String get processPayroll {
    return Intl.message(
      'Process Payroll',
      name: 'processPayroll',
      desc: '',
      args: [],
    );
  }

  /// `product Name`
  String get product {
    return Intl.message('product Name', name: 'product', desc: '', args: []);
  }

  /// `Product Added`
  String get productAdded {
    return Intl.message(
      'Product Added',
      name: 'productAdded',
      desc: '',
      args: [],
    );
  }

  /// `Product Consumption`
  String get productConsumption {
    return Intl.message(
      'Product Consumption',
      name: 'productConsumption',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `The product has been updated successfully`
  String get productHasBeenUpdatedSuccessfully {
    return Intl.message(
      'The product has been updated successfully',
      name: 'productHasBeenUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product ID`
  String get productID {
    return Intl.message('Product ID', name: 'productID', desc: '', args: []);
  }

  /// `Product`
  String get productN {
    return Intl.message('Product', name: 'productN', desc: '', args: []);
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Product Requests`
  String get productRequests {
    return Intl.message(
      'Product Requests',
      name: 'productRequests',
      desc: '',
      args: [],
    );
  }

  /// `Products Discrepancy`
  String get productsDiscrepancy {
    return Intl.message(
      'Products Discrepancy',
      name: 'productsDiscrepancy',
      desc: '',
      args: [],
    );
  }

  /// `Product Specification`
  String get productSpecification {
    return Intl.message(
      'Product Specification',
      name: 'productSpecification',
      desc: '',
      args: [],
    );
  }

  /// `Product Type`
  String get productType {
    return Intl.message(
      'Product Type',
      name: 'productType',
      desc: '',
      args: [],
    );
  }

  /// `Product Updated Successfully`
  String get productUpdatedSuccessfully {
    return Intl.message(
      'Product Updated Successfully',
      name: 'productUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product Warranty`
  String get productWarranty {
    return Intl.message(
      'Product Warranty',
      name: 'productWarranty',
      desc: '',
      args: [],
    );
  }

  /// `Project Performance`
  String get projectPerformance {
    return Intl.message(
      'Project Performance',
      name: 'projectPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Province`
  String get province {
    return Intl.message('Province', name: 'province', desc: '', args: []);
  }

  /// `Public Access`
  String get publicAccess {
    return Intl.message(
      'Public Access',
      name: 'publicAccess',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get publish {
    return Intl.message('Publish', name: 'publish', desc: '', args: []);
  }

  /// `Publish Date`
  String get publish_date {
    return Intl.message(
      'Publish Date',
      name: 'publish_date',
      desc: '',
      args: [],
    );
  }

  /// `Publish Date: `
  String get publishDate {
    return Intl.message(
      'Publish Date: ',
      name: 'publishDate',
      desc: '',
      args: [],
    );
  }

  /// `Published`
  String get published {
    return Intl.message('Published', name: 'published', desc: '', args: []);
  }

  /// `Published Date`
  String get published_date {
    return Intl.message(
      'Published Date',
      name: 'published_date',
      desc: '',
      args: [],
    );
  }

  /// `Published By`
  String get publishedBy {
    return Intl.message(
      'Published By',
      name: 'publishedBy',
      desc: '',
      args: [],
    );
  }

  /// `Publishing Date: `
  String get publishingDate {
    return Intl.message(
      'Publishing Date: ',
      name: 'publishingDate',
      desc: '',
      args: [],
    );
  }

  /// `Publish Policy`
  String get publishPolicy {
    return Intl.message(
      'Publish Policy',
      name: 'publishPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Order`
  String get purchaseOrder {
    return Intl.message(
      'Purchase Order',
      name: 'purchaseOrder',
      desc: '',
      args: [],
    );
  }

  /// `Purpose Of Use`
  String get purposeOfUse {
    return Intl.message(
      'Purpose Of Use',
      name: 'purposeOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Push Notification`
  String get pushNotification {
    return Intl.message(
      'Push Notification',
      name: 'pushNotification',
      desc: '',
      args: [],
    );
  }

  /// `px`
  String get px {
    return Intl.message('px', name: 'px', desc: '', args: []);
  }

  /// `Qatari`
  String get qatari {
    return Intl.message('Qatari', name: 'qatari', desc: '', args: []);
  }

  /// `Qiyas`
  String get qiyas {
    return Intl.message('Qiyas', name: 'qiyas', desc: '', args: []);
  }

  /// `Qiyas 1`
  String get qiyas1 {
    return Intl.message('Qiyas 1', name: 'qiyas1', desc: '', args: []);
  }

  /// `Qiyas 2`
  String get qiyas2 {
    return Intl.message('Qiyas 2', name: 'qiyas2', desc: '', args: []);
  }

  /// `Qiyas Dashboard`
  String get qiyasDashboard {
    return Intl.message(
      'Qiyas Dashboard',
      name: 'qiyasDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Quality Assurance`
  String get qualityAssurance {
    return Intl.message(
      'Quality Assurance',
      name: 'qualityAssurance',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Quantity Assigned`
  String get quantityAssigned {
    return Intl.message(
      'Quantity Assigned',
      name: 'quantityAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Quantity (Density)`
  String get quantityDensity {
    return Intl.message(
      'Quantity (Density)',
      name: 'quantityDensity',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get quarterly {
    return Intl.message('Quarterly', name: 'quarterly', desc: '', args: []);
  }

  /// `Question`
  String get question {
    return Intl.message('Question', name: 'question', desc: '', args: []);
  }

  /// `Quick Actions`
  String get quickActions {
    return Intl.message(
      'Quick Actions',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `Radiation-Protected Storage`
  String get radiationProtectedStorage {
    return Intl.message(
      'Radiation-Protected Storage',
      name: 'radiationProtectedStorage',
      desc: '',
      args: [],
    );
  }

  /// `Rather Not Say`
  String get ratherNotSay {
    return Intl.message(
      'Rather Not Say',
      name: 'ratherNotSay',
      desc: '',
      args: [],
    );
  }

  /// `Reactions`
  String get reactions {
    return Intl.message('Reactions', name: 'reactions', desc: '', args: []);
  }

  /// `Reactive User`
  String get reactiveUser {
    return Intl.message(
      'Reactive User',
      name: 'reactiveUser',
      desc: '',
      args: [],
    );
  }

  /// `Real-Time Team Chat`
  String get realTimeTeamChat {
    return Intl.message(
      'Real-Time Team Chat',
      name: 'realTimeTeamChat',
      desc: '',
      args: [],
    );
  }

  /// `Streamline communication with direct messaging and group chats, ensuring everyone stays informed and engaged. Our chat functionality fosters quick decision-making and improves overall team productivity.`
  String get realTimeTeamChatBody {
    return Intl.message(
      'Streamline communication with direct messaging and group chats, ensuring everyone stays informed and engaged. Our chat functionality fosters quick decision-making and improves overall team productivity.',
      name: 'realTimeTeamChatBody',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get reason {
    return Intl.message('Reason', name: 'reason', desc: '', args: []);
  }

  /// `Reason for Rejection`
  String get reasonForRejection {
    return Intl.message(
      'Reason for Rejection',
      name: 'reasonForRejection',
      desc: '',
      args: [],
    );
  }

  /// `Reason for Request`
  String get reasonForRequest {
    return Intl.message(
      'Reason for Request',
      name: 'reasonForRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reason must be at least 10 characters`
  String get reasonMustBeAtLeast10Characters {
    return Intl.message(
      'Reason must be at least 10 characters',
      name: 'reasonMustBeAtLeast10Characters',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get reasonOfApproval {
    return Intl.message(
      'Reason of Approval',
      name: 'reasonOfApproval',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get ReasonOfApprove {
    return Intl.message(
      'Reason of Approval',
      name: 'ReasonOfApprove',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Approval`
  String get reasonOfApprove {
    return Intl.message(
      'Reason of Approval',
      name: 'reasonOfApprove',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Cancellation`
  String get ReasonOfCancelation {
    return Intl.message(
      'Reason of Cancellation',
      name: 'ReasonOfCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Rejection`
  String get ReasonOfRejection {
    return Intl.message(
      'Reason of Rejection',
      name: 'ReasonOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Reason of Rejection`
  String get reasonOfRejection {
    return Intl.message(
      'Reason of Rejection',
      name: 'reasonOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Editing`
  String get reasonOfEditing {
    return Intl.message(
      'Reason Of Editing',
      name: 'reasonOfEditing',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Removing`
  String get reasonOfRemoving {
    return Intl.message(
      'Reason Of Removing',
      name: 'reasonOfRemoving',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Return`
  String get reasonOfReturn {
    return Intl.message(
      'Reason Of Return',
      name: 'reasonOfReturn',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Cancellation`
  String get reasonsOfCancellation {
    return Intl.message(
      'Reasons of Cancellation',
      name: 'reasonsOfCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Rejection: `
  String get reasonsOfRejection {
    return Intl.message(
      'Reasons of Rejection: ',
      name: 'reasonsOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Rejection`
  String get reasonsOfRejectionTitle {
    return Intl.message(
      'Reasons of Rejection',
      name: 'reasonsOfRejectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reassign`
  String get reassign {
    return Intl.message('Reassign', name: 'reassign', desc: '', args: []);
  }

  /// `Reassign Champion`
  String get reassignChampion {
    return Intl.message(
      'Reassign Champion',
      name: 'reassignChampion',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Champion`
  String get reassignControlChampion {
    return Intl.message(
      'Reassign Control Champion',
      name: 'reassignControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Champion Request`
  String get reassignControlChampionRequest {
    return Intl.message(
      'Reassign Control Champion Request',
      name: 'reassignControlChampionRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Owner`
  String get reassignControlOwner {
    return Intl.message(
      'Reassign Control Owner',
      name: 'reassignControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Control Owner Request`
  String get reassignControlOwnerRequest {
    return Intl.message(
      'Reassign Control Owner Request',
      name: 'reassignControlOwnerRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Owner`
  String get reassignOwner {
    return Intl.message(
      'Reassign Owner',
      name: 'reassignOwner',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get received {
    return Intl.message('Received', name: 'received', desc: '', args: []);
  }

  /// `Received By`
  String get receivedBy {
    return Intl.message('Received By', name: 'receivedBy', desc: '', args: []);
  }

  /// `Received Date`
  String get receivedDate {
    return Intl.message(
      'Received Date',
      name: 'receivedDate',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Date`
  String get receivingDate {
    return Intl.message(
      'Receiving Date',
      name: 'receivingDate',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Method`
  String get receivingMethod {
    return Intl.message(
      'Receiving Method',
      name: 'receivingMethod',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Zone`
  String get receivingZone {
    return Intl.message(
      'Receiving Zone',
      name: 'receivingZone',
      desc: '',
      args: [],
    );
  }

  /// `Recently Contacted`
  String get recentlyContacted {
    return Intl.message(
      'Recently Contacted',
      name: 'recentlyContacted',
      desc: '',
      args: [],
    );
  }

  /// `Recommended Action`
  String get recommendedAction {
    return Intl.message(
      'Recommended Action',
      name: 'recommendedAction',
      desc: '',
      args: [],
    );
  }

  /// `Recording`
  String get recording {
    return Intl.message('Recording', name: 'recording', desc: '', args: []);
  }

  /// `Red`
  String get red {
    return Intl.message('Red', name: 'red', desc: '', args: []);
  }

  /// `Redirecting...`
  String get redirecting {
    return Intl.message(
      'Redirecting...',
      name: 'redirecting',
      desc: '',
      args: [],
    );
  }

  /// `Registration Document`
  String get registrationDocument {
    return Intl.message(
      'Registration Document',
      name: 'registrationDocument',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get Reject {
    return Intl.message('Reject', name: 'Reject', desc: '', args: []);
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Reject Document`
  String get rejectDocument {
    return Intl.message(
      'Reject Document',
      name: 'rejectDocument',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get Rejected {
    return Intl.message('Rejected', name: 'Rejected', desc: '', args: []);
  }

  /// `Rejected`
  String get rejected {
    return Intl.message('Rejected', name: 'rejected', desc: '', args: []);
  }

  /// `Rejected Date: `
  String get rejectedDate {
    return Intl.message(
      'Rejected Date: ',
      name: 'rejectedDate',
      desc: '',
      args: [],
    );
  }

  /// `Reject Evidence`
  String get rejectEvidence {
    return Intl.message(
      'Reject Evidence',
      name: 'rejectEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get RejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'RejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get rejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'rejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Relationship`
  String get relationship {
    return Intl.message(
      'Relationship',
      name: 'relationship',
      desc: '',
      args: [],
    );
  }

  /// `Remaining Quantity`
  String get remainingQuantity {
    return Intl.message(
      'Remaining Quantity',
      name: 'remainingQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Remind All`
  String get remindAll {
    return Intl.message('Remind All', name: 'remindAll', desc: '', args: []);
  }

  /// `Reminder`
  String get Reminder {
    return Intl.message('Reminder', name: 'Reminder', desc: '', args: []);
  }

  /// `Reminder`
  String get reminder {
    return Intl.message('Reminder', name: 'reminder', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Remove Access`
  String get remove_access {
    return Intl.message(
      'Remove Access',
      name: 'remove_access',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove access for this employee?`
  String get remove_access_confirmation {
    return Intl.message(
      'Are you sure you want to remove access for this employee?',
      name: 'remove_access_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Remove Control Champion`
  String get removeControlChampion {
    return Intl.message(
      'Remove Control Champion',
      name: 'removeControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `Remove Control Owner`
  String get removeControlOwner {
    return Intl.message(
      'Remove Control Owner',
      name: 'removeControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `Removed`
  String get removed {
    return Intl.message('Removed', name: 'removed', desc: '', args: []);
  }

  /// `Removed Date: `
  String get removedDate {
    return Intl.message(
      'Removed Date: ',
      name: 'removedDate',
      desc: '',
      args: [],
    );
  }

  /// `Remove Documents`
  String get removeDocuments {
    return Intl.message(
      'Remove Documents',
      name: 'removeDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Remove Employee`
  String get removeEmployee {
    return Intl.message(
      'Remove Employee',
      name: 'removeEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Remove Knowledge`
  String get removeKnowledge {
    return Intl.message(
      'Remove Knowledge',
      name: 'removeKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `Remove Member`
  String get removeMember {
    return Intl.message(
      'Remove Member',
      name: 'removeMember',
      desc: '',
      args: [],
    );
  }

  /// `Remove Selection`
  String get removeSelection {
    return Intl.message(
      'Remove Selection',
      name: 'removeSelection',
      desc: '',
      args: [],
    );
  }

  /// `Removing Document`
  String get removingDocument {
    return Intl.message(
      'Removing Document',
      name: 'removingDocument',
      desc: '',
      args: [],
    );
  }

  /// `Removing Employee`
  String get removingEmployee {
    return Intl.message(
      'Removing Employee',
      name: 'removingEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Reordering Active - Click to Disable`
  String get reorderingActive {
    return Intl.message(
      'Reordering Active - Click to Disable',
      name: 'reorderingActive',
      desc: '',
      args: [],
    );
  }

  /// `Reorder Level`
  String get reorderLevel {
    return Intl.message(
      'Reorder Level',
      name: 'reorderLevel',
      desc: '',
      args: [],
    );
  }

  /// `Reorder Quantity`
  String get reorderQuantity {
    return Intl.message(
      'Reorder Quantity',
      name: 'reorderQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Repair`
  String get repair {
    return Intl.message('Repair', name: 'repair', desc: '', args: []);
  }

  /// `Replacement`
  String get replacement {
    return Intl.message('Replacement', name: 'replacement', desc: '', args: []);
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `Report`
  String get report {
    return Intl.message('Report', name: 'report', desc: '', args: []);
  }

  /// `Report Bugs`
  String get reportBugs {
    return Intl.message('Report Bugs', name: 'reportBugs', desc: '', args: []);
  }

  /// `Reported To Police`
  String get reportedToPolice {
    return Intl.message(
      'Reported To Police',
      name: 'reportedToPolice',
      desc: '',
      args: [],
    );
  }

  /// `Reporting and Audit`
  String get reportingAndAudit {
    return Intl.message(
      'Reporting and Audit',
      name: 'reportingAndAudit',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get Request {
    return Intl.message('Request', name: 'Request', desc: '', args: []);
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `Request Note`
  String get request_note {
    return Intl.message(
      'Request Note',
      name: 'request_note',
      desc: '',
      args: [],
    );
  }

  /// `Request Submitted`
  String get request_submitted {
    return Intl.message(
      'Request Submitted',
      name: 'request_submitted',
      desc: '',
      args: [],
    );
  }

  /// `Request Approved`
  String get requestApproved {
    return Intl.message(
      'Request Approved',
      name: 'requestApproved',
      desc: '',
      args: [],
    );
  }

  /// `Request Approved Successfully`
  String get requestApprovedSuccessfully {
    return Intl.message(
      'Request Approved Successfully',
      name: 'requestApprovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Request Attachments`
  String get requestAttachments {
    return Intl.message(
      'Request Attachments',
      name: 'requestAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Request By`
  String get requestBy {
    return Intl.message('Request By', name: 'requestBy', desc: '', args: []);
  }

  /// `Request Cancelation`
  String get requestCancelation {
    return Intl.message(
      'Request Cancelation',
      name: 'requestCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Request Cancelled`
  String get requestCancelled {
    return Intl.message(
      'Request Cancelled',
      name: 'requestCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Request Date`
  String get RequestDate {
    return Intl.message(
      'Request Date',
      name: 'RequestDate',
      desc: '',
      args: [],
    );
  }

  /// `Request Date`
  String get requestDate {
    return Intl.message(
      'Request Date',
      name: 'requestDate',
      desc: '',
      args: [],
    );
  }

  /// `Request Description`
  String get requestDescription {
    return Intl.message(
      'Request Description',
      name: 'requestDescription',
      desc: '',
      args: [],
    );
  }

  /// `Request Description (Arabic)`
  String get requestDescriptionAr {
    return Intl.message(
      'Request Description (Arabic)',
      name: 'requestDescriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Request Description (English)`
  String get requestDescriptionEn {
    return Intl.message(
      'Request Description (English)',
      name: 'requestDescriptionEn',
      desc: '',
      args: [],
    );
  }

  /// `Request Details`
  String get requestDetails {
    return Intl.message(
      'Request Details',
      name: 'requestDetails',
      desc: '',
      args: [],
    );
  }

  /// `Request Done`
  String get requestDone {
    return Intl.message(
      'Request Done',
      name: 'requestDone',
      desc: '',
      args: [],
    );
  }

  /// `Requested`
  String get requested {
    return Intl.message('Requested', name: 'requested', desc: '', args: []);
  }

  /// `Requested by`
  String get Requestedby {
    return Intl.message(
      'Requested by',
      name: 'Requestedby',
      desc: '',
      args: [],
    );
  }

  /// `Requested By`
  String get requestedBy {
    return Intl.message(
      'Requested By',
      name: 'requestedBy',
      desc: '',
      args: [],
    );
  }

  /// `Requested Date`
  String get RequestedDate {
    return Intl.message(
      'Requested Date',
      name: 'RequestedDate',
      desc: '',
      args: [],
    );
  }

  /// `Requested Date`
  String get requestedDate {
    return Intl.message(
      'Requested Date',
      name: 'requestedDate',
      desc: '',
      args: [],
    );
  }

  /// `Requested Form`
  String get requestedForm {
    return Intl.message(
      'Requested Form',
      name: 'requestedForm',
      desc: '',
      args: [],
    );
  }

  /// `Requested Maintenance`
  String get requestedMaintenance {
    return Intl.message(
      'Requested Maintenance',
      name: 'requestedMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Requested Name`
  String get requestedName {
    return Intl.message(
      'Requested Name',
      name: 'requestedName',
      desc: '',
      args: [],
    );
  }

  /// `Requested Service`
  String get requestedService {
    return Intl.message(
      'Requested Service',
      name: 'requestedService',
      desc: '',
      args: [],
    );
  }

  /// `Requested Services`
  String get RequestedServices {
    return Intl.message(
      'Requested Services',
      name: 'RequestedServices',
      desc: '',
      args: [],
    );
  }

  /// `Requested Services`
  String get requestedServices {
    return Intl.message(
      'Requested Services',
      name: 'requestedServices',
      desc: '',
      args: [],
    );
  }

  /// `Requested Services Details`
  String get RequestedServicesDetails {
    return Intl.message(
      'Requested Services Details',
      name: 'RequestedServicesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Requested Services Module`
  String get requestedServicesModule {
    return Intl.message(
      'Requested Services Module',
      name: 'requestedServicesModule',
      desc: '',
      args: [],
    );
  }

  /// `Requested To Reset Password ?`
  String get requestedToResetPassword {
    return Intl.message(
      'Requested To Reset Password ?',
      name: 'requestedToResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Requester Details`
  String get RequesterDetails {
    return Intl.message(
      'Requester Details',
      name: 'RequesterDetails',
      desc: '',
      args: [],
    );
  }

  /// `This request has no assigned provider`
  String get requestHasNoAssignedProvider {
    return Intl.message(
      'This request has no assigned provider',
      name: 'requestHasNoAssignedProvider',
      desc: '',
      args: [],
    );
  }

  /// `Request ID`
  String get requestId {
    return Intl.message('Request ID', name: 'requestId', desc: '', args: []);
  }

  /// `Request ID`
  String get requestID {
    return Intl.message('Request ID', name: 'requestID', desc: '', args: []);
  }

  /// `Requesting A Change`
  String get requesting_a_change {
    return Intl.message(
      'Requesting A Change',
      name: 'requesting_a_change',
      desc: '',
      args: [],
    );
  }

  /// `Requesting Asset`
  String get requestingAsset {
    return Intl.message(
      'Requesting Asset',
      name: 'requestingAsset',
      desc: '',
      args: [],
    );
  }

  /// `Requesting Resubmit`
  String get requestingResubmit {
    return Intl.message(
      'Requesting Resubmit',
      name: 'requestingResubmit',
      desc: '',
      args: [],
    );
  }

  /// `Request In Progress`
  String get requestInProgress {
    return Intl.message(
      'Request In Progress',
      name: 'requestInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Request Name`
  String get requestName {
    return Intl.message(
      'Request Name',
      name: 'requestName',
      desc: '',
      args: [],
    );
  }

  /// `Request Name (Arabic)`
  String get requestNameAr {
    return Intl.message(
      'Request Name (Arabic)',
      name: 'requestNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Request Name (English)`
  String get requestNameEn {
    return Intl.message(
      'Request Name (English)',
      name: 'requestNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Request New Feature`
  String get requestNewFeature {
    return Intl.message(
      'Request New Feature',
      name: 'requestNewFeature',
      desc: '',
      args: [],
    );
  }

  /// `Request Note`
  String get requestNote {
    return Intl.message(
      'Request Note',
      name: 'requestNote',
      desc: '',
      args: [],
    );
  }

  /// `Request Position`
  String get requestPosition {
    return Intl.message(
      'Request Position',
      name: 'requestPosition',
      desc: '',
      args: [],
    );
  }

  /// `Request Rejected`
  String get requestRejected {
    return Intl.message(
      'Request Rejected',
      name: 'requestRejected',
      desc: '',
      args: [],
    );
  }

  /// `Request Rejected Successfully`
  String get requestRejectedSuccessfully {
    return Intl.message(
      'Request Rejected Successfully',
      name: 'requestRejectedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `Requests`
  String get Requests {
    return Intl.message('Requests', name: 'Requests', desc: '', args: []);
  }

  /// `Request Details`
  String get requestsDetails {
    return Intl.message(
      'Request Details',
      name: 'requestsDetails',
      desc: '',
      args: [],
    );
  }

  /// `Request Service`
  String get RequestService {
    return Intl.message(
      'Request Service',
      name: 'RequestService',
      desc: '',
      args: [],
    );
  }

  /// `Request Service`
  String get requestService {
    return Intl.message(
      'Request Service',
      name: 'requestService',
      desc: '',
      args: [],
    );
  }

  /// `Request Service Permissions`
  String get requestServicePermissions {
    return Intl.message(
      'Request Service Permissions',
      name: 'requestServicePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Request Service Permissions Module`
  String get requestServicePermissionsModule {
    return Intl.message(
      'Request Service Permissions Module',
      name: 'requestServicePermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Request SLA Exceed`
  String get requestSLAExceed {
    return Intl.message(
      'Request SLA Exceed',
      name: 'requestSLAExceed',
      desc: '',
      args: [],
    );
  }

  /// `Request Status`
  String get requestStatus {
    return Intl.message(
      'Request Status',
      name: 'requestStatus',
      desc: '',
      args: [],
    );
  }

  /// `Request Submitted`
  String get requestSubmitted {
    return Intl.message(
      'Request Submitted',
      name: 'requestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your request has been submitted successfully.`
  String get requestSuccess {
    return Intl.message(
      'Your request has been submitted successfully.',
      name: 'requestSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Request Time Frame`
  String get requestTimeFrame {
    return Intl.message(
      'Request Time Frame',
      name: 'requestTimeFrame',
      desc: '',
      args: [],
    );
  }

  /// `Request To Cancellation`
  String get requestToCancellation {
    return Intl.message(
      'Request To Cancellation',
      name: 'requestToCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Request Change`
  String get requestToChange {
    return Intl.message(
      'Request Change',
      name: 'requestToChange',
      desc: '',
      args: [],
    );
  }

  /// `Request Type`
  String get requestType {
    return Intl.message(
      'Request Type',
      name: 'requestType',
      desc: '',
      args: [],
    );
  }

  /// `Request Types`
  String get requestTypes {
    return Intl.message(
      'Request Types',
      name: 'requestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Request Updated`
  String get requestUpdated {
    return Intl.message(
      'Request Updated',
      name: 'requestUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `Requires Approval`
  String get requiresApproval {
    return Intl.message(
      'Requires Approval',
      name: 'requiresApproval',
      desc: '',
      args: [],
    );
  }

  /// `Requires Approvals`
  String get requiresApprovals {
    return Intl.message(
      'Requires Approvals',
      name: 'requiresApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Requires Attachments`
  String get requiresAttachments {
    return Intl.message(
      'Requires Attachments',
      name: 'requiresAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Requires Description`
  String get requiresDescription {
    return Intl.message(
      'Requires Description',
      name: 'requiresDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reschedule`
  String get reschedule {
    return Intl.message('Reschedule', name: 'reschedule', desc: '', args: []);
  }

  /// `Rescheduled`
  String get rescheduled {
    return Intl.message('Rescheduled', name: 'rescheduled', desc: '', args: []);
  }

  /// `Reschedule Meeting`
  String get rescheduleMeeting {
    return Intl.message(
      'Reschedule Meeting',
      name: 'rescheduleMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get Reset {
    return Intl.message('Reset', name: 'Reset', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Reset Branding`
  String get resetBranding {
    return Intl.message(
      'Reset Branding',
      name: 'resetBranding',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Reset Personal Branding`
  String get resetPersonalBranding {
    return Intl.message(
      'Reset Personal Branding',
      name: 'resetPersonalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Reset to Company Defaults`
  String get resetToCompanyDefaults {
    return Intl.message(
      'Reset to Company Defaults',
      name: 'resetToCompanyDefaults',
      desc: '',
      args: [],
    );
  }

  /// `Reset to Default`
  String get resetToDefault {
    return Intl.message(
      'Reset to Default',
      name: 'resetToDefault',
      desc: '',
      args: [],
    );
  }

  /// `Reset Your Account`
  String get resetYourAccount {
    return Intl.message(
      'Reset Your Account',
      name: 'resetYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Reset Your Password`
  String get resetYourPassword {
    return Intl.message(
      'Reset Your Password',
      name: 'resetYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Restock`
  String get restock {
    return Intl.message('Restock', name: 'restock', desc: '', args: []);
  }

  /// `Restock Added`
  String get restockAdded {
    return Intl.message(
      'Restock Added',
      name: 'restockAdded',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added a restock to this product`
  String get restockAddedSuccess {
    return Intl.message(
      'You successfully added a restock to this product',
      name: 'restockAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Restocking Product`
  String get restockingProduct {
    return Intl.message(
      'Restocking Product',
      name: 'restockingProduct',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Restore Data`
  String get restoreData {
    return Intl.message(
      'Restore Data',
      name: 'restoreData',
      desc: '',
      args: [],
    );
  }

  /// `Restored GRC Module`
  String get restoredGrcModule {
    return Intl.message(
      'Restored GRC Module',
      name: 'restoredGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Restored Modules`
  String get restoredModules {
    return Intl.message(
      'Restored Modules',
      name: 'restoredModules',
      desc: '',
      args: [],
    );
  }

  /// `Restored successfully`
  String get restoredSuccessfully {
    return Intl.message(
      'Restored successfully',
      name: 'restoredSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Restore Form`
  String get restoreForm {
    return Intl.message(
      'Restore Form',
      name: 'restoreForm',
      desc: '',
      args: [],
    );
  }

  /// `Are your sure to restore request type?`
  String get restoreRequestType {
    return Intl.message(
      'Are your sure to restore request type?',
      name: 'restoreRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Restoring GRC Module`
  String get restoringGrcModule {
    return Intl.message(
      'Restoring GRC Module',
      name: 'restoringGrcModule',
      desc: '',
      args: [],
    );
  }

  /// `Restoring Module`
  String get restoringModule {
    return Intl.message(
      'Restoring Module',
      name: 'restoringModule',
      desc: '',
      args: [],
    );
  }

  /// `Restricted Location`
  String get restrictedLocation {
    return Intl.message(
      'Restricted Location',
      name: 'restrictedLocation',
      desc: '',
      args: [],
    );
  }

  /// `The app will only open in the countries you selected. Access from anywhere else will be blocked.`
  String get restrictedLocationConfirmSubtitle {
    return Intl.message(
      'The app will only open in the countries you selected. Access from anywhere else will be blocked.',
      name: 'restrictedLocationConfirmSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Select the countries where the app can be opened`
  String get restrictedLocationCountriesHint {
    return Intl.message(
      'Select the countries where the app can be opened',
      name: 'restrictedLocationCountriesHint',
      desc: '',
      args: [],
    );
  }

  /// `You successfully updated the allowed countries`
  String get restrictedLocationSuccessSubtitle {
    return Intl.message(
      'You successfully updated the allowed countries',
      name: 'restrictedLocationSuccessSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Resubmit Evidence`
  String get resubmitEvidence {
    return Intl.message(
      'Resubmit Evidence',
      name: 'resubmitEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Results Permissions`
  String get resultsPermissions {
    return Intl.message(
      'Results Permissions',
      name: 'resultsPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Results Permissions Module`
  String get resultsPermissionsModule {
    return Intl.message(
      'Results Permissions Module',
      name: 'resultsPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get resume {
    return Intl.message('Resume', name: 'resume', desc: '', args: []);
  }

  /// `Retrieve`
  String get retrieve {
    return Intl.message('Retrieve', name: 'retrieve', desc: '', args: []);
  }

  /// `Retrieve Product`
  String get retrieveProduct {
    return Intl.message(
      'Retrieve Product',
      name: 'retrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Return Date`
  String get returnDate {
    return Intl.message('Return Date', name: 'returnDate', desc: '', args: []);
  }

  /// `Returned`
  String get returned {
    return Intl.message('Returned', name: 'returned', desc: '', args: []);
  }

  /// `Review`
  String get review {
    return Intl.message('Review', name: 'review', desc: '', args: []);
  }

  /// `Reviewed Date`
  String get reviewedDate {
    return Intl.message(
      'Reviewed Date',
      name: 'reviewedDate',
      desc: '',
      args: [],
    );
  }

  /// `Risk Management`
  String get riskManagement {
    return Intl.message(
      'Risk Management',
      name: 'riskManagement',
      desc: '',
      args: [],
    );
  }

  /// `Risk Manager`
  String get riskManager {
    return Intl.message(
      'Risk Manager',
      name: 'riskManager',
      desc: '',
      args: [],
    );
  }

  /// `Riyadh`
  String get riyadh {
    return Intl.message('Riyadh', name: 'riyadh', desc: '', args: []);
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Role Description`
  String get role_description {
    return Intl.message(
      'Role Description',
      name: 'role_description',
      desc: '',
      args: [],
    );
  }

  /// `Role Description (AR)`
  String get role_description_ar {
    return Intl.message(
      'Role Description (AR)',
      name: 'role_description_ar',
      desc: '',
      args: [],
    );
  }

  /// `Role Name`
  String get role_name {
    return Intl.message('Role Name', name: 'role_name', desc: '', args: []);
  }

  /// `Role Name (AR)`
  String get role_name_ar {
    return Intl.message(
      'Role Name (AR)',
      name: 'role_name_ar',
      desc: '',
      args: [],
    );
  }

  /// `Role created successfully`
  String get roleCreatedSuccessfully {
    return Intl.message(
      'Role created successfully',
      name: 'roleCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Role deleted successfully`
  String get roleDeletedSuccessfully {
    return Intl.message(
      'Role deleted successfully',
      name: 'roleDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Role Description`
  String get roleDescription {
    return Intl.message(
      'Role Description',
      name: 'roleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Role Description (Arabic)`
  String get roleDescriptionArabic {
    return Intl.message(
      'Role Description (Arabic)',
      name: 'roleDescriptionArabic',
      desc: '',
      args: [],
    );
  }

  /// `Role Details`
  String get roleDetails {
    return Intl.message(
      'Role Details',
      name: 'roleDetails',
      desc: '',
      args: [],
    );
  }

  /// `Role Information`
  String get roleInformation {
    return Intl.message(
      'Role Information',
      name: 'roleInformation',
      desc: '',
      args: [],
    );
  }

  /// `Role Management`
  String get roleManagement {
    return Intl.message(
      'Role Management',
      name: 'roleManagement',
      desc: '',
      args: [],
    );
  }

  /// `Role Management Module`
  String get roleManagementModule {
    return Intl.message(
      'Role Management Module',
      name: 'roleManagementModule',
      desc: '',
      args: [],
    );
  }

  /// `Role Name`
  String get roleName {
    return Intl.message('Role Name', name: 'roleName', desc: '', args: []);
  }

  /// `Role Name (Arabic)`
  String get roleNameArabic {
    return Intl.message(
      'Role Name (Arabic)',
      name: 'roleNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `Role Not Assigned`
  String get roleNotAssigned {
    return Intl.message(
      'Role Not Assigned',
      name: 'roleNotAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Role Permissions`
  String get rolePermissions {
    return Intl.message(
      'Role Permissions',
      name: 'rolePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Roles`
  String get roles {
    return Intl.message('Roles', name: 'roles', desc: '', args: []);
  }

  /// `Role saved as draft successfully`
  String get roleSavedAsDraftSuccessfully {
    return Intl.message(
      'Role saved as draft successfully',
      name: 'roleSavedAsDraftSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Roles Export`
  String get rolesExport {
    return Intl.message(
      'Roles Export',
      name: 'rolesExport',
      desc: '',
      args: [],
    );
  }

  /// `Role Type`
  String get roleType {
    return Intl.message('Role Type', name: 'roleType', desc: '', args: []);
  }

  /// `Role updated successfully`
  String get roleUpdatedSuccessfully {
    return Intl.message(
      'Role updated successfully',
      name: 'roleUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Romanian`
  String get romanian {
    return Intl.message('Romanian', name: 'romanian', desc: '', args: []);
  }

  /// `Routine Maintenance`
  String get routineMaintenance {
    return Intl.message(
      'Routine Maintenance',
      name: 'routineMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Row`
  String get row {
    return Intl.message('Row', name: 'row', desc: '', args: []);
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `Rwandan`
  String get rwandan {
    return Intl.message('Rwandan', name: 'rwandan', desc: '', args: []);
  }

  /// `Safety`
  String get safety {
    return Intl.message('Safety', name: 'safety', desc: '', args: []);
  }

  /// `Saint Lucian`
  String get saintLucian {
    return Intl.message(
      'Saint Lucian',
      name: 'saintLucian',
      desc: '',
      args: [],
    );
  }

  /// `Salary`
  String get salary {
    return Intl.message('Salary', name: 'salary', desc: '', args: []);
  }

  /// `Sales`
  String get Sales {
    return Intl.message('Sales', name: 'Sales', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Salvadoran`
  String get salvadoran {
    return Intl.message('Salvadoran', name: 'salvadoran', desc: '', args: []);
  }

  /// `Samoan`
  String get samoan {
    return Intl.message('Samoan', name: 'samoan', desc: '', args: []);
  }

  /// `San Marinese`
  String get sanMarinese {
    return Intl.message(
      'San Marinese',
      name: 'sanMarinese',
      desc: '',
      args: [],
    );
  }

  /// `Sao Tomean`
  String get saoTomean {
    return Intl.message('Sao Tomean', name: 'saoTomean', desc: '', args: []);
  }

  /// `Saturday`
  String get saturday {
    return Intl.message('Saturday', name: 'saturday', desc: '', args: []);
  }

  /// `Saudi`
  String get saudi {
    return Intl.message('Saudi', name: 'saudi', desc: '', args: []);
  }

  /// `Save`
  String get Save {
    return Intl.message('Save', name: 'Save', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Save as Draft`
  String get saveAsDraft {
    return Intl.message(
      'Save as Draft',
      name: 'saveAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Saved as Draft`
  String get savedAsDraft {
    return Intl.message(
      'Saved as Draft',
      name: 'savedAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Saved Colors`
  String get savedColors {
    return Intl.message(
      'Saved Colors',
      name: 'savedColors',
      desc: '',
      args: [],
    );
  }

  /// `Save Draft`
  String get saveDraft {
    return Intl.message('Save Draft', name: 'saveDraft', desc: '', args: []);
  }

  /// `Saved to history`
  String get savedToHistory {
    return Intl.message(
      'Saved to history',
      name: 'savedToHistory',
      desc: '',
      args: [],
    );
  }

  /// `Save For Later`
  String get saveForLater {
    return Intl.message(
      'Save For Later',
      name: 'saveForLater',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to save it for later?`
  String get saveForLaterMessage {
    return Intl.message(
      'Do you want to save it for later?',
      name: 'saveForLaterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Save Personal Branding`
  String get savePersonalBranding {
    return Intl.message(
      'Save Personal Branding',
      name: 'savePersonalBranding',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveTitle {
    return Intl.message('Save', name: 'saveTitle', desc: '', args: []);
  }

  /// `save To`
  String get saveTo {
    return Intl.message('save To', name: 'saveTo', desc: '', args: []);
  }

  /// `Saving...`
  String get saving {
    return Intl.message('Saving...', name: 'saving', desc: '', args: []);
  }

  /// `Saving addresses...`
  String get savingAddresses {
    return Intl.message(
      'Saving addresses...',
      name: 'savingAddresses',
      desc: '',
      args: [],
    );
  }

  /// `Saving contacts...`
  String get savingContacts {
    return Intl.message(
      'Saving contacts...',
      name: 'savingContacts',
      desc: '',
      args: [],
    );
  }

  /// `Saving Draft...`
  String get savingDraft {
    return Intl.message(
      'Saving Draft...',
      name: 'savingDraft',
      desc: '',
      args: [],
    );
  }

  /// `Saving to database...`
  String get savingToDatabase {
    return Intl.message(
      'Saving to database...',
      name: 'savingToDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Saving warehouses...`
  String get savingWarehouses {
    return Intl.message(
      'Saving warehouses...',
      name: 'savingWarehouses',
      desc: '',
      args: [],
    );
  }

  /// `Sched`
  String get schedAbbreviation {
    return Intl.message('Sched', name: 'schedAbbreviation', desc: '', args: []);
  }

  /// `Schedule`
  String get schedule {
    return Intl.message('Schedule', name: 'schedule', desc: '', args: []);
  }

  /// `Schedule Publishing`
  String get schedule_publishing {
    return Intl.message(
      'Schedule Publishing',
      name: 'schedule_publishing',
      desc: '',
      args: [],
    );
  }

  /// `Schedule a message`
  String get scheduleAMessage {
    return Intl.message(
      'Schedule a message',
      name: 'scheduleAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled`
  String get scheduled {
    return Intl.message('Scheduled', name: 'scheduled', desc: '', args: []);
  }

  /// `Schedule for Activate`
  String get scheduleForActivate {
    return Intl.message(
      'Schedule for Activate',
      name: 'scheduleForActivate',
      desc: '',
      args: [],
    );
  }

  /// `Schedule for Deactivation`
  String get scheduleForDeactivation {
    return Intl.message(
      'Schedule for Deactivation',
      name: 'scheduleForDeactivation',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Message`
  String get scheduleMessage {
    return Intl.message(
      'Schedule Message',
      name: 'scheduleMessage',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Messages`
  String get scheduleMessages {
    return Intl.message(
      'Schedule Messages',
      name: 'scheduleMessages',
      desc: '',
      args: [],
    );
  }

  /// `Schedule To Deactivate`
  String get scheduleToDeactivate {
    return Intl.message(
      'Schedule To Deactivate',
      name: 'scheduleToDeactivate',
      desc: '',
      args: [],
    );
  }

  /// `Schedule To Reactivate`
  String get scheduleToReactivate {
    return Intl.message(
      'Schedule To Reactivate',
      name: 'scheduleToReactivate',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message('Score', name: 'score', desc: '', args: []);
  }

  /// `Scored`
  String get scored {
    return Intl.message('Scored', name: 'scored', desc: '', args: []);
  }

  /// `Scottish`
  String get scottish {
    return Intl.message('Scottish', name: 'scottish', desc: '', args: []);
  }

  /// `Screen Share`
  String get screenShare {
    return Intl.message(
      'Screen Share',
      name: 'screenShare',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Search country...`
  String get searchCountry {
    return Intl.message(
      'Search country...',
      name: 'searchCountry',
      desc: '',
      args: [],
    );
  }

  /// `Search employee...`
  String get searchEmployee {
    return Intl.message(
      'Search employee...',
      name: 'searchEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Search People`
  String get searchPeople {
    return Intl.message(
      'Search People',
      name: 'searchPeople',
      desc: '',
      args: [],
    );
  }

  /// `Second`
  String get Second {
    return Intl.message('Second', name: 'Second', desc: '', args: []);
  }

  /// `Second`
  String get second {
    return Intl.message('Second', name: 'second', desc: '', args: []);
  }

  /// `Secondary Color`
  String get secondaryColor {
    return Intl.message(
      'Secondary Color',
      name: 'secondaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Second Backup`
  String get secondBackup {
    return Intl.message(
      'Second Backup',
      name: 'secondBackup',
      desc: '',
      args: [],
    );
  }

  /// `Second Emergency Contact`
  String get secondEmergencyContact {
    return Intl.message(
      'Second Emergency Contact',
      name: 'secondEmergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get seconds {
    return Intl.message('Seconds', name: 'seconds', desc: '', args: []);
  }

  /// `Seconds Ago`
  String get secondsAgo {
    return Intl.message('Seconds Ago', name: 'secondsAgo', desc: '', args: []);
  }

  /// `Second Reminder`
  String get secReminder {
    return Intl.message(
      'Second Reminder',
      name: 'secReminder',
      desc: '',
      args: [],
    );
  }

  /// `Secure / Restricted Access`
  String get secureRestrictedAccess {
    return Intl.message(
      'Secure / Restricted Access',
      name: 'secureRestrictedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Secure Storage`
  String get secureStorage {
    return Intl.message(
      'Secure Storage',
      name: 'secureStorage',
      desc: '',
      args: [],
    );
  }

  /// `Secure Vault`
  String get secureVault {
    return Intl.message(
      'Secure Vault',
      name: 'secureVault',
      desc: '',
      args: [],
    );
  }

  /// `Security Audit`
  String get securityAudit {
    return Intl.message(
      'Security Audit',
      name: 'securityAudit',
      desc: '',
      args: [],
    );
  }

  /// `Security Cameras (CCTV)`
  String get securityCameras {
    return Intl.message(
      'Security Cameras (CCTV)',
      name: 'securityCameras',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message('See All', name: 'seeAll', desc: '', args: []);
  }

  /// `See Less`
  String get seeLess {
    return Intl.message('See Less', name: 'seeLess', desc: '', args: []);
  }

  /// `See More`
  String get seeMore {
    return Intl.message('See More', name: 'seeMore', desc: '', args: []);
  }

  /// `Seen and Unseen`
  String get seenAndUnseen {
    return Intl.message(
      'Seen and Unseen',
      name: 'seenAndUnseen',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `Select Department`
  String get select_department {
    return Intl.message(
      'Select Department',
      name: 'select_department',
      desc: '',
      args: [],
    );
  }

  /// `Select Service`
  String get select_service {
    return Intl.message(
      'Select Service',
      name: 'select_service',
      desc: '',
      args: [],
    );
  }

  /// `Select Access Granted`
  String get selectAccessGranted {
    return Intl.message(
      'Select Access Granted',
      name: 'selectAccessGranted',
      desc: '',
      args: [],
    );
  }

  /// `Select Access Revoked`
  String get selectAccessRevoked {
    return Intl.message(
      'Select Access Revoked',
      name: 'selectAccessRevoked',
      desc: '',
      args: [],
    );
  }

  /// `Select Activation Date`
  String get selectActivationDate {
    return Intl.message(
      'Select Activation Date',
      name: 'selectActivationDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Advanced Payment`
  String get selectAdvancedPayment {
    return Intl.message(
      'Select Advanced Payment',
      name: 'selectAdvancedPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get selectAll {
    return Intl.message('Select All', name: 'selectAll', desc: '', args: []);
  }

  /// `Select Arabic Font`
  String get selectArabicFont {
    return Intl.message(
      'Select Arabic Font',
      name: 'selectArabicFont',
      desc: '',
      args: [],
    );
  }

  /// `Select Asset Conditions`
  String get selectAssetConditions {
    return Intl.message(
      'Select Asset Conditions',
      name: 'selectAssetConditions',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one employee`
  String get selectAtLeastOneEmployee {
    return Intl.message(
      'Please select at least one employee',
      name: 'selectAtLeastOneEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one row`
  String get selectAtLeastOneRow {
    return Intl.message(
      'Select at least one row',
      name: 'selectAtLeastOneRow',
      desc: '',
      args: [],
    );
  }

  /// `Select Attachment Type`
  String get selectAttachmentType {
    return Intl.message(
      'Select Attachment Type',
      name: 'selectAttachmentType',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Control`
  String get selectControl {
    return Intl.message(
      'Select Control',
      name: 'selectControl',
      desc: '',
      args: [],
    );
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Select Damage Type`
  String get selectDamageType {
    return Intl.message(
      'Select Damage Type',
      name: 'selectDamageType',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectdate {
    return Intl.message('Select Date', name: 'selectdate', desc: '', args: []);
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Select Delivery Method`
  String get selectDeliveryMethod {
    return Intl.message(
      'Select Delivery Method',
      name: 'selectDeliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Select Department`
  String get selectDepartment {
    return Intl.message(
      'Select Department',
      name: 'selectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Select Different Product`
  String get selectDifferentProduct {
    return Intl.message(
      'Select Different Product',
      name: 'selectDifferentProduct',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Selected modules`
  String get selectedModules {
    return Intl.message(
      'Selected modules',
      name: 'selectedModules',
      desc: '',
      args: [],
    );
  }

  /// `Select End Date`
  String get selectEndDate {
    return Intl.message(
      'Select End Date',
      name: 'selectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectEndTime {
    return Intl.message(
      'Select Time',
      name: 'selectEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Select English Font`
  String get selectEnglishFont {
    return Intl.message(
      'Select English Font',
      name: 'selectEnglishFont',
      desc: '',
      args: [],
    );
  }

  /// `Select exactly one row to duplicate`
  String get selectExactlyOneRowToDuplicate {
    return Intl.message(
      'Select exactly one row to duplicate',
      name: 'selectExactlyOneRowToDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Select file source`
  String get selectFileSource {
    return Intl.message(
      'Select file source',
      name: 'selectFileSource',
      desc: '',
      args: [],
    );
  }

  /// `Select Gender`
  String get selectGender {
    return Intl.message(
      'Select Gender',
      name: 'selectGender',
      desc: '',
      args: [],
    );
  }

  /// `Select Location`
  String get selectLocation {
    return Intl.message(
      'Select Location',
      name: 'selectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Method Of Payment`
  String get selectMethodOfPayment {
    return Intl.message(
      'Select Method Of Payment',
      name: 'selectMethodOfPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select Module`
  String get selectModule {
    return Intl.message(
      'Select Module',
      name: 'selectModule',
      desc: '',
      args: [],
    );
  }

  /// `Select Modules`
  String get selectModules {
    return Intl.message(
      'Select Modules',
      name: 'selectModules',
      desc: '',
      args: [],
    );
  }

  /// `Select Order Date`
  String get selectOrderDate {
    return Intl.message(
      'Select Order Date',
      name: 'selectOrderDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Order Type`
  String get selectOrderType {
    return Intl.message(
      'Select Order Type',
      name: 'selectOrderType',
      desc: '',
      args: [],
    );
  }

  /// `Select Owning Department`
  String get selectOwningDepartment {
    return Intl.message(
      'Select Owning Department',
      name: 'selectOwningDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Select Payment Method`
  String get selectPaymentMethod {
    return Intl.message(
      'Select Payment Method',
      name: 'selectPaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Select Policy`
  String get selectPolicy {
    return Intl.message(
      'Select Policy',
      name: 'selectPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Select Priority`
  String get selectpriority {
    return Intl.message(
      'Select Priority',
      name: 'selectpriority',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Type`
  String get selectProductType {
    return Intl.message(
      'Select Product Type',
      name: 'selectProductType',
      desc: '',
      args: [],
    );
  }

  /// `Select Receiving Date`
  String get selectReceivingDate {
    return Intl.message(
      'Select Receiving Date',
      name: 'selectReceivingDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Recommended Action`
  String get selectRecommendedAction {
    return Intl.message(
      'Select Recommended Action',
      name: 'selectRecommendedAction',
      desc: '',
      args: [],
    );
  }

  /// `Select Request Types`
  String get selectRequestTypes {
    return Intl.message(
      'Select Request Types',
      name: 'selectRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Select Role`
  String get selectRole {
    return Intl.message('Select Role', name: 'selectRole', desc: '', args: []);
  }

  /// `Please select a role and at least one employee`
  String get selectRoleAndEmployee {
    return Intl.message(
      'Please select a role and at least one employee',
      name: 'selectRoleAndEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Please select a role type`
  String get selectRoleType {
    return Intl.message(
      'Please select a role type',
      name: 'selectRoleType',
      desc: '',
      args: [],
    );
  }

  /// `Select Severity Level`
  String get selectSeverityLevel {
    return Intl.message(
      'Select Severity Level',
      name: 'selectSeverityLevel',
      desc: '',
      args: [],
    );
  }

  /// `If you select a specific request type, the approval cycle will only apply to that type, and the remaining request types will not have an approval cycle assigned.`
  String get selectSpecificTypeOnly {
    return Intl.message(
      'If you select a specific request type, the approval cycle will only apply to that type, and the remaining request types will not have an approval cycle assigned.',
      name: 'selectSpecificTypeOnly',
      desc: '',
      args: [],
    );
  }

  /// `Select Start Date`
  String get selectStartDate {
    return Intl.message(
      'Select Start Date',
      name: 'selectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectStartTime {
    return Intl.message(
      'Select Time',
      name: 'selectStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Select Storage Location`
  String get selectStorageLocation {
    return Intl.message(
      'Select Storage Location',
      name: 'selectStorageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Subcategory`
  String get selectSubcategory {
    return Intl.message(
      'Select Subcategory',
      name: 'selectSubcategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Supplier Name`
  String get selectSupplierName {
    return Intl.message(
      'Select Supplier Name',
      name: 'selectSupplierName',
      desc: '',
      args: [],
    );
  }

  /// `Select Warranty & Coverage Status`
  String get selectWarrantyCoverageStatus {
    return Intl.message(
      'Select Warranty & Coverage Status',
      name: 'selectWarrantyCoverageStatus',
      desc: '',
      args: [],
    );
  }

  /// `Select Year`
  String get selectYear {
    return Intl.message('Select Year', name: 'selectYear', desc: '', args: []);
  }

  /// `Semi Annual`
  String get semiAnnual {
    return Intl.message('Semi Annual', name: 'semiAnnual', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Sender Type`
  String get senderType {
    return Intl.message('Sender Type', name: 'senderType', desc: '', args: []);
  }

  /// `Send Notifications`
  String get SendNotifications {
    return Intl.message(
      'Send Notifications',
      name: 'SendNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Send Reminder`
  String get SendReminder {
    return Intl.message(
      'Send Reminder',
      name: 'SendReminder',
      desc: '',
      args: [],
    );
  }

  /// `Send Reminder`
  String get sendReminder {
    return Intl.message(
      'Send Reminder',
      name: 'sendReminder',
      desc: '',
      args: [],
    );
  }

  /// `Senegalese`
  String get senegalese {
    return Intl.message('Senegalese', name: 'senegalese', desc: '', args: []);
  }

  /// `Senior Auditor`
  String get seniorAuditor {
    return Intl.message(
      'Senior Auditor',
      name: 'seniorAuditor',
      desc: '',
      args: [],
    );
  }

  /// `Sep`
  String get sep {
    return Intl.message('Sep', name: 'sep', desc: '', args: []);
  }

  /// `Separated`
  String get separated {
    return Intl.message('Separated', name: 'separated', desc: '', args: []);
  }

  /// `Serbian`
  String get serbian {
    return Intl.message('Serbian', name: 'serbian', desc: '', args: []);
  }

  /// `Service`
  String get service {
    return Intl.message('Service', name: 'service', desc: '', args: []);
  }

  /// `Admin Services`
  String get ServiceADMIN {
    return Intl.message(
      'Admin Services',
      name: 'ServiceADMIN',
      desc: '',
      args: [],
    );
  }

  /// `Service Approvals`
  String get serviceApprovals {
    return Intl.message(
      'Service Approvals',
      name: 'serviceApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Service Dashboard`
  String get serviceDashboard {
    return Intl.message(
      'Service Dashboard',
      name: 'serviceDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Service Department Manager`
  String get ServiceDepartmentManager {
    return Intl.message(
      'Service Department Manager',
      name: 'ServiceDepartmentManager',
      desc: '',
      args: [],
    );
  }

  /// `Service Description`
  String get serviceDescription {
    return Intl.message(
      'Service Description',
      name: 'serviceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Service Description`
  String get ServiceDescription {
    return Intl.message(
      'Service Description',
      name: 'ServiceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Service Details`
  String get serviceDetails {
    return Intl.message(
      'Service Details',
      name: 'serviceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Employee Services`
  String get ServiceEmployee {
    return Intl.message(
      'Employee Services',
      name: 'ServiceEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Service Fulfillment`
  String get ServiceFulfillment {
    return Intl.message(
      'Service Fulfillment',
      name: 'ServiceFulfillment',
      desc: '',
      args: [],
    );
  }

  /// `Service History`
  String get serviceHistory {
    return Intl.message(
      'Service History',
      name: 'serviceHistory',
      desc: '',
      args: [],
    );
  }

  /// `Service Name`
  String get ServiceName {
    return Intl.message(
      'Service Name',
      name: 'ServiceName',
      desc: '',
      args: [],
    );
  }

  /// `Service Name`
  String get serviceName {
    return Intl.message(
      'Service Name',
      name: 'serviceName',
      desc: '',
      args: [],
    );
  }

  /// `Service Name Details`
  String get ServiceNameDetails {
    return Intl.message(
      'Service Name Details',
      name: 'ServiceNameDetails',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider`
  String get serviceProvider {
    return Intl.message(
      'Service Provider',
      name: 'serviceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider`
  String get ServiceProvider {
    return Intl.message(
      'Service Provider',
      name: 'ServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider Details`
  String get ServiceProviderDetails {
    return Intl.message(
      'Service Provider Details',
      name: 'ServiceProviderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider Details`
  String get serviceProviderDetails {
    return Intl.message(
      'Service Provider Details',
      name: 'serviceProviderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Service Requested`
  String get serviceRequested {
    return Intl.message(
      'Service Requested',
      name: 'serviceRequested',
      desc: '',
      args: [],
    );
  }

  /// `Service Requested`
  String get ServiceRequested {
    return Intl.message(
      'Service Requested',
      name: 'ServiceRequested',
      desc: '',
      args: [],
    );
  }

  /// `Service Requester`
  String get serviceRequester {
    return Intl.message(
      'Service Requester',
      name: 'serviceRequester',
      desc: '',
      args: [],
    );
  }

  /// `Service Requestor`
  String get ServiceRequestor {
    return Intl.message(
      'Service Requestor',
      name: 'ServiceRequestor',
      desc: '',
      args: [],
    );
  }

  /// `Service Requests`
  String get serviceRequests {
    return Intl.message(
      'Service Requests',
      name: 'serviceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Service Requests`
  String get ServiceRequests {
    return Intl.message(
      'Service Requests',
      name: 'ServiceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get services {
    return Intl.message('Services', name: 'services', desc: '', args: []);
  }

  /// `Form Builder`
  String get services_app {
    return Intl.message(
      'Form Builder',
      name: 'services_app',
      desc: '',
      args: [],
    );
  }

  /// `Services Comparison`
  String get services_comparison {
    return Intl.message(
      'Services Comparison',
      name: 'services_comparison',
      desc: '',
      args: [],
    );
  }

  /// `Services Control And Cycle`
  String get servicesControlAndCycle {
    return Intl.message(
      'Services Control And Cycle',
      name: 'servicesControlAndCycle',
      desc: '',
      args: [],
    );
  }

  /// `Services Data`
  String get servicesData {
    return Intl.message(
      'Services Data',
      name: 'servicesData',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Service`
  String get servicesDeleteDone {
    return Intl.message(
      'You Successfully Deleted This Service',
      name: 'servicesDeleteDone',
      desc: '',
      args: [],
    );
  }

  /// `Services Done`
  String get ServicesDone {
    return Intl.message(
      'Services Done',
      name: 'ServicesDone',
      desc: '',
      args: [],
    );
  }

  /// `services Done`
  String get servicesDone {
    return Intl.message(
      'services Done',
      name: 'servicesDone',
      desc: '',
      args: [],
    );
  }

  /// `Services Offered`
  String get servicesOffered {
    return Intl.message(
      'Services Offered',
      name: 'servicesOffered',
      desc: '',
      args: [],
    );
  }

  /// `Services Permissions`
  String get servicesPermissions {
    return Intl.message(
      'Services Permissions',
      name: 'servicesPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Services Permissions Module`
  String get servicesPermissionsModule {
    return Intl.message(
      'Services Permissions Module',
      name: 'servicesPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Services & Requests Activated Successfully`
  String get servicesRequestsActivatedSuccessfully {
    return Intl.message(
      'Services & Requests Activated Successfully',
      name: 'servicesRequestsActivatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Services Status`
  String get servicesStatus {
    return Intl.message(
      'Services Status',
      name: 'servicesStatus',
      desc: '',
      args: [],
    );
  }

  /// `Service Status`
  String get serviceStatus {
    return Intl.message(
      'Service Status',
      name: 'serviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Services Updated`
  String get servicesUpdated {
    return Intl.message(
      'Services Updated',
      name: 'servicesUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Services Offered`
  String get servicSOffered {
    return Intl.message(
      'Services Offered',
      name: 'servicSOffered',
      desc: '',
      args: [],
    );
  }

  /// `Set CRM Permissions`
  String get setCRMPermissions {
    return Intl.message(
      'Set CRM Permissions',
      name: 'setCRMPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Set Date`
  String get setDate {
    return Intl.message('Set Date', name: 'setDate', desc: '', args: []);
  }

  /// `Set Time`
  String get setTime {
    return Intl.message('Set Time', name: 'setTime', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Settings Module`
  String get settingsModule {
    return Intl.message(
      'Settings Module',
      name: 'settingsModule',
      desc: '',
      args: [],
    );
  }

  /// `Settings Permission`
  String get settingsPermission {
    return Intl.message(
      'Settings Permission',
      name: 'settingsPermission',
      desc: '',
      args: [],
    );
  }

  /// `Severity Level`
  String get severityLevel {
    return Intl.message(
      'Severity Level',
      name: 'severityLevel',
      desc: '',
      args: [],
    );
  }

  /// `Seychellois`
  String get seychellois {
    return Intl.message('Seychellois', name: 'seychellois', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Share Cellphones In Social Data In Bio`
  String get shareCellphonesInSocialDataInBio {
    return Intl.message(
      'Share Cellphones In Social Data In Bio',
      name: 'shareCellphonesInSocialDataInBio',
      desc: '',
      args: [],
    );
  }

  /// `Share Emails And Social Data In Bio`
  String get shareEmailsAndSocialDataInBio {
    return Intl.message(
      'Share Emails And Social Data In Bio',
      name: 'shareEmailsAndSocialDataInBio',
      desc: '',
      args: [],
    );
  }

  /// `Share Social Information`
  String get shareSocialInformation {
    return Intl.message(
      'Share Social Information',
      name: 'shareSocialInformation',
      desc: '',
      args: [],
    );
  }

  /// `Share Something About Yourself`
  String get shareSomethingAboutYourself {
    return Intl.message(
      'Share Something About Yourself',
      name: 'shareSomethingAboutYourself',
      desc: '',
      args: [],
    );
  }

  /// `Shelf`
  String get shelf {
    return Intl.message('Shelf', name: 'shelf', desc: '', args: []);
  }

  /// `Shelving / Racking`
  String get shelvingRacking {
    return Intl.message(
      'Shelving / Racking',
      name: 'shelvingRacking',
      desc: '',
      args: [],
    );
  }

  /// `Shelving / Racking System`
  String get shelvingRackingSystem {
    return Intl.message(
      'Shelving / Racking System',
      name: 'shelvingRackingSystem',
      desc: '',
      args: [],
    );
  }

  /// `Shipping`
  String get shipping {
    return Intl.message('Shipping', name: 'shipping', desc: '', args: []);
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Show CRM Notifications`
  String get showCRMNotifications {
    return Intl.message(
      'Show CRM Notifications',
      name: 'showCRMNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Database Notifications`
  String get showDatabaseNotifications {
    return Intl.message(
      'Show Database Notifications',
      name: 'showDatabaseNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Employees Notifications`
  String get showEmployeesNotifications {
    return Intl.message(
      'Show Employees Notifications',
      name: 'showEmployeesNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Events Notifications`
  String get showEventsNotifications {
    return Intl.message(
      'Show Events Notifications',
      name: 'showEventsNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show GRC Notifications`
  String get showGRCNotifications {
    return Intl.message(
      'Show GRC Notifications',
      name: 'showGRCNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show HR Notifications`
  String get showHRNotifications {
    return Intl.message(
      'Show HR Notifications',
      name: 'showHRNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Inventory Notifications`
  String get showInventoryNotifications {
    return Intl.message(
      'Show Inventory Notifications',
      name: 'showInventoryNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Knowledge Hub Notifications`
  String get showKnowledgeHubNotifications {
    return Intl.message(
      'Show Knowledge Hub Notifications',
      name: 'showKnowledgeHubNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Messages Notifications`
  String get showMessagesNotifications {
    return Intl.message(
      'Show Messages Notifications',
      name: 'showMessagesNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Notes Notifications`
  String get showNotesNotifications {
    return Intl.message(
      'Show Notes Notifications',
      name: 'showNotesNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Qiyas Notifications`
  String get showQiyasNotifications {
    return Intl.message(
      'Show Qiyas Notifications',
      name: 'showQiyasNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Requests Notifications`
  String get showRequestsNotifications {
    return Intl.message(
      'Show Requests Notifications',
      name: 'showRequestsNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Roles Notifications`
  String get showRolesNotifications {
    return Intl.message(
      'Show Roles Notifications',
      name: 'showRolesNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show services app Notifications`
  String get showServicesAppNotifications {
    return Intl.message(
      'Show services app Notifications',
      name: 'showServicesAppNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Services Notifications`
  String get showServicesNotifications {
    return Intl.message(
      'Show Services Notifications',
      name: 'showServicesNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Settings Notifications`
  String get showSettingsNotifications {
    return Intl.message(
      'Show Settings Notifications',
      name: 'showSettingsNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Tasks Notifications`
  String get showTasksNotifications {
    return Intl.message(
      'Show Tasks Notifications',
      name: 'showTasksNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Todo Notifications`
  String get showTodoNotifications {
    return Intl.message(
      'Show Todo Notifications',
      name: 'showTodoNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show Tracking Notifications`
  String get showTrackingNotifications {
    return Intl.message(
      'Show Tracking Notifications',
      name: 'showTrackingNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Sick Leave`
  String get sickLeave {
    return Intl.message('Sick Leave', name: 'sickLeave', desc: '', args: []);
  }

  /// `Sick Vacation`
  String get sickVacation {
    return Intl.message(
      'Sick Vacation',
      name: 'sickVacation',
      desc: '',
      args: [],
    );
  }

  /// `Sierra Leonean`
  String get sierraLeonean {
    return Intl.message(
      'Sierra Leonean',
      name: 'sierraLeonean',
      desc: '',
      args: [],
    );
  }

  /// `You Have Been Signed Out Successfully`
  String get signedOutSuccessfully {
    return Intl.message(
      'You Have Been Signed Out Successfully',
      name: 'signedOutSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message('Sign Out', name: 'signOut', desc: '', args: []);
  }

  /// `Sign Up is not available in demo mode.`
  String get signUpIsNotAvailableInDemoMode {
    return Intl.message(
      'Sign Up is not available in demo mode.',
      name: 'signUpIsNotAvailableInDemoMode',
      desc: '',
      args: [],
    );
  }

  /// `Singaporean`
  String get singaporean {
    return Intl.message('Singaporean', name: 'singaporean', desc: '', args: []);
  }

  /// `Single`
  String get single {
    return Intl.message('Single', name: 'single', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Skill Level`
  String get skillLevel {
    return Intl.message('Skill Level', name: 'skillLevel', desc: '', args: []);
  }

  /// `Skill Name`
  String get skillName {
    return Intl.message('Skill Name', name: 'skillName', desc: '', args: []);
  }

  /// `Skills`
  String get skills {
    return Intl.message('Skills', name: 'skills', desc: '', args: []);
  }

  /// `Skills Hobbies`
  String get skillsHobbies {
    return Intl.message(
      'Skills Hobbies',
      name: 'skillsHobbies',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `SLA`
  String get sla {
    return Intl.message('SLA', name: 'sla', desc: '', args: []);
  }

  /// `Slovakian`
  String get slovakian {
    return Intl.message('Slovakian', name: 'slovakian', desc: '', args: []);
  }

  /// `Slovenian`
  String get slovenian {
    return Intl.message('Slovenian', name: 'slovenian', desc: '', args: []);
  }

  /// `Approved`
  String get sm_approved {
    return Intl.message('Approved', name: 'sm_approved', desc: '', args: []);
  }

  /// `Breached SLA`
  String get sm_breachedSla {
    return Intl.message(
      'Breached SLA',
      name: 'sm_breachedSla',
      desc: '',
      args: [],
    );
  }

  /// `chooseUnit`
  String get sm_chooseunit {
    return Intl.message(
      'chooseUnit',
      name: 'sm_chooseunit',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get sm_day {
    return Intl.message('day', name: 'sm_day', desc: '', args: []);
  }

  /// `days`
  String get sm_days {
    return Intl.message('days', name: 'sm_days', desc: '', args: []);
  }

  /// `Doesn't Need Approval`
  String get sm_doesnTNeedApproval {
    return Intl.message(
      'Doesn\'t Need Approval',
      name: 'sm_doesnTNeedApproval',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get sm_done {
    return Intl.message('Done', name: 'sm_done', desc: '', args: []);
  }

  /// `Duplicate Info Name`
  String get sm_duplicateInfoName {
    return Intl.message(
      'Duplicate Info Name',
      name: 'sm_duplicateInfoName',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get sm_hour {
    return Intl.message('hour', name: 'sm_hour', desc: '', args: []);
  }

  /// `hours`
  String get sm_hours {
    return Intl.message('hours', name: 'sm_hours', desc: '', args: []);
  }

  /// `Inprogress`
  String get sm_inprogress {
    return Intl.message(
      'Inprogress',
      name: 'sm_inprogress',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get sm_minute {
    return Intl.message('minute', name: 'sm_minute', desc: '', args: []);
  }

  /// `minutes`
  String get sm_minutes {
    return Intl.message('minutes', name: 'sm_minutes', desc: '', args: []);
  }

  /// `month`
  String get sm_month {
    return Intl.message('month', name: 'sm_month', desc: '', args: []);
  }

  /// `months`
  String get sm_months {
    return Intl.message('months', name: 'sm_months', desc: '', args: []);
  }

  /// `Need Approval`
  String get sm_needApproval {
    return Intl.message(
      'Need Approval',
      name: 'sm_needApproval',
      desc: '',
      args: [],
    );
  }

  /// `No requests found`
  String get sm_noRequestsFound {
    return Intl.message(
      'No requests found',
      name: 'sm_noRequestsFound',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get sm_second {
    return Intl.message('second', name: 'sm_second', desc: '', args: []);
  }

  /// `seconds`
  String get sm_seconds {
    return Intl.message('seconds', name: 'sm_seconds', desc: '', args: []);
  }

  /// `Selected`
  String get sm_selected {
    return Intl.message('Selected', name: 'sm_selected', desc: '', args: []);
  }

  /// `selected`
  String get sm_selected2 {
    return Intl.message('selected', name: 'sm_selected2', desc: '', args: []);
  }

  /// `Service Created Successfully`
  String get sm_serviceCreatedSuccessfully {
    return Intl.message(
      'Service Created Successfully',
      name: 'sm_serviceCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Service Updated Successfully`
  String get sm_serviceUpdatedSuccessfully {
    return Intl.message(
      'Service Updated Successfully',
      name: 'sm_serviceUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get sm_unknown {
    return Intl.message('Unknown', name: 'sm_unknown', desc: '', args: []);
  }

  /// `Unknown Unit`
  String get sm_unknownUnit {
    return Intl.message(
      'Unknown Unit',
      name: 'sm_unknownUnit',
      desc: '',
      args: [],
    );
  }

  /// `Unspecified`
  String get sm_unspecified {
    return Intl.message(
      'Unspecified',
      name: 'sm_unspecified',
      desc: '',
      args: [],
    );
  }

  /// `week`
  String get sm_week {
    return Intl.message('week', name: 'sm_week', desc: '', args: []);
  }

  /// `weeks`
  String get sm_weeks {
    return Intl.message('weeks', name: 'sm_weeks', desc: '', args: []);
  }

  /// `year`
  String get sm_year {
    return Intl.message('year', name: 'sm_year', desc: '', args: []);
  }

  /// `Social Information`
  String get socialInformation {
    return Intl.message(
      'Social Information',
      name: 'socialInformation',
      desc: '',
      args: [],
    );
  }

  /// `Social Permissions`
  String get socialPermissions {
    return Intl.message(
      'Social Permissions',
      name: 'socialPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Social Permissions Module`
  String get socialPermissionsModule {
    return Intl.message(
      'Social Permissions Module',
      name: 'socialPermissionsModule',
      desc: '',
      args: [],
    );
  }

  /// `Software`
  String get Software {
    return Intl.message('Software', name: 'Software', desc: '', args: []);
  }

  /// `Software`
  String get software {
    return Intl.message('Software', name: 'software', desc: '', args: []);
  }

  /// `Solomon Islander`
  String get solomonIslander {
    return Intl.message(
      'Solomon Islander',
      name: 'solomonIslander',
      desc: '',
      args: [],
    );
  }

  /// `Somali`
  String get somali {
    return Intl.message('Somali', name: 'somali', desc: '', args: []);
  }

  /// `Some champion/owner assignments couldn't be saved`
  String get someChampionOwnerAssignmentsCouldnTBeSaved {
    return Intl.message(
      'Some champion/owner assignments couldn\'t be saved',
      name: 'someChampionOwnerAssignmentsCouldnTBeSaved',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get Sort {
    return Intl.message('Sort', name: 'Sort', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `South African`
  String get southAfrican {
    return Intl.message(
      'South African',
      name: 'southAfrican',
      desc: '',
      args: [],
    );
  }

  /// `South Korean`
  String get southKorean {
    return Intl.message(
      'South Korean',
      name: 'southKorean',
      desc: '',
      args: [],
    );
  }

  /// `South Sudanese`
  String get southSudanese {
    return Intl.message(
      'South Sudanese',
      name: 'southSudanese',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `Special characters not allowed`
  String get specialCharsNotAllowed {
    return Intl.message(
      'Special characters not allowed',
      name: 'specialCharsNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Specification`
  String get specification {
    return Intl.message(
      'Specification',
      name: 'specification',
      desc: '',
      args: [],
    );
  }

  /// `The specified {field} does not exist. Please verify the entry`
  String specifiedDoesNotExist(Object field) {
    return Intl.message(
      'The specified $field does not exist. Please verify the entry',
      name: 'specifiedDoesNotExist',
      desc: '',
      args: [field],
    );
  }

  /// `The specified {field} {error}! Please verify the entry`
  String specifiedError(Object field, Object error) {
    return Intl.message(
      'The specified $field $error! Please verify the entry',
      name: 'specifiedError',
      desc: '',
      args: [field, error],
    );
  }

  /// `Sri Lankan`
  String get sriLankan {
    return Intl.message('Sri Lankan', name: 'sriLankan', desc: '', args: []);
  }

  /// `Edit`
  String get ss {
    return Intl.message('Edit', name: 'ss', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Standard Storage`
  String get standardStorage {
    return Intl.message(
      'Standard Storage',
      name: 'standardStorage',
      desc: '',
      args: [],
    );
  }

  /// `Star`
  String get star {
    return Intl.message('Star', name: 'star', desc: '', args: []);
  }

  /// `Starred Messages`
  String get starredMessages {
    return Intl.message(
      'Starred Messages',
      name: 'starredMessages',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get start_date {
    return Intl.message('Start Date', name: 'start_date', desc: '', args: []);
  }

  /// `Start Date`
  String get startDate {
    return Intl.message('Start Date', name: 'startDate', desc: '', args: []);
  }

  /// `Start date cannot be after the policy end date`
  String get startDateCannotBeAfterThePolicyEndDate {
    return Intl.message(
      'Start date cannot be after the policy end date',
      name: 'startDateCannotBeAfterThePolicyEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Start date cannot be before the policy start date`
  String get startDateCannotBeBeforeThePolicyStartDate {
    return Intl.message(
      'Start date cannot be before the policy start date',
      name: 'startDateCannotBeBeforeThePolicyStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Started Messages`
  String get startedMessages {
    return Intl.message(
      'Started Messages',
      name: 'startedMessages',
      desc: '',
      args: [],
    );
  }

  /// `Start Shift`
  String get startShift {
    return Intl.message('Start Shift', name: 'startShift', desc: '', args: []);
  }

  /// `Start Time`
  String get startTime {
    return Intl.message('Start Time', name: 'startTime', desc: '', args: []);
  }

  /// `State or Province`
  String get state {
    return Intl.message('State or Province', name: 'state', desc: '', args: []);
  }

  /// `State or Province`
  String get stateOrProvince {
    return Intl.message(
      'State or Province',
      name: 'stateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `State/Province is required.`
  String get stateRequired {
    return Intl.message(
      'State/Province is required.',
      name: 'stateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get Statistics {
    return Intl.message('Statistics', name: 'Statistics', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Status`
  String get Status {
    return Intl.message('Status', name: 'Status', desc: '', args: []);
  }

  /// `Approved`
  String get status_approved {
    return Intl.message(
      'Approved',
      name: 'status_approved',
      desc: '',
      args: [],
    );
  }

  /// `Breached SLA`
  String get status_breached {
    return Intl.message(
      'Breached SLA',
      name: 'status_breached',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get status_cancel {
    return Intl.message('Canceled', name: 'status_cancel', desc: '', args: []);
  }

  /// `Done`
  String get status_done {
    return Intl.message('Done', name: 'status_done', desc: '', args: []);
  }

  /// `In progress`
  String get status_inprogress {
    return Intl.message(
      'In progress',
      name: 'status_inprogress',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get status_pending {
    return Intl.message('Pending', name: 'status_pending', desc: '', args: []);
  }

  /// `Rejected`
  String get status_rejected {
    return Intl.message(
      'Rejected',
      name: 'status_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Status Of Services`
  String get StatusOfServices {
    return Intl.message(
      'Status Of Services',
      name: 'StatusOfServices',
      desc: '',
      args: [],
    );
  }

  /// `Status Requested`
  String get statusRequested {
    return Intl.message(
      'Status Requested',
      name: 'statusRequested',
      desc: '',
      args: [],
    );
  }

  /// `Status updated successfully`
  String get statusUpdatedSuccessfully {
    return Intl.message(
      'Status updated successfully',
      name: 'statusUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Step 2: Service Requests`
  String get step2ServiceRequests {
    return Intl.message(
      'Step 2: Service Requests',
      name: 'step2ServiceRequests',
      desc: '',
      args: [],
    );
  }

  /// `Stock`
  String get stock {
    return Intl.message('Stock', name: 'stock', desc: '', args: []);
  }

  /// `Stocks`
  String get stocks {
    return Intl.message('Stocks', name: 'stocks', desc: '', args: []);
  }

  /// `Stocks Overview`
  String get stocksOverview {
    return Intl.message(
      'Stocks Overview',
      name: 'stocksOverview',
      desc: '',
      args: [],
    );
  }

  /// `Stolen`
  String get stolen {
    return Intl.message('Stolen', name: 'stolen', desc: '', args: []);
  }

  /// `Storage`
  String get storage {
    return Intl.message('Storage', name: 'storage', desc: '', args: []);
  }

  /// `Storage Capacity`
  String get storageCapacity {
    return Intl.message(
      'Storage Capacity',
      name: 'storageCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Storage Capacity is required`
  String get storageCapacityRequired {
    return Intl.message(
      'Storage Capacity is required',
      name: 'storageCapacityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Storage ID`
  String get storageId {
    return Intl.message('Storage ID', name: 'storageId', desc: '', args: []);
  }

  /// `Storage Location`
  String get storageLocation {
    return Intl.message(
      'Storage Location',
      name: 'storageLocation',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location And Quantity`
  String get storageLocationAndQuantity {
    return Intl.message(
      'Storage Location And Quantity',
      name: 'storageLocationAndQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location Details`
  String get storageLocationDetails {
    return Intl.message(
      'Storage Location Details',
      name: 'storageLocationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location ID`
  String get storageLocationID {
    return Intl.message(
      'Storage Location ID',
      name: 'storageLocationID',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location ID`
  String get storageLocationId {
    return Intl.message(
      'Storage Location ID',
      name: 'storageLocationId',
      desc: '',
      args: [],
    );
  }

  /// `storageLocation Name`
  String get storageLocationIDName {
    return Intl.message(
      'storageLocation Name',
      name: 'storageLocationIDName',
      desc: '',
      args: [],
    );
  }

  /// `Storage Location ID is required`
  String get storageLocationIdRequired {
    return Intl.message(
      'Storage Location ID is required',
      name: 'storageLocationIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Storage Locations`
  String get storageLocations {
    return Intl.message(
      'Storage Locations',
      name: 'storageLocations',
      desc: '',
      args: [],
    );
  }

  /// `Storage Requirement`
  String get storageRequirement {
    return Intl.message(
      'Storage Requirement',
      name: 'storageRequirement',
      desc: '',
      args: [],
    );
  }

  /// `Stored On`
  String get storedOn {
    return Intl.message('Stored On', name: 'storedOn', desc: '', args: []);
  }

  /// `Stored Products`
  String get storedProducts {
    return Intl.message(
      'Stored Products',
      name: 'storedProducts',
      desc: '',
      args: [],
    );
  }

  /// `Strategy & Alignment`
  String get strategyAlignment {
    return Intl.message(
      'Strategy & Alignment',
      name: 'strategyAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Streamlined Requests`
  String get streamlinedRequests {
    return Intl.message(
      'Streamlined Requests',
      name: 'streamlinedRequests',
      desc: '',
      args: [],
    );
  }

  /// `Simplify the process of submitting, tracking, and managing requests within your organization. Our intuitive system ensures that all requests are handled promptly and efficiently, keeping everyone informed and on the same page.`
  String get streamlinedRequestsBody {
    return Intl.message(
      'Simplify the process of submitting, tracking, and managing requests within your organization. Our intuitive system ensures that all requests are handled promptly and efficiently, keeping everyone informed and on the same page.',
      name: 'streamlinedRequestsBody',
      desc: '',
      args: [],
    );
  }

  /// `Street`
  String get street {
    return Intl.message('Street', name: 'street', desc: '', args: []);
  }

  /// `Street Address`
  String get streetAddress {
    return Intl.message(
      'Street Address',
      name: 'streetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Street Name`
  String get streetName {
    return Intl.message('Street Name', name: 'streetName', desc: '', args: []);
  }

  /// `Street Name is required`
  String get streetNameRequired {
    return Intl.message(
      'Street Name is required',
      name: 'streetNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Subcategory`
  String get subcategory {
    return Intl.message('Subcategory', name: 'subcategory', desc: '', args: []);
  }

  /// `Subject`
  String get subject {
    return Intl.message('Subject', name: 'subject', desc: '', args: []);
  }

  /// `Submission`
  String get submission {
    return Intl.message('Submission', name: 'submission', desc: '', args: []);
  }

  /// `Submission Date`
  String get submissionDate {
    return Intl.message(
      'Submission Date',
      name: 'submissionDate',
      desc: '',
      args: [],
    );
  }

  /// `Submission Form`
  String get submissionForm {
    return Intl.message(
      'Submission Form',
      name: 'submissionForm',
      desc: '',
      args: [],
    );
  }

  /// `Submission Note`
  String get submissionNote {
    return Intl.message(
      'Submission Note',
      name: 'submissionNote',
      desc: '',
      args: [],
    );
  }

  /// `Submission Notes`
  String get submissionNotes {
    return Intl.message(
      'Submission Notes',
      name: 'submissionNotes',
      desc: '',
      args: [],
    );
  }

  /// `Submissions`
  String get submissions {
    return Intl.message('Submissions', name: 'submissions', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Submit For Approval`
  String get submit_for_approval {
    return Intl.message(
      'Submit For Approval',
      name: 'submit_for_approval',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted For Approval`
  String get submit_success_message {
    return Intl.message(
      'You Successfully Submitted For Approval',
      name: 'submit_success_message',
      desc: '',
      args: [],
    );
  }

  /// `Submit Evidence`
  String get submitEvidence {
    return Intl.message(
      'Submit Evidence',
      name: 'submitEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Submit For Approval`
  String get submitForApproval {
    return Intl.message(
      'Submit For Approval',
      name: 'submitForApproval',
      desc: '',
      args: [],
    );
  }

  /// `Submit Form`
  String get submitForm {
    return Intl.message('Submit Form', name: 'submitForm', desc: '', args: []);
  }

  /// `Submit Request`
  String get submitRequest {
    return Intl.message(
      'Submit Request',
      name: 'submitRequest',
      desc: '',
      args: [],
    );
  }

  /// `Submitted`
  String get submitted {
    return Intl.message('Submitted', name: 'submitted', desc: '', args: []);
  }

  /// `Submitted Date: `
  String get submittedDate {
    return Intl.message(
      'Submitted Date: ',
      name: 'submittedDate',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Transaction`
  String get submittedTransaction {
    return Intl.message(
      'Submitted Transaction',
      name: 'submittedTransaction',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Transaction`
  String get submittedTransactionMessage {
    return Intl.message(
      'You Successfully Submitted This Transaction',
      name: 'submittedTransactionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Submitting...`
  String get submitting {
    return Intl.message(
      'Submitting...',
      name: 'submitting',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Control?`
  String get subtitle {
    return Intl.message(
      'Are You Sure You Want To Create This Control?',
      name: 'subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `You Successfully Added This Asset`
  String get successAddAsset {
    return Intl.message(
      'You Successfully Added This Asset',
      name: 'successAddAsset',
      desc: '',
      args: [],
    );
  }

  /// `You successfully assigned this asset`
  String get successAssignAsset {
    return Intl.message(
      'You successfully assigned this asset',
      name: 'successAssignAsset',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed Service Provider`
  String get successChangeServiceProvider {
    return Intl.message(
      'You Successfully Changed Service Provider',
      name: 'successChangeServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked In`
  String get successCheckedInMessage {
    return Intl.message(
      'You Successfully Checked In',
      name: 'successCheckedInMessage',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked Out`
  String get successCheckOutMessage {
    return Intl.message(
      'You Successfully Checked Out',
      name: 'successCheckOutMessage',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this request.`
  String get successCreateRequest {
    return Intl.message(
      'You successfully created this request.',
      name: 'successCreateRequest',
      desc: '',
      args: [],
    );
  }

  /// `File downloaded successfully`
  String get successDownloadFile {
    return Intl.message(
      'File downloaded successfully',
      name: 'successDownloadFile',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully download This page`
  String get successDownloadPage {
    return Intl.message(
      'You Successfully download This page',
      name: 'successDownloadPage',
      desc: '',
      args: [],
    );
  }

  /// `You Have Successfully Assigned Equal Weight To All Controls`
  String get successEqualWeight {
    return Intl.message(
      'You Have Successfully Assigned Equal Weight To All Controls',
      name: 'successEqualWeight',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get Successful {
    return Intl.message('Successful', name: 'Successful', desc: '', args: []);
  }

  /// `Successful`
  String get successful {
    return Intl.message('Successful', name: 'successful', desc: '', args: []);
  }

  /// `Successfully`
  String get successfully {
    return Intl.message(
      'Successfully',
      name: 'successfully',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Request`
  String get successfully_submitted_request {
    return Intl.message(
      'You Successfully Submitted This Request',
      name: 'successfully_submitted_request',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Activated These Services`
  String get successfullyActivated {
    return Intl.message(
      'You Successfully Activated These Services',
      name: 'successfullyActivated',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Module`
  String get successfullyChangedStatus {
    return Intl.message(
      'You Successfully Changed the Status Of This Module',
      name: 'successfullyChangedStatus',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This GRC Module`
  String get successfullyCreatedGrc {
    return Intl.message(
      'You Successfully Created This GRC Module',
      name: 'successfullyCreatedGrc',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Service`
  String get successfullyCreatedService {
    return Intl.message(
      'You Successfully Created This Service',
      name: 'successfullyCreatedService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Control`
  String get successfullyDeletedControl {
    return Intl.message(
      'You Successfully Deleted This Control',
      name: 'successfullyDeletedControl',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Module`
  String get successfullyDeletedGrc {
    return Intl.message(
      'You Successfully Deleted This Module',
      name: 'successfullyDeletedGrc',
      desc: '',
      args: [],
    );
  }

  /// `The supplier has been successfully deleted from the system.`
  String get successfullyDeletedSupplier {
    return Intl.message(
      'The supplier has been successfully deleted from the system.',
      name: 'successfullyDeletedSupplier',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Drafted This Service`
  String get successfullyDraftedService {
    return Intl.message(
      'You Successfully Drafted This Service',
      name: 'successfullyDraftedService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Module`
  String get successfullyEditedGrc {
    return Intl.message(
      'You Successfully Edited This Module',
      name: 'successfullyEditedGrc',
      desc: '',
      args: [],
    );
  }

  /// `You successfully edited this service.`
  String get successfullyEditedService {
    return Intl.message(
      'You successfully edited this service.',
      name: 'successfullyEditedService',
      desc: '',
      args: [],
    );
  }

  /// `You successfully edited this supplier`
  String get successfullyEditedSupplier {
    return Intl.message(
      'You successfully edited this supplier',
      name: 'successfullyEditedSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Successfully fetched specific knowledge`
  String get successfullyFetchedSpecificKnowledge {
    return Intl.message(
      'Successfully fetched specific knowledge',
      name: 'successfullyFetchedSpecificKnowledge',
      desc: '',
      args: [],
    );
  }

  /// `You successfully requested this asset`
  String get successfullyRequestedAsset {
    return Intl.message(
      'You successfully requested this asset',
      name: 'successfullyRequestedAsset',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Restored This Module`
  String get successfullyRestoredGrc {
    return Intl.message(
      'You Successfully Restored This Module',
      name: 'successfullyRestoredGrc',
      desc: '',
      args: [],
    );
  }

  /// `Successfully Restored Module`
  String get successfullyRestoredModule {
    return Intl.message(
      'Successfully Restored Module',
      name: 'successfullyRestoredModule',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Requested Cancelation For This Request`
  String get successfulRequestCancelation {
    return Intl.message(
      'You Successfully Requested Cancelation For This Request',
      name: 'successfulRequestCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Your Request Has Been Successfully Submitted`
  String get successfulRequestSubmission {
    return Intl.message(
      'Your Request Has Been Successfully Submitted',
      name: 'successfulRequestSubmission',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Request Type`
  String get successfulRequestTypeCreate {
    return Intl.message(
      'You Successfully Created This Request Type',
      name: 'successfulRequestTypeCreate',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Request Type`
  String get successfulRequestTypeDelete {
    return Intl.message(
      'You Successfully Deleted This Request Type',
      name: 'successfulRequestTypeDelete',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Request Type`
  String get successfulRequestTypeEdit {
    return Intl.message(
      'You Successfully Edited This Request Type',
      name: 'successfulRequestTypeEdit',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Request Type`
  String get successfulStatusChange {
    return Intl.message(
      'You Successfully Changed the Status Of This Request Type',
      name: 'successfulStatusChange',
      desc: '',
      args: [],
    );
  }

  /// `Your Location Matches the Company’s Location`
  String get successLocationMessage {
    return Intl.message(
      'Your Location Matches the Company’s Location',
      name: 'successLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Your data has been successfully updated`
  String get successMessage {
    return Intl.message(
      'Your data has been successfully updated',
      name: 'successMessage',
      desc: '',
      args: [],
    );
  }

  /// `You successfully retrieved this product`
  String get successRetrieveProduct {
    return Intl.message(
      'You successfully retrieved this product',
      name: 'successRetrieveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Draft saved successfully`
  String get successSavingDraft {
    return Intl.message(
      'Draft saved successfully',
      name: 'successSavingDraft',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This GRC Control`
  String get successSubtitle {
    return Intl.message(
      'You Successfully Created This GRC Control',
      name: 'successSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Creating Control`
  String get successTitle {
    return Intl.message(
      'Creating Control',
      name: 'successTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sudanese`
  String get sudanese {
    return Intl.message('Sudanese', name: 'sudanese', desc: '', args: []);
  }

  /// `Sunday`
  String get sunday {
    return Intl.message('Sunday', name: 'sunday', desc: '', args: []);
  }

  /// `SuperVisor`
  String get superVisor {
    return Intl.message('SuperVisor', name: 'superVisor', desc: '', args: []);
  }

  /// `Supervisor`
  String get supervisor {
    return Intl.message('Supervisor', name: 'supervisor', desc: '', args: []);
  }

  /// `Supplier`
  String get supplier {
    return Intl.message('Supplier', name: 'supplier', desc: '', args: []);
  }

  /// `You Successfully Added This Supplier`
  String get supplierAddedSuccessfully {
    return Intl.message(
      'You Successfully Added This Supplier',
      name: 'supplierAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Bank Transfer Details`
  String get supplierBankTransferDetails {
    return Intl.message(
      'Supplier Bank Transfer Details',
      name: 'supplierBankTransferDetails',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Deleted`
  String get supplierDeleted {
    return Intl.message(
      'Supplier Deleted',
      name: 'supplierDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Details`
  String get supplierDetails {
    return Intl.message(
      'Supplier Details',
      name: 'supplierDetails',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Edited`
  String get supplierEdited {
    return Intl.message(
      'Supplier Edited',
      name: 'supplierEdited',
      desc: '',
      args: [],
    );
  }

  /// `Supplier ID`
  String get supplierId {
    return Intl.message('Supplier ID', name: 'supplierId', desc: '', args: []);
  }

  /// `Supplier ID`
  String get supplierID {
    return Intl.message('Supplier ID', name: 'supplierID', desc: '', args: []);
  }

  /// `Supplier ID is required`
  String get supplierIdRequired {
    return Intl.message(
      'Supplier ID is required',
      name: 'supplierIdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Name`
  String get supplierName {
    return Intl.message(
      'Supplier Name',
      name: 'supplierName',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Name is required`
  String get supplierNameRequired {
    return Intl.message(
      'Supplier Name is required',
      name: 'supplierNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Rank`
  String get supplierRank {
    return Intl.message(
      'Supplier Rank',
      name: 'supplierRank',
      desc: '',
      args: [],
    );
  }

  /// `Suppliers`
  String get suppliers {
    return Intl.message('Suppliers', name: 'suppliers', desc: '', args: []);
  }

  /// `Surinamer`
  String get surinamer {
    return Intl.message('Surinamer', name: 'surinamer', desc: '', args: []);
  }

  /// `Swazi`
  String get swazi {
    return Intl.message('Swazi', name: 'swazi', desc: '', args: []);
  }

  /// `Swedish`
  String get swedish {
    return Intl.message('Swedish', name: 'swedish', desc: '', args: []);
  }

  /// `Bank SWIFT/BIC Code`
  String get swiftCode {
    return Intl.message(
      'Bank SWIFT/BIC Code',
      name: 'swiftCode',
      desc: '',
      args: [],
    );
  }

  /// `SWIFT/BIC code is required.`
  String get swiftCodeRequired {
    return Intl.message(
      'SWIFT/BIC code is required.',
      name: 'swiftCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Swipe Left To Cancel`
  String get swipeLeftToCancel {
    return Intl.message(
      'Swipe Left To Cancel',
      name: 'swipeLeftToCancel',
      desc: '',
      args: [],
    );
  }

  /// `Swiss`
  String get swiss {
    return Intl.message('Swiss', name: 'swiss', desc: '', args: []);
  }

  /// `Syrian`
  String get syrian {
    return Intl.message('Syrian', name: 'syrian', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `System Managements`
  String get systemManagements {
    return Intl.message(
      'System Managements',
      name: 'systemManagements',
      desc: '',
      args: [],
    );
  }

  /// `Systems Logs`
  String get systemsLogs {
    return Intl.message(
      'Systems Logs',
      name: 'systemsLogs',
      desc: '',
      args: [],
    );
  }

  /// `Table`
  String get table {
    return Intl.message('Table', name: 'table', desc: '', args: []);
  }

  /// `Tablet View`
  String get tabletView {
    return Intl.message('Tablet View', name: 'tabletView', desc: '', args: []);
  }

  /// `Tabulated`
  String get tabulated {
    return Intl.message('Tabulated', name: 'tabulated', desc: '', args: []);
  }

  /// `Taiwanese`
  String get taiwanese {
    return Intl.message('Taiwanese', name: 'taiwanese', desc: '', args: []);
  }

  /// `Tajik`
  String get tajik {
    return Intl.message('Tajik', name: 'tajik', desc: '', args: []);
  }

  /// `Take Screen Shot`
  String get takeScreenShot {
    return Intl.message(
      'Take Screen Shot',
      name: 'takeScreenShot',
      desc: '',
      args: [],
    );
  }

  /// `Take Screenshot`
  String get takeScreenshot {
    return Intl.message(
      'Take Screenshot',
      name: 'takeScreenshot',
      desc: '',
      args: [],
    );
  }

  /// `Tanzanian`
  String get tanzanian {
    return Intl.message('Tanzanian', name: 'tanzanian', desc: '', args: []);
  }

  /// `Tap and hold on a message to star it, and it will show up here.`
  String get tapAndHoldOnAMessageToStarItAndItWillShowUpHere {
    return Intl.message(
      'Tap and hold on a message to star it, and it will show up here.',
      name: 'tapAndHoldOnAMessageToStarItAndItWillShowUpHere',
      desc: '',
      args: [],
    );
  }

  /// `Task Details`
  String get taskDetails {
    return Intl.message(
      'Task Details',
      name: 'taskDetails',
      desc: '',
      args: [],
    );
  }

  /// `Task Reminder`
  String get taskReminder {
    return Intl.message(
      'Task Reminder',
      name: 'taskReminder',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasks {
    return Intl.message('Tasks', name: 'tasks', desc: '', args: []);
  }

  /// `TasksResponsivePage`
  String get tasksresponsivepage {
    return Intl.message(
      'TasksResponsivePage',
      name: 'tasksresponsivepage',
      desc: '',
      args: [],
    );
  }

  /// `Tax Certificate`
  String get taxCertificate {
    return Intl.message(
      'Tax Certificate',
      name: 'taxCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Tax Number`
  String get taxNumber {
    return Intl.message('Tax Number', name: 'taxNumber', desc: '', args: []);
  }

  /// `Tax Number is required`
  String get taxNumberRequired {
    return Intl.message(
      'Tax Number is required',
      name: 'taxNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Team Departments`
  String get teamDepartments {
    return Intl.message(
      'Team Departments',
      name: 'teamDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Team Lead`
  String get teamLead {
    return Intl.message('Team Lead', name: 'teamLead', desc: '', args: []);
  }

  /// `Technician`
  String get technician {
    return Intl.message('Technician', name: 'technician', desc: '', args: []);
  }

  /// `Tech Team`
  String get techTeam {
    return Intl.message('Tech Team', name: 'techTeam', desc: '', args: []);
  }

  /// `Temperature Control`
  String get temperatureControl {
    return Intl.message(
      'Temperature Control',
      name: 'temperatureControl',
      desc: '',
      args: [],
    );
  }

  /// `Temperature-Controlled`
  String get temperatureControlled {
    return Intl.message(
      'Temperature-Controlled',
      name: 'temperatureControlled',
      desc: '',
      args: [],
    );
  }

  /// `Temperature Monitoring Devices`
  String get temperatureMonitoringDevices {
    return Intl.message(
      'Temperature Monitoring Devices',
      name: 'temperatureMonitoringDevices',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Terms And Conditions`
  String get termsAndConditions2 {
    return Intl.message(
      'Terms And Conditions',
      name: 'termsAndConditions2',
      desc: '',
      args: [],
    );
  }

  /// `Draft`
  String get test {
    return Intl.message('Draft', name: 'test', desc: '', args: []);
  }

  /// `Text Color`
  String get textColor {
    return Intl.message('Text Color', name: 'textColor', desc: '', args: []);
  }

  /// `Text Here`
  String get Texthere {
    return Intl.message('Text Here', name: 'Texthere', desc: '', args: []);
  }

  /// `Text here`
  String get textHere {
    return Intl.message('Text here', name: 'textHere', desc: '', args: []);
  }

  /// `th`
  String get th {
    return Intl.message('th', name: 'th', desc: '', args: []);
  }

  /// `Thai`
  String get thai {
    return Intl.message('Thai', name: 'thai', desc: '', args: []);
  }

  /// `Thanks for sharing your feedback`
  String get thanksForSharingYourFeedback {
    return Intl.message(
      'Thanks for sharing your feedback',
      name: 'thanksForSharingYourFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Thank You`
  String get thankYou {
    return Intl.message('Thank You', name: 'thankYou', desc: '', args: []);
  }

  /// `The backup has been restored successfully`
  String get theBackupHasBeenRestoredSuccessfully {
    return Intl.message(
      'The backup has been restored successfully',
      name: 'theBackupHasBeenRestoredSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The data for this field is empty.`
  String get theDataForThisFieldIsEmpty {
    return Intl.message(
      'The data for this field is empty.',
      name: 'theDataForThisFieldIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The Department ID must be numeric and contain no letters`
  String get theDepartmentIDMustBeNumericAndContainNoLetters {
    return Intl.message(
      'The Department ID must be numeric and contain no letters',
      name: 'theDepartmentIDMustBeNumericAndContainNoLetters',
      desc: '',
      args: [],
    );
  }

  /// `The document has been approved and will be published`
  String get theDocumentHasBeenApproved {
    return Intl.message(
      'The document has been approved and will be published',
      name: 'theDocumentHasBeenApproved',
      desc: '',
      args: [],
    );
  }

  /// `The document has been rejected and the creator will be notified`
  String get theDocumentHasBeenRejected {
    return Intl.message(
      'The document has been rejected and the creator will be notified',
      name: 'theDocumentHasBeenRejected',
      desc: '',
      args: [],
    );
  }

  /// `The email must follow the format user@domain.com`
  String get theEmailMustFollowTheFormatUserDomainCom {
    return Intl.message(
      'The email must follow the format user@domain.com',
      name: 'theEmailMustFollowTheFormatUserDomainCom',
      desc: '',
      args: [],
    );
  }

  /// `The Excel file is not accepted.`
  String get theExcelFileIsNotAccepted {
    return Intl.message(
      'The Excel file is not accepted.',
      name: 'theExcelFileIsNotAccepted',
      desc: '',
      args: [],
    );
  }

  /// `The Name of Request`
  String get TheNameOfRequest {
    return Intl.message(
      'The Name of Request',
      name: 'TheNameOfRequest',
      desc: '',
      args: [],
    );
  }

  /// `The phone number must be between 8 and 15 digit`
  String get thePhoneNumberMustBeBetween8And15Digit {
    return Intl.message(
      'The phone number must be between 8 and 15 digit',
      name: 'thePhoneNumberMustBeBetween8And15Digit',
      desc: '',
      args: [],
    );
  }

  /// `The request has been approved successfully`
  String get theRequestHasBeenApprovedSuccessfully {
    return Intl.message(
      'The request has been approved successfully',
      name: 'theRequestHasBeenApprovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The request has been rejected successfully`
  String get theRequestHasBeenRejectedSuccessfully {
    return Intl.message(
      'The request has been rejected successfully',
      name: 'theRequestHasBeenRejectedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The request has been updated successfully`
  String get theRequestHasBeenUpdatedSuccessfully {
    return Intl.message(
      'The request has been updated successfully',
      name: 'theRequestHasBeenUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The specified`
  String get theSpecified {
    return Intl.message(
      'The specified',
      name: 'theSpecified',
      desc: '',
      args: [],
    );
  }

  /// `Third`
  String get Third {
    return Intl.message('Third', name: 'Third', desc: '', args: []);
  }

  /// `Third Reminder`
  String get thirdReminder {
    return Intl.message(
      'Third Reminder',
      name: 'thirdReminder',
      desc: '',
      args: [],
    );
  }

  /// `This Email Not Found`
  String get thisEmailNotFound {
    return Intl.message(
      'This Email Not Found',
      name: 'thisEmailNotFound',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted.`
  String get thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi {
    return Intl.message(
      'This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted.',
      name: 'thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted`
  String get thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2 {
    return Intl.message(
      'This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted',
      name: 'thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts English only. Please provide your entry in English script; entries in any other language cannot be accepted.`
  String get thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl {
    return Intl.message(
      'This field accepts English only. Please provide your entry in English script; entries in any other language cannot be accepted.',
      name: 'thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get thisFieldIsRequired {
    return Intl.message(
      'This field is required',
      name: 'thisFieldIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `This module is not available`
  String get thisModuleIsNotAvailable {
    return Intl.message(
      'This module is not available',
      name: 'thisModuleIsNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `This Month`
  String get thisMonth {
    return Intl.message('This Month', name: 'thisMonth', desc: '', args: []);
  }

  /// `This request type is not supported yet`
  String get thisRequestTypeIsNotSupportedYet {
    return Intl.message(
      'This request type is not supported yet',
      name: 'thisRequestTypeIsNotSupportedYet',
      desc: '',
      args: [],
    );
  }

  /// `This Week`
  String get thisWeek {
    return Intl.message('This Week', name: 'thisWeek', desc: '', args: []);
  }

  /// `Thursday`
  String get thursday {
    return Intl.message('Thursday', name: 'thursday', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `timeMinutes`
  String get timeminutes {
    return Intl.message('timeMinutes', name: 'timeminutes', desc: '', args: []);
  }

  /// `Time Tracker`
  String get timeTracker {
    return Intl.message(
      'Time Tracker',
      name: 'timeTracker',
      desc: '',
      args: [],
    );
  }

  /// `Time Unit`
  String get timeUnit {
    return Intl.message('Time Unit', name: 'timeUnit', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Title In Arabic`
  String get titleInArabic {
    return Intl.message(
      'Title In Arabic',
      name: 'titleInArabic',
      desc: '',
      args: [],
    );
  }

  /// `Title Name`
  String get titleName {
    return Intl.message('Title Name', name: 'titleName', desc: '', args: []);
  }

  /// `Title is required.`
  String get titleRequired {
    return Intl.message(
      'Title is required.',
      name: 'titleRequired',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Togolese`
  String get togolese {
    return Intl.message('Togolese', name: 'togolese', desc: '', args: []);
  }

  /// `Tongan`
  String get tongan {
    return Intl.message('Tongan', name: 'tongan', desc: '', args: []);
  }

  /// `Top`
  String get top {
    return Intl.message('Top', name: 'top', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Total: `
  String get total2 {
    return Intl.message('Total: ', name: 'total2', desc: '', args: []);
  }

  /// `Total Owning Departments`
  String get totalOwningDepartments {
    return Intl.message(
      'Total Owning Departments',
      name: 'totalOwningDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Total Modules`
  String get total_modules {
    return Intl.message(
      'Total Modules',
      name: 'total_modules',
      desc: '',
      args: [],
    );
  }

  /// `Total Absent`
  String get totalAbsent {
    return Intl.message(
      'Total Absent',
      name: 'totalAbsent',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Total Assigned Tasks`
  String get totalAssignedTasks {
    return Intl.message(
      'Total Assigned Tasks',
      name: 'totalAssignedTasks',
      desc: '',
      args: [],
    );
  }

  /// `Total Due`
  String get totalDue {
    return Intl.message('Total Due', name: 'totalDue', desc: '', args: []);
  }

  /// `Total Damaged`
  String get totalDamaged {
    return Intl.message(
      'Total Damaged',
      name: 'totalDamaged',
      desc: '',
      args: [],
    );
  }

  /// `Total Departments`
  String get totalDepartments {
    return Intl.message(
      'Total Departments',
      name: 'totalDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Total Employees`
  String get totalEmployees {
    return Intl.message(
      'Total Employees',
      name: 'totalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Total Errors`
  String get totalErrors {
    return Intl.message(
      'Total Errors',
      name: 'totalErrors',
      desc: '',
      args: [],
    );
  }

  /// `Total Hours`
  String get TotalHours {
    return Intl.message('Total Hours', name: 'TotalHours', desc: '', args: []);
  }

  /// `Total Hours`
  String get totalHours {
    return Intl.message('Total Hours', name: 'totalHours', desc: '', args: []);
  }

  /// `Total HT`
  String get totalHT {
    return Intl.message('Total HT', name: 'totalHT', desc: '', args: []);
  }

  /// `Total Late`
  String get totalLate {
    return Intl.message('Total Late', name: 'totalLate', desc: '', args: []);
  }

  /// `Total Missing`
  String get totalMissing {
    return Intl.message(
      'Total Missing',
      name: 'totalMissing',
      desc: '',
      args: [],
    );
  }

  /// `Total Modules`
  String get totalModules {
    return Intl.message(
      'Total Modules',
      name: 'totalModules',
      desc: '',
      args: [],
    );
  }

  /// `Total Picked Files`
  String get totalPickedFiles {
    return Intl.message(
      'Total Picked Files',
      name: 'totalPickedFiles',
      desc: '',
      args: [],
    );
  }

  /// `Total Present`
  String get totalPresent {
    return Intl.message(
      'Total Present',
      name: 'totalPresent',
      desc: '',
      args: [],
    );
  }

  /// `Total Price`
  String get totalPrice {
    return Intl.message('Total Price', name: 'totalPrice', desc: '', args: []);
  }

  /// `Total Product`
  String get totalProduct {
    return Intl.message(
      'Total Product',
      name: 'totalProduct',
      desc: '',
      args: [],
    );
  }

  /// `Total Response: `
  String get totalResponse {
    return Intl.message(
      'Total Response: ',
      name: 'totalResponse',
      desc: '',
      args: [],
    );
  }

  /// `Total Roles`
  String get totalRoles {
    return Intl.message('Total Roles', name: 'totalRoles', desc: '', args: []);
  }

  /// `Total Salon`
  String get totalSalon {
    return Intl.message('Total Salon', name: 'totalSalon', desc: '', args: []);
  }

  /// `Make a change before continuing`
  String get makeAChangeBeforeContinuing {
    return Intl.message(
      'Make a change before continuing',
      name: 'makeAChangeBeforeContinuing',
      desc: '',
      args: [],
    );
  }

  /// `Total Policies`
  String get totalPolicies {
    return Intl.message(
      'Total Policies',
      name: 'totalPolicies',
      desc: '',
      args: [],
    );
  }

  /// `Total Services`
  String get totalServices {
    return Intl.message(
      'Total Services',
      name: 'totalServices',
      desc: '',
      args: [],
    );
  }

  /// `Total Time`
  String get totalTime {
    return Intl.message('Total Time', name: 'totalTime', desc: '', args: []);
  }

  /// `Total VAT`
  String get totalVAT {
    return Intl.message('Total VAT', name: 'totalVAT', desc: '', args: []);
  }

  /// `Total Weight`
  String get totalWeight {
    return Intl.message(
      'Total Weight',
      name: 'totalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Total Weight Should be`
  String get totalWeightShouldBe {
    return Intl.message(
      'Total Weight Should be',
      name: 'totalWeightShouldBe',
      desc: '',
      args: [],
    );
  }

  /// `Total weight should be 100`
  String get totalWeightShouldBe100 {
    return Intl.message(
      'Total weight should be 100',
      name: 'totalWeightShouldBe100',
      desc: '',
      args: [],
    );
  }

  /// `To Which Types Of Requests Does This Apply`
  String get toWhichTypesOfRequestsDoesThisApply {
    return Intl.message(
      'To Which Types Of Requests Does This Apply',
      name: 'toWhichTypesOfRequestsDoesThisApply',
      desc: '',
      args: [],
    );
  }

  /// `Tracker`
  String get tracker {
    return Intl.message('Tracker', name: 'tracker', desc: '', args: []);
  }

  /// `Tracker - Overall`
  String get trackerOverall {
    return Intl.message(
      'Tracker - Overall',
      name: 'trackerOverall',
      desc: '',
      args: [],
    );
  }

  /// `TrackerPageResponsivePageRefactor`
  String get trackerpageresponsivepagerefactor {
    return Intl.message(
      'TrackerPageResponsivePageRefactor',
      name: 'trackerpageresponsivepagerefactor',
      desc: '',
      args: [],
    );
  }

  /// `Tracking`
  String get tracking {
    return Intl.message('Tracking', name: 'tracking', desc: '', args: []);
  }

  /// `Tracking Time`
  String get trackingTime {
    return Intl.message(
      'Tracking Time',
      name: 'trackingTime',
      desc: '',
      args: [],
    );
  }

  /// `Transaction`
  String get transaction {
    return Intl.message('Transaction', name: 'transaction', desc: '', args: []);
  }

  /// `Transaction Created`
  String get transactionCreated {
    return Intl.message(
      'Transaction Created',
      name: 'transactionCreated',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Description`
  String get transactionDescription {
    return Intl.message(
      'Transaction Description',
      name: 'transactionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Document`
  String get transactionDocument {
    return Intl.message(
      'Transaction Document',
      name: 'transactionDocument',
      desc: '',
      args: [],
    );
  }

  /// `Trinidadian or Tobagonian`
  String get trinidadianOrTobagonian {
    return Intl.message(
      'Trinidadian or Tobagonian',
      name: 'trinidadianOrTobagonian',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday', desc: '', args: []);
  }

  /// `Tunisian`
  String get tunisian {
    return Intl.message('Tunisian', name: 'tunisian', desc: '', args: []);
  }

  /// `Turkish`
  String get turkish {
    return Intl.message('Turkish', name: 'turkish', desc: '', args: []);
  }

  /// `You must turn off all notification switches before unchecking this option.`
  String get TurnOffAllNotificationSwitches {
    return Intl.message(
      'You must turn off all notification switches before unchecking this option.',
      name: 'TurnOffAllNotificationSwitches',
      desc: '',
      args: [],
    );
  }

  /// `Tuvaluan`
  String get tuvaluan {
    return Intl.message('Tuvaluan', name: 'tuvaluan', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Type here`
  String get typeHere {
    return Intl.message('Type here', name: 'typeHere', desc: '', args: []);
  }

  /// `Type of Asset Request`
  String get typeOfAssetRequest {
    return Intl.message(
      'Type of Asset Request',
      name: 'typeOfAssetRequest',
      desc: '',
      args: [],
    );
  }

  /// `Type your Message...`
  String get typeYourMessage {
    return Intl.message(
      'Type your Message...',
      name: 'typeYourMessage',
      desc: '',
      args: [],
    );
  }

  /// `Typing...`
  String get typing {
    return Intl.message('Typing...', name: 'typing', desc: '', args: []);
  }

  /// `Ugandan`
  String get ugandan {
    return Intl.message('Ugandan', name: 'ugandan', desc: '', args: []);
  }

  /// `Ukrainian`
  String get ukrainian {
    return Intl.message('Ukrainian', name: 'ukrainian', desc: '', args: []);
  }

  /// `Unable to read the selected file`
  String get unableToReadTheSelectedFile {
    return Intl.message(
      'Unable to read the selected file',
      name: 'unableToReadTheSelectedFile',
      desc: '',
      args: [],
    );
  }

  /// `UnAggregated`
  String get unaggregated {
    return Intl.message(
      'UnAggregated',
      name: 'unaggregated',
      desc: '',
      args: [],
    );
  }

  /// `Unassigned`
  String get unassigned {
    return Intl.message('Unassigned', name: 'unassigned', desc: '', args: []);
  }

  /// `Under Maintenance`
  String get underMaintenance {
    return Intl.message(
      'Under Maintenance',
      name: 'underMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Under Repair`
  String get underRepair {
    return Intl.message(
      'Under Repair',
      name: 'underRepair',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get underReview {
    return Intl.message(
      'Under Review',
      name: 'underReview',
      desc: '',
      args: [],
    );
  }

  /// `Unique Services`
  String get uniqueServices {
    return Intl.message(
      'Unique Services',
      name: 'uniqueServices',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unit {
    return Intl.message('Unit', name: 'unit', desc: '', args: []);
  }

  /// `Hours`
  String get unit_hour {
    return Intl.message('Hours', name: 'unit_hour', desc: '', args: []);
  }

  /// `Minutes`
  String get unit_minute {
    return Intl.message('Minutes', name: 'unit_minute', desc: '', args: []);
  }

  /// `Seconds`
  String get unit_second {
    return Intl.message('Seconds', name: 'unit_second', desc: '', args: []);
  }

  /// `Weeks`
  String get unit_week {
    return Intl.message('Weeks', name: 'unit_week', desc: '', args: []);
  }

  /// `Bag`
  String get unitBag {
    return Intl.message('Bag', name: 'unitBag', desc: '', args: []);
  }

  /// `Bottle`
  String get unitBottle {
    return Intl.message('Bottle', name: 'unitBottle', desc: '', args: []);
  }

  /// `Box`
  String get unitBox {
    return Intl.message('Box', name: 'unitBox', desc: '', args: []);
  }

  /// `Centimeter`
  String get unitCentimeter {
    return Intl.message(
      'Centimeter',
      name: 'unitCentimeter',
      desc: '',
      args: [],
    );
  }

  /// `Unit Cost`
  String get unitCost {
    return Intl.message('Unit Cost', name: 'unitCost', desc: '', args: []);
  }

  /// `Gallon`
  String get unitGallon {
    return Intl.message('Gallon', name: 'unitGallon', desc: '', args: []);
  }

  /// `Gram`
  String get unitGram {
    return Intl.message('Gram', name: 'unitGram', desc: '', args: []);
  }

  /// `Inch`
  String get unitInch {
    return Intl.message('Inch', name: 'unitInch', desc: '', args: []);
  }

  /// `Kilogram`
  String get unitKilogram {
    return Intl.message('Kilogram', name: 'unitKilogram', desc: '', args: []);
  }

  /// `Kit`
  String get unitKit {
    return Intl.message('Kit', name: 'unitKit', desc: '', args: []);
  }

  /// `Liter`
  String get unitLiter {
    return Intl.message('Liter', name: 'unitLiter', desc: '', args: []);
  }

  /// `Meter`
  String get unitMeter {
    return Intl.message('Meter', name: 'unitMeter', desc: '', args: []);
  }

  /// `Milliliter`
  String get unitMilliliter {
    return Intl.message(
      'Milliliter',
      name: 'unitMilliliter',
      desc: '',
      args: [],
    );
  }

  /// `Unit Of Measurement`
  String get unitOfMeasurement {
    return Intl.message(
      'Unit Of Measurement',
      name: 'unitOfMeasurement',
      desc: '',
      args: [],
    );
  }

  /// `Ounce`
  String get unitOunce {
    return Intl.message('Ounce', name: 'unitOunce', desc: '', args: []);
  }

  /// `Pack`
  String get unitPack {
    return Intl.message('Pack', name: 'unitPack', desc: '', args: []);
  }

  /// `Piece`
  String get unitPiece {
    return Intl.message('Piece', name: 'unitPiece', desc: '', args: []);
  }

  /// `Pound`
  String get unitPound {
    return Intl.message('Pound', name: 'unitPound', desc: '', args: []);
  }

  /// `Unit Price`
  String get unitPrice {
    return Intl.message('Unit Price', name: 'unitPrice', desc: '', args: []);
  }

  /// `Reel`
  String get unitReel {
    return Intl.message('Reel', name: 'unitReel', desc: '', args: []);
  }

  /// `Unit is required`
  String get unitRequired {
    return Intl.message(
      'Unit is required',
      name: 'unitRequired',
      desc: '',
      args: [],
    );
  }

  /// `Units`
  String get units {
    return Intl.message('Units', name: 'units', desc: '', args: []);
  }

  /// `Set`
  String get unitSet {
    return Intl.message('Set', name: 'unitSet', desc: '', args: []);
  }

  /// `Ton`
  String get unitTon {
    return Intl.message('Ton', name: 'unitTon', desc: '', args: []);
  }

  /// `Unit`
  String get unitUnit {
    return Intl.message('Unit', name: 'unitUnit', desc: '', args: []);
  }

  /// `University or Institute`
  String get universityOrInstitute {
    return Intl.message(
      'University or Institute',
      name: 'universityOrInstitute',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Unknown columns`
  String get unknownColumns {
    return Intl.message(
      'Unknown columns',
      name: 'unknownColumns',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Group`
  String get unknownGroup {
    return Intl.message(
      'Unknown Group',
      name: 'unknownGroup',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Account`
  String get unlockAccount {
    return Intl.message(
      'Unlock Account',
      name: 'unlockAccount',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Request Submitted`
  String get unlockRequestSubmitted {
    return Intl.message(
      'Unlock Request Submitted',
      name: 'unlockRequestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Unlock User Account`
  String get unlockUserAccount {
    return Intl.message(
      'Unlock User Account',
      name: 'unlockUserAccount',
      desc: '',
      args: [],
    );
  }

  /// `UnPin`
  String get unpin {
    return Intl.message('UnPin', name: 'unpin', desc: '', args: []);
  }

  /// `Unpinned successfully`
  String get unpinnedSuccessfully {
    return Intl.message(
      'Unpinned successfully',
      name: 'unpinnedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `UnStar`
  String get unStar {
    return Intl.message('UnStar', name: 'unStar', desc: '', args: []);
  }

  /// `Unsuccessful`
  String get unsuccessful {
    return Intl.message(
      'Unsuccessful',
      name: 'unsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Un Successful`
  String get unSuccessful {
    return Intl.message(
      'Un Successful',
      name: 'unSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported Characters in Passport Number`
  String get unsupportedCharactersInPassportNumber {
    return Intl.message(
      'Unsupported Characters in Passport Number',
      name: 'unsupportedCharactersInPassportNumber',
      desc: '',
      args: [],
    );
  }

  /// `UnTabulated`
  String get untabulated {
    return Intl.message('UnTabulated', name: 'untabulated', desc: '', args: []);
  }

  /// `Untitled`
  String get untitled {
    return Intl.message('Untitled', name: 'untitled', desc: '', args: []);
  }

  /// `Untitled Task`
  String get untitledTask {
    return Intl.message(
      'Untitled Task',
      name: 'untitledTask',
      desc: '',
      args: [],
    );
  }

  /// `Up Comings`
  String get upComings {
    return Intl.message('Up Comings', name: 'upComings', desc: '', args: []);
  }

  /// `Upcoming Schedule`
  String get upcomingSchedule {
    return Intl.message(
      'Upcoming Schedule',
      name: 'upcomingSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Update Social Information`
  String get updateSocialInformation {
    return Intl.message(
      'Update Social Information',
      name: 'updateSocialInformation',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Upload Attachment`
  String get uploadAttachment {
    return Intl.message(
      'Upload Attachment',
      name: 'uploadAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Upload Control Document (Arabic)`
  String get uploadControlDocumentArabic {
    return Intl.message(
      'Upload Control Document (Arabic)',
      name: 'uploadControlDocumentArabic',
      desc: '',
      args: [],
    );
  }

  /// `Upload Control Document (English)`
  String get uploadControlDocumentEnglish {
    return Intl.message(
      'Upload Control Document (English)',
      name: 'uploadControlDocumentEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Upload Document`
  String get uploadDocument {
    return Intl.message(
      'Upload Document',
      name: 'uploadDocument',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded date`
  String get uploaded_date {
    return Intl.message(
      'Uploaded date',
      name: 'uploaded_date',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Date`
  String get uploadedDate {
    return Intl.message(
      'Uploaded Date',
      name: 'uploadedDate',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Documents`
  String get uploadedDocuments {
    return Intl.message(
      'Uploaded Documents',
      name: 'uploadedDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded On`
  String get uploadedOn {
    return Intl.message('Uploaded On', name: 'uploadedOn', desc: '', args: []);
  }

  /// `There was an error uploading your supplier data. Please try again.`
  String get uploadErrorMessage {
    return Intl.message(
      'There was an error uploading your supplier data. Please try again.',
      name: 'uploadErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Upload Evidence`
  String get uploadEvidence {
    return Intl.message(
      'Upload Evidence',
      name: 'uploadEvidence',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed`
  String get uploadFailed {
    return Intl.message(
      'Upload failed',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message('Uploading...', name: 'uploading', desc: '', args: []);
  }

  /// `Uploading attachments...`
  String get uploadingAttachments {
    return Intl.message(
      'Uploading attachments...',
      name: 'uploadingAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Uploading documents...`
  String get uploadingDocuments {
    return Intl.message(
      'Uploading documents...',
      name: 'uploadingDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Uploading images...`
  String get uploadingImages {
    return Intl.message(
      'Uploading images...',
      name: 'uploadingImages',
      desc: '',
      args: [],
    );
  }

  /// `Uploading registration documents...`
  String get uploadingRegistrationDocuments {
    return Intl.message(
      'Uploading registration documents...',
      name: 'uploadingRegistrationDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Supplier`
  String get uploadingSupplier {
    return Intl.message(
      'Uploading Supplier',
      name: 'uploadingSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Upload Policy Document (Arabic)`
  String get uploadPolicyDocumentArabic {
    return Intl.message(
      'Upload Policy Document (Arabic)',
      name: 'uploadPolicyDocumentArabic',
      desc: '',
      args: [],
    );
  }

  /// `Upload Policy Document (English)`
  String get uploadPolicyDocumentEnglish {
    return Intl.message(
      'Upload Policy Document (English)',
      name: 'uploadPolicyDocumentEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Upload successful`
  String get uploadSuccess {
    return Intl.message(
      'Upload successful',
      name: 'uploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Uruguayan`
  String get uruguayan {
    return Intl.message('Uruguayan', name: 'uruguayan', desc: '', args: []);
  }

  /// `Usage Frequency`
  String get usageFrequency {
    return Intl.message(
      'Usage Frequency',
      name: 'usageFrequency',
      desc: '',
      args: [],
    );
  }

  /// `USD`
  String get uSD {
    return Intl.message('USD', name: 'uSD', desc: '', args: []);
  }

  /// `User Access`
  String get userAccess {
    return Intl.message('User Access', name: 'userAccess', desc: '', args: []);
  }

  /// `User Access Details`
  String get userAccessDetails {
    return Intl.message(
      'User Access Details',
      name: 'userAccessDetails',
      desc: '',
      args: [],
    );
  }

  /// `User Access Module`
  String get userAccessModule {
    return Intl.message(
      'User Access Module',
      name: 'userAccessModule',
      desc: '',
      args: [],
    );
  }

  /// `User access has been successfully updated`
  String get userAccessUpdatedSuccessfully {
    return Intl.message(
      'User access has been successfully updated',
      name: 'userAccessUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `User email not found`
  String get userEmailNotFound {
    return Intl.message(
      'User email not found',
      name: 'userEmailNotFound',
      desc: '',
      args: [],
    );
  }

  /// `User Management`
  String get userManagement {
    return Intl.message(
      'User Management',
      name: 'userManagement',
      desc: '',
      args: [],
    );
  }

  /// `User Management Requests`
  String get userManagementRequests {
    return Intl.message(
      'User Management Requests',
      name: 'userManagementRequests',
      desc: '',
      args: [],
    );
  }

  /// `User Management Module`
  String get userManagementModule {
    return Intl.message(
      'User Management Module',
      name: 'userManagementModule',
      desc: '',
      args: [],
    );
  }

  /// `Users Data`
  String get usersData {
    return Intl.message('Users Data', name: 'usersData', desc: '', args: []);
  }

  /// `Users`
  String get usersPermission {
    return Intl.message('Users', name: 'usersPermission', desc: '', args: []);
  }

  /// `Users Requests`
  String get usersRequests {
    return Intl.message(
      'Users Requests',
      name: 'usersRequests',
      desc: '',
      args: [],
    );
  }

  /// `Uzbekistani`
  String get uzbekistani {
    return Intl.message('Uzbekistani', name: 'uzbekistani', desc: '', args: []);
  }

  /// `Vacation`
  String get vacation {
    return Intl.message('Vacation', name: 'vacation', desc: '', args: []);
  }

  /// `Vacation Credits`
  String get vacationCredits {
    return Intl.message(
      'Vacation Credits',
      name: 'vacationCredits',
      desc: '',
      args: [],
    );
  }

  /// `Vacations Credit`
  String get vacationsCredit {
    return Intl.message(
      'Vacations Credit',
      name: 'vacationsCredit',
      desc: '',
      args: [],
    );
  }

  /// `Validation Error`
  String get validationError {
    return Intl.message(
      'Validation Error',
      name: 'validationError',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get validEmailRequired {
    return Intl.message(
      'Please enter a valid email',
      name: 'validEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Valid Order ID`
  String get validOrderId {
    return Intl.message(
      'Valid Order ID',
      name: 'validOrderId',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid storage capacity (greater than 0)`
  String get validStorageCapacityRequired {
    return Intl.message(
      'Please enter a valid storage capacity (greater than 0)',
      name: 'validStorageCapacityRequired',
      desc: '',
      args: [],
    );
  }

  /// `VAT`
  String get vat {
    return Intl.message('VAT', name: 'vat', desc: '', args: []);
  }

  /// `Venezuelan`
  String get venezuelan {
    return Intl.message('Venezuelan', name: 'venezuelan', desc: '', args: []);
  }

  /// `Version:`
  String get version {
    return Intl.message('Version:', name: 'version', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Video Recording`
  String get video_recording {
    return Intl.message(
      'Video Recording',
      name: 'video_recording',
      desc: '',
      args: [],
    );
  }

  /// `Vietnamese`
  String get vietnamese {
    return Intl.message('Vietnamese', name: 'vietnamese', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `View Access`
  String get viewAccess {
    return Intl.message('View Access', name: 'viewAccess', desc: '', args: []);
  }

  /// `View Accounts`
  String get viewAccounts {
    return Intl.message(
      'View Accounts',
      name: 'viewAccounts',
      desc: '',
      args: [],
    );
  }

  /// `View Activities`
  String get viewActivities {
    return Intl.message(
      'View Activities',
      name: 'viewActivities',
      desc: '',
      args: [],
    );
  }

  /// `View Attendance Reports`
  String get viewAttendanceReports {
    return Intl.message(
      'View Attendance Reports',
      name: 'viewAttendanceReports',
      desc: '',
      args: [],
    );
  }

  /// `View Contact`
  String get viewContact {
    return Intl.message(
      'View Contact',
      name: 'viewContact',
      desc: '',
      args: [],
    );
  }

  /// `View Contacts`
  String get viewContacts {
    return Intl.message(
      'View Contacts',
      name: 'viewContacts',
      desc: '',
      args: [],
    );
  }

  /// `View CRM Reports`
  String get viewCRMReports {
    return Intl.message(
      'View CRM Reports',
      name: 'viewCRMReports',
      desc: '',
      args: [],
    );
  }

  /// `View Dashboard`
  String get viewDashboard {
    return Intl.message(
      'View Dashboard',
      name: 'viewDashboard',
      desc: '',
      args: [],
    );
  }

  /// `View Deals`
  String get viewDeals {
    return Intl.message('View Deals', name: 'viewDeals', desc: '', args: []);
  }

  /// `View Documents`
  String get viewDocuments {
    return Intl.message(
      'View Documents',
      name: 'viewDocuments',
      desc: '',
      args: [],
    );
  }

  /// `View Draft Form`
  String get viewDraftForm {
    return Intl.message(
      'View Draft Form',
      name: 'viewDraftForm',
      desc: '',
      args: [],
    );
  }

  /// `View Employee Records`
  String get viewEmployeeRecords {
    return Intl.message(
      'View Employee Records',
      name: 'viewEmployeeRecords',
      desc: '',
      args: [],
    );
  }

  /// `View Group`
  String get viewGroup {
    return Intl.message('View Group', name: 'viewGroup', desc: '', args: []);
  }

  /// `View HR Analytics`
  String get viewHRAnalytics {
    return Intl.message(
      'View HR Analytics',
      name: 'viewHRAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `View Leads`
  String get viewLeads {
    return Intl.message('View Leads', name: 'viewLeads', desc: '', args: []);
  }

  /// `View Only`
  String get viewOnly {
    return Intl.message('View Only', name: 'viewOnly', desc: '', args: []);
  }

  /// `View Payroll Reports`
  String get viewPayrollReports {
    return Intl.message(
      'View Payroll Reports',
      name: 'viewPayrollReports',
      desc: '',
      args: [],
    );
  }

  /// `View Performance Reviews`
  String get viewPerformanceReviews {
    return Intl.message(
      'View Performance Reviews',
      name: 'viewPerformanceReviews',
      desc: '',
      args: [],
    );
  }

  /// `View Pipeline`
  String get viewPipeline {
    return Intl.message(
      'View Pipeline',
      name: 'viewPipeline',
      desc: '',
      args: [],
    );
  }

  /// `View Requested Form`
  String get viewRequestedForm {
    return Intl.message(
      'View Requested Form',
      name: 'viewRequestedForm',
      desc: '',
      args: [],
    );
  }

  /// `View Requesters`
  String get viewRequesters {
    return Intl.message(
      'View Requesters',
      name: 'viewRequesters',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  /// `View Storage Locations`
  String get viewStorageLocations {
    return Intl.message(
      'View Storage Locations',
      name: 'viewStorageLocations',
      desc: '',
      args: [],
    );
  }

  /// `View Submissions`
  String get viewSubmissions {
    return Intl.message(
      'View Submissions',
      name: 'viewSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `View Training Reports`
  String get viewTrainingReports {
    return Intl.message(
      'View Training Reports',
      name: 'viewTrainingReports',
      desc: '',
      args: [],
    );
  }

  /// `Volume`
  String get volume {
    return Intl.message('Volume', name: 'volume', desc: '', args: []);
  }

  /// `Warehouse`
  String get warehouse {
    return Intl.message('Warehouse', name: 'warehouse', desc: '', args: []);
  }

  /// `Ware House`
  String get wareHouse {
    return Intl.message('Ware House', name: 'wareHouse', desc: '', args: []);
  }

  /// `Warehouse Name`
  String get warehouseName {
    return Intl.message(
      'Warehouse Name',
      name: 'warehouseName',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: City is required`
  String get warehouseNumberCity {
    return Intl.message(
      'Warehouse {0}: City is required',
      name: 'warehouseNumberCity',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Country is required`
  String get warehouseNumberCountry {
    return Intl.message(
      'Warehouse {0}: Country is required',
      name: 'warehouseNumberCountry',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Postal Code is required`
  String get warehouseNumberPostalCode {
    return Intl.message(
      'Warehouse {0}: Postal Code is required',
      name: 'warehouseNumberPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse {0}: Street Name is required`
  String get warehouseNumberStreetName {
    return Intl.message(
      'Warehouse {0}: Street Name is required',
      name: 'warehouseNumberStreetName',
      desc: '',
      args: [],
    );
  }

  /// `Warehouses`
  String get warehouses {
    return Intl.message('Warehouses', name: 'warehouses', desc: '', args: []);
  }

  /// `Warehouses Details`
  String get warehousesDetails {
    return Intl.message(
      'Warehouses Details',
      name: 'warehousesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `Warning: Wrong Entry`
  String get warningWrongEntry {
    return Intl.message(
      'Warning: Wrong Entry',
      name: 'warningWrongEntry',
      desc: '',
      args: [],
    );
  }

  /// `Warranty`
  String get warranty {
    return Intl.message('Warranty', name: 'warranty', desc: '', args: []);
  }

  /// `Warranty & Coverage Status`
  String get warrantyCoverageStatus {
    return Intl.message(
      'Warranty & Coverage Status',
      name: 'warrantyCoverageStatus',
      desc: '',
      args: [],
    );
  }

  /// `Warranty Expiration Date`
  String get warrantyExpirationDate {
    return Intl.message(
      'Warranty Expiration Date',
      name: 'warrantyExpirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Watermark`
  String get watermark {
    return Intl.message('Watermark', name: 'watermark', desc: '', args: []);
  }

  /// `Watermark Content`
  String get watermarkContent {
    return Intl.message(
      'Watermark Content',
      name: 'watermarkContent',
      desc: '',
      args: [],
    );
  }

  /// `Turn the watermark off? It will stop appearing over the app's pages.`
  String get watermarkDisableConfirm {
    return Intl.message(
      'Turn the watermark off? It will stop appearing over the app\'s pages.',
      name: 'watermarkDisableConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The watermark is now off.`
  String get watermarkDisabled {
    return Intl.message(
      'The watermark is now off.',
      name: 'watermarkDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Turn the watermark on? It will appear over the app's pages for everyone.`
  String get watermarkEnableConfirm {
    return Intl.message(
      'Turn the watermark on? It will appear over the app\'s pages for everyone.',
      name: 'watermarkEnableConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The watermark is now active.`
  String get watermarkEnabled {
    return Intl.message(
      'The watermark is now active.',
      name: 'watermarkEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Save the watermark settings?`
  String get watermarkSaveConfirm {
    return Intl.message(
      'Save the watermark settings?',
      name: 'watermarkSaveConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The watermark settings have been saved.`
  String get watermarkSaved {
    return Intl.message(
      'The watermark settings have been saved.',
      name: 'watermarkSaved',
      desc: '',
      args: [],
    );
  }

  /// `Watermark Style`
  String get watermarkStyle {
    return Intl.message(
      'Watermark Style',
      name: 'watermarkStyle',
      desc: '',
      args: [],
    );
  }

  /// `We'd love to hear more about your service`
  String get weDLoveToHearMoreAboutYourService {
    return Intl.message(
      'We\'d love to hear more about your service',
      name: 'weDLoveToHearMoreAboutYourService',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday', desc: '', args: []);
  }

  /// `Weeks`
  String get week {
    return Intl.message('Weeks', name: 'week', desc: '', args: []);
  }

  /// `Weekly`
  String get weekly {
    return Intl.message('Weekly', name: 'weekly', desc: '', args: []);
  }

  /// `Weeks`
  String get weeks {
    return Intl.message('Weeks', name: 'weeks', desc: '', args: []);
  }

  /// `Weeks Ago`
  String get weeksAgo {
    return Intl.message('Weeks Ago', name: 'weeksAgo', desc: '', args: []);
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Welcome to our app`
  String get welcome {
    return Intl.message(
      'Welcome to our app',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Welsh`
  String get welsh {
    return Intl.message('Welsh', name: 'welsh', desc: '', args: []);
  }

  /// `We value our customers and strive to exceed their expectations`
  String get weValueOurCustomersAndStriveToExceedTheirExpecta {
    return Intl.message(
      'We value our customers and strive to exceed their expectations',
      name: 'weValueOurCustomersAndStriveToExceedTheirExpecta',
      desc: '',
      args: [],
    );
  }

  /// `When Their Manager Approves The Service, If It Requires Approvals`
  String get whenManagerApprovesServiceIfRequired {
    return Intl.message(
      'When Their Manager Approves The Service, If It Requires Approvals',
      name: 'whenManagerApprovesServiceIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When Service Provider Breached SLA`
  String get whenProviderBreachedSla {
    return Intl.message(
      'When Service Provider Breached SLA',
      name: 'whenProviderBreachedSla',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By The Requester’s Manager \nIf It Requires Approval`
  String get WhenServiceIsRequestedAndApproved {
    return Intl.message(
      'When Service Is Requested And Approved By The Requester’s Manager \nIf It Requires Approval',
      name: 'WhenServiceIsRequestedAndApproved',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By \nThe Requester’s Manager If It Requires Approval`
  String get WhenServiceIsRequestedAndApprovedByTheRequester {
    return Intl.message(
      'When Service Is Requested And Approved By \nThe Requester’s Manager If It Requires Approval',
      name: 'WhenServiceIsRequestedAndApprovedByTheRequester',
      desc: '',
      args: [],
    );
  }

  /// `When Service Requested And Approved by Manager`
  String get WhenServiceRequestedAndApproved {
    return Intl.message(
      'When Service Requested And Approved by Manager',
      name: 'WhenServiceRequestedAndApproved',
      desc: '',
      args: [],
    );
  }

  /// `When Service Is Requested And Approved By The Requester’s Manager If It Requires Approval`
  String get whenServiceRequestedAndApprovedIfRequired {
    return Intl.message(
      'When Service Is Requested And Approved By The Requester’s Manager If It Requires Approval',
      name: 'whenServiceRequestedAndApprovedIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When Service SLA Is About To Be Breached By`
  String get whenServiceSlaIsAboutToBeBreached {
    return Intl.message(
      'When Service SLA Is About To Be Breached By',
      name: 'whenServiceSlaIsAboutToBeBreached',
      desc: '',
      args: [],
    );
  }

  /// `When Service SLA Is Breached`
  String get whenServiceSlaIsBreached {
    return Intl.message(
      'When Service SLA Is Breached',
      name: 'whenServiceSlaIsBreached',
      desc: '',
      args: [],
    );
  }

  /// `When Services Is Requested And Approved By The Requester’s Manager If It Requires Approval`
  String get whenServicesRequestedAndApprovedIfRequired {
    return Intl.message(
      'When Services Is Requested And Approved By The Requester’s Manager If It Requires Approval',
      name: 'whenServicesRequestedAndApprovedIfRequired',
      desc: '',
      args: [],
    );
  }

  /// `When Service Status Change`
  String get whenServiceStattusChanges {
    return Intl.message(
      'When Service Status Change',
      name: 'whenServiceStattusChanges',
      desc: '',
      args: [],
    );
  }

  /// `When Service Status Changes`
  String get whenServiceStatusChanges {
    return Intl.message(
      'When Service Status Changes',
      name: 'whenServiceStatusChanges',
      desc: '',
      args: [],
    );
  }

  /// `When SLA Is Breached`
  String get whenSlaIsBreached {
    return Intl.message(
      'When SLA Is Breached',
      name: 'whenSlaIsBreached',
      desc: '',
      args: [],
    );
  }

  /// `When Manager Approves The Service,If It Requires Approvals`
  String get WhenTheirManagerApprovesTheService {
    return Intl.message(
      'When Manager Approves The Service,If It Requires Approvals',
      name: 'WhenTheirManagerApprovesTheService',
      desc: '',
      args: [],
    );
  }

  /// `When They Receive A Comment From Service Requester`
  String get whenTheyReceiveCommentFromRequester {
    return Intl.message(
      'When They Receive A Comment From Service Requester',
      name: 'whenTheyReceiveCommentFromRequester',
      desc: '',
      args: [],
    );
  }

  /// `When They Receive A Comment From The Service Provider`
  String get whenTheyReceiveCommentFromServiceProvider {
    return Intl.message(
      'When They Receive A Comment From The Service Provider',
      name: 'whenTheyReceiveCommentFromServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Why`
  String get why {
    return Intl.message('Why', name: 'why', desc: '', args: []);
  }

  /// `Why you want to leave..?`
  String get whyYouWantToLeave {
    return Intl.message(
      'Why you want to leave..?',
      name: 'whyYouWantToLeave',
      desc: '',
      args: [],
    );
  }

  /// `Widget`
  String get widget {
    return Intl.message('Widget', name: 'widget', desc: '', args: []);
  }

  /// `Widowed`
  String get widowed {
    return Intl.message('Widowed', name: 'widowed', desc: '', args: []);
  }

  /// `Will Be Reactivated At`
  String get willBeReactivatedAt {
    return Intl.message(
      'Will Be Reactivated At',
      name: 'willBeReactivatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Will it be a new batch?`
  String get willItBeANewBatch {
    return Intl.message(
      'Will it be a new batch?',
      name: 'willItBeANewBatch',
      desc: '',
      args: [],
    );
  }

  /// `Working Hours`
  String get workingHours {
    return Intl.message(
      'Working Hours',
      name: 'workingHours',
      desc: '',
      args: [],
    );
  }

  /// `Work Location`
  String get workLocation {
    return Intl.message(
      'Work Location',
      name: 'workLocation',
      desc: '',
      args: [],
    );
  }

  /// `Work Performed/Service Actions`
  String get workPerformed {
    return Intl.message(
      'Work Performed/Service Actions',
      name: 'workPerformed',
      desc: '',
      args: [],
    );
  }

  /// `WorkShop`
  String get workshop {
    return Intl.message('WorkShop', name: 'workshop', desc: '', args: []);
  }

  /// `Workstations System`
  String get workstationsSystem {
    return Intl.message(
      'Workstations System',
      name: 'workstationsSystem',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get write_a_comment {
    return Intl.message(
      'Write a Comment',
      name: 'write_a_comment',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get WriteaComment {
    return Intl.message(
      'Write a Comment',
      name: 'WriteaComment',
      desc: '',
      args: [],
    );
  }

  /// `Write a comment`
  String get writeAComment {
    return Intl.message(
      'Write a comment',
      name: 'writeAComment',
      desc: '',
      args: [],
    );
  }

  /// `Write a description`
  String get writeADescription {
    return Intl.message(
      'Write a description',
      name: 'writeADescription',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get writeComment {
    return Intl.message(
      'Write a Comment',
      name: 'writeComment',
      desc: '',
      args: [],
    );
  }

  /// `Write-Off`
  String get writeOff {
    return Intl.message('Write-Off', name: 'writeOff', desc: '', args: []);
  }

  /// `Your check-out location does not match the company's designated location. Please check in from the correct location.`
  String get wrongCheckOutLocationMessage {
    return Intl.message(
      'Your check-out location does not match the company\'s designated location. Please check in from the correct location.',
      name: 'wrongCheckOutLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Location`
  String get wrongLocation {
    return Intl.message(
      'Wrong Location',
      name: 'wrongLocation',
      desc: '',
      args: [],
    );
  }

  /// `Your check-in location does not match the company's designated location. Please check in from the correct location.`
  String get wrongLocationMessage {
    return Intl.message(
      'Your check-in location does not match the company\'s designated location. Please check in from the correct location.',
      name: 'wrongLocationMessage',
      desc: '',
      args: [],
    );
  }

  /// `years`
  String get year {
    return Intl.message('years', name: 'year', desc: '', args: []);
  }

  /// `Yearly`
  String get yearly {
    return Intl.message('Yearly', name: 'yearly', desc: '', args: []);
  }

  /// `Years`
  String get years {
    return Intl.message('Years', name: 'years', desc: '', args: []);
  }

  /// `Years Ago`
  String get yearsAgo {
    return Intl.message('Years Ago', name: 'yearsAgo', desc: '', args: []);
  }

  /// `Yellow`
  String get yellow {
    return Intl.message('Yellow', name: 'yellow', desc: '', args: []);
  }

  /// `Yemenite`
  String get yemenite {
    return Intl.message('Yemenite', name: 'yemenite', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Yes`
  String get yesTitleButton {
    return Intl.message('Yes', name: 'yesTitleButton', desc: '', args: []);
  }

  /// `You`
  String get you {
    return Intl.message('You', name: 'you', desc: '', args: []);
  }

  /// `You,`
  String get you2 {
    return Intl.message('You,', name: 'you2', desc: '', args: []);
  }

  /// `You cannot add an option that already exists`
  String get youCannotAddAnOptionThatAlreadyExists {
    return Intl.message(
      'You cannot add an option that already exists',
      name: 'youCannotAddAnOptionThatAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `You deleted this message`
  String get youDeletedThisMessage {
    return Intl.message(
      'You deleted this message',
      name: 'youDeletedThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `You Grant Access Successfully`
  String get youGrantAccessSuccessfully {
    return Intl.message(
      'You Grant Access Successfully',
      name: 'youGrantAccessSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `You have already requested this asset`
  String get youHaveAlreadyRequestedThisAsset {
    return Intl.message(
      'You have already requested this asset',
      name: 'youHaveAlreadyRequestedThisAsset',
      desc: '',
      args: [],
    );
  }

  /// `You haven't made any changes to submit`
  String get youHavenTMadeAnyChangesToSubmit {
    return Intl.message(
      'You haven\'t made any changes to submit',
      name: 'youHavenTMadeAnyChangesToSubmit',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully edited controls weights`
  String get youHaveSuccessfullyEditedControlsWeights {
    return Intl.message(
      'You have successfully edited controls weights',
      name: 'youHaveSuccessfullyEditedControlsWeights',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully edited policies weights`
  String get youHaveSuccessfullyEditedPoliciesWeights {
    return Intl.message(
      'You have successfully edited policies weights',
      name: 'youHaveSuccessfullyEditedPoliciesWeights',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully assigned equal weight for all controls`
  String get youHaveSuccessfullyEqualWeightForAllControls {
    return Intl.message(
      'You have successfully assigned equal weight for all controls',
      name: 'youHaveSuccessfullyEqualWeightForAllControls',
      desc: '',
      args: [],
    );
  }

  /// `You have unsaved changes. Do you want to save them?`
  String get youHaveUnsavedChangesDoYouWantToSaveThem {
    return Intl.message(
      'You have unsaved changes. Do you want to save them?',
      name: 'youHaveUnsavedChangesDoYouWantToSaveThem',
      desc: '',
      args: [],
    );
  }

  /// `You must correct all errors before uploading`
  String get youMustCorrectAllErrorsBeforeUploading {
    return Intl.message(
      'You must correct all errors before uploading',
      name: 'youMustCorrectAllErrorsBeforeUploading',
      desc: '',
      args: [],
    );
  }

  /// `You must solve these errors`
  String get youMustSolveTheseErrors {
    return Intl.message(
      'You must solve these errors',
      name: 'youMustSolveTheseErrors',
      desc: '',
      args: [],
    );
  }

  /// `Your draft was saved successfully`
  String get yourDraftWasSaved {
    return Intl.message(
      'Your draft was saved successfully',
      name: 'yourDraftWasSaved',
      desc: '',
      args: [],
    );
  }

  /// `Your evidence was submitted successfully`
  String get yourEvidenceWasSubmittedSuccessfully {
    return Intl.message(
      'Your evidence was submitted successfully',
      name: 'yourEvidenceWasSubmittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Your reassign champion request has been submitted`
  String get yourReassignChampionRequestHasBeenSubmitted {
    return Intl.message(
      'Your reassign champion request has been submitted',
      name: 'yourReassignChampionRequestHasBeenSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your reassign owner request has been submitted`
  String get yourReassignOwnerRequestHasBeenSubmitted {
    return Intl.message(
      'Your reassign owner request has been submitted',
      name: 'yourReassignOwnerRequestHasBeenSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Activated These Services`
  String get youSuccessfullyActivatedTheseServices {
    return Intl.message(
      'You Successfully Activated These Services',
      name: 'youSuccessfullyActivatedTheseServices',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this control champion`
  String get youSuccessfullyAddedThisControlChampion {
    return Intl.message(
      'You successfully added this control champion',
      name: 'youSuccessfullyAddedThisControlChampion',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this control owner`
  String get youSuccessfullyAddedThisControlOwner {
    return Intl.message(
      'You successfully added this control owner',
      name: 'youSuccessfullyAddedThisControlOwner',
      desc: '',
      args: [],
    );
  }

  /// `You successfully added this product`
  String get youSuccessfullyAddedThisProduct {
    return Intl.message(
      'You successfully added this product',
      name: 'youSuccessfullyAddedThisProduct',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this evidence`
  String get youSuccessfullyApprovedThisEvidence {
    return Intl.message(
      'You successfully approved this evidence',
      name: 'youSuccessfullyApprovedThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this request`
  String get YouSuccessfullyApprovedThisRequest {
    return Intl.message(
      'You successfully approved this request',
      name: 'YouSuccessfullyApprovedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully approved this request`
  String get youSuccessfullyApprovedThisRequest {
    return Intl.message(
      'You successfully approved this request',
      name: 'youSuccessfullyApprovedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully canceled this request`
  String get YouSuccessfullyCanceledThisRequest {
    return Intl.message(
      'You successfully canceled this request',
      name: 'YouSuccessfullyCanceledThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Cleaned All Notification`
  String get youSuccessfullyCleanedAllNotification {
    return Intl.message(
      'You Successfully Cleaned All Notification',
      name: 'youSuccessfullyCleanedAllNotification',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Completed This Request`
  String get YouSuccessfullyCompletedThisRequest {
    return Intl.message(
      'You Successfully Completed This Request',
      name: 'YouSuccessfullyCompletedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Group`
  String get youSuccessfullyCreatedGroup {
    return Intl.message(
      'You Successfully Created This Group',
      name: 'youSuccessfullyCreatedGroup',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this control`
  String get youSuccessfullyCreatedThisControl {
    return Intl.message(
      'You successfully created this control',
      name: 'youSuccessfullyCreatedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Form`
  String get youSuccessfullyCreatedThisForm {
    return Intl.message(
      'You Successfully Created This Form',
      name: 'youSuccessfullyCreatedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this GRC policy`
  String get youSuccessfullyCreatedThisGrcPolicy {
    return Intl.message(
      'You successfully created this GRC policy',
      name: 'youSuccessfullyCreatedThisGrcPolicy',
      desc: '',
      args: [],
    );
  }

  /// `You successfully created this policy`
  String get youSuccessfullyCreatedThisPolicy {
    return Intl.message(
      'You successfully created this policy',
      name: 'youSuccessfullyCreatedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Service`
  String get YouSuccessfullyCreatedThisService {
    return Intl.message(
      'You Successfully Created This Service',
      name: 'YouSuccessfullyCreatedThisService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Create Policy`
  String get youSuccessfullyCreatePolicy {
    return Intl.message(
      'You Successfully Create Policy',
      name: 'youSuccessfullyCreatePolicy',
      desc: '',
      args: [],
    );
  }

  /// `You successfully deleted all cleared notifications.`
  String get youSuccessfullyDeletedAllNotifications {
    return Intl.message(
      'You successfully deleted all cleared notifications.',
      name: 'youSuccessfullyDeletedAllNotifications',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Group`
  String get youSuccessfullyDeletedGroup {
    return Intl.message(
      'You Successfully Deleted This Group',
      name: 'youSuccessfullyDeletedGroup',
      desc: '',
      args: [],
    );
  }

  /// `You successfully deleted this control`
  String get youSuccessfullyDeletedThisControl {
    return Intl.message(
      'You successfully deleted this control',
      name: 'youSuccessfullyDeletedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You successfully deleted this policy`
  String get youSuccessfullyDeletedThisPolicy {
    return Intl.message(
      'You successfully deleted this policy',
      name: 'youSuccessfullyDeletedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Form`
  String get youSuccessfullyDeletedThisForm {
    return Intl.message(
      'You Successfully Deleted This Form',
      name: 'youSuccessfullyDeletedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Downloaded This Form as Excel`
  String get youSuccessfullyDownloadedThisFormAsExcel {
    return Intl.message(
      'You Successfully Downloaded This Form as Excel',
      name: 'youSuccessfullyDownloadedThisFormAsExcel',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Downloaded This Form as PDF`
  String get youSuccessfullyDownloadedThisFormAsPdf {
    return Intl.message(
      'You Successfully Downloaded This Form as PDF',
      name: 'youSuccessfullyDownloadedThisFormAsPdf',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Drafted This Form`
  String get youSuccessfullyDraftedThisForm {
    return Intl.message(
      'You Successfully Drafted This Form',
      name: 'youSuccessfullyDraftedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Duplicated This Form`
  String get youSuccessfullyDuplicatedThisForm {
    return Intl.message(
      'You Successfully Duplicated This Form',
      name: 'youSuccessfullyDuplicatedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Group`
  String get youSuccessfullyEditedGroup {
    return Intl.message(
      'You Successfully Edited This Group',
      name: 'youSuccessfullyEditedGroup',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Form`
  String get youSuccessfullyEditedThisForm {
    return Intl.message(
      'You Successfully Edited This Form',
      name: 'youSuccessfullyEditedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Service`
  String get YouSuccessfullyEditedThisService {
    return Intl.message(
      'You Successfully Edited This Service',
      name: 'YouSuccessfullyEditedThisService',
      desc: '',
      args: [],
    );
  }

  /// `You successfully rejected this evidence`
  String get youSuccessfullyRejectedThisEvidence {
    return Intl.message(
      'You successfully rejected this evidence',
      name: 'youSuccessfullyRejectedThisEvidence',
      desc: '',
      args: [],
    );
  }

  /// `You successfully rejected this request`
  String get YouSuccessfullyRejectedThisRequest {
    return Intl.message(
      'You successfully rejected this request',
      name: 'YouSuccessfullyRejectedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You successfully rejected this request`
  String get youSuccessfullyRejectedThisRequest {
    return Intl.message(
      'You successfully rejected this request',
      name: 'youSuccessfullyRejectedThisRequest',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Removed Employee`
  String get youSuccessfullyRemovedEmployee {
    return Intl.message(
      'You Successfully Removed Employee',
      name: 'youSuccessfullyRemovedEmployee',
      desc: '',
      args: [],
    );
  }

  /// `You successfully requested this service`
  String get YouSuccessfullyRequestedThisService {
    return Intl.message(
      'You successfully requested this service',
      name: 'YouSuccessfullyRequestedThisService',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Restored This Form`
  String get youSuccessfullyRestoredThisForm {
    return Intl.message(
      'You Successfully Restored This Form',
      name: 'youSuccessfullyRestoredThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Form`
  String get youSuccessfullySubmittedThisForm {
    return Intl.message(
      'You Successfully Submitted This Form',
      name: 'youSuccessfullySubmittedThisForm',
      desc: '',
      args: [],
    );
  }

  /// `You successfully updated this control`
  String get youSuccessfullyUpdatedThisControl {
    return Intl.message(
      'You successfully updated this control',
      name: 'youSuccessfullyUpdatedThisControl',
      desc: '',
      args: [],
    );
  }

  /// `You successfully updated this policy`
  String get youSuccessfullyUpdatedThisPolicy {
    return Intl.message(
      'You successfully updated this policy',
      name: 'youSuccessfullyUpdatedThisPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Zambian`
  String get zambian {
    return Intl.message('Zambian', name: 'zambian', desc: '', args: []);
  }

  /// `Zimbabwean`
  String get zimbabwean {
    return Intl.message('Zimbabwean', name: 'zimbabwean', desc: '', args: []);
  }

  /// `Zip Code or Postal Code`
  String get zipCodeOrPostalCode {
    return Intl.message(
      'Zip Code or Postal Code',
      name: 'zipCodeOrPostalCode',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'JobTitle:' key

  /// `Permissions`
  String get Modules {
    return Intl.message('Permissions', name: 'Modules', desc: '', args: []);
  }

  // skipped getter for the 'approvalCycle:' key

  /// `Are you sure you want to delete this knowledge item?`
  String get areYouSureDeleteKnowledge_ar {
    return Intl.message(
      'Are you sure you want to delete this knowledge item?',
      name: 'areYouSureDeleteKnowledge_ar',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to edit this product?`
  String get areYouSureEditProduct_ar {
    return Intl.message(
      'Are you sure you want to edit this product?',
      name: 'areYouSureEditProduct_ar',
      desc: '',
      args: [],
    );
  }

  /// `Please complete all required fields before submitting`
  String get completeRequiredFieldsBeforeSubmitting_ar {
    return Intl.message(
      'Please complete all required fields before submitting',
      name: 'completeRequiredFieldsBeforeSubmitting_ar',
      desc: '',
      args: [],
    );
  }

  /// `Created Date Range`
  String get createdDateRange_ar {
    return Intl.message(
      'Created Date Range',
      name: 'createdDateRange_ar',
      desc: '',
      args: [],
    );
  }

  /// `Editing Product Details`
  String get editingProductDetails_ar {
    return Intl.message(
      'Editing Product Details',
      name: 'editingProductDetails_ar',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Delete Knowledge`
  String get removeKnowledge_ar {
    return Intl.message(
      'Delete Knowledge',
      name: 'removeKnowledge_ar',
      desc: '',
      args: [],
    );
  }

  /// `Second Emergency Contact`
  String get secondEmergencyContact_ {
    return Intl.message(
      'Second Emergency Contact',
      name: 'secondEmergencyContact_',
      desc: '',
      args: [],
    );
  }

  /// `Validation Error`
  String get validationError_ar {
    return Intl.message(
      'Validation Error',
      name: 'validationError_ar',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we load your services...`
  String get waitUntilDataCome {
    return Intl.message(
      'Please wait while we load your services...',
      name: 'waitUntilDataCome',
      desc: '',
      args: [],
    );
  }

  /// `When they receive a comment from the service provider`
  String get whenTheyReceiveCommentFromSServiceProvider {
    return Intl.message(
      'When they receive a comment from the service provider',
      name: 'whenTheyReceiveCommentFromSServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Route not found`
  String get routeNotFound {
    return Intl.message(
      'Route not found',
      name: 'routeNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Go Back`
  String get goBack {
    return Intl.message('Go Back', name: 'goBack', desc: '', args: []);
  }

  /// `No Form Found`
  String get noFormFound {
    return Intl.message(
      'No Form Found',
      name: 'noFormFound',
      desc: '',
      args: [],
    );
  }

  /// `Last Modified`
  String get lastModified {
    return Intl.message(
      'Last Modified',
      name: 'lastModified',
      desc: '',
      args: [],
    );
  }

  /// `Creating Form`
  String get creatingForm {
    return Intl.message(
      'Creating Form',
      name: 'creatingForm',
      desc: '',
      args: [],
    );
  }

  /// `Loading form...`
  String get loadingForm {
    return Intl.message(
      'Loading form...',
      name: 'loadingForm',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get formStatusPublish {
    return Intl.message(
      'Publish',
      name: 'formStatusPublish',
      desc: '',
      args: [],
    );
  }

  /// `Drafts`
  String get formStatusDrafts {
    return Intl.message('Drafts', name: 'formStatusDrafts', desc: '', args: []);
  }

  /// `Requested Forms`
  String get formStatusRequestedForms {
    return Intl.message(
      'Requested Forms',
      name: 'formStatusRequestedForms',
      desc: '',
      args: [],
    );
  }

  /// `Submissions`
  String get formStatusSubmissions {
    return Intl.message(
      'Submissions',
      name: 'formStatusSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get formStatusDeleted {
    return Intl.message(
      'Deleted',
      name: 'formStatusDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get menuDuplicate {
    return Intl.message('Duplicate', name: 'menuDuplicate', desc: '', args: []);
  }

  /// `Form Title`
  String get formTitle {
    return Intl.message('Form Title', name: 'formTitle', desc: '', args: []);
  }

  /// `Form Details`
  String get formDetails {
    return Intl.message(
      'Form Details',
      name: 'formDetails',
      desc: '',
      args: [],
    );
  }

  /// `Hide form details`
  String get hideFormDetails {
    return Intl.message(
      'Hide form details',
      name: 'hideFormDetails',
      desc: '',
      args: [],
    );
  }

  /// `Show form details`
  String get showFormDetails {
    return Intl.message(
      'Show form details',
      name: 'showFormDetails',
      desc: '',
      args: [],
    );
  }

  /// `Vertical Padding`
  String get verticalPadding {
    return Intl.message(
      'Vertical Padding',
      name: 'verticalPadding',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal Padding`
  String get horizontalPadding {
    return Intl.message(
      'Horizontal Padding',
      name: 'horizontalPadding',
      desc: '',
      args: [],
    );
  }

  /// `Watermark Size`
  String get watermarkSize {
    return Intl.message(
      'Watermark Size',
      name: 'watermarkSize',
      desc: '',
      args: [],
    );
  }

  /// `Watermark Opacity`
  String get watermarkOpacity {
    return Intl.message(
      'Watermark Opacity',
      name: 'watermarkOpacity',
      desc: '',
      args: [],
    );
  }

  /// `Upload Watermark`
  String get uploadWatermark {
    return Intl.message(
      'Upload Watermark',
      name: 'uploadWatermark',
      desc: '',
      args: [],
    );
  }

  /// `No. of Columns`
  String get numberOfColumns {
    return Intl.message(
      'No. of Columns',
      name: 'numberOfColumns',
      desc: '',
      args: [],
    );
  }

  /// `Break Page`
  String get breakPage {
    return Intl.message('Break Page', name: 'breakPage', desc: '', args: []);
  }

  /// `Unknown file path format`
  String get unknownFilePathFormat {
    return Intl.message(
      'Unknown file path format',
      name: 'unknownFilePathFormat',
      desc: '',
      args: [],
    );
  }

  /// `Access Management`
  String get accessManagement {
    return Intl.message(
      'Access Management',
      name: 'accessManagement',
      desc: '',
      args: [],
    );
  }

  /// `Choose Access Management`
  String get chooseAccessManagement {
    return Intl.message(
      'Choose Access Management',
      name: 'chooseAccessManagement',
      desc: '',
      args: [],
    );
  }

  /// `Open Access`
  String get openAccess {
    return Intl.message('Open Access', name: 'openAccess', desc: '', args: []);
  }

  /// `Personal Access`
  String get personalAccess {
    return Intl.message(
      'Personal Access',
      name: 'personalAccess',
      desc: '',
      args: [],
    );
  }

  /// `Restricted Access`
  String get restrictedAccess {
    return Intl.message(
      'Restricted Access',
      name: 'restrictedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Access Begins`
  String get accessBegins {
    return Intl.message(
      'Access Begins',
      name: 'accessBegins',
      desc: '',
      args: [],
    );
  }

  /// `Access Ends`
  String get accessEnds {
    return Intl.message('Access Ends', name: 'accessEnds', desc: '', args: []);
  }

  /// `Orientation`
  String get orientation {
    return Intl.message('Orientation', name: 'orientation', desc: '', args: []);
  }

  /// `Choose Orientation`
  String get chooseOrientation {
    return Intl.message(
      'Choose Orientation',
      name: 'chooseOrientation',
      desc: '',
      args: [],
    );
  }

  /// `Landscape`
  String get orientationLandscape {
    return Intl.message(
      'Landscape',
      name: 'orientationLandscape',
      desc: '',
      args: [],
    );
  }

  /// `Portrait`
  String get orientationPortrait {
    return Intl.message(
      'Portrait',
      name: 'orientationPortrait',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get alignmentLeft {
    return Intl.message('Left', name: 'alignmentLeft', desc: '', args: []);
  }

  /// `Right`
  String get alignmentRight {
    return Intl.message('Right', name: 'alignmentRight', desc: '', args: []);
  }

  /// `Center`
  String get alignmentCenter {
    return Intl.message('Center', name: 'alignmentCenter', desc: '', args: []);
  }

  /// `Expand`
  String get alignmentExpand {
    return Intl.message('Expand', name: 'alignmentExpand', desc: '', args: []);
  }

  /// `Vertical`
  String get arrangementVertical {
    return Intl.message(
      'Vertical',
      name: 'arrangementVertical',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal`
  String get arrangementHorizontal {
    return Intl.message(
      'Horizontal',
      name: 'arrangementHorizontal',
      desc: '',
      args: [],
    );
  }

  /// `Latitude And Longitude`
  String get latitudeAndLongitude {
    return Intl.message(
      'Latitude And Longitude',
      name: 'latitudeAndLongitude',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get fieldTypeImage {
    return Intl.message('Image', name: 'fieldTypeImage', desc: '', args: []);
  }

  /// `Text Field`
  String get fieldTypeTextField {
    return Intl.message(
      'Text Field',
      name: 'fieldTypeTextField',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get fieldTypeEmail {
    return Intl.message('Email', name: 'fieldTypeEmail', desc: '', args: []);
  }

  /// `Phone`
  String get fieldTypePhone {
    return Intl.message('Phone', name: 'fieldTypePhone', desc: '', args: []);
  }

  /// `Location`
  String get fieldTypeLocation {
    return Intl.message(
      'Location',
      name: 'fieldTypeLocation',
      desc: '',
      args: [],
    );
  }

  /// `Drop Down`
  String get fieldTypeDropDown {
    return Intl.message(
      'Drop Down',
      name: 'fieldTypeDropDown',
      desc: '',
      args: [],
    );
  }

  /// `Radio`
  String get fieldTypeRadio {
    return Intl.message('Radio', name: 'fieldTypeRadio', desc: '', args: []);
  }

  /// `Check Box`
  String get fieldTypeCheckBox {
    return Intl.message(
      'Check Box',
      name: 'fieldTypeCheckBox',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get fieldTypeDescription {
    return Intl.message(
      'Description',
      name: 'fieldTypeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Attachment`
  String get fieldTypeAttachment {
    return Intl.message(
      'Attachment',
      name: 'fieldTypeAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get fieldTypeLink {
    return Intl.message('Link', name: 'fieldTypeLink', desc: '', args: []);
  }

  /// `Attached Digital Signature`
  String get fieldTypeDigitalSignature {
    return Intl.message(
      'Attached Digital Signature',
      name: 'fieldTypeDigitalSignature',
      desc: '',
      args: [],
    );
  }

  /// `Date Selector`
  String get fieldTypeDateSelector {
    return Intl.message(
      'Date Selector',
      name: 'fieldTypeDateSelector',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get fieldTypeAddress {
    return Intl.message(
      'Address',
      name: 'fieldTypeAddress',
      desc: '',
      args: [],
    );
  }

  /// `Time Selector`
  String get fieldTypeTimeSelector {
    return Intl.message(
      'Time Selector',
      name: 'fieldTypeTimeSelector',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get fieldTypeTitle {
    return Intl.message('Title', name: 'fieldTypeTitle', desc: '', args: []);
  }

  /// `Radio - Text Field`
  String get fieldTypeRadioTextField {
    return Intl.message(
      'Radio - Text Field',
      name: 'fieldTypeRadioTextField',
      desc: '',
      args: [],
    );
  }

  /// `Terms And Condition`
  String get fieldTypeTermsAndCondition {
    return Intl.message(
      'Terms And Condition',
      name: 'fieldTypeTermsAndCondition',
      desc: '',
      args: [],
    );
  }

  /// `I agree to the Privacy Policy and Terms & Conditions`
  String get iAgreeToThePrivacyPolicyAndTermsAndConditions {
    return Intl.message(
      'I agree to the Privacy Policy and Terms & Conditions',
      name: 'iAgreeToThePrivacyPolicyAndTermsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Field must contain only English characters`
  String get fieldMustContainOnlyEnglishCharacters {
    return Intl.message(
      'Field must contain only English characters',
      name: 'fieldMustContainOnlyEnglishCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Field must contain English characters`
  String get fieldMustContainEnglishCharacters {
    return Intl.message(
      'Field must contain English characters',
      name: 'fieldMustContainEnglishCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Field must contain only Arabic characters`
  String get fieldMustContainOnlyArabicCharacters {
    return Intl.message(
      'Field must contain only Arabic characters',
      name: 'fieldMustContainOnlyArabicCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Field must contain Arabic characters`
  String get fieldMustContainArabicCharacters {
    return Intl.message(
      'Field must contain Arabic characters',
      name: 'fieldMustContainArabicCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get summary {
    return Intl.message('Summary', name: 'summary', desc: '', args: []);
  }

  /// `Row`
  String get rowHeading {
    return Intl.message('Row', name: 'rowHeading', desc: '', args: []);
  }

  /// `Column`
  String get columnHeading {
    return Intl.message('Column', name: 'columnHeading', desc: '', args: []);
  }

  /// `Choose Field of`
  String get chooseFieldOf {
    return Intl.message(
      'Choose Field of',
      name: 'chooseFieldOf',
      desc: '',
      args: [],
    );
  }

  /// `Page`
  String get page {
    return Intl.message('Page', name: 'page', desc: '', args: []);
  }

  /// `{title} Details`
  String detailsOfTitle(Object title) {
    return Intl.message(
      '$title Details',
      name: 'detailsOfTitle',
      desc: '',
      args: [title],
    );
  }

  /// `Result`
  String get result {
    return Intl.message('Result', name: 'result', desc: '', args: []);
  }

  /// `Group Details`
  String get groupDetails {
    return Intl.message(
      'Group Details',
      name: 'groupDetails',
      desc: '',
      args: [],
    );
  }

  /// `Group Information`
  String get groupInformation {
    return Intl.message(
      'Group Information',
      name: 'groupInformation',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Media`
  String get uploadedMedia {
    return Intl.message(
      'Uploaded Media',
      name: 'uploadedMedia',
      desc: '',
      args: [],
    );
  }

  /// `Submission Details`
  String get submissionDetails {
    return Intl.message(
      'Submission Details',
      name: 'submissionDetails',
      desc: '',
      args: [],
    );
  }

  /// `View details`
  String get viewDetails {
    return Intl.message(
      'View details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Base Line Chart`
  String get baseLineChart {
    return Intl.message(
      'Base Line Chart',
      name: 'baseLineChart',
      desc: '',
      args: [],
    );
  }

  /// `Table chart`
  String get tableChart {
    return Intl.message('Table chart', name: 'tableChart', desc: '', args: []);
  }

  /// `Bar chart`
  String get barChart {
    return Intl.message('Bar chart', name: 'barChart', desc: '', args: []);
  }

  /// `Horizontal bar chart`
  String get horizontalBarChart {
    return Intl.message(
      'Horizontal bar chart',
      name: 'horizontalBarChart',
      desc: '',
      args: [],
    );
  }

  /// `Stacked Bar Chart`
  String get stackedBarChart {
    return Intl.message(
      'Stacked Bar Chart',
      name: 'stackedBarChart',
      desc: '',
      args: [],
    );
  }

  /// `Grouped Bar Chart`
  String get groupedBarChart {
    return Intl.message(
      'Grouped Bar Chart',
      name: 'groupedBarChart',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal Stacked Bar Chart`
  String get horizontalStackedBarChart {
    return Intl.message(
      'Horizontal Stacked Bar Chart',
      name: 'horizontalStackedBarChart',
      desc: '',
      args: [],
    );
  }

  /// `Pie Chart`
  String get pieChart {
    return Intl.message('Pie Chart', name: 'pieChart', desc: '', args: []);
  }

  /// `Donut Chart`
  String get donutChart {
    return Intl.message('Donut Chart', name: 'donutChart', desc: '', args: []);
  }

  /// `Radial Bar Chart`
  String get radialBarChart {
    return Intl.message(
      'Radial Bar Chart',
      name: 'radialBarChart',
      desc: '',
      args: [],
    );
  }

  /// `Low Stocks`
  String get lowStocks {
    return Intl.message('Low Stocks', name: 'lowStocks', desc: '', args: []);
  }

  /// `Forms Submission`
  String get formsSubmission {
    return Intl.message(
      'Forms Submission',
      name: 'formsSubmission',
      desc: '',
      args: [],
    );
  }

  /// `View Approval`
  String get viewApproval {
    return Intl.message(
      'View Approval',
      name: 'viewApproval',
      desc: '',
      args: [],
    );
  }

  /// `Total Requests`
  String get totalRequests {
    return Intl.message(
      'Total Requests',
      name: 'totalRequests',
      desc: '',
      args: [],
    );
  }

  /// `Total SLA`
  String get totalSLA {
    return Intl.message('Total SLA', name: 'totalSLA', desc: '', args: []);
  }

  /// `Total Done`
  String get totalDone {
    return Intl.message('Total Done', name: 'totalDone', desc: '', args: []);
  }

  /// `Total Stolen`
  String get totalStolen {
    return Intl.message(
      'Total Stolen',
      name: 'totalStolen',
      desc: '',
      args: [],
    );
  }

  /// `Employee Messages`
  String get employeeMessages {
    return Intl.message(
      'Employee Messages',
      name: 'employeeMessages',
      desc: '',
      args: [],
    );
  }

  /// `Group Messages`
  String get groupMessages {
    return Intl.message(
      'Group Messages',
      name: 'groupMessages',
      desc: '',
      args: [],
    );
  }

  /// `Bar Label`
  String get barLabel {
    return Intl.message('Bar Label', name: 'barLabel', desc: '', args: []);
  }

  /// `Label`
  String get label {
    return Intl.message('Label', name: 'label', desc: '', args: []);
  }

  /// `Left`
  String get left {
    return Intl.message('Left', name: 'left', desc: '', args: []);
  }

  /// `Select Departments`
  String get selectDepartments {
    return Intl.message(
      'Select Departments',
      name: 'selectDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Select Title`
  String get selectTitle {
    return Intl.message(
      'Select Title',
      name: 'selectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select Work Location`
  String get selectWorkLocation {
    return Intl.message(
      'Select Work Location',
      name: 'selectWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Supervisor`
  String get selectSupervisor {
    return Intl.message(
      'Select Supervisor',
      name: 'selectSupervisor',
      desc: '',
      args: [],
    );
  }

  /// `File Format`
  String get fileFormat {
    return Intl.message('File Format', name: 'fileFormat', desc: '', args: []);
  }

  /// `Select File Format`
  String get selectFileFormat {
    return Intl.message(
      'Select File Format',
      name: 'selectFileFormat',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select Nationality`
  String get selectNationality {
    return Intl.message(
      'Select Nationality',
      name: 'selectNationality',
      desc: '',
      args: [],
    );
  }

  /// `CSV`
  String get formatCsv {
    return Intl.message('CSV', name: 'formatCsv', desc: '', args: []);
  }

  /// `Excel (.xlsx)`
  String get formatExcel {
    return Intl.message(
      'Excel (.xlsx)',
      name: 'formatExcel',
      desc: '',
      args: [],
    );
  }

  /// `PDF`
  String get formatPdf {
    return Intl.message('PDF', name: 'formatPdf', desc: '', args: []);
  }

  /// `Both`
  String get bothLanguages {
    return Intl.message('Both', name: 'bothLanguages', desc: '', args: []);
  }

  /// `Preview {count} Matches`
  String previewMatches(Object count) {
    return Intl.message(
      'Preview $count Matches',
      name: 'previewMatches',
      desc: '',
      args: [count],
    );
  }

  /// `Watermark Modules`
  String get watermarkModules {
    return Intl.message(
      'Watermark Modules',
      name: 'watermarkModules',
      desc: '',
      args: [],
    );
  }

  /// `Style`
  String get watermarkStyleLabel {
    return Intl.message(
      'Style',
      name: 'watermarkStyleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get watermarkStyleText {
    return Intl.message('Text', name: 'watermarkStyleText', desc: '', args: []);
  }

  /// `Bubble`
  String get watermarkStyleBubble {
    return Intl.message(
      'Bubble',
      name: 'watermarkStyleBubble',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message('Clear All', name: 'clearAll', desc: '', args: []);
  }

  /// `CRM`
  String get crm {
    return Intl.message('CRM', name: 'crm', desc: '', args: []);
  }

  /// `Clients`
  String get crmClients {
    return Intl.message('Clients', name: 'crmClients', desc: '', args: []);
  }

  /// `Add New Client`
  String get crmAddNewClient {
    return Intl.message(
      'Add New Client',
      name: 'crmAddNewClient',
      desc: '',
      args: [],
    );
  }

  /// `Client Details`
  String get crmClientDetails {
    return Intl.message(
      'Client Details',
      name: 'crmClientDetails',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get crmAddress {
    return Intl.message('Address', name: 'crmAddress', desc: '', args: []);
  }

  /// `Hide`
  String get crmHide {
    return Intl.message('Hide', name: 'crmHide', desc: '', args: []);
  }

  /// `Show`
  String get crmShow {
    return Intl.message('Show', name: 'crmShow', desc: '', args: []);
  }

  /// `Client First Name`
  String get crmClientFirstName {
    return Intl.message(
      'Client First Name',
      name: 'crmClientFirstName',
      desc: '',
      args: [],
    );
  }

  /// `اسم العميل الأول`
  String get crmClientFirstNameAr {
    return Intl.message(
      'اسم العميل الأول',
      name: 'crmClientFirstNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Client Last Name`
  String get crmClientLastName {
    return Intl.message(
      'Client Last Name',
      name: 'crmClientLastName',
      desc: '',
      args: [],
    );
  }

  /// `اسم العميل الأخير`
  String get crmClientLastNameAr {
    return Intl.message(
      'اسم العميل الأخير',
      name: 'crmClientLastNameAr',
      desc: '',
      args: [],
    );
  }

  /// `National ID`
  String get crmNationalId {
    return Intl.message(
      'National ID',
      name: 'crmNationalId',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get crmPhone {
    return Intl.message('Phone', name: 'crmPhone', desc: '', args: []);
  }

  /// `Email`
  String get crmEmail {
    return Intl.message('Email', name: 'crmEmail', desc: '', args: []);
  }

  /// `Preferred Language`
  String get crmPreferredLanguage {
    return Intl.message(
      'Preferred Language',
      name: 'crmPreferredLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Contact Channel`
  String get crmContactChannel {
    return Intl.message(
      'Contact Channel',
      name: 'crmContactChannel',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get crmCountry {
    return Intl.message('Country', name: 'crmCountry', desc: '', args: []);
  }

  /// `City`
  String get crmCity {
    return Intl.message('City', name: 'crmCity', desc: '', args: []);
  }

  /// `Tags`
  String get crmTags {
    return Intl.message('Tags', name: 'crmTags', desc: '', args: []);
  }

  /// `Business Initiation Date`
  String get crmBusinessInitiationDate {
    return Intl.message(
      'Business Initiation Date',
      name: 'crmBusinessInitiationDate',
      desc: '',
      args: [],
    );
  }

  /// `Province`
  String get crmProvince {
    return Intl.message('Province', name: 'crmProvince', desc: '', args: []);
  }

  /// `Street`
  String get crmStreet {
    return Intl.message('Street', name: 'crmStreet', desc: '', args: []);
  }

  /// `Field Required`
  String get crmFieldRequired {
    return Intl.message(
      'Field Required',
      name: 'crmFieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `الحقل مطلوب`
  String get crmFieldRequiredAr {
    return Intl.message(
      'الحقل مطلوب',
      name: 'crmFieldRequiredAr',
      desc: '',
      args: [],
    );
  }

  /// `Text Here`
  String get crmTextHere {
    return Intl.message('Text Here', name: 'crmTextHere', desc: '', args: []);
  }

  /// `اكتب هنا`
  String get crmWriteHere {
    return Intl.message('اكتب هنا', name: 'crmWriteHere', desc: '', args: []);
  }

  /// `Name`
  String get crmName {
    return Intl.message('Name', name: 'crmName', desc: '', args: []);
  }

  /// `الاسم`
  String get crmNameArabic {
    return Intl.message('الاسم', name: 'crmNameArabic', desc: '', args: []);
  }

  /// `Client Type`
  String get crmClientType {
    return Intl.message(
      'Client Type',
      name: 'crmClientType',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get crmNote {
    return Intl.message('Note', name: 'crmNote', desc: '', args: []);
  }

  /// `ملاحظة`
  String get crmNoteArabic {
    return Intl.message('ملاحظة', name: 'crmNoteArabic', desc: '', args: []);
  }

  /// `Description`
  String get crmDescription {
    return Intl.message(
      'Description',
      name: 'crmDescription',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get crmRequiredField {
    return Intl.message(
      'This field is required',
      name: 'crmRequiredField',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get crmSelect {
    return Intl.message('Select', name: 'crmSelect', desc: '', args: []);
  }

  /// `Select Date`
  String get crmSelectDate {
    return Intl.message(
      'Select Date',
      name: 'crmSelectDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get crmChoose {
    return Intl.message('Choose', name: 'crmChoose', desc: '', args: []);
  }

  /// `Company name`
  String get crmCompanyName {
    return Intl.message(
      'Company name',
      name: 'crmCompanyName',
      desc: '',
      args: [],
    );
  }

  /// `اسم الشركة`
  String get crmCompanyNameAr {
    return Intl.message(
      'اسم الشركة',
      name: 'crmCompanyNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Commercial Registration No. (CR No.)`
  String get crmCrNumber {
    return Intl.message(
      'Commercial Registration No. (CR No.)',
      name: 'crmCrNumber',
      desc: '',
      args: [],
    );
  }

  /// `Tax No. (Tax Number)`
  String get crmTaxNumber {
    return Intl.message(
      'Tax No. (Tax Number)',
      name: 'crmTaxNumber',
      desc: '',
      args: [],
    );
  }

  /// `Industry`
  String get crmIndustry {
    return Intl.message('Industry', name: 'crmIndustry', desc: '', args: []);
  }

  /// `Size`
  String get crmCompanySize {
    return Intl.message('Size', name: 'crmCompanySize', desc: '', args: []);
  }

  /// `Website`
  String get crmWebsite {
    return Intl.message('Website', name: 'crmWebsite', desc: '', args: []);
  }

  /// `Entity Name`
  String get crmEntityName {
    return Intl.message(
      'Entity Name',
      name: 'crmEntityName',
      desc: '',
      args: [],
    );
  }

  /// `اسم الكيان`
  String get crmEntityNameAr {
    return Intl.message(
      'اسم الكيان',
      name: 'crmEntityNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Sector`
  String get crmSector {
    return Intl.message('Sector', name: 'crmSector', desc: '', args: []);
  }

  /// `Client Duplication Found`
  String get crmDuplicationFound {
    return Intl.message(
      'Client Duplication Found',
      name: 'crmDuplicationFound',
      desc: '',
      args: [],
    );
  }

  /// `Similar Client found in the system; please review before continuing.`
  String get crmDuplicationSubtitle {
    return Intl.message(
      'Similar Client found in the system; please review before continuing.',
      name: 'crmDuplicationSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `View Client`
  String get crmViewClient {
    return Intl.message(
      'View Client',
      name: 'crmViewClient',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get crmAddAddress {
    return Intl.message(
      'Add Address',
      name: 'crmAddAddress',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get crmDiscard {
    return Intl.message('Discard', name: 'crmDiscard', desc: '', args: []);
  }

  /// `Next`
  String get crmNext {
    return Intl.message('Next', name: 'crmNext', desc: '', args: []);
  }

  /// `Save For Later`
  String get crmSaveForLater {
    return Intl.message(
      'Save For Later',
      name: 'crmSaveForLater',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get crmAdd {
    return Intl.message('Add', name: 'crmAdd', desc: '', args: []);
  }

  /// `Search`
  String get crmSearch {
    return Intl.message('Search', name: 'crmSearch', desc: '', args: []);
  }

  /// `Filter`
  String get crmFilter {
    return Intl.message('Filter', name: 'crmFilter', desc: '', args: []);
  }

  /// `Sort`
  String get crmSort {
    return Intl.message('Sort', name: 'crmSort', desc: '', args: []);
  }

  /// `Export`
  String get crmExport {
    return Intl.message('Export', name: 'crmExport', desc: '', args: []);
  }

  /// `Import`
  String get crmImport {
    return Intl.message('Import', name: 'crmImport', desc: '', args: []);
  }

  /// `Master Template`
  String get crmMasterTemplate {
    return Intl.message(
      'Master Template',
      name: 'crmMasterTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Templates`
  String get crmTemplates {
    return Intl.message('Templates', name: 'crmTemplates', desc: '', args: []);
  }

  /// `No templates available yet`
  String get crmNoTemplates {
    return Intl.message(
      'No templates available yet',
      name: 'crmNoTemplates',
      desc: '',
      args: [],
    );
  }

  /// `Total Clients`
  String get crmTotalClients {
    return Intl.message(
      'Total Clients',
      name: 'crmTotalClients',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get crmActive {
    return Intl.message('Active', name: 'crmActive', desc: '', args: []);
  }

  /// `Inactive`
  String get crmInactive {
    return Intl.message('Inactive', name: 'crmInactive', desc: '', args: []);
  }

  /// `Prospect`
  String get crmProspect {
    return Intl.message('Prospect', name: 'crmProspect', desc: '', args: []);
  }

  /// `Archived`
  String get crmArchived {
    return Intl.message('Archived', name: 'crmArchived', desc: '', args: []);
  }

  /// `Individuals`
  String get crmIndividuals {
    return Intl.message(
      'Individuals',
      name: 'crmIndividuals',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get crmCompany {
    return Intl.message('Company', name: 'crmCompany', desc: '', args: []);
  }

  /// `Government`
  String get crmGovernment {
    return Intl.message(
      'Government',
      name: 'crmGovernment',
      desc: '',
      args: [],
    );
  }

  /// `Clients: {count}`
  String crmClientsCount(Object count) {
    return Intl.message(
      'Clients: $count',
      name: 'crmClientsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Creation Date: {date}`
  String crmCreationDate(Object date) {
    return Intl.message(
      'Creation Date: $date',
      name: 'crmCreationDate',
      desc: '',
      args: [date],
    );
  }

  /// `Review Bulk Upload`
  String get crmReviewBulkUpload {
    return Intl.message(
      'Review Bulk Upload',
      name: 'crmReviewBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `Validate imported clients data before activating`
  String get crmValidateImportedClients {
    return Intl.message(
      'Validate imported clients data before activating',
      name: 'crmValidateImportedClients',
      desc: '',
      args: [],
    );
  }

  /// `Remove Selection`
  String get crmRemoveSelection {
    return Intl.message(
      'Remove Selection',
      name: 'crmRemoveSelection',
      desc: '',
      args: [],
    );
  }

  /// `Row`
  String get crmAddRow {
    return Intl.message('Row', name: 'crmAddRow', desc: '', args: []);
  }

  /// `Error: {count}`
  String crmErrorCount(Object count) {
    return Intl.message(
      'Error: $count',
      name: 'crmErrorCount',
      desc: '',
      args: [count],
    );
  }

  /// `Activate`
  String get crmActivate {
    return Intl.message('Activate', name: 'crmActivate', desc: '', args: []);
  }

  /// `Warning Language Check`
  String get crmWarningLanguageCheckTitle {
    return Intl.message(
      'Warning Language Check',
      name: 'crmWarningLanguageCheckTitle',
      desc: '',
      args: [],
    );
  }

  /// `There is an issue with your entry. Please ensure you use the required language`
  String get crmWarningLanguageCheckSubtitle {
    return Intl.message(
      'There is an issue with your entry. Please ensure you use the required language',
      name: 'crmWarningLanguageCheckSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts English letters only`
  String get crmEnglishLettersOnlyTitle {
    return Intl.message(
      'This field accepts English letters only',
      name: 'crmEnglishLettersOnlyTitle',
      desc: '',
      args: [],
    );
  }

  /// `This Name Exist Before`
  String get crmNameAlreadyExists {
    return Intl.message(
      'This Name Exist Before',
      name: 'crmNameAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts English letters only Please use English letters only (A-Z)`
  String get crmEnglishLettersOnlySubtitle {
    return Intl.message(
      'This field accepts English letters only Please use English letters only (A-Z)',
      name: 'crmEnglishLettersOnlySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Companies`
  String get crmCompanies {
    return Intl.message('Companies', name: 'crmCompanies', desc: '', args: []);
  }

  /// `Government Sector`
  String get crmGovernmentSector {
    return Intl.message(
      'Government Sector',
      name: 'crmGovernmentSector',
      desc: '',
      args: [],
    );
  }

  /// `Persons`
  String get crmPersons {
    return Intl.message('Persons', name: 'crmPersons', desc: '', args: []);
  }

  /// `Leads`
  String get crmSectionLeads {
    return Intl.message('Leads', name: 'crmSectionLeads', desc: '', args: []);
  }

  /// `Manage and track Potential Customer`
  String get crmSectionLeadsDesc {
    return Intl.message(
      'Manage and track Potential Customer',
      name: 'crmSectionLeadsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Clients`
  String get crmSectionClients {
    return Intl.message(
      'Clients',
      name: 'crmSectionClients',
      desc: '',
      args: [],
    );
  }

  /// `Manage Your client and view details`
  String get crmSectionClientsDesc {
    return Intl.message(
      'Manage Your client and view details',
      name: 'crmSectionClientsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Deals`
  String get crmSectionDeals {
    return Intl.message('Deals', name: 'crmSectionDeals', desc: '', args: []);
  }

  /// `Track your deals and manage your sales pipelines`
  String get crmSectionDealsDesc {
    return Intl.message(
      'Track your deals and manage your sales pipelines',
      name: 'crmSectionDealsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get crmSectionProducts {
    return Intl.message(
      'Products',
      name: 'crmSectionProducts',
      desc: '',
      args: [],
    );
  }

  /// `Manage your Products`
  String get crmSectionProductsDesc {
    return Intl.message(
      'Manage your Products',
      name: 'crmSectionProductsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get crmSectionServices {
    return Intl.message(
      'Services',
      name: 'crmSectionServices',
      desc: '',
      args: [],
    );
  }

  /// `Manage your Services`
  String get crmSectionServicesDesc {
    return Intl.message(
      'Manage your Services',
      name: 'crmSectionServicesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Quotes`
  String get crmSectionQuotes {
    return Intl.message('Quotes', name: 'crmSectionQuotes', desc: '', args: []);
  }

  /// `Create and manage quotes for your clients`
  String get crmSectionQuotesDesc {
    return Intl.message(
      'Create and manage quotes for your clients',
      name: 'crmSectionQuotesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Contracts`
  String get crmSectionContracts {
    return Intl.message(
      'Contracts',
      name: 'crmSectionContracts',
      desc: '',
      args: [],
    );
  }

  /// `Manage contracts`
  String get crmSectionContractsDesc {
    return Intl.message(
      'Manage contracts',
      name: 'crmSectionContractsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Merge`
  String get crmSectionMerge {
    return Intl.message('Merge', name: 'crmSectionMerge', desc: '', args: []);
  }

  /// `Review and manage duplicate records`
  String get crmSectionMergeDesc {
    return Intl.message(
      'Review and manage duplicate records',
      name: 'crmSectionMergeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Possible Level`
  String get crmMergePossibleLevel {
    return Intl.message(
      'Possible Level',
      name: 'crmMergePossibleLevel',
      desc: '',
      args: [],
    );
  }

  /// `Range From`
  String get crmMergeRangeFrom {
    return Intl.message(
      'Range From',
      name: 'crmMergeRangeFrom',
      desc: '',
      args: [],
    );
  }

  /// `Range To`
  String get crmMergeRangeTo {
    return Intl.message(
      'Range To',
      name: 'crmMergeRangeTo',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get crmMergeSettings {
    return Intl.message(
      'Settings',
      name: 'crmMergeSettings',
      desc: '',
      args: [],
    );
  }

  /// `Undo Mode`
  String get crmMergeUndoMode {
    return Intl.message(
      'Undo Mode',
      name: 'crmMergeUndoMode',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get crmMergeDuration {
    return Intl.message(
      'Duration',
      name: 'crmMergeDuration',
      desc: '',
      args: [],
    );
  }

  /// `Press to add a likelihood level`
  String get crmMergeNoLevels {
    return Intl.message(
      'Press to add a likelihood level',
      name: 'crmMergeNoLevels',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get crmMergeMinutes {
    return Intl.message('Minutes', name: 'crmMergeMinutes', desc: '', args: []);
  }

  /// `Hours`
  String get crmMergeHours {
    return Intl.message('Hours', name: 'crmMergeHours', desc: '', args: []);
  }

  /// `Days`
  String get crmMergeDays {
    return Intl.message('Days', name: 'crmMergeDays', desc: '', args: []);
  }

  /// `Weeks`
  String get crmMergeWeeks {
    return Intl.message('Weeks', name: 'crmMergeWeeks', desc: '', args: []);
  }

  /// `Months`
  String get crmMergeMonths {
    return Intl.message('Months', name: 'crmMergeMonths', desc: '', args: []);
  }

  /// `Years`
  String get crmMergeYears {
    return Intl.message('Years', name: 'crmMergeYears', desc: '', args: []);
  }

  /// `Range (Low - High)`
  String get crmMergeSortRangeAsc {
    return Intl.message(
      'Range (Low - High)',
      name: 'crmMergeSortRangeAsc',
      desc: '',
      args: [],
    );
  }

  /// `Range (High - Low)`
  String get crmMergeSortRangeDesc {
    return Intl.message(
      'Range (High - Low)',
      name: 'crmMergeSortRangeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get crmMergeColor {
    return Intl.message('Color', name: 'crmMergeColor', desc: '', args: []);
  }

  /// `Choose`
  String get crmMergeChooseColor {
    return Intl.message(
      'Choose',
      name: 'crmMergeChooseColor',
      desc: '',
      args: [],
    );
  }

  /// `Add Level`
  String get crmMergeAddLevel {
    return Intl.message(
      'Add Level',
      name: 'crmMergeAddLevel',
      desc: '',
      args: [],
    );
  }

  /// `Edit Level Details`
  String get crmMergeEditLevel {
    return Intl.message(
      'Edit Level Details',
      name: 'crmMergeEditLevel',
      desc: '',
      args: [],
    );
  }

  /// `Level Details`
  String get crmMergeLevelDetails {
    return Intl.message(
      'Level Details',
      name: 'crmMergeLevelDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this level?`
  String get crmMergeDeleteConfirm {
    return Intl.message(
      'Are you sure you want to delete this level?',
      name: 'crmMergeDeleteConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Deleted successfully .`
  String get crmMergeDeletedSuccess {
    return Intl.message(
      'Deleted successfully .',
      name: 'crmMergeDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get crmSectionRequests {
    return Intl.message(
      'Requests',
      name: 'crmSectionRequests',
      desc: '',
      args: [],
    );
  }

  /// `View and manage requests`
  String get crmSectionRequestsDesc {
    return Intl.message(
      'View and manage requests',
      name: 'crmSectionRequestsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist`
  String get crmSectionBlacklist {
    return Intl.message(
      'Blacklist',
      name: 'crmSectionBlacklist',
      desc: '',
      args: [],
    );
  }

  /// `Manage blocked clients`
  String get crmSectionBlacklistDesc {
    return Intl.message(
      'Manage blocked clients',
      name: 'crmSectionBlacklistDesc',
      desc: '',
      args: [],
    );
  }

  /// `Controls`
  String get crmSectionControls {
    return Intl.message(
      'Controls',
      name: 'crmSectionControls',
      desc: '',
      args: [],
    );
  }

  /// `Configure system settings and control user access.`
  String get crmSectionControlsDesc {
    return Intl.message(
      'Configure system settings and control user access.',
      name: 'crmSectionControlsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Guide`
  String get crmSectionGuide {
    return Intl.message('Guide', name: 'crmSectionGuide', desc: '', args: []);
  }

  /// `Access guides, FAQs, and competitor information`
  String get crmSectionGuideDesc {
    return Intl.message(
      'Access guides, FAQs, and competitor information',
      name: 'crmSectionGuideDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sections`
  String get crmSectionsTab {
    return Intl.message('Sections', name: 'crmSectionsTab', desc: '', args: []);
  }

  /// `Dashboard`
  String get crmDashboardTab {
    return Intl.message(
      'Dashboard',
      name: 'crmDashboardTab',
      desc: '',
      args: [],
    );
  }

  /// `Control`
  String get crmControlTitle {
    return Intl.message('Control', name: 'crmControlTitle', desc: '', args: []);
  }

  /// `Clients Types`
  String get crmControlClientsTypes {
    return Intl.message(
      'Clients Types',
      name: 'crmControlClientsTypes',
      desc: '',
      args: [],
    );
  }

  /// `Manage Your client ans view details`
  String get crmControlClientsTypesDesc {
    return Intl.message(
      'Manage Your client ans view details',
      name: 'crmControlClientsTypesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Templates`
  String get crmControlTemplates {
    return Intl.message(
      'Templates',
      name: 'crmControlTemplates',
      desc: '',
      args: [],
    );
  }

  /// `Create and manage forms for your clients`
  String get crmControlTemplatesDesc {
    return Intl.message(
      'Create and manage forms for your clients',
      name: 'crmControlTemplatesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Teams`
  String get crmControlTeams {
    return Intl.message('Teams', name: 'crmControlTeams', desc: '', args: []);
  }

  /// `Manage Your Employees`
  String get crmControlTeamsDesc {
    return Intl.message(
      'Manage Your Employees',
      name: 'crmControlTeamsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Terms`
  String get crmControlTerms {
    return Intl.message('Terms', name: 'crmControlTerms', desc: '', args: []);
  }

  /// `Create and manage Terms`
  String get crmControlTermsDesc {
    return Intl.message(
      'Create and manage Terms',
      name: 'crmControlTermsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Permissions`
  String get crmControlPermissions {
    return Intl.message(
      'Permissions',
      name: 'crmControlPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Manage all permissions for your Employees`
  String get crmControlPermissionsDesc {
    return Intl.message(
      'Manage all permissions for your Employees',
      name: 'crmControlPermissionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Deals`
  String get crmControlDeals {
    return Intl.message('Deals', name: 'crmControlDeals', desc: '', args: []);
  }

  /// `Manage all permissions for your Employees`
  String get crmControlDealsDesc {
    return Intl.message(
      'Manage all permissions for your Employees',
      name: 'crmControlDealsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get crmControlDiscount {
    return Intl.message(
      'Discount',
      name: 'crmControlDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Create and manage discount for your clients`
  String get crmControlDiscountDesc {
    return Intl.message(
      'Create and manage discount for your clients',
      name: 'crmControlDiscountDesc',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get crmControlActivity {
    return Intl.message(
      'Activity',
      name: 'crmControlActivity',
      desc: '',
      args: [],
    );
  }

  /// `Create and manage activity types for your clients`
  String get crmControlActivityDesc {
    return Intl.message(
      'Create and manage activity types for your clients',
      name: 'crmControlActivityDesc',
      desc: '',
      args: [],
    );
  }

  /// `Relationship`
  String get crmControlRelationship {
    return Intl.message(
      'Relationship',
      name: 'crmControlRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Create and manage activity types for your clients`
  String get crmControlRelationshipDesc {
    return Intl.message(
      'Create and manage activity types for your clients',
      name: 'crmControlRelationshipDesc',
      desc: '',
      args: [],
    );
  }

  /// `Person`
  String get crmPerson {
    return Intl.message('Person', name: 'crmPerson', desc: '', args: []);
  }

  /// `Add Type`
  String get crmAddType {
    return Intl.message('Add Type', name: 'crmAddType', desc: '', args: []);
  }

  /// `Edit Type Details`
  String get crmEditType {
    return Intl.message(
      'Edit Type Details',
      name: 'crmEditType',
      desc: '',
      args: [],
    );
  }

  /// `Type Details`
  String get crmTypeDetails {
    return Intl.message(
      'Type Details',
      name: 'crmTypeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get crmRemove {
    return Intl.message('Remove', name: 'crmRemove', desc: '', args: []);
  }

  /// `Save`
  String get crmSave {
    return Intl.message('Save', name: 'crmSave', desc: '', args: []);
  }

  /// `Remove Field`
  String get crmRemoveField {
    return Intl.message(
      'Remove Field',
      name: 'crmRemoveField',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to remove this field?`
  String get crmRemoveFieldSubtitle {
    return Intl.message(
      'Are you sure to remove this field?',
      name: 'crmRemoveFieldSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Successful!`
  String get crmSuccessful {
    return Intl.message(
      'Successful!',
      name: 'crmSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Removed successfully .`
  String get crmRemovedSuccessfully {
    return Intl.message(
      'Removed successfully .',
      name: 'crmRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to save Changes?`
  String get crmSaveSubtitle {
    return Intl.message(
      'Are you sure to save Changes?',
      name: 'crmSaveSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `submit successfully .`
  String get crmSubmitSuccessfully {
    return Intl.message(
      'submit successfully .',
      name: 'crmSubmitSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `This field accepts Arabic letters only`
  String get crmArabicLettersOnlyTitle {
    return Intl.message(
      'This field accepts Arabic letters only',
      name: 'crmArabicLettersOnlyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Press to add`
  String get crmPressToAdd {
    return Intl.message(
      'Press to add',
      name: 'crmPressToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Section Details`
  String get crmSectionDetails {
    return Intl.message(
      'Section Details',
      name: 'crmSectionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Saved Sections`
  String get crmSavedSections {
    return Intl.message(
      'Saved Sections',
      name: 'crmSavedSections',
      desc: '',
      args: [],
    );
  }

  /// `Section Name`
  String get crmSectionName {
    return Intl.message(
      'Section Name',
      name: 'crmSectionName',
      desc: '',
      args: [],
    );
  }

  /// `اسم القسم`
  String get crmSectionNameAr {
    return Intl.message(
      'اسم القسم',
      name: 'crmSectionNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Field Name`
  String get crmFieldName {
    return Intl.message('Field Name', name: 'crmFieldName', desc: '', args: []);
  }

  /// `اسم الحقل`
  String get crmFieldNameAr {
    return Intl.message(
      'اسم الحقل',
      name: 'crmFieldNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Section`
  String get crmCategorySection {
    return Intl.message(
      'Section',
      name: 'crmCategorySection',
      desc: '',
      args: [],
    );
  }

  /// `Fields`
  String get crmCategoryFields {
    return Intl.message(
      'Fields',
      name: 'crmCategoryFields',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get crmStatusActive {
    return Intl.message('Active', name: 'crmStatusActive', desc: '', args: []);
  }

  /// `Inactive`
  String get crmStatusInactive {
    return Intl.message(
      'Inactive',
      name: 'crmStatusInactive',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get crmStatusDeleted {
    return Intl.message(
      'Deleted',
      name: 'crmStatusDeleted',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get crmValidationNone {
    return Intl.message('None', name: 'crmValidationNone', desc: '', args: []);
  }

  /// `Numbers`
  String get crmValidationNumbers {
    return Intl.message(
      'Numbers',
      name: 'crmValidationNumbers',
      desc: '',
      args: [],
    );
  }

  /// `Symbols`
  String get crmValidationSymbols {
    return Intl.message(
      'Symbols',
      name: 'crmValidationSymbols',
      desc: '',
      args: [],
    );
  }

  /// `Letters`
  String get crmValidationLetters {
    return Intl.message(
      'Letters',
      name: 'crmValidationLetters',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get crmValidationEmail {
    return Intl.message(
      'Email',
      name: 'crmValidationEmail',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get crmValidationPhone {
    return Intl.message(
      'Phone',
      name: 'crmValidationPhone',
      desc: '',
      args: [],
    );
  }

  /// `Last Update`
  String get crmLastUpdate {
    return Intl.message(
      'Last Update',
      name: 'crmLastUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Creation Date`
  String get crmCreationDateLabel {
    return Intl.message(
      'Creation Date',
      name: 'crmCreationDateLabel',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get crmStatus {
    return Intl.message('Status', name: 'crmStatus', desc: '', args: []);
  }

  /// `Bulk Upload`
  String get crmBulkUpload {
    return Intl.message(
      'Bulk Upload',
      name: 'crmBulkUpload',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get crmAll {
    return Intl.message('All', name: 'crmAll', desc: '', args: []);
  }

  /// `All City`
  String get crmAllCity {
    return Intl.message('All City', name: 'crmAllCity', desc: '', args: []);
  }

  /// `All Country`
  String get crmAllCountry {
    return Intl.message(
      'All Country',
      name: 'crmAllCountry',
      desc: '',
      args: [],
    );
  }

  /// `All Status`
  String get crmAllStatus {
    return Intl.message('All Status', name: 'crmAllStatus', desc: '', args: []);
  }

  /// `Total`
  String get crmTotal {
    return Intl.message('Total', name: 'crmTotal', desc: '', args: []);
  }

  /// `Clients Status`
  String get crmClientsStatus {
    return Intl.message(
      'Clients Status',
      name: 'crmClientsStatus',
      desc: '',
      args: [],
    );
  }

  /// `Saved View`
  String get crmSavedView {
    return Intl.message('Saved View', name: 'crmSavedView', desc: '', args: []);
  }

  /// `Add View`
  String get crmAddView {
    return Intl.message('Add View', name: 'crmAddView', desc: '', args: []);
  }

  /// `Name (A - Z)`
  String get crmSortNameAsc {
    return Intl.message(
      'Name (A - Z)',
      name: 'crmSortNameAsc',
      desc: '',
      args: [],
    );
  }

  /// `Name (Z - A)`
  String get crmSortNameDesc {
    return Intl.message(
      'Name (Z - A)',
      name: 'crmSortNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Oldest First`
  String get crmSortOldest {
    return Intl.message(
      'Oldest First',
      name: 'crmSortOldest',
      desc: '',
      args: [],
    );
  }

  /// `Newest First`
  String get crmSortNewest {
    return Intl.message(
      'Newest First',
      name: 'crmSortNewest',
      desc: '',
      args: [],
    );
  }

  /// `Save Client Record`
  String get crmSaveClientRecord {
    return Intl.message(
      'Save Client Record',
      name: 'crmSaveClientRecord',
      desc: '',
      args: [],
    );
  }

  /// `Client Added Successfully`
  String get crmClientAddedSuccessfully {
    return Intl.message(
      'Client Added Successfully',
      name: 'crmClientAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL`
  String get crmInvalidUrl {
    return Intl.message(
      'Invalid URL',
      name: 'crmInvalidUrl',
      desc: '',
      args: [],
    );
  }

  /// `Field Details`
  String get crmFieldDetails {
    return Intl.message(
      'Field Details',
      name: 'crmFieldDetails',
      desc: '',
      args: [],
    );
  }

  /// `Show AR + EN Language`
  String get crmShowBothLanguages {
    return Intl.message(
      'Show AR + EN Language',
      name: 'crmShowBothLanguages',
      desc: '',
      args: [],
    );
  }

  /// `Allow Multiple Emails`
  String get crmAllowMultipleEmails {
    return Intl.message(
      'Allow Multiple Emails',
      name: 'crmAllowMultipleEmails',
      desc: '',
      args: [],
    );
  }

  /// `Max Length`
  String get crmMaxLength {
    return Intl.message('Max Length', name: 'crmMaxLength', desc: '', args: []);
  }

  /// `Max Number`
  String get crmMaxNumber {
    return Intl.message('Max Number', name: 'crmMaxNumber', desc: '', args: []);
  }

  /// `Format Example`
  String get crmFormatExample {
    return Intl.message(
      'Format Example',
      name: 'crmFormatExample',
      desc: '',
      args: [],
    );
  }

  /// `Unique`
  String get crmUnique {
    return Intl.message('Unique', name: 'crmUnique', desc: '', args: []);
  }

  /// `Trim Spaces`
  String get crmTrimSpaces {
    return Intl.message(
      'Trim Spaces',
      name: 'crmTrimSpaces',
      desc: '',
      args: [],
    );
  }

  /// `Allow Spaces`
  String get crmAllowSpaces {
    return Intl.message(
      'Allow Spaces',
      name: 'crmAllowSpaces',
      desc: '',
      args: [],
    );
  }

  /// `Address Components`
  String get crmAddressComponents {
    return Intl.message(
      'Address Components',
      name: 'crmAddressComponents',
      desc: '',
      args: [],
    );
  }

  /// `Entry Type`
  String get crmEntryType {
    return Intl.message('Entry Type', name: 'crmEntryType', desc: '', args: []);
  }

  /// `Allow Special Characters`
  String get crmAllowSpecialCharacters {
    return Intl.message(
      'Allow Special Characters',
      name: 'crmAllowSpecialCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Max Characters`
  String get crmMaxCharacters {
    return Intl.message(
      'Max Characters',
      name: 'crmMaxCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Validation`
  String get crmValidation {
    return Intl.message(
      'Validation',
      name: 'crmValidation',
      desc: '',
      args: [],
    );
  }

  /// `Make This Field Required`
  String get crmMakeFieldRequired {
    return Intl.message(
      'Make This Field Required',
      name: 'crmMakeFieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Error Message`
  String get crmErrorMessage {
    return Intl.message(
      'Error Message',
      name: 'crmErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Allow Multiple Phone`
  String get crmAllowMultiplePhone {
    return Intl.message(
      'Allow Multiple Phone',
      name: 'crmAllowMultiplePhone',
      desc: '',
      args: [],
    );
  }

  /// `Country Code`
  String get crmCountryCode {
    return Intl.message(
      'Country Code',
      name: 'crmCountryCode',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Number`
  String get crmMaximumNumber {
    return Intl.message(
      'Maximum Number',
      name: 'crmMaximumNumber',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get crmSize {
    return Intl.message('Size', name: 'crmSize', desc: '', args: []);
  }

  /// `Date Range From`
  String get crmDateRangeFrom {
    return Intl.message(
      'Date Range From',
      name: 'crmDateRangeFrom',
      desc: '',
      args: [],
    );
  }

  /// `Date Range To`
  String get crmDateRangeTo {
    return Intl.message(
      'Date Range To',
      name: 'crmDateRangeTo',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get crmFrom {
    return Intl.message('From', name: 'crmFrom', desc: '', args: []);
  }

  /// `Select Time`
  String get crmSelectTime {
    return Intl.message(
      'Select Time',
      name: 'crmSelectTime',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get crmTo {
    return Intl.message('To', name: 'crmTo', desc: '', args: []);
  }

  /// `Items`
  String get crmItems {
    return Intl.message('Items', name: 'crmItems', desc: '', args: []);
  }

  /// `Multiple Choose`
  String get crmMultipleChoose {
    return Intl.message(
      'Multiple Choose',
      name: 'crmMultipleChoose',
      desc: '',
      args: [],
    );
  }

  /// `Allow Search`
  String get crmAllowSearch {
    return Intl.message(
      'Allow Search',
      name: 'crmAllowSearch',
      desc: '',
      args: [],
    );
  }

  /// `Multiple Choice`
  String get crmMultipleChoice {
    return Intl.message(
      'Multiple Choice',
      name: 'crmMultipleChoice',
      desc: '',
      args: [],
    );
  }

  /// `Save Format`
  String get crmSaveFormat {
    return Intl.message(
      'Save Format',
      name: 'crmSaveFormat',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get crmType {
    return Intl.message('Type', name: 'crmType', desc: '', args: []);
  }

  /// `Auto Add HTTPS`
  String get crmAutoAddHttps {
    return Intl.message(
      'Auto Add HTTPS',
      name: 'crmAutoAddHttps',
      desc: '',
      args: [],
    );
  }

  /// `Format`
  String get crmFormat {
    return Intl.message('Format', name: 'crmFormat', desc: '', args: []);
  }

  /// `Add More Link`
  String get crmAddMoreLink {
    return Intl.message(
      'Add More Link',
      name: 'crmAddMoreLink',
      desc: '',
      args: [],
    );
  }

  /// `Specific Link Types`
  String get crmSpecificLinkTypes {
    return Intl.message(
      'Specific Link Types',
      name: 'crmSpecificLinkTypes',
      desc: '',
      args: [],
    );
  }

  /// `Continents`
  String get crmContinents {
    return Intl.message(
      'Continents',
      name: 'crmContinents',
      desc: '',
      args: [],
    );
  }

  /// `Countries`
  String get crmCountries {
    return Intl.message('Countries', name: 'crmCountries', desc: '', args: []);
  }

  /// `Cities`
  String get crmCities {
    return Intl.message('Cities', name: 'crmCities', desc: '', args: []);
  }

  /// `Field Type`
  String get crmFieldType {
    return Intl.message('Field Type', name: 'crmFieldType', desc: '', args: []);
  }

  /// `Add Field`
  String get crmAddField {
    return Intl.message('Add Field', name: 'crmAddField', desc: '', args: []);
  }

  /// `Retry`
  String get crmRetry {
    return Intl.message('Retry', name: 'crmRetry', desc: '', args: []);
  }

  /// `Setting`
  String get crmSetting {
    return Intl.message('Setting', name: 'crmSetting', desc: '', args: []);
  }

  /// `Category`
  String get crmCategory {
    return Intl.message('Category', name: 'crmCategory', desc: '', args: []);
  }

  /// `Edit`
  String get crmEdit {
    return Intl.message('Edit', name: 'crmEdit', desc: '', args: []);
  }

  /// `Page`
  String get crmPage {
    return Intl.message('Page', name: 'crmPage', desc: '', args: []);
  }

  /// `Preview`
  String get crmPreview {
    return Intl.message('Preview', name: 'crmPreview', desc: '', args: []);
  }

  /// `Column`
  String get crmColumn {
    return Intl.message('Column', name: 'crmColumn', desc: '', args: []);
  }

  /// `Field`
  String get crmField {
    return Intl.message('Field', name: 'crmField', desc: '', args: []);
  }

  /// `Section`
  String get crmSection {
    return Intl.message('Section', name: 'crmSection', desc: '', args: []);
  }

  /// `Select Section`
  String get crmSelectSection {
    return Intl.message(
      'Select Section',
      name: 'crmSelectSection',
      desc: '',
      args: [],
    );
  }

  /// `Select Field`
  String get crmSelectField {
    return Intl.message(
      'Select Field',
      name: 'crmSelectField',
      desc: '',
      args: [],
    );
  }

  /// `NO`
  String get crmNo {
    return Intl.message('NO', name: 'crmNo', desc: '', args: []);
  }

  /// `Photo`
  String get crmPhoto {
    return Intl.message('Photo', name: 'crmPhoto', desc: '', args: []);
  }

  /// `Code`
  String get crmCode {
    return Intl.message('Code', name: 'crmCode', desc: '', args: []);
  }

  /// `Owner`
  String get crmOwner {
    return Intl.message('Owner', name: 'crmOwner', desc: '', args: []);
  }

  /// `Next Activity`
  String get crmNextActivity {
    return Intl.message(
      'Next Activity',
      name: 'crmNextActivity',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get crmDate {
    return Intl.message('Date', name: 'crmDate', desc: '', args: []);
  }

  /// `Time`
  String get crmTime {
    return Intl.message('Time', name: 'crmTime', desc: '', args: []);
  }

  /// `Add view will be available soon`
  String get crmAddViewComingSoon {
    return Intl.message(
      'Add view will be available soon',
      name: 'crmAddViewComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Export will be available soon`
  String get crmExportComingSoon {
    return Intl.message(
      'Export will be available soon',
      name: 'crmExportComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this client record?`
  String get crmSaveClientConfirm {
    return Intl.message(
      'Are you sure you want to save this client record?',
      name: 'crmSaveClientConfirm',
      desc: '',
      args: [],
    );
  }

  /// `The new client record has been saved successfully`
  String get crmClientAddedSubtitle {
    return Intl.message(
      'The new client record has been saved successfully',
      name: 'crmClientAddedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `To add a section, select 1 column`
  String get crmToAddSectionHint {
    return Intl.message(
      'To add a section, select 1 column',
      name: 'crmToAddSectionHint',
      desc: '',
      args: [],
    );
  }

  /// `Number of Columns`
  String get crmNumberOfColumns {
    return Intl.message(
      'Number of Columns',
      name: 'crmNumberOfColumns',
      desc: '',
      args: [],
    );
  }

  /// `Choices`
  String get crmChoices {
    return Intl.message('Choices', name: 'crmChoices', desc: '', args: []);
  }

  /// `A switch can be used as a simple On/Off toggle, or you can add items to display selectable options when the switch is enabled.`
  String get crmSwitchInfoMessage {
    return Intl.message(
      'A switch can be used as a simple On/Off toggle, or you can add items to display selectable options when the switch is enabled.',
      name: 'crmSwitchInfoMessage',
      desc: '',
      args: [],
    );
  }

  /// `Constraints`
  String get crmConstraints {
    return Intl.message(
      'Constraints',
      name: 'crmConstraints',
      desc: '',
      args: [],
    );
  }

  /// `Image Types`
  String get crmImageTypes {
    return Intl.message(
      'Image Types',
      name: 'crmImageTypes',
      desc: '',
      args: [],
    );
  }

  /// `File Types`
  String get crmFileTypes {
    return Intl.message('File Types', name: 'crmFileTypes', desc: '', args: []);
  }

  /// `All Types`
  String get crmAllTypes {
    return Intl.message('All Types', name: 'crmAllTypes', desc: '', args: []);
  }

  /// `selected`
  String get crmSelected {
    return Intl.message('selected', name: 'crmSelected', desc: '', args: []);
  }

  /// `Name (A-Z)`
  String get crmSortNameAZ {
    return Intl.message(
      'Name (A-Z)',
      name: 'crmSortNameAZ',
      desc: '',
      args: [],
    );
  }

  /// `Name (Z-A)`
  String get crmSortNameZA {
    return Intl.message(
      'Name (Z-A)',
      name: 'crmSortNameZA',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get crmDetails {
    return Intl.message('Details', name: 'crmDetails', desc: '', args: []);
  }

  /// `Success`
  String get crmSuccess {
    return Intl.message('Success', name: 'crmSuccess', desc: '', args: []);
  }

  /// `Alert`
  String get crmAlert {
    return Intl.message('Alert', name: 'crmAlert', desc: '', args: []);
  }

  /// `OK`
  String get crmOK {
    return Intl.message('OK', name: 'crmOK', desc: '', args: []);
  }

  /// `Done`
  String get crmDone {
    return Intl.message('Done', name: 'crmDone', desc: '', args: []);
  }

  /// `Types:`
  String get crmTypesCount {
    return Intl.message('Types:', name: 'crmTypesCount', desc: '', args: []);
  }

  /// `Terms:`
  String get crmTermsCount {
    return Intl.message('Terms:', name: 'crmTermsCount', desc: '', args: []);
  }

  /// `By: `
  String get crmBy {
    return Intl.message('By: ', name: 'crmBy', desc: '', args: []);
  }

  /// `Relationship`
  String get crmRelationship {
    return Intl.message(
      'Relationship',
      name: 'crmRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Add Relationship`
  String get crmAddRelationship {
    return Intl.message(
      'Add Relationship',
      name: 'crmAddRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Edit Relationship`
  String get crmEditRelationship {
    return Intl.message(
      'Edit Relationship',
      name: 'crmEditRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Relationship Details`
  String get crmRelationshipDetails {
    return Intl.message(
      'Relationship Details',
      name: 'crmRelationshipDetails',
      desc: '',
      args: [],
    );
  }

  /// `Save Relationship`
  String get crmSaveRelationship {
    return Intl.message(
      'Save Relationship',
      name: 'crmSaveRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this relationship?`
  String get crmSaveRelationshipConfirm {
    return Intl.message(
      'Are you sure you want to save this relationship?',
      name: 'crmSaveRelationshipConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Remove Relationship`
  String get crmRemoveRelationship {
    return Intl.message(
      'Remove Relationship',
      name: 'crmRemoveRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this relationship completely?`
  String get crmRemoveRelationshipConfirm {
    return Intl.message(
      'Are you sure you want to delete this relationship completely?',
      name: 'crmRemoveRelationshipConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Relationship added successfully`
  String get crmRelationshipAddedSuccess {
    return Intl.message(
      'Relationship added successfully',
      name: 'crmRelationshipAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Relationship updated successfully`
  String get crmRelationshipUpdatedSuccess {
    return Intl.message(
      'Relationship updated successfully',
      name: 'crmRelationshipUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Relationship deleted successfully`
  String get crmRelationshipDeletedSuccess {
    return Intl.message(
      'Relationship deleted successfully',
      name: 'crmRelationshipDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Relationships Available`
  String get crmNoRelationshipsAvailable {
    return Intl.message(
      'No Relationships Available',
      name: 'crmNoRelationshipsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new relationship`
  String get crmRelationshipAddPrompt {
    return Intl.message(
      'Click on Add button to create a new relationship',
      name: 'crmRelationshipAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please enter relationship category name`
  String get crmPleaseEnterRelationshipName {
    return Intl.message(
      'Please enter relationship category name',
      name: 'crmPleaseEnterRelationshipName',
      desc: '',
      args: [],
    );
  }

  /// `Please add at least one type`
  String get crmPleaseAddAtLeastOneType {
    return Intl.message(
      'Please add at least one type',
      name: 'crmPleaseAddAtLeastOneType',
      desc: '',
      args: [],
    );
  }

  /// `Terms`
  String get crmTerms {
    return Intl.message('Terms', name: 'crmTerms', desc: '', args: []);
  }

  /// `Terms Details`
  String get crmTermsDetails {
    return Intl.message(
      'Terms Details',
      name: 'crmTermsDetails',
      desc: '',
      args: [],
    );
  }

  /// `Add Term`
  String get crmAddTerm {
    return Intl.message('Add Term', name: 'crmAddTerm', desc: '', args: []);
  }

  /// `Edit Term`
  String get crmEditTerm {
    return Intl.message('Edit Term', name: 'crmEditTerm', desc: '', args: []);
  }

  /// `Save Term`
  String get crmSaveTerm {
    return Intl.message('Save Term', name: 'crmSaveTerm', desc: '', args: []);
  }

  /// `Are you sure you want to save this term?`
  String get crmSaveTermConfirm {
    return Intl.message(
      'Are you sure you want to save this term?',
      name: 'crmSaveTermConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Remove Term`
  String get crmRemoveTerm {
    return Intl.message(
      'Remove Term',
      name: 'crmRemoveTerm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this term completely?`
  String get crmRemoveTermConfirm {
    return Intl.message(
      'Are you sure you want to delete this term completely?',
      name: 'crmRemoveTermConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Term added successfully`
  String get crmTermAddedSuccess {
    return Intl.message(
      'Term added successfully',
      name: 'crmTermAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Term updated successfully`
  String get crmTermUpdatedSuccess {
    return Intl.message(
      'Term updated successfully',
      name: 'crmTermUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Term deleted successfully`
  String get crmTermDeletedSuccess {
    return Intl.message(
      'Term deleted successfully',
      name: 'crmTermDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Terms Available`
  String get crmNoTermsAvailable {
    return Intl.message(
      'No Terms Available',
      name: 'crmNoTermsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new term`
  String get crmTermsAddPrompt {
    return Intl.message(
      'Click on Add button to create a new term',
      name: 'crmTermsAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please enter term name`
  String get crmPleaseEnterTermName {
    return Intl.message(
      'Please enter term name',
      name: 'crmPleaseEnterTermName',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get crmCategories {
    return Intl.message(
      'Categories',
      name: 'crmCategories',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get crmAddCategory {
    return Intl.message(
      'Add Category',
      name: 'crmAddCategory',
      desc: '',
      args: [],
    );
  }

  /// `Edit Category`
  String get crmEditCategory {
    return Intl.message(
      'Edit Category',
      name: 'crmEditCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category Details`
  String get crmCategoryDetails {
    return Intl.message(
      'Category Details',
      name: 'crmCategoryDetails',
      desc: '',
      args: [],
    );
  }

  /// `Save Category`
  String get crmSaveCategory {
    return Intl.message(
      'Save Category',
      name: 'crmSaveCategory',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save this category?`
  String get crmSaveCategoryConfirm {
    return Intl.message(
      'Are you sure you want to save this category?',
      name: 'crmSaveCategoryConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete Category`
  String get crmDeleteCategory {
    return Intl.message(
      'Delete Category',
      name: 'crmDeleteCategory',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this category?`
  String get crmDeleteCategoryConfirm {
    return Intl.message(
      'Are you sure you want to delete this category?',
      name: 'crmDeleteCategoryConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Category saved successfully`
  String get crmCategorySavedSuccess {
    return Intl.message(
      'Category saved successfully',
      name: 'crmCategorySavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Category deleted successfully`
  String get crmCategoryDeletedSuccess {
    return Intl.message(
      'Category deleted successfully',
      name: 'crmCategoryDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Categories Available`
  String get crmNoCategoriesAvailable {
    return Intl.message(
      'No Categories Available',
      name: 'crmNoCategoriesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new category`
  String get crmCategoriesAddPrompt {
    return Intl.message(
      'Click on Add button to create a new category',
      name: 'crmCategoriesAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Add Tag`
  String get crmAddTag {
    return Intl.message('Add Tag', name: 'crmAddTag', desc: '', args: []);
  }

  /// `Edit Tag`
  String get crmEditTag {
    return Intl.message('Edit Tag', name: 'crmEditTag', desc: '', args: []);
  }

  /// `Delete Tag`
  String get crmDeleteTag {
    return Intl.message('Delete Tag', name: 'crmDeleteTag', desc: '', args: []);
  }

  /// `Are you sure you want to delete this tag?`
  String get crmDeleteTagConfirm {
    return Intl.message(
      'Are you sure you want to delete this tag?',
      name: 'crmDeleteTagConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Tag saved successfully`
  String get crmTagSavedSuccess {
    return Intl.message(
      'Tag saved successfully',
      name: 'crmTagSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Tag updated successfully`
  String get crmTagUpdatedSuccess {
    return Intl.message(
      'Tag updated successfully',
      name: 'crmTagUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Tag deleted successfully`
  String get crmTagDeletedSuccess {
    return Intl.message(
      'Tag deleted successfully',
      name: 'crmTagDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Tags Available`
  String get crmNoTagsAvailable {
    return Intl.message(
      'No Tags Available',
      name: 'crmNoTagsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new tag`
  String get crmTagsAddPrompt {
    return Intl.message(
      'Click on Add button to create a new tag',
      name: 'crmTagsAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Category Name in English`
  String get crmPleaseEnterCategoryNameEn {
    return Intl.message(
      'Please enter Category Name in English',
      name: 'crmPleaseEnterCategoryNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Category Name in Arabic`
  String get crmPleaseEnterCategoryNameAr {
    return Intl.message(
      'Please enter Category Name in Arabic',
      name: 'crmPleaseEnterCategoryNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Type in English`
  String get crmPleaseEnterTypeEn {
    return Intl.message(
      'Please enter Type in English',
      name: 'crmPleaseEnterTypeEn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Type in Arabic`
  String get crmPleaseEnterTypeAr {
    return Intl.message(
      'Please enter Type in Arabic',
      name: 'crmPleaseEnterTypeAr',
      desc: '',
      args: [],
    );
  }

  /// `Please enter tag name in English`
  String get crmPleaseEnterTagNameEn {
    return Intl.message(
      'Please enter tag name in English',
      name: 'crmPleaseEnterTagNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter tag name in Arabic`
  String get crmPleaseEnterTagNameAr {
    return Intl.message(
      'Please enter tag name in Arabic',
      name: 'crmPleaseEnterTagNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Types`
  String get crmTypes {
    return Intl.message('Types', name: 'crmTypes', desc: '', args: []);
  }

  /// `Stages`
  String get crmStages {
    return Intl.message('Stages', name: 'crmStages', desc: '', args: []);
  }

  /// `Add Stage`
  String get crmAddStage {
    return Intl.message('Add Stage', name: 'crmAddStage', desc: '', args: []);
  }

  /// `Edit Stage`
  String get crmEditStage {
    return Intl.message('Edit Stage', name: 'crmEditStage', desc: '', args: []);
  }

  /// `Stage Details`
  String get crmStageDetails {
    return Intl.message(
      'Stage Details',
      name: 'crmStageDetails',
      desc: '',
      args: [],
    );
  }

  /// `Save Stage`
  String get crmSaveStage {
    return Intl.message('Save Stage', name: 'crmSaveStage', desc: '', args: []);
  }

  /// `Delete Stage`
  String get crmDeleteStage {
    return Intl.message(
      'Delete Stage',
      name: 'crmDeleteStage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this stage?`
  String get crmDeleteStageConfirm {
    return Intl.message(
      'Are you sure you want to delete this stage?',
      name: 'crmDeleteStageConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Stage saved successfully`
  String get crmStageSavedSuccess {
    return Intl.message(
      'Stage saved successfully',
      name: 'crmStageSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Stage updated successfully`
  String get crmStageUpdatedSuccess {
    return Intl.message(
      'Stage updated successfully',
      name: 'crmStageUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Stage deleted successfully`
  String get crmStageDeletedSuccess {
    return Intl.message(
      'Stage deleted successfully',
      name: 'crmStageDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Stages Available`
  String get crmNoStagesAvailable {
    return Intl.message(
      'No Stages Available',
      name: 'crmNoStagesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new stage`
  String get crmStagesAddPrompt {
    return Intl.message(
      'Click on Add button to create a new stage',
      name: 'crmStagesAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please enter stage name in English`
  String get crmPleaseEnterStageNameEn {
    return Intl.message(
      'Please enter stage name in English',
      name: 'crmPleaseEnterStageNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter stage name in Arabic`
  String get crmPleaseEnterStageNameAr {
    return Intl.message(
      'Please enter stage name in Arabic',
      name: 'crmPleaseEnterStageNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Probability`
  String get crmProbability {
    return Intl.message(
      'Probability',
      name: 'crmProbability',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get crmDealCategory {
    return Intl.message(
      'Category',
      name: 'crmDealCategory',
      desc: '',
      args: [],
    );
  }

  /// `Stage`
  String get crmDealStage {
    return Intl.message('Stage', name: 'crmDealStage', desc: '', args: []);
  }

  /// `Discounts`
  String get crmDiscounts {
    return Intl.message('Discounts', name: 'crmDiscounts', desc: '', args: []);
  }

  /// `Add Discount`
  String get crmAddDiscount {
    return Intl.message(
      'Add Discount',
      name: 'crmAddDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Edit Discount`
  String get crmEditDiscount {
    return Intl.message(
      'Edit Discount',
      name: 'crmEditDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Edit Rule`
  String get crmEditRule {
    return Intl.message('Edit Rule', name: 'crmEditRule', desc: '', args: []);
  }

  /// `Rule`
  String get crmRule {
    return Intl.message('Rule', name: 'crmRule', desc: '', args: []);
  }

  /// `Rule Details`
  String get crmRuleDetails {
    return Intl.message(
      'Rule Details',
      name: 'crmRuleDetails',
      desc: '',
      args: [],
    );
  }

  /// `Rule Name`
  String get crmRuleName {
    return Intl.message('Rule Name', name: 'crmRuleName', desc: '', args: []);
  }

  /// `اسم القاعدة`
  String get crmRuleNameAr {
    return Intl.message(
      'اسم القاعدة',
      name: 'crmRuleNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Discount Details`
  String get crmDiscountDetails {
    return Intl.message(
      'Discount Details',
      name: 'crmDiscountDetails',
      desc: '',
      args: [],
    );
  }

  /// `Products Category`
  String get crmProductsCategory {
    return Intl.message(
      'Products Category',
      name: 'crmProductsCategory',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Quantity`
  String get crmMinimumQuantity {
    return Intl.message(
      'Minimum Quantity',
      name: 'crmMinimumQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Quantity`
  String get crmMaximumQuantity {
    return Intl.message(
      'Maximum Quantity',
      name: 'crmMaximumQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Discount Value`
  String get crmDiscountValue {
    return Intl.message(
      'Discount Value',
      name: 'crmDiscountValue',
      desc: '',
      args: [],
    );
  }

  /// `Apply on Team`
  String get crmApplyOnTeam {
    return Intl.message(
      'Apply on Team',
      name: 'crmApplyOnTeam',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this discount rule?`
  String get crmDeleteDiscountConfirm {
    return Intl.message(
      'Are you sure you want to delete this discount rule?',
      name: 'crmDeleteDiscountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Discount rule saved successfully`
  String get crmDiscountSavedSuccess {
    return Intl.message(
      'Discount rule saved successfully',
      name: 'crmDiscountSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Discount rule updated successfully`
  String get crmDiscountUpdatedSuccess {
    return Intl.message(
      'Discount rule updated successfully',
      name: 'crmDiscountUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Discount rule deleted successfully`
  String get crmDiscountDeletedSuccess {
    return Intl.message(
      'Discount rule deleted successfully',
      name: 'crmDiscountDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No Discounts Available`
  String get crmNoDiscountsAvailable {
    return Intl.message(
      'No Discounts Available',
      name: 'crmNoDiscountsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Click on Add button to create a new discount rule`
  String get crmDiscountsAddPrompt {
    return Intl.message(
      'Click on Add button to create a new discount rule',
      name: 'crmDiscountsAddPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please enter rule name in English`
  String get crmPleaseEnterRuleNameEn {
    return Intl.message(
      'Please enter rule name in English',
      name: 'crmPleaseEnterRuleNameEn',
      desc: '',
      args: [],
    );
  }

  /// `Please enter rule name in Arabic`
  String get crmPleaseEnterRuleNameAr {
    return Intl.message(
      'Please enter rule name in Arabic',
      name: 'crmPleaseEnterRuleNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid discount value`
  String get crmPleaseEnterDiscountValue {
    return Intl.message(
      'Please enter a valid discount value',
      name: 'crmPleaseEnterDiscountValue',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get crmPleaseSelectCategory {
    return Intl.message(
      'Please select a category',
      name: 'crmPleaseSelectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Teams`
  String get crmTeams {
    return Intl.message('Teams', name: 'crmTeams', desc: '', args: []);
  }

  /// `Value`
  String get crmValue {
    return Intl.message('Value', name: 'crmValue', desc: '', args: []);
  }

  /// `Service`
  String get crmService {
    return Intl.message('Service', name: 'crmService', desc: '', args: []);
  }

  /// `Product`
  String get crmProduct {
    return Intl.message('Product', name: 'crmProduct', desc: '', args: []);
  }

  /// `Both`
  String get crmBoth {
    return Intl.message('Both', name: 'crmBoth', desc: '', args: []);
  }

  /// `Percentage (%)`
  String get crmPercentage {
    return Intl.message(
      'Percentage (%)',
      name: 'crmPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Fixed Amount`
  String get crmFixedAmount {
    return Intl.message(
      'Fixed Amount',
      name: 'crmFixedAmount',
      desc: '',
      args: [],
    );
  }

  /// `This field is required.`
  String get fieldRequired {
    return Intl.message(
      'This field is required.',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Names cannot exceed 20 characters.`
  String get nameMaxLength {
    return Intl.message(
      'Names cannot exceed 20 characters.',
      name: 'nameMaxLength',
      desc: '',
      args: [],
    );
  }

  /// `Numbers cannot exceed 10 digits.`
  String get numberMaxLength {
    return Intl.message(
      'Numbers cannot exceed 10 digits.',
      name: 'numberMaxLength',
      desc: '',
      args: [],
    );
  }

  /// `Only numbers are allowed.`
  String get onlyNumbersAllowed {
    return Intl.message(
      'Only numbers are allowed.',
      name: 'onlyNumbersAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Contractor`
  String get contractor {
    return Intl.message('Contractor', name: 'contractor', desc: '', args: []);
  }

  /// `Onsite`
  String get onsite {
    return Intl.message('Onsite', name: 'onsite', desc: '', args: []);
  }

  /// `Fully Remote`
  String get fullyRemote {
    return Intl.message(
      'Fully Remote',
      name: 'fullyRemote',
      desc: '',
      args: [],
    );
  }

  /// `Partially Remote`
  String get partiallyRemote {
    return Intl.message(
      'Partially Remote',
      name: 'partiallyRemote',
      desc: '',
      args: [],
    );
  }

  /// `Not Remote`
  String get notRemote {
    return Intl.message('Not Remote', name: 'notRemote', desc: '', args: []);
  }

  /// `Headquarters`
  String get headquarters {
    return Intl.message(
      'Headquarters',
      name: 'headquarters',
      desc: '',
      args: [],
    );
  }

  /// `Branch Office`
  String get branchOffice {
    return Intl.message(
      'Branch Office',
      name: 'branchOffice',
      desc: '',
      args: [],
    );
  }

  /// `Intern`
  String get intern {
    return Intl.message('Intern', name: 'intern', desc: '', args: []);
  }

  /// `Junior`
  String get junior {
    return Intl.message('Junior', name: 'junior', desc: '', args: []);
  }

  /// `Mid`
  String get mid {
    return Intl.message('Mid', name: 'mid', desc: '', args: []);
  }

  /// `Senior`
  String get senior {
    return Intl.message('Senior', name: 'senior', desc: '', args: []);
  }

  /// `Lead`
  String get lead {
    return Intl.message('Lead', name: 'lead', desc: '', args: []);
  }

  /// `Friday/Saturday`
  String get fridaySaturday {
    return Intl.message(
      'Friday/Saturday',
      name: 'fridaySaturday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday/Sunday`
  String get saturdaySunday {
    return Intl.message(
      'Saturday/Sunday',
      name: 'saturdaySunday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday/Monday`
  String get sundayMonday {
    return Intl.message(
      'Sunday/Monday',
      name: 'sundayMonday',
      desc: '',
      args: [],
    );
  }

  /// `USD`
  String get usd {
    return Intl.message('USD', name: 'usd', desc: '', args: []);
  }

  /// `EUR`
  String get eur {
    return Intl.message('EUR', name: 'eur', desc: '', args: []);
  }

  /// `CNY`
  String get cny {
    return Intl.message('CNY', name: 'cny', desc: '', args: []);
  }

  /// `GBP`
  String get gbp {
    return Intl.message('GBP', name: 'gbp', desc: '', args: []);
  }

  /// `CHF`
  String get chf {
    return Intl.message('CHF', name: 'chf', desc: '', args: []);
  }

  /// `JPY`
  String get jpy {
    return Intl.message('JPY', name: 'jpy', desc: '', args: []);
  }

  /// `INR`
  String get inr {
    return Intl.message('INR', name: 'inr', desc: '', args: []);
  }

  /// `CAD`
  String get cad {
    return Intl.message('CAD', name: 'cad', desc: '', args: []);
  }

  /// `AUD`
  String get aud {
    return Intl.message('AUD', name: 'aud', desc: '', args: []);
  }

  /// `AED`
  String get aed {
    return Intl.message('AED', name: 'aed', desc: '', args: []);
  }

  /// `SAR`
  String get sar {
    return Intl.message('SAR', name: 'sar', desc: '', args: []);
  }

  /// `QAR`
  String get qar {
    return Intl.message('QAR', name: 'qar', desc: '', args: []);
  }

  /// `KWD`
  String get kwd {
    return Intl.message('KWD', name: 'kwd', desc: '', args: []);
  }

  /// `BHD`
  String get bhd {
    return Intl.message('BHD', name: 'bhd', desc: '', args: []);
  }

  /// `OMR`
  String get omr {
    return Intl.message('OMR', name: 'omr', desc: '', args: []);
  }

  /// `EGP`
  String get egp {
    return Intl.message('EGP', name: 'egp', desc: '', args: []);
  }

  /// `JOD`
  String get jod {
    return Intl.message('JOD', name: 'jod', desc: '', args: []);
  }

  /// `MAD`
  String get mad {
    return Intl.message('MAD', name: 'mad', desc: '', args: []);
  }

  /// `DZD`
  String get dzd {
    return Intl.message('DZD', name: 'dzd', desc: '', args: []);
  }

  /// `TND`
  String get tnd {
    return Intl.message('TND', name: 'tnd', desc: '', args: []);
  }

  /// `IQD`
  String get iqd {
    return Intl.message('IQD', name: 'iqd', desc: '', args: []);
  }

  /// `ILS`
  String get ils {
    return Intl.message('ILS', name: 'ils', desc: '', args: []);
  }

  /// `LBP`
  String get lbp {
    return Intl.message('LBP', name: 'lbp', desc: '', args: []);
  }

  /// `LYD`
  String get lyd {
    return Intl.message('LYD', name: 'lyd', desc: '', args: []);
  }

  /// `SYP`
  String get syp {
    return Intl.message('SYP', name: 'syp', desc: '', args: []);
  }

  /// `YER`
  String get yer {
    return Intl.message('YER', name: 'yer', desc: '', args: []);
  }

  /// `TRY`
  String get tryCurrency {
    return Intl.message('TRY', name: 'tryCurrency', desc: '', args: []);
  }

  /// `High School`
  String get highSchool {
    return Intl.message('High School', name: 'highSchool', desc: '', args: []);
  }

  /// `Bachelor's`
  String get bachelor {
    return Intl.message('Bachelor\'s', name: 'bachelor', desc: '', args: []);
  }

  /// `Master's`
  String get master {
    return Intl.message('Master\'s', name: 'master', desc: '', args: []);
  }

  /// `Doctorate`
  String get doctorate {
    return Intl.message('Doctorate', name: 'doctorate', desc: '', args: []);
  }

  /// `Professional Certification`
  String get professionalCertification {
    return Intl.message(
      'Professional Certification',
      name: 'professionalCertification',
      desc: '',
      args: [],
    );
  }

  /// `Business`
  String get business {
    return Intl.message('Business', name: 'business', desc: '', args: []);
  }

  /// `Engineering`
  String get engineering {
    return Intl.message('Engineering', name: 'engineering', desc: '', args: []);
  }

  /// `University`
  String get university {
    return Intl.message('University', name: 'university', desc: '', args: []);
  }

  /// `Accredited Institute`
  String get accreditedInstitute {
    return Intl.message(
      'Accredited Institute',
      name: 'accreditedInstitute',
      desc: '',
      args: [],
    );
  }

  /// `Professional Body`
  String get professionalBody {
    return Intl.message(
      'Professional Body',
      name: 'professionalBody',
      desc: '',
      args: [],
    );
  }

  /// `Parent`
  String get parent {
    return Intl.message('Parent', name: 'parent', desc: '', args: []);
  }

  /// `Spouse`
  String get spouse {
    return Intl.message('Spouse', name: 'spouse', desc: '', args: []);
  }

  /// `Sibling`
  String get sibling {
    return Intl.message('Sibling', name: 'sibling', desc: '', args: []);
  }

  /// `Child`
  String get child {
    return Intl.message('Child', name: 'child', desc: '', args: []);
  }

  /// `Relative`
  String get relative {
    return Intl.message('Relative', name: 'relative', desc: '', args: []);
  }

  /// `Insurance Provider Contact`
  String get insuranceProviderContact {
    return Intl.message(
      'Insurance Provider Contact',
      name: 'insuranceProviderContact',
      desc: '',
      args: [],
    );
  }

  /// `Employee Grade`
  String get employeeGrade {
    return Intl.message(
      'Employee Grade',
      name: 'employeeGrade',
      desc: '',
      args: [],
    );
  }

  /// `Work Arrangement`
  String get workArrangement {
    return Intl.message(
      'Work Arrangement',
      name: 'workArrangement',
      desc: '',
      args: [],
    );
  }

  /// `Remote Status`
  String get remoteStatus {
    return Intl.message(
      'Remote Status',
      name: 'remoteStatus',
      desc: '',
      args: [],
    );
  }

  /// `Grade or Score`
  String get gradeOrScore {
    return Intl.message(
      'Grade or Score',
      name: 'gradeOrScore',
      desc: '',
      args: [],
    );
  }

  /// `Certificate ID`
  String get certificateId {
    return Intl.message(
      'Certificate ID',
      name: 'certificateId',
      desc: '',
      args: [],
    );
  }

  /// `Issuing Authority`
  String get issuingAuthority {
    return Intl.message(
      'Issuing Authority',
      name: 'issuingAuthority',
      desc: '',
      args: [],
    );
  }

  /// `First Emergency Contact`
  String get firstEmergencyContact {
    return Intl.message(
      'First Emergency Contact',
      name: 'firstEmergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `Field of Study`
  String get fieldOfStudy {
    return Intl.message(
      'Field of Study',
      name: 'fieldOfStudy',
      desc: '',
      args: [],
    );
  }

  /// `End date must not be before start date.`
  String get endDateBeforeStartDate {
    return Intl.message(
      'End date must not be before start date.',
      name: 'endDateBeforeStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Only Excel files (.xlsx or .xls) are supported.`
  String get employeeBulkUnsupportedFile {
    return Intl.message(
      'Only Excel files (.xlsx or .xls) are supported.',
      name: 'employeeBulkUnsupportedFile',
      desc: '',
      args: [],
    );
  }

  /// `No files were dropped.`
  String get employeeBulkNoDroppedFiles {
    return Intl.message(
      'No files were dropped.',
      name: 'employeeBulkNoDroppedFiles',
      desc: '',
      args: [],
    );
  }

  /// `The selected file could not be read. Please choose it again.`
  String get employeeBulkFileReadFailure {
    return Intl.message(
      'The selected file could not be read. Please choose it again.',
      name: 'employeeBulkFileReadFailure',
      desc: '',
      args: [],
    );
  }

  /// `The workbook does not contain a usable worksheet.`
  String get employeeBulkEmptyWorkbook {
    return Intl.message(
      'The workbook does not contain a usable worksheet.',
      name: 'employeeBulkEmptyWorkbook',
      desc: '',
      args: [],
    );
  }

  /// `The spreadsheet headers must exactly match the employee template and order.`
  String get employeeBulkHeaderMismatch {
    return Intl.message(
      'The spreadsheet headers must exactly match the employee template and order.',
      name: 'employeeBulkHeaderMismatch',
      desc: '',
      args: [],
    );
  }

  /// `The spreadsheet does not contain employee rows.`
  String get employeeBulkNoRows {
    return Intl.message(
      'The spreadsheet does not contain employee rows.',
      name: 'employeeBulkNoRows',
      desc: '',
      args: [],
    );
  }

  /// `A bulk upload can contain at most 50 employees.`
  String get employeeBulkRowLimit {
    return Intl.message(
      'A bulk upload can contain at most 50 employees.',
      name: 'employeeBulkRowLimit',
      desc: '',
      args: [],
    );
  }

  /// `The Excel file could not be read. It may be corrupted or invalid.`
  String get employeeBulkInvalidWorkbook {
    return Intl.message(
      'The Excel file could not be read. It may be corrupted or invalid.',
      name: 'employeeBulkInvalidWorkbook',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID is duplicated in this file.`
  String get employeeBulkDuplicateEmployeeId {
    return Intl.message(
      'Employee ID is duplicated in this file.',
      name: 'employeeBulkDuplicateEmployeeId',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID already exists.`
  String get employeeBulkExistingEmployeeId {
    return Intl.message(
      'Employee ID already exists.',
      name: 'employeeBulkExistingEmployeeId',
      desc: '',
      args: [],
    );
  }

  /// `Email is duplicated in this file.`
  String get employeeBulkDuplicateEmail {
    return Intl.message(
      'Email is duplicated in this file.',
      name: 'employeeBulkDuplicateEmail',
      desc: '',
      args: [],
    );
  }

  /// `Email already belongs to an employee.`
  String get employeeBulkExistingEmail {
    return Intl.message(
      'Email already belongs to an employee.',
      name: 'employeeBulkExistingEmail',
      desc: '',
      args: [],
    );
  }

  /// `The literal value null is not allowed.`
  String get employeeBulkNullNotAllowed {
    return Intl.message(
      'The literal value null is not allowed.',
      name: 'employeeBulkNullNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `National ID must contain 9 to 14 digits.`
  String get employeeBulkInvalidNationalId {
    return Intl.message(
      'National ID must contain 9 to 14 digits.',
      name: 'employeeBulkInvalidNationalId',
      desc: '',
      args: [],
    );
  }

  /// `Passport must contain 8 to 11 letters or digits.`
  String get employeeBulkInvalidPassport {
    return Intl.message(
      'Passport must contain 8 to 11 letters or digits.',
      name: 'employeeBulkInvalidPassport',
      desc: '',
      args: [],
    );
  }

  /// `Gender must be male or female.`
  String get employeeBulkInvalidGender {
    return Intl.message(
      'Gender must be male or female.',
      name: 'employeeBulkInvalidGender',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid postal code.`
  String get employeeBulkInvalidPostalCode {
    return Intl.message(
      'Enter a valid postal code.',
      name: 'employeeBulkInvalidPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `Martial Status must be single, married, divorced, or widowed.`
  String get employeeBulkInvalidMaritalStatus {
    return Intl.message(
      'Martial Status must be single, married, divorced, or widowed.',
      name: 'employeeBulkInvalidMaritalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Use unique comma-separated values without empty items.`
  String get employeeBulkInvalidList {
    return Intl.message(
      'Use unique comma-separated values without empty items.',
      name: 'employeeBulkInvalidList',
      desc: '',
      args: [],
    );
  }

  /// `Supervisor email was not found.`
  String get employeeBulkSupervisorNotFound {
    return Intl.message(
      'Supervisor email was not found.',
      name: 'employeeBulkSupervisorNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Role does not exist or is inactive.`
  String get employeeBulkRoleNotFound {
    return Intl.message(
      'Role does not exist or is inactive.',
      name: 'employeeBulkRoleNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Department ID and names do not identify the same department.`
  String get employeeBulkDepartmentConflict {
    return Intl.message(
      'Department ID and names do not identify the same department.',
      name: 'employeeBulkDepartmentConflict',
      desc: '',
      args: [],
    );
  }

  /// `Bulk Upload Employees`
  String get employeeBulkUploadTitle {
    return Intl.message(
      'Bulk Upload Employees',
      name: 'employeeBulkUploadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bulk Upload Health Insurance`
  String get healthInsuranceBulkUploadTitle {
    return Intl.message(
      'Bulk Upload Health Insurance',
      name: 'healthInsuranceBulkUploadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload health insurance`
  String get healthInsuranceBulkUploadAction {
    return Intl.message(
      'Upload health insurance',
      name: 'healthInsuranceBulkUploadAction',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID is duplicated in this file.`
  String get healthInsuranceBulkDuplicateEmployee {
    return Intl.message(
      'Employee ID is duplicated in this file.',
      name: 'healthInsuranceBulkDuplicateEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID was not found.`
  String get healthInsuranceBulkEmployeeNotFound {
    return Intl.message(
      'Employee ID was not found.',
      name: 'healthInsuranceBulkEmployeeNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Employee information does not match the stored personal information.`
  String get healthInsuranceBulkIdentityMismatch {
    return Intl.message(
      'Employee information does not match the stored personal information.',
      name: 'healthInsuranceBulkIdentityMismatch',
      desc: '',
      args: [],
    );
  }

  /// `The health-insurance workbook headers do not match the required template.`
  String get healthInsuranceBulkHeaderMismatch {
    return Intl.message(
      'The health-insurance workbook headers do not match the required template.',
      name: 'healthInsuranceBulkHeaderMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Employee information could not be verified. No changes were saved.`
  String get healthInsuranceBulkPreflightFailure {
    return Intl.message(
      'Employee information could not be verified. No changes were saved.',
      name: 'healthInsuranceBulkPreflightFailure',
      desc: '',
      args: [],
    );
  }

  /// `Health-insurance information uploaded successfully.`
  String get healthInsuranceBulkUploadSuccess {
    return Intl.message(
      'Health-insurance information uploaded successfully.',
      name: 'healthInsuranceBulkUploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Some health-insurance rows could not be uploaded.`
  String get healthInsuranceBulkUploadPartial {
    return Intl.message(
      'Some health-insurance rows could not be uploaded.',
      name: 'healthInsuranceBulkUploadPartial',
      desc: '',
      args: [],
    );
  }

  /// `Updated employees`
  String get healthInsuranceBulkUpdatedCount {
    return Intl.message(
      'Updated employees',
      name: 'healthInsuranceBulkUpdatedCount',
      desc: '',
      args: [],
    );
  }

  /// `Failed rows`
  String get healthInsuranceBulkFailedCount {
    return Intl.message(
      'Failed rows',
      name: 'healthInsuranceBulkFailedCount',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop files here`
  String get employeeBulkDropFile {
    return Intl.message(
      'Drag & Drop files here',
      name: 'employeeBulkDropFile',
      desc: '',
      args: [],
    );
  }

  /// `Use the exact employee template headers. Maximum 50 employees.`
  String get employeeBulkFileGuidance {
    return Intl.message(
      'Use the exact employee template headers. Maximum 50 employees.',
      name: 'employeeBulkFileGuidance',
      desc: '',
      args: [],
    );
  }

  /// `Total employees`
  String get employeeBulkTotalEmployees {
    return Intl.message(
      'Total employees',
      name: 'employeeBulkTotalEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Total errors`
  String get employeeBulkTotalErrors {
    return Intl.message(
      'Total errors',
      name: 'employeeBulkTotalErrors',
      desc: '',
      args: [],
    );
  }

  /// `Add row`
  String get employeeBulkAddRow {
    return Intl.message(
      'Add row',
      name: 'employeeBulkAddRow',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate selected`
  String get employeeBulkDuplicateRow {
    return Intl.message(
      'Duplicate selected',
      name: 'employeeBulkDuplicateRow',
      desc: '',
      args: [],
    );
  }

  /// `Remove selected`
  String get employeeBulkRemoveRows {
    return Intl.message(
      'Remove selected',
      name: 'employeeBulkRemoveRows',
      desc: '',
      args: [],
    );
  }

  /// `Next error`
  String get employeeBulkNextError {
    return Intl.message(
      'Next error',
      name: 'employeeBulkNextError',
      desc: '',
      args: [],
    );
  }

  /// `Replace file`
  String get employeeBulkReplaceFile {
    return Intl.message(
      'Replace file',
      name: 'employeeBulkReplaceFile',
      desc: '',
      args: [],
    );
  }

  /// `No data is saved until every row is valid. The complete upload is committed together.`
  String get employeeBulkAtomicNotice {
    return Intl.message(
      'No data is saved until every row is valid. The complete upload is committed together.',
      name: 'employeeBulkAtomicNotice',
      desc: '',
      args: [],
    );
  }

  /// `Create employees?`
  String get employeeBulkConfirmTitle {
    return Intl.message(
      'Create employees?',
      name: 'employeeBulkConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `This will create all employees, access records, and new departments in one atomic upload.`
  String get employeeBulkConfirmMessage {
    return Intl.message(
      'This will create all employees, access records, and new departments in one atomic upload.',
      name: 'employeeBulkConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Existing employees will not be updated.`
  String get employeeBulkExistingUnaffected {
    return Intl.message(
      'Existing employees will not be updated.',
      name: 'employeeBulkExistingUnaffected',
      desc: '',
      args: [],
    );
  }

  /// `Upload employees`
  String get employeeBulkUploadAction {
    return Intl.message(
      'Upload employees',
      name: 'employeeBulkUploadAction',
      desc: '',
      args: [],
    );
  }

  /// `Employees uploaded successfully.`
  String get employeeBulkUploadSuccess {
    return Intl.message(
      'Employees uploaded successfully.',
      name: 'employeeBulkUploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `The upload failed and no changes were saved.`
  String get employeeBulkUploadFailure {
    return Intl.message(
      'The upload failed and no changes were saved.',
      name: 'employeeBulkUploadFailure',
      desc: '',
      args: [],
    );
  }

  /// `Current employee, role, or department data could not be verified. No changes were saved.`
  String get employeeBulkPreflightFailure {
    return Intl.message(
      'Current employee, role, or department data could not be verified. No changes were saved.',
      name: 'employeeBulkPreflightFailure',
      desc: '',
      args: [],
    );
  }

  /// `Editing Employee Details`
  String get editingEmployeeDetails {
    return Intl.message(
      'Editing Employee Details',
      name: 'editingEmployeeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Employee's Shift?`
  String get confirmEditEmployeeShift {
    return Intl.message(
      'Are You Sure You Want To Edit This Employee\'s Shift?',
      name: 'confirmEditEmployeeShift',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Employee's Shift`
  String get successfullyEditedEmployeeShift {
    return Intl.message(
      'You Successfully Edited This Employee\'s Shift',
      name: 'successfullyEditedEmployeeShift',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit These Employees' Shifts?`
  String get confirmEditEmployeesShift {
    return Intl.message(
      'Are You Sure You Want To Edit These Employees\' Shifts?',
      name: 'confirmEditEmployeesShift',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited These Employees' Shifts`
  String get successfullyEditedEmployeesShifts {
    return Intl.message(
      'You Successfully Edited These Employees\' Shifts',
      name: 'successfullyEditedEmployeesShifts',
      desc: '',
      args: [],
    );
  }

  /// `No employees selected`
  String get noEmployeesSelected {
    return Intl.message(
      'No employees selected',
      name: 'noEmployeesSelected',
      desc: '',
      args: [],
    );
  }

  /// `Job Grade`
  String get jobGrade {
    return Intl.message('Job Grade', name: 'jobGrade', desc: '', args: []);
  }

  /// `Shift Starts`
  String get shiftStarts {
    return Intl.message(
      'Shift Starts',
      name: 'shiftStarts',
      desc: '',
      args: [],
    );
  }

  /// `Structure`
  String get structure {
    return Intl.message('Structure', name: 'structure', desc: '', args: []);
  }

  /// `Branches`
  String get branches {
    return Intl.message('Branches', name: 'branches', desc: '', args: []);
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `View Departments`
  String get viewDepartments {
    return Intl.message(
      'View Departments',
      name: 'viewDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Add Shift`
  String get addShift {
    return Intl.message('Add Shift', name: 'addShift', desc: '', args: []);
  }

  /// `Adding New Employee`
  String get addingNewEmployee {
    return Intl.message(
      'Adding New Employee',
      name: 'addingNewEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Arabic job title translation is required`
  String get arabicJobTitleTranslationRequired {
    return Intl.message(
      'Arabic job title translation is required',
      name: 'arabicJobTitleTranslationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabicLanguage {
    return Intl.message('Arabic', name: 'arabicLanguage', desc: '', args: []);
  }

  /// `Please enter Arabic text only`
  String get arabicTextOnlyError {
    return Intl.message(
      'Please enter Arabic text only',
      name: 'arabicTextOnlyError',
      desc: '',
      args: [],
    );
  }

  /// `Assign Shift`
  String get assignShift {
    return Intl.message(
      'Assign Shift',
      name: 'assignShift',
      desc: '',
      args: [],
    );
  }

  /// `Attendance Compliance`
  String get attendanceCompliance {
    return Intl.message(
      'Attendance Compliance',
      name: 'attendanceCompliance',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get average {
    return Intl.message('Average', name: 'average', desc: '', args: []);
  }

  /// `Bengali`
  String get bengaliLanguage {
    return Intl.message('Bengali', name: 'bengaliLanguage', desc: '', args: []);
  }

  /// `Business Email`
  String get businessEmail {
    return Intl.message(
      'Business Email',
      name: 'businessEmail',
      desc: '',
      args: [],
    );
  }

  /// `This business email is already registered`
  String get businessEmailAlreadyExists {
    return Intl.message(
      'This business email is already registered',
      name: 'businessEmailAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Car Plate`
  String get carPlate {
    return Intl.message('Car Plate', name: 'carPlate', desc: '', args: []);
  }

  /// `Certification Details`
  String get certificationDetails {
    return Intl.message(
      'Certification Details',
      name: 'certificationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to assign this shift?`
  String get confirmAssignShift {
    return Intl.message(
      'Are you sure you want to assign this shift?',
      name: 'confirmAssignShift',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to create this location?`
  String get confirmCreateLocation {
    return Intl.message(
      'Are you sure you want to create this location?',
      name: 'confirmCreateLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to save these changes?`
  String get confirmSaveEmployeeChanges {
    return Intl.message(
      'Are you sure you want to save these changes?',
      name: 'confirmSaveEmployeeChanges',
      desc: '',
      args: [],
    );
  }

  /// `Contact Details`
  String get contactDetails {
    return Intl.message(
      'Contact Details',
      name: 'contactDetails',
      desc: '',
      args: [],
    );
  }

  /// `Arabic department name is required`
  String get departmentArabicNameBilingualRequired {
    return Intl.message(
      'Arabic department name is required',
      name: 'departmentArabicNameBilingualRequired',
      desc: '',
      args: [],
    );
  }

  /// `Department Employees`
  String get departmentEmployees {
    return Intl.message(
      'Department Employees',
      name: 'departmentEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Department name is required`
  String get departmentNameAssignmentRequired {
    return Intl.message(
      'Department name is required',
      name: 'departmentNameAssignmentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Deselect All`
  String get deselectAll {
    return Intl.message(
      'Deselect All',
      name: 'deselectAll',
      desc: '',
      args: [],
    );
  }

  /// `Document URL`
  String get documentUrl {
    return Intl.message(
      'Document URL',
      name: 'documentUrl',
      desc: '',
      args: [],
    );
  }

  /// `Driving License ID`
  String get drivingLicenseId {
    return Intl.message(
      'Driving License ID',
      name: 'drivingLicenseId',
      desc: '',
      args: [],
    );
  }

  /// `Emergency Details`
  String get emergencyDetails {
    return Intl.message(
      'Emergency Details',
      name: 'emergencyDetails',
      desc: '',
      args: [],
    );
  }

  /// `First Name (Arabic)`
  String get employeeArabicFirstName {
    return Intl.message(
      'First Name (Arabic)',
      name: 'employeeArabicFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name (Arabic)`
  String get employeeArabicLastName {
    return Intl.message(
      'Last Name (Arabic)',
      name: 'employeeArabicLastName',
      desc: '',
      args: [],
    );
  }

  /// `Middle Name (Arabic)`
  String get employeeArabicMiddleName {
    return Intl.message(
      'Middle Name (Arabic)',
      name: 'employeeArabicMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter the name in Arabic`
  String get employeeArabicNameHint {
    return Intl.message(
      'Enter the name in Arabic',
      name: 'employeeArabicNameHint',
      desc: '',
      args: [],
    );
  }

  /// `The employee was created, but the list could not be refreshed`
  String get employeeCreatedButRefreshFailed {
    return Intl.message(
      'The employee was created, but the list could not be refreshed',
      name: 'employeeCreatedButRefreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Employee Created Successfully`
  String get employeeCreatedSuccessfully {
    return Intl.message(
      'Employee Created Successfully',
      name: 'employeeCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `The new employee has been added to your organization.`
  String get employeeCreatedSuccessfullyDescription {
    return Intl.message(
      'The new employee has been added to your organization.',
      name: 'employeeCreatedSuccessfullyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create the employee`
  String get employeeCreationFailed {
    return Intl.message(
      'Failed to create the employee',
      name: 'employeeCreationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Employee details updated successfully`
  String get employeeDetailsUpdatedSuccessfully {
    return Intl.message(
      'Employee details updated successfully',
      name: 'employeeDetailsUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `First Name (English)`
  String get employeeEnglishFirstName {
    return Intl.message(
      'First Name (English)',
      name: 'employeeEnglishFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name (English)`
  String get employeeEnglishLastName {
    return Intl.message(
      'Last Name (English)',
      name: 'employeeEnglishLastName',
      desc: '',
      args: [],
    );
  }

  /// `Middle Name (English)`
  String get employeeEnglishMiddleName {
    return Intl.message(
      'Middle Name (English)',
      name: 'employeeEnglishMiddleName',
      desc: '',
      args: [],
    );
  }

  /// `Enter the name in English`
  String get employeeEnglishNameHint {
    return Intl.message(
      'Enter the name in English',
      name: 'employeeEnglishNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload the employee's files`
  String get employeeFileUploadFailed {
    return Intl.message(
      'Failed to upload the employee\'s files',
      name: 'employeeFileUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Employee ID`
  String get employeeId {
    return Intl.message('Employee ID', name: 'employeeId', desc: '', args: []);
  }

  /// `This employee ID is already registered`
  String get employeeIdAlreadyExists {
    return Intl.message(
      'This employee ID is already registered',
      name: 'employeeIdAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Job title is required`
  String get employeeJobTitleRequired {
    return Intl.message(
      'Job title is required',
      name: 'employeeJobTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Employee Operations`
  String get employeeOperations {
    return Intl.message(
      'Employee Operations',
      name: 'employeeOperations',
      desc: '',
      args: [],
    );
  }

  /// `Employee role is required`
  String get employeeRoleRequired {
    return Intl.message(
      'Employee role is required',
      name: 'employeeRoleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Employees per Location`
  String get employeesPerLocation {
    return Intl.message(
      'Employees per Location',
      name: 'employeesPerLocation',
      desc: '',
      args: [],
    );
  }

  /// `Experience data is unavailable`
  String get experienceDataUnavailable {
    return Intl.message(
      'Experience data is unavailable',
      name: 'experienceDataUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Experience in Organization`
  String get experienceInOrganization {
    return Intl.message(
      'Experience in Organization',
      name: 'experienceInOrganization',
      desc: '',
      args: [],
    );
  }

  /// `Extension`
  String get extension {
    return Intl.message('Extension', name: 'extension', desc: '', args: []);
  }

  /// `Hebrew`
  String get hebrewLanguage {
    return Intl.message('Hebrew', name: 'hebrewLanguage', desc: '', args: []);
  }

  /// `Hindi`
  String get hindiLanguage {
    return Intl.message('Hindi', name: 'hindiLanguage', desc: '', args: []);
  }

  /// `Home Number`
  String get homeNumber {
    return Intl.message('Home Number', name: 'homeNumber', desc: '', args: []);
  }

  /// `Identification Details`
  String get identificationDetails {
    return Intl.message(
      'Identification Details',
      name: 'identificationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Invalid employee ID`
  String get invalidEmployeeId {
    return Intl.message(
      'Invalid employee ID',
      name: 'invalidEmployeeId',
      desc: '',
      args: [],
    );
  }

  /// `Kurdish`
  String get kurdishLanguage {
    return Intl.message('Kurdish', name: 'kurdishLanguage', desc: '', args: []);
  }

  /// `Location Name (Arabic)`
  String get locationNameArabic {
    return Intl.message(
      'Location Name (Arabic)',
      name: 'locationNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `Location Name (English)`
  String get locationNameEnglish {
    return Intl.message(
      'Location Name (English)',
      name: 'locationNameEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Malayalam`
  String get malayalamLanguage {
    return Intl.message(
      'Malayalam',
      name: 'malayalamLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Maximum`
  String get maximum {
    return Intl.message('Maximum', name: 'maximum', desc: '', args: []);
  }

  /// `Minimum`
  String get minimum {
    return Intl.message('Minimum', name: 'minimum', desc: '', args: []);
  }

  /// `National ID`
  String get nationalId {
    return Intl.message('National ID', name: 'nationalId', desc: '', args: []);
  }

  /// `National ID Expiration`
  String get nationalIdExpiration {
    return Intl.message(
      'National ID Expiration',
      name: 'nationalIdExpiration',
      desc: '',
      args: [],
    );
  }

  /// `Nationalities`
  String get nationalities {
    return Intl.message(
      'Nationalities',
      name: 'nationalities',
      desc: '',
      args: [],
    );
  }

  /// `No age data available`
  String get noAgeDataAvailable {
    return Intl.message(
      'No age data available',
      name: 'noAgeDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No experience data available`
  String get noExperienceDataAvailable {
    return Intl.message(
      'No experience data available',
      name: 'noExperienceDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Office Number`
  String get officeNumber {
    return Intl.message(
      'Office Number',
      name: 'officeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Onboarding Employees`
  String get onboardingEmployees {
    return Intl.message(
      'Onboarding Employees',
      name: 'onboardingEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Passport`
  String get passport {
    return Intl.message('Passport', name: 'passport', desc: '', args: []);
  }

  /// `Passport Expiration`
  String get passportExpiration {
    return Intl.message(
      'Passport Expiration',
      name: 'passportExpiration',
      desc: '',
      args: [],
    );
  }

  /// `Persian`
  String get persianLanguage {
    return Intl.message('Persian', name: 'persianLanguage', desc: '', args: []);
  }

  /// `The personal and business emails must be different`
  String get personalAndBusinessEmailsMustDiffer {
    return Intl.message(
      'The personal and business emails must be different',
      name: 'personalAndBusinessEmailsMustDiffer',
      desc: '',
      args: [],
    );
  }

  /// `Personal Email`
  String get personalEmail {
    return Intl.message(
      'Personal Email',
      name: 'personalEmail',
      desc: '',
      args: [],
    );
  }

  /// `This personal email is already registered`
  String get personalEmailAlreadyExists {
    return Intl.message(
      'This personal email is already registered',
      name: 'personalEmailAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Profile Change`
  String get profileChange {
    return Intl.message(
      'Profile Change',
      name: 'profileChange',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Leave`
  String get scheduledLeave {
    return Intl.message(
      'Scheduled Leave',
      name: 'scheduledLeave',
      desc: '',
      args: [],
    );
  }

  /// `Please select a branch`
  String get shiftBranchRequired {
    return Intl.message(
      'Please select a branch',
      name: 'shiftBranchRequired',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create the shift`
  String get shiftCreationFailed {
    return Intl.message(
      'Failed to create the shift',
      name: 'shiftCreationFailed',
      desc: '',
      args: [],
    );
  }

  /// `These working hours have already been added`
  String get shiftDuplicateWorkingHours {
    return Intl.message(
      'These working hours have already been added',
      name: 'shiftDuplicateWorkingHours',
      desc: '',
      args: [],
    );
  }

  /// `Please select a location`
  String get shiftLocationRequired {
    return Intl.message(
      'Please select a location',
      name: 'shiftLocationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please set the shift start and end times`
  String get shiftTimesRequired {
    return Intl.message(
      'Please set the shift start and end times',
      name: 'shiftTimesRequired',
      desc: '',
      args: [],
    );
  }

  /// `Shifts`
  String get shifts {
    return Intl.message('Shifts', name: 'shifts', desc: '', args: []);
  }

  /// `Shifts Management`
  String get shiftsManagement {
    return Intl.message(
      'Shifts Management',
      name: 'shiftsManagement',
      desc: '',
      args: [],
    );
  }

  /// `Tagalog`
  String get tagalogLanguage {
    return Intl.message('Tagalog', name: 'tagalogLanguage', desc: '', args: []);
  }

  /// `Tracking Attendance`
  String get trackingAttendance {
    return Intl.message(
      'Tracking Attendance',
      name: 'trackingAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Updated At`
  String get updatedAt {
    return Intl.message('Updated At', name: 'updatedAt', desc: '', args: []);
  }

  /// `Upload Driving License`
  String get uploadDrivingLicenseId {
    return Intl.message(
      'Upload Driving License',
      name: 'uploadDrivingLicenseId',
      desc: '',
      args: [],
    );
  }

  /// `Upload National ID (Back)`
  String get uploadNationalIdBack {
    return Intl.message(
      'Upload National ID (Back)',
      name: 'uploadNationalIdBack',
      desc: '',
      args: [],
    );
  }

  /// `Upload National ID (Front)`
  String get uploadNationalIdFront {
    return Intl.message(
      'Upload National ID (Front)',
      name: 'uploadNationalIdFront',
      desc: '',
      args: [],
    );
  }

  /// `Upload Passport`
  String get uploadPassport {
    return Intl.message(
      'Upload Passport',
      name: 'uploadPassport',
      desc: '',
      args: [],
    );
  }

  /// `Urdu`
  String get urduLanguage {
    return Intl.message('Urdu', name: 'urduLanguage', desc: '', args: []);
  }

  /// `Which section do you want to change?`
  String get whichSectionDoYouWantToChange {
    return Intl.message(
      'Which section do you want to change?',
      name: 'whichSectionDoYouWantToChange',
      desc: '',
      args: [],
    );
  }

  /// `Workforce`
  String get workforce {
    return Intl.message('Workforce', name: 'workforce', desc: '', args: []);
  }

  /// `More Options`
  String get moreOptions {
    return Intl.message(
      'More Options',
      name: 'moreOptions',
      desc: '',
      args: [],
    );
  }

  /// `Steps to reproduce`
  String get stepsToReproduce {
    return Intl.message(
      'Steps to reproduce',
      name: 'stepsToReproduce',
      desc: '',
      args: [],
    );
  }

  /// `Requested Feedback`
  String get requestedFeedback {
    return Intl.message(
      'Requested Feedback',
      name: 'requestedFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Module`
  String get module {
    return Intl.message('Module', name: 'module', desc: '', args: []);
  }

  /// `Screen / Section`
  String get screenSection {
    return Intl.message(
      'Screen / Section',
      name: 'screenSection',
      desc: '',
      args: [],
    );
  }

  /// `Design Issue`
  String get designIssue {
    return Intl.message(
      'Design Issue',
      name: 'designIssue',
      desc: '',
      args: [],
    );
  }

  /// `Logic Issue`
  String get logicIssue {
    return Intl.message('Logic Issue', name: 'logicIssue', desc: '', args: []);
  }

  /// `Software Type`
  String get softwareType {
    return Intl.message(
      'Software Type',
      name: 'softwareType',
      desc: '',
      args: [],
    );
  }

  /// `Device`
  String get device {
    return Intl.message('Device', name: 'device', desc: '', args: []);
  }

  /// `Select screen`
  String get selectScreenSection {
    return Intl.message(
      'Select screen',
      name: 'selectScreenSection',
      desc: '',
      args: [],
    );
  }

  /// `Select design issue`
  String get selectDesignIssue {
    return Intl.message(
      'Select design issue',
      name: 'selectDesignIssue',
      desc: '',
      args: [],
    );
  }

  /// `Select logic issue`
  String get selectLogicIssue {
    return Intl.message(
      'Select logic issue',
      name: 'selectLogicIssue',
      desc: '',
      args: [],
    );
  }

  /// `Select device`
  String get selectDevice {
    return Intl.message(
      'Select device',
      name: 'selectDevice',
      desc: '',
      args: [],
    );
  }

  /// `Select software type`
  String get selectSoftwareType {
    return Intl.message(
      'Select software type',
      name: 'selectSoftwareType',
      desc: '',
      args: [],
    );
  }

  /// `Select frequency`
  String get selectFrequency {
    return Intl.message(
      'Select frequency',
      name: 'selectFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Describe the steps you took`
  String get describeTheStepsYouTook {
    return Intl.message(
      'Describe the steps you took',
      name: 'describeTheStepsYouTook',
      desc: '',
      args: [],
    );
  }

  /// `Form Builder`
  String get formBuilder {
    return Intl.message(
      'Form Builder',
      name: 'formBuilder',
      desc: '',
      args: [],
    );
  }

  /// `Database`
  String get database {
    return Intl.message('Database', name: 'database', desc: '', args: []);
  }

  /// `Leave Request → Approval`
  String get leaveRequestApproval {
    return Intl.message(
      'Leave Request → Approval',
      name: 'leaveRequestApproval',
      desc: '',
      args: [],
    );
  }

  /// `Leave Request → New`
  String get leaveRequestNew {
    return Intl.message(
      'Leave Request → New',
      name: 'leaveRequestNew',
      desc: '',
      args: [],
    );
  }

  /// `Leave Request → List`
  String get leaveRequestList {
    return Intl.message(
      'Leave Request → List',
      name: 'leaveRequestList',
      desc: '',
      args: [],
    );
  }

  /// `Business Trip`
  String get businessTrip {
    return Intl.message(
      'Business Trip',
      name: 'businessTrip',
      desc: '',
      args: [],
    );
  }

  /// `Expense Claim`
  String get expenseClaim {
    return Intl.message(
      'Expense Claim',
      name: 'expenseClaim',
      desc: '',
      args: [],
    );
  }

  /// `Certificate Request`
  String get certificateRequest {
    return Intl.message(
      'Certificate Request',
      name: 'certificateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Layout & Alignment`
  String get layoutAlignment {
    return Intl.message(
      'Layout & Alignment',
      name: 'layoutAlignment',
      desc: '',
      args: [],
    );
  }

  /// `Colours & Contrast`
  String get coloursContrast {
    return Intl.message(
      'Colours & Contrast',
      name: 'coloursContrast',
      desc: '',
      args: [],
    );
  }

  /// `Text & Font`
  String get textFont {
    return Intl.message('Text & Font', name: 'textFont', desc: '', args: []);
  }

  /// `Icons & Images`
  String get iconsImages {
    return Intl.message(
      'Icons & Images',
      name: 'iconsImages',
      desc: '',
      args: [],
    );
  }

  /// `Spacing & Sizing`
  String get spacingSizing {
    return Intl.message(
      'Spacing & Sizing',
      name: 'spacingSizing',
      desc: '',
      args: [],
    );
  }

  /// `Arabic / RTL Layout`
  String get arabicRtlLayout {
    return Intl.message(
      'Arabic / RTL Layout',
      name: 'arabicRtlLayout',
      desc: '',
      args: [],
    );
  }

  /// `Doesn't Fit My Screen`
  String get doesntFitMyScreen {
    return Intl.message(
      'Doesn\'t Fit My Screen',
      name: 'doesntFitMyScreen',
      desc: '',
      args: [],
    );
  }

  /// `Other Design Issue`
  String get otherDesignIssue {
    return Intl.message(
      'Other Design Issue',
      name: 'otherDesignIssue',
      desc: '',
      args: [],
    );
  }

  /// `Button / Action Not Working`
  String get buttonActionNotWorking {
    return Intl.message(
      'Button / Action Not Working',
      name: 'buttonActionNotWorking',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Result or Calculation`
  String get wrongResultOrCalculation {
    return Intl.message(
      'Wrong Result or Calculation',
      name: 'wrongResultOrCalculation',
      desc: '',
      args: [],
    );
  }

  /// `Data Not Saving`
  String get dataNotSaving {
    return Intl.message(
      'Data Not Saving',
      name: 'dataNotSaving',
      desc: '',
      args: [],
    );
  }

  /// `Data Not Loading`
  String get dataNotLoading {
    return Intl.message(
      'Data Not Loading',
      name: 'dataNotLoading',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Validation Message`
  String get wrongValidationMessage {
    return Intl.message(
      'Wrong Validation Message',
      name: 'wrongValidationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Access Denied Wrongly`
  String get accessDeniedWrongly {
    return Intl.message(
      'Access Denied Wrongly',
      name: 'accessDeniedWrongly',
      desc: '',
      args: [],
    );
  }

  /// `Notification Not Received`
  String get notificationNotReceived {
    return Intl.message(
      'Notification Not Received',
      name: 'notificationNotReceived',
      desc: '',
      args: [],
    );
  }

  /// `Duplicated or Out of Sync`
  String get duplicatedOrOutOfSync {
    return Intl.message(
      'Duplicated or Out of Sync',
      name: 'duplicatedOrOutOfSync',
      desc: '',
      args: [],
    );
  }

  /// `Crash or Freeze`
  String get crashOrFreeze {
    return Intl.message(
      'Crash or Freeze',
      name: 'crashOrFreeze',
      desc: '',
      args: [],
    );
  }

  /// `Other Logic Issue`
  String get otherLogicIssue {
    return Intl.message(
      'Other Logic Issue',
      name: 'otherLogicIssue',
      desc: '',
      args: [],
    );
  }

  /// `iPhone`
  String get iphone {
    return Intl.message('iPhone', name: 'iphone', desc: '', args: []);
  }

  /// `iPad`
  String get ipad {
    return Intl.message('iPad', name: 'ipad', desc: '', args: []);
  }

  /// `Android Phone`
  String get androidPhone {
    return Intl.message(
      'Android Phone',
      name: 'androidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Android Tablet`
  String get androidTablet {
    return Intl.message(
      'Android Tablet',
      name: 'androidTablet',
      desc: '',
      args: [],
    );
  }

  /// `Windows Laptop / Desktop`
  String get windowsLaptopDesktop {
    return Intl.message(
      'Windows Laptop / Desktop',
      name: 'windowsLaptopDesktop',
      desc: '',
      args: [],
    );
  }

  /// `Mac Laptop / Desktop`
  String get macLaptopDesktop {
    return Intl.message(
      'Mac Laptop / Desktop',
      name: 'macLaptopDesktop',
      desc: '',
      args: [],
    );
  }

  /// `Web Browser`
  String get webBrowser {
    return Intl.message('Web Browser', name: 'webBrowser', desc: '', args: []);
  }

  /// `iOS`
  String get ios {
    return Intl.message('iOS', name: 'ios', desc: '', args: []);
  }

  /// `iPadOS`
  String get ipados {
    return Intl.message('iPadOS', name: 'ipados', desc: '', args: []);
  }

  /// `Android`
  String get android {
    return Intl.message('Android', name: 'android', desc: '', args: []);
  }

  /// `Windows`
  String get windows {
    return Intl.message('Windows', name: 'windows', desc: '', args: []);
  }

  /// `macOS`
  String get macos {
    return Intl.message('macOS', name: 'macos', desc: '', args: []);
  }

  /// `Web / Browser`
  String get webOrBrowser {
    return Intl.message(
      'Web / Browser',
      name: 'webOrBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Every Time`
  String get everyTime {
    return Intl.message('Every Time', name: 'everyTime', desc: '', args: []);
  }

  /// `Most Of The Time`
  String get mostOfTheTime {
    return Intl.message(
      'Most Of The Time',
      name: 'mostOfTheTime',
      desc: '',
      args: [],
    );
  }

  /// `Rarely`
  String get rarely {
    return Intl.message('Rarely', name: 'rarely', desc: '', args: []);
  }

  /// `Happened Once`
  String get happenedOnce {
    return Intl.message(
      'Happened Once',
      name: 'happenedOnce',
      desc: '',
      args: [],
    );
  }

  /// `You created this group`
  String get youCreatedThisGroup {
    return Intl.message(
      'You created this group',
      name: 'youCreatedThisGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit Notification`
  String get editNotification {
    return Intl.message(
      'Edit Notification',
      name: 'editNotification',
      desc: '',
      args: [],
    );
  }

  /// `Edit Push Notification Messages`
  String get editPushNotificationMessages {
    return Intl.message(
      'Edit Push Notification Messages',
      name: 'editPushNotificationMessages',
      desc: '',
      args: [],
    );
  }

  /// `Edit Email Notification Messages`
  String get editEmailNotificationMessages {
    return Intl.message(
      'Edit Email Notification Messages',
      name: 'editEmailNotificationMessages',
      desc: '',
      args: [],
    );
  }

  /// `Change Notification Status`
  String get changeNotificationStatus {
    return Intl.message(
      'Change Notification Status',
      name: 'changeNotificationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Change Notification Channel`
  String get changeNotificationChannel {
    return Intl.message(
      'Change Notification Channel',
      name: 'changeNotificationChannel',
      desc: '',
      args: [],
    );
  }

  /// `Controls and Management`
  String get controlsAndManagement {
    return Intl.message(
      'Controls and Management',
      name: 'controlsAndManagement',
      desc: '',
      args: [],
    );
  }

  /// `Employees Matches`
  String get employeesMatches {
    return Intl.message(
      'Employees Matches',
      name: 'employeesMatches',
      desc: '',
      args: [],
    );
  }

  /// `Preview Export`
  String get previewExport {
    return Intl.message(
      'Preview Export',
      name: 'previewExport',
      desc: '',
      args: [],
    );
  }

  /// `Date Range`
  String get dateRange {
    return Intl.message('Date Range', name: 'dateRange', desc: '', args: []);
  }

  /// `Last 7 Days`
  String get last7Days {
    return Intl.message('Last 7 Days', name: 'last7Days', desc: '', args: []);
  }

  /// `Last 30 Days`
  String get last30Days {
    return Intl.message('Last 30 Days', name: 'last30Days', desc: '', args: []);
  }

  /// `Column To Export`
  String get columnToExport {
    return Intl.message(
      'Column To Export',
      name: 'columnToExport',
      desc: '',
      args: [],
    );
  }

  /// `Select City`
  String get selectCity {
    return Intl.message('Select City', name: 'selectCity', desc: '', args: []);
  }

  /// `Select Action`
  String get selectAction {
    return Intl.message(
      'Select Action',
      name: 'selectAction',
      desc: '',
      args: [],
    );
  }

  /// `Select Column`
  String get selectColumn {
    return Intl.message(
      'Select Column',
      name: 'selectColumn',
      desc: '',
      args: [],
    );
  }

  /// `Old Assigned Controls`
  String get oldAssignedControls {
    return Intl.message(
      'Old Assigned Controls',
      name: 'oldAssignedControls',
      desc: '',
      args: [],
    );
  }

  /// `New Assigned Controls`
  String get newAssignedControls {
    return Intl.message(
      'New Assigned Controls',
      name: 'newAssignedControls',
      desc: '',
      args: [],
    );
  }

  /// `Editing Controls`
  String get editingControls {
    return Intl.message(
      'Editing Controls',
      name: 'editingControls',
      desc: '',
      args: [],
    );
  }

  /// `Your file has been exported`
  String get grcFileExported {
    return Intl.message(
      'Your file has been exported',
      name: 'grcFileExported',
      desc: '',
      args: [],
    );
  }

  /// `Control Name (Arabic)`
  String get controlNameArabic {
    return Intl.message(
      'Control Name (Arabic)',
      name: 'controlNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `To Do List`
  String get todo {
    return Intl.message('To Do List', name: 'todo', desc: '', args: []);
  }

  /// `To Do List`
  String get toDoListTitle {
    return Intl.message(
      'To Do List',
      name: 'toDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `To-Do List`
  String get homeScreenToDoListTitle {
    return Intl.message(
      'To-Do List',
      name: 'homeScreenToDoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `To-Do`
  String get toDo {
    return Intl.message('To-Do', name: 'toDo', desc: '', args: []);
  }

  /// `To Do Permissions`
  String get toDoPermissions {
    return Intl.message(
      'To Do Permissions',
      name: 'toDoPermissions',
      desc: '',
      args: [],
    );
  }

  /// `View To Do`
  String get viewToDo {
    return Intl.message('View To Do', name: 'viewToDo', desc: '', args: []);
  }

  /// `Create To Do`
  String get createToDo {
    return Intl.message('Create To Do', name: 'createToDo', desc: '', args: []);
  }

  /// `Edit To Do`
  String get editToDo {
    return Intl.message('Edit To Do', name: 'editToDo', desc: '', args: []);
  }

  /// `Delete To Do`
  String get deleteToDo {
    return Intl.message('Delete To Do', name: 'deleteToDo', desc: '', args: []);
  }

  /// `Restore To Do`
  String get restoreToDo {
    return Intl.message(
      'Restore To Do',
      name: 'restoreToDo',
      desc: '',
      args: [],
    );
  }

  /// `To Do List Details`
  String get toDoListDetails {
    return Intl.message(
      'To Do List Details',
      name: 'toDoListDetails',
      desc: '',
      args: [],
    );
  }

  /// `Completion Date`
  String get todoCompletionDate {
    return Intl.message(
      'Completion Date',
      name: 'todoCompletionDate',
      desc: '',
      args: [],
    );
  }

  /// `Deletion Date`
  String get todoDeletionDate {
    return Intl.message(
      'Deletion Date',
      name: 'todoDeletionDate',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled: {date} At {time}`
  String todoScheduledAt(Object date, Object time) {
    return Intl.message(
      'Scheduled: $date At $time',
      name: 'todoScheduledAt',
      desc: '',
      args: [date, time],
    );
  }

  /// `Frequency: {value}`
  String todoFrequencyBadge(Object value) {
    return Intl.message(
      'Frequency: $value',
      name: 'todoFrequencyBadge',
      desc: '',
      args: [value],
    );
  }

  /// `Every {count} {unit}`
  String todoEveryInterval(Object count, Object unit) {
    return Intl.message(
      'Every $count $unit',
      name: 'todoEveryInterval',
      desc: '',
      args: [count, unit],
    );
  }

  /// `Mark as done`
  String get todoMarkDone {
    return Intl.message(
      'Mark as done',
      name: 'todoMarkDone',
      desc: '',
      args: [],
    );
  }

  /// `Add an item`
  String get todoItemHint {
    return Intl.message(
      'Add an item',
      name: 'todoItemHint',
      desc: '',
      args: [],
    );
  }

  /// `Remove item`
  String get todoRemoveItem {
    return Intl.message(
      'Remove item',
      name: 'todoRemoveItem',
      desc: '',
      args: [],
    );
  }

  /// `This to-do no longer exists.`
  String get todoNotFound {
    return Intl.message(
      'This to-do no longer exists.',
      name: 'todoNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Creating To Do List`
  String get creatingToDoList {
    return Intl.message(
      'Creating To Do List',
      name: 'creatingToDoList',
      desc: '',
      args: [],
    );
  }

  /// `Creating To Do`
  String get creatingToDoTitle {
    return Intl.message(
      'Creating To Do',
      name: 'creatingToDoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Creating To Do`
  String get creatingToDodialoge {
    return Intl.message(
      'Creating To Do',
      name: 'creatingToDodialoge',
      desc: '',
      args: [],
    );
  }

  /// `Editing To Do List`
  String get editingToDoList {
    return Intl.message(
      'Editing To Do List',
      name: 'editingToDoList',
      desc: '',
      args: [],
    );
  }

  /// `Editing To Do`
  String get editingToDoTitle {
    return Intl.message(
      'Editing To Do',
      name: 'editingToDoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Editing To Do`
  String get editingToDodialog {
    return Intl.message(
      'Editing To Do',
      name: 'editingToDodialog',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get todoChoose {
    return Intl.message('Choose', name: 'todoChoose', desc: '', args: []);
  }

  /// `DD/MM/YYYY`
  String get todoDateHint {
    return Intl.message('DD/MM/YYYY', name: 'todoDateHint', desc: '', args: []);
  }

  /// `00:00`
  String get todoTimeHint {
    return Intl.message('00:00', name: 'todoTimeHint', desc: '', args: []);
  }

  /// `The end date must be after the start date.`
  String get todoEndAfterStart {
    return Intl.message(
      'The end date must be after the start date.',
      name: 'todoEndAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `Start and end dates are required.`
  String get todoDatesRequired {
    return Intl.message(
      'Start and end dates are required.',
      name: 'todoDatesRequired',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one day.`
  String get todoWeekDaysRequired {
    return Intl.message(
      'Select at least one day.',
      name: 'todoWeekDaysRequired',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get todoWeekUnit {
    return Intl.message('Week', name: 'todoWeekUnit', desc: '', args: []);
  }

  /// `Day`
  String get todoDayUnit {
    return Intl.message('Day', name: 'todoDayUnit', desc: '', args: []);
  }

  /// `Set Frequency`
  String get setFrequency {
    return Intl.message(
      'Set Frequency',
      name: 'setFrequency',
      desc: '',
      args: [],
    );
  }

  /// `First Reminder`
  String get firstReminder {
    return Intl.message(
      'First Reminder',
      name: 'firstReminder',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message('Daily', name: 'daily', desc: '', args: []);
  }

  /// `Monthly`
  String get monthly {
    return Intl.message('Monthly', name: 'monthly', desc: '', args: []);
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `Are you sure you would like to proceed with creating this to-do?`
  String get areYouSureYouWouldLikeToProceedWithCreatingToDo {
    return Intl.message(
      'Are you sure you would like to proceed with creating this to-do?',
      name: 'areYouSureYouWouldLikeToProceedWithCreatingToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created New To Do`
  String get youSuccessfullyCreatedNewToDo {
    return Intl.message(
      'You Successfully Created New To Do',
      name: 'youSuccessfullyCreatedNewToDo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you would like to proceed with editing this to-do?`
  String get areYouSureYouWouldLikeToProceedWithEditingToDo {
    return Intl.message(
      'Are you sure you would like to proceed with editing this to-do?',
      name: 'areYouSureYouWouldLikeToProceedWithEditingToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited The To Do`
  String get youSuccessfullyEditedTheToDo {
    return Intl.message(
      'You Successfully Edited The To Do',
      name: 'youSuccessfullyEditedTheToDo',
      desc: '',
      args: [],
    );
  }

  /// `Deleting To Do List`
  String get deletingToDoList {
    return Intl.message(
      'Deleting To Do List',
      name: 'deletingToDoList',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This List To Do?`
  String get areYouSureYouWantToDeleteThisListToDo {
    return Intl.message(
      'Are You Sure You Want To Delete This List To Do?',
      name: 'areYouSureYouWantToDeleteThisListToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This To Do`
  String get youSuccessfullyDeletedThisToDo {
    return Intl.message(
      'You Successfully Deleted This To Do',
      name: 'youSuccessfullyDeletedThisToDo',
      desc: '',
      args: [],
    );
  }

  /// `Restoring To Do`
  String get restoringToDo {
    return Intl.message(
      'Restoring To Do',
      name: 'restoringToDo',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Restore This List To Do?`
  String get areYouSureYouWantToRestoreThisListToDo {
    return Intl.message(
      'Are You Sure You Want To Restore This List To Do?',
      name: 'areYouSureYouWantToRestoreThisListToDo',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Restored This To Do`
  String get youSuccessfullyRestoredThisToDo {
    return Intl.message(
      'You Successfully Restored This To Do',
      name: 'youSuccessfullyRestoredThisToDo',
      desc: '',
      args: [],
    );
  }

  /// `No open to-dos`
  String get todoHomeNoOpen {
    return Intl.message(
      'No open to-dos',
      name: 'todoHomeNoOpen',
      desc: '',
      args: [],
    );
  }

  /// `You don't have access to the To Do List.`
  String get todoNoAccess {
    return Intl.message(
      'You don\'t have access to the To Do List.',
      name: 'todoNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission for this action.`
  String get todoNoPermission {
    return Intl.message(
      'You don\'t have permission for this action.',
      name: 'todoNoPermission',
      desc: '',
      args: [],
    );
  }

  /// `Could not load your to-dos.`
  String get todoLoadError {
    return Intl.message(
      'Could not load your to-dos.',
      name: 'todoLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Could not save the to-do. Please try again.`
  String get todoSaveError {
    return Intl.message(
      'Could not save the to-do. Please try again.',
      name: 'todoSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Demo tools`
  String get todoDebugTools {
    return Intl.message(
      'Demo tools',
      name: 'todoDebugTools',
      desc: '',
      args: [],
    );
  }

  /// `Available in debug builds only. Due reminders arrive about three minutes after loading the demo to-dos.`
  String get todoDebugToolsHint {
    return Intl.message(
      'Available in debug builds only. Due reminders arrive about three minutes after loading the demo to-dos.',
      name: 'todoDebugToolsHint',
      desc: '',
      args: [],
    );
  }

  /// `Load demo to-dos`
  String get todoDebugLoad {
    return Intl.message(
      'Load demo to-dos',
      name: 'todoDebugLoad',
      desc: '',
      args: [],
    );
  }

  /// `{count} demo to-dos added. Reminders will arrive in about three minutes.`
  String todoDebugLoadDone(Object count) {
    return Intl.message(
      '$count demo to-dos added. Reminders will arrive in about three minutes.',
      name: 'todoDebugLoadDone',
      desc: '',
      args: [count],
    );
  }

  /// `Send due reminders now`
  String get todoDebugSweep {
    return Intl.message(
      'Send due reminders now',
      name: 'todoDebugSweep',
      desc: '',
      args: [],
    );
  }

  /// `{count} reminders sent.`
  String todoDebugSweepDone(Object count) {
    return Intl.message(
      '$count reminders sent.',
      name: 'todoDebugSweepDone',
      desc: '',
      args: [count],
    );
  }

  /// `Remove demo to-dos`
  String get todoDebugRemove {
    return Intl.message(
      'Remove demo to-dos',
      name: 'todoDebugRemove',
      desc: '',
      args: [],
    );
  }

  /// `{count} demo to-dos removed.`
  String todoDebugRemoveDone(Object count) {
    return Intl.message(
      '$count demo to-dos removed.',
      name: 'todoDebugRemoveDone',
      desc: '',
      args: [count],
    );
  }

  /// `The action could not be completed. Please try again.`
  String get todoDebugFailed {
    return Intl.message(
      'The action could not be completed. Please try again.',
      name: 'todoDebugFailed',
      desc: '',
      args: [],
    );
  }

  /// `Check In & Out`
  String get timeTrackerCheckInPermissions {
    return Intl.message(
      'Check In & Out',
      name: 'timeTrackerCheckInPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get timeTrackerDashboardPermissions {
    return Intl.message(
      'Dashboard',
      name: 'timeTrackerDashboardPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get timeTrackerAttendancePermissions {
    return Intl.message(
      'Attendance',
      name: 'timeTrackerAttendancePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get timeTrackerRequestPermissions {
    return Intl.message(
      'Requests',
      name: 'timeTrackerRequestPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Approvals`
  String get timeTrackerApprovalPermissions {
    return Intl.message(
      'Approvals',
      name: 'timeTrackerApprovalPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Request Types`
  String get timeTrackerRequestTypePermissions {
    return Intl.message(
      'Request Types',
      name: 'timeTrackerRequestTypePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get timeTrackerLocationPermissions {
    return Intl.message(
      'Locations',
      name: 'timeTrackerLocationPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get timeTrackerEmployeePermissions {
    return Intl.message(
      'Employees',
      name: 'timeTrackerEmployeePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get timeTrackerGroupPermissions {
    return Intl.message(
      'Groups',
      name: 'timeTrackerGroupPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balance`
  String get timeTrackerVacationBalancePermissions {
    return Intl.message(
      'Vacation Balance',
      name: 'timeTrackerVacationBalancePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Check In and Out`
  String get timeTrackerCheckInAndOut {
    return Intl.message(
      'Check In and Out',
      name: 'timeTrackerCheckInAndOut',
      desc: '',
      args: [],
    );
  }

  /// `Work From a Different Location`
  String get timeTrackerWorkFromDifferentLocation {
    return Intl.message(
      'Work From a Different Location',
      name: 'timeTrackerWorkFromDifferentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Personal Dashboard`
  String get timeTrackerPersonalDashboard {
    return Intl.message(
      'Personal Dashboard',
      name: 'timeTrackerPersonalDashboard',
      desc: '',
      args: [],
    );
  }

  /// `HR Dashboard`
  String get timeTrackerHrDashboard {
    return Intl.message(
      'HR Dashboard',
      name: 'timeTrackerHrDashboard',
      desc: '',
      args: [],
    );
  }

  /// `HR Dashboard — All Departments`
  String get timeTrackerHrDashboardAllDepartments {
    return Intl.message(
      'HR Dashboard — All Departments',
      name: 'timeTrackerHrDashboardAllDepartments',
      desc: '',
      args: [],
    );
  }

  /// `HR Dashboard — Filter by Employee`
  String get timeTrackerHrDashboardFilterByEmployee {
    return Intl.message(
      'HR Dashboard — Filter by Employee',
      name: 'timeTrackerHrDashboardFilterByEmployee',
      desc: '',
      args: [],
    );
  }

  /// `View Attendance`
  String get timeTrackerViewAttendance {
    return Intl.message(
      'View Attendance',
      name: 'timeTrackerViewAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Request Transaction`
  String get timeTrackerRequestTransaction {
    return Intl.message(
      'Request Transaction',
      name: 'timeTrackerRequestTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Transaction`
  String get timeTrackerCancelTransaction {
    return Intl.message(
      'Cancel Transaction',
      name: 'timeTrackerCancelTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Export Attendance`
  String get timeTrackerExportAttendance {
    return Intl.message(
      'Export Attendance',
      name: 'timeTrackerExportAttendance',
      desc: '',
      args: [],
    );
  }

  /// `View Requests`
  String get timeTrackerViewRequests {
    return Intl.message(
      'View Requests',
      name: 'timeTrackerViewRequests',
      desc: '',
      args: [],
    );
  }

  /// `Create Request`
  String get timeTrackerCreateRequest {
    return Intl.message(
      'Create Request',
      name: 'timeTrackerCreateRequest',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request`
  String get timeTrackerCancelRequest {
    return Intl.message(
      'Cancel Request',
      name: 'timeTrackerCancelRequest',
      desc: '',
      args: [],
    );
  }

  /// `Send Reminder`
  String get timeTrackerSendRequestReminder {
    return Intl.message(
      'Send Reminder',
      name: 'timeTrackerSendRequestReminder',
      desc: '',
      args: [],
    );
  }

  /// `Comment on Requests`
  String get timeTrackerCommentOnRequests {
    return Intl.message(
      'Comment on Requests',
      name: 'timeTrackerCommentOnRequests',
      desc: '',
      args: [],
    );
  }

  /// `Export Requests`
  String get timeTrackerExportRequests {
    return Intl.message(
      'Export Requests',
      name: 'timeTrackerExportRequests',
      desc: '',
      args: [],
    );
  }

  /// `View Approvals`
  String get timeTrackerViewApprovals {
    return Intl.message(
      'View Approvals',
      name: 'timeTrackerViewApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Approve and Reject`
  String get timeTrackerApproveAndReject {
    return Intl.message(
      'Approve and Reject',
      name: 'timeTrackerApproveAndReject',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Request After Approving`
  String get timeTrackerCancelRequestAfterApproving {
    return Intl.message(
      'Cancel Request After Approving',
      name: 'timeTrackerCancelRequestAfterApproving',
      desc: '',
      args: [],
    );
  }

  /// `Approvals — All Departments`
  String get timeTrackerApprovalsAllDepartments {
    return Intl.message(
      'Approvals — All Departments',
      name: 'timeTrackerApprovalsAllDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Comment on Approvals`
  String get timeTrackerCommentOnApprovals {
    return Intl.message(
      'Comment on Approvals',
      name: 'timeTrackerCommentOnApprovals',
      desc: '',
      args: [],
    );
  }

  /// `View Request Types`
  String get timeTrackerViewRequestTypes {
    return Intl.message(
      'View Request Types',
      name: 'timeTrackerViewRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Create Request Type`
  String get timeTrackerCreateRequestType {
    return Intl.message(
      'Create Request Type',
      name: 'timeTrackerCreateRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Edit Request Type`
  String get timeTrackerEditRequestType {
    return Intl.message(
      'Edit Request Type',
      name: 'timeTrackerEditRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Change Request Type Status`
  String get timeTrackerChangeRequestTypeStatus {
    return Intl.message(
      'Change Request Type Status',
      name: 'timeTrackerChangeRequestTypeStatus',
      desc: '',
      args: [],
    );
  }

  /// `Remove Request Type`
  String get timeTrackerRemoveRequestType {
    return Intl.message(
      'Remove Request Type',
      name: 'timeTrackerRemoveRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Export Request Types`
  String get timeTrackerExportRequestTypes {
    return Intl.message(
      'Export Request Types',
      name: 'timeTrackerExportRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `View Locations`
  String get timeTrackerViewLocations {
    return Intl.message(
      'View Locations',
      name: 'timeTrackerViewLocations',
      desc: '',
      args: [],
    );
  }

  /// `Create Location`
  String get timeTrackerCreateLocation {
    return Intl.message(
      'Create Location',
      name: 'timeTrackerCreateLocation',
      desc: '',
      args: [],
    );
  }

  /// `Edit Location`
  String get timeTrackerEditLocation {
    return Intl.message(
      'Edit Location',
      name: 'timeTrackerEditLocation',
      desc: '',
      args: [],
    );
  }

  /// `Change Location Status`
  String get timeTrackerChangeLocationStatus {
    return Intl.message(
      'Change Location Status',
      name: 'timeTrackerChangeLocationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delete Location`
  String get timeTrackerDeleteLocation {
    return Intl.message(
      'Delete Location',
      name: 'timeTrackerDeleteLocation',
      desc: '',
      args: [],
    );
  }

  /// `Export Locations`
  String get timeTrackerExportLocations {
    return Intl.message(
      'Export Locations',
      name: 'timeTrackerExportLocations',
      desc: '',
      args: [],
    );
  }

  /// `Import Locations`
  String get timeTrackerImportLocations {
    return Intl.message(
      'Import Locations',
      name: 'timeTrackerImportLocations',
      desc: '',
      args: [],
    );
  }

  /// `View Employees`
  String get timeTrackerViewEmployees {
    return Intl.message(
      'View Employees',
      name: 'timeTrackerViewEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Employees — All Departments`
  String get timeTrackerEmployeesAllDepartments {
    return Intl.message(
      'Employees — All Departments',
      name: 'timeTrackerEmployeesAllDepartments',
      desc: '',
      args: [],
    );
  }

  /// `Assign Employee`
  String get timeTrackerAssignEmployee {
    return Intl.message(
      'Assign Employee',
      name: 'timeTrackerAssignEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Reassign Employee Location`
  String get timeTrackerReassignEmployeeLocation {
    return Intl.message(
      'Reassign Employee Location',
      name: 'timeTrackerReassignEmployeeLocation',
      desc: '',
      args: [],
    );
  }

  /// `Remove Employee Assignment`
  String get timeTrackerRemoveEmployeeAssignment {
    return Intl.message(
      'Remove Employee Assignment',
      name: 'timeTrackerRemoveEmployeeAssignment',
      desc: '',
      args: [],
    );
  }

  /// `Export Employees`
  String get timeTrackerExportEmployees {
    return Intl.message(
      'Export Employees',
      name: 'timeTrackerExportEmployees',
      desc: '',
      args: [],
    );
  }

  /// `View Groups`
  String get timeTrackerViewGroups {
    return Intl.message(
      'View Groups',
      name: 'timeTrackerViewGroups',
      desc: '',
      args: [],
    );
  }

  /// `Create Group`
  String get timeTrackerCreateGroup {
    return Intl.message(
      'Create Group',
      name: 'timeTrackerCreateGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit Group`
  String get timeTrackerEditGroup {
    return Intl.message(
      'Edit Group',
      name: 'timeTrackerEditGroup',
      desc: '',
      args: [],
    );
  }

  /// `Delete Group`
  String get timeTrackerDeleteGroup {
    return Intl.message(
      'Delete Group',
      name: 'timeTrackerDeleteGroup',
      desc: '',
      args: [],
    );
  }

  /// `View Vacation Balances`
  String get timeTrackerViewVacationBalances {
    return Intl.message(
      'View Vacation Balances',
      name: 'timeTrackerViewVacationBalances',
      desc: '',
      args: [],
    );
  }

  /// `Edit Vacation Balance`
  String get timeTrackerEditVacationBalance {
    return Intl.message(
      'Edit Vacation Balance',
      name: 'timeTrackerEditVacationBalance',
      desc: '',
      args: [],
    );
  }

  /// `Import Vacation Balances`
  String get timeTrackerImportVacationBalances {
    return Intl.message(
      'Import Vacation Balances',
      name: 'timeTrackerImportVacationBalances',
      desc: '',
      args: [],
    );
  }

  /// `Export Vacation Balances`
  String get timeTrackerExportVacationBalances {
    return Intl.message(
      'Export Vacation Balances',
      name: 'timeTrackerExportVacationBalances',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get timeTrackerTabDashboard {
    return Intl.message(
      'Dashboard',
      name: 'timeTrackerTabDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get timeTrackerTabOverview {
    return Intl.message(
      'Overview',
      name: 'timeTrackerTabOverview',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get timeTrackerTabAttendance {
    return Intl.message(
      'Attendance',
      name: 'timeTrackerTabAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get timeTrackerTabRequests {
    return Intl.message(
      'Requests',
      name: 'timeTrackerTabRequests',
      desc: '',
      args: [],
    );
  }

  /// `Approvals`
  String get timeTrackerTabApprovals {
    return Intl.message(
      'Approvals',
      name: 'timeTrackerTabApprovals',
      desc: '',
      args: [],
    );
  }

  /// `Request Types`
  String get timeTrackerTabRequestTypes {
    return Intl.message(
      'Request Types',
      name: 'timeTrackerTabRequestTypes',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get timeTrackerTabLocations {
    return Intl.message(
      'Locations',
      name: 'timeTrackerTabLocations',
      desc: '',
      args: [],
    );
  }

  /// `Employees`
  String get timeTrackerTabEmployees {
    return Intl.message(
      'Employees',
      name: 'timeTrackerTabEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balances`
  String get timeTrackerTabVacationBalances {
    return Intl.message(
      'Vacation Balances',
      name: 'timeTrackerTabVacationBalances',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Time`
  String get timeTrackerTitle {
    return Intl.message(
      'Tracking Time',
      name: 'timeTrackerTitle',
      desc: '',
      args: [],
    );
  }

  /// `You don't have access to the Time Tracker.`
  String get timeTrackerNoAccess {
    return Intl.message(
      'You don\'t have access to the Time Tracker.',
      name: 'timeTrackerNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `Could not load the Time Tracker. Please try again.`
  String get timeTrackerLoadError {
    return Intl.message(
      'Could not load the Time Tracker. Please try again.',
      name: 'timeTrackerLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Your Time Tracker sections`
  String get timeTrackerYourTabs {
    return Intl.message(
      'Your Time Tracker sections',
      name: 'timeTrackerYourTabs',
      desc: '',
      args: [],
    );
  }

  /// `You can check in and out.`
  String get timeTrackerCheckInAvailable {
    return Intl.message(
      'You can check in and out.',
      name: 'timeTrackerCheckInAvailable',
      desc: '',
      args: [],
    );
  }

  /// `The Time Tracker screens are being built and will appear here soon.`
  String get timeTrackerScreensComingSoon {
    return Intl.message(
      'The Time Tracker screens are being built and will appear here soon.',
      name: 'timeTrackerScreensComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Locations, shifts and employee assignments are managed in the HR module.`
  String get timeTrackerHrOwnsSetup {
    return Intl.message(
      'Locations, shifts and employee assignments are managed in the HR module.',
      name: 'timeTrackerHrOwnsSetup',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get timeTrackerRetry {
    return Intl.message(
      'Try Again',
      name: 'timeTrackerRetry',
      desc: '',
      args: [],
    );
  }

  /// `Check In`
  String get timeTrackerCheckIn {
    return Intl.message(
      'Check In',
      name: 'timeTrackerCheckIn',
      desc: '',
      args: [],
    );
  }

  /// `Check Out`
  String get timeTrackerCheckOut {
    return Intl.message(
      'Check Out',
      name: 'timeTrackerCheckOut',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get timeTrackerPause {
    return Intl.message('Pause', name: 'timeTrackerPause', desc: '', args: []);
  }

  /// `Resume`
  String get timeTrackerResume {
    return Intl.message(
      'Resume',
      name: 'timeTrackerResume',
      desc: '',
      args: [],
    );
  }

  /// `Hour`
  String get timeTrackerHourUnit {
    return Intl.message(
      'Hour',
      name: 'timeTrackerHourUnit',
      desc: '',
      args: [],
    );
  }

  /// `Work Location`
  String get timeTrackerWorkLocation {
    return Intl.message(
      'Work Location',
      name: 'timeTrackerWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose Work Location`
  String get timeTrackerChooseWorkLocation {
    return Intl.message(
      'Choose Work Location',
      name: 'timeTrackerChooseWorkLocation',
      desc: '',
      args: [],
    );
  }

  /// `Start Shift`
  String get timeTrackerStartShift {
    return Intl.message(
      'Start Shift',
      name: 'timeTrackerStartShift',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get timeTrackerRemote {
    return Intl.message(
      'Remote',
      name: 'timeTrackerRemote',
      desc: '',
      args: [],
    );
  }

  /// `Client Site`
  String get timeTrackerClientSite {
    return Intl.message(
      'Client Site',
      name: 'timeTrackerClientSite',
      desc: '',
      args: [],
    );
  }

  /// `Office`
  String get timeTrackerOffice {
    return Intl.message(
      'Office',
      name: 'timeTrackerOffice',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Location`
  String get timeTrackerWrongLocationTitle {
    return Intl.message(
      'Wrong Location',
      name: 'timeTrackerWrongLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your check-in location does not match the company's designated location. Please check in from the correct location.`
  String get timeTrackerWrongLocationBody {
    return Intl.message(
      'Your check-in location does not match the company\'s designated location. Please check in from the correct location.',
      name: 'timeTrackerWrongLocationBody',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get timeTrackerConfirmedTitle {
    return Intl.message(
      'Confirmed',
      name: 'timeTrackerConfirmedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your Location Matches the Company’s Location`
  String get timeTrackerLocationMatches {
    return Intl.message(
      'Your Location Matches the Company’s Location',
      name: 'timeTrackerLocationMatches',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked In`
  String get timeTrackerCheckedInSuccess {
    return Intl.message(
      'You Successfully Checked In',
      name: 'timeTrackerCheckedInSuccess',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Checked Out`
  String get timeTrackerCheckedOutSuccess {
    return Intl.message(
      'You Successfully Checked Out',
      name: 'timeTrackerCheckedOutSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Checking Out`
  String get timeTrackerCheckOutConfirmTitle {
    return Intl.message(
      'Checking Out',
      name: 'timeTrackerCheckOutConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Check Out ?`
  String get timeTrackerCheckOutConfirmBody {
    return Intl.message(
      'Are You Sure You Want To Check Out ?',
      name: 'timeTrackerCheckOutConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Location Needed`
  String get timeTrackerLocationNeededTitle {
    return Intl.message(
      'Location Needed',
      name: 'timeTrackerLocationNeededTitle',
      desc: '',
      args: [],
    );
  }

  /// `Location access is turned off for Knowticed. Allow it in your device Settings to check in at the office, or choose Remote / Client Site if you are allowed.`
  String get timeTrackerLocationDenied {
    return Intl.message(
      'Location access is turned off for Knowticed. Allow it in your device Settings to check in at the office, or choose Remote / Client Site if you are allowed.',
      name: 'timeTrackerLocationDenied',
      desc: '',
      args: [],
    );
  }

  /// `Location services are turned off on this device. Turn them on to check in at the office.`
  String get timeTrackerLocationServiceOff {
    return Intl.message(
      'Location services are turned off on this device. Turn them on to check in at the office.',
      name: 'timeTrackerLocationServiceOff',
      desc: '',
      args: [],
    );
  }

  /// `We could not read your location. Please try again.`
  String get timeTrackerLocationUnavailable {
    return Intl.message(
      'We could not read your location. Please try again.',
      name: 'timeTrackerLocationUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `You are not assigned to a work location yet. Ask HR to assign you before checking in.`
  String get timeTrackerNotAssigned {
    return Intl.message(
      'You are not assigned to a work location yet. Ask HR to assign you before checking in.',
      name: 'timeTrackerNotAssigned',
      desc: '',
      args: [],
    );
  }

  /// `You can't check in at this location.`
  String get timeTrackerLocationNotAllowed {
    return Intl.message(
      'You can\'t check in at this location.',
      name: 'timeTrackerLocationNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `You are not allowed to work from a different location.`
  String get timeTrackerDifferentLocationNotAllowed {
    return Intl.message(
      'You are not allowed to work from a different location.',
      name: 'timeTrackerDifferentLocationNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get timeTrackerActionFailed {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'timeTrackerActionFailed',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission to do this.`
  String get timeTrackerNoPermission {
    return Intl.message(
      'You don\'t have permission to do this.',
      name: 'timeTrackerNoPermission',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get timeTrackerDate {
    return Intl.message('Date', name: 'timeTrackerDate', desc: '', args: []);
  }

  /// `Check In Time`
  String get timeTrackerCheckInTime {
    return Intl.message(
      'Check In Time',
      name: 'timeTrackerCheckInTime',
      desc: '',
      args: [],
    );
  }

  /// `Check Out Time`
  String get timeTrackerCheckOutTime {
    return Intl.message(
      'Check Out Time',
      name: 'timeTrackerCheckOutTime',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get timeTrackerLocation {
    return Intl.message(
      'Location',
      name: 'timeTrackerLocation',
      desc: '',
      args: [],
    );
  }

  /// `Break`
  String get timeTrackerBreak {
    return Intl.message('Break', name: 'timeTrackerBreak', desc: '', args: []);
  }

  /// `{count} Minutes`
  String timeTrackerMinutesValue(Object count) {
    return Intl.message(
      '$count Minutes',
      name: 'timeTrackerMinutesValue',
      desc: '',
      args: [count],
    );
  }

  /// `No Break`
  String get timeTrackerNoBreak {
    return Intl.message(
      'No Break',
      name: 'timeTrackerNoBreak',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get timeTrackerRangeTime {
    return Intl.message(
      'Time',
      name: 'timeTrackerRangeTime',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get timeTrackerRangeDay {
    return Intl.message('Day', name: 'timeTrackerRangeDay', desc: '', args: []);
  }

  /// `Week`
  String get timeTrackerRangeWeek {
    return Intl.message(
      'Week',
      name: 'timeTrackerRangeWeek',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get timeTrackerRangeMonth {
    return Intl.message(
      'Month',
      name: 'timeTrackerRangeMonth',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get timeTrackerRangeYear {
    return Intl.message(
      'Year',
      name: 'timeTrackerRangeYear',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get timeTrackerRangeCustom {
    return Intl.message(
      'Custom',
      name: 'timeTrackerRangeCustom',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date Selector`
  String get timeTrackerCustomDateSelector {
    return Intl.message(
      'Custom Date Selector',
      name: 'timeTrackerCustomDateSelector',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get timeTrackerStartDate {
    return Intl.message(
      'Start Date',
      name: 'timeTrackerStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get timeTrackerEndDate {
    return Intl.message(
      'End Date',
      name: 'timeTrackerEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Overall`
  String get timeTrackerOverall {
    return Intl.message(
      'Overall',
      name: 'timeTrackerOverall',
      desc: '',
      args: [],
    );
  }

  /// `Present`
  String get timeTrackerPresent {
    return Intl.message(
      'Present',
      name: 'timeTrackerPresent',
      desc: '',
      args: [],
    );
  }

  /// `Absence`
  String get timeTrackerAbsence {
    return Intl.message(
      'Absence',
      name: 'timeTrackerAbsence',
      desc: '',
      args: [],
    );
  }

  /// `Absent`
  String get timeTrackerAbsent {
    return Intl.message(
      'Absent',
      name: 'timeTrackerAbsent',
      desc: '',
      args: [],
    );
  }

  /// `Late`
  String get timeTrackerLate {
    return Intl.message('Late', name: 'timeTrackerLate', desc: '', args: []);
  }

  /// `Vacations Credit`
  String get timeTrackerVacationsCredit {
    return Intl.message(
      'Vacations Credit',
      name: 'timeTrackerVacationsCredit',
      desc: '',
      args: [],
    );
  }

  /// `Vacation`
  String get timeTrackerVacation {
    return Intl.message(
      'Vacation',
      name: 'timeTrackerVacation',
      desc: '',
      args: [],
    );
  }

  /// `Sick Leave`
  String get timeTrackerSickLeave {
    return Intl.message(
      'Sick Leave',
      name: 'timeTrackerSickLeave',
      desc: '',
      args: [],
    );
  }

  /// `Excused`
  String get timeTrackerExcused {
    return Intl.message(
      'Excused',
      name: 'timeTrackerExcused',
      desc: '',
      args: [],
    );
  }

  /// `Excuse Leave`
  String get timeTrackerExcuseLeave {
    return Intl.message(
      'Excuse Leave',
      name: 'timeTrackerExcuseLeave',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get timeTrackerRequestsTitle {
    return Intl.message(
      'Requests',
      name: 'timeTrackerRequestsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get timeTrackerApproved {
    return Intl.message(
      'Approved',
      name: 'timeTrackerApproved',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get timeTrackerPending {
    return Intl.message(
      'Pending',
      name: 'timeTrackerPending',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get timeTrackerRejected {
    return Intl.message(
      'Rejected',
      name: 'timeTrackerRejected',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get timeTrackerCanceled {
    return Intl.message(
      'Canceled',
      name: 'timeTrackerCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get timeTrackerTotal {
    return Intl.message('Total', name: 'timeTrackerTotal', desc: '', args: []);
  }

  /// `Late History`
  String get timeTrackerLateHistory {
    return Intl.message(
      'Late History',
      name: 'timeTrackerLateHistory',
      desc: '',
      args: [],
    );
  }

  /// `Counts`
  String get timeTrackerCounts {
    return Intl.message(
      'Counts',
      name: 'timeTrackerCounts',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get timeTrackerMinutes {
    return Intl.message(
      'Minutes',
      name: 'timeTrackerMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Work Locations`
  String get timeTrackerWorkLocations {
    return Intl.message(
      'Work Locations',
      name: 'timeTrackerWorkLocations',
      desc: '',
      args: [],
    );
  }

  /// `No data for this period yet.`
  String get timeTrackerNoDataYet {
    return Intl.message(
      'No data for this period yet.',
      name: 'timeTrackerNoDataYet',
      desc: '',
      args: [],
    );
  }

  /// `Transaction`
  String get timeTrackerTransactionButton {
    return Intl.message(
      'Transaction',
      name: 'timeTrackerTransactionButton',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get timeTrackerColumnNo {
    return Intl.message('No', name: 'timeTrackerColumnNo', desc: '', args: []);
  }

  /// `Attendance Date`
  String get timeTrackerAttendanceDate {
    return Intl.message(
      'Attendance Date',
      name: 'timeTrackerAttendanceDate',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get timeTrackerStatus {
    return Intl.message(
      'Status',
      name: 'timeTrackerStatus',
      desc: '',
      args: [],
    );
  }

  /// `Oncoming Time`
  String get timeTrackerOncomingTime {
    return Intl.message(
      'Oncoming Time',
      name: 'timeTrackerOncomingTime',
      desc: '',
      args: [],
    );
  }

  /// `Leaving Time`
  String get timeTrackerLeavingTime {
    return Intl.message(
      'Leaving Time',
      name: 'timeTrackerLeavingTime',
      desc: '',
      args: [],
    );
  }

  /// `Break Time`
  String get timeTrackerBreakTime {
    return Intl.message(
      'Break Time',
      name: 'timeTrackerBreakTime',
      desc: '',
      args: [],
    );
  }

  /// `Total Time`
  String get timeTrackerTotalTime {
    return Intl.message(
      'Total Time',
      name: 'timeTrackerTotalTime',
      desc: '',
      args: [],
    );
  }

  /// `{count} Mins`
  String timeTrackerMinsValue(Object count) {
    return Intl.message(
      '$count Mins',
      name: 'timeTrackerMinsValue',
      desc: '',
      args: [count],
    );
  }

  /// `{value} Hrs`
  String timeTrackerHrsValue(Object value) {
    return Intl.message(
      '$value Hrs',
      name: 'timeTrackerHrsValue',
      desc: '',
      args: [value],
    );
  }

  /// `Type`
  String get timeTrackerFilterType {
    return Intl.message(
      'Type',
      name: 'timeTrackerFilterType',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get timeTrackerFilterDay {
    return Intl.message(
      'Day',
      name: 'timeTrackerFilterDay',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get timeTrackerAll {
    return Intl.message('All', name: 'timeTrackerAll', desc: '', args: []);
  }

  /// `At least (hours)`
  String get timeTrackerMinTotalHoursHint {
    return Intl.message(
      'At least (hours)',
      name: 'timeTrackerMinTotalHoursHint',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get timeTrackerAttendanceExportName {
    return Intl.message(
      'Attendance',
      name: 'timeTrackerAttendanceExportName',
      desc: '',
      args: [],
    );
  }

  /// `There is nothing to export.`
  String get timeTrackerExportEmpty {
    return Intl.message(
      'There is nothing to export.',
      name: 'timeTrackerExportEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Creating Transaction`
  String get timeTrackerCreatingTransaction {
    return Intl.message(
      'Creating Transaction',
      name: 'timeTrackerCreatingTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Check In Date`
  String get timeTrackerCheckInDate {
    return Intl.message(
      'Check In Date',
      name: 'timeTrackerCheckInDate',
      desc: '',
      args: [],
    );
  }

  /// `Check Out Date`
  String get timeTrackerCheckOutDate {
    return Intl.message(
      'Check Out Date',
      name: 'timeTrackerCheckOutDate',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get timeTrackerDescription {
    return Intl.message(
      'Description',
      name: 'timeTrackerDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Document`
  String get timeTrackerTransactionDocument {
    return Intl.message(
      'Transaction Document',
      name: 'timeTrackerTransactionDocument',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Transaction ?`
  String get timeTrackerCreateTransactionConfirm {
    return Intl.message(
      'Are You Sure You Want To Create This Transaction ?',
      name: 'timeTrackerCreateTransactionConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Transaction`
  String get timeTrackerSubmittedTransaction {
    return Intl.message(
      'Submitted Transaction',
      name: 'timeTrackerSubmittedTransaction',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Submitted This Transaction`
  String get timeTrackerTransactionSubmitted {
    return Intl.message(
      'You Successfully Submitted This Transaction',
      name: 'timeTrackerTransactionSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Choose the check-in date and time.`
  String get timeTrackerCheckInRequired {
    return Intl.message(
      'Choose the check-in date and time.',
      name: 'timeTrackerCheckInRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose the check-out date and time.`
  String get timeTrackerCheckOutRequired {
    return Intl.message(
      'Choose the check-out date and time.',
      name: 'timeTrackerCheckOutRequired',
      desc: '',
      args: [],
    );
  }

  /// `Check out must be after check in.`
  String get timeTrackerCheckOutAfterCheckIn {
    return Intl.message(
      'Check out must be after check in.',
      name: 'timeTrackerCheckOutAfterCheckIn',
      desc: '',
      args: [],
    );
  }

  /// `A transaction can't be in the future.`
  String get timeTrackerTransactionInFuture {
    return Intl.message(
      'A transaction can\'t be in the future.',
      name: 'timeTrackerTransactionInFuture',
      desc: '',
      args: [],
    );
  }

  /// `Could not upload the file. Please try again.`
  String get timeTrackerUploadFailed {
    return Intl.message(
      'Could not upload the file. Please try again.',
      name: 'timeTrackerUploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `The file is larger than 10 MB.`
  String get timeTrackerFileTooLarge {
    return Intl.message(
      'The file is larger than 10 MB.',
      name: 'timeTrackerFileTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded Date: {date}`
  String timeTrackerUploadedOn(Object date) {
    return Intl.message(
      'Uploaded Date: $date',
      name: 'timeTrackerUploadedOn',
      desc: '',
      args: [date],
    );
  }

  /// `This section is coming soon.`
  String get timeTrackerSectionComingSoon {
    return Intl.message(
      'This section is coming soon.',
      name: 'timeTrackerSectionComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Location Name`
  String get timeTrackerLocationName {
    return Intl.message(
      'Location Name',
      name: 'timeTrackerLocationName',
      desc: '',
      args: [],
    );
  }

  /// `اسم الموقع`
  String get timeTrackerLocationNameAr {
    return Intl.message(
      'اسم الموقع',
      name: 'timeTrackerLocationNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Google Map`
  String get timeTrackerGoogleMap {
    return Intl.message(
      'Google Map',
      name: 'timeTrackerGoogleMap',
      desc: '',
      args: [],
    );
  }

  /// `Location at Google Maps`
  String get timeTrackerLocationAtGoogleMaps {
    return Intl.message(
      'Location at Google Maps',
      name: 'timeTrackerLocationAtGoogleMaps',
      desc: '',
      args: [],
    );
  }

  /// `https://www.google.com/maps/place`
  String get timeTrackerGoogleMapsHint {
    return Intl.message(
      'https://www.google.com/maps/place',
      name: 'timeTrackerGoogleMapsHint',
      desc: '',
      args: [],
    );
  }

  /// `Latitude`
  String get timeTrackerLatitude {
    return Intl.message(
      'Latitude',
      name: 'timeTrackerLatitude',
      desc: '',
      args: [],
    );
  }

  /// `Longitude`
  String get timeTrackerLongitude {
    return Intl.message(
      'Longitude',
      name: 'timeTrackerLongitude',
      desc: '',
      args: [],
    );
  }

  /// `Use My Current Location`
  String get timeTrackerUseMyLocation {
    return Intl.message(
      'Use My Current Location',
      name: 'timeTrackerUseMyLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location access is turned off for Knowticed. Allow it in your device Settings, or type the latitude and longitude.`
  String get timeTrackerLocationDeniedSetup {
    return Intl.message(
      'Location access is turned off for Knowticed. Allow it in your device Settings, or type the latitude and longitude.',
      name: 'timeTrackerLocationDeniedSetup',
      desc: '',
      args: [],
    );
  }

  /// `Allow Geofence`
  String get timeTrackerAllowGeofence {
    return Intl.message(
      'Allow Geofence',
      name: 'timeTrackerAllowGeofence',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing`
  String get timeTrackerGeofencing {
    return Intl.message(
      'Geofencing',
      name: 'timeTrackerGeofencing',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing Radius (meters)`
  String get timeTrackerGeofenceRadius {
    return Intl.message(
      'Geofencing Radius (meters)',
      name: 'timeTrackerGeofenceRadius',
      desc: '',
      args: [],
    );
  }

  /// `Geofencing Radius`
  String get timeTrackerGeofenceRadiusColumn {
    return Intl.message(
      'Geofencing Radius',
      name: 'timeTrackerGeofenceRadiusColumn',
      desc: '',
      args: [],
    );
  }

  /// `500`
  String get timeTrackerRadiusHint {
    return Intl.message(
      '500',
      name: 'timeTrackerRadiusHint',
      desc: '',
      args: [],
    );
  }

  /// `{count} m`
  String timeTrackerMetersValue(Object count) {
    return Intl.message(
      '$count m',
      name: 'timeTrackerMetersValue',
      desc: '',
      args: [count],
    );
  }

  /// `Country`
  String get timeTrackerCountry {
    return Intl.message(
      'Country',
      name: 'timeTrackerCountry',
      desc: '',
      args: [],
    );
  }

  /// `دولة`
  String get timeTrackerCountryAr {
    return Intl.message(
      'دولة',
      name: 'timeTrackerCountryAr',
      desc: '',
      args: [],
    );
  }

  /// `State or Province`
  String get timeTrackerStateOrProvince {
    return Intl.message(
      'State or Province',
      name: 'timeTrackerStateOrProvince',
      desc: '',
      args: [],
    );
  }

  /// `ولاية او محافظة`
  String get timeTrackerStateOrProvinceAr {
    return Intl.message(
      'ولاية او محافظة',
      name: 'timeTrackerStateOrProvinceAr',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get timeTrackerCity {
    return Intl.message('City', name: 'timeTrackerCity', desc: '', args: []);
  }

  /// `مدينة`
  String get timeTrackerCityAr {
    return Intl.message('مدينة', name: 'timeTrackerCityAr', desc: '', args: []);
  }

  /// `Postal Code`
  String get timeTrackerPostalCode {
    return Intl.message(
      'Postal Code',
      name: 'timeTrackerPostalCode',
      desc: '',
      args: [],
    );
  }

  /// `اكتب هنا`
  String get timeTrackerTextHereAr {
    return Intl.message(
      'اكتب هنا',
      name: 'timeTrackerTextHereAr',
      desc: '',
      args: [],
    );
  }

  /// `Location Description`
  String get timeTrackerLocationDescription {
    return Intl.message(
      'Location Description',
      name: 'timeTrackerLocationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Work Schedule`
  String get timeTrackerWorkSchedule {
    return Intl.message(
      'Work Schedule',
      name: 'timeTrackerWorkSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Location Setting`
  String get timeTrackerLocationSetting {
    return Intl.message(
      'Location Setting',
      name: 'timeTrackerLocationSetting',
      desc: '',
      args: [],
    );
  }

  /// `Work Start Time`
  String get timeTrackerWorkStartTime {
    return Intl.message(
      'Work Start Time',
      name: 'timeTrackerWorkStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Work End Time`
  String get timeTrackerWorkEndTime {
    return Intl.message(
      'Work End Time',
      name: 'timeTrackerWorkEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Working Days`
  String get timeTrackerWorkingDays {
    return Intl.message(
      'Working Days',
      name: 'timeTrackerWorkingDays',
      desc: '',
      args: [],
    );
  }

  /// `Late After (minutes)`
  String get timeTrackerLateAfter {
    return Intl.message(
      'Late After (minutes)',
      name: 'timeTrackerLateAfter',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get timeTrackerLateAfterHint {
    return Intl.message(
      '0',
      name: 'timeTrackerLateAfterHint',
      desc: '',
      args: [],
    );
  }

  /// `Allow Breaks in Attendance`
  String get timeTrackerAllowBreaks {
    return Intl.message(
      'Allow Breaks in Attendance',
      name: 'timeTrackerAllowBreaks',
      desc: '',
      args: [],
    );
  }

  /// `Allow Pause`
  String get timeTrackerAllowPause {
    return Intl.message(
      'Allow Pause',
      name: 'timeTrackerAllowPause',
      desc: '',
      args: [],
    );
  }

  /// `30`
  String get timeTrackerBreakLengthHint {
    return Intl.message(
      '30',
      name: 'timeTrackerBreakLengthHint',
      desc: '',
      args: [],
    );
  }

  /// `Mins`
  String get timeTrackerUnitMins {
    return Intl.message(
      'Mins',
      name: 'timeTrackerUnitMins',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get timeTrackerUnitHours {
    return Intl.message(
      'Hours',
      name: 'timeTrackerUnitHours',
      desc: '',
      args: [],
    );
  }

  /// `Enter the name.`
  String get timeTrackerNameRequired {
    return Intl.message(
      'Enter the name.',
      name: 'timeTrackerNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter the Arabic name.`
  String get timeTrackerArabicNameRequired {
    return Intl.message(
      'Enter the Arabic name.',
      name: 'timeTrackerArabicNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a latitude between -90 and 90.`
  String get timeTrackerLatitudeInvalid {
    return Intl.message(
      'Enter a latitude between -90 and 90.',
      name: 'timeTrackerLatitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Enter a longitude between -180 and 180.`
  String get timeTrackerLongitudeInvalid {
    return Intl.message(
      'Enter a longitude between -180 and 180.',
      name: 'timeTrackerLongitudeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `A geofence needs the latitude and longitude.`
  String get timeTrackerCoordinatesRequired {
    return Intl.message(
      'A geofence needs the latitude and longitude.',
      name: 'timeTrackerCoordinatesRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter the radius in meters (up to 50000).`
  String get timeTrackerRadiusRequired {
    return Intl.message(
      'Enter the radius in meters (up to 50000).',
      name: 'timeTrackerRadiusRequired',
      desc: '',
      args: [],
    );
  }

  /// `Work start and end can't be the same time.`
  String get timeTrackerWorkTimesSame {
    return Intl.message(
      'Work start and end can\'t be the same time.',
      name: 'timeTrackerWorkTimesSame',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one working day.`
  String get timeTrackerWorkingDaysRequired {
    return Intl.message(
      'Choose at least one working day.',
      name: 'timeTrackerWorkingDaysRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter the break length.`
  String get timeTrackerBreakLengthRequired {
    return Intl.message(
      'Enter the break length.',
      name: 'timeTrackerBreakLengthRequired',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Location`
  String get timeTrackerCreatingNewLocation {
    return Intl.message(
      'Creating New Location',
      name: 'timeTrackerCreatingNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Editing Location`
  String get timeTrackerEditingLocation {
    return Intl.message(
      'Editing Location',
      name: 'timeTrackerEditingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Location ?`
  String get timeTrackerCreateLocationConfirm {
    return Intl.message(
      'Are You Sure You Want To Create This Location ?',
      name: 'timeTrackerCreateLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Location Created`
  String get timeTrackerLocationCreatedTitle {
    return Intl.message(
      'Location Created',
      name: 'timeTrackerLocationCreatedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created New Location`
  String get timeTrackerLocationCreated {
    return Intl.message(
      'You Successfully Created New Location',
      name: 'timeTrackerLocationCreated',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Location ?`
  String get timeTrackerEditLocationConfirm {
    return Intl.message(
      'Are You Sure You Want To Edit This Location ?',
      name: 'timeTrackerEditLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Location Edited`
  String get timeTrackerLocationEditedTitle {
    return Intl.message(
      'Location Edited',
      name: 'timeTrackerLocationEditedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Location`
  String get timeTrackerLocationEdited {
    return Intl.message(
      'You Successfully Edited This Location',
      name: 'timeTrackerLocationEdited',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Location`
  String get timeTrackerDeletingLocation {
    return Intl.message(
      'Deleting Location',
      name: 'timeTrackerDeletingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Location ?`
  String get timeTrackerDeleteLocationConfirm {
    return Intl.message(
      'Are You Sure You Want To Delete This Location ?',
      name: 'timeTrackerDeleteLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Location Deleted`
  String get timeTrackerLocationDeletedTitle {
    return Intl.message(
      'Location Deleted',
      name: 'timeTrackerLocationDeletedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Location`
  String get timeTrackerLocationDeleted {
    return Intl.message(
      'You Successfully Deleted This Location',
      name: 'timeTrackerLocationDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Changing Status`
  String get timeTrackerChangingStatus {
    return Intl.message(
      'Changing Status',
      name: 'timeTrackerChangingStatus',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Deactivate This Location ?`
  String get timeTrackerDeactivateLocationConfirm {
    return Intl.message(
      'Are You Sure You Want To Deactivate This Location ?',
      name: 'timeTrackerDeactivateLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate This Location ?`
  String get timeTrackerActivateLocationConfirm {
    return Intl.message(
      'Are You Sure You Want To Activate This Location ?',
      name: 'timeTrackerActivateLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Location`
  String get timeTrackerLocationStatusChanged {
    return Intl.message(
      'You Successfully Changed the Status Of This Location',
      name: 'timeTrackerLocationStatusChanged',
      desc: '',
      args: [],
    );
  }

  /// `Status Changed`
  String get timeTrackerStatusChangedTitle {
    return Intl.message(
      'Status Changed',
      name: 'timeTrackerStatusChangedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get timeTrackerActive {
    return Intl.message(
      'Active',
      name: 'timeTrackerActive',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get timeTrackerInactive {
    return Intl.message(
      'Inactive',
      name: 'timeTrackerInactive',
      desc: '',
      args: [],
    );
  }

  /// `Removed`
  String get timeTrackerRemoved {
    return Intl.message(
      'Removed',
      name: 'timeTrackerRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Employees`
  String get timeTrackerAssignedEmployees {
    return Intl.message(
      'Assigned Employees',
      name: 'timeTrackerAssignedEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Locations`
  String get timeTrackerLocationsExportName {
    return Intl.message(
      'Locations',
      name: 'timeTrackerLocationsExportName',
      desc: '',
      args: [],
    );
  }

  /// `Download the template, fill one row per location, then upload it as CSV or Excel. A row whose name matches an existing location updates it (a blank cell keeps the current value); every other row creates a new location. Nothing is deleted.`
  String get timeTrackerImportHelp {
    return Intl.message(
      'Download the template, fill one row per location, then upload it as CSV or Excel. A row whose name matches an existing location updates it (a blank cell keeps the current value); every other row creates a new location. Nothing is deleted.',
      name: 'timeTrackerImportHelp',
      desc: '',
      args: [],
    );
  }

  /// `Download Template`
  String get timeTrackerDownloadTemplate {
    return Intl.message(
      'Download Template',
      name: 'timeTrackerDownloadTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get timeTrackerUploadFile {
    return Intl.message(
      'Upload File',
      name: 'timeTrackerUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Locations Template`
  String get timeTrackerImportTemplateName {
    return Intl.message(
      'Locations Template',
      name: 'timeTrackerImportTemplateName',
      desc: '',
      args: [],
    );
  }

  /// `{create} new · {update} updated · {unchanged} unchanged · {skip} skipped`
  String timeTrackerImportSummary(
    Object create,
    Object update,
    Object unchanged,
    Object skip,
  ) {
    return Intl.message(
      '$create new · $update updated · $unchanged unchanged · $skip skipped',
      name: 'timeTrackerImportSummary',
      desc: '',
      args: [create, update, unchanged, skip],
    );
  }

  /// `Line {line}`
  String timeTrackerImportLine(Object line) {
    return Intl.message(
      'Line $line',
      name: 'timeTrackerImportLine',
      desc: '',
      args: [line],
    );
  }

  /// `Unreadable value in “{column}”`
  String timeTrackerImportUnreadable(Object column) {
    return Intl.message(
      'Unreadable value in “$column”',
      name: 'timeTrackerImportUnreadable',
      desc: '',
      args: [column],
    );
  }

  /// `This name appears more than once in the file`
  String get timeTrackerImportDuplicate {
    return Intl.message(
      'This name appears more than once in the file',
      name: 'timeTrackerImportDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `The file has no “Location Name” column. Please use the template.`
  String get timeTrackerImportNoNameColumn {
    return Intl.message(
      'The file has no “Location Name” column. Please use the template.',
      name: 'timeTrackerImportNoNameColumn',
      desc: '',
      args: [],
    );
  }

  /// `The file could not be read. Please use the CSV or Excel template.`
  String get timeTrackerImportFileError {
    return Intl.message(
      'The file could not be read. Please use the CSV or Excel template.',
      name: 'timeTrackerImportFileError',
      desc: '',
      args: [],
    );
  }

  /// `There is nothing to import.`
  String get timeTrackerImportNothing {
    return Intl.message(
      'There is nothing to import.',
      name: 'timeTrackerImportNothing',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Import These Locations ?`
  String get timeTrackerImportConfirm {
    return Intl.message(
      'Are You Sure You Want To Import These Locations ?',
      name: 'timeTrackerImportConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Locations Imported`
  String get timeTrackerImportDoneTitle {
    return Intl.message(
      'Locations Imported',
      name: 'timeTrackerImportDoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Imported The Locations`
  String get timeTrackerImportDone {
    return Intl.message(
      'You Successfully Imported The Locations',
      name: 'timeTrackerImportDone',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get timeTrackerImportActionCreate {
    return Intl.message(
      'New',
      name: 'timeTrackerImportActionCreate',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get timeTrackerImportActionUpdate {
    return Intl.message(
      'Update',
      name: 'timeTrackerImportActionUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No Change`
  String get timeTrackerImportActionUnchanged {
    return Intl.message(
      'No Change',
      name: 'timeTrackerImportActionUnchanged',
      desc: '',
      args: [],
    );
  }

  /// `Skipped`
  String get timeTrackerImportActionSkip {
    return Intl.message(
      'Skipped',
      name: 'timeTrackerImportActionSkip',
      desc: '',
      args: [],
    );
  }

  /// `Access Granted`
  String get timeTrackerAccessGrantedTitle {
    return Intl.message(
      'Access Granted',
      name: 'timeTrackerAccessGrantedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Granted Access`
  String get timeTrackerAccessGranted {
    return Intl.message(
      'You Successfully Granted Access',
      name: 'timeTrackerAccessGranted',
      desc: '',
      args: [],
    );
  }

  /// `Grant Access`
  String get timeTrackerGrantAccess {
    return Intl.message(
      'Grant Access',
      name: 'timeTrackerGrantAccess',
      desc: '',
      args: [],
    );
  }

  /// `Choose Location`
  String get timeTrackerChooseLocation {
    return Intl.message(
      'Choose Location',
      name: 'timeTrackerChooseLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose the location.`
  String get timeTrackerLocationRequired {
    return Intl.message(
      'Choose the location.',
      name: 'timeTrackerLocationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose The Date`
  String get timeTrackerChooseTheDate {
    return Intl.message(
      'Choose The Date',
      name: 'timeTrackerChooseTheDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose the start date.`
  String get timeTrackerStartDateRequired {
    return Intl.message(
      'Choose the start date.',
      name: 'timeTrackerStartDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Allow Different Work Location`
  String get timeTrackerAllowDifferentLocation {
    return Intl.message(
      'Allow Different Work Location',
      name: 'timeTrackerAllowDifferentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Location`
  String get timeTrackerSelectLocation {
    return Intl.message(
      'Select Location',
      name: 'timeTrackerSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one location.`
  String get timeTrackerAllowedLocationsRequired {
    return Intl.message(
      'Choose at least one location.',
      name: 'timeTrackerAllowedLocationsRequired',
      desc: '',
      args: [],
    );
  }

  /// `{count} Employees Selected`
  String timeTrackerEmployeesSelected(Object count) {
    return Intl.message(
      '$count Employees Selected',
      name: 'timeTrackerEmployeesSelected',
      desc: '',
      args: [count],
    );
  }

  /// `Title`
  String get timeTrackerTitleLabel {
    return Intl.message(
      'Title',
      name: 'timeTrackerTitleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get timeTrackerPhoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'timeTrackerPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get timeTrackerDepartment {
    return Intl.message(
      'Department',
      name: 'timeTrackerDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get timeTrackerEmail {
    return Intl.message('Email', name: 'timeTrackerEmail', desc: '', args: []);
  }

  /// `Assign Date: {date}`
  String timeTrackerAssignDate(Object date) {
    return Intl.message(
      'Assign Date: $date',
      name: 'timeTrackerAssignDate',
      desc: '',
      args: [date],
    );
  }

  /// `Location: {name}`
  String timeTrackerLocationValue(Object name) {
    return Intl.message(
      'Location: $name',
      name: 'timeTrackerLocationValue',
      desc: '',
      args: [name],
    );
  }

  /// `Assigned`
  String get timeTrackerAssigned {
    return Intl.message(
      'Assigned',
      name: 'timeTrackerAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Unassigned`
  String get timeTrackerUnassigned {
    return Intl.message(
      'Unassigned',
      name: 'timeTrackerUnassigned',
      desc: '',
      args: [],
    );
  }

  /// `Assign`
  String get timeTrackerAssign {
    return Intl.message(
      'Assign',
      name: 'timeTrackerAssign',
      desc: '',
      args: [],
    );
  }

  /// `Reassign`
  String get timeTrackerReassign {
    return Intl.message(
      'Reassign',
      name: 'timeTrackerReassign',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get timeTrackerRemove {
    return Intl.message(
      'Remove',
      name: 'timeTrackerRemove',
      desc: '',
      args: [],
    );
  }

  /// `Assign ({count})`
  String timeTrackerAssignCount(Object count) {
    return Intl.message(
      'Assign ($count)',
      name: 'timeTrackerAssignCount',
      desc: '',
      args: [count],
    );
  }

  /// `Employees`
  String get timeTrackerEmployeesExportName {
    return Intl.message(
      'Employees',
      name: 'timeTrackerEmployeesExportName',
      desc: '',
      args: [],
    );
  }

  /// `Employee Name`
  String get timeTrackerEmployeeName {
    return Intl.message(
      'Employee Name',
      name: 'timeTrackerEmployeeName',
      desc: '',
      args: [],
    );
  }

  /// `Removing Assignment`
  String get timeTrackerRemovingAssignment {
    return Intl.message(
      'Removing Assignment',
      name: 'timeTrackerRemovingAssignment',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Remove This Employee's Assignment ?`
  String get timeTrackerRemoveAssignmentConfirm {
    return Intl.message(
      'Are You Sure You Want To Remove This Employee\'s Assignment ?',
      name: 'timeTrackerRemoveAssignmentConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Assignment Removed`
  String get timeTrackerAssignmentRemovedTitle {
    return Intl.message(
      'Assignment Removed',
      name: 'timeTrackerAssignmentRemovedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Removed This Employee's Assignment`
  String get timeTrackerAssignmentRemoved {
    return Intl.message(
      'You Successfully Removed This Employee\'s Assignment',
      name: 'timeTrackerAssignmentRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Group Information`
  String get timeTrackerGroupInformation {
    return Intl.message(
      'Group Information',
      name: 'timeTrackerGroupInformation',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get timeTrackerGroupButton {
    return Intl.message(
      'Group',
      name: 'timeTrackerGroupButton',
      desc: '',
      args: [],
    );
  }

  /// `Name (A to Z)`
  String get timeTrackerSortNameAsc {
    return Intl.message(
      'Name (A to Z)',
      name: 'timeTrackerSortNameAsc',
      desc: '',
      args: [],
    );
  }

  /// `Name (Z to A)`
  String get timeTrackerSortNameDesc {
    return Intl.message(
      'Name (Z to A)',
      name: 'timeTrackerSortNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Newest First`
  String get timeTrackerSortNewest {
    return Intl.message(
      'Newest First',
      name: 'timeTrackerSortNewest',
      desc: '',
      args: [],
    );
  }

  /// `Group Name`
  String get timeTrackerGroupName {
    return Intl.message(
      'Group Name',
      name: 'timeTrackerGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get timeTrackerMembers {
    return Intl.message(
      'Members',
      name: 'timeTrackerMembers',
      desc: '',
      args: [],
    );
  }

  /// `Choose Members`
  String get timeTrackerChooseMembers {
    return Intl.message(
      'Choose Members',
      name: 'timeTrackerChooseMembers',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one member.`
  String get timeTrackerMembersRequired {
    return Intl.message(
      'Choose at least one member.',
      name: 'timeTrackerMembersRequired',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Group`
  String get timeTrackerCreatingNewGroup {
    return Intl.message(
      'Creating New Group',
      name: 'timeTrackerCreatingNewGroup',
      desc: '',
      args: [],
    );
  }

  /// `Editing Group`
  String get timeTrackerEditingGroup {
    return Intl.message(
      'Editing Group',
      name: 'timeTrackerEditingGroup',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Group ?`
  String get timeTrackerCreateGroupConfirm {
    return Intl.message(
      'Are You Sure You Want To Create This Group ?',
      name: 'timeTrackerCreateGroupConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Group Creation`
  String get timeTrackerGroupCreationTitle {
    return Intl.message(
      'Group Creation',
      name: 'timeTrackerGroupCreationTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Group`
  String get timeTrackerGroupCreated {
    return Intl.message(
      'You Successfully Created This Group',
      name: 'timeTrackerGroupCreated',
      desc: '',
      args: [],
    );
  }

  /// `Editing Group Details`
  String get timeTrackerEditingGroupDetails {
    return Intl.message(
      'Editing Group Details',
      name: 'timeTrackerEditingGroupDetails',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Group ?`
  String get timeTrackerEditGroupConfirm {
    return Intl.message(
      'Are You Sure You Want To Edit This Group ?',
      name: 'timeTrackerEditGroupConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Edited Group`
  String get timeTrackerEditedGroupTitle {
    return Intl.message(
      'Edited Group',
      name: 'timeTrackerEditedGroupTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Group`
  String get timeTrackerGroupEdited {
    return Intl.message(
      'You Successfully Edited This Group',
      name: 'timeTrackerGroupEdited',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Group`
  String get timeTrackerDeletingGroups {
    return Intl.message(
      'Deleting Group',
      name: 'timeTrackerDeletingGroups',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Group ?`
  String get timeTrackerDeleteGroupConfirm {
    return Intl.message(
      'Are You Sure You Want To Delete This Group ?',
      name: 'timeTrackerDeleteGroupConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Group Deleted`
  String get timeTrackerDeletedGroupTitle {
    return Intl.message(
      'Group Deleted',
      name: 'timeTrackerDeletedGroupTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Group`
  String get timeTrackerGroupDeleted {
    return Intl.message(
      'You Successfully Deleted This Group',
      name: 'timeTrackerGroupDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Employee Information`
  String get timeTrackerEmployeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'timeTrackerEmployeeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Request Types`
  String get timeTrackerRequestTypesExportName {
    return Intl.message(
      'Request Types',
      name: 'timeTrackerRequestTypesExportName',
      desc: '',
      args: [],
    );
  }

  /// `Request Type`
  String get timeTrackerRequestType {
    return Intl.message(
      'Request Type',
      name: 'timeTrackerRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Request Name`
  String get timeTrackerRequestName {
    return Intl.message(
      'Request Name',
      name: 'timeTrackerRequestName',
      desc: '',
      args: [],
    );
  }

  /// `اسم طلب`
  String get timeTrackerRequestNameAr {
    return Intl.message(
      'اسم طلب',
      name: 'timeTrackerRequestNameAr',
      desc: '',
      args: [],
    );
  }

  /// `وصف طلب`
  String get timeTrackerDescriptionAr {
    return Intl.message(
      'وصف طلب',
      name: 'timeTrackerDescriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Request Description`
  String get timeTrackerRequestDescription {
    return Intl.message(
      'Request Description',
      name: 'timeTrackerRequestDescription',
      desc: '',
      args: [],
    );
  }

  /// `HR Approval`
  String get timeTrackerHrApproval {
    return Intl.message(
      'HR Approval',
      name: 'timeTrackerHrApproval',
      desc: '',
      args: [],
    );
  }

  /// `Manager Approval`
  String get timeTrackerManagerApproval {
    return Intl.message(
      'Manager Approval',
      name: 'timeTrackerManagerApproval',
      desc: '',
      args: [],
    );
  }

  /// `Requires Description`
  String get timeTrackerRequiresDescription {
    return Intl.message(
      'Requires Description',
      name: 'timeTrackerRequiresDescription',
      desc: '',
      args: [],
    );
  }

  /// `Requires Attachments`
  String get timeTrackerRequiresAttachments {
    return Intl.message(
      'Requires Attachments',
      name: 'timeTrackerRequiresAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Deducts From Vacation Balance`
  String get timeTrackerDeductsFromVacation {
    return Intl.message(
      'Deducts From Vacation Balance',
      name: 'timeTrackerDeductsFromVacation',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get timeTrackerAttachments {
    return Intl.message(
      'Attachments',
      name: 'timeTrackerAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get timeTrackerRequired {
    return Intl.message(
      'Required',
      name: 'timeTrackerRequired',
      desc: '',
      args: [],
    );
  }

  /// `Not Required`
  String get timeTrackerNotRequired {
    return Intl.message(
      'Not Required',
      name: 'timeTrackerNotRequired',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get timeTrackerOptional {
    return Intl.message(
      'Optional',
      name: 'timeTrackerOptional',
      desc: '',
      args: [],
    );
  }

  /// `Creation Date`
  String get timeTrackerCreationDate {
    return Intl.message(
      'Creation Date',
      name: 'timeTrackerCreationDate',
      desc: '',
      args: [],
    );
  }

  /// `Added By`
  String get timeTrackerAddedBy {
    return Intl.message(
      'Added By',
      name: 'timeTrackerAddedBy',
      desc: '',
      args: [],
    );
  }

  /// `Last Update`
  String get timeTrackerLastUpdate {
    return Intl.message(
      'Last Update',
      name: 'timeTrackerLastUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Last Update: {date}`
  String timeTrackerLastUpdateValue(Object date) {
    return Intl.message(
      'Last Update: $date',
      name: 'timeTrackerLastUpdateValue',
      desc: '',
      args: [date],
    );
  }

  /// `Created Date: {date}`
  String timeTrackerCreatedDateValue(Object date) {
    return Intl.message(
      'Created Date: $date',
      name: 'timeTrackerCreatedDateValue',
      desc: '',
      args: [date],
    );
  }

  /// `Limit Location Availability`
  String get timeTrackerLimitLocationAvailability {
    return Intl.message(
      'Limit Location Availability',
      name: 'timeTrackerLimitLocationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Location Availability`
  String get timeTrackerLocationAvailability {
    return Intl.message(
      'Location Availability',
      name: 'timeTrackerLocationAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Limit Department Availability`
  String get timeTrackerLimitDepartmentAvailability {
    return Intl.message(
      'Limit Department Availability',
      name: 'timeTrackerLimitDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Department Availability`
  String get timeTrackerDepartmentAvailability {
    return Intl.message(
      'Department Availability',
      name: 'timeTrackerDepartmentAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Choose Here`
  String get timeTrackerChooseHere {
    return Intl.message(
      'Choose Here',
      name: 'timeTrackerChooseHere',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one location, or switch the limit off.`
  String get timeTrackerChooseOneLocation {
    return Intl.message(
      'Choose at least one location, or switch the limit off.',
      name: 'timeTrackerChooseOneLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose at least one department, or switch the limit off.`
  String get timeTrackerChooseOneDepartment {
    return Intl.message(
      'Choose at least one department, or switch the limit off.',
      name: 'timeTrackerChooseOneDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Creating Request Type`
  String get timeTrackerCreatingRequestType {
    return Intl.message(
      'Creating Request Type',
      name: 'timeTrackerCreatingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Editing Request Type`
  String get timeTrackerEditingRequestType {
    return Intl.message(
      'Editing Request Type',
      name: 'timeTrackerEditingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request Type ?`
  String get timeTrackerCreateRequestTypeConfirm {
    return Intl.message(
      'Are You Sure You Want To Create This Request Type ?',
      name: 'timeTrackerCreateRequestTypeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Request Type Created`
  String get timeTrackerRequestTypeCreatedTitle {
    return Intl.message(
      'Request Type Created',
      name: 'timeTrackerRequestTypeCreatedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Created This Request Type`
  String get timeTrackerRequestTypeCreated {
    return Intl.message(
      'You Successfully Created This Request Type',
      name: 'timeTrackerRequestTypeCreated',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Request Type ?`
  String get timeTrackerEditRequestTypeConfirm {
    return Intl.message(
      'Are You Sure You Want To Edit This Request Type ?',
      name: 'timeTrackerEditRequestTypeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Request Type Edited`
  String get timeTrackerRequestTypeEditedTitle {
    return Intl.message(
      'Request Type Edited',
      name: 'timeTrackerRequestTypeEditedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Request Type`
  String get timeTrackerRequestTypeEdited {
    return Intl.message(
      'You Successfully Edited This Request Type',
      name: 'timeTrackerRequestTypeEdited',
      desc: '',
      args: [],
    );
  }

  /// `Removing Request Type`
  String get timeTrackerRemovingRequestType {
    return Intl.message(
      'Removing Request Type',
      name: 'timeTrackerRemovingRequestType',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Remove This Request Type ?`
  String get timeTrackerRemoveRequestTypeConfirm {
    return Intl.message(
      'Are You Sure You Want To Remove This Request Type ?',
      name: 'timeTrackerRemoveRequestTypeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Request Type Removed`
  String get timeTrackerRequestTypeRemovedTitle {
    return Intl.message(
      'Request Type Removed',
      name: 'timeTrackerRequestTypeRemovedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Removed This Request Type`
  String get timeTrackerRequestTypeRemoved {
    return Intl.message(
      'You Successfully Removed This Request Type',
      name: 'timeTrackerRequestTypeRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Deactivate This Request Type ?`
  String get timeTrackerDeactivateRequestTypeConfirm {
    return Intl.message(
      'Are You Sure You Want To Deactivate This Request Type ?',
      name: 'timeTrackerDeactivateRequestTypeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Activate This Request Type ?`
  String get timeTrackerActivateRequestTypeConfirm {
    return Intl.message(
      'Are You Sure You Want To Activate This Request Type ?',
      name: 'timeTrackerActivateRequestTypeConfirm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Changed the Status Of This Request Type`
  String get timeTrackerRequestTypeStatusChanged {
    return Intl.message(
      'You Successfully Changed the Status Of This Request Type',
      name: 'timeTrackerRequestTypeStatusChanged',
      desc: '',
      args: [],
    );
  }

  /// `Under Review`
  String get timeTrackerUnderReview {
    return Intl.message(
      'Under Review',
      name: 'timeTrackerUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `Canceled By HR`
  String get timeTrackerCanceledByHr {
    return Intl.message(
      'Canceled By HR',
      name: 'timeTrackerCanceledByHr',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get timeTrackerRequestWord {
    return Intl.message(
      'Request',
      name: 'timeTrackerRequestWord',
      desc: '',
      args: [],
    );
  }

  /// `Request Date`
  String get timeTrackerRequestDate {
    return Intl.message(
      'Request Date',
      name: 'timeTrackerRequestDate',
      desc: '',
      args: [],
    );
  }

  /// `Requested Timeframe`
  String get timeTrackerRequestedTimeframe {
    return Intl.message(
      'Requested Timeframe',
      name: 'timeTrackerRequestedTimeframe',
      desc: '',
      args: [],
    );
  }

  /// `{start} To {end}`
  String timeTrackerTimeframeValue(Object start, Object end) {
    return Intl.message(
      '$start To $end',
      name: 'timeTrackerTimeframeValue',
      desc: '',
      args: [start, end],
    );
  }

  /// `{date} At {time}`
  String timeTrackerDateAtTime(Object date, Object time) {
    return Intl.message(
      '$date At $time',
      name: 'timeTrackerDateAtTime',
      desc: '',
      args: [date, time],
    );
  }

  /// `{count} Days`
  String timeTrackerDaysValue(Object count) {
    return Intl.message(
      '$count Days',
      name: 'timeTrackerDaysValue',
      desc: '',
      args: [count],
    );
  }

  /// `Requests`
  String get timeTrackerRequestsExportName {
    return Intl.message(
      'Requests',
      name: 'timeTrackerRequestsExportName',
      desc: '',
      args: [],
    );
  }

  /// `Choose Type`
  String get timeTrackerChooseType {
    return Intl.message(
      'Choose Type',
      name: 'timeTrackerChooseType',
      desc: '',
      args: [],
    );
  }

  /// `All Employees`
  String get timeTrackerAllEmployees {
    return Intl.message(
      'All Employees',
      name: 'timeTrackerAllEmployees',
      desc: '',
      args: [],
    );
  }

  /// `No request type is available to you yet. Ask HR to add one.`
  String get timeTrackerNoRequestTypesAvailable {
    return Intl.message(
      'No request type is available to you yet. Ask HR to add one.',
      name: 'timeTrackerNoRequestTypesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Request Details`
  String get timeTrackerRequestDetails {
    return Intl.message(
      'Request Details',
      name: 'timeTrackerRequestDetails',
      desc: '',
      args: [],
    );
  }

  /// `Date Requested`
  String get timeTrackerDateRequested {
    return Intl.message(
      'Date Requested',
      name: 'timeTrackerDateRequested',
      desc: '',
      args: [],
    );
  }

  /// `Requested by`
  String get timeTrackerRequestedBy {
    return Intl.message(
      'Requested by',
      name: 'timeTrackerRequestedBy',
      desc: '',
      args: [],
    );
  }

  /// `Job Title`
  String get timeTrackerJobTitle {
    return Intl.message(
      'Job Title',
      name: 'timeTrackerJobTitle',
      desc: '',
      args: [],
    );
  }

  /// `Approval Cycle`
  String get timeTrackerApprovalCycle {
    return Intl.message(
      'Approval Cycle',
      name: 'timeTrackerApprovalCycle',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Rejection`
  String get timeTrackerReasonsOfRejection {
    return Intl.message(
      'Reasons of Rejection',
      name: 'timeTrackerReasonsOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `Reasons of Cancellation`
  String get timeTrackerReasonsOfCancellation {
    return Intl.message(
      'Reasons of Cancellation',
      name: 'timeTrackerReasonsOfCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Manager`
  String get timeTrackerManagerStep {
    return Intl.message(
      'Manager',
      name: 'timeTrackerManagerStep',
      desc: '',
      args: [],
    );
  }

  /// `HR`
  String get timeTrackerHrStep {
    return Intl.message('HR', name: 'timeTrackerHrStep', desc: '', args: []);
  }

  /// `{role} · {decision}`
  String timeTrackerStepDecision(Object role, Object decision) {
    return Intl.message(
      '$role · $decision',
      name: 'timeTrackerStepDecision',
      desc: '',
      args: [role, decision],
    );
  }

  /// `Inquiries And Comments`
  String get timeTrackerInquiriesAndComments {
    return Intl.message(
      'Inquiries And Comments',
      name: 'timeTrackerInquiriesAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Write a Comment`
  String get timeTrackerWriteComment {
    return Intl.message(
      'Write a Comment',
      name: 'timeTrackerWriteComment',
      desc: '',
      args: [],
    );
  }

  /// `No comments yet.`
  String get timeTrackerNoComments {
    return Intl.message(
      'No comments yet.',
      name: 'timeTrackerNoComments',
      desc: '',
      args: [],
    );
  }

  /// `Edited`
  String get timeTrackerEdited {
    return Intl.message(
      'Edited',
      name: 'timeTrackerEdited',
      desc: '',
      args: [],
    );
  }

  /// `This request is not available.`
  String get timeTrackerRequestNotFound {
    return Intl.message(
      'This request is not available.',
      name: 'timeTrackerRequestNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Creating New Request`
  String get timeTrackerCreatingNewRequest {
    return Intl.message(
      'Creating New Request',
      name: 'timeTrackerCreatingNewRequest',
      desc: '',
      args: [],
    );
  }

  /// `All Day`
  String get timeTrackerAllDay {
    return Intl.message(
      'All Day',
      name: 'timeTrackerAllDay',
      desc: '',
      args: [],
    );
  }

  /// `Start Time`
  String get timeTrackerStartTime {
    return Intl.message(
      'Start Time',
      name: 'timeTrackerStartTime',
      desc: '',
      args: [],
    );
  }

  /// `End Time`
  String get timeTrackerEndTime {
    return Intl.message(
      'End Time',
      name: 'timeTrackerEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Request Attachments`
  String get timeTrackerRequestAttachments {
    return Intl.message(
      'Request Attachments',
      name: 'timeTrackerRequestAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Choose the request type.`
  String get timeTrackerRequestTypeRequired {
    return Intl.message(
      'Choose the request type.',
      name: 'timeTrackerRequestTypeRequired',
      desc: '',
      args: [],
    );
  }

  /// `This request type needs a description.`
  String get timeTrackerDescriptionRequired {
    return Intl.message(
      'This request type needs a description.',
      name: 'timeTrackerDescriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose the end date.`
  String get timeTrackerEndDateRequired {
    return Intl.message(
      'Choose the end date.',
      name: 'timeTrackerEndDateRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose the start time.`
  String get timeTrackerStartTimeRequired {
    return Intl.message(
      'Choose the start time.',
      name: 'timeTrackerStartTimeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Choose the end time.`
  String get timeTrackerEndTimeRequired {
    return Intl.message(
      'Choose the end time.',
      name: 'timeTrackerEndTimeRequired',
      desc: '',
      args: [],
    );
  }

  /// `The end must be after the start.`
  String get timeTrackerEndAfterStart {
    return Intl.message(
      'The end must be after the start.',
      name: 'timeTrackerEndAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `This request type needs an attachment.`
  String get timeTrackerAttachmentsRequired {
    return Intl.message(
      'This request type needs an attachment.',
      name: 'timeTrackerAttachmentsRequired',
      desc: '',
      args: [],
    );
  }

  /// `This request needs {days} vacation days, but only {left} are left.`
  String timeTrackerExceedsBalance(Object days, Object left) {
    return Intl.message(
      'This request needs $days vacation days, but only $left are left.',
      name: 'timeTrackerExceedsBalance',
      desc: '',
      args: [days, left],
    );
  }

  /// `Creating Request`
  String get timeTrackerCreatingRequest {
    return Intl.message(
      'Creating Request',
      name: 'timeTrackerCreatingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Create This Request ?`
  String get timeTrackerCreateRequestConfirm {
    return Intl.message(
      'Are You Sure You Want To Create This Request ?',
      name: 'timeTrackerCreateRequestConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get timeTrackerSuccessful {
    return Intl.message(
      'Successful',
      name: 'timeTrackerSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Your Request Has Been Successfully Submitted`
  String get timeTrackerRequestSubmitted {
    return Intl.message(
      'Your Request Has Been Successfully Submitted',
      name: 'timeTrackerRequestSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Request To Cancellation`
  String get timeTrackerRequestToCancellation {
    return Intl.message(
      'Request To Cancellation',
      name: 'timeTrackerRequestToCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Cancel This Request ?`
  String get timeTrackerCancelRequestConfirm {
    return Intl.message(
      'Are You Sure You Want To Cancel This Request ?',
      name: 'timeTrackerCancelRequestConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Cancellation`
  String get timeTrackerReasonOfCancellation {
    return Intl.message(
      'Reason Of Cancellation',
      name: 'timeTrackerReasonOfCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Request Cancellation`
  String get timeTrackerRequestCancellationTitle {
    return Intl.message(
      'Request Cancellation',
      name: 'timeTrackerRequestCancellationTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Requested Cancellation For This Request`
  String get timeTrackerCancellationRequested {
    return Intl.message(
      'You Successfully Requested Cancellation For This Request',
      name: 'timeTrackerCancellationRequested',
      desc: '',
      args: [],
    );
  }

  /// `Request Canceled`
  String get timeTrackerRequestCanceledTitle {
    return Intl.message(
      'Request Canceled',
      name: 'timeTrackerRequestCanceledTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Canceled This Request`
  String get timeTrackerRequestCanceled {
    return Intl.message(
      'You Successfully Canceled This Request',
      name: 'timeTrackerRequestCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Was Sent On {date}`
  String timeTrackerReminderSentOn(Object date) {
    return Intl.message(
      'Reminder Was Sent On $date',
      name: 'timeTrackerReminderSentOn',
      desc: '',
      args: [date],
    );
  }

  /// `You Can Only Send A Reminder Once Every Two Days. Feel Free To Contact Your Supervisor Directly For Assistance`
  String get timeTrackerReminderRule {
    return Intl.message(
      'You Can Only Send A Reminder Once Every Two Days. Feel Free To Contact Your Supervisor Directly For Assistance',
      name: 'timeTrackerReminderRule',
      desc: '',
      args: [],
    );
  }

  /// `Approve Request`
  String get timeTrackerApproveRequest {
    return Intl.message(
      'Approve Request',
      name: 'timeTrackerApproveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Approve This Request ?`
  String get timeTrackerApproveRequestConfirm {
    return Intl.message(
      'Are You Sure You Want To Approve This Request ?',
      name: 'timeTrackerApproveRequestConfirm',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Approved This Request`
  String get timeTrackerRequestApproved {
    return Intl.message(
      'You Successfully Approved This Request',
      name: 'timeTrackerRequestApproved',
      desc: '',
      args: [],
    );
  }

  /// `Reject Request`
  String get timeTrackerRejectRequest {
    return Intl.message(
      'Reject Request',
      name: 'timeTrackerRejectRequest',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reject This Request ?`
  String get timeTrackerRejectRequestConfirm {
    return Intl.message(
      'Are You Sure You Want To Reject This Request ?',
      name: 'timeTrackerRejectRequestConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Reason Of Rejection`
  String get timeTrackerReasonOfRejection {
    return Intl.message(
      'Reason Of Rejection',
      name: 'timeTrackerReasonOfRejection',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Rejected This Request`
  String get timeTrackerRequestRejected {
    return Intl.message(
      'You Successfully Rejected This Request',
      name: 'timeTrackerRequestRejected',
      desc: '',
      args: [],
    );
  }

  /// `Approve Cancellation`
  String get timeTrackerApproveCancellation {
    return Intl.message(
      'Approve Cancellation',
      name: 'timeTrackerApproveCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Approve The Cancellation Of This Request ?`
  String get timeTrackerApproveCancellationConfirm {
    return Intl.message(
      'Are You Sure You Want To Approve The Cancellation Of This Request ?',
      name: 'timeTrackerApproveCancellationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation Approved`
  String get timeTrackerCancellationApprovedTitle {
    return Intl.message(
      'Cancellation Approved',
      name: 'timeTrackerCancellationApprovedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Approved The Cancellation Of This Request`
  String get timeTrackerCancellationApproved {
    return Intl.message(
      'You Successfully Approved The Cancellation Of This Request',
      name: 'timeTrackerCancellationApproved',
      desc: '',
      args: [],
    );
  }

  /// `Reject Cancellation`
  String get timeTrackerRejectCancellation {
    return Intl.message(
      'Reject Cancellation',
      name: 'timeTrackerRejectCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Reject The Cancellation Of This Request ?`
  String get timeTrackerRejectCancellationConfirm {
    return Intl.message(
      'Are You Sure You Want To Reject The Cancellation Of This Request ?',
      name: 'timeTrackerRejectCancellationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation Rejected`
  String get timeTrackerCancellationRejectedTitle {
    return Intl.message(
      'Cancellation Rejected',
      name: 'timeTrackerCancellationRejectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Request Stays Approved`
  String get timeTrackerCancellationRejected {
    return Intl.message(
      'The Request Stays Approved',
      name: 'timeTrackerCancellationRejected',
      desc: '',
      args: [],
    );
  }

  /// `Deleting Comment`
  String get timeTrackerDeletingComment {
    return Intl.message(
      'Deleting Comment',
      name: 'timeTrackerDeletingComment',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Delete This Comment ?`
  String get timeTrackerDeleteCommentConfirm {
    return Intl.message(
      'Are You Sure You Want To Delete This Comment ?',
      name: 'timeTrackerDeleteCommentConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Comment Deleted`
  String get timeTrackerCommentDeletedTitle {
    return Intl.message(
      'Comment Deleted',
      name: 'timeTrackerCommentDeletedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Deleted This Comment`
  String get timeTrackerCommentDeleted {
    return Intl.message(
      'You Successfully Deleted This Comment',
      name: 'timeTrackerCommentDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Select State or Province`
  String get timeTrackerSelectState {
    return Intl.message(
      'Select State or Province',
      name: 'timeTrackerSelectState',
      desc: '',
      args: [],
    );
  }

  /// `Vacations`
  String get timeTrackerVacations {
    return Intl.message(
      'Vacations',
      name: 'timeTrackerVacations',
      desc: '',
      args: [],
    );
  }

  /// `Tracker Approver`
  String get timeTrackerTrackerApprover {
    return Intl.message(
      'Tracker Approver',
      name: 'timeTrackerTrackerApprover',
      desc: '',
      args: [],
    );
  }

  /// `Pending Approvals`
  String get timeTrackerPendingApprovals {
    return Intl.message(
      'Pending Approvals',
      name: 'timeTrackerPendingApprovals',
      desc: '',
      args: [],
    );
  }

  /// `No Pending Approvals`
  String get timeTrackerNoPendingApprovals {
    return Intl.message(
      'No Pending Approvals',
      name: 'timeTrackerNoPendingApprovals',
      desc: '',
      args: [],
    );
  }

  /// `My Dashboard`
  String get timeTrackerMyDashboard {
    return Intl.message(
      'My Dashboard',
      name: 'timeTrackerMyDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get timeTrackerOthers {
    return Intl.message(
      'Others',
      name: 'timeTrackerOthers',
      desc: '',
      args: [],
    );
  }

  /// `Attendance History`
  String get timeTrackerAttendanceHistory {
    return Intl.message(
      'Attendance History',
      name: 'timeTrackerAttendanceHistory',
      desc: '',
      args: [],
    );
  }

  /// `Request Timeline`
  String get timeTrackerRequestTimeline {
    return Intl.message(
      'Request Timeline',
      name: 'timeTrackerRequestTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Checked In Now`
  String get timeTrackerCheckedInNow {
    return Intl.message(
      'Checked In Now',
      name: 'timeTrackerCheckedInNow',
      desc: '',
      args: [],
    );
  }

  /// `Late Today`
  String get timeTrackerLateToday {
    return Intl.message(
      'Late Today',
      name: 'timeTrackerLateToday',
      desc: '',
      args: [],
    );
  }

  /// `Absent Today`
  String get timeTrackerAbsentToday {
    return Intl.message(
      'Absent Today',
      name: 'timeTrackerAbsentToday',
      desc: '',
      args: [],
    );
  }

  /// `On Leave Today`
  String get timeTrackerOnLeaveToday {
    return Intl.message(
      'On Leave Today',
      name: 'timeTrackerOnLeaveToday',
      desc: '',
      args: [],
    );
  }

  /// `Needs Attention`
  String get timeTrackerNeedsAttention {
    return Intl.message(
      'Needs Attention',
      name: 'timeTrackerNeedsAttention',
      desc: '',
      args: [],
    );
  }

  /// `Nothing needs your attention right now.`
  String get timeTrackerAllClear {
    return Intl.message(
      'Nothing needs your attention right now.',
      name: 'timeTrackerAllClear',
      desc: '',
      args: [],
    );
  }

  /// `Approvals Pending More Than 2 Days`
  String get timeTrackerOverdueApprovals {
    return Intl.message(
      'Approvals Pending More Than 2 Days',
      name: 'timeTrackerOverdueApprovals',
      desc: '',
      args: [],
    );
  }

  /// `3 or More Absences This Month`
  String get timeTrackerFrequentAbsences {
    return Intl.message(
      '3 or More Absences This Month',
      name: 'timeTrackerFrequentAbsences',
      desc: '',
      args: [],
    );
  }

  /// `Missing Check-Outs Yesterday`
  String get timeTrackerMissingCheckOuts {
    return Intl.message(
      'Missing Check-Outs Yesterday',
      name: 'timeTrackerMissingCheckOuts',
      desc: '',
      args: [],
    );
  }

  /// `Transactions Waiting`
  String get timeTrackerTransactionsWaiting {
    return Intl.message(
      'Transactions Waiting',
      name: 'timeTrackerTransactionsWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Waiting {count}`
  String timeTrackerWaitingDays(Object count) {
    return Intl.message(
      'Waiting $count',
      name: 'timeTrackerWaitingDays',
      desc: '',
      args: [count],
    );
  }

  /// `{count} absences`
  String timeTrackerAbsencesCount(Object count) {
    return Intl.message(
      '$count absences',
      name: 'timeTrackerAbsencesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Checked in at {time}, no check-out`
  String timeTrackerCheckedInNoCheckOut(Object time) {
    return Intl.message(
      'Checked in at $time, no check-out',
      name: 'timeTrackerCheckedInNoCheckOut',
      desc: '',
      args: [time],
    );
  }

  /// `+{count} more`
  String timeTrackerMoreItems(Object count) {
    return Intl.message(
      '+$count more',
      name: 'timeTrackerMoreItems',
      desc: '',
      args: [count],
    );
  }

  /// `HR Dashboard`
  String get timeTrackerHrDashboardExportName {
    return Intl.message(
      'HR Dashboard',
      name: 'timeTrackerHrDashboardExportName',
      desc: '',
      args: [],
    );
  }

  /// `Section`
  String get timeTrackerExportSection {
    return Intl.message(
      'Section',
      name: 'timeTrackerExportSection',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get timeTrackerExportItem {
    return Intl.message(
      'Item',
      name: 'timeTrackerExportItem',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get timeTrackerExportValue {
    return Intl.message(
      'Value',
      name: 'timeTrackerExportValue',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get timeTrackerFiltersTitle {
    return Intl.message(
      'Filters',
      name: 'timeTrackerFiltersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Employees Included`
  String get timeTrackerEmployeesInScope {
    return Intl.message(
      'Employees Included',
      name: 'timeTrackerEmployeesInScope',
      desc: '',
      args: [],
    );
  }

  /// `Total Days`
  String get timeTrackerTotalDays {
    return Intl.message(
      'Total Days',
      name: 'timeTrackerTotalDays',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get timeTrackerUsedDays {
    return Intl.message(
      'Used',
      name: 'timeTrackerUsedDays',
      desc: '',
      args: [],
    );
  }

  /// `Remaining`
  String get timeTrackerRemainingDays {
    return Intl.message(
      'Remaining',
      name: 'timeTrackerRemainingDays',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balances`
  String get timeTrackerVacationBalancesExportName {
    return Intl.message(
      'Vacation Balances',
      name: 'timeTrackerVacationBalancesExportName',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balances Template`
  String get timeTrackerVacationTemplateName {
    return Intl.message(
      'Vacation Balances Template',
      name: 'timeTrackerVacationTemplateName',
      desc: '',
      args: [],
    );
  }

  /// `Enter the total days.`
  String get timeTrackerTotalDaysRequired {
    return Intl.message(
      'Enter the total days.',
      name: 'timeTrackerTotalDaysRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a number of days, with at most one decimal.`
  String get timeTrackerTotalDaysInvalid {
    return Intl.message(
      'Enter a number of days, with at most one decimal.',
      name: 'timeTrackerTotalDaysInvalid',
      desc: '',
      args: [],
    );
  }

  /// `A year has at most 366 days.`
  String get timeTrackerTotalDaysTooLarge {
    return Intl.message(
      'A year has at most 366 days.',
      name: 'timeTrackerTotalDaysTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Edit This Vacation Balance ?`
  String get timeTrackerEditVacationConfirm {
    return Intl.message(
      'Are You Sure You Want To Edit This Vacation Balance ?',
      name: 'timeTrackerEditVacationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balance Edited`
  String get timeTrackerVacationEditedTitle {
    return Intl.message(
      'Vacation Balance Edited',
      name: 'timeTrackerVacationEditedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Edited This Vacation Balance`
  String get timeTrackerVacationEdited {
    return Intl.message(
      'You Successfully Edited This Vacation Balance',
      name: 'timeTrackerVacationEdited',
      desc: '',
      args: [],
    );
  }

  /// `Download the template, set each employee's Total Days for {year}, then upload it. A blank Year means {year}; other years are skipped. Nothing is deleted.`
  String timeTrackerVacationImportHelp(Object year) {
    return Intl.message(
      'Download the template, set each employee\'s Total Days for $year, then upload it. A blank Year means $year; other years are skipped. Nothing is deleted.',
      name: 'timeTrackerVacationImportHelp',
      desc: '',
      args: [year],
    );
  }

  /// `No employee has this email`
  String get timeTrackerImportUnknownEmployee {
    return Intl.message(
      'No employee has this email',
      name: 'timeTrackerImportUnknownEmployee',
      desc: '',
      args: [],
    );
  }

  /// `This email appears more than once in the file`
  String get timeTrackerImportDuplicateEmail {
    return Intl.message(
      'This email appears more than once in the file',
      name: 'timeTrackerImportDuplicateEmail',
      desc: '',
      args: [],
    );
  }

  /// `Only {year} can be imported`
  String timeTrackerImportWrongYear(Object year) {
    return Intl.message(
      'Only $year can be imported',
      name: 'timeTrackerImportWrongYear',
      desc: '',
      args: [year],
    );
  }

  /// `The file needs the “Email” and “Total Days” columns. Please use the template.`
  String get timeTrackerVacationImportNoColumns {
    return Intl.message(
      'The file needs the “Email” and “Total Days” columns. Please use the template.',
      name: 'timeTrackerVacationImportNoColumns',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want To Import These Vacation Balances ?`
  String get timeTrackerVacationImportConfirm {
    return Intl.message(
      'Are You Sure You Want To Import These Vacation Balances ?',
      name: 'timeTrackerVacationImportConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Vacation Balances Imported`
  String get timeTrackerVacationImportDoneTitle {
    return Intl.message(
      'Vacation Balances Imported',
      name: 'timeTrackerVacationImportDoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `You Successfully Imported The Vacation Balances`
  String get timeTrackerVacationImportDone {
    return Intl.message(
      'You Successfully Imported The Vacation Balances',
      name: 'timeTrackerVacationImportDone',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get timeTrackerImport {
    return Intl.message(
      'Import',
      name: 'timeTrackerImport',
      desc: '',
      args: [],
    );
  }

  /// `User Limits`
  String get userLimitsTitle {
    return Intl.message(
      'User Limits',
      name: 'userLimitsTitle',
      desc: '',
      args: [],
    );
  }

  /// `{module}: {assigned} of {limit} users`
  String userLimitModuleUsage(Object module, Object assigned, Object limit) {
    return Intl.message(
      '$module: $assigned of $limit users',
      name: 'userLimitModuleUsage',
      desc: '',
      args: [module, assigned, limit],
    );
  }

  /// `Users: {assigned} of {limit}`
  String userLimitTotalUsage(Object assigned, Object limit) {
    return Intl.message(
      'Users: $assigned of $limit',
      name: 'userLimitTotalUsage',
      desc: '',
      args: [assigned, limit],
    );
  }

  /// `{module} allows {limit} users. {assigned} are already assigned.`
  String userLimitModuleReached(Object module, Object limit, Object assigned) {
    return Intl.message(
      '$module allows $limit users. $assigned are already assigned.',
      name: 'userLimitModuleReached',
      desc: '',
      args: [module, limit, assigned],
    );
  }

  /// `Your plan allows {limit} users. {assigned} are already assigned.`
  String userLimitTotalReached(Object limit, Object assigned) {
    return Intl.message(
      'Your plan allows $limit users. $assigned are already assigned.',
      name: 'userLimitTotalReached',
      desc: '',
      args: [limit, assigned],
    );
  }

  /// `Only {remaining} more can be added.`
  String userLimitSeatsLeft(Object remaining) {
    return Intl.message(
      'Only $remaining more can be added.',
      name: 'userLimitSeatsLeft',
      desc: '',
      args: [remaining],
    );
  }

  /// `The user limit for {module} could not be read, so no access was granted.`
  String userLimitModuleUnverifiable(Object module) {
    return Intl.message(
      'The user limit for $module could not be read, so no access was granted.',
      name: 'userLimitModuleUnverifiable',
      desc: '',
      args: [module],
    );
  }

  /// `The company user limit could not be read, so no access was granted.`
  String get userLimitTotalUnverifiable {
    return Intl.message(
      'The company user limit could not be read, so no access was granted.',
      name: 'userLimitTotalUnverifiable',
      desc: '',
      args: [],
    );
  }

  /// `The role "{role}" could not be found, so its user limits cannot be checked.`
  String userLimitUnknownRole(Object role) {
    return Intl.message(
      'The role "$role" could not be found, so its user limits cannot be checked.',
      name: 'userLimitUnknownRole',
      desc: '',
      args: [role],
    );
  }

  /// `Could not verify the user limits, so no access was granted. Please try again.`
  String get userLimitCheckFailed {
    return Intl.message(
      'Could not verify the user limits, so no access was granted. Please try again.',
      name: 'userLimitCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `Checking user limits…`
  String get userLimitChecking {
    return Intl.message(
      'Checking user limits…',
      name: 'userLimitChecking',
      desc: '',
      args: [],
    );
  }

  /// `The check-out must be on the same day as the check-in`
  String get timeTrackerCheckOutSameDay {
    return Intl.message(
      'The check-out must be on the same day as the check-in',
      name: 'timeTrackerCheckOutSameDay',
      desc: '',
      args: [],
    );
  }

  /// `The check-out must be on the check-in day or the next day`
  String get timeTrackerCheckOutSameOrNextDay {
    return Intl.message(
      'The check-out must be on the check-in day or the next day',
      name: 'timeTrackerCheckOutSameOrNextDay',
      desc: '',
      args: [],
    );
  }

  /// `A correction cannot be longer than 24 hours`
  String get timeTrackerTransactionTooLong {
    return Intl.message(
      'A correction cannot be longer than 24 hours',
      name: 'timeTrackerTransactionTooLong',
      desc: '',
      args: [],
    );
  }

  /// `This request was just changed by someone else. Please check it and try again.`
  String get timeTrackerRequestChangedMeanwhile {
    return Intl.message(
      'This request was just changed by someone else. Please check it and try again.',
      name: 'timeTrackerRequestChangedMeanwhile',
      desc: '',
      args: [],
    );
  }

  /// `This employee has no vacation balance yet. Please set it in Vacation Balances first.`
  String get timeTrackerNoBalanceApprover {
    return Intl.message(
      'This employee has no vacation balance yet. Please set it in Vacation Balances first.',
      name: 'timeTrackerNoBalanceApprover',
      desc: '',
      args: [],
    );
  }

  /// `No vacation balance has been set for you yet. Please contact HR.`
  String get timeTrackerNoBalanceEmployee {
    return Intl.message(
      'No vacation balance has been set for you yet. Please contact HR.',
      name: 'timeTrackerNoBalanceEmployee',
      desc: '',
      args: [],
    );
  }

  /// `You already have a request for this time`
  String get timeTrackerRequestOverlaps {
    return Intl.message(
      'You already have a request for this time',
      name: 'timeTrackerRequestOverlaps',
      desc: '',
      args: [],
    );
  }

  /// `Location In Use`
  String get timeTrackerLocationInUseTitle {
    return Intl.message(
      'Location In Use',
      name: 'timeTrackerLocationInUseTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} employees are assigned to this location. Reassign them first.`
  String timeTrackerLocationInUse(Object count) {
    return Intl.message(
      '$count employees are assigned to this location. Reassign them first.',
      name: 'timeTrackerLocationInUse',
      desc: '',
      args: [count],
    );
  }

  /// `Your device is using a fake (mock) location. Please turn it off to check in.`
  String get timeTrackerMockedLocation {
    return Intl.message(
      'Your device is using a fake (mock) location. Please turn it off to check in.',
      name: 'timeTrackerMockedLocation',
      desc: '',
      args: [],
    );
  }

  /// `You can't approve or reject your own request. Another reviewer must decide it.`
  String get selfApprovalBlocked {
    return Intl.message(
      'You can\'t approve or reject your own request. Another reviewer must decide it.',
      name: 'selfApprovalBlocked',
      desc: '',
      args: [],
    );
  }

  /// `This decision could not be verified, so nothing was saved. Please sign in again and retry.`
  String get requestDecisionUnverifiable {
    return Intl.message(
      'This decision could not be verified, so nothing was saved. Please sign in again and retry.',
      name: 'requestDecisionUnverifiable',
      desc: '',
      args: [],
    );
  }

  /// `This is your own request. Another reviewer must approve or reject it.`
  String get ownRequestReviewNote {
    return Intl.message(
      'This is your own request. Another reviewer must approve or reject it.',
      name: 'ownRequestReviewNote',
      desc: '',
      args: [],
    );
  }

  /// `Optional. If you add a second contact, fill in all of its fields.`
  String get secondContactOptionalHint {
    return Intl.message(
      'Optional. If you add a second contact, fill in all of its fields.',
      name: 'secondContactOptionalHint',
      desc: '',
      args: [],
    );
  }

  /// `Fill in every field of the second emergency contact, or leave it all empty.`
  String get secondContactIncomplete {
    return Intl.message(
      'Fill in every field of the second emergency contact, or leave it all empty.',
      name: 'secondContactIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String timeTrackerMembersSelected(Object count) {
    return Intl.message(
      '$count selected',
      name: 'timeTrackerMembersSelected',
      desc: '',
      args: [count],
    );
  }

  /// `اسم المجموعة`
  String get timeTrackerGroupNameAr {
    return Intl.message(
      'اسم المجموعة',
      name: 'timeTrackerGroupNameAr',
      desc: '',
      args: [],
    );
  }

  /// `Rules from {location}`
  String timeTrackerRulesFromLocation(Object location) {
    return Intl.message(
      'Rules from $location',
      name: 'timeTrackerRulesFromLocation',
      desc: '',
      args: [location],
    );
  }

  /// `Use the location's rules`
  String get timeTrackerUseLocationRules {
    return Intl.message(
      'Use the location\'s rules',
      name: 'timeTrackerUseLocationRules',
      desc: '',
      args: [],
    );
  }

  /// `Custom rules for this group`
  String get timeTrackerCustomRulesGroup {
    return Intl.message(
      'Custom rules for this group',
      name: 'timeTrackerCustomRulesGroup',
      desc: '',
      args: [],
    );
  }

  /// `Custom rules for this employee`
  String get timeTrackerCustomRulesEmployee {
    return Intl.message(
      'Custom rules for this employee',
      name: 'timeTrackerCustomRulesEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Custom — overrides the location`
  String get timeTrackerCustomOverridesLocation {
    return Intl.message(
      'Custom — overrides the location',
      name: 'timeTrackerCustomOverridesLocation',
      desc: '',
      args: [],
    );
  }

  /// `From location`
  String get timeTrackerRulesFromLocationTag {
    return Intl.message(
      'From location',
      name: 'timeTrackerRulesFromLocationTag',
      desc: '',
      args: [],
    );
  }

  /// `Late after {minutes} min`
  String timeTrackerLateAfterMinutes(Object minutes) {
    return Intl.message(
      'Late after $minutes min',
      name: 'timeTrackerLateAfterMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `Breaks {minutes} min`
  String timeTrackerBreaksMinutes(Object minutes) {
    return Intl.message(
      'Breaks $minutes min',
      name: 'timeTrackerBreaksMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `No breaks`
  String get timeTrackerNoBreaks {
    return Intl.message(
      'No breaks',
      name: 'timeTrackerNoBreaks',
      desc: '',
      args: [],
    );
  }

  /// `Pause allowed`
  String get timeTrackerPauseAllowed {
    return Intl.message(
      'Pause allowed',
      name: 'timeTrackerPauseAllowed',
      desc: '',
      args: [],
    );
  }

  /// `No pause`
  String get timeTrackerNoPause {
    return Intl.message(
      'No pause',
      name: 'timeTrackerNoPause',
      desc: '',
      args: [],
    );
  }

  /// `وصف المجموعة`
  String get timeTrackerGroupDescriptionAr {
    return Intl.message(
      'وصف المجموعة',
      name: 'timeTrackerGroupDescriptionAr',
      desc: '',
      args: [],
    );
  }

  /// `Maximum pause (minutes)`
  String get timeTrackerMaxPauseMinutes {
    return Intl.message(
      'Maximum pause (minutes)',
      name: 'timeTrackerMaxPauseMinutes',
      desc: '',
      args: [],
    );
  }

  /// `No limit`
  String get timeTrackerNoLimit {
    return Intl.message(
      'No limit',
      name: 'timeTrackerNoLimit',
      desc: '',
      args: [],
    );
  }

  /// `Pause up to {minutes} min`
  String timeTrackerPauseUpToMinutes(String minutes) {
    return Intl.message(
      'Pause up to $minutes min',
      name: 'timeTrackerPauseUpToMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `Demo tools`
  String get timeTrackerDemoTools {
    return Intl.message(
      'Demo tools',
      name: 'timeTrackerDemoTools',
      desc: '',
      args: [],
    );
  }

  /// `Available in debug builds only. Adds realistic sample records to every Time Tracker tab. Existing records are never changed.`
  String get timeTrackerDemoToolsHint {
    return Intl.message(
      'Available in debug builds only. Adds realistic sample records to every Time Tracker tab. Existing records are never changed.',
      name: 'timeTrackerDemoToolsHint',
      desc: '',
      args: [],
    );
  }

  /// `Load demo data`
  String get timeTrackerDemoLoad {
    return Intl.message(
      'Load demo data',
      name: 'timeTrackerDemoLoad',
      desc: '',
      args: [],
    );
  }

  /// `{count} demo records and {files} documents added.`
  String timeTrackerDemoLoadDone(String count, String files) {
    return Intl.message(
      '$count demo records and $files documents added.',
      name: 'timeTrackerDemoLoadDone',
      desc: '',
      args: [count, files],
    );
  }

  /// `The demo data is already loaded.`
  String get timeTrackerDemoAlreadyLoaded {
    return Intl.message(
      'The demo data is already loaded.',
      name: 'timeTrackerDemoAlreadyLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Remove demo data`
  String get timeTrackerDemoRemove {
    return Intl.message(
      'Remove demo data',
      name: 'timeTrackerDemoRemove',
      desc: '',
      args: [],
    );
  }

  /// `{count} demo records removed.`
  String timeTrackerDemoRemoveDone(String count) {
    return Intl.message(
      '$count demo records removed.',
      name: 'timeTrackerDemoRemoveDone',
      desc: '',
      args: [count],
    );
  }

  /// `Attendance Updated`
  String get timeTrackerAttendanceUpdatedTitle {
    return Intl.message(
      'Attendance Updated',
      name: 'timeTrackerAttendanceUpdatedTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have already checked out. The screen now shows your latest attendance.`
  String get timeTrackerAlreadyCheckedOut {
    return Intl.message(
      'You have already checked out. The screen now shows your latest attendance.',
      name: 'timeTrackerAlreadyCheckedOut',
      desc: '',
      args: [],
    );
  }

  /// `Your attendance was changed on another screen or device. It has been refreshed, please check it and try again.`
  String get timeTrackerAttendanceChanged {
    return Intl.message(
      'Your attendance was changed on another screen or device. It has been refreshed, please check it and try again.',
      name: 'timeTrackerAttendanceChanged',
      desc: '',
      args: [],
    );
  }

  /// `From Date`
  String get timeTrackerDateFrom {
    return Intl.message(
      'From Date',
      name: 'timeTrackerDateFrom',
      desc: '',
      args: [],
    );
  }

  /// `To Date`
  String get timeTrackerDateTo {
    return Intl.message(
      'To Date',
      name: 'timeTrackerDateTo',
      desc: '',
      args: [],
    );
  }

  /// `Work Location Type`
  String get timeTrackerWorkLocationType {
    return Intl.message(
      'Work Location Type',
      name: 'timeTrackerWorkLocationType',
      desc: '',
      args: [],
    );
  }

  /// `Choose Employee`
  String get timeTrackerChooseEmployee {
    return Intl.message(
      'Choose Employee',
      name: 'timeTrackerChooseEmployee',
      desc: '',
      args: [],
    );
  }

  /// `The end date must be on or after the start date.`
  String get timeTrackerDateRangeError {
    return Intl.message(
      'The end date must be on or after the start date.',
      name: 'timeTrackerDateRangeError',
      desc: '',
      args: [],
    );
  }

  /// `Assign Date`
  String get timeTrackerAssignDateLabel {
    return Intl.message(
      'Assign Date',
      name: 'timeTrackerAssignDateLabel',
      desc: '',
      args: [],
    );
  }

  /// `🧪 Test employee`
  String get debugTestEmployeeButton {
    return Intl.message(
      '🧪 Test employee',
      name: 'debugTestEmployeeButton',
      desc: '',
      args: [],
    );
  }

  /// `🧪 Switch to test employee`
  String get debugSwitchToTestEmployee {
    return Intl.message(
      '🧪 Switch to test employee',
      name: 'debugSwitchToTestEmployee',
      desc: '',
      args: [],
    );
  }

  /// `🧪 Test Employees`
  String get debugTestEmployeeTitle {
    return Intl.message(
      '🧪 Test Employees',
      name: 'debugTestEmployeeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Debug builds only. Signs in as the chosen test account without its password; its role, status and access dates are still checked.`
  String get debugTestEmployeeHint {
    return Intl.message(
      'Debug builds only. Signs in as the chosen test account without its password; its role, status and access dates are still checked.',
      name: 'debugTestEmployeeHint',
      desc: '',
      args: [],
    );
  }

  /// `Company ID`
  String get debugTestEmployeeCompanyId {
    return Intl.message(
      'Company ID',
      name: 'debugTestEmployeeCompanyId',
      desc: '',
      args: [],
    );
  }

  /// `Load`
  String get debugTestEmployeeLoad {
    return Intl.message(
      'Load',
      name: 'debugTestEmployeeLoad',
      desc: '',
      args: [],
    );
  }

  /// `No test employees found in this company (emails ending in {domains}).`
  String debugTestEmployeeEmpty(String domains) {
    return Intl.message(
      'No test employees found in this company (emails ending in $domains).',
      name: 'debugTestEmployeeEmpty',
      desc: '',
      args: [domains],
    );
  }

  /// `Could not load this company's employees.`
  String get debugTestEmployeeLoadFailed {
    return Intl.message(
      'Could not load this company\'s employees.',
      name: 'debugTestEmployeeLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `DEBUG: test employee`
  String get debugTestEmployeeBadge {
    return Intl.message(
      'DEBUG: test employee',
      name: 'debugTestEmployeeBadge',
      desc: '',
      args: [],
    );
  }

  /// `Cannot Switch`
  String get debugTestEmployeeCannotSwitch {
    return Intl.message(
      'Cannot Switch',
      name: 'debugTestEmployeeCannotSwitch',
      desc: '',
      args: [],
    );
  }

  /// `This is available in debug builds only.`
  String get debugTestEmployeeDebugOnly {
    return Intl.message(
      'This is available in debug builds only.',
      name: 'debugTestEmployeeDebugOnly',
      desc: '',
      args: [],
    );
  }

  /// `Only test accounts can be used (emails ending in {domains}).`
  String debugTestEmployeeNotTestEmail(String domains) {
    return Intl.message(
      'Only test accounts can be used (emails ending in $domains).',
      name: 'debugTestEmployeeNotTestEmail',
      desc: '',
      args: [domains],
    );
  }

  /// `The company admin account cannot be used with the debug switch.`
  String get debugTestEmployeeCompanyAdmin {
    return Intl.message(
      'The company admin account cannot be used with the debug switch.',
      name: 'debugTestEmployeeCompanyAdmin',
      desc: '',
      args: [],
    );
  }

  /// `This account belongs to another company ({companyId}).`
  String debugTestEmployeeOtherCompany(String companyId) {
    return Intl.message(
      'This account belongs to another company ($companyId).',
      name: 'debugTestEmployeeOtherCompany',
      desc: '',
      args: [companyId],
    );
  }

  /// `This account is not activated yet. It must complete its first sign-in (password change) before it can be used here.`
  String get debugTestEmployeeNotActivated {
    return Intl.message(
      'This account is not activated yet. It must complete its first sign-in (password change) before it can be used here.',
      name: 'debugTestEmployeeNotActivated',
      desc: '',
      args: [],
    );
  }

  /// `This account cannot sign in because its status is "{status}".`
  String debugTestEmployeeStatusBlocked(String status) {
    return Intl.message(
      'This account cannot sign in because its status is "$status".',
      name: 'debugTestEmployeeStatusBlocked',
      desc: '',
      args: [status],
    );
  }

  /// `You will be signed out of this session to choose a test employee.`
  String get debugTestEmployeeConfirmSwitch {
    return Intl.message(
      'You will be signed out of this session to choose a test employee.',
      name: 'debugTestEmployeeConfirmSwitch',
      desc: '',
      args: [],
    );
  }

  /// `No role`
  String get debugTestEmployeeNoRole {
    return Intl.message(
      'No role',
      name: 'debugTestEmployeeNoRole',
      desc: '',
      args: [],
    );
  }

  /// `No department`
  String get debugTestEmployeeNoDepartment {
    return Intl.message(
      'No department',
      name: 'debugTestEmployeeNoDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Status: {status}`
  String debugTestEmployeeStatus(String status) {
    return Intl.message(
      'Status: $status',
      name: 'debugTestEmployeeStatus',
      desc: '',
      args: [status],
    );
  }

  /// `Not activated yet (signs in as activated in debug)`
  String get debugTestEmployeeNotActivatedNote {
    return Intl.message(
      'Not activated yet (signs in as activated in debug)',
      name: 'debugTestEmployeeNotActivatedNote',
      desc: '',
      args: [],
    );
  }

  /// `{year} has only {days} vacation days left.`
  String timeTrackerYearBalanceShort(String year, String days) {
    return Intl.message(
      '$year has only $days vacation days left.',
      name: 'timeTrackerYearBalanceShort',
      desc: '',
      args: [year, days],
    );
  }

  /// `1 Day`
  String get timeTrackerOneDay {
    return Intl.message('1 Day', name: 'timeTrackerOneDay', desc: '', args: []);
  }

  /// `2 Days`
  String get timeTrackerTwoDays {
    return Intl.message(
      '2 Days',
      name: 'timeTrackerTwoDays',
      desc: '',
      args: [],
    );
  }

  /// `{count} Days`
  String timeTrackerDaysFew(Object count) {
    return Intl.message(
      '$count Days',
      name: 'timeTrackerDaysFew',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Days`
  String timeTrackerDaysMany(Object count) {
    return Intl.message(
      '$count Days',
      name: 'timeTrackerDaysMany',
      desc: '',
      args: [count],
    );
  }

  /// `1 absence`
  String get timeTrackerOneAbsence {
    return Intl.message(
      '1 absence',
      name: 'timeTrackerOneAbsence',
      desc: '',
      args: [],
    );
  }

  /// `2 absences`
  String get timeTrackerTwoAbsences {
    return Intl.message(
      '2 absences',
      name: 'timeTrackerTwoAbsences',
      desc: '',
      args: [],
    );
  }

  /// `{count} absences`
  String timeTrackerAbsencesFew(Object count) {
    return Intl.message(
      '$count absences',
      name: 'timeTrackerAbsencesFew',
      desc: '',
      args: [count],
    );
  }

  /// `{count} absences`
  String timeTrackerAbsencesMany(Object count) {
    return Intl.message(
      '$count absences',
      name: 'timeTrackerAbsencesMany',
      desc: '',
      args: [count],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
