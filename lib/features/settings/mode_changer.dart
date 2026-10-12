import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class Mode {
  static bool showInvoice= false;
  static bool freelancer = false;
  static bool hr = false;
  static bool owner = false;
  static bool champion = false;
  static bool manager = false;
  static bool employee = false;
  
  static bool departmentManager = false;
  static int addNewEmployeeIndex=0;
  static int signUpindex=0;
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  /*
               then change the value of the freelancer or Cliet in the card screen and services screen
               */
}

class ModeChat {
  static bool chatIndex = false;
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  /*
               then change the value of the freelancer or Cliet in the card screen and services screen
               */
}
