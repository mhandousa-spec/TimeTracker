# Owner review — 10 Oct 2026

Status 13 Oct 2026: every item below is built and pushed (branch claude/knowticed-time-tracker-handover-53ergw) — ready for the owner's re-test.
 (iPad Air 11", dark, EN, demo data)

Figma (Time Tracker page): https://www.figma.com/design/QVFDXSnFPExQVOIycX9ECb/KNOWTICED-PLUS?node-id=6-39427 — node ids in code comments (e.g. `661:11059`) are in this file.

Status key: [ ] open · [x] fixed · [?] question

## Standing rules (from this review — apply everywhere)
- R1. No two charts/tiles share the same icon or the same title. Titles are full, professional names.
- R2. Equal paddings everywhere (avatar: left = top = bottom), consistent alignment, diagonal cut on cards, always core customs.
- R3. Success messages: no OK button — auto-close after 3 seconds.
- R4. Disabled primary buttons still react: tapping shows every missing field (red border + "Required" hint).
- R5. Icons/arrows come from Figma (export them), never ad-hoc Material icons.

## A. Overview — My Dashboard
- [x] A1. Overall card: less space between Present / Absence / Late; Vacations Credit on the SAME row (4 in one row).
- [x] A2. Work Locations chart: legend values all on one line/column; push the donut to the right; fix the icons.
- [x] A3. Rename charts professionally (e.g. "Work Location Distribution", "Requests by Status", "Late Arrivals History") + a distinct icon each (R1).

## B. Overview — HR
- [x] B1. Pending Approvals tile: remove the ">" arrow.
- [x] B2. Distinct icons for tiles/charts (R1).
- [x] B3. Needs Attention "+2 more" hint looks unprofessional — redesign (e.g. "View all (5)" control).

## C. Employee filter dialog
- [x] C1. Employee card: avatar padding equal on left/top/bottom, use the core custom card, diagonal cut (R2). — core person card, equal avatar padding. "Diagonal cut": need the Figma node to match.

## D. Export
- [x] D1. "Export Successful": remove OK, auto-close after 3 s (R3).

## E. Header
- [x] E1. Header hidden: Check In sits next to Expand/Hide above the title — align it with the "Tracking Time" title row.

## F. Attendance
- [x] F1. Summary tile icons are not the Figma icons — use Figma's.
- [x] F2. Table columns equally distributed, equal padding between columns.

## G. Create Transaction
- [x] G1. Submit disabled, but tapping it shows the required fields (R4).
- [x] G2. Upload Attachment button = same width as the fields.
- [x] G3. After upload: label left / file card right properly aligned; the remove (–) icon in the card's top-right corner; diagonal cut; file name + uploaded date aligned. — remove in the corner, name/size/date aligned. "Diagonal cut": need the Figma node.

## H. Requests
- [x] H1. Table: add "Approved By" column.
- [x] H2. Request cards: too much padding around Send Reminder — redesign, well distributed.
- [x] H3. (no-OK part DONE) After Send Reminder: no OK dialog (R3); show a countdown "You can remind again in 23 h 59 m". Rule changes from 2 days → 24 hours. — 24 h + countdown "You Can Remind Again In 23 h 59 m".

## I. Approvals / Request details
- [x] I1. Approve / Reject icons from Figma (export).
- [x] I2. Approve / Reject buttons in details: Figma width.
- [x] I3. Details info: left column 3 rows vs right 5 rows — distribute evenly.
- [x] I4. Approval-cycle arrow: Figma arrow.
- [x] I5. Inquiries & Comments: send icon = the SVG used in Qiyas; remove the "0 / 500" counter; reuse a core custom comments widget if one exists.
- [x] I6. Approve confirmation: the Lottie animation does not show (only a dot).

## J. Request Types
- [x] J1. Cards too plain / old-fashioned — modern design: icons, colour, status as a coloured chip.
- [x] J2. Details page: remove the loose "Removed" text; status inside a coloured container; richer layout with icons.

## K. Edit Request Type
- [x] K1. Dropdowns: core custom dropdown (colour is wrong now).
- [x] K2. Save disabled with no visible reason — apply R4.
- [x] K3. Arabic fields: label on the RIGHT, character counter on the LEFT (check the core custom field in RTL). Wording: "اسم الطلب" / "وصف الطلب".

## L. Locations
- [x] L1. Geofence picker: pick on map or search an address, and draw the radius circle live (e.g. 500 m). google_maps_flutter is already in the project.

## M. Questions
- [?] M1. Where is the phone view? → The app picks the layout from the screen width; the iPad always shows the iPad layout. Run on an iPhone simulator to see the phone layout.

---
# Round 2 — iPhone 18 Pro review (10 Oct, 14:27)

## More standing rules
- R6. All filter controls in one row look identical: same colour, height, radius (Employee / Department / Location / Year).
- R7. Toolbar buttons (search icon, filter, export, import, add) = same size and same icon stroke weight.
- R8. Phone: page title and the form's action buttons (Discard / Create / Submit) stay FIXED; only the content scrolls.
- R9. Links (Expand / Hide / View All): padding so the underline never touches the letters.
- R10. Demo data must look REAL — no "QA TEST" text in names or descriptions. Present-ready for government clients.
- R11. Every word in labels starts with a capital letter in EN ("Use The Location's Rules"). Arabic labels always sit on the RIGHT.
- R12. Cards are visual: icons + colour, never plain text lists.

## N. Overview (phone)
- [x] N1. Filters: different colours for Department / Year / Employee — make them identical (R6).
- [x] N2. "Approvals Pending More Than 2 Days" — the count badge (5) collides with "View All": fix spacing.
- [x] N3. Bar chart: the vertical axis numbers stay fixed while the bars scroll sideways.
- [x] N4. Header hidden: Check In aligned with the Expand link (same row), not floating above it.

## O. Attendance (phone)
- [x] O1. Day cards: add icons (check-in, check-out, break, total) — visual, not plain.
- [x] O2. Toolbar icons all the same size/weight (R7).

## P. Transaction / Request forms (phone)
- [x] P1. Upload button = full field width.
- [x] P2. New Request: after picking the request type, show only what that type needs (description required/optional, attachments required or hidden).

## Q. Request details (phone)
- [x] Q1. Own pending request shows Cancel AND Send Reminder side by side — confusing; Cancel looks disabled. Redesign the action row.
- [x] Q2. Approve / Reject: one row, two equal columns, full width, centred content.
- [x] Q3. Comments: send button = a SQUARE with the same height as the comment field; no 0/500 counter.
- [x] Q4. Comments: edit/delete by LONG-PRESS on the message (not visible buttons in the card).

## R. Request Types (phone + iPad)
- [x] R-1. Export the Figma icons for the card rows (current ones are bad).
- [x] R-2. Created date + Last update on one row, below the status.
- [x] R-3. Details page redesign (visual, icons, colour) — current one "kills me".
- [x] R-4. Filter by status: Active / Inactive / Removed. A removed type can be RESTORED.
- [x] R-5. Details show: created by/date, last update, removed date, removed by.

## S. Locations
- [x] S1. Toolbar too crowded on phone (search + filter + export + import + add in one row) — follow Figma.
- [x] S2. Location cards: follow the Figma card, add icons.
- [x] S3. Import: explain/show how import works; what is "Download template"? — make the import flow self-explanatory (steps + template explanation).
- [x] S4. Details page visual redesign (icons, sections).
- [x] S5. Geofence: Google place search field (shorter) + "Use my current location" ICON inside/next to it (not a whole row) + map circle preview of the radius.

## T. Employees
- [x] T1. Assigned / Unassigned / Groups / Locations = ONE segmented filter in the same row, using the core custom.
- [x] T2. Department filter goes INSIDE the filter sheet together with Location.
- [x] T3. "Custom" = a corner ribbon label (sharta) on the card's left corner, not a button-like chip.
- [x] T4. Message icon: better placement; cards need visuals/icons.
- [x] T5. Employee can have MULTIPLE locations (multi-select) — check in/out at any of them.
- [x] T6. Conflict: "Allow Different Work Locations" ON but the single location field still shows — redesign (multi-location list).
- [x] T7. Reassign dialog UI bad; employee card too big.
- [x] T8. Tap an employee → details page: who assigned him and when, location history (transfers), his dashboard, break-rule warnings, locations.
- [x] T9. Location filter must be the same filter style as elsewhere (boxes with counters + location names).
- [x] T10. BUG: Groups filter — can't deselect the sort.

## U. Create Group
- [x] U1. Arabic labels on the RIGHT (R11).
- [x] U2. Selected members: chips row under the search (avatar + X) showing who is selected and how many.
- [x] U3. Title + Discard/Create fixed on phone (R8).
- [x] U4. Location rules preview goes directly BELOW the location field (not below the start date).
- [x] U5. "Use The Location's Rules" capitalised (R11).
- [x] U6. "Allow Different Work Locations" ON → the dropdown field colour is wrong / broken.

## V. Vacation Balances
- [x] V1. Tap an employee → history: when vacation was used, cancelled ones, details, remaining.
- [x] V2. BUG: overflow when opening Edit.
