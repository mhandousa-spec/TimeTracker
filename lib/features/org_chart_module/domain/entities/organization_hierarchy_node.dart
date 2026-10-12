
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

class OrganizationHierarchyNode {
  NewEmployeeModelHistory employee;
  final List<OrganizationHierarchyNode> children = [];

  OrganizationHierarchyNode({required this.employee});
}
