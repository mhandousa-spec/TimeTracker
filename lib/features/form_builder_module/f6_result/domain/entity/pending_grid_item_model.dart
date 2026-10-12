class PendingGridItemModel {
   int index;
   String name;
   String jobTitle;
   String department;
   int remindersSent;
   DateTime remindersSentTime;
   String imageUrl;

  PendingGridItemModel({
    required this.index,
    required this.name,
    required this.jobTitle,
    required this.department,
    required this.remindersSent,
    required this.remindersSentTime,
    this.imageUrl='https://s3-alpha-sig.figma.com/img/5757/6100/113cda33681365945a634b5cdd83d3d8?Expires=1739750400&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=Dq1z6wfseHNyquYSmParvbtdKfAgckEc1P3Mu0-O0DUC~A6vjRprEur-giZAUmpoHW2ojw6h-ZuMkM8Em03yD3arjEPzyaThazGNI50sEwCZJsWdoIjQYsabDHiNA9UHIOIETYD73LS13sdomT8fs5DssxOA8Gg7YfqCjGwjug4O1PceJdm9W-O~S1lD-8IRk--QQqSjItkKqG4iLW4VFZszpG9wiOF~qx~hCuOri-P-XLkJ8DBhdEAtxSj-q~zniDbX6pol3rX8U8Umt6kjx1ntDARiJgVDeuzki2b0J2Cr1cIKADoGon~oNyPOzL7IeMSTaOfODwNRGmi1JqqGyg__',
  });
}

