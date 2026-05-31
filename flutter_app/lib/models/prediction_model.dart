class PredictionModel {
  const PredictionModel(
      {required this.probability,
      required this.weakAreas,
      required this.recommendations});

  final double probability;
  final List<String> weakAreas;
  final List<String> recommendations;

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      PredictionModel(
        probability: (json['probability'] as num).toDouble(),
        weakAreas: List<String>.from(json['weak_areas'] as List),
        recommendations: List<String>.from(json['recommendations'] ?? const []),
      );
}
