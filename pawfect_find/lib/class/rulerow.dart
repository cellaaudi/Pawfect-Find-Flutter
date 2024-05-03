import 'package:pawfect_find/class/rule.dart';

class RuleRow {
  final int breed_id;
  final int criteria_id;
  final double cf;
  final String breed;
  final String criteria;

  RuleRow({
    required this.breed_id,
    required this.criteria_id,
    required this.cf,
    required this.breed,
    required this.criteria,
  });

  factory RuleRow.fromJson(Map<String, dynamic> json) {
    return RuleRow(
      breed_id: json['breed_id'] as int,
      criteria_id: json['criteria_id'] as int,
      cf: json['cf'] as double,
      breed: json['breed'] as String,
      criteria: json['criteria'] as String,
    );
  }
}
