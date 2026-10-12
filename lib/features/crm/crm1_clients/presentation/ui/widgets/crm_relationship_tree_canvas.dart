// ****************** FILE INFO ******************
// File Name: crm_relationship_tree_canvas.dart
// Purpose: Organizational relationship tree canvas calculating hierarchy based on real employee supervisor relationships
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_relationship_map_node_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmRelationshipTreeCanvas extends StatelessWidget {
  final List<CrmClientRelationshipModel> relationships;
  final ValueChanged<CrmClientRelationshipModel>? onNodeTap;

  const CrmRelationshipTreeCanvas({
    super.key,
    required this.relationships,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relationships.isEmpty) {
      return const SizedBox.shrink();
    }

    final _TreeHierarchy hierarchy = _buildHierarchy(relationships);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Level 1: Root / Peer Nodes on the same level
              _buildNodesRow(hierarchy.roots),

              // If there are any children reporting to roots
              if (hierarchy.children.isNotEmpty) ...<Widget>[
                SizedBox(
                  width: _calculateConnectorWidth(hierarchy.children.length),
                  height: 48.sp,
                  child: CustomPaint(
                    painter: _TreeBranchPainter(
                      childCount: hierarchy.children.length,
                    ),
                  ),
                ),

                // Level 2 & Sub-branches
                _buildChildrenLevel(hierarchy.children, hierarchy.subChildren),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodesRow(List<CrmClientRelationshipModel> nodes) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < nodes.length; i++) ...<Widget>[
          CrmRelationshipMapNodeCard(
            relationship: nodes[i],
            onTap: onNodeTap != null ? () => onNodeTap!(nodes[i]) : null,
          ),
          if (i != nodes.length - 1) SizedBox(width: 32.sp),
        ],
      ],
    );
  }

  Widget _buildChildrenLevel(
    List<CrmClientRelationshipModel> children,
    Map<String, List<CrmClientRelationshipModel>> subChildren,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          _buildChildBranch(children[i],
              subChildren[children[i].id] ?? <CrmClientRelationshipModel>[]),
          if (i != children.length - 1) SizedBox(width: 32.sp),
        ],
      ],
    );
  }

  Widget _buildChildBranch(
    CrmClientRelationshipModel child,
    List<CrmClientRelationshipModel> subs,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CrmRelationshipMapNodeCard(
          relationship: child,
          onTap: onNodeTap != null ? () => onNodeTap!(child) : null,
        ),
        if (subs.isNotEmpty) ...<Widget>[
          SizedBox(
            width: 190.sp,
            height: 32.sp,
            child: CustomPaint(
              painter: _VerticalLinePainter(),
            ),
          ),
          for (int j = 0; j < subs.length; j++) ...<Widget>[
            CrmRelationshipMapNodeCard(
              relationship: subs[j],
              onTap: onNodeTap != null ? () => onNodeTap!(subs[j]) : null,
            ),
            if (j != subs.length - 1)
              SizedBox(
                width: 190.sp,
                height: 32.sp,
                child: CustomPaint(
                  painter: _VerticalLinePainter(),
                ),
              ),
          ],
        ],
      ],
    );
  }

  double _calculateConnectorWidth(int childCount) {
    if (childCount <= 1) return 190.sp;
    return (childCount * 190.sp) + ((childCount - 1) * 32.sp);
  }

  _TreeHierarchy _buildHierarchy(List<CrmClientRelationshipModel> all) {
    // Map employee ID -> EmployeeEntityPro for fast supervisor lookup
    final Map<String, EmployeeEntityPro> employeeMap =
        <String, EmployeeEntityPro>{};
    try {
      final List<EmployeeEntityPro> rawEmployees =
          AppControllers.employee.allEmployeesEntities ?? <EmployeeEntityPro>[];
      for (final EmployeeEntityPro emp in rawEmployees) {
        final String? id = emp.id;
        if (id != null && id.isNotEmpty) {
          employeeMap[id] = emp;
        }
      }
    } catch (_) {}

    // Map relatedEntityId -> CrmClientRelationshipModel
    final Map<String, CrmClientRelationshipModel> relByEntityId =
        <String, CrmClientRelationshipModel>{};
    for (final CrmClientRelationshipModel rel in all) {
      if (rel.relatedEntityId.isNotEmpty) {
        relByEntityId[rel.relatedEntityId] = rel;
      }
    }

    final List<CrmClientRelationshipModel> roots =
        <CrmClientRelationshipModel>[];
    final List<CrmClientRelationshipModel> directChildren =
        <CrmClientRelationshipModel>[];
    final Map<String, List<CrmClientRelationshipModel>> subChildren =
        <String, List<CrmClientRelationshipModel>>{};

    for (final CrmClientRelationshipModel rel in all) {
      final EmployeeEntityPro? emp = employeeMap[rel.relatedEntityId];
      final String? supervisorId = emp?.supervisor;

      // If this employee has a supervisor and that supervisor is also registered in this client's relationships:
      if (supervisorId != null &&
          supervisorId.isNotEmpty &&
          relByEntityId.containsKey(supervisorId) &&
          supervisorId != rel.relatedEntityId) {
        final CrmClientRelationshipModel parentRel =
            relByEntityId[supervisorId]!;

        // Check if parent is itself a child of someone else
        final EmployeeEntityPro? parentEmp =
            employeeMap[parentRel.relatedEntityId];
        final String? grandSupervisorId = parentEmp?.supervisor;
        if (grandSupervisorId != null &&
            grandSupervisorId.isNotEmpty &&
            relByEntityId.containsKey(grandSupervisorId) &&
            grandSupervisorId != parentRel.relatedEntityId) {
          // Sub-child level 3
          subChildren
              .putIfAbsent(parentRel.id, () => <CrmClientRelationshipModel>[])
              .add(rel);
        } else {
          // Direct child level 2
          directChildren.add(rel);
        }
      } else {
        // No supervisor relationship between these persons -> Same top level
        roots.add(rel);
      }
    }

    // Fallback safeguard: If all ended up as children due to circular reference, make all roots
    if (roots.isEmpty && all.isNotEmpty) {
      roots.addAll(all);
      directChildren.clear();
      subChildren.clear();
    }

    return _TreeHierarchy(
      roots: roots,
      children: directChildren,
      subChildren: subChildren,
    );
  }
}

class _TreeHierarchy {
  final List<CrmClientRelationshipModel> roots;
  final List<CrmClientRelationshipModel> children;
  final Map<String, List<CrmClientRelationshipModel>> subChildren;

  const _TreeHierarchy({
    required this.roots,
    required this.children,
    required this.subChildren,
  });
}

class _TreeBranchPainter extends CustomPainter {
  final int childCount;

  const _TreeBranchPainter({required this.childCount});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double startX = size.width / 2;
    final double midY = size.height * 0.55;

    // Stem from root
    canvas.drawLine(Offset(startX, 0), Offset(startX, midY), paint);

    if (childCount <= 1) {
      canvas.drawLine(Offset(startX, midY), Offset(startX, size.height), paint);
      return;
    }

    final double cardWidth = 190.0;
    final double spacing = 32.0;
    final double totalContentWidth =
        (childCount * cardWidth) + ((childCount - 1) * spacing);
    final double leftOffset = (size.width - totalContentWidth) / 2;

    final List<double> childCenters = <double>[];
    for (int i = 0; i < childCount; i++) {
      final double x =
          leftOffset + (i * (cardWidth + spacing)) + (cardWidth / 2);
      childCenters.add(x);
    }

    final double firstX = childCenters.first;
    final double lastX = childCenters.last;

    // Horizontal crossbar with rounded curved corners
    final Path horizontalPath = Path();
    horizontalPath.moveTo(firstX, size.height);
    horizontalPath.quadraticBezierTo(firstX, midY, firstX + 12, midY);
    horizontalPath.lineTo(lastX - 12, midY);
    horizontalPath.quadraticBezierTo(lastX, midY, lastX, size.height);
    canvas.drawPath(horizontalPath, paint);

    // Drop lines to middle children
    for (int i = 1; i < childCount - 1; i++) {
      canvas.drawLine(
        Offset(childCenters[i], midY),
        Offset(childCenters[i], size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreeBranchPainter oldDelegate) {
    return oldDelegate.childCount != childCount;
  }
}

class _VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
