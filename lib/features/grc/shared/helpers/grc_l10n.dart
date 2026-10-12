/// Module: GRC shared
/// Description: Runtime lookup that localizes GRC strings which are only
///              known at runtime — enum labels, table headers, tab titles
///              and status names that arrive as plain English strings from
///              the domain layer. Replaces the GetX `.tr` extension that was
///              used on those values before the S/ARB migration.
///
///              Static UI text uses `S.of(context).<key>` directly; this
///              helper exists only for the dynamic cases, and returns the
///              input unchanged when a value has no registered translation.
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Localizes [raw], an English string produced at runtime.
///
/// Falls back to [raw] when no key is registered, so an unmapped value
/// degrades to the current behaviour instead of throwing.
String grcTr(BuildContext context, String raw) {
  final s = S.of(context);
  switch (raw) {
    case 'ASC':
      return s.asc;
    case 'Active':
      return s.active;
    case 'All':
      return s.all;
    case 'Annually':
      return s.frequencyAnnually;
    case 'Approved':
      return s.status_approved;
    case 'Are You Sure You Want To Delete This GRC Module ?':
      return s.areYouSureYouWantToDeleteThisGrcModule;
    case 'Assigned By':
      return s.assignedBy;
    case 'Bi weekly':
      return s.biWeekly;
    case 'Changed By':
      return s.changedBy;
    case 'Choose Control':
      return s.chooseControl;
    case 'Control':
      return s.control;
    case 'Control Champions':
      return s.controlChampions;
    case 'Control Changes':
      return s.controlChanges;
    case 'Control Description':
      return s.controlDescription;
    case 'Control Name':
      return s.controlName;
    case 'Control Number':
      return s.controlNumber;
    case 'Control Owner':
      return s.controlOwner;
    case 'Control Owners':
      return s.controlOwners;
    case 'Control Weight':
      return s.controlWeight;
    case 'Control Weight Current':
      return s.controlWeightCurrent;
    case 'Control Weight Previous':
      return s.controlWeightPrevious;
    case 'Creation Date':
      return s.creationDate;
    case 'DES':
      return s.des;
    case 'Date Of Action':
      return s.dateOfAction;
    case 'Deleting GRC Module':
      return s.deletingGrcModule;
    case 'Departments':
      return s.departments;
    case 'Description':
      return s.description;
    case 'Draft':
      return s.draft;
    case 'End Date':
      return s.endDate;
    case 'Expired':
      return s.expired;
    case 'Frequency':
      return s.frequency;
    case 'IT':
      return s.itDepartment;
    case 'In Review':
      return s.inReview;
    case 'In review':
      return s.inReview;
    case 'Inactive':
      return s.inactive;
    case 'Last Update':
      return s.lastUpdate;
    case 'Monthly':
      return s.frequencyMonthly;
    case 'NO':
      return s.no;
    case 'No of Controls':
      return s.noOfControls;
    case 'No of Departments':
      return s.noOfDepartments;
    case 'Outstanding':
      return s.outstanding;
    case 'Overdue':
      return s.overdue;
    case 'Pending':
      return s.status_pending;
    case 'Policies':
      return s.policies;
    case 'Last Edit Date':
      return s.lastUpdate;
    case 'Policy Description':
      return s.policyDescription;
    case 'Policy Document':
      return s.policyDocument;
    case 'Policy Name':
      return s.policyName;
    case 'Policy Number':
      return s.policyNumber;
    case 'Policy Number Ar':
      return s.policyNumberAr;
    case 'Policy Weight':
      return s.policyWeight;
    case 'Policy Weight Current':
      return s.policyWeightCurrent;
    case 'Policy Weight Previous':
      return s.policyWeightPrevious;
    case 'Previous Owner':
      return s.previousOwner;
    case 'Quarterly':
      return s.frequencyQuarterly;
    case 'Reassign Control Champion':
      return s.reassignControlChampion;
    case 'Reassign Control Owner':
      return s.reassignControlOwner;
    case 'Rejected':
      return s.status_rejected;
    case 'Removed':
      return s.removed;
    case 'Resubmit Evidence':
      return s.resubmitEvidence;
    case 'Scheduled':
      return s.scheduled;
    case 'Scored':
      return s.scored;
    case 'Score':
      return s.score;
    case 'Semi Annual':
      return s.semiAnnual;
    case 'Start Date':
      return s.startDate;
    case 'Status':
      return s.status;
    case 'Submitted':
      return s.submitted;
    case 'Technician':
      return s.technician;
    case 'Unassigned':
      return s.unassigned;
    case 'Upload Evidence':
      return s.uploadEvidence;
    case 'Weekly':
      return s.weekly;
    case 'Weight':
      return s.weight;
  }
  return raw;
}
