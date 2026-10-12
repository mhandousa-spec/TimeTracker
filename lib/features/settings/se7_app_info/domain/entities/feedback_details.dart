/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_details.dart
/// Purpose: The structured triage fields the "More Options" panel collects for
///          one feedback box — which module and screen the problem is on, what
///          kind of problem it is, on what device, how often, and the steps to
///          reproduce it.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// WHY THIS IS A SEPARATE FILE. `app_feedback.dart` already holds the three
/// enums that describe a submission's LIFECYCLE — kind, status, priority. These
/// seven describe its CONTENT, they are a closed taxonomy that will grow every
/// time a module is added to the app, and there are enough of them that folding
/// them in would double the length of that file. [AppFeedback] imports this;
/// nothing imports back.
///
/// EVERY FIELD IS OPTIONAL. The design puts these behind a collapsed "More
/// Options" header precisely because a user reporting a typo should not have to
/// answer seven dropdowns first. A null means "not answered", never a default —
/// see the note on [FeedbackPriority.fromWire], which this file follows.
///
/// WIRE VALUES ARE SNAKE_CASE AND PERMANENT. They are what lands in Firestore.
/// Renaming an enum CONSTANT is free; renaming its [wireValue] orphans every
/// document already written, exactly as [FeedbackKind] documents.

/// Function Name: [_fromWire]
///
/// Purpose: The one lookup every enum below shares — match a stored string
///          against a list of values, or give back null.
///
/// Parameters:
/// - [values]: the enum's `values` list.
/// - [wireOf]: reads the [wireValue] off one of them.
/// - [raw]: whatever Firestore had, which may be null, empty, or a value
///   written by a build that knew an option this one does not.
///
/// Returns: the matching value, or null.
///
/// Null rather than a first-value default, in all seven cases. These fields
/// feed triage: showing "iPhone" for a document whose device field never
/// resolved would be a fabricated answer that reads exactly like a real one.
import 'package:flutter/foundation.dart' show ValueGetter;

T? _fromWire<T>(
  List<T> values,
  String Function(T) wireOf,
  String? raw,
) {
  final String normalized = (raw ?? '').toLowerCase().trim();
  if (normalized.isEmpty) return null;
  for (final T value in values) {
    if (wireOf(value) == normalized) return value;
  }
  return null;
}

/// Which part of the app the report is about.
///
/// Mirrors the app's own module list, so this enum grows whenever a module is
/// added. [settings] is last to match the order the menu draws them in.
enum FeedbackModule {
  requests('requests'),
  home('home'),
  hr('hr'),
  knowledgeHub('knowledge_hub'),
  services('services'),
  formBuilder('form_builder'),
  messages('messages'),
  database('database'),
  notifications('notifications'),
  calendar('calendar'),
  roleManagement('role_management'),
  settings('settings');

  const FeedbackModule(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackModule? fromWire(String? value) =>
      _fromWire(values, (FeedbackModule v) => v.wireValue, value);
}

/// The specific screen or flow inside the module.
///
/// Deliberately NOT derived from [FeedbackModule]: the design draws one flat
/// list, and a dependent second dropdown would need a mapping for all twelve
/// modules before any of it could ship. When that mapping exists, filter this
/// list by the chosen module — the wire values do not have to change for that.
enum FeedbackScreenSection {
  leaveRequestApproval('leave_request_approval'),
  leaveRequestNew('leave_request_new'),
  leaveRequestList('leave_request_list'),
  businessTrip('business_trip'),
  expenseClaim('expense_claim'),
  certificateRequest('certificate_request');

  const FeedbackScreenSection(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackScreenSection? fromWire(String? value) =>
      _fromWire(values, (FeedbackScreenSection v) => v.wireValue, value);
}

/// Something that looks wrong.
///
/// Split from [FeedbackLogicIssue] because the design draws two dropdowns, and
/// because they route differently: a design issue goes to whoever owns the
/// component, a logic issue goes to whoever owns the feature. A report can
/// carry both — a screen can be both misaligned AND failing to save.
enum FeedbackDesignIssue {
  layoutAlignment('layout_alignment'),
  coloursContrast('colours_contrast'),
  textFont('text_font'),
  iconsImages('icons_images'),
  spacingSizing('spacing_sizing'),
  arabicRtlLayout('arabic_rtl_layout'),
  darkMode('dark_mode'),
  doesntFitMyScreen('doesnt_fit_my_screen'),
  otherDesignIssue('other_design_issue');

  const FeedbackDesignIssue(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackDesignIssue? fromWire(String? value) =>
      _fromWire(values, (FeedbackDesignIssue v) => v.wireValue, value);
}

/// Something that behaves wrong. See the note on [FeedbackDesignIssue].
enum FeedbackLogicIssue {
  buttonActionNotWorking('button_action_not_working'),
  wrongResultOrCalculation('wrong_result_or_calculation'),
  dataNotSaving('data_not_saving'),
  dataNotLoading('data_not_loading'),
  wrongValidationMessage('wrong_validation_message'),
  accessDeniedWrongly('access_denied_wrongly'),
  notificationNotReceived('notification_not_received'),
  duplicatedOrOutOfSync('duplicated_or_out_of_sync'),
  crashOrFreeze('crash_or_freeze'),
  otherLogicIssue('other_logic_issue');

  const FeedbackLogicIssue(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackLogicIssue? fromWire(String? value) =>
      _fromWire(values, (FeedbackLogicIssue v) => v.wireValue, value);
}

/// The hardware the problem was seen on.
///
/// Kept separate from [FeedbackSoftwareType] because the pair is what narrows a
/// bug down: "iPad" alone does not distinguish the native app from Safari on
/// the same device, and the two dropdowns together do.
enum FeedbackDevice {
  iphone('iphone'),
  ipad('ipad'),
  androidPhone('android_phone'),
  androidTablet('android_tablet'),
  windowsLaptopDesktop('windows_laptop_desktop'),
  macLaptopDesktop('mac_laptop_desktop'),
  webBrowser('web_browser'),
  other('other');

  const FeedbackDevice(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackDevice? fromWire(String? value) =>
      _fromWire(values, (FeedbackDevice v) => v.wireValue, value);
}

/// The platform the app was running on. See the note on [FeedbackDevice].
///
/// Intentionally NOT the OS version — the design's dropdown offers platforms,
/// and a free-text version field would be one more thing to fill in for a
/// number the crash report already carries.
enum FeedbackSoftwareType {
  ios('ios'),
  ipados('ipados'),
  android('android'),
  windows('windows'),
  macos('macos'),
  webOrBrowser('web_or_browser');

  const FeedbackSoftwareType(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackSoftwareType? fromWire(String? value) =>
      _fromWire(values, (FeedbackSoftwareType v) => v.wireValue, value);
}

/// How reproducible the problem is.
///
/// Ordered most-reproducible first, which is also roughly triage order: an
/// [everyTime] bug can be picked up and reproduced immediately, a
/// [happenedOnce] one usually needs the logs instead.
enum FeedbackFrequency {
  everyTime('every_time'),
  mostOfTheTime('most_of_the_time'),
  rarely('rarely'),
  happenedOnce('happened_once');

  const FeedbackFrequency(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackFrequency? fromWire(String? value) =>
      _fromWire(values, (FeedbackFrequency v) => v.wireValue, value);
}

/// Everything the "More Options" panel collects for ONE box.
///
/// Immutable, and one instance per [FeedbackKind] — the form lets a user report
/// a bug on the Requests module and ask for a feature on the Calendar in the
/// same submission, so these cannot live on the submission as a whole.
///
/// [stepsToReproduce] is a String rather than a `List<String>`: the design
/// draws one multi-line box, and splitting it on newlines here would put a
/// parser between what the user typed and what a triager reads.
class FeedbackDetails {
  const FeedbackDetails({
    this.module,
    this.screenSection,
    this.designIssue,
    this.logicIssue,
    this.device,
    this.softwareType,
    this.frequency,
    this.stepsToReproduce = '',
  });

  final FeedbackModule? module;
  final FeedbackScreenSection? screenSection;
  final FeedbackDesignIssue? designIssue;
  final FeedbackLogicIssue? logicIssue;
  final FeedbackDevice? device;
  final FeedbackSoftwareType? softwareType;
  final FeedbackFrequency? frequency;

  /// Free text, capped at 500 characters by the field that fills it.
  final String stepsToReproduce;

  /// The maximum the "Steps to reproduce" box accepts.
  ///
  /// Here rather than in the screen so the counter under the field and any
  /// future server-side check cannot disagree about the number.
  static const int maxStepsLength = 500;

  /// True when the user opened "More Options" and answered nothing.
  ///
  /// The data source tests this to decide whether to write a `details` map at
  /// all, so a document from someone who never opened the panel carries no
  /// empty object for a triager to squint at.
  bool get isEmpty =>
      module == null &&
      screenSection == null &&
      designIssue == null &&
      logicIssue == null &&
      device == null &&
      softwareType == null &&
      frequency == null &&
      stepsToReproduce.trim().isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Function Name: [copyWith]
  ///
  /// Purpose: One field changed, the rest carried over.
  ///
  /// CHANGED 8/9/2026 — the seven dropdown fields now take `ValueGetter`
  /// sentinels, exactly as the warning that used to sit here said they would
  /// have to if a "clear" affordance was ever added to a dropdown. One has
  /// been: tapping the selected item again clears the field, so `copyWith`
  /// has to be able to tell "leave it alone" (omit the argument) apart from
  /// "set it to null" (`module: () => null`), which plain `??` cannot.
  ///
  ///     details.copyWith(module: () => value)   // set, or clear when null
  ///     details.copyWith()                      // module untouched
  ///
  /// [stepsToReproduce] keeps the plain `String?` form: it is a text field, it
  /// is never cleared to null, and an empty string already means "blank".
  FeedbackDetails copyWith({
    ValueGetter<FeedbackModule?>? module,
    ValueGetter<FeedbackScreenSection?>? screenSection,
    ValueGetter<FeedbackDesignIssue?>? designIssue,
    ValueGetter<FeedbackLogicIssue?>? logicIssue,
    ValueGetter<FeedbackDevice?>? device,
    ValueGetter<FeedbackSoftwareType?>? softwareType,
    ValueGetter<FeedbackFrequency?>? frequency,
    String? stepsToReproduce,
  }) {
    return FeedbackDetails(
      module: module != null ? module() : this.module,
      screenSection:
          screenSection != null ? screenSection() : this.screenSection,
      designIssue: designIssue != null ? designIssue() : this.designIssue,
      logicIssue: logicIssue != null ? logicIssue() : this.logicIssue,
      device: device != null ? device() : this.device,
      softwareType: softwareType != null ? softwareType() : this.softwareType,
      frequency: frequency != null ? frequency() : this.frequency,
      stepsToReproduce: stepsToReproduce ?? this.stepsToReproduce,
    );
  }

  /// Function Name: [toMap]
  ///
  /// Purpose: The nested `details` object on a feedback document.
  ///
  /// Unanswered fields are written as explicit nulls rather than omitted, so a
  /// triage query can test `details.device == null` without having to know
  /// whether the field is missing or empty. [stepsToReproduce] is trimmed and
  /// collapses to null when blank, for the same reason.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'module': module?.wireValue,
        'screenSection': screenSection?.wireValue,
        'designIssue': designIssue?.wireValue,
        'logicIssue': logicIssue?.wireValue,
        'device': device?.wireValue,
        'softwareType': softwareType?.wireValue,
        'frequency': frequency?.wireValue,
        'stepsToReproduce':
            stepsToReproduce.trim().isEmpty ? null : stepsToReproduce.trim(),
      };

  /// Function Name: [fromMap]
  ///
  /// Purpose: Rebuild a panel's answers from a stored document.
  ///
  /// Parameters:
  /// - [map]: the document's `details` object, or null on every document
  ///   written before 2/9/2026.
  ///
  /// Returns: an empty [FeedbackDetails] for a null or malformed [map], never
  ///          null. A caller rendering a request card should not have to
  ///          null-check the whole object before asking whether it has a
  ///          device on it.
  static FeedbackDetails fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FeedbackDetails();

    return FeedbackDetails(
      module: FeedbackModule.fromWire(map['module']?.toString()),
      screenSection:
          FeedbackScreenSection.fromWire(map['screenSection']?.toString()),
      designIssue:
          FeedbackDesignIssue.fromWire(map['designIssue']?.toString()),
      logicIssue: FeedbackLogicIssue.fromWire(map['logicIssue']?.toString()),
      device: FeedbackDevice.fromWire(map['device']?.toString()),
      softwareType:
          FeedbackSoftwareType.fromWire(map['softwareType']?.toString()),
      frequency: FeedbackFrequency.fromWire(map['frequency']?.toString()),
      stepsToReproduce: map['stepsToReproduce']?.toString() ?? '',
    );
  }
}
