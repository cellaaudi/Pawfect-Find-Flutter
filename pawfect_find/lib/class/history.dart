class History {
  final int id;
  final String answer;
  final int user_id;
  final String created_at;
  final List<Map<String, dynamic>>? recommendations;
  // final List<dynamic> recommendations;

  History({
    required this.id,
    required this.answer,
    required this.user_id,
    required this.created_at,
    required this.recommendations,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
        id: json['id'] as int,
        answer: json['answer'] as String,
        user_id: json['user_id'] as int,
        created_at: json['created_at'] as String,
        // recommendations: json['recommendations'] as List<dynamic>
        recommendations: (json['recommendations'] as List<dynamic>?)
            ?.map((rec) => rec as Map<String, dynamic>)
            .toList()
            );
  }
}
