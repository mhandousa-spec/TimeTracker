/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_card_metrics.dart
/// Purpose: Declares `HomeCardMetrics` — the one place the home component
///          cards get their HEIGHT and their width SAFETY CAP from.
/// Author: Knowticed Plus team
/// Created: 31/8/2026
/// Updated: 7/10/2026 - Owner decision: every home card keeps its OWN width
///          on the dashboard, the layout editor and the widget picker. The
///          shared 250.sp `width` and the unused `box` are gone; `fitBox` and
///          `heightBox` now constrain width only to `minWidth 0` and a
///          [maxWidthOf] cap (screen width minus the panel gutters), so a card
///          is as wide as it declares and nothing can receive an infinite
///          width inside the horizontally scrolling rows.
///
/// WHY THIS EXISTS
/// ---------------
/// A home component is rendered by `HomeComponent.widget(model)`. Three
/// separate call sites build those cards:
///
///   • adding_widget_page.dart   → AddComponentWrapper      (the widget picker)
///   • edit_home_page.dart       → RemoveComponentWrapper   (the layout editor)
///   • home_screen.dart          → the component directly   (the dashboard)
///
/// All three go through [fitBox] (dashboard) or [heightBox] (editor, picker)
/// below, so height behaviour and the width cap live in one place.
///
/// WIDTH CONTRACT (7/10/2026)
/// --------------------------
/// Every module widget returned by `HomeComponents.widget()` declares its own
/// width (a `SizedBox`/`Container` width, or `HomeWidgetCard.width`, whose
/// default is `kHomeWidgetWidth`). The dashboard and editor rows sit inside a
/// horizontal `SingleChildScrollView`, which hands its children UNBOUNDED
/// width — so a card without a width that contains a `Row` + `Expanded` (or a
/// bare `Container()`) would either throw or stretch. The [maxWidthOf] cap is
/// the safety net for that case and also keeps a card wider than a phone
/// (e.g. the 600 Roles cards) inside the screen instead of off its edge.
/// A NEW home card must still declare its own width.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCardMetrics {
  const HomeCardMetrics._();

  /// Height of every home component card, on every screen (a MINIMUM on the
  /// dashboard, fixed in the editor and picker).
  static double get height => 120.sp;

  /// Gap BETWEEN two cards in a row.
  ///
  /// Applied as a `Row.spacing`, which puts this gap between neighbours and
  /// nothing at the two outer ends — as opposed to giving every card its own
  /// horizontal padding, which would also inset the first and last card from
  /// the panel edges.
  static double get gap => 20.sp;

  /// Horizontal gutter of the home panel on each side (the phone dashboard's
  /// `EdgeInsets.symmetric(horizontal: 10.w)`).
  static double get gutter => 10.w;

  /// Function Name: [maxWidthOf]
  ///
  /// Purpose: The widest a single home card may ever be — the screen width
  /// minus the panel gutters on both sides. A safety cap, not a target: cards
  /// keep the width they declare and only one wider than the screen is
  /// clamped to it.
  ///
  /// Parameters:
  ///   [BuildContext] context: read for the screen width.
  ///
  /// Return type: [double]
  static double maxWidthOf(BuildContext context) {
    final double cap = MediaQuery.sizeOf(context).width - 2 * gutter;
    return cap > 0 ? cap : 0;
  }

  /// Function Name: [heightBox]
  ///
  /// Purpose: Fixed [height], the card's OWN width (bounded by [maxWidthOf]).
  /// Used by the layout EDITOR and the widget PICKER, where cards are
  /// previews laid out on an even row height.
  ///
  /// Vertical behaviour: content taller than [height] scrolls inside the card
  /// rather than overflowing, and a short card is stretched up to the full
  /// height so its background paints the whole tile.
  ///
  /// Parameters:
  ///   [Widget] child: the module widget.
  ///
  /// Return type: [Widget]
  static Widget heightBox({required Widget child}) {
    return Builder(
      builder: (BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidthOf(context)),
        child: SizedBox(
          height: height,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Function Name: [fitBox]
  ///
  /// Purpose: The card's OWN width (bounded by [maxWidthOf]) and AT LEAST
  /// [height] — a card that needs more room grows instead of scrolling inside
  /// itself. Used by the DASHBOARD (13/9/2026: pinning the height there hid
  /// the Forms card's third button behind an inner scroll).
  ///
  /// [height] stays the MINIMUM so a short card still paints a full tile.
  /// No `IntrinsicHeight` above the row to even the cards up: several module
  /// widgets contain a `ListView`, which throws when asked for an intrinsic
  /// height. Cards in a row can end on different baselines; that is the
  /// cheaper flaw.
  ///
  /// Parameters:
  ///   [Widget] child: the module widget.
  ///
  /// Return type: [Widget]
  static Widget fitBox({required Widget child}) {
    return Builder(
      builder: (BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidthOf(context),
          minHeight: height,
        ),
        child: child,
      ),
    );
  }
}
