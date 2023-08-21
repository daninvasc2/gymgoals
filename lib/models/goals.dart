class Goals {
  final String? id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime expirationDate;
  final num goalValue;

  Goals({
    this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.expirationDate,
    required this.goalValue,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
      goalValue: json['goalValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'goalValue': goalValue,
    };
  }
}