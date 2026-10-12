/// Module: home/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: qiyas_tracker_entity.dart
/// Purpose: Declares `QiyasTrackerEntity`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************** FILE INFO ********************
/// File Name: qiyas_tracker_entity.dart
/// Description: This file contains the QiyasTrackerEntity class which represents the tracking information for topics
/// Created by: Mohamed Elrashidy
/// Created at: 06/06/2024

class QiyasTrackerEntity {
  int numberOfTopics;
  List<String> approvedTopics;
  List<String> partialAssigned;
  List<String> assigned;
  List<String> notAssigned;

  QiyasTrackerEntity({
    required this.numberOfTopics,
    required this.approvedTopics,
    required this.partialAssigned,
    required this.assigned,
    required this.notAssigned,
  });
}
