class History {
  final int id;
  final String answer;
  final int user_id;
  final String created_at;

  History({
    required this.id,
    required this.answer,
    required this.user_id,
    required this.created_at,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
        id: json['id'] as int,
        answer: json['answer'] as String,
        user_id: json['user_id'] as int,
        created_at: json['created_at'] as String);
  }
}
