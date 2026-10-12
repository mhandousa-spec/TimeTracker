# Time Tracker — server notifications (Cloud Functions)

Server side of the Knowticed Plus Time Tracker notifications, built from
`NOTIFICATIONS_VERIFIED.md` ("DECISIONS — Moataz 9 Oct") and the 9 Oct
schema (`target.json`). **Written, not deployed.** It replaces the client
sweep `TimeTrackerReminderSweeper` and the client-side `pending_approvals`
sends.

- Plain JavaScript (CommonJS), Node 20 runtime, `firebase-functions` v2 +
  `firebase-admin`.
- Every decision is a pure function in `src/rules/` (no firebase import).
  `src/index.js` holds the two thin wrappers; `src/runner.js` is the glue
  (Firestore instance injected).
- Tests use Node's built-in runner and an in-memory Firestore, so they need
  no `npm install`:

```sh
node --test functions/time_tracker/test            # from the app repo root
# or: cd functions/time_tracker && node --test test
```

## Files

| Path | What |
|---|---|
| `src/index.js` | `ttScheduler` (every 5 min) and `ttPendingApprovals` (Firestore trigger) |
| `src/runner.js` | orchestration: companies, employees, plan, send-once transaction, push |
| `src/data.js` | Firestore reads (bounded; see "Reads") |
| `src/history.js` | port of the app's `TimeTrackerHistoryCodec` (append one row to every field + `timestamps`, carry unknown fields, front-pad) + audit trio |
| `src/fields.js` | tolerant readers for the app's current names and the target names |
| `src/schema.js` | paths, field names (`[app today, target]`), pages, permission keys |
| `src/texts.js` | EN/AR defaults, template resolution, `{{var}}` rendering |
| `src/notifications.js` | the `Notifications` document and the FCM push, as the app writes them |
| `src/config.js` | constants and environment switches |
| `src/rules/time.js` | time zones: wall time to UTC (DST safe), day keys, weekdays, `{{time}}` format |
| `src/rules/schedule.js` | effective set-up per employee: location defaults, group / employee `Custom_Rules`, HR shifts, the shift of a day |
| `src/rules/attendance.js` | reads an Attendance day (sessions, Pauses, Breaks, Alerts), totals |
| `src/rules/reminders.js` | missed check-in / check-out, shift start / end reminders, late arrival, absent finalisation |
| `src/rules/breaks.js` | break limit reached / exceeded (+ manager), pause exceeded, overruns that ended between runs |
| `src/rules/autoCheckOut.js` | auto check-out decision and the session rewrite |
| `src/rules/alerts.js` | `Attendance.Alerts[]` records and final `Minutes_Over` |
| `src/rules/approvals.js` | approval rounds, `waitsFor`, real pending count, receivers, trigger transitions, daily reminder |
| `src/rules/access.js` | Employees_Info directory, roles, switches, HR approvers, direct manager |
| `src/rules/leaves.js` | approved leave / permission coverage (D3) |
| `src/rules/dedupe.js` | `Notification_Log` marker id and body |
| `src/rules/mutations.js` | the attendance write (always one appended history row, lists wrapped `{Values:[…]}`) |
| `src/rules/planner.js` | everything that is due for one employee at one instant |
| `test/*.test.js` | 110 tests; `test/index.js` lets `node --test <dir>` work |

## The two functions

### `ttScheduler` — every 5 minutes

For each company under `Demo/` that has a `Modules/time_tracker` document
(or only `TT_COMPANY_IDS`), for each employee with an assignment:

| Event (key) | When | Receiver | Also writes |
|---|---|---|---|
| `shift_start_reminder` | 15 min before the shift start, until the start; working day, not checked in, no whole-day leave | employee | — |
| `missed_check_in` | from start + Late After until the shift end; working day, no session, no leave | employee | Alert `missed_check_in` (creates the day in the app's row shape if missing) |
| `shift_end_reminder` | at the shift end, for 30 min, while checked in | employee | — |
| `missed_check_out` | shift end + 30 min, until the auto check-out, while checked in | employee | Alert `missed_check_out` |
| `automatic_check_out_applied` | shift end + `Auto_Check_Out_After_Minutes` (default 120), session still open | employee | session closed at the **shift end**, `Is_Auto_Check_Out = true`, running pause / break closed, totals recomputed, Alert `auto_check_out` |
| `break_completed` | open Break reaches the allowed break minutes (break keeps running) | employee | — |
| `break_duration_exceeded` | open Break past limit + 5 min | employee | Alert `break_exceeded` (final `Minutes_Over` when the break ends) |
| `break_policy_violation_manager` | same moment, every time | the employee's **direct manager** (Employees_Info `Supervisor`), never HR | — |
| `pause_duration_exceeded` | open Pause past the employee's effective `Allowed_Pause_Minutes` (see "Break and pause rules"); only when his effective `Is_Pause_Allowed` is on; missing = no limit | employee | Alert `pause_exceeded` (final `Minutes_Over` when the pause ends) |
| `pending_approvals` (`Is_Reminder = true`) | once a day from 09:00 company time, for approvers with a request waiting more than 2 days | each such approver, count = real pending total, link = oldest overdue | — |
| `late_arrival_recorded` | **Sent by the APP at check-in** (decision B3: `CheckInCubit.checkIn` sends it and writes the `late_arrival` alert in the same check-in write). The server rule is **OFF by default**; `TT_LATE_ARRIVAL_ON_SERVER=true` turns on a fallback, which never fires when the day already has a `late_arrival` alert | employee | Alert `late_arrival` (fallback only) |

Record-only upkeep in the same run: final `Minutes_Over` for ended
overruns, alerts for overruns that ended between two runs, and
`Attendance_Status = absent` on a day the server created for a missed
check-in once its shift ends (the client absent sweep skips days that
already exist).

Rules applied: time zone and break / pause limits as described below.
Hours, working days and Late After come from the location. HR companies
(licence `hr` on) read
`Modules/hr/Shift_Assignments` and `Shifts`; their week is unknown, so start
reminders, missed check-in and absent are skipped (decision 9, on hold).
Overnight shifts end the next day. A session started after its day's shift
end counts as extra work: no end reminders and no auto check-out.

### `ttPendingApprovals` — `Demo/{companyId}/Modules/time_tracker/Requests/{requestId}` written

Sends `pending_approvals` when the request **enters a step** (created, moved
from manager to HR, cancellation round opened; `Is_Reminder = false`) or the
requester's **Send reminder** moved `Last_Reminder_Date_Time` forward
(`Is_Reminder = true`, "Reminder" title and body). Receivers: the manager on
a manager step; every HR approver (`Approve_And_Reject` +
`Approvals_All_Departments`) on an HR step. Never the requester, and never
the person who decided the manager step of the same round. `{{count}}` is the
approver's real pending total over the company's requests, computed at send
time (this fixes the count bug); `{{countedRequests}}` is that number WITH its
noun in correct grammar — "1 request" / "3 requests", "طلب واحد" / "طلبان" /
"3 طلبات" / "11 طلبا" (QA KP-TT-011, 9/10/2026; `texts.countedRequests`, same
rule as the app's `TimeTrackerCountWording`). Sender = the request's `Modified_By`.

### Send once

Each send creates `Modules/time_tracker/Notification_Log/{subject}__{event}__{occurrenceMs}`
in the same transaction as the notification and attendance write. This is
the app's own `notificationLogDocId` scheme, so a marker left by the old
client sweep (same id for missed check-in / check-out) also blocks the
server. Inside the transaction the attendance day is re-read and the plan
recomputed; an event that is no longer due (checked out, resumed) is
dropped. Markers record an `Outcome` (`sent`, `disabled`, `no_permission`,
`no_receiver`, `on_leave`).

Gates: the template's `isEnabled` (Notification Control) for every event;
`Check_In_And_Out` for the employee reminders; `View_Approvals` +
`Approve_And_Reject` for the daily reminder. A disabled or ungated
notification still writes its data change (auto check-out, alerts), except
that a missed check-in without the permission writes nothing.

## Company settings — `Demo/{cid}/Modules/time_tracker/Settings/general`

House history document (`timestamps` + one entry per field per revision).
Approved schema: it holds **only** this field:

| Field | Default | Meaning |
|---|---|---|
| `Auto_Check_Out_After_Minutes` | 120 | minutes after the shift end; a value of 0 or less turns auto check-out off |

Break / pause limits and the time zone are NOT read from here (a stray
`Allowed_Pause_Minutes` or `Time_Zone` in this document is ignored).

## Break and pause rules (approved schema)

The **Location** holds the defaults for everyone there:
`Is_Break_Allowed`, `Allowed_Break_Minutes` (the app's legacy
`Break_Minutes` is read as a fallback), `Is_Pause_Allowed`,
`Allowed_Pause_Minutes` (missing = no pause limit).

A **Group** or a **Location_Assignment** may override them with the
optional history field `Custom_Rules` = map `{Is_Custom, Is_Break_Allowed,
Allowed_Break_Minutes, Is_Pause_Allowed, Allowed_Pause_Minutes}`. The current
value is its last history entry. Resolution:

1. the employee's `Custom_Rules` when `Is_Custom` is true;
2. else the live group's `Custom_Rules` (the assignment's `Group_Id`, group
   not deleted) when `Is_Custom` is true;
3. else the location defaults.

Inside a `Custom_Rules` map a missing `Allowed_Pause_Minutes` means no pause
limit. Fallback only: when a group or assignment has no `Custom_Rules`, the
app's legacy flat fields (`Is_Custom_Rules` (missing = true),
`Is_Break_Allowed`, `Break_Minutes`, `Is_Pause_Allowed`) are read the same
way. They carry no pause length, so the location's `Allowed_Pause_Minutes`
applies. A limit counts only when its feature is allowed for the employee.
HR companies: pause allowed, no breaks; pause limit = the HR location's
`Allowed_Pause_Minutes` if it has one, else none.

## Time zone (D4)

1. the check-in location's `Time_Zone` (the employee's assigned location;
   `hr/Locations` for HR companies);
2. else the company record's `Time_Zone`;
3. else `TT_DEFAULT_TIME_ZONE` (last resort, default `Asia/Riyadh`).

**Where the company record lives.** Company-scoped paths only, in this
order:

1. `Demo/{cid}/Companys/{cid}` (sic) — where the record lives today. The
   app's Settings reads it through `ApiConstants.company`
   (`{baseUri}/Companys`), and the Admin app writes it there on licensing
   (`addCompanyModelWithinTransaction`).
2. `Demo/{cid}/Companies/{cid}` — the approved rename. The migration is not
   done yet.

The top-level `Companys/{cid}` / `Companies/{cid}` copies are not read
because they are not company-scoped. The server takes the first valid IANA
`Time_Zone`, otherwise `TT_DEFAULT_TIME_ZONE`. It accepts the record's nested
per-field shape `{Time_Zone: {Time_Zone: [...], Timestamp: [...]}}`, a plain
history list, a scalar, or the legacy camelCase `timeZone` twin. The record
does not store `Time_Zone` yet: Settings / Admin must add it (proposed in
target.json). Until then, locations without `Time_Zone` use the env default.
The value is cached 10 minutes per warm instance. The daily
pending-approvals reminder uses the company zone.

## Alerts — stored shape (house history)

`Attendance` is an indexed-history document, so every revision appends one
entry to every field. A history entry that is itself a list is wrapped
`{Values: [...]}`, because Firestore forbids arrays inside arrays:

```
Alerts: [
  {Values: [{Alert_Type: "missed_check_out", At: <Timestamp>, Minutes_Over: 0}]},
  {Values: [{Alert_Type: "missed_check_out", At: <Timestamp>, Minutes_Over: 0},
            {Alert_Type: "auto_check_out",   At: <Timestamp>, Minutes_Over: 0}]},
  …                                   ← one entry per revision; the LAST is current
]
```

(`null` entries front-pad revisions written before the field existed.)
`Sessions` uses the same `{Values: [...]}` wrapping. The server never writes
a plain list into an attendance document; a stored day without `timestamps`
is upgraded to this shape on its next server write. `Alert_Type` is one of
`break_exceeded · pause_exceeded · auto_check_out · late_arrival ·
missed_check_in · missed_check_out`.

Templates: `Demo/{cid}/Modules/notification/notification_templates/time_tracker_{key}`.
A stored template wins over the defaults. A stored text that equals an old
seeded default the 9 Oct decisions replaced (`break_completed`,
`automatic_check_out_applied`, `missed_check_out`) is replaced by the new
text. Renamed keys use the legacy template's on/off switch
(`pending_approvals_manager`, `break_policy_violation_manager_hr`) until
their own template exists. If no template exists, the push is on.

## Reads (bounded)

Per company and run: the licence, Settings/general,
Location_Assignments + Locations (+ the referenced Groups), or the three HR
collections. Then **only yesterday's and today's** Attendance documents of
**assigned** employees (one batched `getAll`), and the markers of due events.

Also once per company (cached 10 minutes): the company record for its
`Time_Zone` (`Demo/{cid}/Companys/{cid}`, then `Demo/{cid}/Companies/{cid}`,
stopping at the first valid zone).

Loaded lazily, only when a due event needs them: the employee's own Requests
(leave check), Employees_Info + Roles + Subscription_Admin + the role
switches (gates, manager, names, HR approvers; cached 10 minutes per warm
instance), and the templates.

`ttPendingApprovals` reads the company's whole Requests collection on each
transition. History documents cannot be filtered on their current
status or step. Once the target schema's scalar `Status` / `Current_Step` /
`Current_Approver_Email` exist, change `loadAllRequests` to `count()` queries.

**Firestore indexes:** none to create. Only single-field queries are used
(`Requester_Email` array-contains or `==`), which Firestore indexes
automatically.

## Deploy (Moataz / Amr only — nothing was deployed or installed)

1. Add the codebase to the app's `firebase.json` (the repo has none today):

   ```json
   {
     "functions": [
       { "source": "functions/time_tracker", "codebase": "time-tracker", "runtime": "nodejs20" }
     ]
   }
   ```

2. Create `functions/time_tracker/.env`:

   ```sh
   TT_REGION=us-central1             # MUST suit the Firestore database location (v2 Firestore triggers)
   TT_DEFAULT_TIME_ZONE=Asia/Riyadh  # last resort after the location and company record zones
   # TT_COMPANY_IDS=companyA,companyB  # optional staged roll-out
   # TT_LATE_ARRIVAL_ON_SERVER=true    # only if the app will not send late_arrival_recorded
   # TT_FCM_PUSH=false                 # in-app notifications only
   ```

3. Install and deploy:

   ```sh
   cd functions/time_tracker && npm install && cd ../..
   firebase use knowticed-v2-scheme   # the project the app's FCM sender targets; confirm
   firebase deploy --only functions:time-tracker
   # or by name: firebase deploy --only functions:ttScheduler,functions:ttPendingApprovals
   ```

   This needs the Blaze plan (Cloud Scheduler, Eventarc). The functions'
   service account needs Firestore read/write and FCM send; check its IAM
   roles before the first deploy.

4. **The same day, ship the app change that retires the client side.** Disable
   `TimeTrackerReminderSweeper.runFromUi` and the `_notifyWaiting` /
   `notifyPendingApprovals` calls in `RequestService`, `ApprovalService` and
   `TransactionService`. Otherwise approvers get two notices per request:
   the client's instant sends use no marker, and the client sweep's daily
   reminder uses the old key `pending_approvals_manager`, so neither is
   deduplicated against the server. Client missed check-in / check-out
   markers share ids with the server, so those two do not double.

5. Watch the logs: `firebase functions:log --only ttScheduler`. Every run
   logs a per-company report (`sent`, `already`, `stale`,
   `no_permission` …).

Note: no Time Tracker permission switches exist in Firebase yet
(target.json "Check"). A missing switch means denied, so the employee
reminders are claimed as `no_permission` until the Admin app writes
`Check_In_And_Out` and the related switches. Auto check-out, alerts and the
manager break notice do not depend on switches.

## Field names the server assumes (app side must match)

- `Sessions[].Breaks` `[{Break_Type, Start, End}]`, separate from `Pauses`.
- `Sessions[].Is_Auto_Check_Out` (and the check-out position fields) in the
  app's session model, so the app's next write keeps them.
- `Attendance.Alerts` in the house history shape above.
- Location defaults: `Allowed_Break_Minutes` (rename of `Break_Minutes`),
  `Allowed_Pause_Minutes`.
- Group / assignment `Custom_Rules` map, replacing the flat
  `Is_Custom_Rules` / `Is_Break_Allowed` / `Break_Minutes` /
  `Is_Pause_Allowed` fields.
- `Locations.Time_Zone` and the company record's `Time_Zone`.
- `Settings/general.Auto_Check_Out_After_Minutes`.
- The `Is_Reminder` flag on notification documents.
- New keys: `pending_approvals`, `break_policy_violation_manager`,
  `pause_duration_exceeded`, `shift_start_reminder`, `shift_end_reminder`.
- `late_arrival_recorded` + its `late_arrival` alert, sent by the app at
  check-in.

Readers accept the app's current names and the target names
(`Check_In_At`, `Work_Start_Minutes`, `Name_English`, `Status`,
`Allowed_Break_Minutes`, `Decided_At`, `Reminders[]`, `Requested_At`).
