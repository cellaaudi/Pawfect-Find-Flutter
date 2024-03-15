class Rule {
  final int breedId;
  final String breedName;
  final int? totalCriterias;
  final List<Map<String, dynamic>>? criterias;

  Rule({
    required this.breedId,
    required this.breedName,
    this.totalCriterias,
    this.criterias,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
        breedId: json['breed_id'] as int,
        breedName: json['breed'] as String,
        totalCriterias: json['total'] == 0 ? 1 : json['total'] as int?,
        criterias: (json['criterias'] as List<dynamic>?)
            ?.map((rec) => rec as Map<String, dynamic>)
            .toList());
  }
}
