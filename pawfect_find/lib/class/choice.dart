class Choice {
  final int id;
  final String choice;
  final int questionId;
  final String question;
  final int? criteriaId;
  final String? criteria;

  Choice({
    required this.id,
    required this.choice,
    required this.questionId,
    required this.question,
    this.criteriaId,
    this.criteria,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as int,
      choice: json['choice'] as String,
      questionId: json['question_id'] as int,
      question: json['question'] as String,
      criteriaId: json['criteria_id'] as int?,
      criteria: json['criteria'] as String?,
    );
  }
}
