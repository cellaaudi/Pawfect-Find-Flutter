class Question {
  final int id;
  final String question;
  final List<Map<String, dynamic>>? choices;

  Question({
    required this.id,
    required this.question,
    this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((choice) => choice as Map<String, dynamic>)
          .toList(),
    );
  }
}
