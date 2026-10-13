# Time Tracker — owner decisions (Moataz, 8 Oct 2026)

1. Location permissions exist (the duplicate "Request Typ Permissions" = Locations). Owner wants FULL control: every action in the module is its own switch — create / edit / delete / status (active-inactive) / export / import / data scope (e.g. dashboard only for own department vs all departments, with or without the department filter).
2. "Admin Access" switch — REMOVED.
3. "Approve Only" — REMOVED. One switch "Approve And Reject". Approval cycle = requester's DEPARTMENT MANAGER first, then HR.
4. Shifts — reuse the HR module's Shift Management (lib/features/hr_module/h9_shift_management; Firestore Demo/{cid}/Modules/hr/Shifts + Shift_Assignments).
5. Check-in / pause — suggestions accepted (several check-ins a day; wrong location blocks unless Remote; geofence = circle radius; Pause = Break, not counted in total hours).
6. Vacation balance — add it, AND it must exist in the HR module too.
7. KEY ARCHITECTURE RULE: a company may buy Time Tracker WITHOUT HR. Then Time Tracker must let them set up locations, shifts, vacation balances itself. If the company has HR, that setup is done from HR. → setup data must be shared by both modules (one source of truth).
8. HR cannot edit attendance directly — only by approving an employee's transaction request. (yes)
9. Firebase layout — SUPERSEDED by item 16 below.
10. Fix every Figma copy mistake ("make it perfect").

Facts found in code (8/10):
- HR Shifts: `Demo/{cid}/Modules/hr/Shifts/{id}` (Location_Ids, Branch_Ids, Start_Minutes, End_Minutes, `Timestamps` capital T, Editor) and `Modules/hr/Shift_Assignments` (Employee_Id, Shift_Id).
- HR Locations/Branches are still HARD-CODED local data (Egypt / KSA / UAE …) — no Firestore yet (`Locations` collection name exists, unused).
- No vacation balance anywhere in the code.
- `core/helper/hr/hr_api_constants.dart` holds the HR paths (core contains HR code — see coupling report).

## Round 2 (8 Oct 2026, 21:00)
11. Vacation balance lives ALWAYS inside Time Tracker.
12. Locations: company HAS HR → HR owns them (Time Tracker reads, Locations tab hidden). NO HR → Time Tracker Locations tab.
13. Shifts: with HR → HR Shift Management. Without HR → NO shifts section; the "shift" is part of the Location (Work Start Time, Work End Time, Working Days, Allow Pause, Allow Breaks + length) and applies to everyone at that location. Owner approved ADDING Work Start/End Time + Working Days to the location form.
14. Employee → location assignment: HAS HR → HR assigns; NO HR → Time Tracker Employees tab.
15. Switch list: 10 sections / 48 switches (recounted) (Shifts section dropped; Admin Access + Approve Only removed; scope switches "All Departments" for Dashboard, Approvals, Employees).
16. Firebase: Modules → time_tracker → one collection per feature:
    Attendance/{email}_{yyyy-MM-dd} · Requests/{id} (transactions too; approval steps stored inside) · Request_Types · Locations (no-HR) · Location_Assignments/{email} (no-HR) · Groups · Vacation_Balances/{email} · Notification_Log.
    With HR: read Modules/hr/Shifts, Shift_Assignments, Locations.

## Round 3 (8 Oct 2026, 22:39) — owner "OK all"
17. Admin licence key: Amr renames `tracking` → `time_tracker` in Admin + adds the 48-switch catalogue (goes in Amr handover).
18. Department manager for approval step 1 = the employee's DIRECT MANAGER from the Org Chart.
19. Attendance corrections (Transactions) use the same cycle as requests: manager → HR.
20. Absent days: filled automatically by the app when anyone opens Time Tracker (client sweep, no server).
21. Vacation balance resets on 1 January to the yearly amount; HR can edit anytime.
22. Add "Late After (minutes)" (grace period, default 0) to the location settings.
23. Requests/approvals keep Created_By / Modified_By (owner informed, accepted).

## Round 4 (9 Oct 2026, 01:26)
24. Nobody approves their own request. Every HR person has a manager: an HR approver's OWN request (or transaction) goes to their direct manager ONLY, and the manager's approval is final. (If no manager is known, another HR approver decides.)
25. Location Country / State / City = translated DROPDOWNS (core LocationDataService), stored as codes; no Arabic address fields.

## Round 5 (9 Oct 2026, 09:40) — from the code review; OWNER CONFIRMED ("go ahead with all of them", 09:39)
26. HR approval step = Approve_And_Reject + Approvals_All_Departments only (FINAL SPEC); one person never decides both steps of one request.
27. HR-licensed companies: until HR stores working days, weekend-sensitive automation (absent sweep, missed-check-in reminder) is skipped for HR-owned schedules.
28. A missing vacation balance = 0 days remaining for deducting request types.
29. Transactions: check-out same day (or next day for overnight), max 24 h.
30. A location with assigned employees cannot be deleted/deactivated until they are reassigned.
31. Employees only download their own requests; company-wide request reads only for approvers / HR dashboard holders.

## Round 6 (9 Oct 2026, 11:22) — owner
32. Group name + description are bilingual (EN + AR fields).
33. Location = source of the attendance rules (hours, days, Late After, breaks + length, pause). Group / employee forms show a PREVIEW of the selected location's rules with a switch "Use the location's rules" (ON by default → follows the location, updates when the location changes). OFF = custom rules for THIS group only (and its members only) — editable, start from the location's values, labelled "Custom — overrides the location". Same pattern on the single-employee Assign/Reassign dialog (custom for that employee only). Precedence: employee custom → group custom → location. Every employee card shows the effective rules with "From location" / "Custom". "Allow Different Work Location" stays a group/employee setting.

## Round 7 (9 Oct 2026, 12:02) — notifications (owner, via schema session; spec Module Schemas/Time Tracker/NOTIFICATIONS_VERIFIED.md)
34. 19 events: keep 9 sent (rename pending_approvals_manager → pending_approvals, one event, Is_Reminder flag "Reminder" badge, count = approver's real pending total at send time); build break_completed, break_duration_exceeded, break_policy_violation_manager (manager only, every time), late_arrival_recorded, shift_updated, work_location_updated (merged, Updated_By), automatic_check_out_applied, + NEW pause_duration_exceeded, shift_start_reminder (15 min before), shift_end_reminder (at shift end). Removed: work_location_updated_management, check_out_outside_geofence (on-screen validation).
35. HR is notified ONLY for pending_approvals at the HR step / cancellation review; routine events → HR dashboard.
36. Break keeps running past its limit (notification + alert). Pause is SEPARATE from Break, has a company time limit Settings/general.Allowed_Pause_Minutes, allowed per employee (assignment/group Is_Pause_Allowed; location default per round 6), not a role permission.
37. Automatic check-out after Settings/general.Auto_Check_Out_After_Minutes (default 120): check-out = shift end, Sessions[].Is_Auto_Check_Out = true, employee notified + alert.
38. Attendance.Alerts[] {Alert_Type, At, Minutes_Over} for break_exceeded, pause_exceeded, auto_check_out, late_arrival, missed_check_in, missed_check_out.
39. Check-out must be inside the geofence (Check_Out_Latitude/Longitude + Check_Out_Location_Matched; blocked otherwise).
40. 10 events server-side (scheduled Cloud Function + Firestore trigger for pending_approvals) — written in functions/time_tracker/, NOT deployed (Moataz/Amr deploy). Client sweep retired after deploy.

## Round 8 (9 Oct 2026, 15:29) — owner
41. Debug-only "Switch to test employee" (option B): compiled out of release/profile, only emails on a test domain (`.test`), runs the normal post-login path without the password check — so QA can test the approval cycle with the test accounts. Goes into Amr's handover.

## Round 9 (9 Oct 2026) — data model (owner, via the schema-mapping session; built 9 Oct — STATUS "Data model 9 Oct")
42. Vacation_Balances = ONE document per employee per year, id `{lower-case email}_{year}` (Employee_Email, Balance_Year, Total_Days, Used_Days + Vacation_Balance_Id). Remaining_Days is never stored (Total − Used). Decision 21's 1 January roll-over is SUPERSEDED: a new year = a new document; no document = no balance (decision 28).
43. ~~A request deducts from / refunds to the balance of the year of its START date. Dev choice (to confirm): a request that uses the balance may NOT span two years (blocked in the form, at submit and at the final approval; one request per year).~~ **SUPERSEDED by owner choice (b), see 49** (built 9 Oct: STATUS "Data model 9 Oct").
44. Request comments move to `Requests/{id}/Comments/{commentId}` (one history document per comment; edit = revision; delete = soft `Is_Deleted`); the request no longer stores `Comments`. Permissions unchanged.
45. Notification_Log unchanged (dedupe markers `{subject}__{event}__{ms}`).
46. Migration script (dry run by default, JSON backup + rollback): `migrations/migrate_tt_data_model_2026_10_09.py` — not run yet.

## Round 10 (9 Oct 2026, 15:55) — owner STANDING RULE (all schemas/modules)
47. No self-id fields in any document (ALL Time Tracker + To-Do docs).
48. Readable professional IDs: REQ-2026-0001 (requests), TRX-2026-0001 (transactions), LOC-0001, GRP-0001, RQT-0001, CMT-0001 (per request), TODO-0001 (per employee folder); natural keys kept: attendance {email}_{date}, balances {email}_{year}, assignments {email}. Per-company counters in a transaction; reference shown in the UI. Existing data renamed only via a dry-run migration. (Playbook §3b updated.)
49. Cross-year leave (round 9 b): split per year on final approval, Deducted_Vacation_Days = per-year map, refunds per year; insufficient year → blocked with that year's remaining days. (Supersedes the earlier block.)

## Built 13 Oct 2026 — readable IDs (decision 48)
50. New records get readable ids inside the same Firestore transaction as the write: REQ-{year}-0001, TRX-{year}-0001 (year of creation), LOC-0001, GRP-0001, RQT-0001, CMT-0001 (numbered per request). Counter documents: `Modules/time_tracker/Counters/{series}` with `Last_Number` (series = `REQ-2026`, `TRX-2026`, `LOC`, `GRP`, `RQT`, `CMT__{requestId}`). An id that already exists is skipped. Existing records keep their old ids (no migration). **Amr:** the security rules must allow company users to read/write `Counters` like the other Time Tracker collections.

## Round 11 (13 Oct 2026) — owner standing rules from the iPad test
51. Data is never cut with "…": table headers and cells wrap. Every table has ONE fixed gap between columns (`ttTableColumnGap`).
52. Dialogs have one size per kind: filters / forms / edits / imports = `TtDialogWidth.standard` (600); short choices = `TtDialogWidth.compact` (450); messages, success, confirm and export keep the core sizes.
53. A transaction (attendance correction) REQUIRES a description and a transaction document — the manager decides from them (validation + Submit disabled until both exist).
54. Export names are professional: `{Report}_{Employee (personal reports)}_{yyyy-MM-dd}`, e.g. `Attendance_Report_Moataz_Handousa_2026-10-13`. Import templates keep their plain name.
55. No divider lines inside cards (e.g. above Send Reminder).
56. Request counters follow the life of a request: All · Pending · Under Review · Approved · Rejected · Canceled (Approvals: All · Pending · Approved · Rejected · Canceled).
57. Dashboard "Custom" range = one date-range picker (no Start / End form). Two-option toggles slide (animation) with a LOW haptic; the yellow pill of "My Dashboard | HR" has radius 2.
58. HR dashboard: Department, Location and "Monthly Requests By Type" are multi-select; a request-type list shows each NAME once (types sharing a name are one choice). Collapsed header on tablet: Check In sits on the Expand row.
59. Title is "Time Tracker" (EN).
60. Approve asks for a REQUIRED justification (kept on the approval step and shown on Request Details), like Reject asks for a reason.
61. Approvals Filter: no Employee list (the search finds employees by name, type or department); Request Type, Status and Department are multi-select. Request Types tab: status counters All · Active · Inactive · Removed.
62. "Requested Timeframe" is labelled "Period". Under Review = an approved request whose requester asked to cancel — Request Details says so.
