# Owner review — 10 Oct 2026 (iPad Air 11", dark, EN, demo data)

Figma (Time Tracker page): https://www.figma.com/design/QVFDXSnFPExQVOIycX9ECb/KNOWTICED-PLUS?node-id=6-39427 — node ids in code comments (e.g. `661:11059`) are in this file.

Status key: [ ] open · [x] fixed · [?] question

## Standing rules (from this review — apply everywhere)
- R1. No two charts/tiles share the same icon or the same title. Titles are full, professional names.
- R2. Equal paddings everywhere (avatar: left = top = bottom), consistent alignment, diagonal cut on cards, always core customs.
- R3. Success messages: no OK button — auto-close after 3 seconds.
- R4. Disabled primary buttons still react: tapping shows every missing field (red border + "Required" hint).
- R5. Icons/arrows come from Figma (export them), never ad-hoc Material icons.

## A. Overview — My Dashboard
- [ ] A1. Overall card: less space between Present / Absence / Late; Vacations Credit on the SAME row (4 in one row).
- [ ] A2. Work Locations chart: legend values all on one line/column; push the donut to the right; fix the icons.
- [ ] A3. Rename charts professionally (e.g. "Work Location Distribution", "Requests by Status", "Late Arrivals History") + a distinct icon each (R1).

## B. Overview — HR
- [x] B1. Pending Approvals tile: remove the ">" arrow.
- [ ] B2. Distinct icons for tiles/charts (R1).
- [ ] B3. Needs Attention "+2 more" hint looks unprofessional — redesign (e.g. "View all (5)" control).

## C. Employee filter dialog
- [ ] C1. Employee card: avatar padding equal on left/top/bottom, use the core custom card, diagonal cut (R2).

## D. Export
- [x] D1. "Export Successful": remove OK, auto-close after 3 s (R3).

## E. Header
- [ ] E1. Header hidden: Check In sits next to Expand/Hide above the title — align it with the "Tracking Time" title row.

## F. Attendance
- [ ] F1. Summary tile icons are not the Figma icons — use Figma's.
- [ ] F2. Table columns equally distributed, equal padding between columns.

## G. Create Transaction
- [ ] G1. Submit disabled, but tapping it shows the required fields (R4).
- [ ] G2. Upload Attachment button = same width as the fields.
- [ ] G3. After upload: label left / file card right properly aligned; the remove (–) icon in the card's top-right corner; diagonal cut; file name + uploaded date aligned.

## H. Requests
- [ ] H1. Table: add "Approved By" column.
- [ ] H2. Request cards: too much padding around Send Reminder — redesign, well distributed.
- [~] H3. (no-OK part DONE) After Send Reminder: no OK dialog (R3); show a countdown "You can remind again in 23 h 59 m". Rule changes from 2 days → 24 hours.

## I. Approvals / Request details
- [ ] I1. Approve / Reject icons from Figma (export).
- [ ] I2. Approve / Reject buttons in details: Figma width.
- [ ] I3. Details info: left column 3 rows vs right 5 rows — distribute evenly.
- [ ] I4. Approval-cycle arrow: Figma arrow.
- [ ] I5. Inquiries & Comments: send icon = the SVG used in Qiyas; remove the "0 / 500" counter; reuse a core custom comments widget if one exists.
- [ ] I6. Approve confirmation: the Lottie animation does not show (only a dot).

## J. Request Types
- [ ] J1. Cards too plain / old-fashioned — modern design: icons, colour, status as a coloured chip.
- [ ] J2. Details page: remove the loose "Removed" text; status inside a coloured container; richer layout with icons.

## K. Edit Request Type
- [ ] K1. Dropdowns: core custom dropdown (colour is wrong now).
- [ ] K2. Save disabled with no visible reason — apply R4.
- [ ] K3. Arabic fields: label on the RIGHT, character counter on the LEFT (check the core custom field in RTL). Wording: "اسم الطلب" / "وصف الطلب".

## L. Locations
- [ ] L1. Geofence picker: pick on map or search an address, and draw the radius circle live (e.g. 500 m). google_maps_flutter is already in the project.

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
- [ ] N1. Filters: different colours for Department / Year / Employee — make them identical (R6).
- [ ] N2. "Approvals Pending More Than 2 Days" — the count badge (5) collides with "View All": fix spacing.
- [ ] N3. Bar chart: the vertical axis numbers stay fixed while the bars scroll sideways.
- [ ] N4. Header hidden: Check In aligned with the Expand link (same row), not floating above it.

## O. Attendance (phone)
- [ ] O1. Day cards: add icons (check-in, check-out, break, total) — visual, not plain.
- [ ] O2. Toolbar icons all the same size/weight (R7).

## P. Transaction / Request forms (phone)
- [ ] P1. Upload button = full field width.
- [ ] P2. New Request: after picking the request type, show only what that type needs (description required/optional, attachments required or hidden).

## Q. Request details (phone)
- [ ] Q1. Own pending request shows Cancel AND Send Reminder side by side — confusing; Cancel looks disabled. Redesign the action row.
- [ ] Q2. Approve / Reject: one row, two equal columns, full width, centred content.
- [ ] Q3. Comments: send button = a SQUARE with the same height as the comment field; no 0/500 counter.
- [ ] Q4. Comments: edit/delete by LONG-PRESS on the message (not visible buttons in the card).

## R. Request Types (phone + iPad)
- [ ] R-1. Export the Figma icons for the card rows (current ones are bad).
- [ ] R-2. Created date + Last update on one row, below the status.
- [ ] R-3. Details page redesign (visual, icons, colour) — current one "kills me".
- [ ] R-4. Filter by status: Active / Inactive / Removed. A removed type can be RESTORED.
- [ ] R-5. Details show: created by/date, last update, removed date, removed by.

## S. Locations
- [ ] S1. Toolbar too crowded on phone (search + filter + export + import + add in one row) — follow Figma.
- [ ] S2. Location cards: follow the Figma card, add icons.
- [ ] S3. Import: explain/show how import works; what is "Download template"? — make the import flow self-explanatory (steps + template explanation).
- [ ] S4. Details page visual redesign (icons, sections).
- [ ] S5. Geofence: Google place search field (shorter) + "Use my current location" ICON inside/next to it (not a whole row) + map circle preview of the radius.

## T. Employees
- [ ] T1. Assigned / Unassigned / Groups / Locations = ONE segmented filter in the same row, using the core custom.
- [ ] T2. Department filter goes INSIDE the filter sheet together with Location.
- [ ] T3. "Custom" = a corner ribbon label (sharta) on the card's left corner, not a button-like chip.
- [ ] T4. Message icon: better placement; cards need visuals/icons.
- [ ] T5. Employee can have MULTIPLE locations (multi-select) — check in/out at any of them.
- [ ] T6. Conflict: "Allow Different Work Locations" ON but the single location field still shows — redesign (multi-location list).
- [ ] T7. Reassign dialog UI bad; employee card too big.
- [ ] T8. Tap an employee → details page: who assigned him and when, location history (transfers), his dashboard, break-rule warnings, locations.
- [ ] T9. Location filter must be the same filter style as elsewhere (boxes with counters + location names).
- [ ] T10. BUG: Groups filter — can't deselect the sort.

## U. Create Group
- [ ] U1. Arabic labels on the RIGHT (R11).
- [ ] U2. Selected members: chips row under the search (avatar + X) showing who is selected and how many.
- [ ] U3. Title + Discard/Create fixed on phone (R8).
- [ ] U4. Location rules preview goes directly BELOW the location field (not below the start date).
- [ ] U5. "Use The Location's Rules" capitalised (R11).
- [ ] U6. "Allow Different Work Locations" ON → the dropdown field colour is wrong / broken.

## V. Vacation Balances
- [ ] V1. Tap an employee → history: when vacation was used, cancelled ones, details, remaining.
- [ ] V2. BUG: overflow when opening Edit.
