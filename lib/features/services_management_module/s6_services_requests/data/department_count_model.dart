// ******************* FILE INFO *******************
// File Name: department_count_model
// Description: View-model holding per-department request counts and the total.
// Module: services_management_module / s6_services_requests / data
// *************************************************

class DepartmentCountModel {
  // Map keys
  static const String kTotal = 'total';
  static const String kDepartmentCounts = 'departmentCounts';

  final int total;
  final Map<String, int> departmentCounts;

  DepartmentCountModel({
    required this.total,
    required this.departmentCounts,
  });

  factory DepartmentCountModel.empty() {
    return DepartmentCountModel(
      total: 0,
      departmentCounts: {},
    );
  }

  factory DepartmentCountModel.fromMap(Map<String, dynamic> map) {
    return DepartmentCountModel(
      total: (map[kTotal] as num?)?.toInt() ?? 0,
      departmentCounts: (map[kDepartmentCounts] as Map?)?.map(
            (key, value) =>
                MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
          ) ??
          <String, int>{},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kTotal: total,
      kDepartmentCounts: departmentCounts,
    };
  }

  DepartmentCountModel copyWith({
    int? total,
    Map<String, int>? departmentCounts,
  }) {
    return DepartmentCountModel(
      total: total ?? this.total,
      departmentCounts: departmentCounts ?? this.departmentCounts,
    );
  }
}
