class Rule {
  final int breedId;
  final String breedName;
  final int totalCriterias;

  Rule({
    required this.breedId,
    required this.breedName,
    required this.totalCriterias,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
        breedId: json['breed_id'] as int,
        breedName: json['breed'] as String,
        totalCriterias: json['total'] as int);
  }
}
