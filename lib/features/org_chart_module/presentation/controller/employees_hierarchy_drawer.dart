///********************* FILE INFO ********************///
/// File Name: employees_hierarchy_drawer.dart
/// Purpose: Contains the logic for building the organization hierarchy graph
/// Author: Mohamed Elrashidy
/// Created at: 25/12/2024

import 'dart:math';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/features/org_chart_module/domain/entities/organization_hierarchy_node.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';

extension OrganizationHierarchyDrawer on OrgChartEmployeeController {
  /// function name: buildOrganizationHierarchyGraph
  /// purpose: build the organization hierarchy graph
  buildOrganizationHierarchyGraph(List<NewEmployeeModelHistory> employees) {
    List<NewEmployeeModelHistory> tempEmployees = initGraph(employees);
    buildGraph(tempEmployees);
    sortChildren();
    getDepth();
    update();
  }

  /// function name: initGraph
  /// purpose: clear needed data structures and initialize the organization hierarchy graph with the CEO node
  /// returns: Map<String,NewEmployeeModel> tempEmployees - a map of all employees
  List<NewEmployeeModelHistory> initGraph(List<NewEmployeeModelHistory> employees) {
    graphDepth = 1;
    organizationHierarchyNodes.clear();
    organizationHierarchyNodesRoots.clear();
    List<NewEmployeeModelHistory> tempEmployees = [];
    for (var element in employees) {
      tempEmployees.add(element);
      OrganizationHierarchyNode node = OrganizationHierarchyNode(employee: element);
      organizationHierarchyNodesRoots.putIfAbsent(
          element.email!.last!.trim(),
          () => node);
      organizationHierarchyNodes.putIfAbsent(
          element.email!.last!.trim(),
          () => node);

    }
    return tempEmployees;
  }

  double getOpacityStep() {
    return 1.0 / graphDepth;
  }

  /// function name: buildGraph
  ///
  /// purpose: build the organization hierarchy graph
  ///
  /// param: List<NewEmployeeModel> tempEmployees - a list of all employees
  /// function name: buildGraph
  /// purpose: build the organization hierarchy graph with smart email matching
  /// param: List<NewEmployeeModelHistory> tempEmployees - a list of all employees
  /// function name: buildGraph
  /// purpose: build the organization hierarchy graph with circular reference handling
  /// param: List<NewEmployeeModelHistory> tempEmployees - a list of all employees
  void buildGraph(List<NewEmployeeModelHistory> tempEmployees) {

    int linkedCount = 0;
    int skippedCount = 0;
    int circularCount = 0;

    for (NewEmployeeModelHistory employee in tempEmployees) {
      String empEmail = employee.email?.last?.trim() ?? '';
      String empName = "${employee.firstName?.last ?? ''} ${employee.lastName?.last ?? ''}".trim();

      if (employee.supervisor?.lastOrNull?.trim() == null ||
          employee.supervisor!.last!.trim().isEmpty) {
        skippedCount++;
        continue;
      } else {
        String supervisorEmail = employee.supervisor!.last!.trim();
        String currentUserEmail = empEmail;

        // ✅ CHECK FOR CIRCULAR REFERENCE (Employee is their own supervisor)
        if (supervisorEmail == currentUserEmail) {
          circularCount++;
          skippedCount++; // Keep them as root
          continue;
        }

        if (organizationHierarchyNodes.containsKey(supervisorEmail)) {
          OrganizationHierarchyNode? currentUserNode =
          organizationHierarchyNodesRoots.remove(currentUserEmail);

          if (currentUserNode != null) {
            organizationHierarchyNodes[supervisorEmail]!
                .children
                .add(currentUserNode);
            linkedCount++;
          }
        } else {
        }
      }
    }


    // ✅ SAFETY CHECK: If no roots exist, something is wrong
    if (organizationHierarchyNodesRoots.isEmpty) {
    }
  }

  getDepth(){
    graphDepth = 0;
    for (var node in organizationHierarchyNodesRoots.values) {
      dfs(node, 1);
    }
  }

  /// function name: [dfs]
  ///
  /// purpose: depth first search to get the depth of the organization hierarchy graph
  ///
  /// parameters: [OrganizationHierarchyNode] node - the current node
  ///             [int] depth - the current depth
  dfs(OrganizationHierarchyNode node, int depth) {
    graphDepth = max(graphDepth, depth);
    for (var child in node.children) {
      dfs(child, depth + 1);
    }
  }
  /// method name: [sortChildren]
  ///
  /// purpose: sort the children of each node in the organization hierarchy graph to group employees not supervise any one
  sortChildren(){
    for (var node in organizationHierarchyNodes.values) {
      node.children.sort((a, b) => b.children.length.compareTo(a.children.length));
    }
  }
}
