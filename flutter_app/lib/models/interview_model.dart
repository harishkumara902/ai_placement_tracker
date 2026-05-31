class InterviewQuestionModel {
  const InterviewQuestionModel(
      {required this.id, required this.prompt, required this.category});

  final String id;
  final String prompt;
  final String category;

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json) =>
      InterviewQuestionModel(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        category: json['category'] as String,
      );
}

class InterviewEvaluationModel {
  const InterviewEvaluationModel(
      {required this.score, required this.feedback, required this.idealAnswer});

  final double score;
  final String feedback;
  final String idealAnswer;

  factory InterviewEvaluationModel.fromJson(Map<String, dynamic> json) =>
      InterviewEvaluationModel(
        score: (json['score'] as num).toDouble(),
        feedback: json['feedback'] as String,
        idealAnswer: json['ideal_answer'] as String,
      );
}
