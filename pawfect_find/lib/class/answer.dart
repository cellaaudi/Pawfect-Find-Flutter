class Answer {
  int questionId;
  int choiceId;
  double cf;

  Answer({
    required this.questionId,
    required this.choiceId,
    required this.cf,
  });

  Map<String, dynamic> convert() {
    return {
      'questionId': questionId,
      'choiceId': choiceId,
      'cf': cf,
    };
  }
}