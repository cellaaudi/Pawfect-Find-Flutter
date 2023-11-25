class Answer {
  final int questionId;
  final int choiceId;
  final double cf;

  Answer({
    required this.questionId,
    required this.choiceId,
    required this.cf,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] as int,
      choiceId: json['choiceId'] as int,
      cf: json['cf'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'choiceId': choiceId,
      'cf': cf,
    };
  }

  // @override
  // String toString() {
  //   return 'Question ID: $questionId, Choice ID: $choiceId, Confidence: $cf';
  // }
}
