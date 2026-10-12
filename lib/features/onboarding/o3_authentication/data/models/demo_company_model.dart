/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_company_model.dart
/// Purpose: A demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

///*************************** FILE INFO ****************************///
/// File Name: demo_company_model.dart
/// Purpose: Contains main company model.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import './company_information_model.dart';
import './contact_information_model.dart';
import './demo_details.dart';

class DemoCompanyModel {
  String requestId;
  ApprovalStatus requestStatus;
  CompanyInformationModel companyInformation;
  DemoDetails? demoDetails;
  ContactInformationModel contactInformation;
  List<String> answers = [];

  DemoCompanyModel(
      {required this.requestId,
      required this.companyInformation,
      required this.demoDetails,
      required this.contactInformation,
      required this.answers,
      required this.requestStatus});
  static const String REQUEST_ID = 'Request_Id';
  static const String COMPANY_INFORMATION = 'Company_Information';
  static const String DEMO_DETAILS = 'Demo_Details';
  static const String CONTACT_INFORMATION = 'Contact_Information';
  static const String ANSWERS = 'Answers';
  static const String REQUEST_STATUS = 'Request_Status';

  Map<String, dynamic> toMap() {
    return {
      REQUEST_ID: requestId,
      COMPANY_INFORMATION: companyInformation.toMap(),
      DEMO_DETAILS: demoDetails?.toMap(),
      CONTACT_INFORMATION: contactInformation.toMap(),
      REQUEST_STATUS: requestStatus.name,
      ANSWERS: answers,
    };
  }

  factory DemoCompanyModel.fromMap(Map<String, dynamic> map) {
    return DemoCompanyModel(
      requestId: map[REQUEST_ID],
      companyInformation:
          CompanyInformationModel.fromMap(map[COMPANY_INFORMATION]),
      demoDetails: map[DEMO_DETAILS] == null
          ? null
          : DemoDetails.fromMap(map[DEMO_DETAILS]),
      contactInformation:
          ContactInformationModel.fromMap(map[CONTACT_INFORMATION]),
      requestStatus: ApprovalStatus.values
          .firstWhere((element) => element.name == map[REQUEST_STATUS]),
      answers: List<String>.from(map[ANSWERS]),
    );
  }
}
