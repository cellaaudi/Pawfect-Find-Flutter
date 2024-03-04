class History {
  // final String uuid;
  // final int breed_id;
  // final String breed;
  // final double cf;
  final int id;
  final String answer;
  final int user_id;
  final String created_at;

  History({
    // required this.uuid,
    // required this.breed_id,
    // required this.breed,
    // required this.cf,
    required this.id,
    required this.answer,
    required this.user_id,
    required this.created_at,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
        // uuid: json['uuid'] as String,
        // breed_id: json['breed_id'] as int,
        // breed: json['breed'] as String,
        // cf: json['cf'] as double,
        id: json['id'] as int,
        answer: json['answer'] as String,
        user_id: json['user_id'] as int,
        created_at: json['created_at'] as String);
  }
}
