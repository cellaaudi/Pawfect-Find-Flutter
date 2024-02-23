class History {
  final String uuid;
  final int breed_id;
  final String breed;
  final double cf;
  final int is_saved;
  final int? user_id;
  final String created_at;
  final String? updated_at;

  History({
    required this.uuid,
    required this.breed_id,
    required this.breed,
    required this.cf,
    required this.is_saved,
    this.user_id,
    required this.created_at,
    this.updated_at,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
        uuid: json['uuid'] as String,
        breed_id: json['breed_id'] as int,
        breed: json['breed'] as String,
        cf: json['cf'] as double,
        is_saved: json['is_saved'] as int,
        user_id: json['user_id'] as int?,
        created_at: json['created_at'] as String,
        updated_at: json['updated_at'] as String?);
  }
}
