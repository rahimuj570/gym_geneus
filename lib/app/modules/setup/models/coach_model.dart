class Coach {
  final int id;
  final String name;
  final String behavior;

  Coach({required this.id, required this.name, required this.behavior});

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'] as int,
      name: json['name'] as String,
      behavior: json['behavior'] as String,
    );
  }
}
