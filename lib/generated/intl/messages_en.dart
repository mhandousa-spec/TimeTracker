// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(n) => "Address #${n}: state/province is required.";

  static String m1(number) => "Contact ${number}: Email is required";

  static String m2(n) => "Contact #${n}: fax number is required.";

  static String m3(number) => "Contact ${number}: First Name is required";

  static String m4(number) => "Contact ${number}: Last Name is required";

  static String m5(n) => "Contact #${n}: middle name is required.";

  static String m6(number) => "Contact ${number}: Phone Number is required";

  static String m7(n) => "Contact #${n}: preferred language is required.";

  static String m8(n) => "Contact #${n}: title is required.";

  static String m9(number) => "Contact ${number}: Please enter a valid email";

  static String m10(count) => "Clients: ${count}";

  static String m11(date) => "Creation Date: ${date}";

  static String m12(count) => "Error: ${count}";

  static String m13(domains) =>
      "No test employees found in this company (emails ending in ${domains}).";

  static String m14(domains) =>
      "Only test accounts can be used (emails ending in ${domains}).";

  static String m15(companyId) =>
      "This account belongs to another company (${companyId}).";

  static String m16(status) => "Status: ${status}";

  static String m17(status) =>
      "This account cannot sign in because its status is \"${status}\".";

  static String m18(title) => "${title} Details";

  static String m19(documentName) => "Editing ${documentName} Details";

  static String m20(count) => "Preview ${count} Matches";

  static String m21(field) =>
      "The specified ${field} does not exist. Please verify the entry";

  static String m22(field, error) =>
      "The specified ${field} ${error}! Please verify the entry";

  static String m23(count) => "${count} Absences";

  static String m24(count) => "${count} Absences";

  static String m25(count) => "${count} Absences";

  static String m26(count) => "Assign (${count})";

  static String m27(date) => "Assign Date: ${date}";

  static String m28(minutes) => "Breaks ${minutes} min";

  static String m29(time) => "Checked in at ${time}, no check-out";

  static String m30(date) => "Created Date: ${date}";

  static String m31(date, time) => "${date} At ${time}";

  static String m32(count) => "${count} Days";

  static String m33(count) => "${count} Days";

  static String m34(count) => "${count} Days";

  static String m35(count, files) =>
      "${count} demo records and ${files} documents added.";

  static String m36(count) => "${count} demo records removed.";

  static String m37(count) => "${count} Employees Selected";

  static String m38(days, left) =>
      "This request needs ${days} vacation days, but only ${left} are left.";

  static String m39(value) => "${value} Hrs";

  static String m40(line) => "Line ${line}";

  static String m41(create, update, unchanged, skip) =>
      "${create} new · ${update} updated · ${unchanged} unchanged · ${skip} skipped";

  static String m42(column) => "Unreadable value in “${column}”";

  static String m43(year) => "Only ${year} can be imported";

  static String m44(date) => "Last Update: ${date}";

  static String m45(minutes) => "Late after ${minutes} min";

  static String m46(count) =>
      "${count} employees are assigned to this location. Reassign them first.";

  static String m47(name) => "Location: ${name}";

  static String m48(count) => "${count} selected";

  static String m49(count) => "${count} m";

  static String m50(count) => "${count} Mins";

  static String m51(count) => "${count} Minutes";

  static String m52(count) => "+${count} more";

  static String m53(minutes) => "Pause up to ${minutes} min";

  static String m54(date) => "Reminder Was Sent On ${date}";

  static String m55(location) => "Rules from ${location}";

  static String m56(role, decision) => "${role} · ${decision}";

  static String m57(start, end) => "${start} To ${end}";

  static String m58(date) => "Uploaded Date: ${date}";

  static String m59(year) =>
      "Download the template, set each employee\'s Total Days for ${year}, then upload it. A blank Year means ${year}; other years are skipped. Nothing is deleted.";

  static String m60(count) => "Waiting ${count}";

  static String m61(year, days) =>
      "${year} has only ${days} vacation days left.";

  static String m62(count) =>
      "${count} demo to-dos added. Reminders will arrive in about three minutes.";

  static String m63(count) => "${count} demo to-dos removed.";

  static String m64(count) => "${count} reminders sent.";

  static String m65(count, unit) => "Every ${count} ${unit}";

  static String m66(value) => "Frequency: ${value}";

  static String m67(date, time) => "Scheduled: ${date} At ${time}";

  static String m68(module, limit, assigned) =>
      "${module} allows ${limit} users. ${assigned} are already assigned.";

  static String m69(module) =>
      "The user limit for ${module} could not be read, so no access was granted.";

  static String m70(module, assigned, limit) =>
      "${module}: ${assigned} of ${limit} users";

  static String m71(remaining) => "Only ${remaining} more can be added.";

  static String m72(limit, assigned) =>
      "Your plan allows ${limit} users. ${assigned} are already assigned.";

  static String m73(assigned, limit) => "Users: ${assigned} of ${limit}";

  static String m74(role) =>
      "The role \"${role}\" could not be found, so its user limits cannot be checked.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "Approval": MessageLookupByLibrary.simpleMessage("Approval"),
    "Approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "ApproveRequest": MessageLookupByLibrary.simpleMessage("Approve Request"),
    "Approved": MessageLookupByLibrary.simpleMessage("Approved"),
    "AreYouSureDeleteThisService": MessageLookupByLibrary.simpleMessage(
      "Are You Sure Delete This Service",
    ),
    "AreYouSureYouWantToApproveThisRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to approve this request?",
        ),
    "AreYouSureYouWantToRejectThisRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to reject this request?",
        ),
    "AreYouSureYouWantToRequestThisService":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to request this service?",
        ),
    "AreYousureYouWanttoCancelThisRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to cancel this request?",
        ),
    "AreYousureYouWanttoDeleteThisMessage":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to delete this message?",
        ),
    "Areyousureyouwanttochangethisstatus": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to change this status",
    ),
    "BreachedSLA": MessageLookupByLibrary.simpleMessage("Breached SLA"),
    "CREATION_DATE": MessageLookupByLibrary.simpleMessage("CREATION_DATE"),
    "Cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "CancelRequest": MessageLookupByLibrary.simpleMessage("Cancel Request"),
    "Canceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "ComplianceLegal": MessageLookupByLibrary.simpleMessage(
      "Compliance & Legal",
    ),
    "CustomerSupport": MessageLookupByLibrary.simpleMessage("Customer Support"),
    "DataManagement": MessageLookupByLibrary.simpleMessage("Data Management"),
    "DateRequested": MessageLookupByLibrary.simpleMessage("Date Requested"),
    "Delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "DeleteMessage": MessageLookupByLibrary.simpleMessage("Delete Message"),
    "Department": MessageLookupByLibrary.simpleMessage("Department"),
    "Done": MessageLookupByLibrary.simpleMessage("Done"),
    "DoneServices": MessageLookupByLibrary.simpleMessage("Done Services"),
    "DurationofService": MessageLookupByLibrary.simpleMessage(
      "Duration of Service",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "EditMessage": MessageLookupByLibrary.simpleMessage("Edit Message"),
    "Editing": MessageLookupByLibrary.simpleMessage("Editing"),
    "EditingerviceName": MessageLookupByLibrary.simpleMessage(
      "Editing Service Name",
    ),
    "Edityourmessage": MessageLookupByLibrary.simpleMessage(
      "Edit your message",
    ),
    "EmployeeInformation": MessageLookupByLibrary.simpleMessage(
      "Employee Information",
    ),
    "Employees": MessageLookupByLibrary.simpleMessage("Employees"),
    "EnterPercentage": MessageLookupByLibrary.simpleMessage("Percentage"),
    "Executive": MessageLookupByLibrary.simpleMessage("Executive"),
    "Expand": MessageLookupByLibrary.simpleMessage("Expand"),
    "Filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "Finance": MessageLookupByLibrary.simpleMessage("Finance"),
    "First": MessageLookupByLibrary.simpleMessage("First"),
    "Fourth": MessageLookupByLibrary.simpleMessage("Fourth"),
    "Hide": MessageLookupByLibrary.simpleMessage("Hide"),
    "HumanResources": MessageLookupByLibrary.simpleMessage("Human Resources"),
    "InformationTechnology": MessageLookupByLibrary.simpleMessage(
      "Information Technology",
    ),
    "Inprogress": MessageLookupByLibrary.simpleMessage("In progress"),
    "InquiriesAndComments": MessageLookupByLibrary.simpleMessage(
      "Inquiries and Comments",
    ),
    "JobTitle": MessageLookupByLibrary.simpleMessage("Job Title"),
    "Justifications": MessageLookupByLibrary.simpleMessage("Justifications"),
    "Lastupdate": MessageLookupByLibrary.simpleMessage("Last update"),
    "ManagerIfItRequiresApproval": MessageLookupByLibrary.simpleMessage(
      " If It Requires Approval",
    ),
    "Marketing": MessageLookupByLibrary.simpleMessage("Marketing"),
    "Modules": MessageLookupByLibrary.simpleMessage("Permissions"),
    "NO": MessageLookupByLibrary.simpleMessage("NO"),
    "NeedsApproval": MessageLookupByLibrary.simpleMessage("Needs Approval"),
    "NoOfService": MessageLookupByLibrary.simpleMessage("No. of Service"),
    "Noproviderdatafound": MessageLookupByLibrary.simpleMessage(
      "No provider data found.",
    ),
    "OWNER": MessageLookupByLibrary.simpleMessage("OWNER"),
    "OfferedDate": MessageLookupByLibrary.simpleMessage("Offered Date"),
    "Onlynumbersareallowed": MessageLookupByLibrary.simpleMessage(
      "Only numbers are allowed.",
    ),
    "Operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "OwningDepartment": MessageLookupByLibrary.simpleMessage(
      "Owning Department",
    ),
    "Pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "Pleaseselectatleastoneemployee": MessageLookupByLibrary.simpleMessage(
      "Please select at least one employee.",
    ),
    "PointofContact": MessageLookupByLibrary.simpleMessage("Point of Contact"),
    "ReasonOfApprove": MessageLookupByLibrary.simpleMessage(
      "Reason of Approval",
    ),
    "ReasonOfCancelation": MessageLookupByLibrary.simpleMessage(
      "Reason of Cancellation",
    ),
    "ReasonOfRejection": MessageLookupByLibrary.simpleMessage(
      "Reason of Rejection",
    ),
    "Reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "RejectRequest": MessageLookupByLibrary.simpleMessage("Reject Request"),
    "Rejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "Reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
    "Request": MessageLookupByLibrary.simpleMessage("Request"),
    "RequestDate": MessageLookupByLibrary.simpleMessage("Request Date"),
    "RequestService": MessageLookupByLibrary.simpleMessage("Request Service"),
    "RequestedDate": MessageLookupByLibrary.simpleMessage("Requested Date"),
    "RequestedServices": MessageLookupByLibrary.simpleMessage(
      "Requested Services",
    ),
    "RequestedServicesDetails": MessageLookupByLibrary.simpleMessage(
      "Requested Services Details",
    ),
    "Requestedby": MessageLookupByLibrary.simpleMessage("Requested by"),
    "RequesterDetails": MessageLookupByLibrary.simpleMessage(
      "Requester Details",
    ),
    "Requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "Reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "Sales": MessageLookupByLibrary.simpleMessage("Sales"),
    "Save": MessageLookupByLibrary.simpleMessage("Save"),
    "Second": MessageLookupByLibrary.simpleMessage("Second"),
    "SendNotifications": MessageLookupByLibrary.simpleMessage(
      "Send Notifications",
    ),
    "SendReminder": MessageLookupByLibrary.simpleMessage("Send Reminder"),
    "ServiceADMIN": MessageLookupByLibrary.simpleMessage("Admin Services"),
    "ServiceDepartmentManager": MessageLookupByLibrary.simpleMessage(
      "Service Department Manager",
    ),
    "ServiceDescription": MessageLookupByLibrary.simpleMessage(
      "Service Description",
    ),
    "ServiceEmployee": MessageLookupByLibrary.simpleMessage(
      "Employee Services",
    ),
    "ServiceFulfillment": MessageLookupByLibrary.simpleMessage(
      "Service Fulfillment",
    ),
    "ServiceName": MessageLookupByLibrary.simpleMessage("Service Name"),
    "ServiceNameDetails": MessageLookupByLibrary.simpleMessage(
      "Service Name Details",
    ),
    "ServiceProvider": MessageLookupByLibrary.simpleMessage("Service Provider"),
    "ServiceProviderDetails": MessageLookupByLibrary.simpleMessage(
      "Service Provider Details",
    ),
    "ServiceRequested": MessageLookupByLibrary.simpleMessage(
      "Service Requested",
    ),
    "ServiceRequestor": MessageLookupByLibrary.simpleMessage(
      "Service Requestor",
    ),
    "ServiceRequests": MessageLookupByLibrary.simpleMessage("Service Requests"),
    "ServicesDone": MessageLookupByLibrary.simpleMessage("Services Done"),
    "Software": MessageLookupByLibrary.simpleMessage("Software"),
    "Sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "Statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
    "Status": MessageLookupByLibrary.simpleMessage("Status"),
    "StatusOfServices": MessageLookupByLibrary.simpleMessage(
      "Status Of Services",
    ),
    "Successful": MessageLookupByLibrary.simpleMessage("Successful"),
    "Texthere": MessageLookupByLibrary.simpleMessage("Text Here"),
    "TheNameOfRequest": MessageLookupByLibrary.simpleMessage(
      "The Name of Request",
    ),
    "Third": MessageLookupByLibrary.simpleMessage("Third"),
    "TotalHours": MessageLookupByLibrary.simpleMessage("Total Hours"),
    "TurnOffAllNotificationSwitches": MessageLookupByLibrary.simpleMessage(
      "You must turn off all notification switches before unchecking this option.",
    ),
    "WhenServiceIsRequestedAndApproved": MessageLookupByLibrary.simpleMessage(
      "When Service Is Requested And Approved By The Requester’s Manager \nIf It Requires Approval",
    ),
    "WhenServiceIsRequestedAndApprovedByTheRequester":
        MessageLookupByLibrary.simpleMessage(
          "When Service Is Requested And Approved By \nThe Requester’s Manager If It Requires Approval",
        ),
    "WhenServiceRequestedAndApproved": MessageLookupByLibrary.simpleMessage(
      "When Service Requested And Approved by Manager",
    ),
    "WhenTheirManagerApprovesTheService": MessageLookupByLibrary.simpleMessage(
      "When Manager Approves The Service,If It Requires Approvals",
    ),
    "WriteaComment": MessageLookupByLibrary.simpleMessage("Write a Comment"),
    "YouSuccessfullyApprovedThisRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully approved this request",
    ),
    "YouSuccessfullyCanceledThisRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully canceled this request",
    ),
    "YouSuccessfullyCompletedThisRequest": MessageLookupByLibrary.simpleMessage(
      "You Successfully Completed This Request",
    ),
    "YouSuccessfullyCreatedThisService": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Service",
    ),
    "YouSuccessfullyEditedThisService": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Service",
    ),
    "YouSuccessfullyRejectedThisRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully rejected this request",
    ),
    "YouSuccessfullyRequestedThisService": MessageLookupByLibrary.simpleMessage(
      "You successfully requested this service",
    ),
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutThisApp": MessageLookupByLibrary.simpleMessage("About This App"),
    "aboutThisPlatform": MessageLookupByLibrary.simpleMessage(
      "About this platform",
    ),
    "aboveBaselineColor": MessageLookupByLibrary.simpleMessage(
      "Above Baseline Color",
    ),
    "absence": MessageLookupByLibrary.simpleMessage("Absence"),
    "absent": MessageLookupByLibrary.simpleMessage("Absent"),
    "academicHistory": MessageLookupByLibrary.simpleMessage("Academic History"),
    "accepted": MessageLookupByLibrary.simpleMessage("Accepted"),
    "access": MessageLookupByLibrary.simpleMessage("Access"),
    "accessBegins": MessageLookupByLibrary.simpleMessage("Access Begins"),
    "accessBlocked": MessageLookupByLibrary.simpleMessage("Access Blocked"),
    "accessDenied": MessageLookupByLibrary.simpleMessage("Access Denied"),
    "accessDeniedWrongly": MessageLookupByLibrary.simpleMessage(
      "Access Denied Wrongly",
    ),
    "accessDetails": MessageLookupByLibrary.simpleMessage("Access Details"),
    "accessEnds": MessageLookupByLibrary.simpleMessage("Access Ends"),
    "accessLevel": MessageLookupByLibrary.simpleMessage("Access Level"),
    "accessLevelRequired": MessageLookupByLibrary.simpleMessage(
      "Access Level is required",
    ),
    "accessManagement": MessageLookupByLibrary.simpleMessage(
      "Access Management",
    ),
    "accessUpdated": MessageLookupByLibrary.simpleMessage("Access Updated"),
    "access_granted": MessageLookupByLibrary.simpleMessage("Access Granted"),
    "access_grantor": MessageLookupByLibrary.simpleMessage("Access Grantor"),
    "access_removed": MessageLookupByLibrary.simpleMessage("Access Removed"),
    "access_removed_success": MessageLookupByLibrary.simpleMessage(
      "User access has been successfully removed. Status changed to inactive and role cleared.",
    ),
    "access_revoked": MessageLookupByLibrary.simpleMessage("Access Revoked"),
    "accessoriesReturned": MessageLookupByLibrary.simpleMessage(
      "Accessories Returned",
    ),
    "accountLocked": MessageLookupByLibrary.simpleMessage("Account Locked"),
    "accountLockedMessage": MessageLookupByLibrary.simpleMessage(
      "Your account has been locked due to multiple unsuccessful login attempts. Please contact the administrator.",
    ),
    "accreditedInstitute": MessageLookupByLibrary.simpleMessage(
      "Accredited Institute",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionFailed": MessageLookupByLibrary.simpleMessage("Action Failed"),
    "actionTaken": MessageLookupByLibrary.simpleMessage("Action Taken"),
    "activate": MessageLookupByLibrary.simpleMessage("Activate"),
    "activatePolicies": MessageLookupByLibrary.simpleMessage(
      "Activate Policies",
    ),
    "activated": MessageLookupByLibrary.simpleMessage("Activated"),
    "activatingRequests": MessageLookupByLibrary.simpleMessage(
      "Activating Requests",
    ),
    "activatingRoles": MessageLookupByLibrary.simpleMessage("Activating Roles"),
    "activatingService": MessageLookupByLibrary.simpleMessage(
      "Activating Service",
    ),
    "activatingUserAccount": MessageLookupByLibrary.simpleMessage(
      "Activating User Account",
    ),
    "activationDate": MessageLookupByLibrary.simpleMessage("Activation Date"),
    "active": MessageLookupByLibrary.simpleMessage("Active"),
    "activeDirectory": MessageLookupByLibrary.simpleMessage("Active Directory"),
    "activeDirectoryModule": MessageLookupByLibrary.simpleMessage(
      "Active Directory Module",
    ),
    "activeForNow": MessageLookupByLibrary.simpleMessage("Active For Now"),
    "activeRoles": MessageLookupByLibrary.simpleMessage("Active Roles"),
    "active_permissions": MessageLookupByLibrary.simpleMessage(
      "Active Permissions",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addAccess": MessageLookupByLibrary.simpleMessage("Add Access"),
    "addApprovals": MessageLookupByLibrary.simpleMessage("Add Approvals"),
    "addAsset": MessageLookupByLibrary.simpleMessage("Add Asset"),
    "addAtLeastOneRow": MessageLookupByLibrary.simpleMessage(
      "Add at least one row",
    ),
    "addBaseline": MessageLookupByLibrary.simpleMessage("Add Baseline"),
    "addCaption": MessageLookupByLibrary.simpleMessage("Add Caption"),
    "addChampion": MessageLookupByLibrary.simpleMessage("Add Champion"),
    "addControl": MessageLookupByLibrary.simpleMessage("Add Control"),
    "addControlChampion": MessageLookupByLibrary.simpleMessage(
      "Add Control Champion",
    ),
    "addControlOwner": MessageLookupByLibrary.simpleMessage(
      "Add Control Owner",
    ),
    "addController": MessageLookupByLibrary.simpleMessage("Add Controller"),
    "addDepartmentsOrSwitchOffLimitAvailability":
        MessageLookupByLibrary.simpleMessage(
          "Add departments or switch off limit department availability",
        ),
    "addEmployee": MessageLookupByLibrary.simpleMessage("Add Employee"),
    "addLocation": MessageLookupByLibrary.simpleMessage("Add Location"),
    "addMember": MessageLookupByLibrary.simpleMessage("Add Member"),
    "addNewControlChampion": MessageLookupByLibrary.simpleMessage(
      "Add New Control Champion",
    ),
    "addNewEmployees": MessageLookupByLibrary.simpleMessage(
      "Add New Employees",
    ),
    "addNewItem": MessageLookupByLibrary.simpleMessage("Add new item"),
    "addNewStorage": MessageLookupByLibrary.simpleMessage("Add New Storage"),
    "addOption": MessageLookupByLibrary.simpleMessage("Add option"),
    "addOrder": MessageLookupByLibrary.simpleMessage("Adding Order"),
    "addOwner": MessageLookupByLibrary.simpleMessage("Add Owner"),
    "addPhoto": MessageLookupByLibrary.simpleMessage("Add Photo"),
    "addPolicy": MessageLookupByLibrary.simpleMessage("Add Policy"),
    "addPolicyControls": MessageLookupByLibrary.simpleMessage(
      "Add Policy Controls",
    ),
    "addProduct": MessageLookupByLibrary.simpleMessage("Add Product"),
    "addService": MessageLookupByLibrary.simpleMessage("Add Service"),
    "addShift": MessageLookupByLibrary.simpleMessage("Add Shift"),
    "addStartDateOrSwitchOffSchedulePublishing":
        MessageLookupByLibrary.simpleMessage(
          "Add start date or switch off Schedule Publishing",
        ),
    "addStorage": MessageLookupByLibrary.simpleMessage("+ Storage"),
    "addSupplier": MessageLookupByLibrary.simpleMessage("Add Supplier"),
    "add_New_Item": MessageLookupByLibrary.simpleMessage("Add New Item"),
    "add_department": MessageLookupByLibrary.simpleMessage("Add Department"),
    "addedBy": MessageLookupByLibrary.simpleMessage("Added By"),
    "addedOn": MessageLookupByLibrary.simpleMessage("Added On"),
    "addingAsset": MessageLookupByLibrary.simpleMessage("Adding Asset"),
    "addingAttachment": MessageLookupByLibrary.simpleMessage(
      "Adding Attachment",
    ),
    "addingNewAccess": MessageLookupByLibrary.simpleMessage(
      "Adding New Access",
    ),
    "addingNewControlChampion": MessageLookupByLibrary.simpleMessage(
      "Adding New Control Champion",
    ),
    "addingNewControlOwner": MessageLookupByLibrary.simpleMessage(
      "Adding New Control Owner",
    ),
    "addingNewEmployee": MessageLookupByLibrary.simpleMessage(
      "Adding New Employee",
    ),
    "addingNewLocation": MessageLookupByLibrary.simpleMessage(
      "Adding New Location",
    ),
    "addingNewOrder": MessageLookupByLibrary.simpleMessage("Adding New Order"),
    "addingNewProduct": MessageLookupByLibrary.simpleMessage(
      "Adding New Product",
    ),
    "addingNewRole": MessageLookupByLibrary.simpleMessage("Adding New Role"),
    "addingNewRolePermissions": MessageLookupByLibrary.simpleMessage(
      "Adding New Role Permissions",
    ),
    "addingNewStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Adding New Storage Location",
    ),
    "addingNewSupplier": MessageLookupByLibrary.simpleMessage(
      "Adding New Supplier",
    ),
    "addingOrderSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Order added successfully",
    ),
    "addingTransaction": MessageLookupByLibrary.simpleMessage(
      "Adding Transaction",
    ),
    "addingWidget": MessageLookupByLibrary.simpleMessage("Adding Widget"),
    "additionalInformation": MessageLookupByLibrary.simpleMessage(
      "Additional Information",
    ),
    "additionalNote": MessageLookupByLibrary.simpleMessage("Additional Note"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressDetails": MessageLookupByLibrary.simpleMessage("Address Details"),
    "addressNumberCity": MessageLookupByLibrary.simpleMessage(
      "Address {0}: City is required",
    ),
    "addressNumberCountry": MessageLookupByLibrary.simpleMessage(
      "Address {0}: Country is required",
    ),
    "addressNumberPostalCode": MessageLookupByLibrary.simpleMessage(
      "Address {0}: Postal Code is required",
    ),
    "addressNumberState": m0,
    "addressNumberStreetName": MessageLookupByLibrary.simpleMessage(
      "Address {0}: Street Name is required",
    ),
    "adminDashboard": MessageLookupByLibrary.simpleMessage("Admin Dashboard"),
    "adminOnly": MessageLookupByLibrary.simpleMessage("Admin Only"),
    "adminOnlyAccess": MessageLookupByLibrary.simpleMessage(
      "Admin-Only Access",
    ),
    "advancedDeposit": MessageLookupByLibrary.simpleMessage("Advanced Deposit"),
    "advancedPayment": MessageLookupByLibrary.simpleMessage("Advanced Payment"),
    "aed": MessageLookupByLibrary.simpleMessage("AED"),
    "afghan": MessageLookupByLibrary.simpleMessage("Afghan"),
    "age": MessageLookupByLibrary.simpleMessage("Age"),
    "aggregated": MessageLookupByLibrary.simpleMessage("Aggregated"),
    "ahmed": MessageLookupByLibrary.simpleMessage("Ahmed"),
    "ahmedWael": MessageLookupByLibrary.simpleMessage("Ahmed Wael"),
    "airflowInspection": MessageLookupByLibrary.simpleMessage(
      "Airflow Inspection",
    ),
    "albanian": MessageLookupByLibrary.simpleMessage("Albanian"),
    "algerian": MessageLookupByLibrary.simpleMessage("Algerian"),
    "ali": MessageLookupByLibrary.simpleMessage("Ali"),
    "alignmentCenter": MessageLookupByLibrary.simpleMessage("Center"),
    "alignmentExpand": MessageLookupByLibrary.simpleMessage("Expand"),
    "alignmentLeft": MessageLookupByLibrary.simpleMessage("Left"),
    "alignmentRight": MessageLookupByLibrary.simpleMessage("Right"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allDay": MessageLookupByLibrary.simpleMessage("All Day"),
    "allDepartmentsLong": MessageLookupByLibrary.simpleMessage(
      "All Departments",
    ),
    "allNotificationsCleared": MessageLookupByLibrary.simpleMessage(
      "All Notifications Cleared",
    ),
    "allNotificationsDeleted": MessageLookupByLibrary.simpleMessage(
      "All Notifications Deleted",
    ),
    "allRIGHTSRESERVED": MessageLookupByLibrary.simpleMessage(
      "ALL RIGHTS RESERVED",
    ),
    "all_departments": MessageLookupByLibrary.simpleMessage("All Departments"),
    "all_services": MessageLookupByLibrary.simpleMessage("All Services"),
    "allocated": MessageLookupByLibrary.simpleMessage("Allocated"),
    "allowBreaksInAttendance": MessageLookupByLibrary.simpleMessage(
      "Allow Breaks in Attendance",
    ),
    "allowDifferentWorkLocations": MessageLookupByLibrary.simpleMessage(
      "Allow Different Work Locations",
    ),
    "allowGeofence": MessageLookupByLibrary.simpleMessage("Allow Geofence"),
    "allowMultipleAnswers": MessageLookupByLibrary.simpleMessage(
      "Allow Multiple Answers",
    ),
    "allowPause": MessageLookupByLibrary.simpleMessage("Allow Pause"),
    "allowsRemovingDocumentsOwnedByAnyone":
        MessageLookupByLibrary.simpleMessage(
          "Allows Removing Documents Owned By Anyone",
        ),
    "alreadyExistsAndSelected": MessageLookupByLibrary.simpleMessage(
      "Already exists and selected",
    ),
    "alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery":
        MessageLookupByLibrary.simpleMessage(
          "Also delete media received in this chat from the device gallery",
        ),
    "am": MessageLookupByLibrary.simpleMessage("AM"),
    "ambientStorage": MessageLookupByLibrary.simpleMessage("Ambient Storage"),
    "american": MessageLookupByLibrary.simpleMessage("American"),
    "amroHandousa": MessageLookupByLibrary.simpleMessage("Amro Handousa"),
    "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred while processing your request.",
    ),
    "anErrorOccurredDuringLoginPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "An error occurred during login. Please try again.",
        ),
    "analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "and": MessageLookupByLibrary.simpleMessage("And"),
    "andorran": MessageLookupByLibrary.simpleMessage("Andorran"),
    "android": MessageLookupByLibrary.simpleMessage("Android"),
    "androidPhone": MessageLookupByLibrary.simpleMessage("Android Phone"),
    "androidTablet": MessageLookupByLibrary.simpleMessage("Android Tablet"),
    "angle": MessageLookupByLibrary.simpleMessage("Angle"),
    "angolan": MessageLookupByLibrary.simpleMessage("Angolan"),
    "animation": MessageLookupByLibrary.simpleMessage("Animation"),
    "annualVacation": MessageLookupByLibrary.simpleMessage("Annual Vacation"),
    "annually": MessageLookupByLibrary.simpleMessage("Annually"),
    "antiguans": MessageLookupByLibrary.simpleMessage("Antiguans"),
    "appTheme": MessageLookupByLibrary.simpleMessage("App Theme"),
    "appliedControls": MessageLookupByLibrary.simpleMessage("Applied Controls"),
    "appliedPolicies": MessageLookupByLibrary.simpleMessage("Applied Policies"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "applyChanges": MessageLookupByLibrary.simpleMessage("Apply Changes"),
    "approval": MessageLookupByLibrary.simpleMessage("Approval"),
    "approvalCycle": MessageLookupByLibrary.simpleMessage("Approval Cycle"),
    "approvalJustification": MessageLookupByLibrary.simpleMessage(
      "Approval Justification",
    ),
    "approvalPermissions": MessageLookupByLibrary.simpleMessage(
      "Approval Permissions",
    ),
    "approvalPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Approval Permissions Module",
    ),
    "approval_request_details": MessageLookupByLibrary.simpleMessage(
      "Approval Request Details",
    ),
    "approvals": MessageLookupByLibrary.simpleMessage("Approvals"),
    "approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "approveAndReject": MessageLookupByLibrary.simpleMessage(
      "Approve And Reject",
    ),
    "approveEvidence": MessageLookupByLibrary.simpleMessage("Approve Evidence"),
    "approveLeaveRequests": MessageLookupByLibrary.simpleMessage(
      "Approve Leave Requests",
    ),
    "approveRequest": MessageLookupByLibrary.simpleMessage("Approve Request"),
    "approved": MessageLookupByLibrary.simpleMessage("Approved"),
    "approvedAndRejected": MessageLookupByLibrary.simpleMessage(
      "Approved And Rejected",
    ),
    "approvedAndRejectedRequest": MessageLookupByLibrary.simpleMessage(
      "Approved And Rejected Request",
    ),
    "approvedEvidence": MessageLookupByLibrary.simpleMessage(
      "Approved Evidence",
    ),
    "approvedOnly": MessageLookupByLibrary.simpleMessage("Approved Only"),
    "apr": MessageLookupByLibrary.simpleMessage("Apr"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "arabicDepartmentNameMissing": MessageLookupByLibrary.simpleMessage(
      "Arabic Department Name Missing",
    ),
    "arabicFirstNameMissing": MessageLookupByLibrary.simpleMessage(
      "Arabic First Name Missing",
    ),
    "arabicJobTitleRequired": MessageLookupByLibrary.simpleMessage(
      "Arabic Job Title Required",
    ),
    "arabicJobTitleTranslationRequired": MessageLookupByLibrary.simpleMessage(
      "Arabic job title translation is required",
    ),
    "arabicLanguage": MessageLookupByLibrary.simpleMessage("Arabic"),
    "arabicLanguageMandatory": MessageLookupByLibrary.simpleMessage(
      "Arabic Language Mandatory",
    ),
    "arabicLastNameMissing": MessageLookupByLibrary.simpleMessage(
      "Arabic Last Name Missing",
    ),
    "arabicMiddleNameMissing": MessageLookupByLibrary.simpleMessage(
      "Arabic Middle Name Missing",
    ),
    "arabicName": MessageLookupByLibrary.simpleMessage("Arabic Name"),
    "arabicNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Arabic not allowed",
    ),
    "arabicOnly": MessageLookupByLibrary.simpleMessage("Arabic letters only"),
    "arabicRtlLayout": MessageLookupByLibrary.simpleMessage(
      "Arabic / RTL Layout",
    ),
    "arabicTextOnlyError": MessageLookupByLibrary.simpleMessage(
      "Please enter Arabic text only",
    ),
    "archive": MessageLookupByLibrary.simpleMessage("Archived"),
    "archiveDate": MessageLookupByLibrary.simpleMessage("Archive Date"),
    "archiveRoom": MessageLookupByLibrary.simpleMessage("Archive Room"),
    "archived": MessageLookupByLibrary.simpleMessage("Archived"),
    "areYouSureActivate": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Activate These Services?",
    ),
    "areYouSureActivateRequests": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to activate these requests?",
    ),
    "areYouSureAddSupplier": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Add This Supplier?",
    ),
    "areYouSureAddingOrder": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to add this order",
    ),
    "areYouSureApproveRequest": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Approve This Request?",
    ),
    "areYouSureCancelRequest": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want to Cancel This Request ?",
    ),
    "areYouSureChangeStatus": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Inactive The Request Type?",
    ),
    "areYouSureCompleteDraftRole": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to complete this draft role?",
    ),
    "areYouSureCreate": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Module?",
    ),
    "areYouSureCreateForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Form ?",
    ),
    "areYouSureCreateLocation": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Location ?",
    ),
    "areYouSureCreateRole": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create this role?",
    ),
    "areYouSureCreateService": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Service?",
    ),
    "areYouSureCreatingRequest": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Request ?",
    ),
    "areYouSureCreatingRequestType": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Request ?",
    ),
    "areYouSureCreatingTransaction": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Transaction ?",
    ),
    "areYouSureDelete": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This GRC Module?",
    ),
    "areYouSureDeleteAllCleared": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to permanently delete all cleared notifications? This cannot be undone.",
    ),
    "areYouSureDeleteControl": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Control?",
    ),
    "areYouSureDeleteForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Form?",
    ),
    "areYouSureDeleteGroup": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Group?",
    ),
    "areYouSureDeleteKnowledge": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this knowledge?",
    ),
    "areYouSureDeleteKnowledge_ar": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this knowledge item?",
    ),
    "areYouSureDeleteLocation": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Location ?",
    ),
    "areYouSureDeleteRequestType": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Request Type ?",
    ),
    "areYouSureDeleteRow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this row?",
    ),
    "areYouSureDisable": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Disable The Module?",
    ),
    "areYouSureDownloadPage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to download this page",
    ),
    "areYouSureDraftForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Put This Form In The Draft?",
    ),
    "areYouSureEdit": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Module?",
    ),
    "areYouSureEditForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Form ?",
    ),
    "areYouSureEditGroup": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Group ?",
    ),
    "areYouSureEditLocation": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Location ?",
    ),
    "areYouSureEditProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this product?",
    ),
    "areYouSureEditProduct_ar": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this product?",
    ),
    "areYouSureEditRequestType": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Request Type ?",
    ),
    "areYouSureEditRole": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this role?",
    ),
    "areYouSureEditService": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this service?",
    ),
    "areYouSureRestore": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Restore The Module?",
    ),
    "areYouSureRestoreForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Restore The Form?",
    ),
    "areYouSureSubmitForm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Submit This Form ?",
    ),
    "areYouSureToDeleteImage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the image?",
    ),
    "areYouSureToDisableService": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to disable the service?",
    ),
    "areYouSureToProceed": MessageLookupByLibrary.simpleMessage(
      "Are You Sure To Proceed",
    ),
    "areYouSureToRequestAsset": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to request this asset?",
    ),
    "areYouSureYouWantToActivateTheseAssignments":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to activate these assignments?",
        ),
    "areYouSureYouWantToActivateThesePolicies":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to activate these policies?",
        ),
    "areYouSureYouWantToActivateTheseServices":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Activate These Services?",
        ),
    "areYouSureYouWantToActivateThisAccount":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Activate This Account?",
        ),
    "areYouSureYouWantToActivateThisRole": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to activate this role?",
    ),
    "areYouSureYouWantToAddThisControlChampion":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to add this control champion?",
        ),
    "areYouSureYouWantToAddThisControlOwner":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to add this control owner?",
        ),
    "areYouSureYouWantToAddThisProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to add this product?",
    ),
    "areYouSureYouWantToApproveRequest": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to approve this request?",
    ),
    "areYouSureYouWantToApproveThisEvidence":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to approve this evidence?",
        ),
    "areYouSureYouWantToApproveThisRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to approve this request?",
        ),
    "areYouSureYouWantToChangeTheStatusOfThisModule":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to change the status of this module?",
        ),
    "areYouSureYouWantToCleanAll": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Clean All ?",
    ),
    "areYouSureYouWantToCreateThisControl":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to create this control?",
        ),
    "areYouSureYouWantToCreateThisModule": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create this module?",
    ),
    "areYouSureYouWantToCreateThisPolicy": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create this policy?",
    ),
    "areYouSureYouWantToCreateThisRequestType":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Create This Request Type?",
        ),
    "areYouSureYouWantToDeactivateThisAccount":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Deactivate This Account?",
        ),
    "areYouSureYouWantToDeactivateThisRole":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to deactivate this role?",
        ),
    "areYouSureYouWantToDeleteThisGrcModule":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to delete this GRC module?",
        ),
    "areYouSureYouWantToDeleteThisListToDo":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Delete This List To Do?",
        ),
    "areYouSureYouWantToDeleteThisRole": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this role?",
    ),
    "areYouSureYouWantToDeleteThisRow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this row?",
    ),
    "areYouSureYouWantToDiscardThisPolicy":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to discard this policy?",
        ),
    "areYouSureYouWantToEditControlsWeight":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to edit controls weight?",
        ),
    "areYouSureYouWantToEditPoliciesWeight":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to edit policies weight?",
        ),
    "areYouSureYouWantToEditThisControl": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this control?",
    ),
    "areYouSureYouWantToEditThisModule": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this module?",
    ),
    "areYouSureYouWantToEditThisPolicy": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this policy?",
    ),
    "areYouSureYouWantToProceedWithAssigningEqualWeightToAllControls":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to proceed with assigning equal weight to all controls?",
        ),
    "areYouSureYouWantToPublishThisPolicy":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to publish this policy?",
        ),
    "areYouSureYouWantToRejectRequest": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reject this request?",
    ),
    "areYouSureYouWantToRejectThisDocument":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to reject this document?",
        ),
    "areYouSureYouWantToRejectThisEvidence":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to reject this evidence?",
        ),
    "areYouSureYouWantToRejectThisRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to reject this request?",
        ),
    "areYouSureYouWantToRemoveDocument": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this document?",
    ),
    "areYouSureYouWantToRemoveThisAccess": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this access?",
    ),
    "areYouSureYouWantToRemoveThisControlChampion":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to remove this control champion?",
        ),
    "areYouSureYouWantToRemoveThisControlOwner":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to remove this control owner?",
        ),
    "areYouSureYouWantToRemoveThisEmployee":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Remove This Employee?",
        ),
    "areYouSureYouWantToResetTheCompanyBranding":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Reset The Company Branding?",
        ),
    "areYouSureYouWantToResetYourPersonalBrandingToCo":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Reset Your Personal Branding To Company Defaults?",
        ),
    "areYouSureYouWantToRestoreThisListToDo":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Restore This List To Do?",
        ),
    "areYouSureYouWantToRestoreThisModule":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to restore this module?",
        ),
    "areYouSureYouWantToResubmit": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to resubmit this document?",
    ),
    "areYouSureYouWantToSaveAsDraft": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save as draft?",
    ),
    "areYouSureYouWantToSaveTheseChanges": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save these changes?",
    ),
    "areYouSureYouWantToSaveThisControlAsADraft":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to save this control as a draft?",
        ),
    "areYouSureYouWantToSaveThisPolicyAsADraft":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to save this policy as a draft?",
        ),
    "areYouSureYouWantToSubmitThisEvidence":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to submit this evidence?",
        ),
    "areYouSureYouWantToSubmitThisReassignmentRequest":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you want to submit this reassignment request?",
        ),
    "areYouSureYouWouldLikeToProceedWithCreatingToDo":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you would like to proceed with creating this to-do?",
        ),
    "areYouSureYouWouldLikeToProceedWithEditingToDo":
        MessageLookupByLibrary.simpleMessage(
          "Are you sure you would like to proceed with editing this to-do?",
        ),
    "are_you_sure_submit": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Submit For Approval?",
    ),
    "are_you_sure_submit_request": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Submit This Request?",
    ),
    "area": MessageLookupByLibrary.simpleMessage("Area"),
    "areaRequired": MessageLookupByLibrary.simpleMessage("Area is required"),
    "argentinean": MessageLookupByLibrary.simpleMessage("Argentinean"),
    "armenian": MessageLookupByLibrary.simpleMessage("Armenian"),
    "arrangementHorizontal": MessageLookupByLibrary.simpleMessage("Horizontal"),
    "arrangementVertical": MessageLookupByLibrary.simpleMessage("Vertical"),
    "asc": MessageLookupByLibrary.simpleMessage("ASC"),
    "ascending": MessageLookupByLibrary.simpleMessage("Ascending"),
    "askAQuestion": MessageLookupByLibrary.simpleMessage("Ask a Question"),
    "asset": MessageLookupByLibrary.simpleMessage("Asset"),
    "assetConditions": MessageLookupByLibrary.simpleMessage("Asset Conditions"),
    "assetDetails": MessageLookupByLibrary.simpleMessage("Asset Details"),
    "assetId": MessageLookupByLibrary.simpleMessage("Asset Id"),
    "assetMissing": MessageLookupByLibrary.simpleMessage("Asset Missing"),
    "assetRepair": MessageLookupByLibrary.simpleMessage("Asset Repair"),
    "assetRequest": MessageLookupByLibrary.simpleMessage("Asset Request"),
    "assetRequested": MessageLookupByLibrary.simpleMessage("Asset Requested"),
    "assetReturn": MessageLookupByLibrary.simpleMessage("Asset Return"),
    "assetStolen": MessageLookupByLibrary.simpleMessage("Asset Stolen"),
    "assets": MessageLookupByLibrary.simpleMessage("Assets"),
    "assetsAssigned": MessageLookupByLibrary.simpleMessage("Assets Assigned"),
    "assetsName": MessageLookupByLibrary.simpleMessage("Assets Name"),
    "assetsNameDetails": MessageLookupByLibrary.simpleMessage(
      "Assets Name Details",
    ),
    "assetsUnderMaintenance": MessageLookupByLibrary.simpleMessage(
      "Assets Under Maintenance",
    ),
    "assign": MessageLookupByLibrary.simpleMessage("Assign"),
    "assignControl": MessageLookupByLibrary.simpleMessage("Assign Control"),
    "assignDate": MessageLookupByLibrary.simpleMessage("Assign Date"),
    "assignLead": MessageLookupByLibrary.simpleMessage("Assign Lead"),
    "assignShift": MessageLookupByLibrary.simpleMessage("Assign Shift"),
    "assigned": MessageLookupByLibrary.simpleMessage("Assigned"),
    "assignedBy": MessageLookupByLibrary.simpleMessage("Assigned By"),
    "assignedControls": MessageLookupByLibrary.simpleMessage(
      "Assigned Controls",
    ),
    "assignedDate": MessageLookupByLibrary.simpleMessage("Assigned Date"),
    "assignedDepartment": MessageLookupByLibrary.simpleMessage(
      "Assigned Department",
    ),
    "assignedDepartmentRequired": MessageLookupByLibrary.simpleMessage(
      "Assigned Department is required",
    ),
    "assignedEmployees": MessageLookupByLibrary.simpleMessage(
      "Assigned Employees",
    ),
    "assignedTo": MessageLookupByLibrary.simpleMessage("Assigned To"),
    "assigneesCreated": MessageLookupByLibrary.simpleMessage(
      "Assignees Created",
    ),
    "assigningAsset": MessageLookupByLibrary.simpleMessage("Assigning Asset"),
    "assigningAssets": MessageLookupByLibrary.simpleMessage("Assigning Assets"),
    "assigningControl": MessageLookupByLibrary.simpleMessage(
      "Assigning Control",
    ),
    "assigningControls": MessageLookupByLibrary.simpleMessage(
      "Assigning Controls",
    ),
    "assigningDetails": MessageLookupByLibrary.simpleMessage(
      "Assigning Details",
    ),
    "assigningHistory": MessageLookupByLibrary.simpleMessage(
      "Assigning History",
    ),
    "assigningProduct": MessageLookupByLibrary.simpleMessage(
      "Assigning Product",
    ),
    "assignmentControls": MessageLookupByLibrary.simpleMessage(
      "Assignment Controls",
    ),
    "assignmentDate": MessageLookupByLibrary.simpleMessage("Assignment Date"),
    "at": MessageLookupByLibrary.simpleMessage("At"),
    "atLeastOneEmployeeRequired": MessageLookupByLibrary.simpleMessage(
      "Please select at least one employee",
    ),
    "attach_document": MessageLookupByLibrary.simpleMessage("Attach Document"),
    "attachments": MessageLookupByLibrary.simpleMessage("Attachments"),
    "attendance": MessageLookupByLibrary.simpleMessage("Attendance"),
    "attendanceCompliance": MessageLookupByLibrary.simpleMessage(
      "Attendance Compliance",
    ),
    "attendanceDate": MessageLookupByLibrary.simpleMessage("Attendance Date"),
    "attention": MessageLookupByLibrary.simpleMessage("Attention"),
    "aud": MessageLookupByLibrary.simpleMessage("AUD"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "aug": MessageLookupByLibrary.simpleMessage("Aug"),
    "australian": MessageLookupByLibrary.simpleMessage("Australian"),
    "austrian": MessageLookupByLibrary.simpleMessage("Austrian"),
    "authenticationError": MessageLookupByLibrary.simpleMessage(
      "Authentication Error",
    ),
    "authenticationFailed": MessageLookupByLibrary.simpleMessage(
      "Authentication Failed",
    ),
    "authorizedPersonnelOnly": MessageLookupByLibrary.simpleMessage(
      "Authorized Personnel Only",
    ),
    "automaticIDs": MessageLookupByLibrary.simpleMessage("Automatic IDs"),
    "available": MessageLookupByLibrary.simpleMessage("Available"),
    "average": MessageLookupByLibrary.simpleMessage("Average"),
    "azerbaijani": MessageLookupByLibrary.simpleMessage("Azerbaijani"),
    "bachelor": MessageLookupByLibrary.simpleMessage("Bachelor\'s"),
    "bachelorDegree": MessageLookupByLibrary.simpleMessage(
      "Bachelor\'s Degree",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "bahamian": MessageLookupByLibrary.simpleMessage("Bahamian"),
    "bahraini": MessageLookupByLibrary.simpleMessage("Bahraini"),
    "bangladeshi": MessageLookupByLibrary.simpleMessage("Bangladeshi"),
    "bankAddress": MessageLookupByLibrary.simpleMessage("Bank Address"),
    "bankAddressRequired": MessageLookupByLibrary.simpleMessage(
      "Bank Address is required",
    ),
    "bankTransferDetails": MessageLookupByLibrary.simpleMessage(
      "Bank Transfer Details",
    ),
    "barChart": MessageLookupByLibrary.simpleMessage("Bar chart"),
    "barLabel": MessageLookupByLibrary.simpleMessage("Bar Label"),
    "barbadian": MessageLookupByLibrary.simpleMessage("Barbadian"),
    "barbudans": MessageLookupByLibrary.simpleMessage("Barbudans"),
    "baseLineChart": MessageLookupByLibrary.simpleMessage("Base Line Chart"),
    "baseline": MessageLookupByLibrary.simpleMessage("Baseline"),
    "baselineColor": MessageLookupByLibrary.simpleMessage("Baseline Color"),
    "basline": MessageLookupByLibrary.simpleMessage("Baseline"),
    "batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "batchCreated": MessageLookupByLibrary.simpleMessage("Batch created"),
    "batchCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Batch created successfully",
    ),
    "batchId": MessageLookupByLibrary.simpleMessage("Batch ID"),
    "batswana": MessageLookupByLibrary.simpleMessage("Batswana"),
    "beginner": MessageLookupByLibrary.simpleMessage("Beginner"),
    "beginsIn30m": MessageLookupByLibrary.simpleMessage("Begins in 30m"),
    "belarusian": MessageLookupByLibrary.simpleMessage("Belarusian"),
    "belgian": MessageLookupByLibrary.simpleMessage("Belgian"),
    "belizean": MessageLookupByLibrary.simpleMessage("Belizean"),
    "belowBaselineColor": MessageLookupByLibrary.simpleMessage(
      "Below Baseline Color",
    ),
    "beneficiaryBankName": MessageLookupByLibrary.simpleMessage(
      "Beneficiary Bank Name",
    ),
    "beneficiaryBankNameRequired": MessageLookupByLibrary.simpleMessage(
      "Beneficiary Bank Name is required",
    ),
    "beneficiaryName": MessageLookupByLibrary.simpleMessage("Beneficiary Name"),
    "beneficiaryNameRequired": MessageLookupByLibrary.simpleMessage(
      "Beneficiary Name is required",
    ),
    "bengaliLanguage": MessageLookupByLibrary.simpleMessage("Bengali"),
    "beninese": MessageLookupByLibrary.simpleMessage("Beninese"),
    "bhd": MessageLookupByLibrary.simpleMessage("BHD"),
    "bhutanese": MessageLookupByLibrary.simpleMessage("Bhutanese"),
    "biWeekly": MessageLookupByLibrary.simpleMessage("Bi weekly"),
    "bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "biometrics": MessageLookupByLibrary.simpleMessage("Biometrics"),
    "biometricsForLogin": MessageLookupByLibrary.simpleMessage(
      "Biometrics For Login",
    ),
    "birthVacation": MessageLookupByLibrary.simpleMessage("Birth Vacation"),
    "birthday": MessageLookupByLibrary.simpleMessage("Birthday"),
    "blue": MessageLookupByLibrary.simpleMessage("Blue"),
    "body": MessageLookupByLibrary.simpleMessage("Body"),
    "bolivian": MessageLookupByLibrary.simpleMessage("Bolivian"),
    "booklet": MessageLookupByLibrary.simpleMessage("Booklet"),
    "bosnian": MessageLookupByLibrary.simpleMessage("Bosnian"),
    "bothLanguages": MessageLookupByLibrary.simpleMessage("Both"),
    "branch": MessageLookupByLibrary.simpleMessage("Branch"),
    "branchName": MessageLookupByLibrary.simpleMessage("Branch Name"),
    "branchNameRequired": MessageLookupByLibrary.simpleMessage(
      "Branch Name is required",
    ),
    "branchOffice": MessageLookupByLibrary.simpleMessage("Branch Office"),
    "branches": MessageLookupByLibrary.simpleMessage("Branches"),
    "brand": MessageLookupByLibrary.simpleMessage("Brand"),
    "brandingAndTheme": MessageLookupByLibrary.simpleMessage(
      "Branding & Theme",
    ),
    "brandingPermission": MessageLookupByLibrary.simpleMessage("Branding"),
    "brazilian": MessageLookupByLibrary.simpleMessage("Brazilian"),
    "breakKey": MessageLookupByLibrary.simpleMessage("Break"),
    "breakPage": MessageLookupByLibrary.simpleMessage("Break Page"),
    "breakTime": MessageLookupByLibrary.simpleMessage("Break Time"),
    "british": MessageLookupByLibrary.simpleMessage("British"),
    "browseFiles": MessageLookupByLibrary.simpleMessage("Browse Files"),
    "bruneian": MessageLookupByLibrary.simpleMessage("Bruneian"),
    "buildingApartment": MessageLookupByLibrary.simpleMessage(
      "Building / Apartment",
    ),
    "bulgarian": MessageLookupByLibrary.simpleMessage("Bulgarian"),
    "bulkUpload": MessageLookupByLibrary.simpleMessage("Bulk Upload"),
    "bulkUploadEmployees": MessageLookupByLibrary.simpleMessage(
      "Bulk Upload Employees",
    ),
    "bulkUploadPreview": MessageLookupByLibrary.simpleMessage(
      "Bulk Upload Preview",
    ),
    "burkinabe": MessageLookupByLibrary.simpleMessage("Burkinabe"),
    "burmese": MessageLookupByLibrary.simpleMessage("Burmese"),
    "burundian": MessageLookupByLibrary.simpleMessage("Burundian"),
    "business": MessageLookupByLibrary.simpleMessage("Business"),
    "businessEmail": MessageLookupByLibrary.simpleMessage("Business Email"),
    "businessEmailAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "This business email is already registered",
    ),
    "businessMission": MessageLookupByLibrary.simpleMessage("Business Mission"),
    "businessRegistrationNumber": MessageLookupByLibrary.simpleMessage(
      "Business Registration Number",
    ),
    "businessRegistrationRequired": MessageLookupByLibrary.simpleMessage(
      "Business Registration Number is required",
    ),
    "businessTrip": MessageLookupByLibrary.simpleMessage("Business Trip"),
    "businessType": MessageLookupByLibrary.simpleMessage("Business Type"),
    "businessTypeRequired": MessageLookupByLibrary.simpleMessage(
      "Business Type is required",
    ),
    "buttonActionNotWorking": MessageLookupByLibrary.simpleMessage(
      "Button / Action Not Working",
    ),
    "byType": MessageLookupByLibrary.simpleMessage("By Type"),
    "cEO": MessageLookupByLibrary.simpleMessage("CEO"),
    "cabinet": MessageLookupByLibrary.simpleMessage("Cabinet"),
    "cad": MessageLookupByLibrary.simpleMessage("CAD"),
    "cairo": MessageLookupByLibrary.simpleMessage("Cairo"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
    "cambodian": MessageLookupByLibrary.simpleMessage("Cambodian"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cameroonian": MessageLookupByLibrary.simpleMessage("Cameroonian"),
    "canTConnectCheckInternet": MessageLookupByLibrary.simpleMessage(
      "Can\'t Connect .. Check Internet",
    ),
    "canadian": MessageLookupByLibrary.simpleMessage("Canadian"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelConfirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this request?",
    ),
    "cancelMeeting": MessageLookupByLibrary.simpleMessage("Cancel Meeting"),
    "cancelRequest": MessageLookupByLibrary.simpleMessage("Cancel Request"),
    "cancelService": MessageLookupByLibrary.simpleMessage("Cancel Service"),
    "cancelSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "You successfully canceled this request.",
    ),
    "canceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "canceledByHr": MessageLookupByLibrary.simpleMessage("Canceled By HR"),
    "cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "cannotBeNull": MessageLookupByLibrary.simpleMessage("Cannot be \"null\""),
    "cannotMessageYourself": MessageLookupByLibrary.simpleMessage(
      "You can\'t send a message to yourself",
    ),
    "cantEditFormBecauseSubmitted": MessageLookupByLibrary.simpleMessage(
      "You Can\'t Edit This Form Because It Has Been Submitted",
    ),
    "capacity": MessageLookupByLibrary.simpleMessage("Capacity"),
    "capeVerdean": MessageLookupByLibrary.simpleMessage("Cape Verdean"),
    "carPlate": MessageLookupByLibrary.simpleMessage("Car Plate"),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "categorySubcategory": MessageLookupByLibrary.simpleMessage(
      "Category / Subcategory",
    ),
    "centralAfrican": MessageLookupByLibrary.simpleMessage("Central African"),
    "certificate": MessageLookupByLibrary.simpleMessage("Certificate"),
    "certificateId": MessageLookupByLibrary.simpleMessage("Certificate ID"),
    "certificateRequest": MessageLookupByLibrary.simpleMessage(
      "Certificate Request",
    ),
    "certificatesPermission": MessageLookupByLibrary.simpleMessage(
      "Certificates",
    ),
    "certificationDetails": MessageLookupByLibrary.simpleMessage(
      "Certification Details",
    ),
    "chadian": MessageLookupByLibrary.simpleMessage("Chadian"),
    "changeDealStage": MessageLookupByLibrary.simpleMessage(
      "Change Deal Stage",
    ),
    "changeDefaultPassword": MessageLookupByLibrary.simpleMessage(
      "Change Default Password",
    ),
    "changeExpirationDate": MessageLookupByLibrary.simpleMessage(
      "Change Expiration Date",
    ),
    "changeNotificationChannel": MessageLookupByLibrary.simpleMessage(
      "Change Notification Channel",
    ),
    "changeNotificationStatus": MessageLookupByLibrary.simpleMessage(
      "Change Notification Status",
    ),
    "changeRoleStatus": MessageLookupByLibrary.simpleMessage(
      "Change Role Status",
    ),
    "changeServiceStatus": MessageLookupByLibrary.simpleMessage(
      "Change Service Status",
    ),
    "changedBy": MessageLookupByLibrary.simpleMessage("Changed By"),
    "changedStatus": MessageLookupByLibrary.simpleMessage("Changed Status"),
    "changingServiceProvider": MessageLookupByLibrary.simpleMessage(
      "Changing Service Provider",
    ),
    "changingStatus": MessageLookupByLibrary.simpleMessage("Changing Status"),
    "chartExamples": MessageLookupByLibrary.simpleMessage("Chart Examples"),
    "chartGraph": MessageLookupByLibrary.simpleMessage("Chart & Graph"),
    "chat": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatNotReady": MessageLookupByLibrary.simpleMessage(
      "Messaging is still loading. Please try again in a moment.",
    ),
    "chatUserNotFound": MessageLookupByLibrary.simpleMessage(
      "This user has no messaging profile",
    ),
    "checkAirCirculationInStorageArea": MessageLookupByLibrary.simpleMessage(
      "Check air circulation in storage area.",
    ),
    "checkAllLightingFixtures": MessageLookupByLibrary.simpleMessage(
      "Check all lighting fixtures.",
    ),
    "checkForCleanlinessAndHygieneStandards":
        MessageLookupByLibrary.simpleMessage(
          "Check for cleanliness and hygiene standards.",
        ),
    "checkIn": MessageLookupByLibrary.simpleMessage("Check In"),
    "checkInDate": MessageLookupByLibrary.simpleMessage("Check In Date"),
    "checkInOut": MessageLookupByLibrary.simpleMessage("Check In-Out"),
    "checkInTime": MessageLookupByLibrary.simpleMessage("Check In Time"),
    "checkOut": MessageLookupByLibrary.simpleMessage("Check Out"),
    "checkOutDate": MessageLookupByLibrary.simpleMessage("Check Out Date"),
    "checkOutTime": MessageLookupByLibrary.simpleMessage("Check Out Time"),
    "checkValidation": MessageLookupByLibrary.simpleMessage(
      "Please disable all notification switches before unchecking this section.",
    ),
    "chf": MessageLookupByLibrary.simpleMessage("CHF"),
    "child": MessageLookupByLibrary.simpleMessage("Child"),
    "chilean": MessageLookupByLibrary.simpleMessage("Chilean"),
    "chinese": MessageLookupByLibrary.simpleMessage("Chinese"),
    "chooseAccessManagement": MessageLookupByLibrary.simpleMessage(
      "Choose Access Management",
    ),
    "chooseBaseline": MessageLookupByLibrary.simpleMessage("Choose Baseline"),
    "chooseControl": MessageLookupByLibrary.simpleMessage("Choose Control"),
    "chooseDate": MessageLookupByLibrary.simpleMessage("Choose Date"),
    "chooseDegree": MessageLookupByLibrary.simpleMessage("Choose Degree"),
    "chooseDepartment": MessageLookupByLibrary.simpleMessage(
      "Choose Department",
    ),
    "chooseFieldOf": MessageLookupByLibrary.simpleMessage("Choose Field of"),
    "chooseHere": MessageLookupByLibrary.simpleMessage("Choose Here"),
    "chooseHere2": MessageLookupByLibrary.simpleMessage("Choose here"),
    "chooseModuleMode": MessageLookupByLibrary.simpleMessage(
      "Choose Module Mode",
    ),
    "chooseOrientation": MessageLookupByLibrary.simpleMessage(
      "Choose Orientation",
    ),
    "choosePolicy": MessageLookupByLibrary.simpleMessage("Choose Policy"),
    "chooseRequestType": MessageLookupByLibrary.simpleMessage(
      "Choose Request Type",
    ),
    "chooseStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Please choose a storage location for all added rows.",
    ),
    "chooseTheDate": MessageLookupByLibrary.simpleMessage("Choose the date"),
    "chooseTime": MessageLookupByLibrary.simpleMessage("Choose Time"),
    "chooseWhichBackupYouWantToRestore": MessageLookupByLibrary.simpleMessage(
      "Choose which backup you want to restore",
    ),
    "chooseWorkLocation": MessageLookupByLibrary.simpleMessage(
      "Choose work location",
    ),
    "choose_type": MessageLookupByLibrary.simpleMessage("Choose Type"),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "cityRequired": MessageLookupByLibrary.simpleMessage("City is required"),
    "cleanAll": MessageLookupByLibrary.simpleMessage("Clean All"),
    "cleaningNotifications": MessageLookupByLibrary.simpleMessage(
      "Cleaning Notifications",
    ),
    "cleanlinessAudit": MessageLookupByLibrary.simpleMessage(
      "Cleanliness Audit",
    ),
    "clearAll": MessageLookupByLibrary.simpleMessage("Clear All"),
    "clearFilter": MessageLookupByLibrary.simpleMessage("Clear Filter"),
    "clearOrganizationChart": MessageLookupByLibrary.simpleMessage(
      "Clear Organization Chart",
    ),
    "clearOrganizationChartBody": MessageLookupByLibrary.simpleMessage(
      "Visualize your company\'s structure effortlessly with our dynamic organization chart. Easily navigate through departments and roles to understand reporting lines and team relationships.",
    ),
    "cleared": MessageLookupByLibrary.simpleMessage("Cleared"),
    "click": MessageLookupByLibrary.simpleMessage("Click"),
    "clickAddDifferentApprovalCycle": MessageLookupByLibrary.simpleMessage(
      "If you wish to add approval cycles for the remaining request types, click \'Add Different Approval Cycle for Other Request Types\' and select the additional requests as needed.",
    ),
    "clickNextToContinue": MessageLookupByLibrary.simpleMessage(
      "Click Next to continue to Settings.",
    ),
    "clientSite": MessageLookupByLibrary.simpleMessage("Client Site"),
    "closureStatus": MessageLookupByLibrary.simpleMessage("Closure Status"),
    "cny": MessageLookupByLibrary.simpleMessage("CNY"),
    "coldChainLogistics": MessageLookupByLibrary.simpleMessage(
      "Cold Chain Logistics",
    ),
    "coldStorage": MessageLookupByLibrary.simpleMessage("Cold Storage"),
    "collapse": MessageLookupByLibrary.simpleMessage("Collapse"),
    "collapseTools": MessageLookupByLibrary.simpleMessage("Hide Toggle Panel"),
    "colombian": MessageLookupByLibrary.simpleMessage("Colombian"),
    "colorCoding": MessageLookupByLibrary.simpleMessage("Color Coding"),
    "colors": MessageLookupByLibrary.simpleMessage("Colors"),
    "coloursContrast": MessageLookupByLibrary.simpleMessage(
      "Colours & Contrast",
    ),
    "columnHeading": MessageLookupByLibrary.simpleMessage("Column"),
    "columnToExport": MessageLookupByLibrary.simpleMessage("Column To Export"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "commaAtStartOrEnd": MessageLookupByLibrary.simpleMessage(
      "Comma cannot be at start or end",
    ),
    "commaCannotBeAtStartOrEnd": MessageLookupByLibrary.simpleMessage(
      "Comma cannot be at start or end",
    ),
    "commentAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Comment and Feedback",
    ),
    "commentNotFound": MessageLookupByLibrary.simpleMessage(
      "No Comment uploaded yet",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "commentsAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Comments And Feedback",
    ),
    "commentsAndFeedbacks": MessageLookupByLibrary.simpleMessage(
      "Comments And Feedbacks",
    ),
    "comoran": MessageLookupByLibrary.simpleMessage("Comoran"),
    "company": MessageLookupByLibrary.simpleMessage("Company"),
    "companyIndustry": MessageLookupByLibrary.simpleMessage("Company Industry"),
    "companyInformation": MessageLookupByLibrary.simpleMessage(
      "Company Information",
    ),
    "companyName": MessageLookupByLibrary.simpleMessage("Company Name"),
    "companyServices": MessageLookupByLibrary.simpleMessage("Company Services"),
    "companySize": MessageLookupByLibrary.simpleMessage("Company Size"),
    "compensation": MessageLookupByLibrary.simpleMessage("Compensation"),
    "completeRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Please complete all required fields before continuing.",
    ),
    "completeRequiredFieldsBeforeSubmitting":
        MessageLookupByLibrary.simpleMessage(
          "Please complete all required fields before submitting.",
        ),
    "completeRequiredFieldsBeforeSubmitting_ar":
        MessageLookupByLibrary.simpleMessage(
          "Please complete all required fields before submitting",
        ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completingDraftRole": MessageLookupByLibrary.simpleMessage(
      "Completing Draft Role",
    ),
    "complianceAndLegal": MessageLookupByLibrary.simpleMessage(
      "Compliance & Legal",
    ),
    "complianceOfficer": MessageLookupByLibrary.simpleMessage(
      "Compliance Officer",
    ),
    "complianceScore": MessageLookupByLibrary.simpleMessage("Compliance Score"),
    "complianceTimeline": MessageLookupByLibrary.simpleMessage(
      "Compliance Timeline",
    ),
    "comprehensiveServiceManagement": MessageLookupByLibrary.simpleMessage(
      "Comprehensive Service Management",
    ),
    "comprehensiveServiceManagementBody": MessageLookupByLibrary.simpleMessage(
      "Manage inter-departmental service requests effortlessly with our all-in-one platform. Any department can request services from others, with the ability to approve, reject, and track the progress of these requests.",
    ),
    "computerTerminal": MessageLookupByLibrary.simpleMessage(
      "Computer Terminal / Inventory Access Point",
    ),
    "condition": MessageLookupByLibrary.simpleMessage("Condition"),
    "conditionOfStorage": MessageLookupByLibrary.simpleMessage(
      "Condition Of Storage",
    ),
    "conditionOfStorageRequired": MessageLookupByLibrary.simpleMessage(
      "Condition of Storage is required",
    ),
    "conductPerformanceReviews": MessageLookupByLibrary.simpleMessage(
      "Conduct Performance Reviews",
    ),
    "confidentialSecureAccess": MessageLookupByLibrary.simpleMessage(
      "Confidential / Secure Access",
    ),
    "configureCRMSettings": MessageLookupByLibrary.simpleMessage(
      "Configure CRM Settings",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmActivateRoles": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to activate these roles?",
    ),
    "confirmAddAsset": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Add This Asset ?",
    ),
    "confirmAddLocation": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Add This Location?",
    ),
    "confirmAddUsersAccess": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to add these users access?",
    ),
    "confirmAssignAsset": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to assign this asset?",
    ),
    "confirmAssignProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to assign this product to the selected employee?",
    ),
    "confirmAssignShift": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to assign this shift?",
    ),
    "confirmChangeServiceProvider": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Change Service Provider?",
    ),
    "confirmCreateLocation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create this location?",
    ),
    "confirmCreateNewBatch": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create a new batch?",
    ),
    "confirmCreateRequest": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to create this request?",
    ),
    "confirmDeleteSupplier": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this supplier?",
    ),
    "confirmDeletion": MessageLookupByLibrary.simpleMessage("Confirm Deletion"),
    "confirmEditEmployeeShift": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Employee\'s Shift?",
    ),
    "confirmEditEmployeesShift": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit These Employees\' Shifts?",
    ),
    "confirmEditSupplier": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to edit this supplier?",
    ),
    "confirmEmailAndPassword": MessageLookupByLibrary.simpleMessage(
      "Please ensure that all email and password fields are filled in correctly.",
    ),
    "confirmEqualWeight": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Proceed With Assigning Equal Weight To All Controls?",
    ),
    "confirmLogout": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmRestockProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restock this product?",
    ),
    "confirmRetrieveProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to retrieve this product?",
    ),
    "confirmSaveEmployeeChanges": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save these changes?",
    ),
    "confirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "congolese": MessageLookupByLibrary.simpleMessage("Congolese"),
    "consumable": MessageLookupByLibrary.simpleMessage("Consumable"),
    "consumableDetails": MessageLookupByLibrary.simpleMessage(
      "Consumable Details",
    ),
    "consumableExpired": MessageLookupByLibrary.simpleMessage(
      "Consumable Expired",
    ),
    "consumableMissing": MessageLookupByLibrary.simpleMessage(
      "Consumable Missing",
    ),
    "consumableReturn": MessageLookupByLibrary.simpleMessage(
      "Consumable Return",
    ),
    "consumableStolen": MessageLookupByLibrary.simpleMessage(
      "Consumable Stolen",
    ),
    "consumables": MessageLookupByLibrary.simpleMessage("Consumables"),
    "consumablesAssigned": MessageLookupByLibrary.simpleMessage(
      "Consumables Assigned",
    ),
    "contact": MessageLookupByLibrary.simpleMessage("Contact"),
    "contactDetails": MessageLookupByLibrary.simpleMessage("Contact Details"),
    "contactInfo": MessageLookupByLibrary.simpleMessage("Contact Info"),
    "contactInformation": MessageLookupByLibrary.simpleMessage(
      "Contact Information",
    ),
    "contactManager": MessageLookupByLibrary.simpleMessage("Contact Manager"),
    "contactNumberEmail": m1,
    "contactNumberFaxNumber": m2,
    "contactNumberFirstName": m3,
    "contactNumberLastName": m4,
    "contactNumberMiddleName": m5,
    "contactNumberPhoneNumber": m6,
    "contactNumberPreferredLanguage": m7,
    "contactNumberTitle": m8,
    "contactNumberValidEmail": m9,
    "continueText": MessageLookupByLibrary.simpleMessage("Continue"),
    "continueToNextProduct": MessageLookupByLibrary.simpleMessage(
      "Continue to Next Product",
    ),
    "contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "contractDateRange": MessageLookupByLibrary.simpleMessage(
      "Contract Date Range",
    ),
    "contractDetails": MessageLookupByLibrary.simpleMessage("Contract Details"),
    "contractDocument": MessageLookupByLibrary.simpleMessage(
      "Contract Document",
    ),
    "contractEndDate": MessageLookupByLibrary.simpleMessage(
      "Contract End Date",
    ),
    "contractEndDateRequired": MessageLookupByLibrary.simpleMessage(
      "Contract End Date is required",
    ),
    "contractStartDate": MessageLookupByLibrary.simpleMessage(
      "Contract Start Date",
    ),
    "contractStartDateRequired": MessageLookupByLibrary.simpleMessage(
      "Contract Start Date is required",
    ),
    "contractor": MessageLookupByLibrary.simpleMessage("Contractor"),
    "contributor": MessageLookupByLibrary.simpleMessage("Contributor"),
    "control": MessageLookupByLibrary.simpleMessage("Control"),
    "controlAverageWeight": MessageLookupByLibrary.simpleMessage(
      "Control Average Weight",
    ),
    "controlBulkUpload": MessageLookupByLibrary.simpleMessage(
      "Control Bulk Upload",
    ),
    "controlBulkUploadPreview": MessageLookupByLibrary.simpleMessage(
      "Control Bulk Upload Preview",
    ),
    "controlChampion": MessageLookupByLibrary.simpleMessage("Control Champion"),
    "controlChampionAdded": MessageLookupByLibrary.simpleMessage(
      "Control Champion Added",
    ),
    "controlChampionRemoved": MessageLookupByLibrary.simpleMessage(
      "Control Champion Removed",
    ),
    "controlChampionRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Control champion removed successfully",
    ),
    "controlChampions": MessageLookupByLibrary.simpleMessage(
      "Control Champions",
    ),
    "controlChanges": MessageLookupByLibrary.simpleMessage("Control Changes"),
    "controlCreated": MessageLookupByLibrary.simpleMessage("Control Created"),
    "controlDeleted": MessageLookupByLibrary.simpleMessage("Control Deleted"),
    "controlDescription": MessageLookupByLibrary.simpleMessage(
      "Control Description",
    ),
    "controlDescriptionMustBeWrittenInArabic":
        MessageLookupByLibrary.simpleMessage(
          "Control description must be written in Arabic",
        ),
    "controlDescriptionMustBeWrittenInEnglish":
        MessageLookupByLibrary.simpleMessage(
          "Control description must be written in English",
        ),
    "controlDetails": MessageLookupByLibrary.simpleMessage("Control Details"),
    "controlDocument": MessageLookupByLibrary.simpleMessage("Control Document"),
    "controlDocumentAr": MessageLookupByLibrary.simpleMessage(
      "Control Document (Arabic)",
    ),
    "controlDocumentEng": MessageLookupByLibrary.simpleMessage(
      "Control Document (English)",
    ),
    "controlName": MessageLookupByLibrary.simpleMessage("Control Name"),
    "controlNameArabic": MessageLookupByLibrary.simpleMessage(
      "Control Name (Arabic)",
    ),
    "controlNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Control Name cannot be empty",
    ),
    "controlNameMustBeWrittenInArabic": MessageLookupByLibrary.simpleMessage(
      "Control name must be written in Arabic",
    ),
    "controlNameMustBeWrittenInEnglish": MessageLookupByLibrary.simpleMessage(
      "Control name must be written in English",
    ),
    "controlNumber": MessageLookupByLibrary.simpleMessage("Control Number"),
    "controlNumberMustBeWrittenInArabic": MessageLookupByLibrary.simpleMessage(
      "Control number must be written in Arabic",
    ),
    "controlNumberMustBeWrittenInEnglish": MessageLookupByLibrary.simpleMessage(
      "Control number must be written in English",
    ),
    "controlOwner": MessageLookupByLibrary.simpleMessage("Control Owner"),
    "controlOwnerAdded": MessageLookupByLibrary.simpleMessage(
      "Control Owner Added",
    ),
    "controlOwnerRemoved": MessageLookupByLibrary.simpleMessage(
      "Control Owner Removed",
    ),
    "controlOwnerRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Control owner removed successfully",
    ),
    "controlOwners": MessageLookupByLibrary.simpleMessage("Control Owners"),
    "controlOwnersHistoryScreenNotImplemented":
        MessageLookupByLibrary.simpleMessage(
          "Control owners history screen not implemented yet",
        ),
    "controlSCreated": MessageLookupByLibrary.simpleMessage(
      "Control(s) Created",
    ),
    "controlSavedAsDraftSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Control saved as draft successfully",
    ),
    "controlStatus": MessageLookupByLibrary.simpleMessage("Control Status"),
    "controlUpdated": MessageLookupByLibrary.simpleMessage("Control Updated"),
    "controlWeight": MessageLookupByLibrary.simpleMessage("Control Weight"),
    "controlWeightCannotBeMoreThan100": MessageLookupByLibrary.simpleMessage(
      "Control weight cannot be more than 100",
    ),
    "controlWeightCurrent": MessageLookupByLibrary.simpleMessage(
      "Control Weight Current",
    ),
    "controlWeightIssue": MessageLookupByLibrary.simpleMessage(
      "Control Weight Issue",
    ),
    "controlWeightMustBeAPositiveNumber": MessageLookupByLibrary.simpleMessage(
      "Control weight must be a positive number",
    ),
    "controlWeightMustBeAValidNumber": MessageLookupByLibrary.simpleMessage(
      "Control weight must be a valid number",
    ),
    "controlWeightPrevious": MessageLookupByLibrary.simpleMessage(
      "Control Weight Previous",
    ),
    "controls": MessageLookupByLibrary.simpleMessage("Controls"),
    "controlsAndManagement": MessageLookupByLibrary.simpleMessage(
      "Controls and Management",
    ),
    "controlsUpdated": MessageLookupByLibrary.simpleMessage("Controls Updated"),
    "controlsUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Controls updated successfully",
    ),
    "convertLead": MessageLookupByLibrary.simpleMessage("Convert Lead"),
    "convertToPdf": MessageLookupByLibrary.simpleMessage("Convert to PDF"),
    "conveyorSystem": MessageLookupByLibrary.simpleMessage("Conveyor System"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyDone": MessageLookupByLibrary.simpleMessage("Copy Done"),
    "copyright": MessageLookupByLibrary.simpleMessage("Copyright"),
    "costaRican": MessageLookupByLibrary.simpleMessage("Costa Rican"),
    "couldNotOpenChat": MessageLookupByLibrary.simpleMessage(
      "Could not open the chat",
    ),
    "couldNotOpenFile": MessageLookupByLibrary.simpleMessage(
      "CouldNotOpenFile",
    ),
    "couldNotReadTheSelectedFilePleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Could not read the selected file. Please try again.",
        ),
    "countItemsAndVerifyStockLevels": MessageLookupByLibrary.simpleMessage(
      "Count items and verify stock levels.",
    ),
    "countries": MessageLookupByLibrary.simpleMessage("countries"),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "countryRequired": MessageLookupByLibrary.simpleMessage(
      "Country is required",
    ),
    "counts": MessageLookupByLibrary.simpleMessage("Counts"),
    "crashOrFreeze": MessageLookupByLibrary.simpleMessage("Crash or Freeze"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createANewGroupWith": MessageLookupByLibrary.simpleMessage(
      "Create a new group with",
    ),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
    "createArabicVersion": MessageLookupByLibrary.simpleMessage(
      "Create Arabic Version",
    ),
    "createAutomaticIDs": MessageLookupByLibrary.simpleMessage(
      "Create Automatic IDs",
    ),
    "createBarcode": MessageLookupByLibrary.simpleMessage("Create Barcode"),
    "createBoard": MessageLookupByLibrary.simpleMessage("Create Board"),
    "createContact": MessageLookupByLibrary.simpleMessage("Create Contact"),
    "createDeal": MessageLookupByLibrary.simpleMessage("Create Deal"),
    "createForm": MessageLookupByLibrary.simpleMessage("Create Form"),
    "createGrcModule": MessageLookupByLibrary.simpleMessage(
      "Create GRC Module",
    ),
    "createGroup": MessageLookupByLibrary.simpleMessage("Create Group"),
    "createGroupPermissions": MessageLookupByLibrary.simpleMessage(
      "Create Group Permissions",
    ),
    "createGroupPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Create Group Permissions Module",
    ),
    "createHub": MessageLookupByLibrary.simpleMessage("Create Hub"),
    "createKnowledgeHub": MessageLookupByLibrary.simpleMessage(
      "Create Knowledge Hub",
    ),
    "createLead": MessageLookupByLibrary.simpleMessage("Create Lead"),
    "createMeeting": MessageLookupByLibrary.simpleMessage("Create Meeting"),
    "createMeetingFromHomePage": MessageLookupByLibrary.simpleMessage(
      "Create Meeting from Home Page",
    ),
    "createModule": MessageLookupByLibrary.simpleMessage("Create Module"),
    "createNew": MessageLookupByLibrary.simpleMessage("Create New"),
    "createNewBatch": MessageLookupByLibrary.simpleMessage("Create new batch"),
    "createNewForm": MessageLookupByLibrary.simpleMessage("Create New Form"),
    "createNewGrcModule": MessageLookupByLibrary.simpleMessage(
      "Create New GRC Module",
    ),
    "createNewGroup": MessageLookupByLibrary.simpleMessage("Create New Group"),
    "createNewPolicy": MessageLookupByLibrary.simpleMessage(
      "Create New Policy",
    ),
    "createNewRequest": MessageLookupByLibrary.simpleMessage(
      "Create New Request",
    ),
    "createOrder": MessageLookupByLibrary.simpleMessage("Create Order"),
    "createPoll": MessageLookupByLibrary.simpleMessage("Create Poll"),
    "createRoleManagement": MessageLookupByLibrary.simpleMessage(
      "Create Role Management",
    ),
    "createService": MessageLookupByLibrary.simpleMessage("Create Service"),
    "createSuccess": MessageLookupByLibrary.simpleMessage("Creating Success"),
    "createTask": MessageLookupByLibrary.simpleMessage("Create Task"),
    "createTaskFromHomePage": MessageLookupByLibrary.simpleMessage(
      "Create Task from Home Page",
    ),
    "createTitle": MessageLookupByLibrary.simpleMessage("Create"),
    "createToDo": MessageLookupByLibrary.simpleMessage("Create To Do"),
    "createWithoutNeedApproval": MessageLookupByLibrary.simpleMessage(
      "Create Without Need Approval",
    ),
    "create_new_knowledge": MessageLookupByLibrary.simpleMessage(
      "Create New Knowledge",
    ),
    "created": MessageLookupByLibrary.simpleMessage("Created"),
    "createdAt": MessageLookupByLibrary.simpleMessage("Created At"),
    "createdBy": MessageLookupByLibrary.simpleMessage("Created By"),
    "createdDate": MessageLookupByLibrary.simpleMessage("Created Date"),
    "createdDateRange": MessageLookupByLibrary.simpleMessage(
      "Created Date Range",
    ),
    "createdDateRange_ar": MessageLookupByLibrary.simpleMessage(
      "Created Date Range",
    ),
    "createdModules": MessageLookupByLibrary.simpleMessage("Created Modules"),
    "created_at": MessageLookupByLibrary.simpleMessage("Created At"),
    "created_by": MessageLookupByLibrary.simpleMessage("Created By"),
    "creatingForm": MessageLookupByLibrary.simpleMessage("Creating Form"),
    "creatingModules": MessageLookupByLibrary.simpleMessage("Creating Modules"),
    "creatingNewLocation": MessageLookupByLibrary.simpleMessage(
      "Creating New Location",
    ),
    "creatingNewRequestType": MessageLookupByLibrary.simpleMessage(
      "Creating New Request Type",
    ),
    "creatingNewService": MessageLookupByLibrary.simpleMessage(
      "Creating New Service",
    ),
    "creatingPolicy": MessageLookupByLibrary.simpleMessage("Creating policy"),
    "creatingRequest": MessageLookupByLibrary.simpleMessage("Creating Request"),
    "creatingRequestType": MessageLookupByLibrary.simpleMessage(
      "Creating Request Type",
    ),
    "creatingRole": MessageLookupByLibrary.simpleMessage("Creating Role"),
    "creatingService": MessageLookupByLibrary.simpleMessage("Creating Service"),
    "creatingToDoList": MessageLookupByLibrary.simpleMessage(
      "Creating To Do List",
    ),
    "creatingToDoTitle": MessageLookupByLibrary.simpleMessage("Creating To Do"),
    "creatingToDodialoge": MessageLookupByLibrary.simpleMessage(
      "Creating To Do",
    ),
    "creatingTransaction": MessageLookupByLibrary.simpleMessage(
      "Creating Transaction",
    ),
    "creating_knowledge_hub": MessageLookupByLibrary.simpleMessage(
      "Creating Knowledge Hub",
    ),
    "creationDate": MessageLookupByLibrary.simpleMessage("Creation Date"),
    "critical": MessageLookupByLibrary.simpleMessage("Critical"),
    "crm": MessageLookupByLibrary.simpleMessage("CRM"),
    "crmActivate": MessageLookupByLibrary.simpleMessage("Activate"),
    "crmActive": MessageLookupByLibrary.simpleMessage("Active"),
    "crmAdd": MessageLookupByLibrary.simpleMessage("Add"),
    "crmAddAddress": MessageLookupByLibrary.simpleMessage("Add Address"),
    "crmAddCategory": MessageLookupByLibrary.simpleMessage("Add Category"),
    "crmAddDiscount": MessageLookupByLibrary.simpleMessage("Add Discount"),
    "crmAddField": MessageLookupByLibrary.simpleMessage("Add Field"),
    "crmAddMoreLink": MessageLookupByLibrary.simpleMessage("Add More Link"),
    "crmAddNewClient": MessageLookupByLibrary.simpleMessage("Add New Client"),
    "crmAddRelationship": MessageLookupByLibrary.simpleMessage(
      "Add Relationship",
    ),
    "crmAddRow": MessageLookupByLibrary.simpleMessage("Row"),
    "crmAddStage": MessageLookupByLibrary.simpleMessage("Add Stage"),
    "crmAddTag": MessageLookupByLibrary.simpleMessage("Add Tag"),
    "crmAddTerm": MessageLookupByLibrary.simpleMessage("Add Term"),
    "crmAddType": MessageLookupByLibrary.simpleMessage("Add Type"),
    "crmAddView": MessageLookupByLibrary.simpleMessage("Add View"),
    "crmAddViewComingSoon": MessageLookupByLibrary.simpleMessage(
      "Add view will be available soon",
    ),
    "crmAddress": MessageLookupByLibrary.simpleMessage("Address"),
    "crmAddressComponents": MessageLookupByLibrary.simpleMessage(
      "Address Components",
    ),
    "crmAlert": MessageLookupByLibrary.simpleMessage("Alert"),
    "crmAll": MessageLookupByLibrary.simpleMessage("All"),
    "crmAllCity": MessageLookupByLibrary.simpleMessage("All City"),
    "crmAllCountry": MessageLookupByLibrary.simpleMessage("All Country"),
    "crmAllStatus": MessageLookupByLibrary.simpleMessage("All Status"),
    "crmAllTypes": MessageLookupByLibrary.simpleMessage("All Types"),
    "crmAllowMultipleEmails": MessageLookupByLibrary.simpleMessage(
      "Allow Multiple Emails",
    ),
    "crmAllowMultiplePhone": MessageLookupByLibrary.simpleMessage(
      "Allow Multiple Phone",
    ),
    "crmAllowSearch": MessageLookupByLibrary.simpleMessage("Allow Search"),
    "crmAllowSpaces": MessageLookupByLibrary.simpleMessage("Allow Spaces"),
    "crmAllowSpecialCharacters": MessageLookupByLibrary.simpleMessage(
      "Allow Special Characters",
    ),
    "crmApplyOnTeam": MessageLookupByLibrary.simpleMessage("Apply on Team"),
    "crmArabicLettersOnlyTitle": MessageLookupByLibrary.simpleMessage(
      "This field accepts Arabic letters only",
    ),
    "crmArchived": MessageLookupByLibrary.simpleMessage("Archived"),
    "crmAutoAddHttps": MessageLookupByLibrary.simpleMessage("Auto Add HTTPS"),
    "crmBoth": MessageLookupByLibrary.simpleMessage("Both"),
    "crmBulkUpload": MessageLookupByLibrary.simpleMessage("Bulk Upload"),
    "crmBusinessInitiationDate": MessageLookupByLibrary.simpleMessage(
      "Business Initiation Date",
    ),
    "crmBy": MessageLookupByLibrary.simpleMessage("By: "),
    "crmCategories": MessageLookupByLibrary.simpleMessage("Categories"),
    "crmCategoriesAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new category",
    ),
    "crmCategory": MessageLookupByLibrary.simpleMessage("Category"),
    "crmCategoryDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Category deleted successfully",
    ),
    "crmCategoryDetails": MessageLookupByLibrary.simpleMessage(
      "Category Details",
    ),
    "crmCategoryFields": MessageLookupByLibrary.simpleMessage("Fields"),
    "crmCategorySavedSuccess": MessageLookupByLibrary.simpleMessage(
      "Category saved successfully",
    ),
    "crmCategorySection": MessageLookupByLibrary.simpleMessage("Section"),
    "crmChoices": MessageLookupByLibrary.simpleMessage("Choices"),
    "crmChoose": MessageLookupByLibrary.simpleMessage("Choose"),
    "crmCities": MessageLookupByLibrary.simpleMessage("Cities"),
    "crmCity": MessageLookupByLibrary.simpleMessage("City"),
    "crmClientAddedSubtitle": MessageLookupByLibrary.simpleMessage(
      "The new client record has been saved successfully",
    ),
    "crmClientAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Client Added Successfully",
    ),
    "crmClientDetails": MessageLookupByLibrary.simpleMessage("Client Details"),
    "crmClientFirstName": MessageLookupByLibrary.simpleMessage(
      "Client First Name",
    ),
    "crmClientFirstNameAr": MessageLookupByLibrary.simpleMessage(
      "اسم العميل الأول",
    ),
    "crmClientLastName": MessageLookupByLibrary.simpleMessage(
      "Client Last Name",
    ),
    "crmClientLastNameAr": MessageLookupByLibrary.simpleMessage(
      "اسم العميل الأخير",
    ),
    "crmClientType": MessageLookupByLibrary.simpleMessage("Client Type"),
    "crmClients": MessageLookupByLibrary.simpleMessage("Clients"),
    "crmClientsCount": m10,
    "crmClientsStatus": MessageLookupByLibrary.simpleMessage("Clients Status"),
    "crmCode": MessageLookupByLibrary.simpleMessage("Code"),
    "crmColumn": MessageLookupByLibrary.simpleMessage("Column"),
    "crmCompanies": MessageLookupByLibrary.simpleMessage("Companies"),
    "crmCompany": MessageLookupByLibrary.simpleMessage("Company"),
    "crmCompanyName": MessageLookupByLibrary.simpleMessage("Company name"),
    "crmCompanyNameAr": MessageLookupByLibrary.simpleMessage("اسم الشركة"),
    "crmCompanySize": MessageLookupByLibrary.simpleMessage("Size"),
    "crmConstraints": MessageLookupByLibrary.simpleMessage("Constraints"),
    "crmContactChannel": MessageLookupByLibrary.simpleMessage(
      "Contact Channel",
    ),
    "crmContinents": MessageLookupByLibrary.simpleMessage("Continents"),
    "crmControlActivity": MessageLookupByLibrary.simpleMessage("Activity"),
    "crmControlActivityDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage activity types for your clients",
    ),
    "crmControlClientsTypes": MessageLookupByLibrary.simpleMessage(
      "Clients Types",
    ),
    "crmControlClientsTypesDesc": MessageLookupByLibrary.simpleMessage(
      "Manage Your client ans view details",
    ),
    "crmControlDeals": MessageLookupByLibrary.simpleMessage("Deals"),
    "crmControlDealsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage all permissions for your Employees",
    ),
    "crmControlDiscount": MessageLookupByLibrary.simpleMessage("Discount"),
    "crmControlDiscountDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage discount for your clients",
    ),
    "crmControlPermissions": MessageLookupByLibrary.simpleMessage(
      "Permissions",
    ),
    "crmControlPermissionsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage all permissions for your Employees",
    ),
    "crmControlRelationship": MessageLookupByLibrary.simpleMessage(
      "Relationship",
    ),
    "crmControlRelationshipDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage activity types for your clients",
    ),
    "crmControlTeams": MessageLookupByLibrary.simpleMessage("Teams"),
    "crmControlTeamsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage Your Employees",
    ),
    "crmControlTemplates": MessageLookupByLibrary.simpleMessage("Templates"),
    "crmControlTemplatesDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage forms for your clients",
    ),
    "crmControlTerms": MessageLookupByLibrary.simpleMessage("Terms"),
    "crmControlTermsDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage Terms",
    ),
    "crmControlTitle": MessageLookupByLibrary.simpleMessage("Control"),
    "crmCountries": MessageLookupByLibrary.simpleMessage("Countries"),
    "crmCountry": MessageLookupByLibrary.simpleMessage("Country"),
    "crmCountryCode": MessageLookupByLibrary.simpleMessage("Country Code"),
    "crmCrNumber": MessageLookupByLibrary.simpleMessage(
      "Commercial Registration No. (CR No.)",
    ),
    "crmCreationDate": m11,
    "crmCreationDateLabel": MessageLookupByLibrary.simpleMessage(
      "Creation Date",
    ),
    "crmDashboardTab": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "crmDate": MessageLookupByLibrary.simpleMessage("Date"),
    "crmDateRangeFrom": MessageLookupByLibrary.simpleMessage("Date Range From"),
    "crmDateRangeTo": MessageLookupByLibrary.simpleMessage("Date Range To"),
    "crmDealCategory": MessageLookupByLibrary.simpleMessage("Category"),
    "crmDealStage": MessageLookupByLibrary.simpleMessage("Stage"),
    "crmDeleteCategory": MessageLookupByLibrary.simpleMessage(
      "Delete Category",
    ),
    "crmDeleteCategoryConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this category?",
    ),
    "crmDeleteDiscountConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this discount rule?",
    ),
    "crmDeleteStage": MessageLookupByLibrary.simpleMessage("Delete Stage"),
    "crmDeleteStageConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this stage?",
    ),
    "crmDeleteTag": MessageLookupByLibrary.simpleMessage("Delete Tag"),
    "crmDeleteTagConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this tag?",
    ),
    "crmDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "crmDetails": MessageLookupByLibrary.simpleMessage("Details"),
    "crmDiscard": MessageLookupByLibrary.simpleMessage("Discard"),
    "crmDiscountDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Discount rule deleted successfully",
    ),
    "crmDiscountDetails": MessageLookupByLibrary.simpleMessage(
      "Discount Details",
    ),
    "crmDiscountSavedSuccess": MessageLookupByLibrary.simpleMessage(
      "Discount rule saved successfully",
    ),
    "crmDiscountUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Discount rule updated successfully",
    ),
    "crmDiscountValue": MessageLookupByLibrary.simpleMessage("Discount Value"),
    "crmDiscounts": MessageLookupByLibrary.simpleMessage("Discounts"),
    "crmDiscountsAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new discount rule",
    ),
    "crmDone": MessageLookupByLibrary.simpleMessage("Done"),
    "crmDuplicationFound": MessageLookupByLibrary.simpleMessage(
      "Client Duplication Found",
    ),
    "crmDuplicationSubtitle": MessageLookupByLibrary.simpleMessage(
      "Similar Client found in the system; please review before continuing.",
    ),
    "crmEdit": MessageLookupByLibrary.simpleMessage("Edit"),
    "crmEditCategory": MessageLookupByLibrary.simpleMessage("Edit Category"),
    "crmEditDiscount": MessageLookupByLibrary.simpleMessage("Edit Discount"),
    "crmEditRelationship": MessageLookupByLibrary.simpleMessage(
      "Edit Relationship",
    ),
    "crmEditRule": MessageLookupByLibrary.simpleMessage("Edit Rule"),
    "crmEditStage": MessageLookupByLibrary.simpleMessage("Edit Stage"),
    "crmEditTag": MessageLookupByLibrary.simpleMessage("Edit Tag"),
    "crmEditTerm": MessageLookupByLibrary.simpleMessage("Edit Term"),
    "crmEditType": MessageLookupByLibrary.simpleMessage("Edit Type Details"),
    "crmEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "crmEnglishLettersOnlySubtitle": MessageLookupByLibrary.simpleMessage(
      "This field accepts English letters only Please use English letters only (A-Z)",
    ),
    "crmEnglishLettersOnlyTitle": MessageLookupByLibrary.simpleMessage(
      "This field accepts English letters only",
    ),
    "crmEntityName": MessageLookupByLibrary.simpleMessage("Entity Name"),
    "crmEntityNameAr": MessageLookupByLibrary.simpleMessage("اسم الكيان"),
    "crmEntryType": MessageLookupByLibrary.simpleMessage("Entry Type"),
    "crmErrorCount": m12,
    "crmErrorMessage": MessageLookupByLibrary.simpleMessage("Error Message"),
    "crmExport": MessageLookupByLibrary.simpleMessage("Export"),
    "crmExportComingSoon": MessageLookupByLibrary.simpleMessage(
      "Export will be available soon",
    ),
    "crmField": MessageLookupByLibrary.simpleMessage("Field"),
    "crmFieldDetails": MessageLookupByLibrary.simpleMessage("Field Details"),
    "crmFieldName": MessageLookupByLibrary.simpleMessage("Field Name"),
    "crmFieldNameAr": MessageLookupByLibrary.simpleMessage("اسم الحقل"),
    "crmFieldRequired": MessageLookupByLibrary.simpleMessage("Field Required"),
    "crmFieldRequiredAr": MessageLookupByLibrary.simpleMessage("الحقل مطلوب"),
    "crmFieldType": MessageLookupByLibrary.simpleMessage("Field Type"),
    "crmFileTypes": MessageLookupByLibrary.simpleMessage("File Types"),
    "crmFilter": MessageLookupByLibrary.simpleMessage("Filter"),
    "crmFixedAmount": MessageLookupByLibrary.simpleMessage("Fixed Amount"),
    "crmFormat": MessageLookupByLibrary.simpleMessage("Format"),
    "crmFormatExample": MessageLookupByLibrary.simpleMessage("Format Example"),
    "crmFrom": MessageLookupByLibrary.simpleMessage("From"),
    "crmGovernment": MessageLookupByLibrary.simpleMessage("Government"),
    "crmGovernmentSector": MessageLookupByLibrary.simpleMessage(
      "Government Sector",
    ),
    "crmHide": MessageLookupByLibrary.simpleMessage("Hide"),
    "crmImageTypes": MessageLookupByLibrary.simpleMessage("Image Types"),
    "crmImport": MessageLookupByLibrary.simpleMessage("Import"),
    "crmInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "crmIndividuals": MessageLookupByLibrary.simpleMessage("Individuals"),
    "crmIndustry": MessageLookupByLibrary.simpleMessage("Industry"),
    "crmInvalidUrl": MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "crmItems": MessageLookupByLibrary.simpleMessage("Items"),
    "crmLastUpdate": MessageLookupByLibrary.simpleMessage("Last Update"),
    "crmMakeFieldRequired": MessageLookupByLibrary.simpleMessage(
      "Make This Field Required",
    ),
    "crmMasterTemplate": MessageLookupByLibrary.simpleMessage(
      "Master Template",
    ),
    "crmMaxCharacters": MessageLookupByLibrary.simpleMessage("Max Characters"),
    "crmMaxLength": MessageLookupByLibrary.simpleMessage("Max Length"),
    "crmMaxNumber": MessageLookupByLibrary.simpleMessage("Max Number"),
    "crmMaximumNumber": MessageLookupByLibrary.simpleMessage("Maximum Number"),
    "crmMaximumQuantity": MessageLookupByLibrary.simpleMessage(
      "Maximum Quantity",
    ),
    "crmMergeAddLevel": MessageLookupByLibrary.simpleMessage("Add Level"),
    "crmMergeChooseColor": MessageLookupByLibrary.simpleMessage("Choose"),
    "crmMergeColor": MessageLookupByLibrary.simpleMessage("Color"),
    "crmMergeDays": MessageLookupByLibrary.simpleMessage("Days"),
    "crmMergeDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this level?",
    ),
    "crmMergeDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Deleted successfully .",
    ),
    "crmMergeDuration": MessageLookupByLibrary.simpleMessage("Duration"),
    "crmMergeEditLevel": MessageLookupByLibrary.simpleMessage(
      "Edit Level Details",
    ),
    "crmMergeHours": MessageLookupByLibrary.simpleMessage("Hours"),
    "crmMergeLevelDetails": MessageLookupByLibrary.simpleMessage(
      "Level Details",
    ),
    "crmMergeMinutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "crmMergeMonths": MessageLookupByLibrary.simpleMessage("Months"),
    "crmMergeNoLevels": MessageLookupByLibrary.simpleMessage(
      "Press to add a likelihood level",
    ),
    "crmMergePossibleLevel": MessageLookupByLibrary.simpleMessage(
      "Possible Level",
    ),
    "crmMergeRangeFrom": MessageLookupByLibrary.simpleMessage("Range From"),
    "crmMergeRangeTo": MessageLookupByLibrary.simpleMessage("Range To"),
    "crmMergeSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "crmMergeSortRangeAsc": MessageLookupByLibrary.simpleMessage(
      "Range (Low - High)",
    ),
    "crmMergeSortRangeDesc": MessageLookupByLibrary.simpleMessage(
      "Range (High - Low)",
    ),
    "crmMergeUndoMode": MessageLookupByLibrary.simpleMessage("Undo Mode"),
    "crmMergeWeeks": MessageLookupByLibrary.simpleMessage("Weeks"),
    "crmMergeYears": MessageLookupByLibrary.simpleMessage("Years"),
    "crmMinimumQuantity": MessageLookupByLibrary.simpleMessage(
      "Minimum Quantity",
    ),
    "crmModule": MessageLookupByLibrary.simpleMessage("CRM Module"),
    "crmMultipleChoice": MessageLookupByLibrary.simpleMessage(
      "Multiple Choice",
    ),
    "crmMultipleChoose": MessageLookupByLibrary.simpleMessage(
      "Multiple Choose",
    ),
    "crmName": MessageLookupByLibrary.simpleMessage("Name"),
    "crmNameAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "This Name Exist Before",
    ),
    "crmNameArabic": MessageLookupByLibrary.simpleMessage("الاسم"),
    "crmNationalId": MessageLookupByLibrary.simpleMessage("National ID"),
    "crmNext": MessageLookupByLibrary.simpleMessage("Next"),
    "crmNextActivity": MessageLookupByLibrary.simpleMessage("Next Activity"),
    "crmNo": MessageLookupByLibrary.simpleMessage("NO"),
    "crmNoCategoriesAvailable": MessageLookupByLibrary.simpleMessage(
      "No Categories Available",
    ),
    "crmNoDiscountsAvailable": MessageLookupByLibrary.simpleMessage(
      "No Discounts Available",
    ),
    "crmNoRelationshipsAvailable": MessageLookupByLibrary.simpleMessage(
      "No Relationships Available",
    ),
    "crmNoStagesAvailable": MessageLookupByLibrary.simpleMessage(
      "No Stages Available",
    ),
    "crmNoTagsAvailable": MessageLookupByLibrary.simpleMessage(
      "No Tags Available",
    ),
    "crmNoTemplates": MessageLookupByLibrary.simpleMessage(
      "No templates available yet",
    ),
    "crmNoTermsAvailable": MessageLookupByLibrary.simpleMessage(
      "No Terms Available",
    ),
    "crmNote": MessageLookupByLibrary.simpleMessage("Note"),
    "crmNoteArabic": MessageLookupByLibrary.simpleMessage("ملاحظة"),
    "crmNumberOfColumns": MessageLookupByLibrary.simpleMessage(
      "Number of Columns",
    ),
    "crmOK": MessageLookupByLibrary.simpleMessage("OK"),
    "crmOwner": MessageLookupByLibrary.simpleMessage("Owner"),
    "crmPage": MessageLookupByLibrary.simpleMessage("Page"),
    "crmPercentage": MessageLookupByLibrary.simpleMessage("Percentage (%)"),
    "crmPerson": MessageLookupByLibrary.simpleMessage("Person"),
    "crmPersons": MessageLookupByLibrary.simpleMessage("Persons"),
    "crmPhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "crmPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
    "crmPleaseAddAtLeastOneType": MessageLookupByLibrary.simpleMessage(
      "Please add at least one type",
    ),
    "crmPleaseEnterCategoryNameAr": MessageLookupByLibrary.simpleMessage(
      "Please enter Category Name in Arabic",
    ),
    "crmPleaseEnterCategoryNameEn": MessageLookupByLibrary.simpleMessage(
      "Please enter Category Name in English",
    ),
    "crmPleaseEnterDiscountValue": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid discount value",
    ),
    "crmPleaseEnterRelationshipName": MessageLookupByLibrary.simpleMessage(
      "Please enter relationship category name",
    ),
    "crmPleaseEnterRuleNameAr": MessageLookupByLibrary.simpleMessage(
      "Please enter rule name in Arabic",
    ),
    "crmPleaseEnterRuleNameEn": MessageLookupByLibrary.simpleMessage(
      "Please enter rule name in English",
    ),
    "crmPleaseEnterStageNameAr": MessageLookupByLibrary.simpleMessage(
      "Please enter stage name in Arabic",
    ),
    "crmPleaseEnterStageNameEn": MessageLookupByLibrary.simpleMessage(
      "Please enter stage name in English",
    ),
    "crmPleaseEnterTagNameAr": MessageLookupByLibrary.simpleMessage(
      "Please enter tag name in Arabic",
    ),
    "crmPleaseEnterTagNameEn": MessageLookupByLibrary.simpleMessage(
      "Please enter tag name in English",
    ),
    "crmPleaseEnterTermName": MessageLookupByLibrary.simpleMessage(
      "Please enter term name",
    ),
    "crmPleaseEnterTypeAr": MessageLookupByLibrary.simpleMessage(
      "Please enter Type in Arabic",
    ),
    "crmPleaseEnterTypeEn": MessageLookupByLibrary.simpleMessage(
      "Please enter Type in English",
    ),
    "crmPleaseSelectCategory": MessageLookupByLibrary.simpleMessage(
      "Please select a category",
    ),
    "crmPreferredLanguage": MessageLookupByLibrary.simpleMessage(
      "Preferred Language",
    ),
    "crmPressToAdd": MessageLookupByLibrary.simpleMessage("Press to add"),
    "crmPreview": MessageLookupByLibrary.simpleMessage("Preview"),
    "crmProbability": MessageLookupByLibrary.simpleMessage("Probability"),
    "crmProduct": MessageLookupByLibrary.simpleMessage("Product"),
    "crmProductsCategory": MessageLookupByLibrary.simpleMessage(
      "Products Category",
    ),
    "crmProspect": MessageLookupByLibrary.simpleMessage("Prospect"),
    "crmProvince": MessageLookupByLibrary.simpleMessage("Province"),
    "crmRelationship": MessageLookupByLibrary.simpleMessage("Relationship"),
    "crmRelationshipAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new relationship",
    ),
    "crmRelationshipAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Relationship added successfully",
    ),
    "crmRelationshipDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Relationship deleted successfully",
    ),
    "crmRelationshipDetails": MessageLookupByLibrary.simpleMessage(
      "Relationship Details",
    ),
    "crmRelationshipUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Relationship updated successfully",
    ),
    "crmRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "crmRemoveField": MessageLookupByLibrary.simpleMessage("Remove Field"),
    "crmRemoveFieldSubtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure to remove this field?",
    ),
    "crmRemoveRelationship": MessageLookupByLibrary.simpleMessage(
      "Remove Relationship",
    ),
    "crmRemoveRelationshipConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this relationship completely?",
    ),
    "crmRemoveSelection": MessageLookupByLibrary.simpleMessage(
      "Remove Selection",
    ),
    "crmRemoveTerm": MessageLookupByLibrary.simpleMessage("Remove Term"),
    "crmRemoveTermConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this term completely?",
    ),
    "crmRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Removed successfully .",
    ),
    "crmRequiredField": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "crmRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "crmReviewBulkUpload": MessageLookupByLibrary.simpleMessage(
      "Review Bulk Upload",
    ),
    "crmRule": MessageLookupByLibrary.simpleMessage("Rule"),
    "crmRuleDetails": MessageLookupByLibrary.simpleMessage("Rule Details"),
    "crmRuleName": MessageLookupByLibrary.simpleMessage("Rule Name"),
    "crmRuleNameAr": MessageLookupByLibrary.simpleMessage("اسم القاعدة"),
    "crmSave": MessageLookupByLibrary.simpleMessage("Save"),
    "crmSaveCategory": MessageLookupByLibrary.simpleMessage("Save Category"),
    "crmSaveCategoryConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save this category?",
    ),
    "crmSaveClientConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save this client record?",
    ),
    "crmSaveClientRecord": MessageLookupByLibrary.simpleMessage(
      "Save Client Record",
    ),
    "crmSaveForLater": MessageLookupByLibrary.simpleMessage("Save For Later"),
    "crmSaveFormat": MessageLookupByLibrary.simpleMessage("Save Format"),
    "crmSaveRelationship": MessageLookupByLibrary.simpleMessage(
      "Save Relationship",
    ),
    "crmSaveRelationshipConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save this relationship?",
    ),
    "crmSaveStage": MessageLookupByLibrary.simpleMessage("Save Stage"),
    "crmSaveSubtitle": MessageLookupByLibrary.simpleMessage(
      "Are you sure to save Changes?",
    ),
    "crmSaveTerm": MessageLookupByLibrary.simpleMessage("Save Term"),
    "crmSaveTermConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to save this term?",
    ),
    "crmSavedSections": MessageLookupByLibrary.simpleMessage("Saved Sections"),
    "crmSavedView": MessageLookupByLibrary.simpleMessage("Saved View"),
    "crmSearch": MessageLookupByLibrary.simpleMessage("Search"),
    "crmSection": MessageLookupByLibrary.simpleMessage("Section"),
    "crmSectionBlacklist": MessageLookupByLibrary.simpleMessage("Blacklist"),
    "crmSectionBlacklistDesc": MessageLookupByLibrary.simpleMessage(
      "Manage blocked clients",
    ),
    "crmSectionClients": MessageLookupByLibrary.simpleMessage("Clients"),
    "crmSectionClientsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage Your client and view details",
    ),
    "crmSectionContracts": MessageLookupByLibrary.simpleMessage("Contracts"),
    "crmSectionContractsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage contracts",
    ),
    "crmSectionControls": MessageLookupByLibrary.simpleMessage("Controls"),
    "crmSectionControlsDesc": MessageLookupByLibrary.simpleMessage(
      "Configure system settings and control user access.",
    ),
    "crmSectionDeals": MessageLookupByLibrary.simpleMessage("Deals"),
    "crmSectionDealsDesc": MessageLookupByLibrary.simpleMessage(
      "Track your deals and manage your sales pipelines",
    ),
    "crmSectionDetails": MessageLookupByLibrary.simpleMessage(
      "Section Details",
    ),
    "crmSectionGuide": MessageLookupByLibrary.simpleMessage("Guide"),
    "crmSectionGuideDesc": MessageLookupByLibrary.simpleMessage(
      "Access guides, FAQs, and competitor information",
    ),
    "crmSectionLeads": MessageLookupByLibrary.simpleMessage("Leads"),
    "crmSectionLeadsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage and track Potential Customer",
    ),
    "crmSectionMerge": MessageLookupByLibrary.simpleMessage("Merge"),
    "crmSectionMergeDesc": MessageLookupByLibrary.simpleMessage(
      "Review and manage duplicate records",
    ),
    "crmSectionName": MessageLookupByLibrary.simpleMessage("Section Name"),
    "crmSectionNameAr": MessageLookupByLibrary.simpleMessage("اسم القسم"),
    "crmSectionProducts": MessageLookupByLibrary.simpleMessage("Products"),
    "crmSectionProductsDesc": MessageLookupByLibrary.simpleMessage(
      "Manage your Products",
    ),
    "crmSectionQuotes": MessageLookupByLibrary.simpleMessage("Quotes"),
    "crmSectionQuotesDesc": MessageLookupByLibrary.simpleMessage(
      "Create and manage quotes for your clients",
    ),
    "crmSectionRequests": MessageLookupByLibrary.simpleMessage("Requests"),
    "crmSectionRequestsDesc": MessageLookupByLibrary.simpleMessage(
      "View and manage requests",
    ),
    "crmSectionServices": MessageLookupByLibrary.simpleMessage("Services"),
    "crmSectionServicesDesc": MessageLookupByLibrary.simpleMessage(
      "Manage your Services",
    ),
    "crmSectionsTab": MessageLookupByLibrary.simpleMessage("Sections"),
    "crmSector": MessageLookupByLibrary.simpleMessage("Sector"),
    "crmSelect": MessageLookupByLibrary.simpleMessage("Select"),
    "crmSelectDate": MessageLookupByLibrary.simpleMessage("Select Date"),
    "crmSelectField": MessageLookupByLibrary.simpleMessage("Select Field"),
    "crmSelectSection": MessageLookupByLibrary.simpleMessage("Select Section"),
    "crmSelectTime": MessageLookupByLibrary.simpleMessage("Select Time"),
    "crmSelected": MessageLookupByLibrary.simpleMessage("selected"),
    "crmService": MessageLookupByLibrary.simpleMessage("Service"),
    "crmSetting": MessageLookupByLibrary.simpleMessage("Setting"),
    "crmShow": MessageLookupByLibrary.simpleMessage("Show"),
    "crmShowBothLanguages": MessageLookupByLibrary.simpleMessage(
      "Show AR + EN Language",
    ),
    "crmSize": MessageLookupByLibrary.simpleMessage("Size"),
    "crmSort": MessageLookupByLibrary.simpleMessage("Sort"),
    "crmSortNameAZ": MessageLookupByLibrary.simpleMessage("Name (A-Z)"),
    "crmSortNameAsc": MessageLookupByLibrary.simpleMessage("Name (A - Z)"),
    "crmSortNameDesc": MessageLookupByLibrary.simpleMessage("Name (Z - A)"),
    "crmSortNameZA": MessageLookupByLibrary.simpleMessage("Name (Z-A)"),
    "crmSortNewest": MessageLookupByLibrary.simpleMessage("Newest First"),
    "crmSortOldest": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "crmSpecificLinkTypes": MessageLookupByLibrary.simpleMessage(
      "Specific Link Types",
    ),
    "crmStageDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Stage deleted successfully",
    ),
    "crmStageDetails": MessageLookupByLibrary.simpleMessage("Stage Details"),
    "crmStageSavedSuccess": MessageLookupByLibrary.simpleMessage(
      "Stage saved successfully",
    ),
    "crmStageUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Stage updated successfully",
    ),
    "crmStages": MessageLookupByLibrary.simpleMessage("Stages"),
    "crmStagesAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new stage",
    ),
    "crmStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "crmStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "crmStatusDeleted": MessageLookupByLibrary.simpleMessage("Deleted"),
    "crmStatusInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "crmStreet": MessageLookupByLibrary.simpleMessage("Street"),
    "crmSubmitSuccessfully": MessageLookupByLibrary.simpleMessage(
      "submit successfully .",
    ),
    "crmSuccess": MessageLookupByLibrary.simpleMessage("Success"),
    "crmSuccessful": MessageLookupByLibrary.simpleMessage("Successful!"),
    "crmSwitchInfoMessage": MessageLookupByLibrary.simpleMessage(
      "A switch can be used as a simple On/Off toggle, or you can add items to display selectable options when the switch is enabled.",
    ),
    "crmTagDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Tag deleted successfully",
    ),
    "crmTagSavedSuccess": MessageLookupByLibrary.simpleMessage(
      "Tag saved successfully",
    ),
    "crmTagUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Tag updated successfully",
    ),
    "crmTags": MessageLookupByLibrary.simpleMessage("Tags"),
    "crmTagsAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new tag",
    ),
    "crmTaxNumber": MessageLookupByLibrary.simpleMessage(
      "Tax No. (Tax Number)",
    ),
    "crmTeams": MessageLookupByLibrary.simpleMessage("Teams"),
    "crmTemplates": MessageLookupByLibrary.simpleMessage("Templates"),
    "crmTermAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "Term added successfully",
    ),
    "crmTermDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Term deleted successfully",
    ),
    "crmTermUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Term updated successfully",
    ),
    "crmTerms": MessageLookupByLibrary.simpleMessage("Terms"),
    "crmTermsAddPrompt": MessageLookupByLibrary.simpleMessage(
      "Click on Add button to create a new term",
    ),
    "crmTermsCount": MessageLookupByLibrary.simpleMessage("Terms:"),
    "crmTermsDetails": MessageLookupByLibrary.simpleMessage("Terms Details"),
    "crmTextHere": MessageLookupByLibrary.simpleMessage("Text Here"),
    "crmTime": MessageLookupByLibrary.simpleMessage("Time"),
    "crmTo": MessageLookupByLibrary.simpleMessage("To"),
    "crmToAddSectionHint": MessageLookupByLibrary.simpleMessage(
      "To add a section, select 1 column",
    ),
    "crmTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "crmTotalClients": MessageLookupByLibrary.simpleMessage("Total Clients"),
    "crmTrimSpaces": MessageLookupByLibrary.simpleMessage("Trim Spaces"),
    "crmType": MessageLookupByLibrary.simpleMessage("Type"),
    "crmTypeDetails": MessageLookupByLibrary.simpleMessage("Type Details"),
    "crmTypes": MessageLookupByLibrary.simpleMessage("Types"),
    "crmTypesCount": MessageLookupByLibrary.simpleMessage("Types:"),
    "crmUnique": MessageLookupByLibrary.simpleMessage("Unique"),
    "crmValidateImportedClients": MessageLookupByLibrary.simpleMessage(
      "Validate imported clients data before activating",
    ),
    "crmValidation": MessageLookupByLibrary.simpleMessage("Validation"),
    "crmValidationEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "crmValidationLetters": MessageLookupByLibrary.simpleMessage("Letters"),
    "crmValidationNone": MessageLookupByLibrary.simpleMessage("None"),
    "crmValidationNumbers": MessageLookupByLibrary.simpleMessage("Numbers"),
    "crmValidationPhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "crmValidationSymbols": MessageLookupByLibrary.simpleMessage("Symbols"),
    "crmValue": MessageLookupByLibrary.simpleMessage("Value"),
    "crmViewClient": MessageLookupByLibrary.simpleMessage("View Client"),
    "crmWarningLanguageCheckSubtitle": MessageLookupByLibrary.simpleMessage(
      "There is an issue with your entry. Please ensure you use the required language",
    ),
    "crmWarningLanguageCheckTitle": MessageLookupByLibrary.simpleMessage(
      "Warning Language Check",
    ),
    "crmWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "crmWriteHere": MessageLookupByLibrary.simpleMessage("اكتب هنا"),
    "croatian": MessageLookupByLibrary.simpleMessage("Croatian"),
    "csvFileSaved": MessageLookupByLibrary.simpleMessage(
      "Your CSV file has been saved",
    ),
    "csvImport": MessageLookupByLibrary.simpleMessage("CSV Import"),
    "cuban": MessageLookupByLibrary.simpleMessage("Cuban"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "currentControlChampion": MessageLookupByLibrary.simpleMessage(
      "Current Control Champion",
    ),
    "currentControlOwner": MessageLookupByLibrary.simpleMessage(
      "Current Control Owner",
    ),
    "currentLabel": MessageLookupByLibrary.simpleMessage("Current"),
    "current_details": MessageLookupByLibrary.simpleMessage("Current Details"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customTable": MessageLookupByLibrary.simpleMessage("Custom Table"),
    "customerSupport": MessageLookupByLibrary.simpleMessage("Customer Support"),
    "customizeYourPersonalBrandingTheseSettingsWillOv":
        MessageLookupByLibrary.simpleMessage(
          "Customize your personal branding. These settings will override company branding for your account only.",
        ),
    "cyberSecurity": MessageLookupByLibrary.simpleMessage("Cyber Security"),
    "cypriot": MessageLookupByLibrary.simpleMessage("Cypriot"),
    "czech": MessageLookupByLibrary.simpleMessage("Czech"),
    "daily": MessageLookupByLibrary.simpleMessage("Daily"),
    "damageType": MessageLookupByLibrary.simpleMessage("Damage Type"),
    "damaged": MessageLookupByLibrary.simpleMessage("Damaged"),
    "danish": MessageLookupByLibrary.simpleMessage("Danish"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardPermissions": MessageLookupByLibrary.simpleMessage(
      "Dashboard Permissions",
    ),
    "dashboardPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Dashboard Permissions Module",
    ),
    "dataHasBeenSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Data has been saved successfully",
    ),
    "dataManagement": MessageLookupByLibrary.simpleMessage("Data Management"),
    "dataNotLoading": MessageLookupByLibrary.simpleMessage("Data Not Loading"),
    "dataNotSaving": MessageLookupByLibrary.simpleMessage("Data Not Saving"),
    "dataSavedLocally": MessageLookupByLibrary.simpleMessage(
      "Data saved locally.",
    ),
    "dataWillAppearOnceUsersInteract": MessageLookupByLibrary.simpleMessage(
      "Data will appear once users interact with this document",
    ),
    "database": MessageLookupByLibrary.simpleMessage("Database"),
    "database_builder": MessageLookupByLibrary.simpleMessage(
      "Database Builder",
    ),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dateAdded": MessageLookupByLibrary.simpleMessage("Date Added"),
    "dateOfAction": MessageLookupByLibrary.simpleMessage("Date Of Action"),
    "dateRange": MessageLookupByLibrary.simpleMessage("Date Range"),
    "dateReceived": MessageLookupByLibrary.simpleMessage("Date Received"),
    "dateRequested": MessageLookupByLibrary.simpleMessage("Date Requested"),
    "day": MessageLookupByLibrary.simpleMessage("Day"),
    "days": MessageLookupByLibrary.simpleMessage("Days"),
    "daysAgo": MessageLookupByLibrary.simpleMessage("Days Ago"),
    "daysOff": MessageLookupByLibrary.simpleMessage("Days Off"),
    "deactivateUser": MessageLookupByLibrary.simpleMessage("Deactivate User"),
    "deactivatedForNow": MessageLookupByLibrary.simpleMessage(
      "Deactivated For Now",
    ),
    "deactivatingUserAccount": MessageLookupByLibrary.simpleMessage(
      "Deactivating User Account",
    ),
    "deathVacation": MessageLookupByLibrary.simpleMessage("Death Vacation"),
    "debugSwitchToTestEmployee": MessageLookupByLibrary.simpleMessage(
      "🧪 Switch to test employee",
    ),
    "debugTestEmployeeBadge": MessageLookupByLibrary.simpleMessage(
      "DEBUG: test employee",
    ),
    "debugTestEmployeeButton": MessageLookupByLibrary.simpleMessage(
      "🧪 Test employee",
    ),
    "debugTestEmployeeCannotSwitch": MessageLookupByLibrary.simpleMessage(
      "Cannot Switch",
    ),
    "debugTestEmployeeCompanyAdmin": MessageLookupByLibrary.simpleMessage(
      "The company admin account cannot be used with the debug switch.",
    ),
    "debugTestEmployeeCompanyId": MessageLookupByLibrary.simpleMessage(
      "Company ID",
    ),
    "debugTestEmployeeConfirmSwitch": MessageLookupByLibrary.simpleMessage(
      "You will be signed out of this session to choose a test employee.",
    ),
    "debugTestEmployeeDebugOnly": MessageLookupByLibrary.simpleMessage(
      "This is available in debug builds only.",
    ),
    "debugTestEmployeeEmpty": m13,
    "debugTestEmployeeHint": MessageLookupByLibrary.simpleMessage(
      "Debug builds only. Signs in as the chosen test account without its password; its role, status and access dates are still checked.",
    ),
    "debugTestEmployeeLoad": MessageLookupByLibrary.simpleMessage("Load"),
    "debugTestEmployeeLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not load this company\'s employees.",
    ),
    "debugTestEmployeeNoDepartment": MessageLookupByLibrary.simpleMessage(
      "No department",
    ),
    "debugTestEmployeeNoRole": MessageLookupByLibrary.simpleMessage("No role"),
    "debugTestEmployeeNotActivated": MessageLookupByLibrary.simpleMessage(
      "This account is not activated yet. It must complete its first sign-in (password change) before it can be used here.",
    ),
    "debugTestEmployeeNotActivatedNote": MessageLookupByLibrary.simpleMessage(
      "Not activated yet (signs in as activated in debug)",
    ),
    "debugTestEmployeeNotTestEmail": m14,
    "debugTestEmployeeOtherCompany": m15,
    "debugTestEmployeeStatus": m16,
    "debugTestEmployeeStatusBlocked": m17,
    "debugTestEmployeeTitle": MessageLookupByLibrary.simpleMessage(
      "🧪 Test Employees",
    ),
    "dec": MessageLookupByLibrary.simpleMessage("Dec"),
    "defaultPassword": MessageLookupByLibrary.simpleMessage("Default Password"),
    "degreeOrCertification": MessageLookupByLibrary.simpleMessage(
      "Degree or Certification",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "deleteAll": MessageLookupByLibrary.simpleMessage("Delete All"),
    "deleteAllNotifications": MessageLookupByLibrary.simpleMessage(
      "Delete All Notifications",
    ),
    "deleteAttachment": MessageLookupByLibrary.simpleMessage(
      "Delete Attachment",
    ),
    "deleteContact": MessageLookupByLibrary.simpleMessage("Delete Contact"),
    "deleteDeal": MessageLookupByLibrary.simpleMessage("Delete Deal"),
    "deleteEmployee": MessageLookupByLibrary.simpleMessage("Delete Employee"),
    "deleteForm": MessageLookupByLibrary.simpleMessage("Delete Form"),
    "deleteImage": MessageLookupByLibrary.simpleMessage("Delete Image"),
    "deleteLead": MessageLookupByLibrary.simpleMessage("Delete Lead"),
    "deleteMessage": MessageLookupByLibrary.simpleMessage("Delete Message"),
    "deleteQiyas": MessageLookupByLibrary.simpleMessage("Delete Qiyas"),
    "deleteRole": MessageLookupByLibrary.simpleMessage("Delete Role"),
    "deleteService": MessageLookupByLibrary.simpleMessage("Delete Service"),
    "deleteServices": MessageLookupByLibrary.simpleMessage("Delete Service"),
    "deleteStarredMessages": MessageLookupByLibrary.simpleMessage(
      "Delete starred messages",
    ),
    "deleteSupplier": MessageLookupByLibrary.simpleMessage("Delete Supplier"),
    "deleteToDo": MessageLookupByLibrary.simpleMessage("Delete To Do"),
    "deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
    "deletedGrcModule": MessageLookupByLibrary.simpleMessage(
      "Deleted GRC Module",
    ),
    "deletedMessage": MessageLookupByLibrary.simpleMessage("Deleted Message"),
    "deletingControls": MessageLookupByLibrary.simpleMessage(
      "Deleting Controls",
    ),
    "deletingForm": MessageLookupByLibrary.simpleMessage("Deleting Form"),
    "deletingGrcModule": MessageLookupByLibrary.simpleMessage(
      "Deleting GRC Module",
    ),
    "deletingGroups": MessageLookupByLibrary.simpleMessage("Deleting Groups"),
    "deletingLocation": MessageLookupByLibrary.simpleMessage(
      "Deleting Location",
    ),
    "deletingRequestType": MessageLookupByLibrary.simpleMessage(
      "Deleting Request Type",
    ),
    "deletingToDoList": MessageLookupByLibrary.simpleMessage(
      "Deleting To Do List",
    ),
    "delivery": MessageLookupByLibrary.simpleMessage("Delivery"),
    "deliveryMethod": MessageLookupByLibrary.simpleMessage("Delivery Method"),
    "deliveryMethodAdvancedPayment": MessageLookupByLibrary.simpleMessage(
      "Advanced Payment",
    ),
    "deliveryMethodBankTransfer": MessageLookupByLibrary.simpleMessage(
      "Bank Transfer",
    ),
    "deliveryMethodCash": MessageLookupByLibrary.simpleMessage("Cash"),
    "deliveryMethodCashOnDelivery": MessageLookupByLibrary.simpleMessage(
      "Cash On Delivery",
    ),
    "deliveryMethodCheque": MessageLookupByLibrary.simpleMessage("Cheque"),
    "deliveryMethodCreditCard": MessageLookupByLibrary.simpleMessage(
      "Credit Card",
    ),
    "deliveryMethodInstallments": MessageLookupByLibrary.simpleMessage(
      "Installments",
    ),
    "deliveryMethodOnAccount": MessageLookupByLibrary.simpleMessage(
      "On Account",
    ),
    "demands": MessageLookupByLibrary.simpleMessage("Demands"),
    "demoAppPlus": MessageLookupByLibrary.simpleMessage("Knowticed Plus"),
    "department": MessageLookupByLibrary.simpleMessage("Department"),
    "departmentArabicNameBilingualRequired":
        MessageLookupByLibrary.simpleMessage(
          "Arabic department name is required",
        ),
    "departmentAvailability": MessageLookupByLibrary.simpleMessage(
      "Department Availability",
    ),
    "departmentCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Department cannot be empty",
    ),
    "departmentDashboard": MessageLookupByLibrary.simpleMessage(
      "Department Dashboard",
    ),
    "departmentDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "Department does not exist",
    ),
    "departmentEmployees": MessageLookupByLibrary.simpleMessage(
      "Department Employees",
    ),
    "departmentManager": MessageLookupByLibrary.simpleMessage(
      "Department Manager",
    ),
    "departmentMinLength": MessageLookupByLibrary.simpleMessage(
      "Department name must be at least 2 characters",
    ),
    "departmentNameAssignmentRequired": MessageLookupByLibrary.simpleMessage(
      "Department name is required",
    ),
    "departmentNameRequired": MessageLookupByLibrary.simpleMessage(
      "Department Name Required.",
    ),
    "departmentPerformance": MessageLookupByLibrary.simpleMessage(
      "Department Performance",
    ),
    "departmentRequired": MessageLookupByLibrary.simpleMessage(
      "Department required when limit is enabled",
    ),
    "departmentRestricted": MessageLookupByLibrary.simpleMessage(
      "Department-Restricted",
    ),
    "departmentScore": MessageLookupByLibrary.simpleMessage("Department Score"),
    "departmentScores": MessageLookupByLibrary.simpleMessage(
      "Department Score",
    ),
    "department_customer_support": MessageLookupByLibrary.simpleMessage(
      "Customer Support",
    ),
    "department_executive": MessageLookupByLibrary.simpleMessage("Executive"),
    "department_finance": MessageLookupByLibrary.simpleMessage("Finance"),
    "department_hr": MessageLookupByLibrary.simpleMessage("HR"),
    "department_human_resources": MessageLookupByLibrary.simpleMessage(
      "Human Resources",
    ),
    "department_it": MessageLookupByLibrary.simpleMessage(
      "Information Technology",
    ),
    "department_marketing": MessageLookupByLibrary.simpleMessage("Marketing"),
    "department_operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "department_sales": MessageLookupByLibrary.simpleMessage("Sales"),
    "departments": MessageLookupByLibrary.simpleMessage("Departments"),
    "departmentsScore": MessageLookupByLibrary.simpleMessage(
      "Departments Score",
    ),
    "departmentsWeight": MessageLookupByLibrary.simpleMessage(
      "Departments Weight",
    ),
    "des": MessageLookupByLibrary.simpleMessage("DES"),
    "descending": MessageLookupByLibrary.simpleMessage("Descending"),
    "describeTheStepsYouTook": MessageLookupByLibrary.simpleMessage(
      "Describe the steps you took",
    ),
    "describe_the_feature": MessageLookupByLibrary.simpleMessage(
      "Describe the feature",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "descriptionAr": MessageLookupByLibrary.simpleMessage(
      "Description (Arabic)",
    ),
    "descriptionArabic": MessageLookupByLibrary.simpleMessage(
      "Description (Arabic)",
    ),
    "descriptionEn": MessageLookupByLibrary.simpleMessage(
      "Description (English)",
    ),
    "descriptionIsRequired": MessageLookupByLibrary.simpleMessage(
      "Description is required",
    ),
    "descriptionMustBeWrittenInArabic": MessageLookupByLibrary.simpleMessage(
      "Description must be written in Arabic",
    ),
    "descriptionOfIncident": MessageLookupByLibrary.simpleMessage(
      "Description of Incident",
    ),
    "descriptionOfIssue": MessageLookupByLibrary.simpleMessage(
      "Description of Issue/Service Needed",
    ),
    "descriptionSpecialChars": MessageLookupByLibrary.simpleMessage(
      "Only . : \" , special characters are allowed",
    ),
    "deselectAll": MessageLookupByLibrary.simpleMessage("Deselect All"),
    "design": MessageLookupByLibrary.simpleMessage("Design"),
    "designIssue": MessageLookupByLibrary.simpleMessage("Design Issue"),
    "desktopView": MessageLookupByLibrary.simpleMessage("Desktop View"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "detailsOfTitle": m18,
    "detailsPageTitle": MessageLookupByLibrary.simpleMessage("To Do Details"),
    "development": MessageLookupByLibrary.simpleMessage("Development"),
    "developmentTeam": MessageLookupByLibrary.simpleMessage("Development Team"),
    "device": MessageLookupByLibrary.simpleMessage("Device"),
    "differentApprovalCycleForTheOtherRequestTypes":
        MessageLookupByLibrary.simpleMessage(
          "Different Approval Cycle For The Other Request Types",
        ),
    "diploma": MessageLookupByLibrary.simpleMessage("Diploma"),
    "directMessage": MessageLookupByLibrary.simpleMessage("Direct Message"),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "disappearingMessages": MessageLookupByLibrary.simpleMessage(
      "Disappearing Messages",
    ),
    "discard": MessageLookupByLibrary.simpleMessage("Discard"),
    "discardChange": MessageLookupByLibrary.simpleMessage("Discard Changes"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("Discard Changes"),
    "discardPolicy": MessageLookupByLibrary.simpleMessage("Discard Policy"),
    "discardTitle": MessageLookupByLibrary.simpleMessage("Discard"),
    "discountPercentage": MessageLookupByLibrary.simpleMessage(
      "Discount Percentage",
    ),
    "dispatchZone": MessageLookupByLibrary.simpleMessage("Dispatch Zone"),
    "displayWith": MessageLookupByLibrary.simpleMessage("Display With"),
    "divorced": MessageLookupByLibrary.simpleMessage("Divorced"),
    "djibouti": MessageLookupByLibrary.simpleMessage("Djibouti"),
    "doYouWantToProceedToNextProduct": MessageLookupByLibrary.simpleMessage(
      "Do you want to proceed to the next product?",
    ),
    "doYouWantToSaveThisRoleAsDraft": MessageLookupByLibrary.simpleMessage(
      "Do you want to save this role as draft?",
    ),
    "doctorate": MessageLookupByLibrary.simpleMessage("Doctorate"),
    "document": MessageLookupByLibrary.simpleMessage("Document"),
    "documentDetails": MessageLookupByLibrary.simpleMessage("Document Details"),
    "documentFileRejected": MessageLookupByLibrary.simpleMessage(
      "Document Rejected",
    ),
    "documentManagement": MessageLookupByLibrary.simpleMessage(
      "Document Management",
    ),
    "documentRemoveSuccess": MessageLookupByLibrary.simpleMessage(
      "The document has been rejected successfully",
    ),
    "documentTitle": MessageLookupByLibrary.simpleMessage("Document Title"),
    "documentUrl": MessageLookupByLibrary.simpleMessage("Document URL"),
    "documentUtilization": MessageLookupByLibrary.simpleMessage(
      "Document Utilization",
    ),
    "document_description": MessageLookupByLibrary.simpleMessage(
      "Document Description",
    ),
    "document_name": MessageLookupByLibrary.simpleMessage("Document Name"),
    "document_type": MessageLookupByLibrary.simpleMessage("Document Type"),
    "document_utilization": MessageLookupByLibrary.simpleMessage(
      "Document Utilization",
    ),
    "documents": MessageLookupByLibrary.simpleMessage("Documents"),
    "doesEachDepartmentCarryADistinctWeighting":
        MessageLookupByLibrary.simpleMessage(
          "Does each department carry a distinct weighting?",
        ),
    "doesntFitMyScreen": MessageLookupByLibrary.simpleMessage(
      "Doesn\'t Fit My Screen",
    ),
    "dominican": MessageLookupByLibrary.simpleMessage("Dominican"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "doneProjects": MessageLookupByLibrary.simpleMessage("Done Projects"),
    "doneServices": MessageLookupByLibrary.simpleMessage("Done Services"),
    "donutChart": MessageLookupByLibrary.simpleMessage("Donut Chart"),
    "doubleCommas": MessageLookupByLibrary.simpleMessage(
      "Double commas not allowed",
    ),
    "doubleCommasNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Double commas not allowed",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadAsExcel": MessageLookupByLibrary.simpleMessage(
      "Download As Excel",
    ),
    "downloadAsPdf": MessageLookupByLibrary.simpleMessage("Download As PDF"),
    "downloadAsPng": MessageLookupByLibrary.simpleMessage("Download as PNG"),
    "downloadComplete": MessageLookupByLibrary.simpleMessage(
      "Download Complete",
    ),
    "downloadDocuments": MessageLookupByLibrary.simpleMessage(
      "Download Documents",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("Download Failed"),
    "downloadFile": MessageLookupByLibrary.simpleMessage("Download File"),
    "downloadForm": MessageLookupByLibrary.simpleMessage("Download Form"),
    "downloadFormDigitalAssets": MessageLookupByLibrary.simpleMessage(
      "Download Form Digital Assets",
    ),
    "downloadPDFofAboutThisApp": MessageLookupByLibrary.simpleMessage(
      "Download PDF of About This Platform",
    ),
    "downloadPDFofPrivacyAndPolicy": MessageLookupByLibrary.simpleMessage(
      "Download PDF of Privacy And Policy",
    ),
    "downloadPDFofTermsAndCondition": MessageLookupByLibrary.simpleMessage(
      "Download PDF of Terms And Condition",
    ),
    "downloadPage": MessageLookupByLibrary.simpleMessage("Download Page"),
    "downloadSubmissions": MessageLookupByLibrary.simpleMessage(
      "Download Submissions",
    ),
    "downloadSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "You have successfully downloaded this document.",
    ),
    "downloadSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "Download Successful",
    ),
    "downloading": MessageLookupByLibrary.simpleMessage("Downloading"),
    "downloadingFile": MessageLookupByLibrary.simpleMessage("Downloading File"),
    "downloads": MessageLookupByLibrary.simpleMessage("Downloads"),
    "draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "draftForm": MessageLookupByLibrary.simpleMessage("Draft Form"),
    "draftRoleCompletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Draft role completed successfully",
    ),
    "draftRoles": MessageLookupByLibrary.simpleMessage("Draft Roles"),
    "draftSaved": MessageLookupByLibrary.simpleMessage("Draft Saved"),
    "draftSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Draft saved successfully!",
    ),
    "draftService": MessageLookupByLibrary.simpleMessage("Draft Service"),
    "dragDropFilesHere": MessageLookupByLibrary.simpleMessage(
      "Drag and drop files here",
    ),
    "dragDropHere": MessageLookupByLibrary.simpleMessage(
      "Drag & Drop files here",
    ),
    "drivingLicense": MessageLookupByLibrary.simpleMessage("Driving License"),
    "drivingLicenseId": MessageLookupByLibrary.simpleMessage(
      "Driving License ID",
    ),
    "dryStorage": MessageLookupByLibrary.simpleMessage("Dry Storage"),
    "dubai": MessageLookupByLibrary.simpleMessage("Dubai"),
    "dueDate": MessageLookupByLibrary.simpleMessage("Due Date"),
    "dueDateOfReturn": MessageLookupByLibrary.simpleMessage(
      "Due Date of Return",
    ),
    "duplicateEmails": MessageLookupByLibrary.simpleMessage(
      "Duplicate emails not allowed",
    ),
    "duplicateForm": MessageLookupByLibrary.simpleMessage("Duplicate Form"),
    "duplicateRequest": MessageLookupByLibrary.simpleMessage(
      "Duplicate Request",
    ),
    "duplicateStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Duplicate storage location.",
    ),
    "duplicateValue": MessageLookupByLibrary.simpleMessage(
      "Duplicate value – must be unique",
    ),
    "duplicatedOrOutOfSync": MessageLookupByLibrary.simpleMessage(
      "Duplicated or Out of Sync",
    ),
    "duplicatingForm": MessageLookupByLibrary.simpleMessage("Duplicating Form"),
    "duplication": MessageLookupByLibrary.simpleMessage("Duplication"),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "durationOfService": MessageLookupByLibrary.simpleMessage(
      "Duration of Service",
    ),
    "duration_unit_hours": MessageLookupByLibrary.simpleMessage("Hours"),
    "duration_unit_minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "duration_unit_seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "duration_unit_week": MessageLookupByLibrary.simpleMessage("Week"),
    "dutch": MessageLookupByLibrary.simpleMessage("Dutch"),
    "dzd": MessageLookupByLibrary.simpleMessage("DZD"),
    "eGP": MessageLookupByLibrary.simpleMessage("EGP"),
    "eUR": MessageLookupByLibrary.simpleMessage("EUR"),
    "earliestSubmitted": MessageLookupByLibrary.simpleMessage(
      "Earliest Submitted",
    ),
    "eastTimorese": MessageLookupByLibrary.simpleMessage("East Timorese"),
    "ecuadorean": MessageLookupByLibrary.simpleMessage("Ecuadorean"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editAccess": MessageLookupByLibrary.simpleMessage("Edit Access"),
    "editAccount": MessageLookupByLibrary.simpleMessage("Edit Account"),
    "editContact": MessageLookupByLibrary.simpleMessage("Edit Contact"),
    "editControlScreenNotImplemented": MessageLookupByLibrary.simpleMessage(
      "Edit control screen not implemented yet",
    ),
    "editControls": MessageLookupByLibrary.simpleMessage("Edit Controls"),
    "editDeal": MessageLookupByLibrary.simpleMessage("Edit Deal"),
    "editDocumentWithApproval": MessageLookupByLibrary.simpleMessage(
      "Edit Document With Approval",
    ),
    "editDocumentWithoutApproval": MessageLookupByLibrary.simpleMessage(
      "Edit Document Without Approval",
    ),
    "editEmailNotificationMessages": MessageLookupByLibrary.simpleMessage(
      "Edit Email Notification Messages",
    ),
    "editEmployee": MessageLookupByLibrary.simpleMessage("Edit Employee"),
    "editFileName": MessageLookupByLibrary.simpleMessage("Edit File Name"),
    "editForm": MessageLookupByLibrary.simpleMessage("Edit Form"),
    "editGroup": MessageLookupByLibrary.simpleMessage("Edit Group"),
    "editLead": MessageLookupByLibrary.simpleMessage("Edit Lead"),
    "editMeeting": MessageLookupByLibrary.simpleMessage("Edit Meeting"),
    "editMessage": MessageLookupByLibrary.simpleMessage("Edit Message"),
    "editNotification": MessageLookupByLibrary.simpleMessage(
      "Edit Notification",
    ),
    "editPermission": MessageLookupByLibrary.simpleMessage("Edit Permission"),
    "editPolicy": MessageLookupByLibrary.simpleMessage("Edit Policy"),
    "editProductInformation": MessageLookupByLibrary.simpleMessage(
      "Edit Product Information",
    ),
    "editPushNotificationMessages": MessageLookupByLibrary.simpleMessage(
      "Edit Push Notification Messages",
    ),
    "editQiyasDetails": MessageLookupByLibrary.simpleMessage(
      "Edit Qiyas Details",
    ),
    "editRole": MessageLookupByLibrary.simpleMessage("Edit Role"),
    "editRolePermissions": MessageLookupByLibrary.simpleMessage(
      "Edit Role Permissions",
    ),
    "editRoleSettingsPermissions": MessageLookupByLibrary.simpleMessage(
      "Edit Role Settings Permissions",
    ),
    "editService": MessageLookupByLibrary.simpleMessage("Edit Service"),
    "editServiceProvider": MessageLookupByLibrary.simpleMessage(
      "Edit Service Provider",
    ),
    "editSuccess": MessageLookupByLibrary.simpleMessage("Editing Success"),
    "editToDo": MessageLookupByLibrary.simpleMessage("Edit To Do"),
    "editUploadedDocument": MessageLookupByLibrary.simpleMessage(
      "Edit Uploaded Document",
    ),
    "editYourMessage": MessageLookupByLibrary.simpleMessage(
      "Edit your message",
    ),
    "editable": MessageLookupByLibrary.simpleMessage("Editable"),
    "edited": MessageLookupByLibrary.simpleMessage("Edited"),
    "editedGroup": MessageLookupByLibrary.simpleMessage("Edited Group"),
    "editedModules": MessageLookupByLibrary.simpleMessage("Edited Modules"),
    "editedService": MessageLookupByLibrary.simpleMessage("Edited Service"),
    "editingAccessDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Access Details",
    ),
    "editingControl": MessageLookupByLibrary.simpleMessage("Editing Control"),
    "editingControls": MessageLookupByLibrary.simpleMessage("Editing Controls"),
    "editingControlsWeight": MessageLookupByLibrary.simpleMessage(
      "Editing Controls Weight",
    ),
    "editingDocumentDetails": m19,
    "editingEmployeeDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Employee Details",
    ),
    "editingForm": MessageLookupByLibrary.simpleMessage("Editing Form"),
    "editingGrcModule": MessageLookupByLibrary.simpleMessage(
      "Editing GRC Module",
    ),
    "editingGroupDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Group Details",
    ),
    "editingHealthInsurance": MessageLookupByLibrary.simpleMessage(
      "Editing Health Insurance",
    ),
    "editingLocation": MessageLookupByLibrary.simpleMessage("Editing Location"),
    "editingModules": MessageLookupByLibrary.simpleMessage("Editing Modules"),
    "editingMyPersonalData": MessageLookupByLibrary.simpleMessage(
      "Editing My Personal Data",
    ),
    "editingPoliciesWeight": MessageLookupByLibrary.simpleMessage(
      "Editing Policies Weight",
    ),
    "editingPolicy": MessageLookupByLibrary.simpleMessage("Editing Policy"),
    "editingProductDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Product Details",
    ),
    "editingProductDetails_ar": MessageLookupByLibrary.simpleMessage(
      "Editing Product Details",
    ),
    "editingRequestType": MessageLookupByLibrary.simpleMessage(
      "Editing Request Type",
    ),
    "editingRole": MessageLookupByLibrary.simpleMessage("Editing Role"),
    "editingService": MessageLookupByLibrary.simpleMessage("Editing Service"),
    "editingSupplierDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Supplier Details",
    ),
    "editingToDoList": MessageLookupByLibrary.simpleMessage(
      "Editing To Do List",
    ),
    "editingToDoTitle": MessageLookupByLibrary.simpleMessage("Editing To Do"),
    "editingToDodialog": MessageLookupByLibrary.simpleMessage("Editing To Do"),
    "educationCertificate": MessageLookupByLibrary.simpleMessage(
      "Education Certificate",
    ),
    "efficientEventManagement": MessageLookupByLibrary.simpleMessage(
      "Efficient Event Management",
    ),
    "efficientEventManagementBody": MessageLookupByLibrary.simpleMessage(
      "Organize and manage company events seamlessly with the help of our dedicated media team. From sending invitations to gathering feedback, our event management tools ensure every event runs smoothly and successfully.",
    ),
    "effortlessTaskManagement": MessageLookupByLibrary.simpleMessage(
      "Effortless Task Management",
    ),
    "effortlessTaskManagementBody": MessageLookupByLibrary.simpleMessage(
      "Stay on top of your workload with real-time updates and seamless collaboration. Our task management tools ensure everyone knows what needs to be done and when, fostering accountability and efficiency across your team.",
    ),
    "egp": MessageLookupByLibrary.simpleMessage("EGP"),
    "egyptian": MessageLookupByLibrary.simpleMessage("Egyptian"),
    "electrical": MessageLookupByLibrary.simpleMessage("Electrical"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailDoesNotExist": MessageLookupByLibrary.simpleMessage(
      "Email does not exist",
    ),
    "emailRequired": MessageLookupByLibrary.simpleMessage("Email is required"),
    "emailRequired2": MessageLookupByLibrary.simpleMessage("Email Required"),
    "emailsCommaSeparated": MessageLookupByLibrary.simpleMessage(
      "Emails must be comma-separated without spaces or special characters",
    ),
    "emergencyContact": MessageLookupByLibrary.simpleMessage(
      "Emergency Contact",
    ),
    "emergencyContactInformation": MessageLookupByLibrary.simpleMessage(
      "Emergency Contact Information",
    ),
    "emergencyDetails": MessageLookupByLibrary.simpleMessage(
      "Emergency Details",
    ),
    "emergencyVacation": MessageLookupByLibrary.simpleMessage(
      "Emergency Vacation",
    ),
    "emirian": MessageLookupByLibrary.simpleMessage("Emirian"),
    "employee": MessageLookupByLibrary.simpleMessage("Employee"),
    "employeeArabicFirstName": MessageLookupByLibrary.simpleMessage(
      "First Name (Arabic)",
    ),
    "employeeArabicLastName": MessageLookupByLibrary.simpleMessage(
      "Last Name (Arabic)",
    ),
    "employeeArabicMiddleName": MessageLookupByLibrary.simpleMessage(
      "Middle Name (Arabic)",
    ),
    "employeeArabicNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter the name in Arabic",
    ),
    "employeeAssignedInformation": MessageLookupByLibrary.simpleMessage(
      "Employee Assigned Information",
    ),
    "employeeBulkAddRow": MessageLookupByLibrary.simpleMessage("Add row"),
    "employeeBulkAtomicNotice": MessageLookupByLibrary.simpleMessage(
      "No data is saved until every row is valid. The complete upload is committed together.",
    ),
    "employeeBulkConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "This will create all employees, access records, and new departments in one atomic upload.",
    ),
    "employeeBulkConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Create employees?",
    ),
    "employeeBulkDepartmentConflict": MessageLookupByLibrary.simpleMessage(
      "Department ID and names do not identify the same department.",
    ),
    "employeeBulkDropFile": MessageLookupByLibrary.simpleMessage(
      "Drag & Drop files here",
    ),
    "employeeBulkDuplicateEmail": MessageLookupByLibrary.simpleMessage(
      "Email is duplicated in this file.",
    ),
    "employeeBulkDuplicateEmployeeId": MessageLookupByLibrary.simpleMessage(
      "Employee ID is duplicated in this file.",
    ),
    "employeeBulkDuplicateRow": MessageLookupByLibrary.simpleMessage(
      "Duplicate selected",
    ),
    "employeeBulkEmptyWorkbook": MessageLookupByLibrary.simpleMessage(
      "The workbook does not contain a usable worksheet.",
    ),
    "employeeBulkExistingEmail": MessageLookupByLibrary.simpleMessage(
      "Email already belongs to an employee.",
    ),
    "employeeBulkExistingEmployeeId": MessageLookupByLibrary.simpleMessage(
      "Employee ID already exists.",
    ),
    "employeeBulkExistingUnaffected": MessageLookupByLibrary.simpleMessage(
      "Existing employees will not be updated.",
    ),
    "employeeBulkFileGuidance": MessageLookupByLibrary.simpleMessage(
      "Use the exact employee template headers. Maximum 50 employees.",
    ),
    "employeeBulkFileReadFailure": MessageLookupByLibrary.simpleMessage(
      "The selected file could not be read. Please choose it again.",
    ),
    "employeeBulkHeaderMismatch": MessageLookupByLibrary.simpleMessage(
      "The spreadsheet headers must exactly match the employee template and order.",
    ),
    "employeeBulkInvalidGender": MessageLookupByLibrary.simpleMessage(
      "Gender must be male or female.",
    ),
    "employeeBulkInvalidList": MessageLookupByLibrary.simpleMessage(
      "Use unique comma-separated values without empty items.",
    ),
    "employeeBulkInvalidMaritalStatus": MessageLookupByLibrary.simpleMessage(
      "Martial Status must be single, married, divorced, or widowed.",
    ),
    "employeeBulkInvalidNationalId": MessageLookupByLibrary.simpleMessage(
      "National ID must contain 9 to 14 digits.",
    ),
    "employeeBulkInvalidPassport": MessageLookupByLibrary.simpleMessage(
      "Passport must contain 8 to 11 letters or digits.",
    ),
    "employeeBulkInvalidPostalCode": MessageLookupByLibrary.simpleMessage(
      "Enter a valid postal code.",
    ),
    "employeeBulkInvalidWorkbook": MessageLookupByLibrary.simpleMessage(
      "The Excel file could not be read. It may be corrupted or invalid.",
    ),
    "employeeBulkNextError": MessageLookupByLibrary.simpleMessage("Next error"),
    "employeeBulkNoDroppedFiles": MessageLookupByLibrary.simpleMessage(
      "No files were dropped.",
    ),
    "employeeBulkNoRows": MessageLookupByLibrary.simpleMessage(
      "The spreadsheet does not contain employee rows.",
    ),
    "employeeBulkNullNotAllowed": MessageLookupByLibrary.simpleMessage(
      "The literal value null is not allowed.",
    ),
    "employeeBulkPreflightFailure": MessageLookupByLibrary.simpleMessage(
      "Current employee, role, or department data could not be verified. No changes were saved.",
    ),
    "employeeBulkRemoveRows": MessageLookupByLibrary.simpleMessage(
      "Remove selected",
    ),
    "employeeBulkReplaceFile": MessageLookupByLibrary.simpleMessage(
      "Replace file",
    ),
    "employeeBulkRoleNotFound": MessageLookupByLibrary.simpleMessage(
      "Role does not exist or is inactive.",
    ),
    "employeeBulkRowLimit": MessageLookupByLibrary.simpleMessage(
      "A bulk upload can contain at most 50 employees.",
    ),
    "employeeBulkSupervisorNotFound": MessageLookupByLibrary.simpleMessage(
      "Supervisor email was not found.",
    ),
    "employeeBulkTotalEmployees": MessageLookupByLibrary.simpleMessage(
      "Total employees",
    ),
    "employeeBulkTotalErrors": MessageLookupByLibrary.simpleMessage(
      "Total errors",
    ),
    "employeeBulkUnsupportedFile": MessageLookupByLibrary.simpleMessage(
      "Only Excel files (.xlsx or .xls) are supported.",
    ),
    "employeeBulkUploadAction": MessageLookupByLibrary.simpleMessage(
      "Upload employees",
    ),
    "employeeBulkUploadFailure": MessageLookupByLibrary.simpleMessage(
      "The upload failed and no changes were saved.",
    ),
    "employeeBulkUploadSuccess": MessageLookupByLibrary.simpleMessage(
      "Employees uploaded successfully.",
    ),
    "employeeBulkUploadTitle": MessageLookupByLibrary.simpleMessage(
      "Bulk Upload Employees",
    ),
    "employeeCreatedButRefreshFailed": MessageLookupByLibrary.simpleMessage(
      "The employee was created, but the list could not be refreshed",
    ),
    "employeeCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Employee Created Successfully",
    ),
    "employeeCreatedSuccessfullyDescription":
        MessageLookupByLibrary.simpleMessage(
          "The new employee has been added to your organization.",
        ),
    "employeeCreationFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to create the employee",
    ),
    "employeeDetails": MessageLookupByLibrary.simpleMessage("Employee Details"),
    "employeeDetailsUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Employee details updated successfully",
    ),
    "employeeEmail": MessageLookupByLibrary.simpleMessage("Employee Email"),
    "employeeEnglishFirstName": MessageLookupByLibrary.simpleMessage(
      "First Name (English)",
    ),
    "employeeEnglishLastName": MessageLookupByLibrary.simpleMessage(
      "Last Name (English)",
    ),
    "employeeEnglishMiddleName": MessageLookupByLibrary.simpleMessage(
      "Middle Name (English)",
    ),
    "employeeEnglishNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter the name in English",
    ),
    "employeeFileUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to upload the employee\'s files",
    ),
    "employeeGrade": MessageLookupByLibrary.simpleMessage("Employee Grade"),
    "employeeId": MessageLookupByLibrary.simpleMessage("Employee ID"),
    "employeeIdAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "This employee ID is already registered",
    ),
    "employeeInfo": MessageLookupByLibrary.simpleMessage("Employee Info"),
    "employeeInformation": MessageLookupByLibrary.simpleMessage(
      "Employee Information",
    ),
    "employeeJobTitleRequired": MessageLookupByLibrary.simpleMessage(
      "Job title is required",
    ),
    "employeeMessages": MessageLookupByLibrary.simpleMessage(
      "Employee Messages",
    ),
    "employeeName": MessageLookupByLibrary.simpleMessage("Employee Name"),
    "employeeOperations": MessageLookupByLibrary.simpleMessage(
      "Employee Operations",
    ),
    "employeePhone": MessageLookupByLibrary.simpleMessage("Employee Phone"),
    "employeeProfile": MessageLookupByLibrary.simpleMessage("Employee Profile"),
    "employeeRemoved": MessageLookupByLibrary.simpleMessage("Employee Removed"),
    "employeeRoleRequired": MessageLookupByLibrary.simpleMessage(
      "Employee role is required",
    ),
    "employeeSelfService": MessageLookupByLibrary.simpleMessage(
      "Employee Self Service",
    ),
    "employeeStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "employeeStatusAll": MessageLookupByLibrary.simpleMessage("All"),
    "employeeStatusDeactivated": MessageLookupByLibrary.simpleMessage(
      "Deactivated",
    ),
    "employeeStatusInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "employeeStatusLocked": MessageLookupByLibrary.simpleMessage("Locked"),
    "employeeStatusLockedWithRequest": MessageLookupByLibrary.simpleMessage(
      "Locked with Send Request",
    ),
    "employeeStatusResetPassword": MessageLookupByLibrary.simpleMessage(
      "Request to Reset Password",
    ),
    "employeeStatusWillBeActivated": MessageLookupByLibrary.simpleMessage(
      "Scheduled Activation",
    ),
    "employeeStatusWillBeDeactivated": MessageLookupByLibrary.simpleMessage(
      "Scheduled Deactivation",
    ),
    "employees": MessageLookupByLibrary.simpleMessage("Employees"),
    "employeesAdded": MessageLookupByLibrary.simpleMessage("Employees Added"),
    "employeesAttendance": MessageLookupByLibrary.simpleMessage(
      "Employees Attendance",
    ),
    "employeesMatches": MessageLookupByLibrary.simpleMessage(
      "Employees Matches",
    ),
    "employeesPerLocation": MessageLookupByLibrary.simpleMessage(
      "Employees per Location",
    ),
    "employeesTerminated": MessageLookupByLibrary.simpleMessage(
      "Employees Terminated",
    ),
    "emptyControlNameBetweenCommas": MessageLookupByLibrary.simpleMessage(
      "Empty control name between commas",
    ),
    "emptyDepartment": MessageLookupByLibrary.simpleMessage(
      "Empty department between commas",
    ),
    "emptyEmail": MessageLookupByLibrary.simpleMessage(
      "Empty email between commas",
    ),
    "enableDrawerReordering": MessageLookupByLibrary.simpleMessage(
      "Enable Drawer Reordering",
    ),
    "endDate": MessageLookupByLibrary.simpleMessage("End Date"),
    "endDateBeforeStartDate": MessageLookupByLibrary.simpleMessage(
      "End date must not be before start date.",
    ),
    "endDateCannotBeAfterThePolicyEndDate":
        MessageLookupByLibrary.simpleMessage(
          "End date cannot be after the policy end date",
        ),
    "endDateCannotBeBeforeStartDate": MessageLookupByLibrary.simpleMessage(
      "End date cannot be before start date",
    ),
    "endDateCannotBeBeforeThePolicyStartDate":
        MessageLookupByLibrary.simpleMessage(
          "End date cannot be before the policy start date",
        ),
    "endDateMustBeAfterStartDate": MessageLookupByLibrary.simpleMessage(
      "End date must be after start date",
    ),
    "endTime": MessageLookupByLibrary.simpleMessage("End Time"),
    "end_date": MessageLookupByLibrary.simpleMessage("End Date"),
    "enddatemustbeafterstartdate": MessageLookupByLibrary.simpleMessage(
      "End date must be after start date",
    ),
    "endtimemustbeafterstarttime": MessageLookupByLibrary.simpleMessage(
      "End time must be after start time",
    ),
    "engaged": MessageLookupByLibrary.simpleMessage("Engaged"),
    "engineering": MessageLookupByLibrary.simpleMessage("Engineering"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "englishLanguageMandatory": MessageLookupByLibrary.simpleMessage(
      "English Language Mandatory",
    ),
    "englishName": MessageLookupByLibrary.simpleMessage("English Name"),
    "englishNotAllowed": MessageLookupByLibrary.simpleMessage(
      "English not allowed",
    ),
    "englishOnly": MessageLookupByLibrary.simpleMessage("English letters only"),
    "ensureAllEquipmentIsFunctional": MessageLookupByLibrary.simpleMessage(
      "Ensure all equipment is functional.",
    ),
    "ensureAllSecurityProtocolsAreFollowed":
        MessageLookupByLibrary.simpleMessage(
          "Ensure all security protocols are followed.",
        ),
    "ensureRoomTemperatureRemainsStable": MessageLookupByLibrary.simpleMessage(
      "Ensure room temperature remains stable.",
    ),
    "enterApprovalJustification": MessageLookupByLibrary.simpleMessage(
      "Enter approval justification here...",
    ),
    "enterCity": MessageLookupByLibrary.simpleMessage("Enter City"),
    "enterCompanyName": MessageLookupByLibrary.simpleMessage(
      "Enter Company Name",
    ),
    "enterContactRelation": MessageLookupByLibrary.simpleMessage(
      "Enter Contact Relation",
    ),
    "enterCountry": MessageLookupByLibrary.simpleMessage("Enter Country"),
    "enterDefaultPassword": MessageLookupByLibrary.simpleMessage(
      "Enter Default Password",
    ),
    "enterDescription": MessageLookupByLibrary.simpleMessage(
      "Enter Description",
    ),
    "enterEmail": MessageLookupByLibrary.simpleMessage("Enter Email"),
    "enterExpirationTime": MessageLookupByLibrary.simpleMessage(
      "Enter Expiration Time",
    ),
    "enterFileName": MessageLookupByLibrary.simpleMessage("Enter file name"),
    "enterFirstName": MessageLookupByLibrary.simpleMessage("Enter First Name"),
    "enterHobby": MessageLookupByLibrary.simpleMessage("Enter Hobby"),
    "enterInsuranceName": MessageLookupByLibrary.simpleMessage(
      "Enter Insurance Name",
    ),
    "enterInsurancePoliceNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Insurance Police Number",
    ),
    "enterLanguage": MessageLookupByLibrary.simpleMessage("Enter Language"),
    "enterLastName": MessageLookupByLibrary.simpleMessage("Enter Last Name"),
    "enterMiddleName": MessageLookupByLibrary.simpleMessage(
      "Enter Middle Name",
    ),
    "enterNewEmail": MessageLookupByLibrary.simpleMessage("Enter New Email"),
    "enterNewPassword": MessageLookupByLibrary.simpleMessage(
      "Enter New Password",
    ),
    "enterOldPassword": MessageLookupByLibrary.simpleMessage(
      "Enter Old Password",
    ),
    "enterOrderId": MessageLookupByLibrary.simpleMessage("Enter Order ID"),
    "enterPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Phone Number",
    ),
    "enterPolicyNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Policy Number",
    ),
    "enterPostalCode": MessageLookupByLibrary.simpleMessage(
      "Enter Postal Code",
    ),
    "enterRejectionReason": MessageLookupByLibrary.simpleMessage(
      "Enter rejection reason here...",
    ),
    "enterSkill": MessageLookupByLibrary.simpleMessage("Enter Skill"),
    "enterStateOrProvince": MessageLookupByLibrary.simpleMessage(
      "Enter State Or Province",
    ),
    "enterStreetAddress": MessageLookupByLibrary.simpleMessage(
      "Enter Street Address",
    ),
    "enterTaxNumber": MessageLookupByLibrary.simpleMessage("Enter Tax Number"),
    "enterTheArabicFirstName": MessageLookupByLibrary.simpleMessage(
      "Enter The Arabic First Name",
    ),
    "enterTheArabicLastName": MessageLookupByLibrary.simpleMessage(
      "Enter The Arabic Last Name",
    ),
    "enterTheArabicMiddleName": MessageLookupByLibrary.simpleMessage(
      "Enter The Arabic Middle Name",
    ),
    "enterTheCity": MessageLookupByLibrary.simpleMessage("Enter The City"),
    "enterTheCountry": MessageLookupByLibrary.simpleMessage(
      "Enter The Country",
    ),
    "enterTheEmail": MessageLookupByLibrary.simpleMessage("Enter The Email"),
    "enterTheFirstName": MessageLookupByLibrary.simpleMessage(
      "Enter The First Name",
    ),
    "enterTheLastName": MessageLookupByLibrary.simpleMessage(
      "Enter The Last Name",
    ),
    "enterTheMiddleName": MessageLookupByLibrary.simpleMessage(
      "Enter The Middle Name",
    ),
    "enterTheNationalID": MessageLookupByLibrary.simpleMessage(
      "Enter The National ID",
    ),
    "enterTheNationalIDExpirationDate": MessageLookupByLibrary.simpleMessage(
      "Enter The National ID Expiration Date",
    ),
    "enterThePeriod": MessageLookupByLibrary.simpleMessage("Enter The Period"),
    "enterThePhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Enter The Phone Number",
    ),
    "enterThePostalCode": MessageLookupByLibrary.simpleMessage(
      "Enter The Postal Code",
    ),
    "enterTheStateOrProvince": MessageLookupByLibrary.simpleMessage(
      "Enter The State Or Province",
    ),
    "enterTheWorkDays": MessageLookupByLibrary.simpleMessage(
      "Enter The Work Days",
    ),
    "enterYourCity": MessageLookupByLibrary.simpleMessage("Enter Your City"),
    "enterYourCountry": MessageLookupByLibrary.simpleMessage(
      "Enter Your Country",
    ),
    "enterYourEmail": MessageLookupByLibrary.simpleMessage("Enter Your Email"),
    "enterYourFirstName": MessageLookupByLibrary.simpleMessage(
      "Enter Your First Name",
    ),
    "enterYourLastName": MessageLookupByLibrary.simpleMessage(
      "Enter Your Last Name",
    ),
    "enterYourMiddleName": MessageLookupByLibrary.simpleMessage(
      "Enter Your Middle Name",
    ),
    "enterYourMobileNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Your Mobile Number",
    ),
    "enterYourMobilePhone": MessageLookupByLibrary.simpleMessage(
      "Enter Your Mobile Phone",
    ),
    "enterYourPassword": MessageLookupByLibrary.simpleMessage(
      "Enter Your Password",
    ),
    "enterYourStateOrProvince": MessageLookupByLibrary.simpleMessage(
      "Enter Your State Or Province",
    ),
    "enterYourStreetAddress": MessageLookupByLibrary.simpleMessage(
      "Enter Your Street Address",
    ),
    "enter_bug_details": MessageLookupByLibrary.simpleMessage(
      "Enter bug details",
    ),
    "enter_your_comments": MessageLookupByLibrary.simpleMessage(
      "Enter your comments",
    ),
    "enterbirthday": MessageLookupByLibrary.simpleMessage(
      "Enter Your Birth Date",
    ),
    "enterhexacolor": MessageLookupByLibrary.simpleMessage("Enter Hex Code"),
    "entersCountry": MessageLookupByLibrary.simpleMessage("Enters Country"),
    "entryDate": MessageLookupByLibrary.simpleMessage("Entry Date"),
    "equalControlWeight": MessageLookupByLibrary.simpleMessage(
      "Equal Control Weight",
    ),
    "equalPolicyWeight": MessageLookupByLibrary.simpleMessage(
      "Equal Policy Weight",
    ),
    "equalWeight": MessageLookupByLibrary.simpleMessage("Equal Weight"),
    "equalWeights": MessageLookupByLibrary.simpleMessage("Equal Weights"),
    "equatorialGuinean": MessageLookupByLibrary.simpleMessage(
      "Equatorial Guinean",
    ),
    "equipmentAvailable": MessageLookupByLibrary.simpleMessage(
      "Equipment Available",
    ),
    "equipmentAvailableRequired": MessageLookupByLibrary.simpleMessage(
      "Equipment Available is required",
    ),
    "equipmentCheck": MessageLookupByLibrary.simpleMessage("Equipment Check"),
    "eritrean": MessageLookupByLibrary.simpleMessage("Eritrean"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorApprovingDocument": MessageLookupByLibrary.simpleMessage(
      "Error approving document",
    ),
    "errorLoadingAnalytics": MessageLookupByLibrary.simpleMessage(
      "Error loading analytics",
    ),
    "errorLoadingApprovals": MessageLookupByLibrary.simpleMessage(
      "Error loading approvals",
    ),
    "errorLoadingDashboard": MessageLookupByLibrary.simpleMessage(
      "Error loading dashboard",
    ),
    "errorLoadingData": MessageLookupByLibrary.simpleMessage(
      "Error loading data",
    ),
    "errorLoadingNotifications": MessageLookupByLibrary.simpleMessage(
      "Error loading notifications",
    ),
    "errorLoadingServices": MessageLookupByLibrary.simpleMessage(
      "Error loading services",
    ),
    "errorLoadingStatistics": MessageLookupByLibrary.simpleMessage(
      "Error loading statistics",
    ),
    "errorLoadingSubmissions": MessageLookupByLibrary.simpleMessage(
      "Error Loading Submissions",
    ),
    "errorLoadingTasks": MessageLookupByLibrary.simpleMessage(
      "Error loading tasks",
    ),
    "errorOccuredPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Error Occured, Please try again",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Error occurred"),
    "errorRejectingDocument": MessageLookupByLibrary.simpleMessage(
      "Error rejecting document",
    ),
    "errorSubmittingRequest": MessageLookupByLibrary.simpleMessage(
      "Error submitting request",
    ),
    "errorSubmittingToFirebase": MessageLookupByLibrary.simpleMessage(
      "Error submitting to Firebase",
    ),
    "error_downloading_file": MessageLookupByLibrary.simpleMessage(
      "Error Downloading File",
    ),
    "error_loading": MessageLookupByLibrary.simpleMessage("Error loading"),
    "error_opening_download_link": MessageLookupByLibrary.simpleMessage(
      "Could not open download link",
    ),
    "error_opening_file": MessageLookupByLibrary.simpleMessage(
      "Could not open file",
    ),
    "error_viewing_file": MessageLookupByLibrary.simpleMessage(
      "Error Viewing File",
    ),
    "escalateToSupervisor": MessageLookupByLibrary.simpleMessage(
      "Escalate to Supervisor",
    ),
    "escalates": MessageLookupByLibrary.simpleMessage("Escalates"),
    "estimatedCompletionDate": MessageLookupByLibrary.simpleMessage(
      "Estimated Completion Date",
    ),
    "estonian": MessageLookupByLibrary.simpleMessage("Estonian"),
    "ethiopian": MessageLookupByLibrary.simpleMessage("Ethiopian"),
    "eur": MessageLookupByLibrary.simpleMessage("EUR"),
    "events": MessageLookupByLibrary.simpleMessage("Events"),
    "everyTime": MessageLookupByLibrary.simpleMessage("Every Time"),
    "evidenceSubmitted": MessageLookupByLibrary.simpleMessage(
      "Evidence Submitted",
    ),
    "excelNotAccepted": MessageLookupByLibrary.simpleMessage(
      "The Excel file is not accepted.",
    ),
    "excused": MessageLookupByLibrary.simpleMessage("Excused"),
    "excusedConference": MessageLookupByLibrary.simpleMessage(
      "Excused – Conference",
    ),
    "excusedUrgentPersonal": MessageLookupByLibrary.simpleMessage(
      "Excused – Urgent Personal",
    ),
    "excusedWorkshop": MessageLookupByLibrary.simpleMessage(
      "Excused – Workshop",
    ),
    "executive": MessageLookupByLibrary.simpleMessage("Executive Management"),
    "existingBatch": MessageLookupByLibrary.simpleMessage("Existing Batch"),
    "existingBatchRestockTitle": MessageLookupByLibrary.simpleMessage(
      "Restocking Existing Batch",
    ),
    "existingProduct": MessageLookupByLibrary.simpleMessage("Existing Product"),
    "expand": MessageLookupByLibrary.simpleMessage("Expand"),
    "expandCalendar": MessageLookupByLibrary.simpleMessage("Expand Calendar"),
    "expandTools": MessageLookupByLibrary.simpleMessage("Expand Toggle Panel"),
    "expansion": MessageLookupByLibrary.simpleMessage("Expansion"),
    "expectedDelivery": MessageLookupByLibrary.simpleMessage(
      "Expected Delivery",
    ),
    "expectedDeliveryDate": MessageLookupByLibrary.simpleMessage(
      "Expected Delivery Date",
    ),
    "expectedLifetime": MessageLookupByLibrary.simpleMessage(
      "Expected Lifetime",
    ),
    "expectedLifetimeEnded": MessageLookupByLibrary.simpleMessage(
      "Expected Lifetime Ended",
    ),
    "expectedPickUpDate": MessageLookupByLibrary.simpleMessage(
      "Expected Pick Up Date",
    ),
    "expectedPickUpTime": MessageLookupByLibrary.simpleMessage(
      "Expected Pick Up Time",
    ),
    "expectedReturn": MessageLookupByLibrary.simpleMessage("Expected Return"),
    "expectedReturnDate": MessageLookupByLibrary.simpleMessage(
      "Expected Return Date",
    ),
    "expenseClaim": MessageLookupByLibrary.simpleMessage("Expense Claim"),
    "expenses": MessageLookupByLibrary.simpleMessage("Expenses"),
    "experienceDataUnavailable": MessageLookupByLibrary.simpleMessage(
      "Experience data is unavailable",
    ),
    "experienceInOrganization": MessageLookupByLibrary.simpleMessage(
      "Experience in Organization",
    ),
    "expert": MessageLookupByLibrary.simpleMessage("Expert"),
    "expirationDate": MessageLookupByLibrary.simpleMessage("Expiration Date"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Expiration Time"),
    "expirationTimeOfPassword": MessageLookupByLibrary.simpleMessage(
      "Expiration Time of Password",
    ),
    "expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "expiringSoon": MessageLookupByLibrary.simpleMessage("Expiring Soon"),
    "expiryDateMustBeInTheFuture": MessageLookupByLibrary.simpleMessage(
      "Expiry Date Must Be in the Future",
    ),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "exportAnalyticsData": MessageLookupByLibrary.simpleMessage(
      "Export Analytics Data",
    ),
    "exportCRMReports": MessageLookupByLibrary.simpleMessage(
      "Export CRM Reports",
    ),
    "exportContacts": MessageLookupByLibrary.simpleMessage("Export Contacts"),
    "exportCsv": MessageLookupByLibrary.simpleMessage("Export CSV"),
    "exportData": MessageLookupByLibrary.simpleMessage("Export Data"),
    "exportDetails": MessageLookupByLibrary.simpleMessage("Export Details"),
    "exportEmployeeData": MessageLookupByLibrary.simpleMessage(
      "Export Employee Data",
    ),
    "exportFailed": MessageLookupByLibrary.simpleMessage("Export Failed"),
    "exportHRReports": MessageLookupByLibrary.simpleMessage(
      "Export HR Reports",
    ),
    "exportRequestedServices": MessageLookupByLibrary.simpleMessage(
      "Export Requested Services",
    ),
    "exportRoleData": MessageLookupByLibrary.simpleMessage("Export Role Data"),
    "exportRoles": MessageLookupByLibrary.simpleMessage("Export Roles"),
    "exportService": MessageLookupByLibrary.simpleMessage("Export Service"),
    "exportStatisticsTable": MessageLookupByLibrary.simpleMessage(
      "Export Statistics Table",
    ),
    "exportSubmissionData": MessageLookupByLibrary.simpleMessage(
      "Export Submission Data",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exported successfully. You have successfully exported this file.",
    ),
    "exportSuccessful": MessageLookupByLibrary.simpleMessage(
      "Export Successful",
    ),
    "exportUserManagement": MessageLookupByLibrary.simpleMessage(
      "Export User Management",
    ),
    "exportUsersData": MessageLookupByLibrary.simpleMessage(
      "Export Users Data",
    ),
    "exported": MessageLookupByLibrary.simpleMessage("Exported"),
    "exporting": MessageLookupByLibrary.simpleMessage("Exporting..."),
    "extension": MessageLookupByLibrary.simpleMessage("Extension"),
    "extensionRequired": MessageLookupByLibrary.simpleMessage(
      "Extension Required",
    ),
    "external": MessageLookupByLibrary.simpleMessage("External"),
    "extraSpaces": MessageLookupByLibrary.simpleMessage(
      "Only one space allowed between words",
    ),
    "failedToAddComment": MessageLookupByLibrary.simpleMessage(
      "Failed to add comment",
    ),
    "failedToCreateKnowledgeHub": MessageLookupByLibrary.simpleMessage(
      "Failed to create knowledge hub",
    ),
    "failedToCreateServiceRequest": MessageLookupByLibrary.simpleMessage(
      "Failed to create service request. Please try again.",
    ),
    "failedToDownloadFile": MessageLookupByLibrary.simpleMessage(
      "FailedToDownloadFile",
    ),
    "failedToLoadDepartments": MessageLookupByLibrary.simpleMessage(
      "Failed to load departments",
    ),
    "failedToLoadServiceData": MessageLookupByLibrary.simpleMessage(
      "Failed to load service data",
    ),
    "failedToPickImage": MessageLookupByLibrary.simpleMessage(
      "Failed to pick image",
    ),
    "failedToRemoveUserAccessPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Failed to remove user access. Please try again.",
        ),
    "failedToSaveDraftPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Failed to save draft. Please try again.",
    ),
    "failedToSaveRolePleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Failed to save the role. Please try again.",
    ),
    "failedToUpdateAccess": MessageLookupByLibrary.simpleMessage(
      "Failed to update access",
    ),
    "failedToUpdateKnowledgeHub": MessageLookupByLibrary.simpleMessage(
      "Failed to update knowledge hub",
    ),
    "failedToUpdateProduct": MessageLookupByLibrary.simpleMessage(
      "Failed to update product",
    ),
    "family": MessageLookupByLibrary.simpleMessage("Family"),
    "faxNumber": MessageLookupByLibrary.simpleMessage("Fax Number"),
    "faxNumberRequired": MessageLookupByLibrary.simpleMessage(
      "Fax number is required.",
    ),
    "feb": MessageLookupByLibrary.simpleMessage("Feb"),
    "feedbackClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "feedbackFixed": MessageLookupByLibrary.simpleMessage("Fixed"),
    "female": MessageLookupByLibrary.simpleMessage("Female"),
    "fieldMustContainArabicCharacters": MessageLookupByLibrary.simpleMessage(
      "Field must contain Arabic characters",
    ),
    "fieldMustContainEnglishCharacters": MessageLookupByLibrary.simpleMessage(
      "Field must contain English characters",
    ),
    "fieldMustContainOnlyArabicCharacters":
        MessageLookupByLibrary.simpleMessage(
          "Field must contain only Arabic characters",
        ),
    "fieldMustContainOnlyEnglishCharacters":
        MessageLookupByLibrary.simpleMessage(
          "Field must contain only English characters",
        ),
    "fieldOfStudy": MessageLookupByLibrary.simpleMessage("Field of Study"),
    "fieldRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required.",
    ),
    "fieldTypeAddress": MessageLookupByLibrary.simpleMessage("Address"),
    "fieldTypeAttachment": MessageLookupByLibrary.simpleMessage("Attachment"),
    "fieldTypeCheckBox": MessageLookupByLibrary.simpleMessage("Check Box"),
    "fieldTypeDateSelector": MessageLookupByLibrary.simpleMessage(
      "Date Selector",
    ),
    "fieldTypeDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "fieldTypeDigitalSignature": MessageLookupByLibrary.simpleMessage(
      "Attached Digital Signature",
    ),
    "fieldTypeDropDown": MessageLookupByLibrary.simpleMessage("Drop Down"),
    "fieldTypeEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "fieldTypeImage": MessageLookupByLibrary.simpleMessage("Image"),
    "fieldTypeLink": MessageLookupByLibrary.simpleMessage("Link"),
    "fieldTypeLocation": MessageLookupByLibrary.simpleMessage("Location"),
    "fieldTypePhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "fieldTypeRadio": MessageLookupByLibrary.simpleMessage("Radio"),
    "fieldTypeRadioTextField": MessageLookupByLibrary.simpleMessage(
      "Radio - Text Field",
    ),
    "fieldTypeTermsAndCondition": MessageLookupByLibrary.simpleMessage(
      "Terms And Condition",
    ),
    "fieldTypeTextField": MessageLookupByLibrary.simpleMessage("Text Field"),
    "fieldTypeTimeSelector": MessageLookupByLibrary.simpleMessage(
      "Time Selector",
    ),
    "fieldTypeTitle": MessageLookupByLibrary.simpleMessage("Title"),
    "fields": MessageLookupByLibrary.simpleMessage("Fields"),
    "fijian": MessageLookupByLibrary.simpleMessage("Fijian"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDate": MessageLookupByLibrary.simpleMessage("Date"),
    "fileDownloadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File downloaded successfully",
    ),
    "fileFormat": MessageLookupByLibrary.simpleMessage("File Format"),
    "fileName": MessageLookupByLibrary.simpleMessage("File Name"),
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File saved successfully",
    ),
    "fileSize": MessageLookupByLibrary.simpleMessage("File Size"),
    "filipino": MessageLookupByLibrary.simpleMessage("Filipino"),
    "fillAllRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Please fill all required fields",
    ),
    "fillAtLeastTwoOptions": MessageLookupByLibrary.simpleMessage(
      "Fill at least two options",
    ),
    "fillOutForm": MessageLookupByLibrary.simpleMessage("Fill Out Form"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filter_by_department": MessageLookupByLibrary.simpleMessage(
      "Filter by Department",
    ),
    "finalAmount": MessageLookupByLibrary.simpleMessage("Final Amount"),
    "finalizing": MessageLookupByLibrary.simpleMessage("Finalizing..."),
    "finance": MessageLookupByLibrary.simpleMessage("Finance"),
    "financeDepartment": MessageLookupByLibrary.simpleMessage(
      "Finance Department",
    ),
    "financeOfficer": MessageLookupByLibrary.simpleMessage("Finance Officer"),
    "financialService": MessageLookupByLibrary.simpleMessage(
      "Financial Service",
    ),
    "finnish": MessageLookupByLibrary.simpleMessage("Finnish"),
    "fireSafety": MessageLookupByLibrary.simpleMessage("Fire Safety"),
    "firstBackup": MessageLookupByLibrary.simpleMessage("First Backup"),
    "firstEmergencyContact": MessageLookupByLibrary.simpleMessage(
      "First Emergency Contact",
    ),
    "firstLogin": MessageLookupByLibrary.simpleMessage("First Login"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "firstNameMissing": MessageLookupByLibrary.simpleMessage(
      "First Name Missing",
    ),
    "firstNameRequired": MessageLookupByLibrary.simpleMessage(
      "First Name is required",
    ),
    "firstReminder": MessageLookupByLibrary.simpleMessage("First Reminder"),
    "fixed": MessageLookupByLibrary.simpleMessage("Fixed"),
    "fixedBonus": MessageLookupByLibrary.simpleMessage("Fixed + Bonus"),
    "flammableStorage": MessageLookupByLibrary.simpleMessage(
      "Flammable Storage",
    ),
    "flexibleRoleManagement": MessageLookupByLibrary.simpleMessage(
      "Flexible Role Management",
    ),
    "flexibleRoleManagementBody": MessageLookupByLibrary.simpleMessage(
      "Assign and manage roles within your organization effortlessly. Ensure that every team member has the appropriate access and responsibilities to perform their duties effectively.",
    ),
    "fonts": MessageLookupByLibrary.simpleMessage("Fonts"),
    "foodService": MessageLookupByLibrary.simpleMessage("Food Service"),
    "forDirectMessage": MessageLookupByLibrary.simpleMessage(
      "For Direct Message",
    ),
    "forGroup": MessageLookupByLibrary.simpleMessage("For Group"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "forgotPassword2": MessageLookupByLibrary.simpleMessage("Forgot Password"),
    "forklift": MessageLookupByLibrary.simpleMessage("Forklift"),
    "form": MessageLookupByLibrary.simpleMessage("Form"),
    "formBuilder": MessageLookupByLibrary.simpleMessage("Form Builder"),
    "formCreated": MessageLookupByLibrary.simpleMessage("Form Created"),
    "formDetails": MessageLookupByLibrary.simpleMessage("Form Details"),
    "formDownloadAsPdf": MessageLookupByLibrary.simpleMessage(
      "Form Download As PDF",
    ),
    "formName": MessageLookupByLibrary.simpleMessage("Form Name"),
    "formPermissions": MessageLookupByLibrary.simpleMessage("Form Permissions"),
    "formPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Form Permissions Module",
    ),
    "formStatusDeleted": MessageLookupByLibrary.simpleMessage("Deleted"),
    "formStatusDrafts": MessageLookupByLibrary.simpleMessage("Drafts"),
    "formStatusPublish": MessageLookupByLibrary.simpleMessage("Publish"),
    "formStatusRequestedForms": MessageLookupByLibrary.simpleMessage(
      "Requested Forms",
    ),
    "formStatusSubmissions": MessageLookupByLibrary.simpleMessage(
      "Submissions",
    ),
    "formSubmissions": MessageLookupByLibrary.simpleMessage("Form Submissions"),
    "formTitle": MessageLookupByLibrary.simpleMessage("Form Title"),
    "formatCsv": MessageLookupByLibrary.simpleMessage("CSV"),
    "formatExcel": MessageLookupByLibrary.simpleMessage("Excel (.xlsx)"),
    "formatPdf": MessageLookupByLibrary.simpleMessage("PDF"),
    "formresponsivepage": MessageLookupByLibrary.simpleMessage(
      "FormResponsivePage",
    ),
    "forms": MessageLookupByLibrary.simpleMessage("Forms"),
    "formsSubmission": MessageLookupByLibrary.simpleMessage("Forms Submission"),
    "forwardMessage": MessageLookupByLibrary.simpleMessage("Forward Message"),
    "forwardMessages": MessageLookupByLibrary.simpleMessage("Forward Messages"),
    "forwardTo": MessageLookupByLibrary.simpleMessage("Forward to"),
    "fragileHandleWithCare": MessageLookupByLibrary.simpleMessage(
      "Fragile – Handle with Care",
    ),
    "frame_work": MessageLookupByLibrary.simpleMessage("Frame Work"),
    "framework": MessageLookupByLibrary.simpleMessage("Framework"),
    "french": MessageLookupByLibrary.simpleMessage("French"),
    "freqAbbreviation": MessageLookupByLibrary.simpleMessage("Freq"),
    "frequency": MessageLookupByLibrary.simpleMessage("Frequency"),
    "frequencyAnnually": MessageLookupByLibrary.simpleMessage("Annually"),
    "frequencyBiweekly": MessageLookupByLibrary.simpleMessage("Biweekly"),
    "frequencyContinuousRealTime": MessageLookupByLibrary.simpleMessage(
      "Continuous / Real-Time",
    ),
    "frequencyDaily": MessageLookupByLibrary.simpleMessage("Daily"),
    "frequencyMonthly": MessageLookupByLibrary.simpleMessage("Monthly"),
    "frequencyOccasionally": MessageLookupByLibrary.simpleMessage(
      "Occasionally",
    ),
    "frequencyOnDemandAsNeeded": MessageLookupByLibrary.simpleMessage(
      "On Demand / As Needed",
    ),
    "frequencyOneTimeUse": MessageLookupByLibrary.simpleMessage("One-Time Use"),
    "frequencyQuarterly": MessageLookupByLibrary.simpleMessage("Quarterly"),
    "frequencyRarely": MessageLookupByLibrary.simpleMessage("Rarely"),
    "frequencySeasonally": MessageLookupByLibrary.simpleMessage("Seasonally"),
    "frequencyShiftBased": MessageLookupByLibrary.simpleMessage("Shift-Based"),
    "frequentlyContacted": MessageLookupByLibrary.simpleMessage(
      "Frequently Contacted",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Friday"),
    "fridaySaturday": MessageLookupByLibrary.simpleMessage("Friday/Saturday"),
    "friend": MessageLookupByLibrary.simpleMessage("Friend"),
    "from": MessageLookupByLibrary.simpleMessage("From"),
    "frozenStorage": MessageLookupByLibrary.simpleMessage("Frozen Storage"),
    "fullTime": MessageLookupByLibrary.simpleMessage("Full-time"),
    "fullyRemote": MessageLookupByLibrary.simpleMessage("Fully Remote"),
    "gabonese": MessageLookupByLibrary.simpleMessage("Gabonese"),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "gambian": MessageLookupByLibrary.simpleMessage("Gambian"),
    "gbp": MessageLookupByLibrary.simpleMessage("GBP"),
    "gender": MessageLookupByLibrary.simpleMessage("Gender"),
    "genderFieldMustBeEitherMaleFemaleOrOther":
        MessageLookupByLibrary.simpleMessage(
          "Gender field must be either \'male\', \'female\', or \'other\'.",
        ),
    "generalInformation": MessageLookupByLibrary.simpleMessage(
      "General Information",
    ),
    "generalManager": MessageLookupByLibrary.simpleMessage("General Manager"),
    "geofencing": MessageLookupByLibrary.simpleMessage("Geofencing"),
    "geofencingArea": MessageLookupByLibrary.simpleMessage("Geofencing Area"),
    "geofencingPerimeter": MessageLookupByLibrary.simpleMessage(
      "Geofencing perimeter",
    ),
    "georgian": MessageLookupByLibrary.simpleMessage("Georgian"),
    "german": MessageLookupByLibrary.simpleMessage("German"),
    "getStart": MessageLookupByLibrary.simpleMessage("Get Start"),
    "ghanaian": MessageLookupByLibrary.simpleMessage("Ghanaian"),
    "giveAScore": MessageLookupByLibrary.simpleMessage("Give a Score"),
    "giveAccess": MessageLookupByLibrary.simpleMessage("Give Access"),
    "goBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Good Afternoon"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Good Evening"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good Morning"),
    "googleMaps": MessageLookupByLibrary.simpleMessage("Google Maps"),
    "gotIt": MessageLookupByLibrary.simpleMessage("Got it"),
    "governanceRiskCompliance": MessageLookupByLibrary.simpleMessage(
      "Governance, Risk, and Compliance",
    ),
    "gradeOrScore": MessageLookupByLibrary.simpleMessage("Grade or Score"),
    "graduationFrom": MessageLookupByLibrary.simpleMessage("Graduation From"),
    "graduationYear": MessageLookupByLibrary.simpleMessage("Graduation Year"),
    "grantAccess": MessageLookupByLibrary.simpleMessage("Grant Access"),
    "grantAccessSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Grant Access Successfully",
    ),
    "grantedAccess": MessageLookupByLibrary.simpleMessage("Granted Access"),
    "grc": MessageLookupByLibrary.simpleMessage("GRC"),
    "grcFileExported": MessageLookupByLibrary.simpleMessage(
      "Your file has been exported",
    ),
    "grcModuleName": MessageLookupByLibrary.simpleMessage("GRC Module Name"),
    "grcModuleNameArabic": MessageLookupByLibrary.simpleMessage(
      "Governance Framework Title (Arabic)",
    ),
    "grcModuleNameIsRequired": MessageLookupByLibrary.simpleMessage(
      "GRC module name is required",
    ),
    "grcModuleNameMustBeWrittenInArabic": MessageLookupByLibrary.simpleMessage(
      "GRC module name must be written in Arabic",
    ),
    "grcPolicyNumber": MessageLookupByLibrary.simpleMessage(
      "GRC Policy Number",
    ),
    "grcresponsivepage": MessageLookupByLibrary.simpleMessage(
      "GrcResponsivePage",
    ),
    "greek": MessageLookupByLibrary.simpleMessage("Greek"),
    "grenadian": MessageLookupByLibrary.simpleMessage("Grenadian"),
    "group": MessageLookupByLibrary.simpleMessage("Group"),
    "groupCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Group Created Successfully",
    ),
    "groupDetails": MessageLookupByLibrary.simpleMessage("Group Details"),
    "groupInformation": MessageLookupByLibrary.simpleMessage(
      "Group Information",
    ),
    "groupMessages": MessageLookupByLibrary.simpleMessage("Group Messages"),
    "groupName": MessageLookupByLibrary.simpleMessage("Group Name"),
    "groupedBarChart": MessageLookupByLibrary.simpleMessage(
      "Grouped Bar Chart",
    ),
    "groups": MessageLookupByLibrary.simpleMessage("Groups"),
    "groupsCommon": MessageLookupByLibrary.simpleMessage("Groups Common"),
    "groupsInCommon": MessageLookupByLibrary.simpleMessage("Groups in common"),
    "guatemalan": MessageLookupByLibrary.simpleMessage("Guatemalan"),
    "guidelines": MessageLookupByLibrary.simpleMessage("Guidelines"),
    "guineaBissauan": MessageLookupByLibrary.simpleMessage("Guinea-Bissauan"),
    "guinean": MessageLookupByLibrary.simpleMessage("Guinean"),
    "guyanese": MessageLookupByLibrary.simpleMessage("Guyanese"),
    "haitian": MessageLookupByLibrary.simpleMessage("Haitian"),
    "handDelivery": MessageLookupByLibrary.simpleMessage("Hand Delivery"),
    "handPalletTruck": MessageLookupByLibrary.simpleMessage(
      "Hand Pallet Truck (Manual Jack)",
    ),
    "happenedOnce": MessageLookupByLibrary.simpleMessage("Happened Once"),
    "hapticFeedback": MessageLookupByLibrary.simpleMessage("Haptic Feedback"),
    "hazardousMaterialHandlingKit": MessageLookupByLibrary.simpleMessage(
      "Hazardous Material Handling Kit",
    ),
    "hazardousMaterialStorage": MessageLookupByLibrary.simpleMessage(
      "Hazardous Material Storage",
    ),
    "headerMismatch": MessageLookupByLibrary.simpleMessage("Header Mismatch"),
    "headquarters": MessageLookupByLibrary.simpleMessage("Headquarters"),
    "healthInsurance": MessageLookupByLibrary.simpleMessage("Health Insurance"),
    "healthInsuranceBulkDuplicateEmployee":
        MessageLookupByLibrary.simpleMessage(
          "Employee ID is duplicated in this file.",
        ),
    "healthInsuranceBulkEmployeeNotFound": MessageLookupByLibrary.simpleMessage(
      "Employee ID was not found.",
    ),
    "healthInsuranceBulkFailedCount": MessageLookupByLibrary.simpleMessage(
      "Failed rows",
    ),
    "healthInsuranceBulkHeaderMismatch": MessageLookupByLibrary.simpleMessage(
      "The health-insurance workbook headers do not match the required template.",
    ),
    "healthInsuranceBulkIdentityMismatch": MessageLookupByLibrary.simpleMessage(
      "Employee information does not match the stored personal information.",
    ),
    "healthInsuranceBulkPreflightFailure": MessageLookupByLibrary.simpleMessage(
      "Employee information could not be verified. No changes were saved.",
    ),
    "healthInsuranceBulkUpdatedCount": MessageLookupByLibrary.simpleMessage(
      "Updated employees",
    ),
    "healthInsuranceBulkUploadAction": MessageLookupByLibrary.simpleMessage(
      "Upload health insurance",
    ),
    "healthInsuranceBulkUploadPartial": MessageLookupByLibrary.simpleMessage(
      "Some health-insurance rows could not be uploaded.",
    ),
    "healthInsuranceBulkUploadSuccess": MessageLookupByLibrary.simpleMessage(
      "Health-insurance information uploaded successfully.",
    ),
    "healthInsuranceBulkUploadTitle": MessageLookupByLibrary.simpleMessage(
      "Bulk Upload Health Insurance",
    ),
    "healthSafetyEnvironment": MessageLookupByLibrary.simpleMessage(
      "Health, Safety, and Environment",
    ),
    "heavyDutyStorage": MessageLookupByLibrary.simpleMessage(
      "Heavy-Duty Storage",
    ),
    "hebrewLanguage": MessageLookupByLibrary.simpleMessage("Hebrew"),
    "herzegovinian": MessageLookupByLibrary.simpleMessage("Herzegovinian"),
    "hide": MessageLookupByLibrary.simpleMessage("Hide"),
    "hideFormDetails": MessageLookupByLibrary.simpleMessage(
      "Hide form details",
    ),
    "high": MessageLookupByLibrary.simpleMessage("High"),
    "highSchool": MessageLookupByLibrary.simpleMessage("High School"),
    "hindi": MessageLookupByLibrary.simpleMessage("Hindi"),
    "hindiLanguage": MessageLookupByLibrary.simpleMessage("Hindi"),
    "hiredOn": MessageLookupByLibrary.simpleMessage("Hired On"),
    "historyControlOwners": MessageLookupByLibrary.simpleMessage(
      "History Control Owners",
    ),
    "historyOfControlOwners": MessageLookupByLibrary.simpleMessage(
      "History of Control Owners",
    ),
    "historyProductStorage": MessageLookupByLibrary.simpleMessage(
      "History Product Storage",
    ),
    "hobbies": MessageLookupByLibrary.simpleMessage("Hobbies"),
    "hobbys": MessageLookupByLibrary.simpleMessage("Hobbys"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "homeLayout": MessageLookupByLibrary.simpleMessage("Home Layout"),
    "homeNumber": MessageLookupByLibrary.simpleMessage("Home Number"),
    "homePreview": MessageLookupByLibrary.simpleMessage("Home Preview"),
    "homeScreenAllTitle": MessageLookupByLibrary.simpleMessage("All"),
    "homeScreenCreateToDoListTitle": MessageLookupByLibrary.simpleMessage(
      "Create To-Do",
    ),
    "homeScreenEndDateTitle": MessageLookupByLibrary.simpleMessage("End Date"),
    "homeScreenFrequencyTitle": MessageLookupByLibrary.simpleMessage(
      "Frequency",
    ),
    "homeScreenScheduleTitle": MessageLookupByLibrary.simpleMessage("Schedule"),
    "homeScreenSortTitle": MessageLookupByLibrary.simpleMessage("Sort"),
    "homeScreenStartDateTitle": MessageLookupByLibrary.simpleMessage(
      "Start Date",
    ),
    "homeScreenToDoListTitle": MessageLookupByLibrary.simpleMessage(
      "To-Do List",
    ),
    "homepagehelper": MessageLookupByLibrary.simpleMessage("HomePageHelper"),
    "honduran": MessageLookupByLibrary.simpleMessage("Honduran"),
    "horizontalBarChart": MessageLookupByLibrary.simpleMessage(
      "Horizontal bar chart",
    ),
    "horizontalPadding": MessageLookupByLibrary.simpleMessage(
      "Horizontal Padding",
    ),
    "horizontalStackedBarChart": MessageLookupByLibrary.simpleMessage(
      "Horizontal Stacked Bar Chart",
    ),
    "hospitality": MessageLookupByLibrary.simpleMessage("Hospitality"),
    "hour": MessageLookupByLibrary.simpleMessage("Hour"),
    "hourly": MessageLookupByLibrary.simpleMessage("Hourly"),
    "hours": MessageLookupByLibrary.simpleMessage("Hours"),
    "hoursAgo": MessageLookupByLibrary.simpleMessage("Hours Ago"),
    "hr": MessageLookupByLibrary.simpleMessage("HR"),
    "hrApproval": MessageLookupByLibrary.simpleMessage("HR Approval"),
    "hrModule": MessageLookupByLibrary.simpleMessage("HR Module"),
    "hse": MessageLookupByLibrary.simpleMessage(
      "Health, Safety and Environment",
    ),
    "humanResources": MessageLookupByLibrary.simpleMessage("Human Resources"),
    "humidityCheck": MessageLookupByLibrary.simpleMessage("Humidity Check"),
    "humidityControlled": MessageLookupByLibrary.simpleMessage(
      "Humidity-Controlled",
    ),
    "hungarian": MessageLookupByLibrary.simpleMessage("Hungarian"),
    "hybrid": MessageLookupByLibrary.simpleMessage("hybrid"),
    "hybrid2": MessageLookupByLibrary.simpleMessage("Hybrid"),
    "iAgreeToThePrivacyPolicyAndTermsAndConditions":
        MessageLookupByLibrary.simpleMessage(
          "I agree to the Privacy Policy and Terms & Conditions",
        ),
    "iD": MessageLookupByLibrary.simpleMessage("ID"),
    "iDPhoto": MessageLookupByLibrary.simpleMessage("ID Photo"),
    "iKiribati": MessageLookupByLibrary.simpleMessage("I-Kiribati"),
    "iban": MessageLookupByLibrary.simpleMessage(
      "Beneficiary Bank Account Number / IBAN",
    ),
    "ibanRequired": MessageLookupByLibrary.simpleMessage("IBAN is required"),
    "icelander": MessageLookupByLibrary.simpleMessage("Icelander"),
    "icons": MessageLookupByLibrary.simpleMessage("Icons"),
    "iconsImages": MessageLookupByLibrary.simpleMessage("Icons & Images"),
    "identificationDetails": MessageLookupByLibrary.simpleMessage(
      "Identification Details",
    ),
    "ifYouSelectAllRequests": MessageLookupByLibrary.simpleMessage(
      "If you select \'All Requests\', the approval cycle will be applied to all request types.",
    ),
    "ils": MessageLookupByLibrary.simpleMessage("ILS"),
    "image": MessageLookupByLibrary.simpleMessage("Image"),
    "imageAsset": MessageLookupByLibrary.simpleMessage(
      "assets/icons_assets/main_icons_assets/check_circle_green.svg",
    ),
    "imageDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Image deleted successfully",
    ),
    "imageNotFound": MessageLookupByLibrary.simpleMessage("Image not found"),
    "imageUploadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Image uploaded successfully",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importContacts": MessageLookupByLibrary.simpleMessage("Import Contacts"),
    "importUsersData": MessageLookupByLibrary.simpleMessage(
      "Import Users Data",
    ),
    "improvementsToExistingFeature": MessageLookupByLibrary.simpleMessage(
      "Improvements To Existing Feature",
    ),
    "inProgress": MessageLookupByLibrary.simpleMessage("In Progress"),
    "inProgressProjects": MessageLookupByLibrary.simpleMessage(
      "In Progress Projects",
    ),
    "inReview": MessageLookupByLibrary.simpleMessage("In Review"),
    "inServiceDate": MessageLookupByLibrary.simpleMessage("In-Service Date"),
    "inStock": MessageLookupByLibrary.simpleMessage("InStock"),
    "inUse": MessageLookupByLibrary.simpleMessage("In Use"),
    "inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "inactiveForNow": MessageLookupByLibrary.simpleMessage("Inactive For Now"),
    "inactiveRoles": MessageLookupByLibrary.simpleMessage("Inactive Roles"),
    "incidentDate": MessageLookupByLibrary.simpleMessage("Incident Date"),
    "incidentLocation": MessageLookupByLibrary.simpleMessage(
      "Incident Location",
    ),
    "incompleteForm": MessageLookupByLibrary.simpleMessage("Incomplete Form"),
    "incorrectPasswordMessage": MessageLookupByLibrary.simpleMessage(
      "The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you can reset it using the \"Forgot Password\" option.",
    ),
    "indian": MessageLookupByLibrary.simpleMessage("Indian"),
    "indicatesNumberInTable": MessageLookupByLibrary.simpleMessage(
      "Indicates number in table",
    ),
    "indonesian": MessageLookupByLibrary.simpleMessage("Indonesian"),
    "industry": MessageLookupByLibrary.simpleMessage("Industry"),
    "infoOrder": MessageLookupByLibrary.simpleMessage(
      "We are pleased to place a new purchase order with your company. Please find attached the details of our order, including item descriptions, quantities, pricing, and delivery address. Kindly confirm receipt of this order and provide an estimated delivery date. Should you have any questions or need clarification, please do not hesitate to contact us.",
    ),
    "informationTechnology": MessageLookupByLibrary.simpleMessage(
      "Information Technology",
    ),
    "inquires": MessageLookupByLibrary.simpleMessage("Inquiries"),
    "inquiriesAndComments": MessageLookupByLibrary.simpleMessage(
      "Inquiries And Comments",
    ),
    "inquiriesComingSoon": MessageLookupByLibrary.simpleMessage(
      "Inquiries coming soon",
    ),
    "inquiries_and_comments": MessageLookupByLibrary.simpleMessage(
      "Inquiries And Comments",
    ),
    "inr": MessageLookupByLibrary.simpleMessage("INR"),
    "inspectFireExtinguishersAndAlarms": MessageLookupByLibrary.simpleMessage(
      "Inspect fire extinguishers and alarms.",
    ),
    "inspectForAnySignsOfPests": MessageLookupByLibrary.simpleMessage(
      "Inspect for any signs of pests.",
    ),
    "institutionName": MessageLookupByLibrary.simpleMessage("Institution Name"),
    "instock": MessageLookupByLibrary.simpleMessage("New"),
    "insurance": MessageLookupByLibrary.simpleMessage("Insurance"),
    "insuranceDetails": MessageLookupByLibrary.simpleMessage(
      "Insurance Details",
    ),
    "insuranceName": MessageLookupByLibrary.simpleMessage("Insurance Name"),
    "insurancePolicyNumber": MessageLookupByLibrary.simpleMessage(
      "Insurance Policy Number",
    ),
    "insuranceProviderContact": MessageLookupByLibrary.simpleMessage(
      "Insurance Provider Contact",
    ),
    "intermediate": MessageLookupByLibrary.simpleMessage("Intermediate"),
    "intern": MessageLookupByLibrary.simpleMessage("Intern"),
    "internalAccessOnly": MessageLookupByLibrary.simpleMessage(
      "Internal Access Only",
    ),
    "internalAudit": MessageLookupByLibrary.simpleMessage("Internal Audit"),
    "internalSearch": MessageLookupByLibrary.simpleMessage("Internal Search"),
    "invalidBirthDate": MessageLookupByLibrary.simpleMessage(
      "Invalid Birth Date",
    ),
    "invalidCity": MessageLookupByLibrary.simpleMessage("Invalid City"),
    "invalidCountryName": MessageLookupByLibrary.simpleMessage(
      "Invalid Country Name",
    ),
    "invalidCredentialsPleaseVerifyAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Invalid credentials. Please verify and try again.",
        ),
    "invalidData": MessageLookupByLibrary.simpleMessage("Invalid Data"),
    "invalidDate": MessageLookupByLibrary.simpleMessage("Invalid Date"),
    "invalidDepartmentChars": MessageLookupByLibrary.simpleMessage(
      "Only letters, numbers, spaces, and commas are allowed",
    ),
    "invalidDepartmentIDFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid Department ID Format",
    ),
    "invalidEmail": MessageLookupByLibrary.simpleMessage("Invalid Email"),
    "invalidEmailFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid email format",
    ),
    "invalidEmployeeID": MessageLookupByLibrary.simpleMessage(
      "Invalid Employee ID",
    ),
    "invalidEmployeeId": MessageLookupByLibrary.simpleMessage(
      "Invalid employee ID",
    ),
    "invalidExpiryDate": MessageLookupByLibrary.simpleMessage(
      "Invalid Expiry Date",
    ),
    "invalidFirstName": MessageLookupByLibrary.simpleMessage(
      "Invalid First Name",
    ),
    "invalidGender": MessageLookupByLibrary.simpleMessage("Invalid Gender"),
    "invalidLanguage": MessageLookupByLibrary.simpleMessage("Invalid Language"),
    "invalidLastName": MessageLookupByLibrary.simpleMessage(
      "Invalid Last Name",
    ),
    "invalidMiddleName": MessageLookupByLibrary.simpleMessage(
      "Invalid Middle Name",
    ),
    "invalidNationalID": MessageLookupByLibrary.simpleMessage(
      "Invalid National ID",
    ),
    "invalidPassportNumber": MessageLookupByLibrary.simpleMessage(
      "Invalid Passport Number",
    ),
    "invalidPhoneFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid Phone Format",
    ),
    "invalidPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Invalid Phone Number",
    ),
    "invalidPostalCode": MessageLookupByLibrary.simpleMessage(
      "Invalid Postal Code",
    ),
    "invalidProvince": MessageLookupByLibrary.simpleMessage("Invalid Province"),
    "invalidStreet": MessageLookupByLibrary.simpleMessage("Invalid Street"),
    "invalidTimeUnit": MessageLookupByLibrary.simpleMessage(
      "Must be one of: Hours, Days, Seconds, Minutes",
    ),
    "invalidWorkLocation": MessageLookupByLibrary.simpleMessage(
      "Invalid Work Location",
    ),
    "invalidYesNo": MessageLookupByLibrary.simpleMessage(
      "Must be \"yes\" or \"no\"",
    ),
    "inventory": MessageLookupByLibrary.simpleMessage("Inventory"),
    "inventoryAudit": MessageLookupByLibrary.simpleMessage("Inventory Audit"),
    "inventoryDashboard": MessageLookupByLibrary.simpleMessage(
      "Inventory Dashboard",
    ),
    "inventoryManagement": MessageLookupByLibrary.simpleMessage(
      "Inventory Management",
    ),
    "invoice": MessageLookupByLibrary.simpleMessage("Invoice"),
    "invoiceDetails": MessageLookupByLibrary.simpleMessage("Invoice Details"),
    "ios": MessageLookupByLibrary.simpleMessage("iOS"),
    "ipad": MessageLookupByLibrary.simpleMessage("iPad"),
    "ipados": MessageLookupByLibrary.simpleMessage("iPadOS"),
    "iphone": MessageLookupByLibrary.simpleMessage("iPhone"),
    "iqd": MessageLookupByLibrary.simpleMessage("IQD"),
    "iranian": MessageLookupByLibrary.simpleMessage("Iranian"),
    "iraqi": MessageLookupByLibrary.simpleMessage("Iraqi"),
    "irish": MessageLookupByLibrary.simpleMessage("Irish"),
    "isNotAvailable": MessageLookupByLibrary.simpleMessage("is not available"),
    "israeli": MessageLookupByLibrary.simpleMessage("Israeli"),
    "issueType": MessageLookupByLibrary.simpleMessage("Issue Type"),
    "issuingAuthority": MessageLookupByLibrary.simpleMessage(
      "Issuing Authority",
    ),
    "itCanViewOrJoinWithInvite": MessageLookupByLibrary.simpleMessage(
      "It can view or Join with invite",
    ),
    "itDepartment": MessageLookupByLibrary.simpleMessage("IT Department"),
    "italian": MessageLookupByLibrary.simpleMessage("Italian"),
    "item": MessageLookupByLibrary.simpleMessage("Item"),
    "itemAddSuccessful": MessageLookupByLibrary.simpleMessage(
      "Item added successfully",
    ),
    "itemAlreadyAssigned": MessageLookupByLibrary.simpleMessage(
      "Item Already Assigned",
    ),
    "itemAssignedMessage": MessageLookupByLibrary.simpleMessage(
      "This item has already been assigned to someone. You cannot select it for assignment.",
    ),
    "itemsReplacedUsed": MessageLookupByLibrary.simpleMessage(
      "List Of Items Replaced/Used",
    ),
    "ivorian": MessageLookupByLibrary.simpleMessage("Ivorian"),
    "jamaican": MessageLookupByLibrary.simpleMessage("Jamaican"),
    "jan": MessageLookupByLibrary.simpleMessage("Jan"),
    "japanese": MessageLookupByLibrary.simpleMessage("Japanese"),
    "jobGrade": MessageLookupByLibrary.simpleMessage("Job Grade"),
    "jobLocation": MessageLookupByLibrary.simpleMessage("Job Location"),
    "jobTitle": MessageLookupByLibrary.simpleMessage("Job Title"),
    "jobTitleMissing": MessageLookupByLibrary.simpleMessage(
      "Job Title Missing",
    ),
    "jobType": MessageLookupByLibrary.simpleMessage("Job Type"),
    "jod": MessageLookupByLibrary.simpleMessage("JOD"),
    "jordanian": MessageLookupByLibrary.simpleMessage("Jordanian"),
    "jpy": MessageLookupByLibrary.simpleMessage("JPY"),
    "jul": MessageLookupByLibrary.simpleMessage("Jul"),
    "jun": MessageLookupByLibrary.simpleMessage("Jun"),
    "junior": MessageLookupByLibrary.simpleMessage("Junior"),
    "justificationMustBeAtLeast10Characters":
        MessageLookupByLibrary.simpleMessage(
          "Justification must be at least 10 characters",
        ),
    "justifications": MessageLookupByLibrary.simpleMessage("Justifications"),
    "k": MessageLookupByLibrary.simpleMessage("K"),
    "k1HBefore": MessageLookupByLibrary.simpleMessage("1 H Before"),
    "k1h": MessageLookupByLibrary.simpleMessage("1h"),
    "k1k": MessageLookupByLibrary.simpleMessage("+1K"),
    "k1st": MessageLookupByLibrary.simpleMessage("1st"),
    "k2HBefore": MessageLookupByLibrary.simpleMessage("2 H Before"),
    "k2nd": MessageLookupByLibrary.simpleMessage("2nd"),
    "k3rd": MessageLookupByLibrary.simpleMessage("3rd"),
    "kazakhstani": MessageLookupByLibrary.simpleMessage("Kazakhstani"),
    "kenyan": MessageLookupByLibrary.simpleMessage("Kenyan"),
    "kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc":
        MessageLookupByLibrary.simpleMessage(
          "Kindly assign a role to the employee. This is a required field for access permissions.",
        ),
    "kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor":
        MessageLookupByLibrary.simpleMessage(
          "Kindly enter the employee’s first name. This field is mandatory for identification",
        ),
    "kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI":
        MessageLookupByLibrary.simpleMessage(
          "Kindly enter the employee’s last name. This field is mandatory for identification",
        ),
    "kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo":
        MessageLookupByLibrary.simpleMessage(
          "Kindly enter the employee’s middle name. This field is mandatory for identification",
        ),
    "kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen":
        MessageLookupByLibrary.simpleMessage(
          "Kindly enter the name of the department to complete the assignment.",
        ),
    "kindlyProvideTheArabicTranslationOfTheJobTitleForBiling":
        MessageLookupByLibrary.simpleMessage(
          "Kindly provide the Arabic translation of the job title for bilingual records",
        ),
    "kittianAndNevisian": MessageLookupByLibrary.simpleMessage(
      "Kittian and Nevisian",
    ),
    "knowledgeHub": MessageLookupByLibrary.simpleMessage("Knowledge Hub"),
    "knowledgeHubPermissions": MessageLookupByLibrary.simpleMessage(
      "Knowledge Hub Permissions",
    ),
    "knowledgeHubResources": MessageLookupByLibrary.simpleMessage(
      "Knowledge Hub Resources",
    ),
    "knowledgeRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "You removed this knowledge successfully",
    ),
    "knowledge_hub": MessageLookupByLibrary.simpleMessage("Knowledge Hub"),
    "knowledge_monthly_comparison": MessageLookupByLibrary.simpleMessage(
      "Knowledge Monthly Comparison",
    ),
    "kurdishLanguage": MessageLookupByLibrary.simpleMessage("Kurdish"),
    "kuwaiti": MessageLookupByLibrary.simpleMessage("Kuwaiti"),
    "kwd": MessageLookupByLibrary.simpleMessage("KWD"),
    "kyrgyz": MessageLookupByLibrary.simpleMessage("Kyrgyz"),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "labelingScanningDevices": MessageLookupByLibrary.simpleMessage(
      "Labeling / Scanning Devices",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "laotian": MessageLookupByLibrary.simpleMessage("Laotian"),
    "last30Days": MessageLookupByLibrary.simpleMessage("Last 30 Days"),
    "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 Days"),
    "lastEdit": MessageLookupByLibrary.simpleMessage("Last Edit"),
    "lastModified": MessageLookupByLibrary.simpleMessage("Last Modified"),
    "lastMonth": MessageLookupByLibrary.simpleMessage("Last Month"),
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "lastNameMissing": MessageLookupByLibrary.simpleMessage(
      "Last Name Missing",
    ),
    "lastNameRequired": MessageLookupByLibrary.simpleMessage(
      "Last Name is required",
    ),
    "lastSeenDate": MessageLookupByLibrary.simpleMessage("Last Seen Date"),
    "lastSeenLocation": MessageLookupByLibrary.simpleMessage(
      "Last Seen Location",
    ),
    "lastUpdate": MessageLookupByLibrary.simpleMessage("Last Update"),
    "lastWeek": MessageLookupByLibrary.simpleMessage("Last Week"),
    "lastYear": MessageLookupByLibrary.simpleMessage("Last Year"),
    "last_edit": MessageLookupByLibrary.simpleMessage("Last Edit"),
    "last_login": MessageLookupByLibrary.simpleMessage("Last Login"),
    "late": MessageLookupByLibrary.simpleMessage("Late"),
    "lateHistory": MessageLookupByLibrary.simpleMessage("Late History"),
    "latitude": MessageLookupByLibrary.simpleMessage("Latitude"),
    "latitudeAndLongitude": MessageLookupByLibrary.simpleMessage(
      "Latitude And Longitude",
    ),
    "latitudeInvalid": MessageLookupByLibrary.simpleMessage(
      "Latitude invalid.",
    ),
    "latvian": MessageLookupByLibrary.simpleMessage("Latvian"),
    "layoutAlignment": MessageLookupByLibrary.simpleMessage(
      "Layout & Alignment",
    ),
    "lbp": MessageLookupByLibrary.simpleMessage("LBP"),
    "lead": MessageLookupByLibrary.simpleMessage("Lead"),
    "leader": MessageLookupByLibrary.simpleMessage("Leader"),
    "least": MessageLookupByLibrary.simpleMessage("Least"),
    "leaveRequestApproval": MessageLookupByLibrary.simpleMessage(
      "Leave Request → Approval",
    ),
    "leaveRequestList": MessageLookupByLibrary.simpleMessage(
      "Leave Request → List",
    ),
    "leaveRequestNew": MessageLookupByLibrary.simpleMessage(
      "Leave Request → New",
    ),
    "leavingTime": MessageLookupByLibrary.simpleMessage("Leaving Time"),
    "lebanese": MessageLookupByLibrary.simpleMessage("Lebanese"),
    "left": MessageLookupByLibrary.simpleMessage("Left"),
    "legalDepartment": MessageLookupByLibrary.simpleMessage("Legal Department"),
    "legalOfficer": MessageLookupByLibrary.simpleMessage("Legal Officer"),
    "lessThan30Minutes": MessageLookupByLibrary.simpleMessage(
      "Less than 30 minutes",
    ),
    "letter": MessageLookupByLibrary.simpleMessage("Letter"),
    "liberian": MessageLookupByLibrary.simpleMessage("Liberian"),
    "libyan": MessageLookupByLibrary.simpleMessage("Libyan"),
    "liechtensteiner": MessageLookupByLibrary.simpleMessage("Liechtensteiner"),
    "lifeInsuranceCard": MessageLookupByLibrary.simpleMessage(
      "Life Insurance Card",
    ),
    "liftingCrane": MessageLookupByLibrary.simpleMessage(
      "Lifting Crane / Hoist",
    ),
    "lightDarkMode": MessageLookupByLibrary.simpleMessage("Light/Dark Mode"),
    "lightingInspection": MessageLookupByLibrary.simpleMessage(
      "Lighting Inspection",
    ),
    "limitDepartmentAvailability": MessageLookupByLibrary.simpleMessage(
      "Limit Department Availability",
    ),
    "limitLocationAvailability": MessageLookupByLibrary.simpleMessage(
      "Limit Location Availability",
    ),
    "limitServiceAvailability": MessageLookupByLibrary.simpleMessage(
      "Limit Service Availability",
    ),
    "limit_department_availability": MessageLookupByLibrary.simpleMessage(
      "Limit Department Availability",
    ),
    "limitedDepartmentAvailability": MessageLookupByLibrary.simpleMessage(
      "Limited Department Availability",
    ),
    "linkInvalid": MessageLookupByLibrary.simpleMessage("Link invalid"),
    "links": MessageLookupByLibrary.simpleMessage("Links"),
    "lithuanian": MessageLookupByLibrary.simpleMessage("Lithuanian"),
    "loadMore": MessageLookupByLibrary.simpleMessage("Load more"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingDashboard": MessageLookupByLibrary.simpleMessage(
      "Loading dashboard...",
    ),
    "loadingDepartments": MessageLookupByLibrary.simpleMessage(
      "Loading departments...",
    ),
    "loadingEmployeeDetails": MessageLookupByLibrary.simpleMessage(
      "Loading employee details",
    ),
    "loadingForm": MessageLookupByLibrary.simpleMessage("Loading form..."),
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "locationAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Added This Location",
    ),
    "locationAtGoogleMaps": MessageLookupByLibrary.simpleMessage(
      "Location at Google Maps",
    ),
    "locationAvailability": MessageLookupByLibrary.simpleMessage(
      "Location Availability",
    ),
    "locationCreated": MessageLookupByLibrary.simpleMessage("Location Created"),
    "locationCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created New Location",
    ),
    "locationDeleted": MessageLookupByLibrary.simpleMessage("Location Deleted"),
    "locationDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Location",
    ),
    "locationDelivery": MessageLookupByLibrary.simpleMessage(
      "Location Delivery",
    ),
    "locationDescription": MessageLookupByLibrary.simpleMessage(
      "Location Description",
    ),
    "locationDetails": MessageLookupByLibrary.simpleMessage("Location Details"),
    "locationEdited": MessageLookupByLibrary.simpleMessage("Location Edited"),
    "locationEditedSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Location",
    ),
    "locationID": MessageLookupByLibrary.simpleMessage("Location ID"),
    "locationInformation": MessageLookupByLibrary.simpleMessage(
      "Location Information",
    ),
    "locationName": MessageLookupByLibrary.simpleMessage("Location Name"),
    "locationNameArabic": MessageLookupByLibrary.simpleMessage(
      "Location Name (Arabic)",
    ),
    "locationNameEnglish": MessageLookupByLibrary.simpleMessage(
      "Location Name (English)",
    ),
    "locationType": MessageLookupByLibrary.simpleMessage("Location Type"),
    "locationTypeRequired": MessageLookupByLibrary.simpleMessage(
      "Location Type is required",
    ),
    "location_settings": MessageLookupByLibrary.simpleMessage(
      "Location Settings",
    ),
    "locations": MessageLookupByLibrary.simpleMessage("Locations"),
    "lockGeographical": MessageLookupByLibrary.simpleMessage(
      "Lock Geographical",
    ),
    "locker": MessageLookupByLibrary.simpleMessage("Locker"),
    "logActivity": MessageLookupByLibrary.simpleMessage("Log Activity"),
    "logOut": MessageLookupByLibrary.simpleMessage("Log Out"),
    "logicIssue": MessageLookupByLibrary.simpleMessage("Logic Issue"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "london": MessageLookupByLibrary.simpleMessage("London"),
    "longitude": MessageLookupByLibrary.simpleMessage("Longitude"),
    "longitudeInvalid": MessageLookupByLibrary.simpleMessage(
      "Longitude invalid.",
    ),
    "low": MessageLookupByLibrary.simpleMessage("Low"),
    "lowStock": MessageLookupByLibrary.simpleMessage("Low Stock"),
    "lowStocks": MessageLookupByLibrary.simpleMessage("Low Stocks"),
    "luxembourger": MessageLookupByLibrary.simpleMessage("Luxembourger"),
    "lyd": MessageLookupByLibrary.simpleMessage("LYD"),
    "m": MessageLookupByLibrary.simpleMessage("M"),
    "macLaptopDesktop": MessageLookupByLibrary.simpleMessage(
      "Mac Laptop / Desktop",
    ),
    "macedonian": MessageLookupByLibrary.simpleMessage("Macedonian"),
    "macos": MessageLookupByLibrary.simpleMessage("macOS"),
    "mad": MessageLookupByLibrary.simpleMessage("MAD"),
    "mainOffice": MessageLookupByLibrary.simpleMessage("Main Office"),
    "mainStorage": MessageLookupByLibrary.simpleMessage("Main Storage"),
    "maintenance": MessageLookupByLibrary.simpleMessage("Maintenance"),
    "maintenanceDate": MessageLookupByLibrary.simpleMessage("Maintenance Date"),
    "maintenanceDetails": MessageLookupByLibrary.simpleMessage(
      "Maintenance Details",
    ),
    "maintenanceFrequency": MessageLookupByLibrary.simpleMessage(
      "Maintenance Frequency",
    ),
    "maintenanceId": MessageLookupByLibrary.simpleMessage("Maintenance ID"),
    "maintenanceInspector": MessageLookupByLibrary.simpleMessage(
      "Maintenance Inspector",
    ),
    "maintenanceRequests": MessageLookupByLibrary.simpleMessage(
      "Maintenance Requests",
    ),
    "maintenanceSchedule": MessageLookupByLibrary.simpleMessage(
      "Maintenance Schedule",
    ),
    "maintenanceService": MessageLookupByLibrary.simpleMessage(
      "Maintenance Service",
    ),
    "maintenanceStatus": MessageLookupByLibrary.simpleMessage(
      "Maintenance Status",
    ),
    "makeAChangeBeforeContinuing": MessageLookupByLibrary.simpleMessage(
      "Make a change before continuing",
    ),
    "makePrivate": MessageLookupByLibrary.simpleMessage("Make Private"),
    "malagasy": MessageLookupByLibrary.simpleMessage("Malagasy"),
    "malawian": MessageLookupByLibrary.simpleMessage("Malawian"),
    "malayalamLanguage": MessageLookupByLibrary.simpleMessage("Malayalam"),
    "malaysian": MessageLookupByLibrary.simpleMessage("Malaysian"),
    "maldivan": MessageLookupByLibrary.simpleMessage("Maldivan"),
    "male": MessageLookupByLibrary.simpleMessage("Male"),
    "malian": MessageLookupByLibrary.simpleMessage("Malian"),
    "maltese": MessageLookupByLibrary.simpleMessage("Maltese"),
    "manageAttendance": MessageLookupByLibrary.simpleMessage(
      "Manage Attendance",
    ),
    "manageBenefits": MessageLookupByLibrary.simpleMessage("Manage Benefits"),
    "manageDepartments": MessageLookupByLibrary.simpleMessage(
      "Manage Departments",
    ),
    "manageJobPositions": MessageLookupByLibrary.simpleMessage(
      "Manage Job Positions",
    ),
    "manageOffboarding": MessageLookupByLibrary.simpleMessage(
      "Manage Offboarding",
    ),
    "manageOnboarding": MessageLookupByLibrary.simpleMessage(
      "Manage Onboarding",
    ),
    "managePayroll": MessageLookupByLibrary.simpleMessage("Manage Payroll"),
    "managePipeline": MessageLookupByLibrary.simpleMessage("Manage Pipeline"),
    "manageTraining": MessageLookupByLibrary.simpleMessage("Manage Training"),
    "manager": MessageLookupByLibrary.simpleMessage("Manager"),
    "managerApproval": MessageLookupByLibrary.simpleMessage("Manager Approval"),
    "managerialAccess": MessageLookupByLibrary.simpleMessage(
      "Managerial Access",
    ),
    "mandarinChinese": MessageLookupByLibrary.simpleMessage("Mandarin Chinese"),
    "mandate": MessageLookupByLibrary.simpleMessage("Mandate"),
    "mar": MessageLookupByLibrary.simpleMessage("Mar"),
    "maritalCertificate": MessageLookupByLibrary.simpleMessage(
      "Marital Certificate",
    ),
    "maritalStatus": MessageLookupByLibrary.simpleMessage("Marital Status"),
    "marketResearchService": MessageLookupByLibrary.simpleMessage(
      "Market Research Service",
    ),
    "marketing": MessageLookupByLibrary.simpleMessage("Marketing"),
    "marketingLead": MessageLookupByLibrary.simpleMessage("Marketing lead"),
    "marketingManager": MessageLookupByLibrary.simpleMessage(
      "Marketing Manager",
    ),
    "marketingTeam": MessageLookupByLibrary.simpleMessage("Marketing Team"),
    "marriageVacation": MessageLookupByLibrary.simpleMessage(
      "Marriage Vacation",
    ),
    "married": MessageLookupByLibrary.simpleMessage("Married"),
    "marshallese": MessageLookupByLibrary.simpleMessage("Marshallese"),
    "martialServiceProof": MessageLookupByLibrary.simpleMessage(
      "Martial Service Proof",
    ),
    "master": MessageLookupByLibrary.simpleMessage("Master\'s"),
    "masterBulkUpload": MessageLookupByLibrary.simpleMessage(
      "Master Bulk Upload",
    ),
    "masterDegree": MessageLookupByLibrary.simpleMessage("Master\'s Degree"),
    "masterUpload": MessageLookupByLibrary.simpleMessage("Master Upload"),
    "matches": MessageLookupByLibrary.simpleMessage("matches"),
    "matches2": MessageLookupByLibrary.simpleMessage("Matches"),
    "mauritanian": MessageLookupByLibrary.simpleMessage("Mauritanian"),
    "mauritian": MessageLookupByLibrary.simpleMessage("Mauritian"),
    "maximum": MessageLookupByLibrary.simpleMessage("Maximum"),
    "may": MessageLookupByLibrary.simpleMessage("May"),
    "mechanical": MessageLookupByLibrary.simpleMessage("Mechanical"),
    "media": MessageLookupByLibrary.simpleMessage("Media"),
    "mediaLinksAndDocs": MessageLookupByLibrary.simpleMessage(
      "Media, links, and docs",
    ),
    "mediaTeam": MessageLookupByLibrary.simpleMessage("Media Team"),
    "medium": MessageLookupByLibrary.simpleMessage("Medium"),
    "meeting": MessageLookupByLibrary.simpleMessage("Meeting"),
    "member": MessageLookupByLibrary.simpleMessage("Member"),
    "membersVoted": MessageLookupByLibrary.simpleMessage("members voted"),
    "menuDuplicate": MessageLookupByLibrary.simpleMessage("Duplicate"),
    "message": MessageLookupByLibrary.simpleMessage("Message"),
    "messageAddedToStarredMessages": MessageLookupByLibrary.simpleMessage(
      "Message added to starred messages!",
    ),
    "messageFormOwner": MessageLookupByLibrary.simpleMessage(
      "Message Form Owner",
    ),
    "messageRemovedFromStarredMessages": MessageLookupByLibrary.simpleMessage(
      "Message removed from starred messages!",
    ),
    "messages": MessageLookupByLibrary.simpleMessage("Messages"),
    "messagesPermissions": MessageLookupByLibrary.simpleMessage(
      "Messages Permissions",
    ),
    "meter": MessageLookupByLibrary.simpleMessage("meter"),
    "meter2": MessageLookupByLibrary.simpleMessage("meter2"),
    "methodOfPayment": MessageLookupByLibrary.simpleMessage(
      "Method of Payment",
    ),
    "mexican": MessageLookupByLibrary.simpleMessage("Mexican"),
    "micronesian": MessageLookupByLibrary.simpleMessage("Micronesian"),
    "mid": MessageLookupByLibrary.simpleMessage("Mid"),
    "middleName": MessageLookupByLibrary.simpleMessage("Middle Name"),
    "middleNameMissing": MessageLookupByLibrary.simpleMessage(
      "Middle Name Missing",
    ),
    "middleNameRequired": MessageLookupByLibrary.simpleMessage(
      "Middle name is required.",
    ),
    "minimum": MessageLookupByLibrary.simpleMessage("Minimum"),
    "mins": MessageLookupByLibrary.simpleMessage("Mins"),
    "minute": MessageLookupByLibrary.simpleMessage("Minute"),
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesAgo": MessageLookupByLibrary.simpleMessage("Minutes Ago"),
    "minutesShort": MessageLookupByLibrary.simpleMessage("30 Minutes"),
    "missing": MessageLookupByLibrary.simpleMessage("Missing"),
    "missingColumn": MessageLookupByLibrary.simpleMessage("Missing column"),
    "missingColumns": MessageLookupByLibrary.simpleMessage("Missing columns"),
    "missingDate": MessageLookupByLibrary.simpleMessage("Missing Date"),
    "missingDepartmentID": MessageLookupByLibrary.simpleMessage(
      "Missing Department ID",
    ),
    "missingInformation": MessageLookupByLibrary.simpleMessage(
      "Missing Information",
    ),
    "missingRequiredColumns": MessageLookupByLibrary.simpleMessage(
      "Missing required columns",
    ),
    "mobilePhone": MessageLookupByLibrary.simpleMessage("Mobile Phone"),
    "mobileView": MessageLookupByLibrary.simpleMessage("Mobile View"),
    "model": MessageLookupByLibrary.simpleMessage("Model"),
    "module": MessageLookupByLibrary.simpleMessage("Module"),
    "moduleName": MessageLookupByLibrary.simpleMessage("Module Name"),
    "moduleNameAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "The Module Name Already Exists",
    ),
    "moduleOwner": MessageLookupByLibrary.simpleMessage("Module Owner"),
    "moduleOwners": MessageLookupByLibrary.simpleMessage("Module Owners"),
    "moduleUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Module updated successfully!",
    ),
    "modules": MessageLookupByLibrary.simpleMessage("Modules"),
    "mohamed": MessageLookupByLibrary.simpleMessage("Mohamed"),
    "moldovan": MessageLookupByLibrary.simpleMessage("Moldovan"),
    "monacan": MessageLookupByLibrary.simpleMessage("Monacan"),
    "monday": MessageLookupByLibrary.simpleMessage("Monday"),
    "mongolian": MessageLookupByLibrary.simpleMessage("Mongolian"),
    "monitorHumidityLevelsAndAdjustIfNecessary":
        MessageLookupByLibrary.simpleMessage(
          "Monitor humidity levels and adjust if necessary.",
        ),
    "month": MessageLookupByLibrary.simpleMessage("Months"),
    "month2": MessageLookupByLibrary.simpleMessage("Month"),
    "monthly": MessageLookupByLibrary.simpleMessage("Monthly"),
    "monthlyComparison": MessageLookupByLibrary.simpleMessage(
      "Monthly Comparison",
    ),
    "months": MessageLookupByLibrary.simpleMessage("Months"),
    "monthsAgo": MessageLookupByLibrary.simpleMessage("Months Ago"),
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "moreOptions": MessageLookupByLibrary.simpleMessage("More Options"),
    "morePermissions": MessageLookupByLibrary.simpleMessage("More Permissions"),
    "moreThan30Minutes": MessageLookupByLibrary.simpleMessage(
      "More than 30 minutes",
    ),
    "moroccan": MessageLookupByLibrary.simpleMessage("Moroccan"),
    "mosotho": MessageLookupByLibrary.simpleMessage("Mosotho"),
    "mostOfTheTime": MessageLookupByLibrary.simpleMessage("Most Of The Time"),
    "mostRecent": MessageLookupByLibrary.simpleMessage("Most Recent"),
    "motswana": MessageLookupByLibrary.simpleMessage("Motswana"),
    "mozambican": MessageLookupByLibrary.simpleMessage("Mozambican"),
    "msg": MessageLookupByLibrary.simpleMessage("Message"),
    "mustBeAValidEmailAddress": MessageLookupByLibrary.simpleMessage(
      "Must be a valid email address",
    ),
    "mustBeGreaterThanZero": MessageLookupByLibrary.simpleMessage(
      "Must be > 0",
    ),
    "mustBeLessThanOrEqual": MessageLookupByLibrary.simpleMessage(
      "Must be ≤ 1000",
    ),
    "mustBeNumber": MessageLookupByLibrary.simpleMessage("Must be a number"),
    "mustCorrectErrors": MessageLookupByLibrary.simpleMessage(
      "You must correct all errors before uploading",
    ),
    "mustSelectApprovalEmployees": MessageLookupByLibrary.simpleMessage(
      "You must select at least one employee for the approval cycle",
    ),
    "mustSelectDepartment": MessageLookupByLibrary.simpleMessage(
      "You must select at least one department when limiting service availability",
    ),
    "muteNotification": MessageLookupByLibrary.simpleMessage(
      "Mute Notification",
    ),
    "muteNotifications": MessageLookupByLibrary.simpleMessage(
      "Mute Notifications",
    ),
    "myAudit": MessageLookupByLibrary.simpleMessage("My Audit"),
    "myAudits": MessageLookupByLibrary.simpleMessage("My Audits"),
    "myDashboard": MessageLookupByLibrary.simpleMessage("My Dashboard"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "myRequest": MessageLookupByLibrary.simpleMessage("My Request"),
    "myRequests": MessageLookupByLibrary.simpleMessage("My Requests"),
    "myServices": MessageLookupByLibrary.simpleMessage("My Services"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameMaxLength": MessageLookupByLibrary.simpleMessage(
      "Names cannot exceed 20 characters.",
    ),
    "namibian": MessageLookupByLibrary.simpleMessage("Namibian"),
    "nationalIDMustBeExactly14DigitsLong": MessageLookupByLibrary.simpleMessage(
      "National ID must be exactly 14 digits long.",
    ),
    "nationalId": MessageLookupByLibrary.simpleMessage("National ID"),
    "nationalIdExpiration": MessageLookupByLibrary.simpleMessage(
      "National ID Expiration",
    ),
    "nationalities": MessageLookupByLibrary.simpleMessage("Nationalities"),
    "nationality": MessageLookupByLibrary.simpleMessage("Nationality"),
    "nauruan": MessageLookupByLibrary.simpleMessage("Nauruan"),
    "navigateTheDigitalFrontierWithEase": MessageLookupByLibrary.simpleMessage(
      "Navigate the Digital Frontier with Ease",
    ),
    "nearBreachedSLA": MessageLookupByLibrary.simpleMessage(
      "Near Breached SLA",
    ),
    "nepalese": MessageLookupByLibrary.simpleMessage("Nepalese"),
    "newAsset": MessageLookupByLibrary.simpleMessage("New Asset"),
    "newAssignedControls": MessageLookupByLibrary.simpleMessage(
      "New Assigned Controls",
    ),
    "newBatch": MessageLookupByLibrary.simpleMessage("New Batch"),
    "newBatchRestockTitle": MessageLookupByLibrary.simpleMessage(
      "Restocking New Batch",
    ),
    "newChampionCannotBeTheCurrentChampion":
        MessageLookupByLibrary.simpleMessage(
          "New champion cannot be the current champion",
        ),
    "newControlChampion": MessageLookupByLibrary.simpleMessage(
      "New Control Champion",
    ),
    "newControlOwner": MessageLookupByLibrary.simpleMessage(
      "New Control Owner",
    ),
    "newOwnerCannotBeTheCurrentOwner": MessageLookupByLibrary.simpleMessage(
      "New owner cannot be the current owner",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "newPasswordMatchesConfirmField": MessageLookupByLibrary.simpleMessage(
      "New password matches the confirm field.",
    ),
    "newProduct": MessageLookupByLibrary.simpleMessage("New Product"),
    "newRequest": MessageLookupByLibrary.simpleMessage("New Request"),
    "newStorageLocationAdded": MessageLookupByLibrary.simpleMessage(
      "New Storage Location Added",
    ),
    "newSupplierAdded": MessageLookupByLibrary.simpleMessage(
      "New Supplier Added",
    ),
    "newZealander": MessageLookupByLibrary.simpleMessage("New Zealander"),
    "new_details": MessageLookupByLibrary.simpleMessage("New Details"),
    "newestFirst": MessageLookupByLibrary.simpleMessage("Newest First"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nextDisposition": MessageLookupByLibrary.simpleMessage("Next Disposition"),
    "nextScheduledDate": MessageLookupByLibrary.simpleMessage(
      "Next Scheduled Date",
    ),
    "nextScheduledMaintenance": MessageLookupByLibrary.simpleMessage(
      "Next Scheduled Maintenance",
    ),
    "nicaraguan": MessageLookupByLibrary.simpleMessage("Nicaraguan"),
    "nigerian": MessageLookupByLibrary.simpleMessage("Nigerian"),
    "nigerien": MessageLookupByLibrary.simpleMessage("Nigerien"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noActiveTasks": MessageLookupByLibrary.simpleMessage("No active tasks"),
    "noAgeDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No age data available",
    ),
    "noAnalyticsDataAvailableYet": MessageLookupByLibrary.simpleMessage(
      "No analytics data available yet",
    ),
    "noApprovals": MessageLookupByLibrary.simpleMessage("No approvals"),
    "noApprovalsFound": MessageLookupByLibrary.simpleMessage(
      "No approvals found",
    ),
    "noApprovalsInThisStatus": MessageLookupByLibrary.simpleMessage(
      "No approvals in this status",
    ),
    "noApprovalsMatchFilters": MessageLookupByLibrary.simpleMessage(
      "No approvals match your filters",
    ),
    "noAttachmentsAvailable": MessageLookupByLibrary.simpleMessage(
      "No attachments available",
    ),
    "noAuditsInThisStatus": MessageLookupByLibrary.simpleMessage(
      "No audits in this status",
    ),
    "noChangeFound": MessageLookupByLibrary.simpleMessage("No Change Found"),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage("No comments yet"),
    "noCommonGroups": MessageLookupByLibrary.simpleMessage("No common groups"),
    "noControlChampionsFound": MessageLookupByLibrary.simpleMessage(
      "No control champions found",
    ),
    "noControlOwnersFound": MessageLookupByLibrary.simpleMessage(
      "No control owners found",
    ),
    "noControlsAssigned": MessageLookupByLibrary.simpleMessage(
      "No controls assigned",
    ),
    "noControlsFound": MessageLookupByLibrary.simpleMessage(
      "No controls found",
    ),
    "noControlsInThisStatus": MessageLookupByLibrary.simpleMessage(
      "No controls in this status",
    ),
    "noCountriesFound": MessageLookupByLibrary.simpleMessage(
      "No countries found",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No Data"),
    "noDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No data available",
    ),
    "noDataRowsFoundInTheExcelFile": MessageLookupByLibrary.simpleMessage(
      "No data rows found in the Excel file",
    ),
    "noDocs": MessageLookupByLibrary.simpleMessage("No Docs"),
    "noDocumentsFound": MessageLookupByLibrary.simpleMessage(
      "No documents found",
    ),
    "noEmployeesAtLocation": MessageLookupByLibrary.simpleMessage(
      "No employees at this location",
    ),
    "noEmployeesFound": MessageLookupByLibrary.simpleMessage(
      "No employees found",
    ),
    "noEmployeesSelected": MessageLookupByLibrary.simpleMessage(
      "No employees selected",
    ),
    "noExperienceDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No experience data available",
    ),
    "noFileSelected": MessageLookupByLibrary.simpleMessage("No file selected"),
    "noFormFound": MessageLookupByLibrary.simpleMessage("No Form Found"),
    "noGrcModulesFound": MessageLookupByLibrary.simpleMessage(
      "No GRC modules found",
    ),
    "noGroupFound": MessageLookupByLibrary.simpleMessage("No Group Found"),
    "noGroupsInCommon": MessageLookupByLibrary.simpleMessage(
      "No groups in common",
    ),
    "noImageSelected": MessageLookupByLibrary.simpleMessage(
      "No image selected",
    ),
    "noKnowledgedocumentsFound": MessageLookupByLibrary.simpleMessage(
      "No knowledge documents found",
    ),
    "noLinks": MessageLookupByLibrary.simpleMessage("No Links"),
    "noLocationsFound": MessageLookupByLibrary.simpleMessage(
      "No Locations Found",
    ),
    "noMatchesFound": MessageLookupByLibrary.simpleMessage("No matches found"),
    "noMedia": MessageLookupByLibrary.simpleMessage("No Media"),
    "noModulesGranted": MessageLookupByLibrary.simpleMessage(
      "No modules granted",
    ),
    "noMoreResults": MessageLookupByLibrary.simpleMessage("No more results"),
    "noNearBreachedSLAServices": MessageLookupByLibrary.simpleMessage(
      "No near breached SLA services",
    ),
    "noOfControls": MessageLookupByLibrary.simpleMessage("No of Controls"),
    "noOfDepartments": MessageLookupByLibrary.simpleMessage(
      "No of Departments",
    ),
    "noOrdersFound": MessageLookupByLibrary.simpleMessage("No orders found"),
    "noOwnersAssigned": MessageLookupByLibrary.simpleMessage(
      "No owners assigned",
    ),
    "noPeopleFound": MessageLookupByLibrary.simpleMessage("No people found"),
    "noPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "No permission configuration needed for these modules.",
    ),
    "noPermissionToCreateGroup": MessageLookupByLibrary.simpleMessage(
      "Your role doesn\'t allow creating groups",
    ),
    "noPermissionsFound": MessageLookupByLibrary.simpleMessage(
      "No permissions found",
    ),
    "noPoliciesFound": MessageLookupByLibrary.simpleMessage(
      "No policies found",
    ),
    "noPreviousControlOwners": MessageLookupByLibrary.simpleMessage(
      "No previous control owners",
    ),
    "noPreviousModuleOwners": MessageLookupByLibrary.simpleMessage(
      "No previous module owners",
    ),
    "noResourcesDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No resources data available",
    ),
    "noResults": MessageLookupByLibrary.simpleMessage("No results"),
    "noRole": MessageLookupByLibrary.simpleMessage("No Role"),
    "noRolesToExport": MessageLookupByLibrary.simpleMessage(
      "No roles to export",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No Search Results",
    ),
    "noServicesFound": MessageLookupByLibrary.simpleMessage(
      "No services found",
    ),
    "noStarredMessages": MessageLookupByLibrary.simpleMessage(
      "No starred messages",
    ),
    "noStatisticsAvailable": MessageLookupByLibrary.simpleMessage(
      "No statistics available",
    ),
    "noStatisticsAvailableYet": MessageLookupByLibrary.simpleMessage(
      "No statistics available yet",
    ),
    "noSubmissionWasMadeBeforeTheDeadline":
        MessageLookupByLibrary.simpleMessage(
          "No submission was made before the deadline",
        ),
    "noSubmissionsFound": MessageLookupByLibrary.simpleMessage(
      "No submissions found",
    ),
    "noSubmissionsMatchFilters": MessageLookupByLibrary.simpleMessage(
      "No Submissions Match Filters",
    ),
    "noSubmissionsYet": MessageLookupByLibrary.simpleMessage(
      "No Submissions Yet",
    ),
    "noSystemLogsFound": MessageLookupByLibrary.simpleMessage(
      "No system logs found",
    ),
    "noTitleButton": MessageLookupByLibrary.simpleMessage("No"),
    "noUserPermissionsToExport": MessageLookupByLibrary.simpleMessage(
      "No user permissions to export",
    ),
    "noWeightChanges": MessageLookupByLibrary.simpleMessage(
      "No weight changes",
    ),
    "noWrongDataFound": MessageLookupByLibrary.simpleMessage(
      "No Wrong Data Found",
    ),
    "no_data_available": MessageLookupByLibrary.simpleMessage(
      "No canceled or rejected services found",
    ),
    "no_specific_permissions": MessageLookupByLibrary.simpleMessage(
      "No specific permissions",
    ),
    "nonNumericCharactersInNationalID": MessageLookupByLibrary.simpleMessage(
      "Non-Numeric Characters in National ID",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "northKorean": MessageLookupByLibrary.simpleMessage("North Korean"),
    "northernIrish": MessageLookupByLibrary.simpleMessage("Northern Irish"),
    "norwegian": MessageLookupByLibrary.simpleMessage("Norwegian"),
    "notAccepted": MessageLookupByLibrary.simpleMessage("Not Accepted"),
    "notAllowed": MessageLookupByLibrary.simpleMessage("This is not allowed."),
    "notAssigned": MessageLookupByLibrary.simpleMessage("Not Assigned"),
    "notAvailable": MessageLookupByLibrary.simpleMessage("Not Available"),
    "notRemote": MessageLookupByLibrary.simpleMessage("Not Remote"),
    "notes": MessageLookupByLibrary.simpleMessage("Notes"),
    "notesObservations": MessageLookupByLibrary.simpleMessage(
      "Notes & Observations",
    ),
    "notice": MessageLookupByLibrary.simpleMessage("Notice"),
    "notification": MessageLookupByLibrary.simpleMessage("Notification"),
    "notificationControl": MessageLookupByLibrary.simpleMessage(
      "Notification Control",
    ),
    "notificationModule": MessageLookupByLibrary.simpleMessage(
      "Notification Module",
    ),
    "notificationNotReceived": MessageLookupByLibrary.simpleMessage(
      "Notification Not Received",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationsType": MessageLookupByLibrary.simpleMessage(
      "Notifications Type",
    ),
    "notifiedSecurityTeam": MessageLookupByLibrary.simpleMessage(
      "Notified Security Team",
    ),
    "notifyProviderManager": MessageLookupByLibrary.simpleMessage(
      "Notify Provider Manager",
    ),
    "notifyServiceProvider": MessageLookupByLibrary.simpleMessage(
      "Notify Service Provider",
    ),
    "notifyServiceRequester": MessageLookupByLibrary.simpleMessage(
      "Notify Service Requester",
    ),
    "nov": MessageLookupByLibrary.simpleMessage("Nov"),
    "num": MessageLookupByLibrary.simpleMessage("No"),
    "number": MessageLookupByLibrary.simpleMessage("NO"),
    "numberLabel": MessageLookupByLibrary.simpleMessage("Number"),
    "numberMaxLength": MessageLookupByLibrary.simpleMessage(
      "Numbers cannot exceed 10 digits.",
    ),
    "numberOfColumns": MessageLookupByLibrary.simpleMessage("No. of Columns"),
    "numberOfDownloads": MessageLookupByLibrary.simpleMessage(
      "Number of Downloads",
    ),
    "numberOfProduct": MessageLookupByLibrary.simpleMessage(
      "Number Of Product",
    ),
    "numberOfServices": MessageLookupByLibrary.simpleMessage(
      "Number Of Services",
    ),
    "numberOfViews": MessageLookupByLibrary.simpleMessage("Number of Views"),
    "numbersNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Numbers not allowed",
    ),
    "oct": MessageLookupByLibrary.simpleMessage("Oct"),
    "ofLabel": MessageLookupByLibrary.simpleMessage("of"),
    "office": MessageLookupByLibrary.simpleMessage("Office"),
    "office1": MessageLookupByLibrary.simpleMessage("Office - 1"),
    "office2": MessageLookupByLibrary.simpleMessage("Office - 2"),
    "officeCoordinates": MessageLookupByLibrary.simpleMessage(
      "Office Coordinates",
    ),
    "officeNumber": MessageLookupByLibrary.simpleMessage("Office Number"),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "ok2": MessageLookupByLibrary.simpleMessage("OK"),
    "oldAssignedControls": MessageLookupByLibrary.simpleMessage(
      "Old Assigned Controls",
    ),
    "oldPasswordMatchesSavedPassword": MessageLookupByLibrary.simpleMessage(
      "Old password matches the saved password.",
    ),
    "oldestFirst": MessageLookupByLibrary.simpleMessage("Oldest First"),
    "omani": MessageLookupByLibrary.simpleMessage("Omani"),
    "omr": MessageLookupByLibrary.simpleMessage("OMR"),
    "onHold": MessageLookupByLibrary.simpleMessage("On Hold"),
    "onSite": MessageLookupByLibrary.simpleMessage("On Site"),
    "onTime": MessageLookupByLibrary.simpleMessage("On Time"),
    "onboardingEmployees": MessageLookupByLibrary.simpleMessage(
      "Onboarding Employees",
    ),
    "oncomingTime": MessageLookupByLibrary.simpleMessage("Oncoming Time"),
    "onlineRetail": MessageLookupByLibrary.simpleMessage("Online Retail"),
    "onlyAdminsCanShareContent": MessageLookupByLibrary.simpleMessage(
      "Only Admins can share content",
    ),
    "onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols":
        MessageLookupByLibrary.simpleMessage(
          "Only digits are allowed. Please remove any letters or symbols.",
        ),
    "onlyDigitsArePermittedInTheExtensionField":
        MessageLookupByLibrary.simpleMessage(
          "Only digits are permitted in the extension field",
        ),
    "onlyNumbersAllowed": MessageLookupByLibrary.simpleMessage(
      "Only numbers are allowed.",
    ),
    "onsite": MessageLookupByLibrary.simpleMessage("Onsite"),
    "opacity": MessageLookupByLibrary.simpleMessage("Opacity"),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "openAccess": MessageLookupByLibrary.simpleMessage("Open Access"),
    "openingFile": MessageLookupByLibrary.simpleMessage("OpeningFile"),
    "operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "operationsDepartment": MessageLookupByLibrary.simpleMessage(
      "Operations Department",
    ),
    "operationsManager": MessageLookupByLibrary.simpleMessage(
      "Operations Manager",
    ),
    "option": MessageLookupByLibrary.simpleMessage("Option"),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "optionsMustBeUnique": MessageLookupByLibrary.simpleMessage(
      "Options must be unique",
    ),
    "or": MessageLookupByLibrary.simpleMessage("Or"),
    "orange": MessageLookupByLibrary.simpleMessage("Orange"),
    "order": MessageLookupByLibrary.simpleMessage("Order"),
    "orderAndProductDetails": MessageLookupByLibrary.simpleMessage(
      "Order & Product Details",
    ),
    "orderCreatedBy": MessageLookupByLibrary.simpleMessage("Order Created By"),
    "orderDate": MessageLookupByLibrary.simpleMessage("Order Date"),
    "orderDetails": MessageLookupByLibrary.simpleMessage("Order Details"),
    "orderFulfillmentStatus": MessageLookupByLibrary.simpleMessage(
      "Order Fulfillment Status",
    ),
    "orderID": MessageLookupByLibrary.simpleMessage("Order ID"),
    "orderNote": MessageLookupByLibrary.simpleMessage("Order Note"),
    "orderRequest": MessageLookupByLibrary.simpleMessage("Order Request"),
    "orderStatus": MessageLookupByLibrary.simpleMessage("Order Status"),
    "orderType": MessageLookupByLibrary.simpleMessage("Order Type"),
    "orderValue": MessageLookupByLibrary.simpleMessage("Order Value"),
    "orders": MessageLookupByLibrary.simpleMessage("Orders"),
    "ordersHistory": MessageLookupByLibrary.simpleMessage("Orders History"),
    "orgChart": MessageLookupByLibrary.simpleMessage("Org Chart"),
    "organizationChart": MessageLookupByLibrary.simpleMessage(
      "Organization Chart",
    ),
    "orientation": MessageLookupByLibrary.simpleMessage("Orientation"),
    "orientationLandscape": MessageLookupByLibrary.simpleMessage("Landscape"),
    "orientationPortrait": MessageLookupByLibrary.simpleMessage("Portrait"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherDesignIssue": MessageLookupByLibrary.simpleMessage(
      "Other Design Issue",
    ),
    "otherLogicIssue": MessageLookupByLibrary.simpleMessage(
      "Other Logic Issue",
    ),
    "outOfStock": MessageLookupByLibrary.simpleMessage("Out Of Stock"),
    "outdoorStorage": MessageLookupByLibrary.simpleMessage("Outdoor Storage"),
    "outdoorYard": MessageLookupByLibrary.simpleMessage("Outdoor Yard"),
    "outstanding": MessageLookupByLibrary.simpleMessage("Outstanding"),
    "overall": MessageLookupByLibrary.simpleMessage("Overall"),
    "overdue": MessageLookupByLibrary.simpleMessage("Overdue"),
    "overdueReturn": MessageLookupByLibrary.simpleMessage("Overdue Return"),
    "ownRequestReviewNote": MessageLookupByLibrary.simpleMessage(
      "This is your own request. Another reviewer must approve or reject it.",
    ),
    "owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "owningDepartment": MessageLookupByLibrary.simpleMessage(
      "Owning Department",
    ),
    "owningStatus": MessageLookupByLibrary.simpleMessage("Owning Status"),
    "owning_department": MessageLookupByLibrary.simpleMessage(
      "Owning Department",
    ),
    "packagingUnpackingStation": MessageLookupByLibrary.simpleMessage(
      "Packaging / Unpacking Station",
    ),
    "page": MessageLookupByLibrary.simpleMessage("Page"),
    "pages": MessageLookupByLibrary.simpleMessage("Pages"),
    "pakistani": MessageLookupByLibrary.simpleMessage("Pakistani"),
    "palauan": MessageLookupByLibrary.simpleMessage("Palauan"),
    "palletSpace": MessageLookupByLibrary.simpleMessage("Pallet Space"),
    "panamanian": MessageLookupByLibrary.simpleMessage("Panamanian"),
    "papuaNewGuinean": MessageLookupByLibrary.simpleMessage(
      "Papua New Guinean",
    ),
    "paraguayan": MessageLookupByLibrary.simpleMessage("Paraguayan"),
    "parent": MessageLookupByLibrary.simpleMessage("Parent"),
    "partTime": MessageLookupByLibrary.simpleMessage("Part-time"),
    "partiallyReceived": MessageLookupByLibrary.simpleMessage(
      "Partially Received",
    ),
    "partiallyRemote": MessageLookupByLibrary.simpleMessage("Partially Remote"),
    "passport": MessageLookupByLibrary.simpleMessage("Passport"),
    "passportExpiration": MessageLookupByLibrary.simpleMessage(
      "Passport Expiration",
    ),
    "passwordAndExpirationTimeUpdatedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Password and Expiration Time Updated Successfully",
        ),
    "passwordMustBeAtLeast8Characters": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters.",
    ),
    "passwordMustContainNumber": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one number.",
    ),
    "passwordMustContainSymbol": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one symbol.",
    ),
    "passwordMustContainUppercase": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one uppercase letter.",
    ),
    "passwordResetLinkSent": MessageLookupByLibrary.simpleMessage(
      "A password reset link has been sent to your email",
    ),
    "passwordResetSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Your password has been reset successfully. Please log in again with your new credentials.",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "paternityLeave": MessageLookupByLibrary.simpleMessage("Paternity Leave"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "paymentMethod": MessageLookupByLibrary.simpleMessage("Payment Method"),
    "paymentType": MessageLookupByLibrary.simpleMessage("Payment Type"),
    "pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "pendingProjects": MessageLookupByLibrary.simpleMessage("Pending Projects"),
    "pendingSubmissions": MessageLookupByLibrary.simpleMessage(
      "Pending Submissions",
    ),
    "performance": MessageLookupByLibrary.simpleMessage("Performance"),
    "permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "permissionControls": MessageLookupByLibrary.simpleMessage(
      "Permission Controls",
    ),
    "permissions": MessageLookupByLibrary.simpleMessage("Permissions"),
    "persianLanguage": MessageLookupByLibrary.simpleMessage("Persian"),
    "personalAccess": MessageLookupByLibrary.simpleMessage("Personal Access"),
    "personalAndBusinessEmailsMustDiffer": MessageLookupByLibrary.simpleMessage(
      "The personal and business emails must be different",
    ),
    "personalBranding": MessageLookupByLibrary.simpleMessage(
      "Personal Branding",
    ),
    "personalData": MessageLookupByLibrary.simpleMessage("Personal Data"),
    "personalEmail": MessageLookupByLibrary.simpleMessage("Personal Email"),
    "personalEmailAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "This personal email is already registered",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Personal Information",
    ),
    "personalLeave": MessageLookupByLibrary.simpleMessage("Personal Leave"),
    "personalLogo": MessageLookupByLibrary.simpleMessage("Personal Logo"),
    "personalizedToDoLists": MessageLookupByLibrary.simpleMessage(
      "Personalized To-Do Lists",
    ),
    "personalizedToDoListsBody": MessageLookupByLibrary.simpleMessage(
      "Our to-do list feature helps you manage your workload efficiently, ensuring you never miss a task. Keep your day structured and focused with intuitive tools designed for your convenience.",
    ),
    "peruvian": MessageLookupByLibrary.simpleMessage("Peruvian"),
    "pestControl": MessageLookupByLibrary.simpleMessage("Pest Control"),
    "phdDegree": MessageLookupByLibrary.simpleMessage("PhD"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "phoneNumberRequired": MessageLookupByLibrary.simpleMessage(
      "Phone Number is required",
    ),
    "phoneRequired": MessageLookupByLibrary.simpleMessage("Phone Required"),
    "photo": MessageLookupByLibrary.simpleMessage("Photo"),
    "pickALocation": MessageLookupByLibrary.simpleMessage("Pick a location"),
    "pickUpDate": MessageLookupByLibrary.simpleMessage("Pick Up Date"),
    "pickup": MessageLookupByLibrary.simpleMessage("Pick Up"),
    "pieChart": MessageLookupByLibrary.simpleMessage("Pie Chart"),
    "pin": MessageLookupByLibrary.simpleMessage("Pin"),
    "pinNotification": MessageLookupByLibrary.simpleMessage("Pin Notification"),
    "pinned": MessageLookupByLibrary.simpleMessage("Pinned"),
    "platformControlsAndManagement": MessageLookupByLibrary.simpleMessage(
      "Platform Controls and Management",
    ),
    "platformRoles": MessageLookupByLibrary.simpleMessage("Platform Roles"),
    "pleaseAddAQuestion": MessageLookupByLibrary.simpleMessage(
      "Please add a question",
    ),
    "pleaseAssignAtLeastOneControl": MessageLookupByLibrary.simpleMessage(
      "Please assign at least one control",
    ),
    "pleaseAttachDocument": MessageLookupByLibrary.simpleMessage(
      "Please attach a document",
    ),
    "pleaseCheckYourInternetConnection": MessageLookupByLibrary.simpleMessage(
      "Please Check Your Internet Connection",
    ),
    "pleaseChooseAStartDate": MessageLookupByLibrary.simpleMessage(
      "Please choose a start date",
    ),
    "pleaseDropAnExcelFileXlsxOrXls": MessageLookupByLibrary.simpleMessage(
      "Please drop an Excel file (.xlsx or .xls)",
    ),
    "pleaseEnableLocationServices": MessageLookupByLibrary.simpleMessage(
      "Please enable location services!",
    ),
    "pleaseEnableMicrophoneService": MessageLookupByLibrary.simpleMessage(
      "Please enable microphone service!",
    ),
    "pleaseEnterAFileName": MessageLookupByLibrary.simpleMessage(
      "Please enter a file name",
    ),
    "pleaseEnterAValidDateInDDMMYYYYFormat":
        MessageLookupByLibrary.simpleMessage(
          "Please enter a valid date in DD/MM/YYYY format.",
        ),
    "pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed":
        MessageLookupByLibrary.simpleMessage(
          "Please enter a valid date of birth. Future dates are not allowed",
        ),
    "pleaseEnterAValidEmailAddressForCommunication":
        MessageLookupByLibrary.simpleMessage(
          "Please enter a valid email address for communication",
        ),
    "pleaseEnterAValidLink": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid link",
    ),
    "pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe":
        MessageLookupByLibrary.simpleMessage(
          "Please enter a valid phone number in the format +[Country Code][Number]",
        ),
    "pleaseEnterApprovalJustification": MessageLookupByLibrary.simpleMessage(
      "Please enter approval justification",
    ),
    "pleaseEnterBothEmailAndPasswordToSignIn":
        MessageLookupByLibrary.simpleMessage(
          "Please enter both email and password to sign in",
        ),
    "pleaseEnterCancelReason": MessageLookupByLibrary.simpleMessage(
      "Please enter a cancellation reason",
    ),
    "pleaseEnterDefaultPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter default password",
    ),
    "pleaseEnterExpirationTime": MessageLookupByLibrary.simpleMessage(
      "Please enter expiration time",
    ),
    "pleaseEnterFileName": MessageLookupByLibrary.simpleMessage(
      "Please enter a file name",
    ),
    "pleaseEnterJustification": MessageLookupByLibrary.simpleMessage(
      "Please enter justification",
    ),
    "pleaseEnterNumbersOnlyMoreThen0": MessageLookupByLibrary.simpleMessage(
      "Please enter numbers only more then 0",
    ),
    "pleaseEnterRejectionReason": MessageLookupByLibrary.simpleMessage(
      "Please enter a rejection reason",
    ),
    "pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the employee\'s job title. It is essential for internal designation",
        ),
    "pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the first name in Arabic. This is a required field for localization purposes.",
        ),
    "pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the last name in Arabic. This is a required field for localization purposes.",
        ),
    "pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the middle name in Arabic. This is a required field for localization purposes.",
        ),
    "pleaseEnterTheOfficeExtensionNumber": MessageLookupByLibrary.simpleMessage(
      "Please enter the office extension number",
    ),
    "pleaseEnterTheTextInArabicLanguage": MessageLookupByLibrary.simpleMessage(
      "Please Enter The Text In Arabic Language",
    ),
    "pleaseEnterTheTextInEnglishLanguage": MessageLookupByLibrary.simpleMessage(
      "Please Enter The Text In English Language",
    ),
    "pleaseEnterTheValidEmail": MessageLookupByLibrary.simpleMessage(
      "Please Enter The valid Email",
    ),
    "pleaseEnterTheValidPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Please Enter The valid Phone Number",
    ),
    "pleaseFillAllRequiredFieldsCorrectly":
        MessageLookupByLibrary.simpleMessage(
          "Please fill all required fields correctly",
        ),
    "pleaseFillInAllRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Please fill in all required fields",
    ),
    "pleaseFixTheHighlightedErrorsBeforeContinuing":
        MessageLookupByLibrary.simpleMessage(
          "Please fix the highlighted errors before continuing",
        ),
    "pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO":
        MessageLookupByLibrary.simpleMessage(
          "Please provide a valid department ID. This field is mandatory for organizational structure.",
        ),
    "pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi":
        MessageLookupByLibrary.simpleMessage(
          "Please provide a valid postal code. It must match the city and province.",
        ),
    "pleaseProvideJustificationForApproval":
        MessageLookupByLibrary.simpleMessage(
          "Please provide a justification for approving this document",
        ),
    "pleaseProvideReasonForRejection": MessageLookupByLibrary.simpleMessage(
      "Please provide a detailed reason for rejecting this document",
    ),
    "pleaseProvideTheDepartmentNameInArabicForBilingualConsi":
        MessageLookupByLibrary.simpleMessage(
          "Please provide the department name in Arabic for bilingual consistency.",
        ),
    "pleaseSelectAControlChampion": MessageLookupByLibrary.simpleMessage(
      "Please select a control champion",
    ),
    "pleaseSelectAControlOwner": MessageLookupByLibrary.simpleMessage(
      "Please select a control owner",
    ),
    "pleaseSelectADate": MessageLookupByLibrary.simpleMessage(
      "Please select a date",
    ),
    "pleaseSelectADateLaterThanTodayForTheNationalIDExpirati":
        MessageLookupByLibrary.simpleMessage(
          "Please select a date later than today for the National ID expiration.",
        ),
    "pleaseSelectANewControlChampion": MessageLookupByLibrary.simpleMessage(
      "Please select a new control champion",
    ),
    "pleaseSelectANewControlOwner": MessageLookupByLibrary.simpleMessage(
      "Please select a new control owner",
    ),
    "pleaseSelectARoleType": MessageLookupByLibrary.simpleMessage(
      "Please select a role type",
    ),
    "pleaseSelectAccessGrantedDate": MessageLookupByLibrary.simpleMessage(
      "Please select access granted date",
    ),
    "pleaseSelectAccessRevokedDate": MessageLookupByLibrary.simpleMessage(
      "Please select access revoked date",
    ),
    "pleaseSelectAnEmployee": MessageLookupByLibrary.simpleMessage(
      "Please select an employee",
    ),
    "pleaseSelectAtLeastOneDepartment": MessageLookupByLibrary.simpleMessage(
      "Please select at least one department",
    ),
    "pleaseSelectAtLeastOneRowToRemove": MessageLookupByLibrary.simpleMessage(
      "Please select at least one row to remove.",
    ),
    "pleaseSelectDocumentType": MessageLookupByLibrary.simpleMessage(
      "Please select a document type",
    ),
    "pleaseSelectEndDate": MessageLookupByLibrary.simpleMessage(
      "Please select end date",
    ),
    "pleaseSelectExactlyOneRowToDuplicate":
        MessageLookupByLibrary.simpleMessage(
          "Please select exactly one row to duplicate.",
        ),
    "pleaseSelectImageInSvgFormat": MessageLookupByLibrary.simpleMessage(
      "Please Select Image In SVG Format",
    ),
    "pleaseSelectOneProviderAtLeast": MessageLookupByLibrary.simpleMessage(
      "Please select at least one provider",
    ),
    "pleaseSelectStartDate": MessageLookupByLibrary.simpleMessage(
      "Please select start date",
    ),
    "pleaseVerifyTheEntry": MessageLookupByLibrary.simpleMessage(
      "! .Please verify the entry",
    ),
    "pleaseWait": MessageLookupByLibrary.simpleMessage(
      "Please wait while we save your data",
    ),
    "pleaseWaitSaving": MessageLookupByLibrary.simpleMessage(
      "Please wait while we save your draft",
    ),
    "please_select_doc_type": MessageLookupByLibrary.simpleMessage(
      "Please select a document type",
    ),
    "pleaseselectadurationunitforreminder":
        MessageLookupByLibrary.simpleMessage(
          "Please select a duration unit for reminder",
        ),
    "pleaseselectafrequencyunit": MessageLookupByLibrary.simpleMessage(
      "Please select a frequency unit",
    ),
    "pleaseselectapriority": MessageLookupByLibrary.simpleMessage(
      "Please select a priority",
    ),
    "pleaseselectatleastoneday": MessageLookupByLibrary.simpleMessage(
      "Please select at least one day",
    ),
    "pleaseselectbothstartdateandstarttime":
        MessageLookupByLibrary.simpleMessage(
          "Please select both start date and start time",
        ),
    "pleaseselectstartdatebeforeenddate": MessageLookupByLibrary.simpleMessage(
      "Please select start date before selecting end date or end time",
    ),
    "pm": MessageLookupByLibrary.simpleMessage("PM"),
    "pointOfContactDetails": MessageLookupByLibrary.simpleMessage(
      "Point Of Contact Details",
    ),
    "policYIesCreated": MessageLookupByLibrary.simpleMessage(
      "Policy(ies) Created",
    ),
    "policies": MessageLookupByLibrary.simpleMessage("Policies"),
    "policy": MessageLookupByLibrary.simpleMessage("Policy"),
    "policyBulkUpload": MessageLookupByLibrary.simpleMessage(
      "Policy Bulk Upload",
    ),
    "policyBulkUploadPreview": MessageLookupByLibrary.simpleMessage(
      "Policy Bulk Upload Preview",
    ),
    "policyCompliance": MessageLookupByLibrary.simpleMessage(
      "Policy Compliance",
    ),
    "policyCreated": MessageLookupByLibrary.simpleMessage("Policy Created"),
    "policyDeleted": MessageLookupByLibrary.simpleMessage("Policy Deleted"),
    "policyDescription": MessageLookupByLibrary.simpleMessage(
      "Policy Description",
    ),
    "policyDescriptionMustBeWrittenInEnglish":
        MessageLookupByLibrary.simpleMessage(
          "Policy description must be written in English",
        ),
    "policyDetails": MessageLookupByLibrary.simpleMessage("Policy Details"),
    "policyDocument": MessageLookupByLibrary.simpleMessage("Policy Document"),
    "policyDocumentAr": MessageLookupByLibrary.simpleMessage(
      "Policy Document (Arabic)",
    ),
    "policyDocumentEng": MessageLookupByLibrary.simpleMessage(
      "Policy Document (English)",
    ),
    "policyName": MessageLookupByLibrary.simpleMessage("Policy Name"),
    "policyName1": MessageLookupByLibrary.simpleMessage("Policy Name 1"),
    "policyName2": MessageLookupByLibrary.simpleMessage("Policy Name 2"),
    "policyName3": MessageLookupByLibrary.simpleMessage("Policy Name 3"),
    "policyName4": MessageLookupByLibrary.simpleMessage("Policy Name 4"),
    "policyName5": MessageLookupByLibrary.simpleMessage("Policy Name 5"),
    "policyName6": MessageLookupByLibrary.simpleMessage("Policy Name 6"),
    "policyNameCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Policy Name cannot be empty",
    ),
    "policyNumber": MessageLookupByLibrary.simpleMessage("Policy Number"),
    "policyNumberAr": MessageLookupByLibrary.simpleMessage("Policy Number Ar"),
    "policyNumberMustBeWrittenInEnglish": MessageLookupByLibrary.simpleMessage(
      "Policy number must be written in English",
    ),
    "policySavedAsDraftSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Policy saved as draft successfully",
    ),
    "policySavedButOneOrMoreControlsFailedToSave":
        MessageLookupByLibrary.simpleMessage(
          "Policy saved, but one or more controls failed to save",
        ),
    "policyUpdated": MessageLookupByLibrary.simpleMessage("Policy Updated"),
    "policyWeight": MessageLookupByLibrary.simpleMessage("Policy Weight"),
    "policyWeightCannotBeMoreThan100": MessageLookupByLibrary.simpleMessage(
      "Policy weight cannot be more than 100",
    ),
    "policyWeightCurrent": MessageLookupByLibrary.simpleMessage(
      "Policy Weight Current",
    ),
    "policyWeightIssue": MessageLookupByLibrary.simpleMessage(
      "Policy Weight Issue",
    ),
    "policyWeightMustBeAPositiveNumber": MessageLookupByLibrary.simpleMessage(
      "Policy weight must be a positive number",
    ),
    "policyWeightMustBeAValidNumber": MessageLookupByLibrary.simpleMessage(
      "Policy weight must be a valid number",
    ),
    "policyWeightPrevious": MessageLookupByLibrary.simpleMessage(
      "Policy Weight Previous",
    ),
    "polish": MessageLookupByLibrary.simpleMessage("Polish"),
    "poll": MessageLookupByLibrary.simpleMessage("Poll"),
    "pollDetails": MessageLookupByLibrary.simpleMessage("Poll Details"),
    "portuguese": MessageLookupByLibrary.simpleMessage("Portuguese"),
    "positionDetails": MessageLookupByLibrary.simpleMessage("Position Details"),
    "positiveQuantityDefaultLocation": MessageLookupByLibrary.simpleMessage(
      "Please enter a positive quantity for the default storage location.",
    ),
    "positiveQuantityLocation": MessageLookupByLibrary.simpleMessage(
      "Please enter a positive quantity for location.",
    ),
    "postalCode": MessageLookupByLibrary.simpleMessage("Postal Code"),
    "postalCodeRequired": MessageLookupByLibrary.simpleMessage(
      "Postal Code is required",
    ),
    "preferredLanguage": MessageLookupByLibrary.simpleMessage(
      "Preferred Language",
    ),
    "preferredLanguageRequired": MessageLookupByLibrary.simpleMessage(
      "Preferred language is required.",
    ),
    "preparingData": MessageLookupByLibrary.simpleMessage("Preparing data..."),
    "preparingDataStructure": MessageLookupByLibrary.simpleMessage(
      "Preparing data structure...",
    ),
    "present": MessageLookupByLibrary.simpleMessage("Present"),
    "presentation": MessageLookupByLibrary.simpleMessage("Presentation"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previewExport": MessageLookupByLibrary.simpleMessage("Preview Export"),
    "previewHealthInsuranceChanges": MessageLookupByLibrary.simpleMessage(
      "Preview Health Insurance",
    ),
    "previewMatches": m20,
    "previewingPolicyAndControls": MessageLookupByLibrary.simpleMessage(
      "Previewing Policy & Controls",
    ),
    "previousControlOwners": MessageLookupByLibrary.simpleMessage(
      "Previous Control Owners",
    ),
    "previousModuleOwners": MessageLookupByLibrary.simpleMessage(
      "Previous Module Owners",
    ),
    "previousOwner": MessageLookupByLibrary.simpleMessage("Previous Owner"),
    "primaryColor": MessageLookupByLibrary.simpleMessage("Primary Color"),
    "priority": MessageLookupByLibrary.simpleMessage("Priority"),
    "priorityHigh": MessageLookupByLibrary.simpleMessage("High"),
    "priorityLow": MessageLookupByLibrary.simpleMessage("Low"),
    "priorityMedium": MessageLookupByLibrary.simpleMessage("Medium"),
    "priorityUrgent": MessageLookupByLibrary.simpleMessage("Urgent"),
    "privacyStatement": MessageLookupByLibrary.simpleMessage(
      "Privacy Statement",
    ),
    "proceed": MessageLookupByLibrary.simpleMessage("Proceed"),
    "processPayroll": MessageLookupByLibrary.simpleMessage("Process Payroll"),
    "processingData": MessageLookupByLibrary.simpleMessage(
      "Processing your data, please wait",
    ),
    "processingFile": MessageLookupByLibrary.simpleMessage(
      "Processing file...",
    ),
    "processingRequest": MessageLookupByLibrary.simpleMessage(
      "Processing request...",
    ),
    "product": MessageLookupByLibrary.simpleMessage("product Name"),
    "productAdded": MessageLookupByLibrary.simpleMessage("Product Added"),
    "productConsumption": MessageLookupByLibrary.simpleMessage(
      "Product Consumption",
    ),
    "productDetails": MessageLookupByLibrary.simpleMessage("Product Details"),
    "productHasBeenUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "The product has been updated successfully",
    ),
    "productID": MessageLookupByLibrary.simpleMessage("Product ID"),
    "productN": MessageLookupByLibrary.simpleMessage("Product"),
    "productName": MessageLookupByLibrary.simpleMessage("Product Name"),
    "productRequests": MessageLookupByLibrary.simpleMessage("Product Requests"),
    "productSpecification": MessageLookupByLibrary.simpleMessage(
      "Product Specification",
    ),
    "productType": MessageLookupByLibrary.simpleMessage("Product Type"),
    "productUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Product Updated Successfully",
    ),
    "productWarranty": MessageLookupByLibrary.simpleMessage("Product Warranty"),
    "products": MessageLookupByLibrary.simpleMessage("Products"),
    "productsDiscrepancy": MessageLookupByLibrary.simpleMessage(
      "Products Discrepancy",
    ),
    "professionalBody": MessageLookupByLibrary.simpleMessage(
      "Professional Body",
    ),
    "professionalCertification": MessageLookupByLibrary.simpleMessage(
      "Professional Certification",
    ),
    "profileChange": MessageLookupByLibrary.simpleMessage("Profile Change"),
    "projectPerformance": MessageLookupByLibrary.simpleMessage(
      "Project Performance",
    ),
    "province": MessageLookupByLibrary.simpleMessage("Province"),
    "publicAccess": MessageLookupByLibrary.simpleMessage("Public Access"),
    "publish": MessageLookupByLibrary.simpleMessage("Publish"),
    "publishDate": MessageLookupByLibrary.simpleMessage("Publish Date: "),
    "publishPolicy": MessageLookupByLibrary.simpleMessage("Publish Policy"),
    "publish_date": MessageLookupByLibrary.simpleMessage("Publish Date"),
    "published": MessageLookupByLibrary.simpleMessage("Published"),
    "publishedBy": MessageLookupByLibrary.simpleMessage("Published By"),
    "published_date": MessageLookupByLibrary.simpleMessage("Published Date"),
    "publishingDate": MessageLookupByLibrary.simpleMessage("Publishing Date: "),
    "purchaseOrder": MessageLookupByLibrary.simpleMessage("Purchase Order"),
    "purposeOfUse": MessageLookupByLibrary.simpleMessage("Purpose Of Use"),
    "pushNotification": MessageLookupByLibrary.simpleMessage(
      "Push Notification",
    ),
    "px": MessageLookupByLibrary.simpleMessage("px"),
    "qar": MessageLookupByLibrary.simpleMessage("QAR"),
    "qatari": MessageLookupByLibrary.simpleMessage("Qatari"),
    "qiyas": MessageLookupByLibrary.simpleMessage("Qiyas"),
    "qiyas1": MessageLookupByLibrary.simpleMessage("Qiyas 1"),
    "qiyas2": MessageLookupByLibrary.simpleMessage("Qiyas 2"),
    "qiyasDashboard": MessageLookupByLibrary.simpleMessage("Qiyas Dashboard"),
    "qualityAssurance": MessageLookupByLibrary.simpleMessage(
      "Quality Assurance",
    ),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "quantityAssigned": MessageLookupByLibrary.simpleMessage(
      "Quantity Assigned",
    ),
    "quantityDensity": MessageLookupByLibrary.simpleMessage(
      "Quantity (Density)",
    ),
    "quarterly": MessageLookupByLibrary.simpleMessage("Quarterly"),
    "question": MessageLookupByLibrary.simpleMessage("Question"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "radialBarChart": MessageLookupByLibrary.simpleMessage("Radial Bar Chart"),
    "radiationProtectedStorage": MessageLookupByLibrary.simpleMessage(
      "Radiation-Protected Storage",
    ),
    "rarely": MessageLookupByLibrary.simpleMessage("Rarely"),
    "ratherNotSay": MessageLookupByLibrary.simpleMessage("Rather Not Say"),
    "reactions": MessageLookupByLibrary.simpleMessage("Reactions"),
    "reactiveUser": MessageLookupByLibrary.simpleMessage("Reactive User"),
    "realTimeTeamChat": MessageLookupByLibrary.simpleMessage(
      "Real-Time Team Chat",
    ),
    "realTimeTeamChatBody": MessageLookupByLibrary.simpleMessage(
      "Streamline communication with direct messaging and group chats, ensuring everyone stays informed and engaged. Our chat functionality fosters quick decision-making and improves overall team productivity.",
    ),
    "reason": MessageLookupByLibrary.simpleMessage("Reason"),
    "reasonForRejection": MessageLookupByLibrary.simpleMessage(
      "Reason for Rejection",
    ),
    "reasonForRequest": MessageLookupByLibrary.simpleMessage(
      "Reason for Request",
    ),
    "reasonMustBeAtLeast10Characters": MessageLookupByLibrary.simpleMessage(
      "Reason must be at least 10 characters",
    ),
    "reasonOfApproval": MessageLookupByLibrary.simpleMessage(
      "Reason of Approval",
    ),
    "reasonOfApprove": MessageLookupByLibrary.simpleMessage(
      "Reason of Approval",
    ),
    "reasonOfEditing": MessageLookupByLibrary.simpleMessage(
      "Reason Of Editing",
    ),
    "reasonOfRejection": MessageLookupByLibrary.simpleMessage(
      "Reason of Rejection",
    ),
    "reasonOfRemoving": MessageLookupByLibrary.simpleMessage(
      "Reason Of Removing",
    ),
    "reasonOfReturn": MessageLookupByLibrary.simpleMessage("Reason Of Return"),
    "reasonsOfCancellation": MessageLookupByLibrary.simpleMessage(
      "Reasons of Cancellation",
    ),
    "reasonsOfRejection": MessageLookupByLibrary.simpleMessage(
      "Reasons of Rejection: ",
    ),
    "reasonsOfRejectionTitle": MessageLookupByLibrary.simpleMessage(
      "Reasons of Rejection",
    ),
    "reassign": MessageLookupByLibrary.simpleMessage("Reassign"),
    "reassignChampion": MessageLookupByLibrary.simpleMessage(
      "Reassign Champion",
    ),
    "reassignControlChampion": MessageLookupByLibrary.simpleMessage(
      "Reassign Control Champion",
    ),
    "reassignControlChampionRequest": MessageLookupByLibrary.simpleMessage(
      "Reassign Control Champion Request",
    ),
    "reassignControlOwner": MessageLookupByLibrary.simpleMessage(
      "Reassign Control Owner",
    ),
    "reassignControlOwnerRequest": MessageLookupByLibrary.simpleMessage(
      "Reassign Control Owner Request",
    ),
    "reassignOwner": MessageLookupByLibrary.simpleMessage("Reassign Owner"),
    "received": MessageLookupByLibrary.simpleMessage("Received"),
    "receivedBy": MessageLookupByLibrary.simpleMessage("Received By"),
    "receivedDate": MessageLookupByLibrary.simpleMessage("Received Date"),
    "receivingDate": MessageLookupByLibrary.simpleMessage("Receiving Date"),
    "receivingMethod": MessageLookupByLibrary.simpleMessage("Receiving Method"),
    "receivingZone": MessageLookupByLibrary.simpleMessage("Receiving Zone"),
    "recentlyContacted": MessageLookupByLibrary.simpleMessage(
      "Recently Contacted",
    ),
    "recommendedAction": MessageLookupByLibrary.simpleMessage(
      "Recommended Action",
    ),
    "recording": MessageLookupByLibrary.simpleMessage("Recording"),
    "red": MessageLookupByLibrary.simpleMessage("Red"),
    "redirecting": MessageLookupByLibrary.simpleMessage("Redirecting..."),
    "registrationDocument": MessageLookupByLibrary.simpleMessage(
      "Registration Document",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "rejectDocument": MessageLookupByLibrary.simpleMessage("Reject Document"),
    "rejectEvidence": MessageLookupByLibrary.simpleMessage("Reject Evidence"),
    "rejectRequest": MessageLookupByLibrary.simpleMessage("Reject Request"),
    "rejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "rejectedDate": MessageLookupByLibrary.simpleMessage("Rejected Date: "),
    "relationship": MessageLookupByLibrary.simpleMessage("Relationship"),
    "relative": MessageLookupByLibrary.simpleMessage("Relative"),
    "remainingQuantity": MessageLookupByLibrary.simpleMessage(
      "Remaining Quantity",
    ),
    "remindAll": MessageLookupByLibrary.simpleMessage("Remind All"),
    "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteStatus": MessageLookupByLibrary.simpleMessage("Remote Status"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removeControlChampion": MessageLookupByLibrary.simpleMessage(
      "Remove Control Champion",
    ),
    "removeControlOwner": MessageLookupByLibrary.simpleMessage(
      "Remove Control Owner",
    ),
    "removeDocuments": MessageLookupByLibrary.simpleMessage("Remove Documents"),
    "removeEmployee": MessageLookupByLibrary.simpleMessage("Remove Employee"),
    "removeKnowledge": MessageLookupByLibrary.simpleMessage("Remove Knowledge"),
    "removeKnowledge_ar": MessageLookupByLibrary.simpleMessage(
      "Delete Knowledge",
    ),
    "removeMember": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "removeSelection": MessageLookupByLibrary.simpleMessage("Remove Selection"),
    "remove_access": MessageLookupByLibrary.simpleMessage("Remove Access"),
    "remove_access_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove access for this employee?",
    ),
    "removed": MessageLookupByLibrary.simpleMessage("Removed"),
    "removedDate": MessageLookupByLibrary.simpleMessage("Removed Date: "),
    "removingDocument": MessageLookupByLibrary.simpleMessage(
      "Removing Document",
    ),
    "removingEmployee": MessageLookupByLibrary.simpleMessage(
      "Removing Employee",
    ),
    "reorderLevel": MessageLookupByLibrary.simpleMessage("Reorder Level"),
    "reorderQuantity": MessageLookupByLibrary.simpleMessage("Reorder Quantity"),
    "reorderingActive": MessageLookupByLibrary.simpleMessage(
      "Reordering Active - Click to Disable",
    ),
    "repair": MessageLookupByLibrary.simpleMessage("Repair"),
    "replacement": MessageLookupByLibrary.simpleMessage("Replacement"),
    "reply": MessageLookupByLibrary.simpleMessage("Reply"),
    "report": MessageLookupByLibrary.simpleMessage("Report"),
    "reportBugs": MessageLookupByLibrary.simpleMessage("Report Bugs"),
    "reportedToPolice": MessageLookupByLibrary.simpleMessage(
      "Reported To Police",
    ),
    "reportingAndAudit": MessageLookupByLibrary.simpleMessage(
      "Reporting and Audit",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requestApproved": MessageLookupByLibrary.simpleMessage("Request Approved"),
    "requestApprovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Request Approved Successfully",
    ),
    "requestAttachments": MessageLookupByLibrary.simpleMessage(
      "Request Attachments",
    ),
    "requestBy": MessageLookupByLibrary.simpleMessage("Request By"),
    "requestCancelation": MessageLookupByLibrary.simpleMessage(
      "Request Cancelation",
    ),
    "requestCancelled": MessageLookupByLibrary.simpleMessage(
      "Request Cancelled",
    ),
    "requestDate": MessageLookupByLibrary.simpleMessage("Request Date"),
    "requestDecisionUnverifiable": MessageLookupByLibrary.simpleMessage(
      "This decision could not be verified, so nothing was saved. Please sign in again and retry.",
    ),
    "requestDescription": MessageLookupByLibrary.simpleMessage(
      "Request Description",
    ),
    "requestDescriptionAr": MessageLookupByLibrary.simpleMessage(
      "Request Description (Arabic)",
    ),
    "requestDescriptionEn": MessageLookupByLibrary.simpleMessage(
      "Request Description (English)",
    ),
    "requestDetails": MessageLookupByLibrary.simpleMessage("Request Details"),
    "requestDone": MessageLookupByLibrary.simpleMessage("Request Done"),
    "requestHasNoAssignedProvider": MessageLookupByLibrary.simpleMessage(
      "This request has no assigned provider",
    ),
    "requestID": MessageLookupByLibrary.simpleMessage("Request ID"),
    "requestId": MessageLookupByLibrary.simpleMessage("Request ID"),
    "requestInProgress": MessageLookupByLibrary.simpleMessage(
      "Request In Progress",
    ),
    "requestName": MessageLookupByLibrary.simpleMessage("Request Name"),
    "requestNameAr": MessageLookupByLibrary.simpleMessage(
      "Request Name (Arabic)",
    ),
    "requestNameEn": MessageLookupByLibrary.simpleMessage(
      "Request Name (English)",
    ),
    "requestNewFeature": MessageLookupByLibrary.simpleMessage(
      "Request New Feature",
    ),
    "requestNote": MessageLookupByLibrary.simpleMessage("Request Note"),
    "requestPosition": MessageLookupByLibrary.simpleMessage("Request Position"),
    "requestRejected": MessageLookupByLibrary.simpleMessage("Request Rejected"),
    "requestRejectedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Request Rejected Successfully",
    ),
    "requestSLAExceed": MessageLookupByLibrary.simpleMessage(
      "Request SLA Exceed",
    ),
    "requestService": MessageLookupByLibrary.simpleMessage("Request Service"),
    "requestServicePermissions": MessageLookupByLibrary.simpleMessage(
      "Request Service Permissions",
    ),
    "requestServicePermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Request Service Permissions Module",
    ),
    "requestStatus": MessageLookupByLibrary.simpleMessage("Request Status"),
    "requestSubmitted": MessageLookupByLibrary.simpleMessage(
      "Request Submitted",
    ),
    "requestSuccess": MessageLookupByLibrary.simpleMessage(
      "Your request has been submitted successfully.",
    ),
    "requestTimeFrame": MessageLookupByLibrary.simpleMessage(
      "Request Time Frame",
    ),
    "requestToCancellation": MessageLookupByLibrary.simpleMessage(
      "Request To Cancellation",
    ),
    "requestToChange": MessageLookupByLibrary.simpleMessage("Request Change"),
    "requestType": MessageLookupByLibrary.simpleMessage("Request Type"),
    "requestTypes": MessageLookupByLibrary.simpleMessage("Request Types"),
    "requestUpdated": MessageLookupByLibrary.simpleMessage("Request Updated"),
    "request_note": MessageLookupByLibrary.simpleMessage("Request Note"),
    "request_submitted": MessageLookupByLibrary.simpleMessage(
      "Request Submitted",
    ),
    "requested": MessageLookupByLibrary.simpleMessage("Requested"),
    "requestedBy": MessageLookupByLibrary.simpleMessage("Requested By"),
    "requestedDate": MessageLookupByLibrary.simpleMessage("Requested Date"),
    "requestedFeedback": MessageLookupByLibrary.simpleMessage(
      "Requested Feedback",
    ),
    "requestedForm": MessageLookupByLibrary.simpleMessage("Requested Form"),
    "requestedMaintenance": MessageLookupByLibrary.simpleMessage(
      "Requested Maintenance",
    ),
    "requestedName": MessageLookupByLibrary.simpleMessage("Requested Name"),
    "requestedService": MessageLookupByLibrary.simpleMessage(
      "Requested Service",
    ),
    "requestedServices": MessageLookupByLibrary.simpleMessage(
      "Requested Services",
    ),
    "requestedServicesModule": MessageLookupByLibrary.simpleMessage(
      "Requested Services Module",
    ),
    "requestedToResetPassword": MessageLookupByLibrary.simpleMessage(
      "Requested To Reset Password ?",
    ),
    "requestingAsset": MessageLookupByLibrary.simpleMessage("Requesting Asset"),
    "requestingResubmit": MessageLookupByLibrary.simpleMessage(
      "Requesting Resubmit",
    ),
    "requesting_a_change": MessageLookupByLibrary.simpleMessage(
      "Requesting A Change",
    ),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsByDepartment": MessageLookupByLibrary.simpleMessage(
      "Requests by Department",
    ),
    "requestsDetails": MessageLookupByLibrary.simpleMessage("Request Details"),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "requiresApproval": MessageLookupByLibrary.simpleMessage(
      "Requires Approval",
    ),
    "requiresApprovals": MessageLookupByLibrary.simpleMessage(
      "Requires Approvals",
    ),
    "requiresAttachments": MessageLookupByLibrary.simpleMessage(
      "Requires Attachments",
    ),
    "requiresDescription": MessageLookupByLibrary.simpleMessage(
      "Requires Description",
    ),
    "reschedule": MessageLookupByLibrary.simpleMessage("Reschedule"),
    "rescheduleMeeting": MessageLookupByLibrary.simpleMessage(
      "Reschedule Meeting",
    ),
    "rescheduled": MessageLookupByLibrary.simpleMessage("Rescheduled"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetBranding": MessageLookupByLibrary.simpleMessage("Reset Branding"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "resetPersonalBranding": MessageLookupByLibrary.simpleMessage(
      "Reset Personal Branding",
    ),
    "resetToCompanyDefaults": MessageLookupByLibrary.simpleMessage(
      "Reset to Company Defaults",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("Reset to Default"),
    "resetYourAccount": MessageLookupByLibrary.simpleMessage(
      "Reset Your Account",
    ),
    "resetYourPassword": MessageLookupByLibrary.simpleMessage(
      "Reset Your Password",
    ),
    "restock": MessageLookupByLibrary.simpleMessage("Restock"),
    "restockAdded": MessageLookupByLibrary.simpleMessage("Restock Added"),
    "restockAddedSuccess": MessageLookupByLibrary.simpleMessage(
      "You successfully added a restock to this product",
    ),
    "restockingProduct": MessageLookupByLibrary.simpleMessage(
      "Restocking Product",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreData": MessageLookupByLibrary.simpleMessage("Restore Data"),
    "restoreForm": MessageLookupByLibrary.simpleMessage("Restore Form"),
    "restoreRequestType": MessageLookupByLibrary.simpleMessage(
      "Are your sure to restore request type?",
    ),
    "restoreToDo": MessageLookupByLibrary.simpleMessage("Restore To Do"),
    "restoredGrcModule": MessageLookupByLibrary.simpleMessage(
      "Restored GRC Module",
    ),
    "restoredModules": MessageLookupByLibrary.simpleMessage("Restored Modules"),
    "restoredSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Restored successfully",
    ),
    "restoringGrcModule": MessageLookupByLibrary.simpleMessage(
      "Restoring GRC Module",
    ),
    "restoringModule": MessageLookupByLibrary.simpleMessage("Restoring Module"),
    "restoringToDo": MessageLookupByLibrary.simpleMessage("Restoring To Do"),
    "restrictedAccess": MessageLookupByLibrary.simpleMessage(
      "Restricted Access",
    ),
    "restrictedLocation": MessageLookupByLibrary.simpleMessage(
      "Restricted Location",
    ),
    "restrictedLocationConfirmSubtitle": MessageLookupByLibrary.simpleMessage(
      "The app will only open in the countries you selected. Access from anywhere else will be blocked.",
    ),
    "restrictedLocationCountriesHint": MessageLookupByLibrary.simpleMessage(
      "Select the countries where the app can be opened",
    ),
    "restrictedLocationSuccessSubtitle": MessageLookupByLibrary.simpleMessage(
      "You successfully updated the allowed countries",
    ),
    "resubmitEvidence": MessageLookupByLibrary.simpleMessage(
      "Resubmit Evidence",
    ),
    "result": MessageLookupByLibrary.simpleMessage("Result"),
    "resultsPermissions": MessageLookupByLibrary.simpleMessage(
      "Results Permissions",
    ),
    "resultsPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Results Permissions Module",
    ),
    "resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "retrieve": MessageLookupByLibrary.simpleMessage("Retrieve"),
    "retrieveProduct": MessageLookupByLibrary.simpleMessage("Retrieve Product"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "returnDate": MessageLookupByLibrary.simpleMessage("Return Date"),
    "returned": MessageLookupByLibrary.simpleMessage("Returned"),
    "review": MessageLookupByLibrary.simpleMessage("Review"),
    "reviewedDate": MessageLookupByLibrary.simpleMessage("Reviewed Date"),
    "riskManagement": MessageLookupByLibrary.simpleMessage("Risk Management"),
    "riskManager": MessageLookupByLibrary.simpleMessage("Risk Manager"),
    "riyadh": MessageLookupByLibrary.simpleMessage("Riyadh"),
    "role": MessageLookupByLibrary.simpleMessage("Role"),
    "roleCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Role created successfully",
    ),
    "roleDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Role deleted successfully",
    ),
    "roleDescription": MessageLookupByLibrary.simpleMessage("Role Description"),
    "roleDescriptionArabic": MessageLookupByLibrary.simpleMessage(
      "Role Description (Arabic)",
    ),
    "roleDetails": MessageLookupByLibrary.simpleMessage("Role Details"),
    "roleInformation": MessageLookupByLibrary.simpleMessage("Role Information"),
    "roleManagement": MessageLookupByLibrary.simpleMessage("Role Management"),
    "roleManagementModule": MessageLookupByLibrary.simpleMessage(
      "Role Management Module",
    ),
    "roleName": MessageLookupByLibrary.simpleMessage("Role Name"),
    "roleNameArabic": MessageLookupByLibrary.simpleMessage(
      "Role Name (Arabic)",
    ),
    "roleNotAssigned": MessageLookupByLibrary.simpleMessage(
      "Role Not Assigned",
    ),
    "rolePermissions": MessageLookupByLibrary.simpleMessage("Role Permissions"),
    "roleSavedAsDraftSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Role saved as draft successfully",
    ),
    "roleStatus": MessageLookupByLibrary.simpleMessage("Role Status"),
    "roleType": MessageLookupByLibrary.simpleMessage("Role Type"),
    "roleUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Role updated successfully",
    ),
    "role_description": MessageLookupByLibrary.simpleMessage(
      "Role Description",
    ),
    "role_description_ar": MessageLookupByLibrary.simpleMessage(
      "Role Description (AR)",
    ),
    "role_name": MessageLookupByLibrary.simpleMessage("Role Name"),
    "role_name_ar": MessageLookupByLibrary.simpleMessage("Role Name (AR)"),
    "roles": MessageLookupByLibrary.simpleMessage("Roles"),
    "rolesExport": MessageLookupByLibrary.simpleMessage("Roles Export"),
    "romanian": MessageLookupByLibrary.simpleMessage("Romanian"),
    "routeNotFound": MessageLookupByLibrary.simpleMessage("Route not found"),
    "routineMaintenance": MessageLookupByLibrary.simpleMessage(
      "Routine Maintenance",
    ),
    "row": MessageLookupByLibrary.simpleMessage("Row"),
    "rowHeading": MessageLookupByLibrary.simpleMessage("Row"),
    "russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "rwandan": MessageLookupByLibrary.simpleMessage("Rwandan"),
    "safety": MessageLookupByLibrary.simpleMessage("Safety"),
    "saintLucian": MessageLookupByLibrary.simpleMessage("Saint Lucian"),
    "salary": MessageLookupByLibrary.simpleMessage("Salary"),
    "sales": MessageLookupByLibrary.simpleMessage("Sales"),
    "salvadoran": MessageLookupByLibrary.simpleMessage("Salvadoran"),
    "samoan": MessageLookupByLibrary.simpleMessage("Samoan"),
    "sanMarinese": MessageLookupByLibrary.simpleMessage("San Marinese"),
    "saoTomean": MessageLookupByLibrary.simpleMessage("Sao Tomean"),
    "sar": MessageLookupByLibrary.simpleMessage("SAR"),
    "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
    "saturdaySunday": MessageLookupByLibrary.simpleMessage("Saturday/Sunday"),
    "saudi": MessageLookupByLibrary.simpleMessage("Saudi"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveAsDraft": MessageLookupByLibrary.simpleMessage("Save as Draft"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saveDraft": MessageLookupByLibrary.simpleMessage("Save Draft"),
    "saveForLater": MessageLookupByLibrary.simpleMessage("Save For Later"),
    "saveForLaterMessage": MessageLookupByLibrary.simpleMessage(
      "Do you want to save it for later?",
    ),
    "savePersonalBranding": MessageLookupByLibrary.simpleMessage(
      "Save Personal Branding",
    ),
    "saveTitle": MessageLookupByLibrary.simpleMessage("Save"),
    "saveTo": MessageLookupByLibrary.simpleMessage("save To"),
    "savedAsDraft": MessageLookupByLibrary.simpleMessage("Saved as Draft"),
    "savedColors": MessageLookupByLibrary.simpleMessage("Saved Colors"),
    "savedToHistory": MessageLookupByLibrary.simpleMessage("Saved to history"),
    "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
    "savingAddresses": MessageLookupByLibrary.simpleMessage(
      "Saving addresses...",
    ),
    "savingContacts": MessageLookupByLibrary.simpleMessage(
      "Saving contacts...",
    ),
    "savingDraft": MessageLookupByLibrary.simpleMessage("Saving Draft..."),
    "savingToDatabase": MessageLookupByLibrary.simpleMessage(
      "Saving to database...",
    ),
    "savingWarehouses": MessageLookupByLibrary.simpleMessage(
      "Saving warehouses...",
    ),
    "schedAbbreviation": MessageLookupByLibrary.simpleMessage("Sched"),
    "schedule": MessageLookupByLibrary.simpleMessage("Schedule"),
    "scheduleAMessage": MessageLookupByLibrary.simpleMessage(
      "Schedule a message",
    ),
    "scheduleForActivate": MessageLookupByLibrary.simpleMessage(
      "Schedule for Activate",
    ),
    "scheduleForDeactivation": MessageLookupByLibrary.simpleMessage(
      "Schedule for Deactivation",
    ),
    "scheduleMessage": MessageLookupByLibrary.simpleMessage("Schedule Message"),
    "scheduleMessages": MessageLookupByLibrary.simpleMessage(
      "Schedule Messages",
    ),
    "scheduleToDeactivate": MessageLookupByLibrary.simpleMessage(
      "Schedule To Deactivate",
    ),
    "scheduleToReactivate": MessageLookupByLibrary.simpleMessage(
      "Schedule To Reactivate",
    ),
    "schedule_publishing": MessageLookupByLibrary.simpleMessage(
      "Schedule Publishing",
    ),
    "scheduled": MessageLookupByLibrary.simpleMessage("Scheduled"),
    "scheduledLeave": MessageLookupByLibrary.simpleMessage("Scheduled Leave"),
    "score": MessageLookupByLibrary.simpleMessage("Score"),
    "scored": MessageLookupByLibrary.simpleMessage("Scored"),
    "scottish": MessageLookupByLibrary.simpleMessage("Scottish"),
    "screenSection": MessageLookupByLibrary.simpleMessage("Screen / Section"),
    "screenShare": MessageLookupByLibrary.simpleMessage("Screen Share"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchCountry": MessageLookupByLibrary.simpleMessage("Search country..."),
    "searchEmployee": MessageLookupByLibrary.simpleMessage(
      "Search employee...",
    ),
    "searchPeople": MessageLookupByLibrary.simpleMessage("Search People"),
    "secReminder": MessageLookupByLibrary.simpleMessage("Second Reminder"),
    "second": MessageLookupByLibrary.simpleMessage("Second"),
    "secondBackup": MessageLookupByLibrary.simpleMessage("Second Backup"),
    "secondContactIncomplete": MessageLookupByLibrary.simpleMessage(
      "Fill in every field of the second emergency contact, or leave it all empty.",
    ),
    "secondContactOptionalHint": MessageLookupByLibrary.simpleMessage(
      "Optional. If you add a second contact, fill in all of its fields.",
    ),
    "secondEmergencyContact": MessageLookupByLibrary.simpleMessage(
      "Second Emergency Contact",
    ),
    "secondEmergencyContact_": MessageLookupByLibrary.simpleMessage(
      "Second Emergency Contact",
    ),
    "secondaryColor": MessageLookupByLibrary.simpleMessage("Secondary Color"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secondsAgo": MessageLookupByLibrary.simpleMessage("Seconds Ago"),
    "secureRestrictedAccess": MessageLookupByLibrary.simpleMessage(
      "Secure / Restricted Access",
    ),
    "secureStorage": MessageLookupByLibrary.simpleMessage("Secure Storage"),
    "secureVault": MessageLookupByLibrary.simpleMessage("Secure Vault"),
    "securityAudit": MessageLookupByLibrary.simpleMessage("Security Audit"),
    "securityCameras": MessageLookupByLibrary.simpleMessage(
      "Security Cameras (CCTV)",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("See All"),
    "seeLess": MessageLookupByLibrary.simpleMessage("See Less"),
    "seeMore": MessageLookupByLibrary.simpleMessage("See More"),
    "seenAndUnseen": MessageLookupByLibrary.simpleMessage("Seen and Unseen"),
    "select": MessageLookupByLibrary.simpleMessage("Select"),
    "selectAccessGranted": MessageLookupByLibrary.simpleMessage(
      "Select Access Granted",
    ),
    "selectAccessRevoked": MessageLookupByLibrary.simpleMessage(
      "Select Access Revoked",
    ),
    "selectAction": MessageLookupByLibrary.simpleMessage("Select Action"),
    "selectActivationDate": MessageLookupByLibrary.simpleMessage(
      "Select Activation Date",
    ),
    "selectAdvancedPayment": MessageLookupByLibrary.simpleMessage(
      "Select Advanced Payment",
    ),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selectArabicFont": MessageLookupByLibrary.simpleMessage(
      "Select Arabic Font",
    ),
    "selectAssetConditions": MessageLookupByLibrary.simpleMessage(
      "Select Asset Conditions",
    ),
    "selectAtLeastOneEmployee": MessageLookupByLibrary.simpleMessage(
      "Please select at least one employee",
    ),
    "selectAtLeastOneRow": MessageLookupByLibrary.simpleMessage(
      "Select at least one row",
    ),
    "selectAttachmentType": MessageLookupByLibrary.simpleMessage(
      "Select Attachment Type",
    ),
    "selectCategory": MessageLookupByLibrary.simpleMessage("Select Category"),
    "selectCity": MessageLookupByLibrary.simpleMessage("Select City"),
    "selectColumn": MessageLookupByLibrary.simpleMessage("Select Column"),
    "selectControl": MessageLookupByLibrary.simpleMessage("Select Control"),
    "selectCountry": MessageLookupByLibrary.simpleMessage("Select Country"),
    "selectDamageType": MessageLookupByLibrary.simpleMessage(
      "Select Damage Type",
    ),
    "selectDate": MessageLookupByLibrary.simpleMessage("Select Date"),
    "selectDeliveryMethod": MessageLookupByLibrary.simpleMessage(
      "Select Delivery Method",
    ),
    "selectDepartment": MessageLookupByLibrary.simpleMessage(
      "Select Department",
    ),
    "selectDepartments": MessageLookupByLibrary.simpleMessage(
      "Select Departments",
    ),
    "selectDesignIssue": MessageLookupByLibrary.simpleMessage(
      "Select design issue",
    ),
    "selectDevice": MessageLookupByLibrary.simpleMessage("Select device"),
    "selectDifferentProduct": MessageLookupByLibrary.simpleMessage(
      "Select Different Product",
    ),
    "selectEndDate": MessageLookupByLibrary.simpleMessage("Select End Date"),
    "selectEndTime": MessageLookupByLibrary.simpleMessage("Select Time"),
    "selectEnglishFont": MessageLookupByLibrary.simpleMessage(
      "Select English Font",
    ),
    "selectExactlyOneRowToDuplicate": MessageLookupByLibrary.simpleMessage(
      "Select exactly one row to duplicate",
    ),
    "selectFileFormat": MessageLookupByLibrary.simpleMessage(
      "Select File Format",
    ),
    "selectFileSource": MessageLookupByLibrary.simpleMessage(
      "Select file source",
    ),
    "selectFrequency": MessageLookupByLibrary.simpleMessage("Select frequency"),
    "selectGender": MessageLookupByLibrary.simpleMessage("Select Gender"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "selectLocation": MessageLookupByLibrary.simpleMessage("Select Location"),
    "selectLogicIssue": MessageLookupByLibrary.simpleMessage(
      "Select logic issue",
    ),
    "selectMethodOfPayment": MessageLookupByLibrary.simpleMessage(
      "Select Method Of Payment",
    ),
    "selectModule": MessageLookupByLibrary.simpleMessage("Select Module"),
    "selectModules": MessageLookupByLibrary.simpleMessage("Select Modules"),
    "selectNationality": MessageLookupByLibrary.simpleMessage(
      "Select Nationality",
    ),
    "selectOrderDate": MessageLookupByLibrary.simpleMessage(
      "Select Order Date",
    ),
    "selectOrderType": MessageLookupByLibrary.simpleMessage(
      "Select Order Type",
    ),
    "selectOwningDepartment": MessageLookupByLibrary.simpleMessage(
      "Select Owning Department",
    ),
    "selectPaymentMethod": MessageLookupByLibrary.simpleMessage(
      "Select Payment Method",
    ),
    "selectPolicy": MessageLookupByLibrary.simpleMessage("Select Policy"),
    "selectProductType": MessageLookupByLibrary.simpleMessage(
      "Select Product Type",
    ),
    "selectReceivingDate": MessageLookupByLibrary.simpleMessage(
      "Select Receiving Date",
    ),
    "selectRecommendedAction": MessageLookupByLibrary.simpleMessage(
      "Select Recommended Action",
    ),
    "selectRequestTypes": MessageLookupByLibrary.simpleMessage(
      "Select Request Types",
    ),
    "selectRole": MessageLookupByLibrary.simpleMessage("Select Role"),
    "selectRoleAndEmployee": MessageLookupByLibrary.simpleMessage(
      "Please select a role and at least one employee",
    ),
    "selectRoleType": MessageLookupByLibrary.simpleMessage(
      "Please select a role type",
    ),
    "selectScreenSection": MessageLookupByLibrary.simpleMessage(
      "Select screen",
    ),
    "selectSeverityLevel": MessageLookupByLibrary.simpleMessage(
      "Select Severity Level",
    ),
    "selectSoftwareType": MessageLookupByLibrary.simpleMessage(
      "Select software type",
    ),
    "selectSpecificTypeOnly": MessageLookupByLibrary.simpleMessage(
      "If you select a specific request type, the approval cycle will only apply to that type, and the remaining request types will not have an approval cycle assigned.",
    ),
    "selectStartDate": MessageLookupByLibrary.simpleMessage(
      "Select Start Date",
    ),
    "selectStartTime": MessageLookupByLibrary.simpleMessage("Select Time"),
    "selectStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Select Storage Location",
    ),
    "selectSubcategory": MessageLookupByLibrary.simpleMessage(
      "Select Subcategory",
    ),
    "selectSupervisor": MessageLookupByLibrary.simpleMessage(
      "Select Supervisor",
    ),
    "selectSupplierName": MessageLookupByLibrary.simpleMessage(
      "Select Supplier Name",
    ),
    "selectTitle": MessageLookupByLibrary.simpleMessage("Select Title"),
    "selectWarrantyCoverageStatus": MessageLookupByLibrary.simpleMessage(
      "Select Warranty & Coverage Status",
    ),
    "selectWorkLocation": MessageLookupByLibrary.simpleMessage(
      "Select Work Location",
    ),
    "selectYear": MessageLookupByLibrary.simpleMessage("Select Year"),
    "select_department": MessageLookupByLibrary.simpleMessage(
      "Select Department",
    ),
    "select_service": MessageLookupByLibrary.simpleMessage("Select Service"),
    "selectdate": MessageLookupByLibrary.simpleMessage("Select Date"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedModules": MessageLookupByLibrary.simpleMessage("Selected modules"),
    "selectpriority": MessageLookupByLibrary.simpleMessage("Select Priority"),
    "selfApprovalBlocked": MessageLookupByLibrary.simpleMessage(
      "You can\'t approve or reject your own request. Another reviewer must decide it.",
    ),
    "semiAnnual": MessageLookupByLibrary.simpleMessage("Semi Annual"),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "sendReminder": MessageLookupByLibrary.simpleMessage("Send Reminder"),
    "senderType": MessageLookupByLibrary.simpleMessage("Sender Type"),
    "senegalese": MessageLookupByLibrary.simpleMessage("Senegalese"),
    "senior": MessageLookupByLibrary.simpleMessage("Senior"),
    "seniorAuditor": MessageLookupByLibrary.simpleMessage("Senior Auditor"),
    "sep": MessageLookupByLibrary.simpleMessage("Sep"),
    "separated": MessageLookupByLibrary.simpleMessage("Separated"),
    "serbian": MessageLookupByLibrary.simpleMessage("Serbian"),
    "servicSOffered": MessageLookupByLibrary.simpleMessage("Services Offered"),
    "service": MessageLookupByLibrary.simpleMessage("Service"),
    "serviceApprovals": MessageLookupByLibrary.simpleMessage(
      "Service Approvals",
    ),
    "serviceDashboard": MessageLookupByLibrary.simpleMessage(
      "Service Dashboard",
    ),
    "serviceDescription": MessageLookupByLibrary.simpleMessage(
      "Service Description",
    ),
    "serviceDetails": MessageLookupByLibrary.simpleMessage("Service Details"),
    "serviceHistory": MessageLookupByLibrary.simpleMessage("Service History"),
    "serviceName": MessageLookupByLibrary.simpleMessage("Service Name"),
    "serviceProvider": MessageLookupByLibrary.simpleMessage("Service Provider"),
    "serviceProviderDetails": MessageLookupByLibrary.simpleMessage(
      "Service Provider Details",
    ),
    "serviceRequested": MessageLookupByLibrary.simpleMessage(
      "Service Requested",
    ),
    "serviceRequester": MessageLookupByLibrary.simpleMessage(
      "Service Requester",
    ),
    "serviceRequests": MessageLookupByLibrary.simpleMessage("Service Requests"),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Service Status"),
    "services": MessageLookupByLibrary.simpleMessage("Services"),
    "servicesControlAndCycle": MessageLookupByLibrary.simpleMessage(
      "Services Control And Cycle",
    ),
    "servicesData": MessageLookupByLibrary.simpleMessage("Services Data"),
    "servicesDeleteDone": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Service",
    ),
    "servicesDone": MessageLookupByLibrary.simpleMessage("services Done"),
    "servicesOffered": MessageLookupByLibrary.simpleMessage("Services Offered"),
    "servicesPermissions": MessageLookupByLibrary.simpleMessage(
      "Services Permissions",
    ),
    "servicesPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Services Permissions Module",
    ),
    "servicesRequestsActivatedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Services & Requests Activated Successfully",
        ),
    "servicesStatus": MessageLookupByLibrary.simpleMessage("Services Status"),
    "servicesUpdated": MessageLookupByLibrary.simpleMessage("Services Updated"),
    "services_app": MessageLookupByLibrary.simpleMessage("Form Builder"),
    "services_comparison": MessageLookupByLibrary.simpleMessage(
      "Services Comparison",
    ),
    "setCRMPermissions": MessageLookupByLibrary.simpleMessage(
      "Set CRM Permissions",
    ),
    "setDate": MessageLookupByLibrary.simpleMessage("Set Date"),
    "setFrequency": MessageLookupByLibrary.simpleMessage("Set Frequency"),
    "setTime": MessageLookupByLibrary.simpleMessage("Set Time"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsModule": MessageLookupByLibrary.simpleMessage("Settings Module"),
    "settingsPermission": MessageLookupByLibrary.simpleMessage(
      "Settings Permission",
    ),
    "severityLevel": MessageLookupByLibrary.simpleMessage("Severity Level"),
    "seychellois": MessageLookupByLibrary.simpleMessage("Seychellois"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareCellphonesInSocialDataInBio": MessageLookupByLibrary.simpleMessage(
      "Share Cellphones In Social Data In Bio",
    ),
    "shareEmailsAndSocialDataInBio": MessageLookupByLibrary.simpleMessage(
      "Share Emails And Social Data In Bio",
    ),
    "shareSocialInformation": MessageLookupByLibrary.simpleMessage(
      "Share Social Information",
    ),
    "shareSomethingAboutYourself": MessageLookupByLibrary.simpleMessage(
      "Share Something About Yourself",
    ),
    "shelf": MessageLookupByLibrary.simpleMessage("Shelf"),
    "shelvingRacking": MessageLookupByLibrary.simpleMessage(
      "Shelving / Racking",
    ),
    "shelvingRackingSystem": MessageLookupByLibrary.simpleMessage(
      "Shelving / Racking System",
    ),
    "shiftBranchRequired": MessageLookupByLibrary.simpleMessage(
      "Please select a branch",
    ),
    "shiftCreationFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to create the shift",
    ),
    "shiftDuplicateWorkingHours": MessageLookupByLibrary.simpleMessage(
      "These working hours have already been added",
    ),
    "shiftLocationRequired": MessageLookupByLibrary.simpleMessage(
      "Please select a location",
    ),
    "shiftStarts": MessageLookupByLibrary.simpleMessage("Shift Starts"),
    "shiftTimesRequired": MessageLookupByLibrary.simpleMessage(
      "Please set the shift start and end times",
    ),
    "shifts": MessageLookupByLibrary.simpleMessage("Shifts"),
    "shiftsManagement": MessageLookupByLibrary.simpleMessage(
      "Shifts Management",
    ),
    "shipping": MessageLookupByLibrary.simpleMessage("Shipping"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showCRMNotifications": MessageLookupByLibrary.simpleMessage(
      "Show CRM Notifications",
    ),
    "showDatabaseNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Database Notifications",
    ),
    "showEmployeesNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Employees Notifications",
    ),
    "showEventsNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Events Notifications",
    ),
    "showFormDetails": MessageLookupByLibrary.simpleMessage(
      "Show form details",
    ),
    "showGRCNotifications": MessageLookupByLibrary.simpleMessage(
      "Show GRC Notifications",
    ),
    "showHRNotifications": MessageLookupByLibrary.simpleMessage(
      "Show HR Notifications",
    ),
    "showInventoryNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Inventory Notifications",
    ),
    "showKnowledgeHubNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Knowledge Hub Notifications",
    ),
    "showMessagesNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Messages Notifications",
    ),
    "showNotesNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Notes Notifications",
    ),
    "showQiyasNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Qiyas Notifications",
    ),
    "showRequestsNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Requests Notifications",
    ),
    "showRolesNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Roles Notifications",
    ),
    "showServicesAppNotifications": MessageLookupByLibrary.simpleMessage(
      "Show services app Notifications",
    ),
    "showServicesNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Services Notifications",
    ),
    "showSettingsNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Settings Notifications",
    ),
    "showTasksNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Tasks Notifications",
    ),
    "showTodoNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Todo Notifications",
    ),
    "showTrackingNotifications": MessageLookupByLibrary.simpleMessage(
      "Show Tracking Notifications",
    ),
    "sibling": MessageLookupByLibrary.simpleMessage("Sibling"),
    "sickLeave": MessageLookupByLibrary.simpleMessage("Sick Leave"),
    "sickVacation": MessageLookupByLibrary.simpleMessage("Sick Vacation"),
    "sierraLeonean": MessageLookupByLibrary.simpleMessage("Sierra Leonean"),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signOut": MessageLookupByLibrary.simpleMessage("Sign Out"),
    "signUpIsNotAvailableInDemoMode": MessageLookupByLibrary.simpleMessage(
      "Sign Up is not available in demo mode.",
    ),
    "signedOutSuccessfully": MessageLookupByLibrary.simpleMessage(
      "You Have Been Signed Out Successfully",
    ),
    "singaporean": MessageLookupByLibrary.simpleMessage("Singaporean"),
    "single": MessageLookupByLibrary.simpleMessage("Single"),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skillLevel": MessageLookupByLibrary.simpleMessage("Skill Level"),
    "skillName": MessageLookupByLibrary.simpleMessage("Skill Name"),
    "skills": MessageLookupByLibrary.simpleMessage("Skills"),
    "skillsHobbies": MessageLookupByLibrary.simpleMessage("Skills Hobbies"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "sla": MessageLookupByLibrary.simpleMessage("SLA"),
    "slovakian": MessageLookupByLibrary.simpleMessage("Slovakian"),
    "slovenian": MessageLookupByLibrary.simpleMessage("Slovenian"),
    "sm_approved": MessageLookupByLibrary.simpleMessage("Approved"),
    "sm_breachedSla": MessageLookupByLibrary.simpleMessage("Breached SLA"),
    "sm_chooseunit": MessageLookupByLibrary.simpleMessage("chooseUnit"),
    "sm_day": MessageLookupByLibrary.simpleMessage("day"),
    "sm_days": MessageLookupByLibrary.simpleMessage("days"),
    "sm_doesnTNeedApproval": MessageLookupByLibrary.simpleMessage(
      "Doesn\'t Need Approval",
    ),
    "sm_done": MessageLookupByLibrary.simpleMessage("Done"),
    "sm_duplicateInfoName": MessageLookupByLibrary.simpleMessage(
      "Duplicate Info Name",
    ),
    "sm_hour": MessageLookupByLibrary.simpleMessage("hour"),
    "sm_hours": MessageLookupByLibrary.simpleMessage("hours"),
    "sm_inprogress": MessageLookupByLibrary.simpleMessage("Inprogress"),
    "sm_minute": MessageLookupByLibrary.simpleMessage("minute"),
    "sm_minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "sm_month": MessageLookupByLibrary.simpleMessage("month"),
    "sm_months": MessageLookupByLibrary.simpleMessage("months"),
    "sm_needApproval": MessageLookupByLibrary.simpleMessage("Need Approval"),
    "sm_noRequestsFound": MessageLookupByLibrary.simpleMessage(
      "No requests found",
    ),
    "sm_second": MessageLookupByLibrary.simpleMessage("second"),
    "sm_seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "sm_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "sm_selected2": MessageLookupByLibrary.simpleMessage("selected"),
    "sm_serviceCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Service Created Successfully",
    ),
    "sm_serviceUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Service Updated Successfully",
    ),
    "sm_unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "sm_unknownUnit": MessageLookupByLibrary.simpleMessage("Unknown Unit"),
    "sm_unspecified": MessageLookupByLibrary.simpleMessage("Unspecified"),
    "sm_week": MessageLookupByLibrary.simpleMessage("week"),
    "sm_weeks": MessageLookupByLibrary.simpleMessage("weeks"),
    "sm_year": MessageLookupByLibrary.simpleMessage("year"),
    "socialInformation": MessageLookupByLibrary.simpleMessage(
      "Social Information",
    ),
    "socialPermissions": MessageLookupByLibrary.simpleMessage(
      "Social Permissions",
    ),
    "socialPermissionsModule": MessageLookupByLibrary.simpleMessage(
      "Social Permissions Module",
    ),
    "software": MessageLookupByLibrary.simpleMessage("Software"),
    "softwareType": MessageLookupByLibrary.simpleMessage("Software Type"),
    "solomonIslander": MessageLookupByLibrary.simpleMessage("Solomon Islander"),
    "somali": MessageLookupByLibrary.simpleMessage("Somali"),
    "someChampionOwnerAssignmentsCouldnTBeSaved":
        MessageLookupByLibrary.simpleMessage(
          "Some champion/owner assignments couldn\'t be saved",
        ),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "southAfrican": MessageLookupByLibrary.simpleMessage("South African"),
    "southKorean": MessageLookupByLibrary.simpleMessage("South Korean"),
    "southSudanese": MessageLookupByLibrary.simpleMessage("South Sudanese"),
    "spacingSizing": MessageLookupByLibrary.simpleMessage("Spacing & Sizing"),
    "spanish": MessageLookupByLibrary.simpleMessage("Spanish"),
    "specialCharsNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Special characters not allowed",
    ),
    "specification": MessageLookupByLibrary.simpleMessage("Specification"),
    "specifiedDoesNotExist": m21,
    "specifiedError": m22,
    "spouse": MessageLookupByLibrary.simpleMessage("Spouse"),
    "sriLankan": MessageLookupByLibrary.simpleMessage("Sri Lankan"),
    "ss": MessageLookupByLibrary.simpleMessage("Edit"),
    "stackedBarChart": MessageLookupByLibrary.simpleMessage(
      "Stacked Bar Chart",
    ),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardStorage": MessageLookupByLibrary.simpleMessage("Standard Storage"),
    "star": MessageLookupByLibrary.simpleMessage("Star"),
    "starredMessages": MessageLookupByLibrary.simpleMessage("Starred Messages"),
    "startDate": MessageLookupByLibrary.simpleMessage("Start Date"),
    "startDateCannotBeAfterThePolicyEndDate":
        MessageLookupByLibrary.simpleMessage(
          "Start date cannot be after the policy end date",
        ),
    "startDateCannotBeBeforeThePolicyStartDate":
        MessageLookupByLibrary.simpleMessage(
          "Start date cannot be before the policy start date",
        ),
    "startShift": MessageLookupByLibrary.simpleMessage("Start Shift"),
    "startTime": MessageLookupByLibrary.simpleMessage("Start Time"),
    "start_date": MessageLookupByLibrary.simpleMessage("Start Date"),
    "startedMessages": MessageLookupByLibrary.simpleMessage("Started Messages"),
    "state": MessageLookupByLibrary.simpleMessage("State or Province"),
    "stateOrProvince": MessageLookupByLibrary.simpleMessage(
      "State or Province",
    ),
    "stateRequired": MessageLookupByLibrary.simpleMessage(
      "State/Province is required.",
    ),
    "statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Status Requested"),
    "statusUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Status updated successfully",
    ),
    "status_approved": MessageLookupByLibrary.simpleMessage("Approved"),
    "status_breached": MessageLookupByLibrary.simpleMessage("Breached SLA"),
    "status_cancel": MessageLookupByLibrary.simpleMessage("Canceled"),
    "status_done": MessageLookupByLibrary.simpleMessage("Done"),
    "status_inprogress": MessageLookupByLibrary.simpleMessage("In progress"),
    "status_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "status_rejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "step2ServiceRequests": MessageLookupByLibrary.simpleMessage(
      "Step 2: Service Requests",
    ),
    "stepsToReproduce": MessageLookupByLibrary.simpleMessage(
      "Steps to reproduce",
    ),
    "stock": MessageLookupByLibrary.simpleMessage("Stock"),
    "stocks": MessageLookupByLibrary.simpleMessage("Stocks"),
    "stocksOverview": MessageLookupByLibrary.simpleMessage("Stocks Overview"),
    "stolen": MessageLookupByLibrary.simpleMessage("Stolen"),
    "storage": MessageLookupByLibrary.simpleMessage("Storage"),
    "storageCapacity": MessageLookupByLibrary.simpleMessage("Storage Capacity"),
    "storageCapacityRequired": MessageLookupByLibrary.simpleMessage(
      "Storage Capacity is required",
    ),
    "storageId": MessageLookupByLibrary.simpleMessage("Storage ID"),
    "storageLocation": MessageLookupByLibrary.simpleMessage("Storage Location"),
    "storageLocationAndQuantity": MessageLookupByLibrary.simpleMessage(
      "Storage Location And Quantity",
    ),
    "storageLocationDetails": MessageLookupByLibrary.simpleMessage(
      "Storage Location Details",
    ),
    "storageLocationID": MessageLookupByLibrary.simpleMessage(
      "Storage Location ID",
    ),
    "storageLocationIDName": MessageLookupByLibrary.simpleMessage(
      "storageLocation Name",
    ),
    "storageLocationId": MessageLookupByLibrary.simpleMessage(
      "Storage Location ID",
    ),
    "storageLocationIdRequired": MessageLookupByLibrary.simpleMessage(
      "Storage Location ID is required",
    ),
    "storageLocations": MessageLookupByLibrary.simpleMessage(
      "Storage Locations",
    ),
    "storageRequirement": MessageLookupByLibrary.simpleMessage(
      "Storage Requirement",
    ),
    "storedOn": MessageLookupByLibrary.simpleMessage("Stored On"),
    "storedProducts": MessageLookupByLibrary.simpleMessage("Stored Products"),
    "strategyAlignment": MessageLookupByLibrary.simpleMessage(
      "Strategy & Alignment",
    ),
    "streamlinedRequests": MessageLookupByLibrary.simpleMessage(
      "Streamlined Requests",
    ),
    "streamlinedRequestsBody": MessageLookupByLibrary.simpleMessage(
      "Simplify the process of submitting, tracking, and managing requests within your organization. Our intuitive system ensures that all requests are handled promptly and efficiently, keeping everyone informed and on the same page.",
    ),
    "street": MessageLookupByLibrary.simpleMessage("Street"),
    "streetAddress": MessageLookupByLibrary.simpleMessage("Street Address"),
    "streetName": MessageLookupByLibrary.simpleMessage("Street Name"),
    "streetNameRequired": MessageLookupByLibrary.simpleMessage(
      "Street Name is required",
    ),
    "structure": MessageLookupByLibrary.simpleMessage("Structure"),
    "subcategory": MessageLookupByLibrary.simpleMessage("Subcategory"),
    "subject": MessageLookupByLibrary.simpleMessage("Subject"),
    "submission": MessageLookupByLibrary.simpleMessage("Submission"),
    "submissionDate": MessageLookupByLibrary.simpleMessage("Submission Date"),
    "submissionDetails": MessageLookupByLibrary.simpleMessage(
      "Submission Details",
    ),
    "submissionForm": MessageLookupByLibrary.simpleMessage("Submission Form"),
    "submissionNote": MessageLookupByLibrary.simpleMessage("Submission Note"),
    "submissionNotes": MessageLookupByLibrary.simpleMessage("Submission Notes"),
    "submissions": MessageLookupByLibrary.simpleMessage("Submissions"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "submitEvidence": MessageLookupByLibrary.simpleMessage("Submit Evidence"),
    "submitForApproval": MessageLookupByLibrary.simpleMessage(
      "Submit For Approval",
    ),
    "submitForm": MessageLookupByLibrary.simpleMessage("Submit Form"),
    "submitRequest": MessageLookupByLibrary.simpleMessage("Submit Request"),
    "submit_for_approval": MessageLookupByLibrary.simpleMessage(
      "Submit For Approval",
    ),
    "submit_success_message": MessageLookupByLibrary.simpleMessage(
      "You Successfully Submitted For Approval",
    ),
    "submitted": MessageLookupByLibrary.simpleMessage("Submitted"),
    "submittedDate": MessageLookupByLibrary.simpleMessage("Submitted Date: "),
    "submittedTransaction": MessageLookupByLibrary.simpleMessage(
      "Submitted Transaction",
    ),
    "submittedTransactionMessage": MessageLookupByLibrary.simpleMessage(
      "You Successfully Submitted This Transaction",
    ),
    "submitting": MessageLookupByLibrary.simpleMessage("Submitting..."),
    "subscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subtitle": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Control?",
    ),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "successAddAsset": MessageLookupByLibrary.simpleMessage(
      "You Successfully Added This Asset",
    ),
    "successAssignAsset": MessageLookupByLibrary.simpleMessage(
      "You successfully assigned this asset",
    ),
    "successChangeServiceProvider": MessageLookupByLibrary.simpleMessage(
      "You Successfully Changed Service Provider",
    ),
    "successCheckOutMessage": MessageLookupByLibrary.simpleMessage(
      "You Successfully Checked Out",
    ),
    "successCheckedInMessage": MessageLookupByLibrary.simpleMessage(
      "You Successfully Checked In",
    ),
    "successCreateRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully created this request.",
    ),
    "successDownloadFile": MessageLookupByLibrary.simpleMessage(
      "File downloaded successfully",
    ),
    "successDownloadPage": MessageLookupByLibrary.simpleMessage(
      "You Successfully download This page",
    ),
    "successEqualWeight": MessageLookupByLibrary.simpleMessage(
      "You Have Successfully Assigned Equal Weight To All Controls",
    ),
    "successLocationMessage": MessageLookupByLibrary.simpleMessage(
      "Your Location Matches the Company’s Location",
    ),
    "successMessage": MessageLookupByLibrary.simpleMessage(
      "Your data has been successfully updated",
    ),
    "successRetrieveProduct": MessageLookupByLibrary.simpleMessage(
      "You successfully retrieved this product",
    ),
    "successSavingDraft": MessageLookupByLibrary.simpleMessage(
      "Draft saved successfully",
    ),
    "successSubtitle": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This GRC Control",
    ),
    "successTitle": MessageLookupByLibrary.simpleMessage("Creating Control"),
    "successful": MessageLookupByLibrary.simpleMessage("Successful"),
    "successfulRequestCancelation": MessageLookupByLibrary.simpleMessage(
      "You Successfully Requested Cancelation For This Request",
    ),
    "successfulRequestSubmission": MessageLookupByLibrary.simpleMessage(
      "Your Request Has Been Successfully Submitted",
    ),
    "successfulRequestTypeCreate": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Request Type",
    ),
    "successfulRequestTypeDelete": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Request Type",
    ),
    "successfulRequestTypeEdit": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Request Type",
    ),
    "successfulStatusChange": MessageLookupByLibrary.simpleMessage(
      "You Successfully Changed the Status Of This Request Type",
    ),
    "successfully": MessageLookupByLibrary.simpleMessage("Successfully"),
    "successfullyActivated": MessageLookupByLibrary.simpleMessage(
      "You Successfully Activated These Services",
    ),
    "successfullyChangedStatus": MessageLookupByLibrary.simpleMessage(
      "You Successfully Changed the Status Of This Module",
    ),
    "successfullyCreatedGrc": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This GRC Module",
    ),
    "successfullyCreatedService": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Service",
    ),
    "successfullyDeletedControl": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Control",
    ),
    "successfullyDeletedGrc": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Module",
    ),
    "successfullyDeletedSupplier": MessageLookupByLibrary.simpleMessage(
      "The supplier has been successfully deleted from the system.",
    ),
    "successfullyDraftedService": MessageLookupByLibrary.simpleMessage(
      "You Successfully Drafted This Service",
    ),
    "successfullyEditedEmployeeShift": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Employee\'s Shift",
    ),
    "successfullyEditedEmployeesShifts": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited These Employees\' Shifts",
    ),
    "successfullyEditedGrc": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Module",
    ),
    "successfullyEditedService": MessageLookupByLibrary.simpleMessage(
      "You successfully edited this service.",
    ),
    "successfullyEditedSupplier": MessageLookupByLibrary.simpleMessage(
      "You successfully edited this supplier",
    ),
    "successfullyFetchedSpecificKnowledge":
        MessageLookupByLibrary.simpleMessage(
          "Successfully fetched specific knowledge",
        ),
    "successfullyRequestedAsset": MessageLookupByLibrary.simpleMessage(
      "You successfully requested this asset",
    ),
    "successfullyRestoredGrc": MessageLookupByLibrary.simpleMessage(
      "You Successfully Restored This Module",
    ),
    "successfullyRestoredModule": MessageLookupByLibrary.simpleMessage(
      "Successfully Restored Module",
    ),
    "successfully_submitted_request": MessageLookupByLibrary.simpleMessage(
      "You Successfully Submitted This Request",
    ),
    "sudanese": MessageLookupByLibrary.simpleMessage("Sudanese"),
    "summary": MessageLookupByLibrary.simpleMessage("Summary"),
    "sunday": MessageLookupByLibrary.simpleMessage("Sunday"),
    "sundayMonday": MessageLookupByLibrary.simpleMessage("Sunday/Monday"),
    "superVisor": MessageLookupByLibrary.simpleMessage("SuperVisor"),
    "supervisor": MessageLookupByLibrary.simpleMessage("Supervisor"),
    "supplier": MessageLookupByLibrary.simpleMessage("Supplier"),
    "supplierAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "You Successfully Added This Supplier",
    ),
    "supplierBankTransferDetails": MessageLookupByLibrary.simpleMessage(
      "Supplier Bank Transfer Details",
    ),
    "supplierDeleted": MessageLookupByLibrary.simpleMessage("Supplier Deleted"),
    "supplierDetails": MessageLookupByLibrary.simpleMessage("Supplier Details"),
    "supplierEdited": MessageLookupByLibrary.simpleMessage("Supplier Edited"),
    "supplierID": MessageLookupByLibrary.simpleMessage("Supplier ID"),
    "supplierId": MessageLookupByLibrary.simpleMessage("Supplier ID"),
    "supplierIdRequired": MessageLookupByLibrary.simpleMessage(
      "Supplier ID is required",
    ),
    "supplierName": MessageLookupByLibrary.simpleMessage("Supplier Name"),
    "supplierNameRequired": MessageLookupByLibrary.simpleMessage(
      "Supplier Name is required",
    ),
    "supplierRank": MessageLookupByLibrary.simpleMessage("Supplier Rank"),
    "suppliers": MessageLookupByLibrary.simpleMessage("Suppliers"),
    "surinamer": MessageLookupByLibrary.simpleMessage("Surinamer"),
    "swazi": MessageLookupByLibrary.simpleMessage("Swazi"),
    "swedish": MessageLookupByLibrary.simpleMessage("Swedish"),
    "swiftCode": MessageLookupByLibrary.simpleMessage("Bank SWIFT/BIC Code"),
    "swiftCodeRequired": MessageLookupByLibrary.simpleMessage(
      "SWIFT/BIC code is required.",
    ),
    "swipeLeftToCancel": MessageLookupByLibrary.simpleMessage(
      "Swipe Left To Cancel",
    ),
    "swiss": MessageLookupByLibrary.simpleMessage("Swiss"),
    "syp": MessageLookupByLibrary.simpleMessage("SYP"),
    "syrian": MessageLookupByLibrary.simpleMessage("Syrian"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemManagements": MessageLookupByLibrary.simpleMessage(
      "System Managements",
    ),
    "systemsLogs": MessageLookupByLibrary.simpleMessage("Systems Logs"),
    "table": MessageLookupByLibrary.simpleMessage("Table"),
    "tableChart": MessageLookupByLibrary.simpleMessage("Table chart"),
    "tabletView": MessageLookupByLibrary.simpleMessage("Tablet View"),
    "tabulated": MessageLookupByLibrary.simpleMessage("Tabulated"),
    "tagalogLanguage": MessageLookupByLibrary.simpleMessage("Tagalog"),
    "taiwanese": MessageLookupByLibrary.simpleMessage("Taiwanese"),
    "tajik": MessageLookupByLibrary.simpleMessage("Tajik"),
    "takeScreenShot": MessageLookupByLibrary.simpleMessage("Take Screen Shot"),
    "takeScreenshot": MessageLookupByLibrary.simpleMessage("Take Screenshot"),
    "tanzanian": MessageLookupByLibrary.simpleMessage("Tanzanian"),
    "tapAndHoldOnAMessageToStarItAndItWillShowUpHere":
        MessageLookupByLibrary.simpleMessage(
          "Tap and hold on a message to star it, and it will show up here.",
        ),
    "taskDetails": MessageLookupByLibrary.simpleMessage("Task Details"),
    "taskReminder": MessageLookupByLibrary.simpleMessage("Task Reminder"),
    "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "tasksresponsivepage": MessageLookupByLibrary.simpleMessage(
      "TasksResponsivePage",
    ),
    "taxCertificate": MessageLookupByLibrary.simpleMessage("Tax Certificate"),
    "taxNumber": MessageLookupByLibrary.simpleMessage("Tax Number"),
    "taxNumberRequired": MessageLookupByLibrary.simpleMessage(
      "Tax Number is required",
    ),
    "teamDepartments": MessageLookupByLibrary.simpleMessage("Team Departments"),
    "teamLead": MessageLookupByLibrary.simpleMessage("Team Lead"),
    "techTeam": MessageLookupByLibrary.simpleMessage("Tech Team"),
    "technician": MessageLookupByLibrary.simpleMessage("Technician"),
    "temperatureControl": MessageLookupByLibrary.simpleMessage(
      "Temperature Control",
    ),
    "temperatureControlled": MessageLookupByLibrary.simpleMessage(
      "Temperature-Controlled",
    ),
    "temperatureMonitoringDevices": MessageLookupByLibrary.simpleMessage(
      "Temperature Monitoring Devices",
    ),
    "termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions",
    ),
    "termsAndConditions2": MessageLookupByLibrary.simpleMessage(
      "Terms And Conditions",
    ),
    "test": MessageLookupByLibrary.simpleMessage("Draft"),
    "textColor": MessageLookupByLibrary.simpleMessage("Text Color"),
    "textFont": MessageLookupByLibrary.simpleMessage("Text & Font"),
    "textHere": MessageLookupByLibrary.simpleMessage("Text here"),
    "th": MessageLookupByLibrary.simpleMessage("th"),
    "thai": MessageLookupByLibrary.simpleMessage("Thai"),
    "thankYou": MessageLookupByLibrary.simpleMessage("Thank You"),
    "thanksForSharingYourFeedback": MessageLookupByLibrary.simpleMessage(
      "Thanks for sharing your feedback",
    ),
    "theBackupHasBeenRestoredSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "The backup has been restored successfully",
        ),
    "theDataForThisFieldIsEmpty": MessageLookupByLibrary.simpleMessage(
      "The data for this field is empty.",
    ),
    "theDepartmentIDMustBeNumericAndContainNoLetters":
        MessageLookupByLibrary.simpleMessage(
          "The Department ID must be numeric and contain no letters",
        ),
    "theDocumentHasBeenApproved": MessageLookupByLibrary.simpleMessage(
      "The document has been approved and will be published",
    ),
    "theDocumentHasBeenRejected": MessageLookupByLibrary.simpleMessage(
      "The document has been rejected and the creator will be notified",
    ),
    "theEmailMustFollowTheFormatUserDomainCom":
        MessageLookupByLibrary.simpleMessage(
          "The email must follow the format user@domain.com",
        ),
    "theExcelFileIsNotAccepted": MessageLookupByLibrary.simpleMessage(
      "The Excel file is not accepted.",
    ),
    "thePhoneNumberMustBeBetween8And15Digit":
        MessageLookupByLibrary.simpleMessage(
          "The phone number must be between 8 and 15 digit",
        ),
    "theRequestHasBeenApprovedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "The request has been approved successfully",
        ),
    "theRequestHasBeenRejectedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "The request has been rejected successfully",
        ),
    "theRequestHasBeenUpdatedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "The request has been updated successfully",
        ),
    "theSpecified": MessageLookupByLibrary.simpleMessage("The specified"),
    "thirdReminder": MessageLookupByLibrary.simpleMessage("Third Reminder"),
    "thisEmailNotFound": MessageLookupByLibrary.simpleMessage(
      "This Email Not Found",
    ),
    "thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi":
        MessageLookupByLibrary.simpleMessage(
          "This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted.",
        ),
    "thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2":
        MessageLookupByLibrary.simpleMessage(
          "This field accepts Arabic only. Please provide your entry in Arabic script; entries in any other language cannot be accepted",
        ),
    "thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl":
        MessageLookupByLibrary.simpleMessage(
          "This field accepts English only. Please provide your entry in English script; entries in any other language cannot be accepted.",
        ),
    "thisFieldIsRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "thisModuleIsNotAvailable": MessageLookupByLibrary.simpleMessage(
      "This module is not available",
    ),
    "thisMonth": MessageLookupByLibrary.simpleMessage("This Month"),
    "thisRequestTypeIsNotSupportedYet": MessageLookupByLibrary.simpleMessage(
      "This request type is not supported yet",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("This Week"),
    "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeTracker": MessageLookupByLibrary.simpleMessage("Time Tracker"),
    "timeTrackerAbsence": MessageLookupByLibrary.simpleMessage("Absence"),
    "timeTrackerAbsencesCount": m23,
    "timeTrackerAbsencesFew": m24,
    "timeTrackerAbsencesMany": m25,
    "timeTrackerAbsent": MessageLookupByLibrary.simpleMessage("Absent"),
    "timeTrackerAbsentToday": MessageLookupByLibrary.simpleMessage(
      "Absent Today",
    ),
    "timeTrackerAccessGranted": MessageLookupByLibrary.simpleMessage(
      "You Successfully Granted Access",
    ),
    "timeTrackerAccessGrantedTitle": MessageLookupByLibrary.simpleMessage(
      "Access Granted",
    ),
    "timeTrackerActionFailed": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "timeTrackerActivateLocationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Activate This Location ?",
    ),
    "timeTrackerActivateRequestTypeConfirm":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Activate This Request Type ?",
        ),
    "timeTrackerActive": MessageLookupByLibrary.simpleMessage("Active"),
    "timeTrackerAddedBy": MessageLookupByLibrary.simpleMessage("Added By"),
    "timeTrackerAddressNotFound": MessageLookupByLibrary.simpleMessage(
      "No place was found for this address. Try a fuller address, or tap the map.",
    ),
    "timeTrackerAll": MessageLookupByLibrary.simpleMessage("All"),
    "timeTrackerAllClear": MessageLookupByLibrary.simpleMessage(
      "Nothing needs your attention right now.",
    ),
    "timeTrackerAllDay": MessageLookupByLibrary.simpleMessage("All Day"),
    "timeTrackerAllEmployees": MessageLookupByLibrary.simpleMessage(
      "All Employees",
    ),
    "timeTrackerAllowBreaks": MessageLookupByLibrary.simpleMessage(
      "Allow Breaks In Attendance",
    ),
    "timeTrackerAllowDifferentLocation": MessageLookupByLibrary.simpleMessage(
      "Allow Different Work Location",
    ),
    "timeTrackerAllowGeofence": MessageLookupByLibrary.simpleMessage(
      "Allow Geofence",
    ),
    "timeTrackerAllowPause": MessageLookupByLibrary.simpleMessage(
      "Allow Pause",
    ),
    "timeTrackerAllowedLocationsRequired": MessageLookupByLibrary.simpleMessage(
      "Choose at least one location.",
    ),
    "timeTrackerAlreadyCheckedOut": MessageLookupByLibrary.simpleMessage(
      "You have already checked out. The screen now shows your latest attendance.",
    ),
    "timeTrackerApprovalCycle": MessageLookupByLibrary.simpleMessage(
      "Approval Cycle",
    ),
    "timeTrackerApprovalPermissions": MessageLookupByLibrary.simpleMessage(
      "Approvals",
    ),
    "timeTrackerApprovalsAllDepartments": MessageLookupByLibrary.simpleMessage(
      "Approvals — All Departments",
    ),
    "timeTrackerApproveAndReject": MessageLookupByLibrary.simpleMessage(
      "Approve And Reject",
    ),
    "timeTrackerApproveCancellation": MessageLookupByLibrary.simpleMessage(
      "Approve Cancellation",
    ),
    "timeTrackerApproveCancellationConfirm":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Approve The Cancellation Of This Request ?",
        ),
    "timeTrackerApproveRequest": MessageLookupByLibrary.simpleMessage(
      "Approve Request",
    ),
    "timeTrackerApproveRequestConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Approve This Request ?",
    ),
    "timeTrackerApproved": MessageLookupByLibrary.simpleMessage("Approved"),
    "timeTrackerArabicNameRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the Arabic name.",
    ),
    "timeTrackerAssign": MessageLookupByLibrary.simpleMessage("Assign"),
    "timeTrackerAssignCount": m26,
    "timeTrackerAssignDate": m27,
    "timeTrackerAssignDateLabel": MessageLookupByLibrary.simpleMessage(
      "Assign Date",
    ),
    "timeTrackerAssignEmployee": MessageLookupByLibrary.simpleMessage(
      "Assign Employee",
    ),
    "timeTrackerAssigned": MessageLookupByLibrary.simpleMessage("Assigned"),
    "timeTrackerAssignedEmployees": MessageLookupByLibrary.simpleMessage(
      "Assigned Employees",
    ),
    "timeTrackerAssignmentRemoved": MessageLookupByLibrary.simpleMessage(
      "You Successfully Removed This Employee\'s Assignment",
    ),
    "timeTrackerAssignmentRemovedTitle": MessageLookupByLibrary.simpleMessage(
      "Assignment Removed",
    ),
    "timeTrackerAttachments": MessageLookupByLibrary.simpleMessage(
      "Attachments",
    ),
    "timeTrackerAttachmentsRequired": MessageLookupByLibrary.simpleMessage(
      "This request type needs an attachment.",
    ),
    "timeTrackerAttendanceChanged": MessageLookupByLibrary.simpleMessage(
      "Your attendance was changed on another screen or device. It has been refreshed, please check it and try again.",
    ),
    "timeTrackerAttendanceDate": MessageLookupByLibrary.simpleMessage(
      "Attendance Date",
    ),
    "timeTrackerAttendanceExportName": MessageLookupByLibrary.simpleMessage(
      "Attendance",
    ),
    "timeTrackerAttendanceHistory": MessageLookupByLibrary.simpleMessage(
      "Attendance History",
    ),
    "timeTrackerAttendancePermissions": MessageLookupByLibrary.simpleMessage(
      "Attendance",
    ),
    "timeTrackerAttendanceUpdatedTitle": MessageLookupByLibrary.simpleMessage(
      "Attendance Updated",
    ),
    "timeTrackerBreak": MessageLookupByLibrary.simpleMessage("Break"),
    "timeTrackerBreakLengthHint": MessageLookupByLibrary.simpleMessage("30"),
    "timeTrackerBreakLengthRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the break length.",
    ),
    "timeTrackerBreakTime": MessageLookupByLibrary.simpleMessage("Break Time"),
    "timeTrackerBreaksMinutes": m28,
    "timeTrackerCancelRequest": MessageLookupByLibrary.simpleMessage(
      "Cancel Request",
    ),
    "timeTrackerCancelRequestAfterApproving":
        MessageLookupByLibrary.simpleMessage("Cancel Request After Approving"),
    "timeTrackerCancelRequestConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Cancel This Request ?",
    ),
    "timeTrackerCancelTransaction": MessageLookupByLibrary.simpleMessage(
      "Cancel Transaction",
    ),
    "timeTrackerCanceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "timeTrackerCanceledByHr": MessageLookupByLibrary.simpleMessage(
      "Canceled By HR",
    ),
    "timeTrackerCancellationApproved": MessageLookupByLibrary.simpleMessage(
      "You Successfully Approved The Cancellation Of This Request",
    ),
    "timeTrackerCancellationApprovedTitle":
        MessageLookupByLibrary.simpleMessage("Cancellation Approved"),
    "timeTrackerCancellationRejected": MessageLookupByLibrary.simpleMessage(
      "The Request Stays Approved",
    ),
    "timeTrackerCancellationRejectedTitle":
        MessageLookupByLibrary.simpleMessage("Cancellation Rejected"),
    "timeTrackerCancellationRequested": MessageLookupByLibrary.simpleMessage(
      "You Successfully Requested Cancellation For This Request",
    ),
    "timeTrackerChangeLocationStatus": MessageLookupByLibrary.simpleMessage(
      "Change Location Status",
    ),
    "timeTrackerChangeRequestTypeStatus": MessageLookupByLibrary.simpleMessage(
      "Change Request Type Status",
    ),
    "timeTrackerChangingStatus": MessageLookupByLibrary.simpleMessage(
      "Changing Status",
    ),
    "timeTrackerChartAttendanceSummary": MessageLookupByLibrary.simpleMessage(
      "Attendance Summary",
    ),
    "timeTrackerChartLateArrivalsHistory": MessageLookupByLibrary.simpleMessage(
      "Late Arrivals History",
    ),
    "timeTrackerChartMonthlyAttendance": MessageLookupByLibrary.simpleMessage(
      "Monthly Attendance History",
    ),
    "timeTrackerChartMonthlyRequestsByType":
        MessageLookupByLibrary.simpleMessage("Monthly Requests By Type"),
    "timeTrackerChartMonthlyRequestsVolume":
        MessageLookupByLibrary.simpleMessage("Monthly Requests Volume"),
    "timeTrackerChartRequestsByStatus": MessageLookupByLibrary.simpleMessage(
      "Requests By Status",
    ),
    "timeTrackerChartRequestsByType": MessageLookupByLibrary.simpleMessage(
      "Requests By Type",
    ),
    "timeTrackerChartWorkLocationDistribution":
        MessageLookupByLibrary.simpleMessage("Work Location Distribution"),
    "timeTrackerCheckIn": MessageLookupByLibrary.simpleMessage("Check In"),
    "timeTrackerCheckInAndOut": MessageLookupByLibrary.simpleMessage(
      "Check In And Out",
    ),
    "timeTrackerCheckInAvailable": MessageLookupByLibrary.simpleMessage(
      "You can check in and out.",
    ),
    "timeTrackerCheckInDate": MessageLookupByLibrary.simpleMessage(
      "Check In Date",
    ),
    "timeTrackerCheckInPermissions": MessageLookupByLibrary.simpleMessage(
      "Check In & Out",
    ),
    "timeTrackerCheckInRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the check-in date and time.",
    ),
    "timeTrackerCheckInTime": MessageLookupByLibrary.simpleMessage(
      "Check In Time",
    ),
    "timeTrackerCheckOut": MessageLookupByLibrary.simpleMessage("Check Out"),
    "timeTrackerCheckOutAfterCheckIn": MessageLookupByLibrary.simpleMessage(
      "Check out must be after check in.",
    ),
    "timeTrackerCheckOutConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Check Out ?",
    ),
    "timeTrackerCheckOutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Checking Out",
    ),
    "timeTrackerCheckOutDate": MessageLookupByLibrary.simpleMessage(
      "Check Out Date",
    ),
    "timeTrackerCheckOutRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the check-out date and time.",
    ),
    "timeTrackerCheckOutSameDay": MessageLookupByLibrary.simpleMessage(
      "The check-out must be on the same day as the check-in",
    ),
    "timeTrackerCheckOutSameOrNextDay": MessageLookupByLibrary.simpleMessage(
      "The check-out must be on the check-in day or the next day",
    ),
    "timeTrackerCheckOutTime": MessageLookupByLibrary.simpleMessage(
      "Check Out Time",
    ),
    "timeTrackerCheckedInNoCheckOut": m29,
    "timeTrackerCheckedInNow": MessageLookupByLibrary.simpleMessage(
      "Checked In Now",
    ),
    "timeTrackerCheckedInSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Checked In",
    ),
    "timeTrackerCheckedOutSuccess": MessageLookupByLibrary.simpleMessage(
      "You Successfully Checked Out",
    ),
    "timeTrackerChooseEmployee": MessageLookupByLibrary.simpleMessage(
      "Choose Employee",
    ),
    "timeTrackerChooseHere": MessageLookupByLibrary.simpleMessage(
      "Choose Here",
    ),
    "timeTrackerChooseLocation": MessageLookupByLibrary.simpleMessage(
      "Choose Location",
    ),
    "timeTrackerChooseMembers": MessageLookupByLibrary.simpleMessage(
      "Choose Members",
    ),
    "timeTrackerChooseOneDepartment": MessageLookupByLibrary.simpleMessage(
      "Choose at least one department, or switch the limit off.",
    ),
    "timeTrackerChooseOneLocation": MessageLookupByLibrary.simpleMessage(
      "Choose at least one location, or switch the limit off.",
    ),
    "timeTrackerChooseTheDate": MessageLookupByLibrary.simpleMessage(
      "Choose The Date",
    ),
    "timeTrackerChooseType": MessageLookupByLibrary.simpleMessage(
      "Choose Type",
    ),
    "timeTrackerChooseWorkLocation": MessageLookupByLibrary.simpleMessage(
      "Choose Work Location",
    ),
    "timeTrackerCity": MessageLookupByLibrary.simpleMessage("City"),
    "timeTrackerCityAr": MessageLookupByLibrary.simpleMessage("مدينة"),
    "timeTrackerClientSite": MessageLookupByLibrary.simpleMessage(
      "Client Site",
    ),
    "timeTrackerColumnNo": MessageLookupByLibrary.simpleMessage("No"),
    "timeTrackerCommentDeleted": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Comment",
    ),
    "timeTrackerCommentDeletedTitle": MessageLookupByLibrary.simpleMessage(
      "Comment Deleted",
    ),
    "timeTrackerCommentOnApprovals": MessageLookupByLibrary.simpleMessage(
      "Comment On Approvals",
    ),
    "timeTrackerCommentOnRequests": MessageLookupByLibrary.simpleMessage(
      "Comment On Requests",
    ),
    "timeTrackerConfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Confirmed",
    ),
    "timeTrackerCoordinatesRequired": MessageLookupByLibrary.simpleMessage(
      "A geofence needs the latitude and longitude.",
    ),
    "timeTrackerCountry": MessageLookupByLibrary.simpleMessage("Country"),
    "timeTrackerCountryAr": MessageLookupByLibrary.simpleMessage("دولة"),
    "timeTrackerCounts": MessageLookupByLibrary.simpleMessage("Counts"),
    "timeTrackerCreateGroup": MessageLookupByLibrary.simpleMessage(
      "Create Group",
    ),
    "timeTrackerCreateGroupConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Group ?",
    ),
    "timeTrackerCreateLocation": MessageLookupByLibrary.simpleMessage(
      "Create Location",
    ),
    "timeTrackerCreateLocationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Location ?",
    ),
    "timeTrackerCreateRequest": MessageLookupByLibrary.simpleMessage(
      "Create Request",
    ),
    "timeTrackerCreateRequestConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Request ?",
    ),
    "timeTrackerCreateRequestType": MessageLookupByLibrary.simpleMessage(
      "Create Request Type",
    ),
    "timeTrackerCreateRequestTypeConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Request Type ?",
    ),
    "timeTrackerCreateTransactionConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Create This Transaction ?",
    ),
    "timeTrackerCreatedDateValue": m30,
    "timeTrackerCreatingNewGroup": MessageLookupByLibrary.simpleMessage(
      "Creating New Group",
    ),
    "timeTrackerCreatingNewLocation": MessageLookupByLibrary.simpleMessage(
      "Creating New Location",
    ),
    "timeTrackerCreatingNewRequest": MessageLookupByLibrary.simpleMessage(
      "Creating New Request",
    ),
    "timeTrackerCreatingRequest": MessageLookupByLibrary.simpleMessage(
      "Creating Request",
    ),
    "timeTrackerCreatingRequestType": MessageLookupByLibrary.simpleMessage(
      "Creating Request Type",
    ),
    "timeTrackerCreatingTransaction": MessageLookupByLibrary.simpleMessage(
      "Creating Transaction",
    ),
    "timeTrackerCreationDate": MessageLookupByLibrary.simpleMessage(
      "Creation Date",
    ),
    "timeTrackerCustomDateSelector": MessageLookupByLibrary.simpleMessage(
      "Custom Date Selector",
    ),
    "timeTrackerCustomOverridesLocation": MessageLookupByLibrary.simpleMessage(
      "Custom — Overrides The Location",
    ),
    "timeTrackerCustomRulesEmployee": MessageLookupByLibrary.simpleMessage(
      "Custom Rules For This Employee",
    ),
    "timeTrackerCustomRulesGroup": MessageLookupByLibrary.simpleMessage(
      "Custom Rules For This Group",
    ),
    "timeTrackerDashboardPermissions": MessageLookupByLibrary.simpleMessage(
      "Dashboard",
    ),
    "timeTrackerDate": MessageLookupByLibrary.simpleMessage("Date"),
    "timeTrackerDateAtTime": m31,
    "timeTrackerDateFrom": MessageLookupByLibrary.simpleMessage("From Date"),
    "timeTrackerDateRangeError": MessageLookupByLibrary.simpleMessage(
      "The end date must be on or after the start date.",
    ),
    "timeTrackerDateRequested": MessageLookupByLibrary.simpleMessage(
      "Date Requested",
    ),
    "timeTrackerDateTo": MessageLookupByLibrary.simpleMessage("To Date"),
    "timeTrackerDaysFew": m32,
    "timeTrackerDaysMany": m33,
    "timeTrackerDaysValue": m34,
    "timeTrackerDeactivateLocationConfirm":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Deactivate This Location ?",
        ),
    "timeTrackerDeactivateRequestTypeConfirm":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Deactivate This Request Type ?",
        ),
    "timeTrackerDeductsFromVacation": MessageLookupByLibrary.simpleMessage(
      "Deducts From Vacation Balance",
    ),
    "timeTrackerDeleteCommentConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Comment ?",
    ),
    "timeTrackerDeleteGroup": MessageLookupByLibrary.simpleMessage(
      "Delete Group",
    ),
    "timeTrackerDeleteGroupConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Group ?",
    ),
    "timeTrackerDeleteLocation": MessageLookupByLibrary.simpleMessage(
      "Delete Location",
    ),
    "timeTrackerDeleteLocationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Delete This Location ?",
    ),
    "timeTrackerDeletedGroupTitle": MessageLookupByLibrary.simpleMessage(
      "Group Deleted",
    ),
    "timeTrackerDeletingComment": MessageLookupByLibrary.simpleMessage(
      "Deleting Comment",
    ),
    "timeTrackerDeletingGroups": MessageLookupByLibrary.simpleMessage(
      "Deleting Group",
    ),
    "timeTrackerDeletingLocation": MessageLookupByLibrary.simpleMessage(
      "Deleting Location",
    ),
    "timeTrackerDemoAlreadyLoaded": MessageLookupByLibrary.simpleMessage(
      "The demo data is already loaded.",
    ),
    "timeTrackerDemoLoad": MessageLookupByLibrary.simpleMessage(
      "Load Demo Data",
    ),
    "timeTrackerDemoLoadDone": m35,
    "timeTrackerDemoRemove": MessageLookupByLibrary.simpleMessage(
      "Remove Demo Data",
    ),
    "timeTrackerDemoRemoveDone": m36,
    "timeTrackerDemoTools": MessageLookupByLibrary.simpleMessage("Demo Tools"),
    "timeTrackerDemoToolsHint": MessageLookupByLibrary.simpleMessage(
      "Available in debug builds only. Adds realistic sample records to every Time Tracker tab. Existing records are never changed.",
    ),
    "timeTrackerDepartment": MessageLookupByLibrary.simpleMessage("Department"),
    "timeTrackerDepartmentAvailability": MessageLookupByLibrary.simpleMessage(
      "Department Availability",
    ),
    "timeTrackerDescription": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "timeTrackerDescriptionAr": MessageLookupByLibrary.simpleMessage(
      "وصف الطلب",
    ),
    "timeTrackerDescriptionRequired": MessageLookupByLibrary.simpleMessage(
      "This request type needs a description.",
    ),
    "timeTrackerDifferentLocationNotAllowed":
        MessageLookupByLibrary.simpleMessage(
          "You are not allowed to work from a different location.",
        ),
    "timeTrackerDownloadTemplate": MessageLookupByLibrary.simpleMessage(
      "Download Template",
    ),
    "timeTrackerEditGroup": MessageLookupByLibrary.simpleMessage("Edit Group"),
    "timeTrackerEditGroupConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Group ?",
    ),
    "timeTrackerEditLocation": MessageLookupByLibrary.simpleMessage(
      "Edit Location",
    ),
    "timeTrackerEditLocationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Location ?",
    ),
    "timeTrackerEditRequestType": MessageLookupByLibrary.simpleMessage(
      "Edit Request Type",
    ),
    "timeTrackerEditRequestTypeConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Request Type ?",
    ),
    "timeTrackerEditVacationBalance": MessageLookupByLibrary.simpleMessage(
      "Edit Vacation Balance",
    ),
    "timeTrackerEditVacationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Edit This Vacation Balance ?",
    ),
    "timeTrackerEdited": MessageLookupByLibrary.simpleMessage("Edited"),
    "timeTrackerEditedGroupTitle": MessageLookupByLibrary.simpleMessage(
      "Edited Group",
    ),
    "timeTrackerEditingGroup": MessageLookupByLibrary.simpleMessage(
      "Editing Group",
    ),
    "timeTrackerEditingGroupDetails": MessageLookupByLibrary.simpleMessage(
      "Editing Group Details",
    ),
    "timeTrackerEditingLocation": MessageLookupByLibrary.simpleMessage(
      "Editing Location",
    ),
    "timeTrackerEditingRequestType": MessageLookupByLibrary.simpleMessage(
      "Editing Request Type",
    ),
    "timeTrackerEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "timeTrackerEmployeeInformation": MessageLookupByLibrary.simpleMessage(
      "Employee Information",
    ),
    "timeTrackerEmployeeName": MessageLookupByLibrary.simpleMessage(
      "Employee Name",
    ),
    "timeTrackerEmployeePermissions": MessageLookupByLibrary.simpleMessage(
      "Employees",
    ),
    "timeTrackerEmployeesAllDepartments": MessageLookupByLibrary.simpleMessage(
      "Employees — All Departments",
    ),
    "timeTrackerEmployeesExportName": MessageLookupByLibrary.simpleMessage(
      "Employees",
    ),
    "timeTrackerEmployeesInScope": MessageLookupByLibrary.simpleMessage(
      "Employees Included",
    ),
    "timeTrackerEmployeesSelected": m37,
    "timeTrackerEnDescription": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "timeTrackerEnGroupName": MessageLookupByLibrary.simpleMessage(
      "Group Name",
    ),
    "timeTrackerEnLocationName": MessageLookupByLibrary.simpleMessage(
      "Location Name",
    ),
    "timeTrackerEnRequestName": MessageLookupByLibrary.simpleMessage(
      "Request Name",
    ),
    "timeTrackerEndAfterStart": MessageLookupByLibrary.simpleMessage(
      "The end must be after the start.",
    ),
    "timeTrackerEndDate": MessageLookupByLibrary.simpleMessage("End Date"),
    "timeTrackerEndDateRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the end date.",
    ),
    "timeTrackerEndTime": MessageLookupByLibrary.simpleMessage("End Time"),
    "timeTrackerEndTimeRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the end time.",
    ),
    "timeTrackerExceedsBalance": m38,
    "timeTrackerExcuseLeave": MessageLookupByLibrary.simpleMessage(
      "Excuse Leave",
    ),
    "timeTrackerExcused": MessageLookupByLibrary.simpleMessage("Excused"),
    "timeTrackerExportAttendance": MessageLookupByLibrary.simpleMessage(
      "Export Attendance",
    ),
    "timeTrackerExportEmployees": MessageLookupByLibrary.simpleMessage(
      "Export Employees",
    ),
    "timeTrackerExportEmpty": MessageLookupByLibrary.simpleMessage(
      "There is nothing to export.",
    ),
    "timeTrackerExportItem": MessageLookupByLibrary.simpleMessage("Item"),
    "timeTrackerExportLocations": MessageLookupByLibrary.simpleMessage(
      "Export Locations",
    ),
    "timeTrackerExportRequestTypes": MessageLookupByLibrary.simpleMessage(
      "Export Request Types",
    ),
    "timeTrackerExportRequests": MessageLookupByLibrary.simpleMessage(
      "Export Requests",
    ),
    "timeTrackerExportSection": MessageLookupByLibrary.simpleMessage("Section"),
    "timeTrackerExportVacationBalances": MessageLookupByLibrary.simpleMessage(
      "Export Vacation Balances",
    ),
    "timeTrackerExportValue": MessageLookupByLibrary.simpleMessage("Value"),
    "timeTrackerFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "The file is larger than 10 MB.",
    ),
    "timeTrackerFilterDay": MessageLookupByLibrary.simpleMessage("Day"),
    "timeTrackerFilterType": MessageLookupByLibrary.simpleMessage("Type"),
    "timeTrackerFiltersTitle": MessageLookupByLibrary.simpleMessage("Filters"),
    "timeTrackerFrequentAbsences": MessageLookupByLibrary.simpleMessage(
      "3 Or More Absences This Month",
    ),
    "timeTrackerGeofencePreview": MessageLookupByLibrary.simpleMessage(
      "Location On Map",
    ),
    "timeTrackerGeofenceRadius": MessageLookupByLibrary.simpleMessage(
      "Geofencing Radius (Meters)",
    ),
    "timeTrackerGeofenceRadiusColumn": MessageLookupByLibrary.simpleMessage(
      "Geofencing Radius",
    ),
    "timeTrackerGeofencing": MessageLookupByLibrary.simpleMessage("Geofencing"),
    "timeTrackerGoogleMap": MessageLookupByLibrary.simpleMessage("Google Map"),
    "timeTrackerGoogleMapsHint": MessageLookupByLibrary.simpleMessage(
      "https://www.google.com/maps/place",
    ),
    "timeTrackerGrantAccess": MessageLookupByLibrary.simpleMessage(
      "Grant Access",
    ),
    "timeTrackerGroupButton": MessageLookupByLibrary.simpleMessage("Group"),
    "timeTrackerGroupCreated": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Group",
    ),
    "timeTrackerGroupCreationTitle": MessageLookupByLibrary.simpleMessage(
      "Group Creation",
    ),
    "timeTrackerGroupDeleted": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Group",
    ),
    "timeTrackerGroupDescriptionAr": MessageLookupByLibrary.simpleMessage(
      "وصف المجموعة",
    ),
    "timeTrackerGroupEdited": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Group",
    ),
    "timeTrackerGroupInformation": MessageLookupByLibrary.simpleMessage(
      "Group Information",
    ),
    "timeTrackerGroupName": MessageLookupByLibrary.simpleMessage("Group Name"),
    "timeTrackerGroupNameAr": MessageLookupByLibrary.simpleMessage(
      "اسم المجموعة",
    ),
    "timeTrackerGroupPermissions": MessageLookupByLibrary.simpleMessage(
      "Groups",
    ),
    "timeTrackerHourUnit": MessageLookupByLibrary.simpleMessage("Hour"),
    "timeTrackerHrApproval": MessageLookupByLibrary.simpleMessage(
      "HR Approval",
    ),
    "timeTrackerHrDashboard": MessageLookupByLibrary.simpleMessage(
      "HR Dashboard",
    ),
    "timeTrackerHrDashboardAllDepartments":
        MessageLookupByLibrary.simpleMessage("HR Dashboard — All Departments"),
    "timeTrackerHrDashboardExportName": MessageLookupByLibrary.simpleMessage(
      "HR Dashboard",
    ),
    "timeTrackerHrDashboardFilterByEmployee":
        MessageLookupByLibrary.simpleMessage(
          "HR Dashboard — Filter By Employee",
        ),
    "timeTrackerHrOwnsSetup": MessageLookupByLibrary.simpleMessage(
      "Locations, shifts and employee assignments are managed in the HR module.",
    ),
    "timeTrackerHrStep": MessageLookupByLibrary.simpleMessage("HR"),
    "timeTrackerHrsValue": m39,
    "timeTrackerImport": MessageLookupByLibrary.simpleMessage("Import"),
    "timeTrackerImportActionCreate": MessageLookupByLibrary.simpleMessage(
      "New",
    ),
    "timeTrackerImportActionSkip": MessageLookupByLibrary.simpleMessage(
      "Skipped",
    ),
    "timeTrackerImportActionUnchanged": MessageLookupByLibrary.simpleMessage(
      "No Change",
    ),
    "timeTrackerImportActionUpdate": MessageLookupByLibrary.simpleMessage(
      "Update",
    ),
    "timeTrackerImportConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Import These Locations ?",
    ),
    "timeTrackerImportDone": MessageLookupByLibrary.simpleMessage(
      "You Successfully Imported The Locations",
    ),
    "timeTrackerImportDoneTitle": MessageLookupByLibrary.simpleMessage(
      "Locations Imported",
    ),
    "timeTrackerImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "This name appears more than once in the file",
    ),
    "timeTrackerImportDuplicateEmail": MessageLookupByLibrary.simpleMessage(
      "This email appears more than once in the file",
    ),
    "timeTrackerImportFileError": MessageLookupByLibrary.simpleMessage(
      "The file could not be read. Please use the CSV or Excel template.",
    ),
    "timeTrackerImportHelp": MessageLookupByLibrary.simpleMessage(
      "Download the template, fill one row per location, then upload it as CSV or Excel. A row whose name matches an existing location updates it (a blank cell keeps the current value); every other row creates a new location. Nothing is deleted.",
    ),
    "timeTrackerImportLine": m40,
    "timeTrackerImportLocations": MessageLookupByLibrary.simpleMessage(
      "Import Locations",
    ),
    "timeTrackerImportNoNameColumn": MessageLookupByLibrary.simpleMessage(
      "The file has no “Location Name” column. Please use the template.",
    ),
    "timeTrackerImportNothing": MessageLookupByLibrary.simpleMessage(
      "There is nothing to import.",
    ),
    "timeTrackerImportSummary": m41,
    "timeTrackerImportTemplateName": MessageLookupByLibrary.simpleMessage(
      "Locations Template",
    ),
    "timeTrackerImportUnknownEmployee": MessageLookupByLibrary.simpleMessage(
      "No employee has this email",
    ),
    "timeTrackerImportUnreadable": m42,
    "timeTrackerImportVacationBalances": MessageLookupByLibrary.simpleMessage(
      "Import Vacation Balances",
    ),
    "timeTrackerImportWrongYear": m43,
    "timeTrackerInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "timeTrackerInquiriesAndComments": MessageLookupByLibrary.simpleMessage(
      "Inquiries And Comments",
    ),
    "timeTrackerJobTitle": MessageLookupByLibrary.simpleMessage("Job Title"),
    "timeTrackerLastUpdate": MessageLookupByLibrary.simpleMessage(
      "Last Update",
    ),
    "timeTrackerLastUpdateValue": m44,
    "timeTrackerLate": MessageLookupByLibrary.simpleMessage("Late"),
    "timeTrackerLateAfter": MessageLookupByLibrary.simpleMessage(
      "Late After (Minutes)",
    ),
    "timeTrackerLateAfterHint": MessageLookupByLibrary.simpleMessage("0"),
    "timeTrackerLateAfterMinutes": m45,
    "timeTrackerLateHistory": MessageLookupByLibrary.simpleMessage(
      "Late History",
    ),
    "timeTrackerLateToday": MessageLookupByLibrary.simpleMessage("Late Today"),
    "timeTrackerLatitude": MessageLookupByLibrary.simpleMessage("Latitude"),
    "timeTrackerLatitudeInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a latitude between -90 and 90.",
    ),
    "timeTrackerLeavingTime": MessageLookupByLibrary.simpleMessage(
      "Leaving Time",
    ),
    "timeTrackerLimitDepartmentAvailability":
        MessageLookupByLibrary.simpleMessage("Limit Department Availability"),
    "timeTrackerLimitLocationAvailability":
        MessageLookupByLibrary.simpleMessage("Limit Location Availability"),
    "timeTrackerLoadError": MessageLookupByLibrary.simpleMessage(
      "Could not load the Time Tracker. Please try again.",
    ),
    "timeTrackerLocation": MessageLookupByLibrary.simpleMessage("Location"),
    "timeTrackerLocationAtGoogleMaps": MessageLookupByLibrary.simpleMessage(
      "Location At Google Maps",
    ),
    "timeTrackerLocationAvailability": MessageLookupByLibrary.simpleMessage(
      "Location Availability",
    ),
    "timeTrackerLocationCreated": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created New Location",
    ),
    "timeTrackerLocationCreatedTitle": MessageLookupByLibrary.simpleMessage(
      "Location Created",
    ),
    "timeTrackerLocationDeleted": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Location",
    ),
    "timeTrackerLocationDeletedTitle": MessageLookupByLibrary.simpleMessage(
      "Location Deleted",
    ),
    "timeTrackerLocationDenied": MessageLookupByLibrary.simpleMessage(
      "Location access is turned off for Knowticed. Allow it in your device Settings to check in at the office, or choose Remote / Client Site if you are allowed.",
    ),
    "timeTrackerLocationDeniedSetup": MessageLookupByLibrary.simpleMessage(
      "Location access is turned off for Knowticed. Allow it in your device Settings, or type the latitude and longitude.",
    ),
    "timeTrackerLocationDescription": MessageLookupByLibrary.simpleMessage(
      "Location Description",
    ),
    "timeTrackerLocationEdited": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Location",
    ),
    "timeTrackerLocationEditedTitle": MessageLookupByLibrary.simpleMessage(
      "Location Edited",
    ),
    "timeTrackerLocationInUse": m46,
    "timeTrackerLocationInUseTitle": MessageLookupByLibrary.simpleMessage(
      "Location In Use",
    ),
    "timeTrackerLocationMatches": MessageLookupByLibrary.simpleMessage(
      "Your Location Matches The Company’s Location",
    ),
    "timeTrackerLocationName": MessageLookupByLibrary.simpleMessage(
      "Location Name",
    ),
    "timeTrackerLocationNameAr": MessageLookupByLibrary.simpleMessage(
      "اسم الموقع",
    ),
    "timeTrackerLocationNeededTitle": MessageLookupByLibrary.simpleMessage(
      "Location Needed",
    ),
    "timeTrackerLocationNotAllowed": MessageLookupByLibrary.simpleMessage(
      "You can\'t check in at this location.",
    ),
    "timeTrackerLocationPermissions": MessageLookupByLibrary.simpleMessage(
      "Locations",
    ),
    "timeTrackerLocationRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the location.",
    ),
    "timeTrackerLocationServiceOff": MessageLookupByLibrary.simpleMessage(
      "Location services are turned off on this device. Turn them on to check in at the office.",
    ),
    "timeTrackerLocationSetting": MessageLookupByLibrary.simpleMessage(
      "Location Setting",
    ),
    "timeTrackerLocationStatusChanged": MessageLookupByLibrary.simpleMessage(
      "You Successfully Changed the Status Of This Location",
    ),
    "timeTrackerLocationUnavailable": MessageLookupByLibrary.simpleMessage(
      "We could not read your location. Please try again.",
    ),
    "timeTrackerLocationValue": m47,
    "timeTrackerLocationsExportName": MessageLookupByLibrary.simpleMessage(
      "Locations",
    ),
    "timeTrackerLongitude": MessageLookupByLibrary.simpleMessage("Longitude"),
    "timeTrackerLongitudeInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a longitude between -180 and 180.",
    ),
    "timeTrackerMainLocation": MessageLookupByLibrary.simpleMessage("Main"),
    "timeTrackerManagerApproval": MessageLookupByLibrary.simpleMessage(
      "Manager Approval",
    ),
    "timeTrackerManagerStep": MessageLookupByLibrary.simpleMessage("Manager"),
    "timeTrackerMapView": MessageLookupByLibrary.simpleMessage("Map"),
    "timeTrackerMaxPauseMinutes": MessageLookupByLibrary.simpleMessage(
      "Maximum Pause (Minutes)",
    ),
    "timeTrackerMembers": MessageLookupByLibrary.simpleMessage("Members"),
    "timeTrackerMembersRequired": MessageLookupByLibrary.simpleMessage(
      "Choose at least one member.",
    ),
    "timeTrackerMembersSelected": m48,
    "timeTrackerMetersValue": m49,
    "timeTrackerMinTotalHoursHint": MessageLookupByLibrary.simpleMessage(
      "At Least (Hours)",
    ),
    "timeTrackerMinsValue": m50,
    "timeTrackerMinutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "timeTrackerMinutesValue": m51,
    "timeTrackerMissingCheckOuts": MessageLookupByLibrary.simpleMessage(
      "Missing Check-Outs Yesterday",
    ),
    "timeTrackerMockedLocation": MessageLookupByLibrary.simpleMessage(
      "Your device is using a fake (mock) location. Please turn it off to check in.",
    ),
    "timeTrackerMoreItems": m52,
    "timeTrackerMyDashboard": MessageLookupByLibrary.simpleMessage(
      "My Dashboard",
    ),
    "timeTrackerNameRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the name.",
    ),
    "timeTrackerNeedsAttention": MessageLookupByLibrary.simpleMessage(
      "Needs Attention",
    ),
    "timeTrackerNo": MessageLookupByLibrary.simpleMessage("No"),
    "timeTrackerNoAccess": MessageLookupByLibrary.simpleMessage(
      "You don\'t have access to the Time Tracker.",
    ),
    "timeTrackerNoBalanceApprover": MessageLookupByLibrary.simpleMessage(
      "This employee has no vacation balance yet. Please set it in Vacation Balances first.",
    ),
    "timeTrackerNoBalanceEmployee": MessageLookupByLibrary.simpleMessage(
      "No vacation balance has been set for you yet. Please contact HR.",
    ),
    "timeTrackerNoBreak": MessageLookupByLibrary.simpleMessage("No Break"),
    "timeTrackerNoBreaks": MessageLookupByLibrary.simpleMessage("No Breaks"),
    "timeTrackerNoComments": MessageLookupByLibrary.simpleMessage(
      "No comments yet.",
    ),
    "timeTrackerNoDataYet": MessageLookupByLibrary.simpleMessage(
      "No data for this period yet.",
    ),
    "timeTrackerNoLimit": MessageLookupByLibrary.simpleMessage("No Limit"),
    "timeTrackerNoPause": MessageLookupByLibrary.simpleMessage("No Pause"),
    "timeTrackerNoPendingApprovals": MessageLookupByLibrary.simpleMessage(
      "No Pending Approvals",
    ),
    "timeTrackerNoPermission": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission to do this.",
    ),
    "timeTrackerNoRequestTypesAvailable": MessageLookupByLibrary.simpleMessage(
      "No request type is available to you yet. Ask HR to add one.",
    ),
    "timeTrackerNotAssigned": MessageLookupByLibrary.simpleMessage(
      "You are not assigned to a work location yet. Ask HR to assign you before checking in.",
    ),
    "timeTrackerNotRequired": MessageLookupByLibrary.simpleMessage(
      "Not Required",
    ),
    "timeTrackerOffice": MessageLookupByLibrary.simpleMessage("Office"),
    "timeTrackerOnLeaveToday": MessageLookupByLibrary.simpleMessage(
      "On Leave Today",
    ),
    "timeTrackerOncomingTime": MessageLookupByLibrary.simpleMessage(
      "Oncoming Time",
    ),
    "timeTrackerOneAbsence": MessageLookupByLibrary.simpleMessage("1 Absence"),
    "timeTrackerOneDay": MessageLookupByLibrary.simpleMessage("1 Day"),
    "timeTrackerOptional": MessageLookupByLibrary.simpleMessage("Optional"),
    "timeTrackerOthers": MessageLookupByLibrary.simpleMessage("Others"),
    "timeTrackerOverall": MessageLookupByLibrary.simpleMessage("Overall"),
    "timeTrackerOverdueApprovals": MessageLookupByLibrary.simpleMessage(
      "Approvals Pending More Than 2 Days",
    ),
    "timeTrackerPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "timeTrackerPauseAllowed": MessageLookupByLibrary.simpleMessage(
      "Pause Allowed",
    ),
    "timeTrackerPauseUpToMinutes": m53,
    "timeTrackerPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "timeTrackerPendingApprovals": MessageLookupByLibrary.simpleMessage(
      "Pending Approvals",
    ),
    "timeTrackerPersonalDashboard": MessageLookupByLibrary.simpleMessage(
      "Personal Dashboard",
    ),
    "timeTrackerPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Phone Number",
    ),
    "timeTrackerPostalCode": MessageLookupByLibrary.simpleMessage(
      "Postal Code",
    ),
    "timeTrackerPresent": MessageLookupByLibrary.simpleMessage("Present"),
    "timeTrackerRadiusHint": MessageLookupByLibrary.simpleMessage("500"),
    "timeTrackerRadiusRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the radius in meters (up to 50000).",
    ),
    "timeTrackerRangeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "timeTrackerRangeDay": MessageLookupByLibrary.simpleMessage("Day"),
    "timeTrackerRangeMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "timeTrackerRangeTime": MessageLookupByLibrary.simpleMessage("Time"),
    "timeTrackerRangeWeek": MessageLookupByLibrary.simpleMessage("Week"),
    "timeTrackerRangeYear": MessageLookupByLibrary.simpleMessage("Year"),
    "timeTrackerReasonOfCancellation": MessageLookupByLibrary.simpleMessage(
      "Reason Of Cancellation",
    ),
    "timeTrackerReasonOfRejection": MessageLookupByLibrary.simpleMessage(
      "Reason Of Rejection",
    ),
    "timeTrackerReasonsOfCancellation": MessageLookupByLibrary.simpleMessage(
      "Reasons Of Cancellation",
    ),
    "timeTrackerReasonsOfRejection": MessageLookupByLibrary.simpleMessage(
      "Reasons Of Rejection",
    ),
    "timeTrackerReassign": MessageLookupByLibrary.simpleMessage("Reassign"),
    "timeTrackerReassignEmployeeLocation": MessageLookupByLibrary.simpleMessage(
      "Reassign Employee Location",
    ),
    "timeTrackerRejectCancellation": MessageLookupByLibrary.simpleMessage(
      "Reject Cancellation",
    ),
    "timeTrackerRejectCancellationConfirm":
        MessageLookupByLibrary.simpleMessage(
          "Are You Sure You Want To Reject The Cancellation Of This Request ?",
        ),
    "timeTrackerRejectRequest": MessageLookupByLibrary.simpleMessage(
      "Reject Request",
    ),
    "timeTrackerRejectRequestConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Reject This Request ?",
    ),
    "timeTrackerRejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "timeTrackerRemainingDays": MessageLookupByLibrary.simpleMessage(
      "Remaining",
    ),
    "timeTrackerReminderRule": MessageLookupByLibrary.simpleMessage(
      "You Can Only Send A Reminder Once Every Two Days. Feel Free To Contact Your Supervisor Directly For Assistance",
    ),
    "timeTrackerReminderSentOn": m54,
    "timeTrackerRemote": MessageLookupByLibrary.simpleMessage("Remote"),
    "timeTrackerRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "timeTrackerRemoveAssignmentConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Remove This Employee\'s Assignment ?",
    ),
    "timeTrackerRemoveEmployeeAssignment": MessageLookupByLibrary.simpleMessage(
      "Remove Employee Assignment",
    ),
    "timeTrackerRemoveRequestType": MessageLookupByLibrary.simpleMessage(
      "Remove Request Type",
    ),
    "timeTrackerRemoveRequestTypeConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Remove This Request Type ?",
    ),
    "timeTrackerRemoved": MessageLookupByLibrary.simpleMessage("Removed"),
    "timeTrackerRemovedBy": MessageLookupByLibrary.simpleMessage("Removed By"),
    "timeTrackerRemovedDate": MessageLookupByLibrary.simpleMessage(
      "Removed Date",
    ),
    "timeTrackerRemovingAssignment": MessageLookupByLibrary.simpleMessage(
      "Removing Assignment",
    ),
    "timeTrackerRemovingRequestType": MessageLookupByLibrary.simpleMessage(
      "Removing Request Type",
    ),
    "timeTrackerRequestApproved": MessageLookupByLibrary.simpleMessage(
      "You Successfully Approved This Request",
    ),
    "timeTrackerRequestAttachments": MessageLookupByLibrary.simpleMessage(
      "Request Attachments",
    ),
    "timeTrackerRequestCanceled": MessageLookupByLibrary.simpleMessage(
      "You Successfully Canceled This Request",
    ),
    "timeTrackerRequestCanceledTitle": MessageLookupByLibrary.simpleMessage(
      "Request Canceled",
    ),
    "timeTrackerRequestCancellationTitle": MessageLookupByLibrary.simpleMessage(
      "Request Cancellation",
    ),
    "timeTrackerRequestChangedMeanwhile": MessageLookupByLibrary.simpleMessage(
      "This request was just changed by someone else. Please check it and try again.",
    ),
    "timeTrackerRequestDate": MessageLookupByLibrary.simpleMessage(
      "Request Date",
    ),
    "timeTrackerRequestDescription": MessageLookupByLibrary.simpleMessage(
      "Request Description",
    ),
    "timeTrackerRequestDetails": MessageLookupByLibrary.simpleMessage(
      "Request Details",
    ),
    "timeTrackerRequestName": MessageLookupByLibrary.simpleMessage(
      "Request Name",
    ),
    "timeTrackerRequestNameAr": MessageLookupByLibrary.simpleMessage(
      "اسم الطلب",
    ),
    "timeTrackerRequestNotFound": MessageLookupByLibrary.simpleMessage(
      "This request is not available.",
    ),
    "timeTrackerRequestOverlaps": MessageLookupByLibrary.simpleMessage(
      "You already have a request for this time",
    ),
    "timeTrackerRequestPermissions": MessageLookupByLibrary.simpleMessage(
      "Requests",
    ),
    "timeTrackerRequestRejected": MessageLookupByLibrary.simpleMessage(
      "You Successfully Rejected This Request",
    ),
    "timeTrackerRequestSubmitted": MessageLookupByLibrary.simpleMessage(
      "Your Request Has Been Successfully Submitted",
    ),
    "timeTrackerRequestTimeline": MessageLookupByLibrary.simpleMessage(
      "Request Timeline",
    ),
    "timeTrackerRequestToCancellation": MessageLookupByLibrary.simpleMessage(
      "Request To Cancellation",
    ),
    "timeTrackerRequestTransaction": MessageLookupByLibrary.simpleMessage(
      "Request Transaction",
    ),
    "timeTrackerRequestType": MessageLookupByLibrary.simpleMessage(
      "Request Type",
    ),
    "timeTrackerRequestTypeCreated": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Request Type",
    ),
    "timeTrackerRequestTypeCreatedTitle": MessageLookupByLibrary.simpleMessage(
      "Request Type Created",
    ),
    "timeTrackerRequestTypeEdited": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Request Type",
    ),
    "timeTrackerRequestTypeEditedTitle": MessageLookupByLibrary.simpleMessage(
      "Request Type Edited",
    ),
    "timeTrackerRequestTypePermissions": MessageLookupByLibrary.simpleMessage(
      "Request Types",
    ),
    "timeTrackerRequestTypeRemoved": MessageLookupByLibrary.simpleMessage(
      "You Successfully Removed This Request Type",
    ),
    "timeTrackerRequestTypeRemovedTitle": MessageLookupByLibrary.simpleMessage(
      "Request Type Removed",
    ),
    "timeTrackerRequestTypeRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the request type.",
    ),
    "timeTrackerRequestTypeRestored": MessageLookupByLibrary.simpleMessage(
      "The request type is active again.",
    ),
    "timeTrackerRequestTypeRestoredTitle": MessageLookupByLibrary.simpleMessage(
      "Request Type Restored",
    ),
    "timeTrackerRequestTypeStatusChanged": MessageLookupByLibrary.simpleMessage(
      "You Successfully Changed the Status Of This Request Type",
    ),
    "timeTrackerRequestTypesExportName": MessageLookupByLibrary.simpleMessage(
      "Request Types",
    ),
    "timeTrackerRequestWord": MessageLookupByLibrary.simpleMessage("Request"),
    "timeTrackerRequestedBy": MessageLookupByLibrary.simpleMessage(
      "Requested By",
    ),
    "timeTrackerRequestedTimeframe": MessageLookupByLibrary.simpleMessage(
      "Requested Timeframe",
    ),
    "timeTrackerRequestsExportName": MessageLookupByLibrary.simpleMessage(
      "Requests",
    ),
    "timeTrackerRequestsTitle": MessageLookupByLibrary.simpleMessage(
      "Requests",
    ),
    "timeTrackerRequired": MessageLookupByLibrary.simpleMessage("Required"),
    "timeTrackerRequiresAttachments": MessageLookupByLibrary.simpleMessage(
      "Requires Attachments",
    ),
    "timeTrackerRequiresDescription": MessageLookupByLibrary.simpleMessage(
      "Requires Description",
    ),
    "timeTrackerRestore": MessageLookupByLibrary.simpleMessage("Restore"),
    "timeTrackerRestoreRequestTypeConfirm":
        MessageLookupByLibrary.simpleMessage(
          "This request type will be active again and employees can use it in new requests.",
        ),
    "timeTrackerRestoringRequestType": MessageLookupByLibrary.simpleMessage(
      "Restoring Request Type",
    ),
    "timeTrackerResume": MessageLookupByLibrary.simpleMessage("Resume"),
    "timeTrackerRetry": MessageLookupByLibrary.simpleMessage("Try Again"),
    "timeTrackerRulesFromLocation": m55,
    "timeTrackerRulesFromLocationTag": MessageLookupByLibrary.simpleMessage(
      "From Location",
    ),
    "timeTrackerSatelliteView": MessageLookupByLibrary.simpleMessage(
      "Satellite",
    ),
    "timeTrackerScreensComingSoon": MessageLookupByLibrary.simpleMessage(
      "The Time Tracker screens are being built and will appear here soon.",
    ),
    "timeTrackerSearchAddress": MessageLookupByLibrary.simpleMessage(
      "Search An Address Or Place",
    ),
    "timeTrackerSearching": MessageLookupByLibrary.simpleMessage("Searching…"),
    "timeTrackerSectionAvailability": MessageLookupByLibrary.simpleMessage(
      "Availability",
    ),
    "timeTrackerSectionComingSoon": MessageLookupByLibrary.simpleMessage(
      "This section is coming soon.",
    ),
    "timeTrackerSectionHistory": MessageLookupByLibrary.simpleMessage(
      "History",
    ),
    "timeTrackerSectionRequirements": MessageLookupByLibrary.simpleMessage(
      "Request Requirements",
    ),
    "timeTrackerSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Select Location",
    ),
    "timeTrackerSelectState": MessageLookupByLibrary.simpleMessage(
      "Select State Or Province",
    ),
    "timeTrackerSendRequestReminder": MessageLookupByLibrary.simpleMessage(
      "Send Reminder",
    ),
    "timeTrackerSickLeave": MessageLookupByLibrary.simpleMessage("Sick Leave"),
    "timeTrackerSortNameAsc": MessageLookupByLibrary.simpleMessage(
      "Name (A To Z)",
    ),
    "timeTrackerSortNameDesc": MessageLookupByLibrary.simpleMessage(
      "Name (Z To A)",
    ),
    "timeTrackerSortNewest": MessageLookupByLibrary.simpleMessage(
      "Newest First",
    ),
    "timeTrackerStartDate": MessageLookupByLibrary.simpleMessage("Start Date"),
    "timeTrackerStartDateRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the start date.",
    ),
    "timeTrackerStartShift": MessageLookupByLibrary.simpleMessage(
      "Start Shift",
    ),
    "timeTrackerStartTime": MessageLookupByLibrary.simpleMessage("Start Time"),
    "timeTrackerStartTimeRequired": MessageLookupByLibrary.simpleMessage(
      "Choose the start time.",
    ),
    "timeTrackerStateOrProvince": MessageLookupByLibrary.simpleMessage(
      "State Or Province",
    ),
    "timeTrackerStateOrProvinceAr": MessageLookupByLibrary.simpleMessage(
      "ولاية او محافظة",
    ),
    "timeTrackerStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "timeTrackerStatusChangedTitle": MessageLookupByLibrary.simpleMessage(
      "Status Changed",
    ),
    "timeTrackerStepDecision": m56,
    "timeTrackerSubmittedTransaction": MessageLookupByLibrary.simpleMessage(
      "Submitted Transaction",
    ),
    "timeTrackerSuccessful": MessageLookupByLibrary.simpleMessage("Successful"),
    "timeTrackerTabApprovals": MessageLookupByLibrary.simpleMessage(
      "Approvals",
    ),
    "timeTrackerTabAttendance": MessageLookupByLibrary.simpleMessage(
      "Attendance",
    ),
    "timeTrackerTabDashboard": MessageLookupByLibrary.simpleMessage(
      "Dashboard",
    ),
    "timeTrackerTabEmployees": MessageLookupByLibrary.simpleMessage(
      "Employees",
    ),
    "timeTrackerTabLocations": MessageLookupByLibrary.simpleMessage(
      "Locations",
    ),
    "timeTrackerTabOverview": MessageLookupByLibrary.simpleMessage("Overview"),
    "timeTrackerTabRequestTypes": MessageLookupByLibrary.simpleMessage(
      "Request Types",
    ),
    "timeTrackerTabRequests": MessageLookupByLibrary.simpleMessage("Requests"),
    "timeTrackerTabVacationBalances": MessageLookupByLibrary.simpleMessage(
      "Vacation Balances",
    ),
    "timeTrackerTapMapHint": MessageLookupByLibrary.simpleMessage(
      "Tap the map to place the pin. The yellow circle is the check-in area.",
    ),
    "timeTrackerTextHereAr": MessageLookupByLibrary.simpleMessage("اكتب هنا"),
    "timeTrackerTextHereEn": MessageLookupByLibrary.simpleMessage("Text here"),
    "timeTrackerTimeframeValue": m57,
    "timeTrackerTitle": MessageLookupByLibrary.simpleMessage("Tracking Time"),
    "timeTrackerTitleLabel": MessageLookupByLibrary.simpleMessage("Title"),
    "timeTrackerTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "timeTrackerTotalDays": MessageLookupByLibrary.simpleMessage("Total Days"),
    "timeTrackerTotalDaysInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a number of days, with at most one decimal.",
    ),
    "timeTrackerTotalDaysRequired": MessageLookupByLibrary.simpleMessage(
      "Enter the total days.",
    ),
    "timeTrackerTotalDaysTooLarge": MessageLookupByLibrary.simpleMessage(
      "A year has at most 366 days.",
    ),
    "timeTrackerTotalTime": MessageLookupByLibrary.simpleMessage("Total Time"),
    "timeTrackerTrackerApprover": MessageLookupByLibrary.simpleMessage(
      "Tracker Approver",
    ),
    "timeTrackerTransactionButton": MessageLookupByLibrary.simpleMessage(
      "Transaction",
    ),
    "timeTrackerTransactionDocument": MessageLookupByLibrary.simpleMessage(
      "Transaction Document",
    ),
    "timeTrackerTransactionInFuture": MessageLookupByLibrary.simpleMessage(
      "A transaction can\'t be in the future.",
    ),
    "timeTrackerTransactionSubmitted": MessageLookupByLibrary.simpleMessage(
      "You Successfully Submitted This Transaction",
    ),
    "timeTrackerTransactionTooLong": MessageLookupByLibrary.simpleMessage(
      "A correction cannot be longer than 24 hours",
    ),
    "timeTrackerTransactionsWaiting": MessageLookupByLibrary.simpleMessage(
      "Transactions Waiting",
    ),
    "timeTrackerTwoAbsences": MessageLookupByLibrary.simpleMessage(
      "2 Absences",
    ),
    "timeTrackerTwoDays": MessageLookupByLibrary.simpleMessage("2 Days"),
    "timeTrackerUnassigned": MessageLookupByLibrary.simpleMessage("Unassigned"),
    "timeTrackerUnderReview": MessageLookupByLibrary.simpleMessage(
      "Under Review",
    ),
    "timeTrackerUnitHours": MessageLookupByLibrary.simpleMessage("Hours"),
    "timeTrackerUnitMins": MessageLookupByLibrary.simpleMessage("Mins"),
    "timeTrackerUpdatedBy": MessageLookupByLibrary.simpleMessage("Updated By"),
    "timeTrackerUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not upload the file. Please try again.",
    ),
    "timeTrackerUploadFile": MessageLookupByLibrary.simpleMessage(
      "Upload File",
    ),
    "timeTrackerUploadedOn": m58,
    "timeTrackerUseLocationRules": MessageLookupByLibrary.simpleMessage(
      "Use The Location\'s Rules",
    ),
    "timeTrackerUseMyLocation": MessageLookupByLibrary.simpleMessage(
      "Use My Current Location",
    ),
    "timeTrackerUsedDays": MessageLookupByLibrary.simpleMessage("Used"),
    "timeTrackerVacation": MessageLookupByLibrary.simpleMessage("Vacation"),
    "timeTrackerVacationBalancePermissions":
        MessageLookupByLibrary.simpleMessage("Vacation Balance"),
    "timeTrackerVacationBalanceShort": MessageLookupByLibrary.simpleMessage(
      "Vacation Balance",
    ),
    "timeTrackerVacationBalancesExportName":
        MessageLookupByLibrary.simpleMessage("Vacation Balances"),
    "timeTrackerVacationEdited": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Vacation Balance",
    ),
    "timeTrackerVacationEditedTitle": MessageLookupByLibrary.simpleMessage(
      "Vacation Balance Edited",
    ),
    "timeTrackerVacationImportConfirm": MessageLookupByLibrary.simpleMessage(
      "Are You Sure You Want To Import These Vacation Balances ?",
    ),
    "timeTrackerVacationImportDone": MessageLookupByLibrary.simpleMessage(
      "You Successfully Imported The Vacation Balances",
    ),
    "timeTrackerVacationImportDoneTitle": MessageLookupByLibrary.simpleMessage(
      "Vacation Balances Imported",
    ),
    "timeTrackerVacationImportHelp": m59,
    "timeTrackerVacationImportNoColumns": MessageLookupByLibrary.simpleMessage(
      "The file needs the “Email” and “Total Days” columns. Please use the template.",
    ),
    "timeTrackerVacationTemplateName": MessageLookupByLibrary.simpleMessage(
      "Vacation Balances Template",
    ),
    "timeTrackerVacations": MessageLookupByLibrary.simpleMessage("Vacations"),
    "timeTrackerVacationsCredit": MessageLookupByLibrary.simpleMessage(
      "Vacations Credit",
    ),
    "timeTrackerViewApprovals": MessageLookupByLibrary.simpleMessage(
      "View Approvals",
    ),
    "timeTrackerViewAttendance": MessageLookupByLibrary.simpleMessage(
      "View Attendance",
    ),
    "timeTrackerViewEmployees": MessageLookupByLibrary.simpleMessage(
      "View Employees",
    ),
    "timeTrackerViewGroups": MessageLookupByLibrary.simpleMessage(
      "View Groups",
    ),
    "timeTrackerViewLocations": MessageLookupByLibrary.simpleMessage(
      "View Locations",
    ),
    "timeTrackerViewRequestTypes": MessageLookupByLibrary.simpleMessage(
      "View Request Types",
    ),
    "timeTrackerViewRequests": MessageLookupByLibrary.simpleMessage(
      "View Requests",
    ),
    "timeTrackerViewVacationBalances": MessageLookupByLibrary.simpleMessage(
      "View Vacation Balances",
    ),
    "timeTrackerWaitingDays": m60,
    "timeTrackerWorkEndTime": MessageLookupByLibrary.simpleMessage(
      "Work End Time",
    ),
    "timeTrackerWorkFromDifferentLocation":
        MessageLookupByLibrary.simpleMessage("Work From A Different Location"),
    "timeTrackerWorkLocation": MessageLookupByLibrary.simpleMessage(
      "Work Location",
    ),
    "timeTrackerWorkLocationType": MessageLookupByLibrary.simpleMessage(
      "Work Location Type",
    ),
    "timeTrackerWorkLocations": MessageLookupByLibrary.simpleMessage(
      "Work Locations",
    ),
    "timeTrackerWorkLocationsHint": MessageLookupByLibrary.simpleMessage(
      "The first location is the main one: its hours and rules apply.",
    ),
    "timeTrackerWorkSchedule": MessageLookupByLibrary.simpleMessage(
      "Work Schedule",
    ),
    "timeTrackerWorkStartTime": MessageLookupByLibrary.simpleMessage(
      "Work Start Time",
    ),
    "timeTrackerWorkTimesSame": MessageLookupByLibrary.simpleMessage(
      "Work start and end can\'t be the same time.",
    ),
    "timeTrackerWorkingDays": MessageLookupByLibrary.simpleMessage(
      "Working Days",
    ),
    "timeTrackerWorkingDaysRequired": MessageLookupByLibrary.simpleMessage(
      "Choose at least one working day.",
    ),
    "timeTrackerWriteComment": MessageLookupByLibrary.simpleMessage(
      "Write A Comment",
    ),
    "timeTrackerWrongLocationBody": MessageLookupByLibrary.simpleMessage(
      "Your check-in location does not match the company\'s designated location. Please check in from the correct location.",
    ),
    "timeTrackerWrongLocationTitle": MessageLookupByLibrary.simpleMessage(
      "Wrong Location",
    ),
    "timeTrackerYearBalanceShort": m61,
    "timeTrackerYes": MessageLookupByLibrary.simpleMessage("Yes"),
    "timeTrackerYourTabs": MessageLookupByLibrary.simpleMessage(
      "Your Time Tracker sections",
    ),
    "timeUnit": MessageLookupByLibrary.simpleMessage("Time Unit"),
    "timeminutes": MessageLookupByLibrary.simpleMessage("timeMinutes"),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "titleInArabic": MessageLookupByLibrary.simpleMessage("Title In Arabic"),
    "titleName": MessageLookupByLibrary.simpleMessage("Title Name"),
    "titleRequired": MessageLookupByLibrary.simpleMessage("Title is required."),
    "tnd": MessageLookupByLibrary.simpleMessage("TND"),
    "to": MessageLookupByLibrary.simpleMessage("To"),
    "toDo": MessageLookupByLibrary.simpleMessage("To-Do"),
    "toDoListDetails": MessageLookupByLibrary.simpleMessage(
      "To Do List Details",
    ),
    "toDoListTitle": MessageLookupByLibrary.simpleMessage("To Do List"),
    "toDoPermissions": MessageLookupByLibrary.simpleMessage(
      "To Do Permissions",
    ),
    "toWhichTypesOfRequestsDoesThisApply": MessageLookupByLibrary.simpleMessage(
      "To Which Types Of Requests Does This Apply",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "todo": MessageLookupByLibrary.simpleMessage("To Do List"),
    "todoChoose": MessageLookupByLibrary.simpleMessage("Choose"),
    "todoCompletionDate": MessageLookupByLibrary.simpleMessage(
      "Completion Date",
    ),
    "todoDateHint": MessageLookupByLibrary.simpleMessage("DD/MM/YYYY"),
    "todoDatesRequired": MessageLookupByLibrary.simpleMessage(
      "Start and end dates are required.",
    ),
    "todoDayUnit": MessageLookupByLibrary.simpleMessage("Day"),
    "todoDebugFailed": MessageLookupByLibrary.simpleMessage(
      "The action could not be completed. Please try again.",
    ),
    "todoDebugLoad": MessageLookupByLibrary.simpleMessage("Load demo to-dos"),
    "todoDebugLoadDone": m62,
    "todoDebugRemove": MessageLookupByLibrary.simpleMessage(
      "Remove demo to-dos",
    ),
    "todoDebugRemoveDone": m63,
    "todoDebugSweep": MessageLookupByLibrary.simpleMessage(
      "Send due reminders now",
    ),
    "todoDebugSweepDone": m64,
    "todoDebugTools": MessageLookupByLibrary.simpleMessage("Demo tools"),
    "todoDebugToolsHint": MessageLookupByLibrary.simpleMessage(
      "Available in debug builds only. Due reminders arrive about three minutes after loading the demo to-dos.",
    ),
    "todoDeletionDate": MessageLookupByLibrary.simpleMessage("Deletion Date"),
    "todoEndAfterStart": MessageLookupByLibrary.simpleMessage(
      "The end date must be after the start date.",
    ),
    "todoEveryInterval": m65,
    "todoFrequencyBadge": m66,
    "todoHomeNoOpen": MessageLookupByLibrary.simpleMessage("No open to-dos"),
    "todoItemHint": MessageLookupByLibrary.simpleMessage("Add an item"),
    "todoLoadError": MessageLookupByLibrary.simpleMessage(
      "Could not load your to-dos.",
    ),
    "todoMarkDone": MessageLookupByLibrary.simpleMessage("Mark as done"),
    "todoNoAccess": MessageLookupByLibrary.simpleMessage(
      "You don\'t have access to the To Do List.",
    ),
    "todoNoPermission": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission for this action.",
    ),
    "todoNotFound": MessageLookupByLibrary.simpleMessage(
      "This to-do no longer exists.",
    ),
    "todoRemoveItem": MessageLookupByLibrary.simpleMessage("Remove item"),
    "todoSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save the to-do. Please try again.",
    ),
    "todoScheduledAt": m67,
    "todoTimeHint": MessageLookupByLibrary.simpleMessage("00:00"),
    "todoWeekDaysRequired": MessageLookupByLibrary.simpleMessage(
      "Select at least one day.",
    ),
    "todoWeekUnit": MessageLookupByLibrary.simpleMessage("Week"),
    "togolese": MessageLookupByLibrary.simpleMessage("Togolese"),
    "tongan": MessageLookupByLibrary.simpleMessage("Tongan"),
    "top": MessageLookupByLibrary.simpleMessage("Top"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "total2": MessageLookupByLibrary.simpleMessage("Total: "),
    "totalAbsent": MessageLookupByLibrary.simpleMessage("Total Absent"),
    "totalAmount": MessageLookupByLibrary.simpleMessage("Total Amount"),
    "totalAssignedTasks": MessageLookupByLibrary.simpleMessage(
      "Total Assigned Tasks",
    ),
    "totalDamaged": MessageLookupByLibrary.simpleMessage("Total Damaged"),
    "totalDepartments": MessageLookupByLibrary.simpleMessage(
      "Total Departments",
    ),
    "totalDone": MessageLookupByLibrary.simpleMessage("Total Done"),
    "totalDue": MessageLookupByLibrary.simpleMessage("Total Due"),
    "totalEmployees": MessageLookupByLibrary.simpleMessage("Total Employees"),
    "totalErrors": MessageLookupByLibrary.simpleMessage("Total Errors"),
    "totalHT": MessageLookupByLibrary.simpleMessage("Total HT"),
    "totalHours": MessageLookupByLibrary.simpleMessage("Total Hours"),
    "totalLate": MessageLookupByLibrary.simpleMessage("Total Late"),
    "totalMissing": MessageLookupByLibrary.simpleMessage("Total Missing"),
    "totalModules": MessageLookupByLibrary.simpleMessage("Total Modules"),
    "totalOwningDepartments": MessageLookupByLibrary.simpleMessage(
      "Total Owning Departments",
    ),
    "totalPickedFiles": MessageLookupByLibrary.simpleMessage(
      "Total Picked Files",
    ),
    "totalPolicies": MessageLookupByLibrary.simpleMessage("Total Policies"),
    "totalPresent": MessageLookupByLibrary.simpleMessage("Total Present"),
    "totalPrice": MessageLookupByLibrary.simpleMessage("Total Price"),
    "totalProduct": MessageLookupByLibrary.simpleMessage("Total Product"),
    "totalRequests": MessageLookupByLibrary.simpleMessage("Total Requests"),
    "totalResponse": MessageLookupByLibrary.simpleMessage("Total Response: "),
    "totalRoles": MessageLookupByLibrary.simpleMessage("Total Roles"),
    "totalSLA": MessageLookupByLibrary.simpleMessage("Total SLA"),
    "totalSalon": MessageLookupByLibrary.simpleMessage("Total Salon"),
    "totalServices": MessageLookupByLibrary.simpleMessage("Total Services"),
    "totalStolen": MessageLookupByLibrary.simpleMessage("Total Stolen"),
    "totalTime": MessageLookupByLibrary.simpleMessage("Total Time"),
    "totalVAT": MessageLookupByLibrary.simpleMessage("Total VAT"),
    "totalWeight": MessageLookupByLibrary.simpleMessage("Total Weight"),
    "totalWeightShouldBe": MessageLookupByLibrary.simpleMessage(
      "Total Weight Should be",
    ),
    "totalWeightShouldBe100": MessageLookupByLibrary.simpleMessage(
      "Total weight should be 100",
    ),
    "total_modules": MessageLookupByLibrary.simpleMessage("Total Modules"),
    "tracker": MessageLookupByLibrary.simpleMessage("Tracker"),
    "trackerOverall": MessageLookupByLibrary.simpleMessage("Tracker - Overall"),
    "trackerpageresponsivepagerefactor": MessageLookupByLibrary.simpleMessage(
      "TrackerPageResponsivePageRefactor",
    ),
    "tracking": MessageLookupByLibrary.simpleMessage("Tracking"),
    "trackingAttendance": MessageLookupByLibrary.simpleMessage(
      "Tracking Attendance",
    ),
    "trackingTime": MessageLookupByLibrary.simpleMessage("Tracking Time"),
    "transaction": MessageLookupByLibrary.simpleMessage("Transaction"),
    "transactionCreated": MessageLookupByLibrary.simpleMessage(
      "Transaction Created",
    ),
    "transactionDescription": MessageLookupByLibrary.simpleMessage(
      "Transaction Description",
    ),
    "transactionDocument": MessageLookupByLibrary.simpleMessage(
      "Transaction Document",
    ),
    "trinidadianOrTobagonian": MessageLookupByLibrary.simpleMessage(
      "Trinidadian or Tobagonian",
    ),
    "tryCurrency": MessageLookupByLibrary.simpleMessage("TRY"),
    "tuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
    "tunisian": MessageLookupByLibrary.simpleMessage("Tunisian"),
    "turkish": MessageLookupByLibrary.simpleMessage("Turkish"),
    "tuvaluan": MessageLookupByLibrary.simpleMessage("Tuvaluan"),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "typeHere": MessageLookupByLibrary.simpleMessage("Type here"),
    "typeOfAssetRequest": MessageLookupByLibrary.simpleMessage(
      "Type of Asset Request",
    ),
    "typeYourMessage": MessageLookupByLibrary.simpleMessage(
      "Type your Message...",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Typing..."),
    "uSD": MessageLookupByLibrary.simpleMessage("USD"),
    "ugandan": MessageLookupByLibrary.simpleMessage("Ugandan"),
    "ukrainian": MessageLookupByLibrary.simpleMessage("Ukrainian"),
    "unStar": MessageLookupByLibrary.simpleMessage("UnStar"),
    "unSuccessful": MessageLookupByLibrary.simpleMessage("Un Successful"),
    "unableToReadTheSelectedFile": MessageLookupByLibrary.simpleMessage(
      "Unable to read the selected file",
    ),
    "unaggregated": MessageLookupByLibrary.simpleMessage("UnAggregated"),
    "unassigned": MessageLookupByLibrary.simpleMessage("Unassigned"),
    "underMaintenance": MessageLookupByLibrary.simpleMessage(
      "Under Maintenance",
    ),
    "underRepair": MessageLookupByLibrary.simpleMessage("Under Repair"),
    "underReview": MessageLookupByLibrary.simpleMessage("Under Review"),
    "uniqueServices": MessageLookupByLibrary.simpleMessage("Unique Services"),
    "unit": MessageLookupByLibrary.simpleMessage("Unit"),
    "unitBag": MessageLookupByLibrary.simpleMessage("Bag"),
    "unitBottle": MessageLookupByLibrary.simpleMessage("Bottle"),
    "unitBox": MessageLookupByLibrary.simpleMessage("Box"),
    "unitCentimeter": MessageLookupByLibrary.simpleMessage("Centimeter"),
    "unitCost": MessageLookupByLibrary.simpleMessage("Unit Cost"),
    "unitGallon": MessageLookupByLibrary.simpleMessage("Gallon"),
    "unitGram": MessageLookupByLibrary.simpleMessage("Gram"),
    "unitInch": MessageLookupByLibrary.simpleMessage("Inch"),
    "unitKilogram": MessageLookupByLibrary.simpleMessage("Kilogram"),
    "unitKit": MessageLookupByLibrary.simpleMessage("Kit"),
    "unitLiter": MessageLookupByLibrary.simpleMessage("Liter"),
    "unitMeter": MessageLookupByLibrary.simpleMessage("Meter"),
    "unitMilliliter": MessageLookupByLibrary.simpleMessage("Milliliter"),
    "unitOfMeasurement": MessageLookupByLibrary.simpleMessage(
      "Unit Of Measurement",
    ),
    "unitOunce": MessageLookupByLibrary.simpleMessage("Ounce"),
    "unitPack": MessageLookupByLibrary.simpleMessage("Pack"),
    "unitPiece": MessageLookupByLibrary.simpleMessage("Piece"),
    "unitPound": MessageLookupByLibrary.simpleMessage("Pound"),
    "unitPrice": MessageLookupByLibrary.simpleMessage("Unit Price"),
    "unitReel": MessageLookupByLibrary.simpleMessage("Reel"),
    "unitRequired": MessageLookupByLibrary.simpleMessage("Unit is required"),
    "unitSet": MessageLookupByLibrary.simpleMessage("Set"),
    "unitTon": MessageLookupByLibrary.simpleMessage("Ton"),
    "unitUnit": MessageLookupByLibrary.simpleMessage("Unit"),
    "unit_hour": MessageLookupByLibrary.simpleMessage("Hours"),
    "unit_minute": MessageLookupByLibrary.simpleMessage("Minutes"),
    "unit_second": MessageLookupByLibrary.simpleMessage("Seconds"),
    "unit_week": MessageLookupByLibrary.simpleMessage("Weeks"),
    "units": MessageLookupByLibrary.simpleMessage("Units"),
    "university": MessageLookupByLibrary.simpleMessage("University"),
    "universityOrInstitute": MessageLookupByLibrary.simpleMessage(
      "University or Institute",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownColumns": MessageLookupByLibrary.simpleMessage("Unknown columns"),
    "unknownFilePathFormat": MessageLookupByLibrary.simpleMessage(
      "Unknown file path format",
    ),
    "unknownGroup": MessageLookupByLibrary.simpleMessage("Unknown Group"),
    "unlockAccount": MessageLookupByLibrary.simpleMessage("Unlock Account"),
    "unlockRequestSubmitted": MessageLookupByLibrary.simpleMessage(
      "Unlock Request Submitted",
    ),
    "unlockUserAccount": MessageLookupByLibrary.simpleMessage(
      "Unlock User Account",
    ),
    "unpin": MessageLookupByLibrary.simpleMessage("UnPin"),
    "unpinnedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Unpinned successfully",
    ),
    "unsuccessful": MessageLookupByLibrary.simpleMessage("Unsuccessful"),
    "unsupportedCharactersInPassportNumber":
        MessageLookupByLibrary.simpleMessage(
          "Unsupported Characters in Passport Number",
        ),
    "untabulated": MessageLookupByLibrary.simpleMessage("UnTabulated"),
    "untitled": MessageLookupByLibrary.simpleMessage("Untitled"),
    "untitledTask": MessageLookupByLibrary.simpleMessage("Untitled Task"),
    "upComings": MessageLookupByLibrary.simpleMessage("Up Comings"),
    "upcomingSchedule": MessageLookupByLibrary.simpleMessage(
      "Upcoming Schedule",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateSocialInformation": MessageLookupByLibrary.simpleMessage(
      "Update Social Information",
    ),
    "updatedAt": MessageLookupByLibrary.simpleMessage("Updated At"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadAttachment": MessageLookupByLibrary.simpleMessage(
      "Upload Attachment",
    ),
    "uploadControlDocumentArabic": MessageLookupByLibrary.simpleMessage(
      "Upload Control Document (Arabic)",
    ),
    "uploadControlDocumentEnglish": MessageLookupByLibrary.simpleMessage(
      "Upload Control Document (English)",
    ),
    "uploadDocument": MessageLookupByLibrary.simpleMessage("Upload Document"),
    "uploadDrivingLicenseId": MessageLookupByLibrary.simpleMessage(
      "Upload Driving License",
    ),
    "uploadErrorMessage": MessageLookupByLibrary.simpleMessage(
      "There was an error uploading your supplier data. Please try again.",
    ),
    "uploadEvidence": MessageLookupByLibrary.simpleMessage("Upload Evidence"),
    "uploadFailed": MessageLookupByLibrary.simpleMessage("Upload failed"),
    "uploadNationalIdBack": MessageLookupByLibrary.simpleMessage(
      "Upload National ID (Back)",
    ),
    "uploadNationalIdFront": MessageLookupByLibrary.simpleMessage(
      "Upload National ID (Front)",
    ),
    "uploadPassport": MessageLookupByLibrary.simpleMessage("Upload Passport"),
    "uploadPolicyDocumentArabic": MessageLookupByLibrary.simpleMessage(
      "Upload Policy Document (Arabic)",
    ),
    "uploadPolicyDocumentEnglish": MessageLookupByLibrary.simpleMessage(
      "Upload Policy Document (English)",
    ),
    "uploadSuccess": MessageLookupByLibrary.simpleMessage("Upload successful"),
    "uploadWatermark": MessageLookupByLibrary.simpleMessage("Upload Watermark"),
    "uploadedDate": MessageLookupByLibrary.simpleMessage("Uploaded Date"),
    "uploadedDocuments": MessageLookupByLibrary.simpleMessage(
      "Uploaded Documents",
    ),
    "uploadedMedia": MessageLookupByLibrary.simpleMessage("Uploaded Media"),
    "uploadedOn": MessageLookupByLibrary.simpleMessage("Uploaded On"),
    "uploaded_date": MessageLookupByLibrary.simpleMessage("Uploaded date"),
    "uploading": MessageLookupByLibrary.simpleMessage("Uploading..."),
    "uploadingAttachments": MessageLookupByLibrary.simpleMessage(
      "Uploading attachments...",
    ),
    "uploadingDocuments": MessageLookupByLibrary.simpleMessage(
      "Uploading documents...",
    ),
    "uploadingImages": MessageLookupByLibrary.simpleMessage(
      "Uploading images...",
    ),
    "uploadingRegistrationDocuments": MessageLookupByLibrary.simpleMessage(
      "Uploading registration documents...",
    ),
    "uploadingSupplier": MessageLookupByLibrary.simpleMessage(
      "Uploading Supplier",
    ),
    "urduLanguage": MessageLookupByLibrary.simpleMessage("Urdu"),
    "uruguayan": MessageLookupByLibrary.simpleMessage("Uruguayan"),
    "usageFrequency": MessageLookupByLibrary.simpleMessage("Usage Frequency"),
    "usd": MessageLookupByLibrary.simpleMessage("USD"),
    "userAccess": MessageLookupByLibrary.simpleMessage("User Access"),
    "userAccessDetails": MessageLookupByLibrary.simpleMessage(
      "User Access Details",
    ),
    "userAccessModule": MessageLookupByLibrary.simpleMessage(
      "User Access Module",
    ),
    "userAccessUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "User access has been successfully updated",
    ),
    "userEmailNotFound": MessageLookupByLibrary.simpleMessage(
      "User email not found",
    ),
    "userLimitCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Could not verify the user limits, so no access was granted. Please try again.",
    ),
    "userLimitChecking": MessageLookupByLibrary.simpleMessage(
      "Checking user limits…",
    ),
    "userLimitModuleReached": m68,
    "userLimitModuleUnverifiable": m69,
    "userLimitModuleUsage": m70,
    "userLimitSeatsLeft": m71,
    "userLimitTotalReached": m72,
    "userLimitTotalUnverifiable": MessageLookupByLibrary.simpleMessage(
      "The company user limit could not be read, so no access was granted.",
    ),
    "userLimitTotalUsage": m73,
    "userLimitUnknownRole": m74,
    "userLimitsTitle": MessageLookupByLibrary.simpleMessage("User Limits"),
    "userManagement": MessageLookupByLibrary.simpleMessage("User Management"),
    "userManagementModule": MessageLookupByLibrary.simpleMessage(
      "User Management Module",
    ),
    "userManagementRequests": MessageLookupByLibrary.simpleMessage(
      "User Management Requests",
    ),
    "usersData": MessageLookupByLibrary.simpleMessage("Users Data"),
    "usersPermission": MessageLookupByLibrary.simpleMessage("Users"),
    "usersRequests": MessageLookupByLibrary.simpleMessage("Users Requests"),
    "uzbekistani": MessageLookupByLibrary.simpleMessage("Uzbekistani"),
    "vacation": MessageLookupByLibrary.simpleMessage("Vacation"),
    "vacationCredits": MessageLookupByLibrary.simpleMessage("Vacation Credits"),
    "vacationsCredit": MessageLookupByLibrary.simpleMessage("Vacations Credit"),
    "validEmailRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email",
    ),
    "validOrderId": MessageLookupByLibrary.simpleMessage("Valid Order ID"),
    "validStorageCapacityRequired": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid storage capacity (greater than 0)",
    ),
    "validationError": MessageLookupByLibrary.simpleMessage("Validation Error"),
    "validationError_ar": MessageLookupByLibrary.simpleMessage(
      "Validation Error",
    ),
    "vat": MessageLookupByLibrary.simpleMessage("VAT"),
    "venezuelan": MessageLookupByLibrary.simpleMessage("Venezuelan"),
    "version": MessageLookupByLibrary.simpleMessage("Version:"),
    "verticalPadding": MessageLookupByLibrary.simpleMessage("Vertical Padding"),
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "video_recording": MessageLookupByLibrary.simpleMessage("Video Recording"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Vietnamese"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "viewAccess": MessageLookupByLibrary.simpleMessage("View Access"),
    "viewAccounts": MessageLookupByLibrary.simpleMessage("View Accounts"),
    "viewActivities": MessageLookupByLibrary.simpleMessage("View Activities"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewApproval": MessageLookupByLibrary.simpleMessage("View Approval"),
    "viewAttendanceReports": MessageLookupByLibrary.simpleMessage(
      "View Attendance Reports",
    ),
    "viewCRMReports": MessageLookupByLibrary.simpleMessage("View CRM Reports"),
    "viewContact": MessageLookupByLibrary.simpleMessage("View Contact"),
    "viewContacts": MessageLookupByLibrary.simpleMessage("View Contacts"),
    "viewDashboard": MessageLookupByLibrary.simpleMessage("View Dashboard"),
    "viewDeals": MessageLookupByLibrary.simpleMessage("View Deals"),
    "viewDepartments": MessageLookupByLibrary.simpleMessage("View Departments"),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View details"),
    "viewDocuments": MessageLookupByLibrary.simpleMessage("View Documents"),
    "viewDraftForm": MessageLookupByLibrary.simpleMessage("View Draft Form"),
    "viewEmployeeRecords": MessageLookupByLibrary.simpleMessage(
      "View Employee Records",
    ),
    "viewGroup": MessageLookupByLibrary.simpleMessage("View Group"),
    "viewHRAnalytics": MessageLookupByLibrary.simpleMessage(
      "View HR Analytics",
    ),
    "viewLeads": MessageLookupByLibrary.simpleMessage("View Leads"),
    "viewOnly": MessageLookupByLibrary.simpleMessage("View Only"),
    "viewPayrollReports": MessageLookupByLibrary.simpleMessage(
      "View Payroll Reports",
    ),
    "viewPerformanceReviews": MessageLookupByLibrary.simpleMessage(
      "View Performance Reviews",
    ),
    "viewPipeline": MessageLookupByLibrary.simpleMessage("View Pipeline"),
    "viewRequestedForm": MessageLookupByLibrary.simpleMessage(
      "View Requested Form",
    ),
    "viewRequesters": MessageLookupByLibrary.simpleMessage("View Requesters"),
    "viewStorageLocations": MessageLookupByLibrary.simpleMessage(
      "View Storage Locations",
    ),
    "viewSubmissions": MessageLookupByLibrary.simpleMessage("View Submissions"),
    "viewToDo": MessageLookupByLibrary.simpleMessage("View To Do"),
    "viewTrainingReports": MessageLookupByLibrary.simpleMessage(
      "View Training Reports",
    ),
    "views": MessageLookupByLibrary.simpleMessage("Views"),
    "volume": MessageLookupByLibrary.simpleMessage("Volume"),
    "waitUntilDataCome": MessageLookupByLibrary.simpleMessage(
      "Please wait while we load your services...",
    ),
    "wareHouse": MessageLookupByLibrary.simpleMessage("Ware House"),
    "warehouse": MessageLookupByLibrary.simpleMessage("Warehouse"),
    "warehouseName": MessageLookupByLibrary.simpleMessage("Warehouse Name"),
    "warehouseNumberCity": MessageLookupByLibrary.simpleMessage(
      "Warehouse {0}: City is required",
    ),
    "warehouseNumberCountry": MessageLookupByLibrary.simpleMessage(
      "Warehouse {0}: Country is required",
    ),
    "warehouseNumberPostalCode": MessageLookupByLibrary.simpleMessage(
      "Warehouse {0}: Postal Code is required",
    ),
    "warehouseNumberStreetName": MessageLookupByLibrary.simpleMessage(
      "Warehouse {0}: Street Name is required",
    ),
    "warehouses": MessageLookupByLibrary.simpleMessage("Warehouses"),
    "warehousesDetails": MessageLookupByLibrary.simpleMessage(
      "Warehouses Details",
    ),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "warningWrongEntry": MessageLookupByLibrary.simpleMessage(
      "Warning: Wrong Entry",
    ),
    "warranty": MessageLookupByLibrary.simpleMessage("Warranty"),
    "warrantyCoverageStatus": MessageLookupByLibrary.simpleMessage(
      "Warranty & Coverage Status",
    ),
    "warrantyExpirationDate": MessageLookupByLibrary.simpleMessage(
      "Warranty Expiration Date",
    ),
    "watermark": MessageLookupByLibrary.simpleMessage("Watermark"),
    "watermarkContent": MessageLookupByLibrary.simpleMessage(
      "Watermark Content",
    ),
    "watermarkDisableConfirm": MessageLookupByLibrary.simpleMessage(
      "Turn the watermark off? It will stop appearing over the app\'s pages.",
    ),
    "watermarkDisabled": MessageLookupByLibrary.simpleMessage(
      "The watermark is now off.",
    ),
    "watermarkEnableConfirm": MessageLookupByLibrary.simpleMessage(
      "Turn the watermark on? It will appear over the app\'s pages for everyone.",
    ),
    "watermarkEnabled": MessageLookupByLibrary.simpleMessage(
      "The watermark is now active.",
    ),
    "watermarkModules": MessageLookupByLibrary.simpleMessage(
      "Watermark Modules",
    ),
    "watermarkOpacity": MessageLookupByLibrary.simpleMessage(
      "Watermark Opacity",
    ),
    "watermarkSaveConfirm": MessageLookupByLibrary.simpleMessage(
      "Save the watermark settings?",
    ),
    "watermarkSaved": MessageLookupByLibrary.simpleMessage(
      "The watermark settings have been saved.",
    ),
    "watermarkSize": MessageLookupByLibrary.simpleMessage("Watermark Size"),
    "watermarkStyle": MessageLookupByLibrary.simpleMessage("Watermark Style"),
    "watermarkStyleBubble": MessageLookupByLibrary.simpleMessage("Bubble"),
    "watermarkStyleLabel": MessageLookupByLibrary.simpleMessage("Style"),
    "watermarkStyleText": MessageLookupByLibrary.simpleMessage("Text"),
    "weDLoveToHearMoreAboutYourService": MessageLookupByLibrary.simpleMessage(
      "We\'d love to hear more about your service",
    ),
    "weValueOurCustomersAndStriveToExceedTheirExpecta":
        MessageLookupByLibrary.simpleMessage(
          "We value our customers and strive to exceed their expectations",
        ),
    "webBrowser": MessageLookupByLibrary.simpleMessage("Web Browser"),
    "webOrBrowser": MessageLookupByLibrary.simpleMessage("Web / Browser"),
    "wednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
    "week": MessageLookupByLibrary.simpleMessage("Weeks"),
    "weekly": MessageLookupByLibrary.simpleMessage("Weekly"),
    "weeks": MessageLookupByLibrary.simpleMessage("Weeks"),
    "weeksAgo": MessageLookupByLibrary.simpleMessage("Weeks Ago"),
    "weight": MessageLookupByLibrary.simpleMessage("Weight"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome to our app"),
    "welsh": MessageLookupByLibrary.simpleMessage("Welsh"),
    "whenManagerApprovesServiceIfRequired":
        MessageLookupByLibrary.simpleMessage(
          "When Their Manager Approves The Service, If It Requires Approvals",
        ),
    "whenProviderBreachedSla": MessageLookupByLibrary.simpleMessage(
      "When Service Provider Breached SLA",
    ),
    "whenServiceRequestedAndApprovedIfRequired":
        MessageLookupByLibrary.simpleMessage(
          "When Service Is Requested And Approved By The Requester’s Manager If It Requires Approval",
        ),
    "whenServiceSlaIsAboutToBeBreached": MessageLookupByLibrary.simpleMessage(
      "When Service SLA Is About To Be Breached By",
    ),
    "whenServiceSlaIsBreached": MessageLookupByLibrary.simpleMessage(
      "When Service SLA Is Breached",
    ),
    "whenServiceStattusChanges": MessageLookupByLibrary.simpleMessage(
      "When Service Status Change",
    ),
    "whenServiceStatusChanges": MessageLookupByLibrary.simpleMessage(
      "When Service Status Changes",
    ),
    "whenServicesRequestedAndApprovedIfRequired":
        MessageLookupByLibrary.simpleMessage(
          "When Services Is Requested And Approved By The Requester’s Manager If It Requires Approval",
        ),
    "whenSlaIsBreached": MessageLookupByLibrary.simpleMessage(
      "When SLA Is Breached",
    ),
    "whenTheyReceiveCommentFromRequester": MessageLookupByLibrary.simpleMessage(
      "When They Receive A Comment From Service Requester",
    ),
    "whenTheyReceiveCommentFromSServiceProvider":
        MessageLookupByLibrary.simpleMessage(
          "When they receive a comment from the service provider",
        ),
    "whenTheyReceiveCommentFromServiceProvider":
        MessageLookupByLibrary.simpleMessage(
          "When They Receive A Comment From The Service Provider",
        ),
    "whichSectionDoYouWantToChange": MessageLookupByLibrary.simpleMessage(
      "Which section do you want to change?",
    ),
    "why": MessageLookupByLibrary.simpleMessage("Why"),
    "whyYouWantToLeave": MessageLookupByLibrary.simpleMessage(
      "Why you want to leave..?",
    ),
    "widget": MessageLookupByLibrary.simpleMessage("Widget"),
    "widowed": MessageLookupByLibrary.simpleMessage("Widowed"),
    "willBeReactivatedAt": MessageLookupByLibrary.simpleMessage(
      "Will Be Reactivated At",
    ),
    "willItBeANewBatch": MessageLookupByLibrary.simpleMessage(
      "Will it be a new batch?",
    ),
    "windows": MessageLookupByLibrary.simpleMessage("Windows"),
    "windowsLaptopDesktop": MessageLookupByLibrary.simpleMessage(
      "Windows Laptop / Desktop",
    ),
    "workArrangement": MessageLookupByLibrary.simpleMessage("Work Arrangement"),
    "workLocation": MessageLookupByLibrary.simpleMessage("Work Location"),
    "workPerformed": MessageLookupByLibrary.simpleMessage(
      "Work Performed/Service Actions",
    ),
    "workforce": MessageLookupByLibrary.simpleMessage("Workforce"),
    "workingHours": MessageLookupByLibrary.simpleMessage("Working Hours"),
    "workshop": MessageLookupByLibrary.simpleMessage("WorkShop"),
    "workstationsSystem": MessageLookupByLibrary.simpleMessage(
      "Workstations System",
    ),
    "writeAComment": MessageLookupByLibrary.simpleMessage("Write a comment"),
    "writeADescription": MessageLookupByLibrary.simpleMessage(
      "Write a description",
    ),
    "writeComment": MessageLookupByLibrary.simpleMessage("Write a Comment"),
    "writeOff": MessageLookupByLibrary.simpleMessage("Write-Off"),
    "write_a_comment": MessageLookupByLibrary.simpleMessage("Write a Comment"),
    "wrongCheckOutLocationMessage": MessageLookupByLibrary.simpleMessage(
      "Your check-out location does not match the company\'s designated location. Please check in from the correct location.",
    ),
    "wrongLocation": MessageLookupByLibrary.simpleMessage("Wrong Location"),
    "wrongLocationMessage": MessageLookupByLibrary.simpleMessage(
      "Your check-in location does not match the company\'s designated location. Please check in from the correct location.",
    ),
    "wrongResultOrCalculation": MessageLookupByLibrary.simpleMessage(
      "Wrong Result or Calculation",
    ),
    "wrongValidationMessage": MessageLookupByLibrary.simpleMessage(
      "Wrong Validation Message",
    ),
    "year": MessageLookupByLibrary.simpleMessage("years"),
    "yearly": MessageLookupByLibrary.simpleMessage("Yearly"),
    "years": MessageLookupByLibrary.simpleMessage("Years"),
    "yearsAgo": MessageLookupByLibrary.simpleMessage("Years Ago"),
    "yellow": MessageLookupByLibrary.simpleMessage("Yellow"),
    "yemenite": MessageLookupByLibrary.simpleMessage("Yemenite"),
    "yer": MessageLookupByLibrary.simpleMessage("YER"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "yesTitleButton": MessageLookupByLibrary.simpleMessage("Yes"),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "you": MessageLookupByLibrary.simpleMessage("You"),
    "you2": MessageLookupByLibrary.simpleMessage("You,"),
    "youCannotAddAnOptionThatAlreadyExists":
        MessageLookupByLibrary.simpleMessage(
          "You cannot add an option that already exists",
        ),
    "youCreatedThisGroup": MessageLookupByLibrary.simpleMessage(
      "You created this group",
    ),
    "youDeletedThisMessage": MessageLookupByLibrary.simpleMessage(
      "You deleted this message",
    ),
    "youGrantAccessSuccessfully": MessageLookupByLibrary.simpleMessage(
      "You Grant Access Successfully",
    ),
    "youHaveAlreadyRequestedThisAsset": MessageLookupByLibrary.simpleMessage(
      "You have already requested this asset",
    ),
    "youHaveSuccessfullyEditedControlsWeights":
        MessageLookupByLibrary.simpleMessage(
          "You have successfully edited controls weights",
        ),
    "youHaveSuccessfullyEditedPoliciesWeights":
        MessageLookupByLibrary.simpleMessage(
          "You have successfully edited policies weights",
        ),
    "youHaveSuccessfullyEqualWeightForAllControls":
        MessageLookupByLibrary.simpleMessage(
          "You have successfully assigned equal weight for all controls",
        ),
    "youHaveUnsavedChangesDoYouWantToSaveThem":
        MessageLookupByLibrary.simpleMessage(
          "You have unsaved changes. Do you want to save them?",
        ),
    "youHavenTMadeAnyChangesToSubmit": MessageLookupByLibrary.simpleMessage(
      "You haven\'t made any changes to submit",
    ),
    "youMustCorrectAllErrorsBeforeUploading":
        MessageLookupByLibrary.simpleMessage(
          "You must correct all errors before uploading",
        ),
    "youMustSolveTheseErrors": MessageLookupByLibrary.simpleMessage(
      "You must solve these errors",
    ),
    "youSuccessfullyActivatedTheseServices":
        MessageLookupByLibrary.simpleMessage(
          "You Successfully Activated These Services",
        ),
    "youSuccessfullyAddedThisControlChampion":
        MessageLookupByLibrary.simpleMessage(
          "You successfully added this control champion",
        ),
    "youSuccessfullyAddedThisControlOwner":
        MessageLookupByLibrary.simpleMessage(
          "You successfully added this control owner",
        ),
    "youSuccessfullyAddedThisProduct": MessageLookupByLibrary.simpleMessage(
      "You successfully added this product",
    ),
    "youSuccessfullyApprovedThisEvidence": MessageLookupByLibrary.simpleMessage(
      "You successfully approved this evidence",
    ),
    "youSuccessfullyApprovedThisRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully approved this request",
    ),
    "youSuccessfullyCleanedAllNotification":
        MessageLookupByLibrary.simpleMessage(
          "You Successfully Cleaned All Notification",
        ),
    "youSuccessfullyCreatePolicy": MessageLookupByLibrary.simpleMessage(
      "You Successfully Create Policy",
    ),
    "youSuccessfullyCreatedGroup": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Group",
    ),
    "youSuccessfullyCreatedNewToDo": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created New To Do",
    ),
    "youSuccessfullyCreatedThisControl": MessageLookupByLibrary.simpleMessage(
      "You successfully created this control",
    ),
    "youSuccessfullyCreatedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Created This Form",
    ),
    "youSuccessfullyCreatedThisGrcPolicy": MessageLookupByLibrary.simpleMessage(
      "You successfully created this GRC policy",
    ),
    "youSuccessfullyCreatedThisPolicy": MessageLookupByLibrary.simpleMessage(
      "You successfully created this policy",
    ),
    "youSuccessfullyDeletedAllNotifications":
        MessageLookupByLibrary.simpleMessage(
          "You successfully deleted all cleared notifications.",
        ),
    "youSuccessfullyDeletedGroup": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Group",
    ),
    "youSuccessfullyDeletedThisControl": MessageLookupByLibrary.simpleMessage(
      "You successfully deleted this control",
    ),
    "youSuccessfullyDeletedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This Form",
    ),
    "youSuccessfullyDeletedThisPolicy": MessageLookupByLibrary.simpleMessage(
      "You successfully deleted this policy",
    ),
    "youSuccessfullyDeletedThisToDo": MessageLookupByLibrary.simpleMessage(
      "You Successfully Deleted This To Do",
    ),
    "youSuccessfullyDownloadedThisFormAsExcel":
        MessageLookupByLibrary.simpleMessage(
          "You Successfully Downloaded This Form as Excel",
        ),
    "youSuccessfullyDownloadedThisFormAsPdf":
        MessageLookupByLibrary.simpleMessage(
          "You Successfully Downloaded This Form as PDF",
        ),
    "youSuccessfullyDraftedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Drafted This Form",
    ),
    "youSuccessfullyDuplicatedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Duplicated This Form",
    ),
    "youSuccessfullyEditedGroup": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Group",
    ),
    "youSuccessfullyEditedTheToDo": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited The To Do",
    ),
    "youSuccessfullyEditedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Edited This Form",
    ),
    "youSuccessfullyRejectedThisEvidence": MessageLookupByLibrary.simpleMessage(
      "You successfully rejected this evidence",
    ),
    "youSuccessfullyRejectedThisRequest": MessageLookupByLibrary.simpleMessage(
      "You successfully rejected this request",
    ),
    "youSuccessfullyRemovedEmployee": MessageLookupByLibrary.simpleMessage(
      "You Successfully Removed Employee",
    ),
    "youSuccessfullyRestoredThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Restored This Form",
    ),
    "youSuccessfullyRestoredThisToDo": MessageLookupByLibrary.simpleMessage(
      "You Successfully Restored This To Do",
    ),
    "youSuccessfullySubmittedThisForm": MessageLookupByLibrary.simpleMessage(
      "You Successfully Submitted This Form",
    ),
    "youSuccessfullyUpdatedThisControl": MessageLookupByLibrary.simpleMessage(
      "You successfully updated this control",
    ),
    "youSuccessfullyUpdatedThisPolicy": MessageLookupByLibrary.simpleMessage(
      "You successfully updated this policy",
    ),
    "yourDraftWasSaved": MessageLookupByLibrary.simpleMessage(
      "Your draft was saved successfully",
    ),
    "yourEvidenceWasSubmittedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Your evidence was submitted successfully",
        ),
    "yourReassignChampionRequestHasBeenSubmitted":
        MessageLookupByLibrary.simpleMessage(
          "Your reassign champion request has been submitted",
        ),
    "yourReassignOwnerRequestHasBeenSubmitted":
        MessageLookupByLibrary.simpleMessage(
          "Your reassign owner request has been submitted",
        ),
    "zambian": MessageLookupByLibrary.simpleMessage("Zambian"),
    "zimbabwean": MessageLookupByLibrary.simpleMessage("Zimbabwean"),
    "zipCodeOrPostalCode": MessageLookupByLibrary.simpleMessage(
      "Zip Code or Postal Code",
    ),
  };
}
