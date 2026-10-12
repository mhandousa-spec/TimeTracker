// ******************* FILE INFO *******************
// File Name: dashboard_admin_market_research_service_tablet
// Description: Dashboard admin market research service tablet.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';


class MarketResearchServiceTablet extends StatefulWidget {
  const MarketResearchServiceTablet({super.key});

  @override
  State<MarketResearchServiceTablet> createState() => _MarketResearchServiceTabletState();
}

class _MarketResearchServiceTabletState extends State<MarketResearchServiceTablet> {
  bool showAll = false;

  List<Service> services = List.generate(
    10,
        (index) => Service(
      title: 'Market Research Service',
      doneServices: 20,
      totalHours: 40,
      startDate: '28 May 2020',
    ),
  );

  @override
  Widget build(BuildContext context) {
    int displayCount = showAll ? services.length : 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(displayCount, (index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 18,
                    child: ServiceCard(service: services[index]),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() => showAll = !showAll);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showAll ? 'Show less' : 'See all',
                    style:  StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.blue,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String title;
  final int doneServices;
  final int totalHours;
  final String startDate;

  Service({
    required this.title,
    required this.doneServices,
    required this.totalHours,
    required this.startDate,
  });
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.switchOff,
                  child: Icon(Icons.headphones, color: AppColors.black),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service.title,
                    style: StyleText.fontSize14Weight400.copyWith(fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text(
                      "Start Date:",
                      style: StyleText.fontSize14Weight400.copyWith(color: AppColors.grey, fontSize: 12),
                    ),
                    Text(
                      service.startDate,
                      style: StyleText.fontSize14Weight400.copyWith(fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            // Stats Row
            Row(
              children: [
                 Text(
                  "Done Services",
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.grey),
                ),
                const SizedBox(width: 6),
                Text(
                  service.doneServices.toString(),
                  style: StyleText.fontSize14Weight400.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                 Text(
                  "Total Hours",
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.grey),
                ),
                const SizedBox(width: 6),
                Text(
                  service.totalHours.toString(),
                  style: StyleText.fontSize14Weight400.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
