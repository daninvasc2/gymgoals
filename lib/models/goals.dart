class Goals {
  final String name;
  final String description;
  final String imageUrl;
  final DateTime expirationDate;
  final num goalValue;

  Goals({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.expirationDate,
    required this.goalValue,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      expirationDate: DateTime.parse(json['expirationDate']),
      goalValue: json['goalValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'expirationDate': expirationDate.toIso8601String(),
      'goalValue': goalValue,
    };
  }
}