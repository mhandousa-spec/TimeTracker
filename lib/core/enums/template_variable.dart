/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: template_variable.dart
/// Purpose: Enum `TemplateVariable` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-011: + `countedRequests`.

/// ************************* FILE INFO ************************* ///
/// File Name: template_variable.dart
/// Purpose: Every dynamic placeholder that can appear in a piece of
///          templated text — a notification title/body, or a calendar card
///          description. Shared, so both features substitute the same
///          tokens the same way.
///
/// Convention: `{{camelCase}}` — TemplateVariable.serviceName renders as
/// `{{serviceName}}` and is replaced at render time.
///
/// LAYOUT: grouped by the module that uses the placeholder. A variable used
/// by two or more modules lives in SHARED at the top and appears exactly
/// once — never copy it into a module section. Adding a variable: put it
/// under its module; if a second module later needs it, move it to SHARED.
///
/// Was `NotificationVariable` inside the notification feature; moved to
/// core once the calendar needed it too.
///
/// RULE: never type a placeholder as a raw string. Use the enum and
/// `toTemplateVariables()`.

enum TemplateVariable {
  // ///////////////  SHARED  —  used by more than one module  ////////////////
  // Do NOT duplicate these into a module section. If a second module starts
  // using a module-specific variable below, move it up here instead.
  approverName('approverName'),
  departmentName('departmentName'),
  documentName('documentName'),
  dueDate('dueDate'),
  employeeName('employeeName'),
  endDate('endDate'),
  moduleName('moduleName'),
  newActivationDate('newActivationDate'),
  oldActivationDate('oldActivationDate'),
  rejectionReason('rejectionReason'),
  requesterName('requesterName'),
  scheduledDate('scheduledDate'),
  startDate('startDate'),
  status('status'),
  userName('userName'),

  // //////////////////////////  SERVICE MANAGEMENT  //////////////////////////
  serviceName('serviceName'),

  // ////////////////////////////  KNOWLEDGE HUB  /////////////////////////////
  // Uses only shared variables: documentName, endDate.
  // (none of its own)

  // //////////////////////////////  TO-DO LIST  //////////////////////////////
  toDoName('toDoName'),

  // ///////////////////////////  ROLE MANAGEMENT  ////////////////////////////
  accessGrantedDate('accessGrantedDate'),
  accessRevokedDate('accessRevokedDate'),
  newStatus('newStatus'),
  oldStatus('oldStatus'),
  roleName('roleName'),

  // /////////////////////////////  USER ACCESS  //////////////////////////////
  newDeactivationDate('newDeactivationDate'),
  oldDeactivationDate('oldDeactivationDate'),

  // ////////////////////  USER MANAGEMENT & PERMISSIONS  /////////////////////
  // Uses only shared variables: userName, scheduledDate.
  // (none of its own)

  // //////////////////////  TIME TRACKER & ATTENDANCE  ///////////////////////
  count('count'),
  // ADDED 9/10/2026 (Time Tracker QA KP-TT-011): the count WITH its noun in
  // correct grammar — "1 request" / "3 requests", "طلب واحد" / "طلبان" /
  // "3 طلبات" / "11 طلبا" (`TimeTrackerCountWording`). Same token in the
  // Cloud Functions' texts.
  countedRequests('countedRequests'),
  minutes('minutes'),
  requestType('requestType'),
  time('time'),

  // /////////////////////////  DATABASE MANAGEMENT  //////////////////////////
  columnName('columnName'),
  databaseName('databaseName'),
  permissionLevel('permissionLevel'),
  tableName('tableName'),

  // ////////////////////////////////  QIYAS  /////////////////////////////////
  fileName('fileName'),
  frameworkName('frameworkName'),

  // /////////////////////////////////  GRC  //////////////////////////////////
  activationDate('activationDate'),
  controlChampionName('controlChampionName'),
  controlName('controlName'),
  controlOwnerName('controlOwnerName'),
  controlScore('controlScore'),
  currentChampionName('currentChampionName'),
  departmentManagerName('departmentManagerName'),
  newChampionName('newChampionName'),
  newControlName('newControlName'),
  newControlScore('newControlScore'),
  newDate('newDate'),
  newEndDate('newEndDate'),
  newOwnerName('newOwnerName'),
  newStartDate('newStartDate'),
  newWeight('newWeight'),
  oldControlName('oldControlName'),
  oldControlScore('oldControlScore'),
  oldDate('oldDate'),
  oldEndDate('oldEndDate'),
  oldStartDate('oldStartDate'),
  oldWeight('oldWeight'),
  policyName('policyName'),
  uploadedByUserName('uploadedByUserName'),

  // ///////////////////////////////  SETTINGS  ///////////////////////////////
  companyName('companyName'),
  feedbackType('feedbackType'),
  permissionName('permissionName'),

  // ///////////////////////////////  MESSAGES  ///////////////////////////////
  // ADDED 2/9/2026 for section 2.4 of the notification spec.
  //
  // `fileName` is NOT here — it already lives in the GRC section above and the
  // "File Attachment Received" event reuses it. Per the LAYOUT rule at the top
  // of this file it should be moved to SHARED now that a second module uses
  // it; left in place for this change so the diff stays about Messages, but
  // that is the correct follow-up.
  addedByName('addedByName'),
  chatName('chatName'),
  createdByName('createdByName'),
  deletedByName('deletedByName'),
  groupName('groupName'),
  /// The first ~50 characters of the message, NOT the whole body. A
  /// notification is a pointer to the conversation, not a copy of it, and a
  /// full message in a push payload leaks content onto a lock screen.
  messagePreview('messagePreview'),
  optionName('optionName'),
  pollQuestion('pollQuestion'),
  recipientName('recipientName'),
  removedByName('removedByName'),
  senderName('senderName'),
  /// Rendered as a string because every other variable is. The calendar's
  /// unread reminder updates this in place rather than raising a second entry.
  unreadMessageCount('unreadMessageCount'),
  voterName('voterName'),

  // ////////////////////////  NOTIFICATIONS CONTROL  /////////////////////////
  channel('channel'),
  requestStatus('requestStatus'),

  // /////////////  LEGACY  —  no longer referenced by any event  /////////////
  // Kept so older Firestore templates that still contain the token keep
  // rendering. Safe to delete once no template text uses it.
  cancelledBy('cancelledBy'),

  ;

  const TemplateVariable(this.key);

  /// Bare name, e.g. 'serviceName' — this is the map key passed to
  /// AppNotificationSender.sendFromTemplate(variables: ...).
  final String key;

  /// The literal token as written inside a template: `{{serviceName}}`.
  String get token => '{{$key}}';
}

/// Convenience: build the `variables` map without typing raw strings.
extension TemplateVariableMap on Map<TemplateVariable, String> {
  Map<String, String> toTemplateVariables() =>
      map((k, val) => MapEntry(k.key, val));
}
