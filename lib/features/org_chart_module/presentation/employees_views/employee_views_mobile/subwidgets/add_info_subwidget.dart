import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/custom_icon_container.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AddInfoFieldMobile extends StatefulWidget {
  const AddInfoFieldMobile({super.key});

  @override
  State<AddInfoFieldMobile> createState() => _AddInfoFieldMobileState();
}

class _AddInfoFieldMobileState extends State<AddInfoFieldMobile> {
  List<String> imageExtentions = [
    ".PSD",
    ".XCF",
    ".AI",
    ".CDR",
    ".tif",
    ".tiff",
    ".bmp",
    ".jpg",
    ".jpeg",
    ".gif",
    ".png",
    ".eps",
    ".raw",
    ".cr2",
    ".nef",
    ".orf",
    ".sr2"
  ];
  String? educationCertificate2;
  String? idPhoto2;
  String? armyCertificate2;
  String? drivingLicense2;
  String? maritalCertificate2;
  String? insuranceCard2;

  bool isImage(String filePath) {
    bool flag = false;
    for (String imageExtention in imageExtentions) {
      if (filePath.contains(imageExtention)) {
        return true;
      }
    }
    return flag;
  }

  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());
  Future<void> pickAndUploadFile(
    int index,
  ) async {
    FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (pickedPdf != null) {
      showLoadingIndicator();
      final file = File(pickedPdf.files.single.path!);
      String filePath = pickedPdf.files.single.path!;

      if (isImage(filePath)) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'employee/"${employee!.firstName!.last!}_${employee!.lastName!.last!}"/${index == 0 ? "education_certificate_photo" : index == 1 ? "id_photo" : index == 2 ? "army_certificate_photo" : index == 3 ? "driving_license_photo" : index == 4 ? "marital_certificate_photo" : "insurance_card_photo"}_${DateTime.now()}.png');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final TaskSnapshot task = await ref.putFile(file, metadata);
        index == 0
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
    /*    index == 0
            ? addEmployeeController.employeePhone.educationCertificate = EducationCertificate(
                educationCertificate: [await task.ref.getDownloadURL()],
                timestamps: [Timestamp.now()])
            :*/ /*index == 1
                ? addEmployeeController.employeePhone.idPhoto = IdPhoto(
                    idPhoto: [await task.ref.getDownloadURL()],
                    timestamps: [Timestamp.now()])
                : *//*index == 2
                    ? addEmployeeController.employeePhone.armyCertificate = ArmyCertificate(
                        armyCertificate: [await task.ref.getDownloadURL()],
                        timestamps: [Timestamp.now()])
                    : *//*index == 3
                        ? addEmployeeController.employeePhone.drivingLicense = DrivingLicense(
                            drivingLicense: [await task.ref.getDownloadURL()],
                            timestamps: [Timestamp.now()])
                        :*//* index == 4
                            ? addEmployeeController.employeePhone.maritalCertificate = MaritalCertificate(
                                maritalCertificate: [await task.ref.getDownloadURL()],
                                timestamps: [Timestamp.now()])
                            :*/ /*addEmployeeController.employeePhone.insuranceCard = InsuranceCard(insuranceCard: [await task.ref.getDownloadURL()], timestamps: [Timestamp.now()]);*/
      } else {
        final Reference storageRef = FirebaseStorage.instance.ref().child(
            'employee/"${employee!.firstName!.last!}_${employee!.lastName!.last!}"/${index == 0 ? "education_certificate_file" : index == 1 ? "id_file" : index == 2 ? "army_certificate_file" : index == 3 ? "driving_license_file" : index == 4 ? "marital_certificate_file" : "insurance_card_file"}_${DateTime.now()}.pdf');
        final metadata = SettableMetadata(contentType: 'application/pdf');
        final TaskSnapshot task = await storageRef.putFile(file, metadata);
        index == 0
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
/*        index == 0
            ? addEmployeeController.employeePhone.educationCertificate = EducationCertificate(
                educationCertificate: [await task.ref.getDownloadURL()],
                timestamps: [Timestamp.now()])
            : index == 1
                ? addEmployeeController.employeePhone.idPhoto = IdPhoto(
                    idPhoto: [await task.ref.getDownloadURL()],
                    timestamps: [Timestamp.now()])
                : index == 2
                    ? addEmployeeController.employeePhone.armyCertificate = ArmyCertificate(
                        armyCertificate: [await task.ref.getDownloadURL()],
                        timestamps: [Timestamp.now()])
                    : index == 3
                        ? addEmployeeController.employeePhone.drivingLicense = DrivingLicense(
                            drivingLicense: [await task.ref.getDownloadURL()],
                            timestamps: [Timestamp.now()])
                        : index == 4
                            ? addEmployeeController.employeePhone.maritalCertificate = MaritalCertificate(
                                maritalCertificate: [await task.ref.getDownloadURL()],
                                timestamps: [Timestamp.now()])
                            : addEmployeeController.employeePhone.insuranceCard = InsuranceCard(insuranceCard: [await task.ref.getDownloadURL()], timestamps: [Timestamp.now()]);
   */   }
      setState(() {});
      hideLoadingIndicator();
    }
  }

  // void initState() {
  //   educationCertificate2 = null;
  //   idPhoto2 = null;
  //   armyCertificate2 = null;
  //   drivingLicense2 = null;
  //   maritalCertificate2 = null;
  //   insuranceCard2 = null;

  //   super.initState();
  // }
  double heightSpacer = 0.025.h;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
     
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:isTablet? 0.025.w : 0, vertical:isTablet? 0 :0.02.h),
      child: SizedBox(
        // height: 0.62.h,
        child: ListView(
          physics:isTablet? null : NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            SizedBox(
              width: 1.0.w,
              child: CustomIconContainer(
                text: S.of(context).educationCertificate,
                isEdit: true,
                isEditIcon: true,
                image: educationCertificate2 != null
                    ? isImage(educationCertificate2!)
                        ? educationCertificate2
                        : 'assets/png_assets/pdf.jpg'
                    : null,
                onPressed: () {
                  pickAndUploadFile(
                    0,
                  );
                },
              ),
            ),
           
            Padding(
              padding: EdgeInsets.symmetric(vertical: heightSpacer),
              child: SizedBox(
                width: 1.0.w,
                child: CustomIconContainer(
                  text: S.of(context).iDPhoto,
                  isEdit: true,
                  isEditIcon: true,
                  image: idPhoto2 != null
                      ? isImage(idPhoto2!)
                          ? idPhoto2
                          : 'assets/png_assets/pdf.jpg'
                      : null,
                  onPressed: () {
                    pickAndUploadFile(
                      1,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 1.0.w,
              child: CustomIconContainer(
                text: S.of(context).martialServiceProof,
                isEdit: true,
                isEditIcon: true,
                image: armyCertificate2 != null
                    ? isImage(armyCertificate2!)
                        ? armyCertificate2
                        : 'assets/png_assets/pdf.jpg'
                    : null,
                onPressed: () {
                  pickAndUploadFile(
                    2,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: heightSpacer),
              child: SizedBox(
                width: 1.0.w,
                child: CustomIconContainer(
                  text: S.of(context).drivingLicense,
                  isEdit: true,
                  image: drivingLicense2 != null
                      ? isImage(drivingLicense2!)
                          ? drivingLicense2
                          : 'assets/png_assets/pdf.jpg'
                      : null,
                  isEditIcon: true,
                  onPressed: () {
                    pickAndUploadFile(
                      3,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 1.0.w,
              child: CustomIconContainer(
                text: S.of(context).maritalCertificate,
                isEdit: true,
                isEditIcon: true,
                image: maritalCertificate2 != null
                    ? isImage(maritalCertificate2!)
                        ? maritalCertificate2
                        : 'assets/png_assets/pdf.jpg'
                    : null,
                onPressed: () {
                  pickAndUploadFile(
                    4,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: heightSpacer),
              child: SizedBox(
                width: 1.0.w,
                child: CustomIconContainer(
                  text: S.of(context).lifeInsuranceCard,
                  isEdit: true,
                  image: insuranceCard2 != null
                      ? isImage(insuranceCard2!)
                          ? insuranceCard2
                          : 'assets/png_assets/pdf.jpg'
                      : null,
                  isEditIcon: true,
                  onPressed: () {
                    pickAndUploadFile(
                      5,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
