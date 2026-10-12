import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_bar_charts_container.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/statistics_manager_tablet.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TabletDashboard extends StatefulWidget {
  const TabletDashboard({super.key});

  @override
  State<TabletDashboard> createState() => _TabletDashboardState();
}

class _TabletDashboardState extends State<TabletDashboard> {
  int selectedFilterIndex = 0;

  @override
  initState() {
    super.initState();

  }

  void filterRequestedServices() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: orientation ? 0.015.w : 0.03.h,
                        top: orientation ? 0.015.w : 0.01.h,
                        right: orientation ? 0.015.w : 0.02.h,
                        //0.03.w
                        left: orientation ? 0.015.w : 0.02.h, //0.03.w
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                    },
                                    child: Text(
                                      S.of(context).services,
                                      style: TextStyle(
                                        fontSize:28,
                                        fontWeight: FontWeight.w600,
                                        fontFamily:
                                        FontConstants.cairoFontFamily,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5.0),
                                      child: Transform.translate(
                                        offset: Offset(0, 0),
                                        child: Transform.rotate(
                                          angle: Get.locale
                                              .toString()
                                              .contains('ar')
                                              ? 3.13
                                              : 0,
                                          child: SvgPicture.asset(
                                            "assets/icons_assets/main_icons_assets/chevron_right.svg",
                                            height: 0.05.h,
                                            width: 0.04.h,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onInverseSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    S.of(context).dashboard,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                      FontConstants.cairoFontFamily,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 0.02.h,
                              ),
                              const StatisticsManagerTablet(),
                              SizedBox(
                                  height: 0.01.h
                              ),
                              SizedBox(
                                height:  0.01.h
                                ,
                              ),

                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
