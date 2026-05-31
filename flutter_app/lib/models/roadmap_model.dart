class RoadmapWeekModel {
  const RoadmapWeekModel(
      {required this.number,
      required this.title,
      required this.topics,
      required this.complete});

  final int number;
  final String title;
  final List<String> topics;
  final bool complete;

  factory RoadmapWeekModel.fromJson(Map<String, dynamic> json) =>
      RoadmapWeekModel(
        number: json['number'] as int,
        title: json['title'] as String,
        topics: List<String>.from(json['topics'] as List),
        complete: json['complete'] == true,
      );
}
