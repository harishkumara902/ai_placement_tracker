class UserModel {
  const UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.college,
      required this.targetDomain});

  final int id;
  final String name;
  final String email;
  final String college;
  final String targetDomain;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: (json['name'] ?? json['full_name'] ?? '') as String,
        email: json['email'] as String,
        college: (json['college'] ?? '') as String,
        targetDomain: (json['target_domain'] ?? '') as String,
      );
}
