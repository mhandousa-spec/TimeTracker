/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: persistent_nav_bar.dart
/// Purpose: Public surface of the vendored persistent nav bar.
///
/// The implementation used to live in two god files — utils/styles.dart
/// (3,251 LOC) and utils/model.dart (1,727 LOC), both past the 1,500 LOC
/// auto-reject. They are now one declaration per file; this barrel keeps a
/// single import for consumers and lets the split files see each other.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026

export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/custom_widget_route_and_navigator_settings.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/item_animation_properties.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/nav_bar_decoration.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/nav_bar_essentials.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/nav_bar_padding.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/neumorphic_properties.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/persistent_bottom_nav_bar_item.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/route_and_navigator_settings.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/models/screen_transition_animation.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/data/utils/nav_bar_constant_modules.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/domain/enums/nav_bar_style.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/domain/enums/page_transition_animation.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/domain/enums/pop_action_screens_type.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/persistent_tab_controller.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/bottom_nav_simple.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/custom_tab_view.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/nav_bar_animation.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/nav_bar_paint.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/nav_bar_utilities.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/neumorphic_bottom_nav_bar.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/neumorphic_container.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/persistent_bottom_nav_bar.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/persistent_nav_bar_navigator.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/persistent_tab_scaffold.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar/persistent_tab_view.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_1.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_10.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_11.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_12.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_13.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_14.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_15.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_16.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_17.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_18.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_19.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_2.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_3.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_4.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_5.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_6.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_7.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_8.dart';
export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/nav_bar_styles/bottom_nav_style_9.dart';
