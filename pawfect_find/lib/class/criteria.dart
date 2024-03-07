class Criteria {
  final int id;
  final String criteria;

  Criteria({
    required this.id,
    required this.criteria,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
        id: json['id'] as int, criteria: json['criteria'] as String);
  }
}
