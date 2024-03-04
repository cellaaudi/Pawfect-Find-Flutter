class Recommendation {
  final int id;
  final int breed_id;
  final double cf;
  final int history_id;
  final String breed;

  Recommendation({
    required this.id,
    required this.breed_id,
    required this.cf,
    required this.history_id,
    required this.breed,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
        id: json['id'] as int,
        breed_id: json['breed_id'] as int,
        cf: json['cf'] as double,
        history_id: json['history_id'] as int,
        breed: json['breed'] as String);
  }
}
