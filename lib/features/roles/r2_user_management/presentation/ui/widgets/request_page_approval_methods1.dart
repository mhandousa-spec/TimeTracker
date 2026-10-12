/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_page_approval_methods1.dart
/// Purpose: Declares `RequestPageApprovalMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/request_page_approval.dart';

extension RequestPageApprovalMethods1 on _RequestPageApprovalState {
  // REMOVED 24/8/2026: `_updateRequestStatus` — dead code, and the kind that
  // would have been a bug the moment anyone wired it up.
  //
  // It had zero callers: the cards on this page open
  // `UserManagementDetailsRequestSettings`, which is where a decision is
  // actually taken. What it did was write `status` straight onto the request
  // document — no employee-profile write, no notification — so an inline
  // approve here would have marked a request approved while leaving the
  // profile untouched and the employee uninformed.
  //
  // A decision belongs to `RequestsCubit.approve` / `.setStatus`, which is the
  // one choke point that applies the change AND notifies. If this page ever
  // grows inline approve/reject buttons, they go through the cubit, and the
  // reject path collects a reason the same way `umdr_methods1
  // ._showConfirmDialog` does.
  // REMOVED 12/8/2026: `_showConfirmDialog` — dead code. The approve/reject
  // buttons on this page call `_handleAction` directly; the only live callers
  // of a method by this name belong to the user-management-details library,
  // which declares its own.
  /// Firestore holds both spellings of cancelled depending on which screen
  /// wrote the record, so every comparison funnels through here first.
  String _normalizeStatus(dynamic raw) {
    final value = (raw ?? '').toString().toLowerCase().trim();
    return value == 'canceled' ? kCancelled : value;
  }

  int _countOf(String status) =>
      allRequests.where((r) => _normalizeStatus(r['status']) == status).length;

  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(allRequests);

    // selectStatus holds a canonical key, not a display label. Comparing
    // against localized labels meant the Pending / Rejected chips matched
    // nothing under an Arabic locale.
    if (selectStatus != kAll) {
      filtered = filtered
          .where((request) => _normalizeStatus(request['status']) == selectStatus)
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((request) {
        final title = request['title'].toString().toLowerCase();
        final name = (request['employeeName'] ?? '').toString().toLowerCase();
        return title.contains(searchText) || name.contains(searchText);
      }).toList();
    }

    // Sort by submission date. dateRequested is millisecondsSinceEpoch, so a
    // plain numeric compare is enough.
    filtered.sort((a, b) {
      final int aDate = (a['dateRequested'] ?? 0) as int;
      final int bDate = (b['dateRequested'] ?? 0) as int;
      return sortMostRecentFirst ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });

    setState(() {
      filteredRequests = filtered;
    });
  }

  /// Sort menu: newest first vs oldest first.
  ///
  /// CHANGED 13/8/2026: was `showModalBottomSheet`, which slid a full-width
  /// sheet up from the bottom of the window — fine on a phone, out of place on
  /// desktop where the trigger is a small toolbar button. It now opens as a
  /// dropdown anchored directly beneath that button and constrained to exactly
  /// its width, matching the sort control on the User Access screen.
  ///
  /// The position is measured from `_sortButtonKey`'s RenderBox relative to the
  /// overlay, so it follows the button in both LTR and RTL without any
  /// hardcoded offsets.
  Future<void> _showSortMenu() async {
    final BuildContext? buttonContext = _sortButtonKey.currentContext;
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Size buttonSize = button.size;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    // 4px of breathing room so the menu reads as attached to the button
    // without touching it.
    const double gap = 4.0;

    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + buttonSize.height + gap,
      overlay.size.width - (topLeft.dx + buttonSize.width),
      0,
    );

    final bool? selected = await showMenu<bool>(
      context: context,
      position: position,
      color: AppColors.card,
      // Min-width, not tightFor: the menu is at least as wide as the button but
      // grows to fit the full option labels — "Most Recent" / "Earliest
      // Submitted" must show in full, never ellipsised.
      constraints: BoxConstraints(minWidth: buttonSize.width),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      // EDIT 29/8/2026: the selected row is painted edge to edge (see
      // `_sortMenuItem`), so the menu itself has to do the rounding — without
      // this the fill on the first/last row squares off the menu's corners.
      clipBehavior: Clip.antiAlias,
      // ...and the menu's default 8 vertical list padding has to go too, or the
      // fill stops short of the menu's top and bottom edges — which is exactly
      // the gap that made the selection read as unfilled.
      menuPadding: EdgeInsets.zero,
      items: <PopupMenuEntry<bool>>[
        _sortMenuItem(label: S.of(context).mostRecent, value: true),
        _sortMenuItem(label: S.of(context).earliestSubmitted, value: false),
      ],
    );

    // Selecting ANY item marks the sort as chosen, so the button takes its
    // active look — even when the picked option is already the current one.
    if (selected != null) {
      // Role QA p.12: tapping the option that is already active clears the
      // sort (back to the default order, newest first) — the same rule as the
      // User Access sort.
      final bool clearing = sortSelected && sortMostRecentFirst == selected;
      setState(() {
        sortSelected = !clearing;
        sortMostRecentFirst = clearing ? true : selected;
      });
      _filterRequests();
    }
  }

  /// One row of the sort dropdown.
  ///
  /// The row sizes to its content (no `Expanded`, no ellipsis) so the full
  /// option label always shows; the menu grows to fit the widest row.
  ///
  /// EDIT 29/8/2026: the selected option was marked by a tick glyph sitting
  /// after the label, which pushed that row wider than its neighbour and left
  /// the two visibly misaligned. Selection is now carried by the row itself —
  /// a primary fill with on-primary text, the same pairing the sort BUTTON
  /// already uses when a sort is active — so the tick is gone and both rows
  /// are the same width.
  ///
  /// Mechanics worth keeping:
  /// - `padding: EdgeInsets.zero` on the item, with the inset moved inside the
  ///   `Container`, so the fill covers the whole row instead of stopping at the
  ///   item's own padding.
  /// - `MainAxisSize.max` on the `Row` is what stretches the fill across the
  ///   menu. The menu sizes itself from its children's INTRINSIC width, so the
  ///   row must not be given an explicit `double.infinity` width — that makes
  ///   the intrinsic measurement unbounded and throws at layout.
  /// - The fill is edge to edge: no margin, no radius, and `height` on the
  ///   `Container` matching the item's own so it covers the full row box. The
  ///   rounding is done by the menu instead, via `clipBehavior` on `showMenu`.
  ///   An inset fill was tried first and read as a floating chip rather than a
  ///   selected row.
  PopupMenuItem<bool> _sortMenuItem({
    required String label,
    required bool value,
  }) {
    // Only highlighted while a sort is actually applied (see _showSortMenu).
    final bool isSelected = sortSelected && sortMostRecentFirst == value;

    return PopupMenuItem<bool>(
      value: value,
      height: 40.h,
      padding: EdgeInsets.zero,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: AlignmentDirectional.centerStart,
        color: isSelected ? AppColors.primary : AppColors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: StyleText.fontSize14Weight500.copyWith(
                color: isSelected ? AppColors.textButton : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }
  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case kApproved:
        return AppColors.green;
      case kPending:
        // EDIT 29/8/2026: statusPending (0xFFFF814A), not AppColors.yellow —
        // matches `se6_requests/request_page.dart`, which is the same request
        // in the employee's own view. Pending is the orange in the status
        // palette; the yellow reads as the brand primary, which this screen
        // already spends on the selected status chip and the active Sort
        // button, so a pending row looked like another selected control.
        return AppColors.statusPending;
      case kRejected:
        return AppColors.red;
      case kCancelled:
        return AppColors.red;
      default:
        return AppColors.secondaryText;
    }
  }
  String _getStatusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case kApproved:
        return S.of(context).Approved;
      case kPending:
        return S.of(context).pending;
      case kRejected:
        return S.of(context).rejected;
      case kCancelled:
        return S.of(context).canceled;
      default:
        return status;
    }
  }
  // ─── Reusable info row ───────────────────────────────────────────────────────
  Widget _infoRow({
    required String icon,
    required String label,
    required String value,
    required bool lightMode,
    bool ellipsis = false,
  }) {
    return Row(
      children: [
        CustomSvgImage(
          assetPath: icon,
          width: 14.w,
          height: 14.h,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: StyleText.fontSize12Weight400.copyWith(
              color:
              AppColors.text),
        ),
        ellipsis
            ? Expanded(
          child: Text(
            value,
            style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        )
            : Text(
          value,
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text),
        ),
      ],
    );
  }
  Widget filterSection() {
    final s = S.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statusChip("$totalRequests", s.all,
              isSelected: selectStatus == kAll,
              onTap: () {
                setState(() {
                  selectStatus = kAll;
                  _filterRequests();
                });
              },
              labelColor: AppColors.text),
          _statusChip("$approvedCount", s.Approved,
              isSelected: selectStatus == kApproved,
              onTap: () {
                setState(() {
                  selectStatus = kApproved;
                  _filterRequests();
                });
              },
              labelColor: AppColors.green),
          _statusChip("$pendingCount", s.pending,
              isSelected: selectStatus == kPending,
              onTap: () {
                setState(() {
                  selectStatus = kPending;
                  _filterRequests();
                });
              },
              // EDIT 29/8/2026: statusPending, not AppColors.primary. This is
              // the chip the pending colour is actually read from — the card's
              // status text goes through `_getStatusColor`, which was fixed
              // separately, but the tab kept the brand yellow. `primary` is
              // also what `_statusChip` fills the SELECTED chip with, so the
              // pending tab looked selected whichever tab was really active.
              // Matches `se6_requests/request_page.dart`.
              labelColor: AppColors.statusPending),
          _statusChip("$rejectedCount", s.rejected,
              isSelected: selectStatus == kRejected,
              onTap: () {
                setState(() {
                  selectStatus = kRejected;
                  _filterRequests();
                });
              },
              labelColor: AppColors.red),
          _statusChip("$cancelledCount", s.canceled,
              isSelected: selectStatus == kCancelled,
              onTap: () {
                setState(() {
                  selectStatus = kCancelled;
                  _filterRequests();
                });
              },
              labelColor: AppColors.red),
        ],
      ),
    );
  }
  Widget _statusChip(String count, String label,
      {required bool isSelected,
        required Color labelColor,
        required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? isSelected
                  ? AppColors.primary
                  : AppColors.white
                  : isSelected
                  ? AppColors.primary
                  : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.text,
                )
                    : StyleText.fontSize20Weight500.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.text,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          SizedBox(
            child: Text(
              label,
              style: isMobile
                  ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                  : StyleText.fontSize16Weight600.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}
