/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_slot_row.dart
/// Purpose: Declares `HomeSlotRow` — one row of the Home Layout grid, laid out
///          in fixed slots where a card may span more than one slot.
/// Author: Knowticed Plus team
/// Created: 31/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// A row is always `HomeConstants.NUMBER_OF_COLUMNS` slots wide — the count is
/// a property of the grid, never of the cards in it. But the cards are not all
/// one slot wide: a card that needs roughly two slots must CONSUME two, and the
/// slots it does not reach must still show as empty "+" placeholders.
///
/// A plain `Row` cannot express that. Its two options are both wrong here:
///   • `Expanded` children — every card squeezed to exactly one slot, so a wide
///     card is crushed rather than given the room it needs;
///   • natural-width children — nothing stops four wide cards from totalling
///     more than the row, which is the "RIGHT OVERFLOWED BY 61 PIXELS" stripe.
///
/// So the row measures. Each card is laid out loose to learn the width it
/// actually wants, that width is converted into a whole number of slots, and
/// the next card starts after them. Once the slots are gone, the remaining
/// children are collapsed to nothing — the row can never overflow, and it never
/// needs a sideways scroll to reach a card.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeSlotRow extends StatelessWidget {
  const HomeSlotRow({
    super.key,
    required this.slotCount,
    required this.gap,
    required this.rowHeight,
    required this.children,
    required this.isPlaceholder,
  }) : assert(children.length == isPlaceholder.length);

  /// Slots in this row. Fixed by the grid (4), never derived from card widths.
  final int slotCount;

  /// Gap BETWEEN two slots. Not applied at the row's outer ends.
  final double gap;

  /// Height of the row. Every card is the same height by design, so this is a
  /// constant rather than something measured.
  final double rowHeight;

  /// One child per column, in column order.
  final List<Widget> children;

  /// Whether the child at the same index is an empty-slot placeholder.
  ///
  /// A placeholder is always exactly one slot and is stretched to fill it — it
  /// has no content to measure, so it cannot ask for a width. A card is
  /// measured and may span several.
  final List<bool> isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: CustomMultiChildLayout(
        delegate: _HomeSlotRowDelegate(
          slotCount: slotCount,
          gap: gap,
          isPlaceholder: isPlaceholder,
          isRtl: Directionality.of(context) == TextDirection.rtl,
        ),
        children: [
          for (int i = 0; i < children.length; i++)
            LayoutId(id: i, child: children[i]),
        ],
      ),
    );
  }
}

class _HomeSlotRowDelegate extends MultiChildLayoutDelegate {
  _HomeSlotRowDelegate({
    required this.slotCount,
    required this.gap,
    required this.isPlaceholder,
    required this.isRtl,
  });

  final int slotCount;
  final double gap;
  final List<bool> isPlaceholder;
  final bool isRtl;

  @override
  void performLayout(Size size) {
    // One slot's share of the row, with the gaps taken out first so that
    // slotCount slots plus (slotCount - 1) gaps come to exactly the row width.
    final double unit =
        (size.width - gap * (slotCount - 1)) / slotCount;

    // Degenerate width (a zero-width parent during a transition, or a slot
    // count that leaves nothing over). Collapse everything rather than divide
    // into a negative slot.
    if (unit <= 0) {
      for (int i = 0; i < isPlaceholder.length; i++) {
        if (hasChild(i)) {
          layoutChild(i, BoxConstraints.tight(Size.zero));
          positionChild(i, Offset.zero);
        }
      }
      return;
    }

    double cursor = 0;
    int usedSlots = 0;

    for (int i = 0; i < isPlaceholder.length; i++) {
      if (!hasChild(i)) continue;

      final int remainingSlots = slotCount - usedSlots;

      // The row is full. Every remaining child is laid out at zero size and
      // parked outside the row, so it takes no space and paints nothing.
      //
      // They are still laid out: MultiChildLayoutDelegate requires every child
      // it was given to be laid out and positioned exactly once.
      if (remainingSlots <= 0) {
        layoutChild(i, BoxConstraints.tight(Size.zero));
        positionChild(i, Offset(size.width, 0));
        continue;
      }

      final int span;
      final double occupiedWidth;

      if (isPlaceholder[i]) {
        // An empty slot has nothing to measure — it is given exactly one slot
        // and stretched to fill it.
        span = 1;
        occupiedWidth = unit;
        layoutChild(i, BoxConstraints.tight(Size(unit, size.height)));
      } else {
        // Measure the card at the width it WANTS. Loose constraints, so it
        // reports its natural width rather than being told one.
        //
        // Note this is the child's only layout pass — a delegate may not lay a
        // child out twice — so the card keeps its natural width and is not
        // stretched to fill the slots it reserves. That is deliberate: a card
        // takes the width it needs, and the span only decides how much of the
        // row is spoken for and where the next card begins.
        final Size measured =
            layoutChild(i, BoxConstraints.loose(Size(size.width, size.height)));

        // A card 1.05 slots wide reserves 2 — rounding up is what stops the
        // next card from being pushed past the row's edge. Clamped to what is
        // actually left so the last card in a row can never reserve more slots
        // than exist.
        final int wanted = (measured.width / unit).ceil();
        span = math.min(math.max(wanted, 1), remainingSlots);
        occupiedWidth = measured.width;
      }

      // Slots reserved, measured edge to edge including the gaps they swallow.
      final double reservedWidth = span * unit + (span - 1) * gap;

      // Mirrored for Arabic: the first column is the RIGHTMOST one, and the
      // cursor still walks away from that edge.
      final double dx = isRtl
          ? size.width - cursor - occupiedWidth
          : cursor;

      positionChild(i, Offset(dx, 0));

      cursor += reservedWidth + gap;
      usedSlots += span;
    }
  }

  @override
  bool shouldRelayout(_HomeSlotRowDelegate oldDelegate) {
    return slotCount != oldDelegate.slotCount ||
        gap != oldDelegate.gap ||
        isRtl != oldDelegate.isRtl ||
        !listEquals(isPlaceholder, oldDelegate.isPlaceholder);
  }

  static bool listEquals(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
