/// Module: Policy Management
/// Description: Defines [DepartmentWeight], a small value object that pairs
///              a department name with the weight (percentage) assigned to
///              it inside a single Control. Introduced so that a Control's
///              departments are no longer just names but each carry their
///              own contribution weight, with the guarantee that when all
///              departments are selected ("All") the weights are split
///              equally and always sum to 100.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: None
/// Revision History: 2026-07-18 - Initial creation

/// ************************* FILE INFO *************************** ///
/// File Name: control_department_weight.dart
/// Purpose: Contains the DepartmentWeight class and the helper used to
///          build an equal-weight distribution across departments.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 18/7/2026

/// class name: [DepartmentWeight]
///
/// purpose: represent a single department entry inside a Control's
///          [departments] list, together with the weight (percentage) that
///          department contributes. When a Control's departments are set to
///          equal weights (e.g. the user picked "All"), every
///          [DepartmentWeight] in the list is generated through
///          [DepartmentWeight.equalSplit] so their [weight] values always
///          sum to exactly 100.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class DepartmentWeight {
  static const String _keyDepartment = 'Department';
  static const String _keyWeight = 'Weight';

  final String department;
  final double weight;

  const DepartmentWeight({
    required this.department,
    required this.weight,
  });

  /// function name: [equalSplit]
  ///
  /// purpose: distribute a weight of 100 equally across every department in
  ///          [departments]. Used whenever the Control's departments are
  ///          marked as equal weights (for example when the user selects
  ///          "All" departments instead of hand-picking weights). Any
  ///          rounding remainder is added to the last department so the
  ///          total always sums to exactly 100.
  ///
  /// parameters:
  ///            [List<String>] departments: the department names to split the weight across
  ///
  /// return type: [List<DepartmentWeight>] - one entry per department, weights summing to 100
  static List<DepartmentWeight> equalSplit(List<String> departments) {
    if (departments.isEmpty) return [];

    final rawShare = 100 / departments.length;
    // Round to 2 decimal places to keep the numbers clean.
    final roundedShare = double.parse(rawShare.toStringAsFixed(2));

    final result = List<DepartmentWeight>.generate(
      departments.length,
      (i) => DepartmentWeight(
        department: departments[i],
        weight: roundedShare,
      ),
    );

    // Fix any rounding drift on the last entry so the sum is exactly 100.
    final sumExceptLast = result
        .take(result.length - 1)
        .fold<double>(0, (sum, d) => sum + d.weight);
    final lastWeight = double.parse(
      (100 - sumExceptLast).toStringAsFixed(2),
    );
    result[result.length - 1] =
        DepartmentWeight(department: departments.last, weight: lastWeight);

    return result;
  }

  /// function name: [totalWeight]
  ///
  /// purpose: sum the [weight] of every [DepartmentWeight] in [departments].
  ///          Useful for validating that a manually-weighted (non-equal)
  ///          departments list still adds up to 100.
  ///
  /// parameters:
  ///            [List<DepartmentWeight>] departments: the departments list to sum
  ///
  /// return type: [double] - the sum of all weights
  static double totalWeight(List<DepartmentWeight> departments) {
    return departments.fold<double>(0, (sum, d) => sum + d.weight);
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize this department/weight pair for Firestore storage.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore-ready representation
  Map<String, dynamic> toJson() {
    return {
      _keyDepartment: department,
      _keyWeight: weight,
    };
  }

  /// function name: [fromJson]
  ///
  /// purpose: rebuild a [DepartmentWeight] from raw Firestore map data.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw department entry data
  ///
  /// return type: [DepartmentWeight] - the reconstructed instance
  factory DepartmentWeight.fromJson(Map<String, dynamic> json) {
    return DepartmentWeight(
      department: json[_keyDepartment] as String,
      weight: (json[_keyWeight] as num).toDouble(),
    );
  }
}