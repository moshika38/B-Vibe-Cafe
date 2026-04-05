import 'dart:convert';

class ExpenseItemModel {
  final String id;
  final String name;
  final String description;
  final String unit; // e.g. 'kg', 'ltr', 'units'

  ExpenseItemModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
    };
  }

  factory ExpenseItemModel.fromMap(Map<String, dynamic> map) {
    return ExpenseItemModel(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      unit: map['unit'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseItemModel.fromJson(String source) =>
      ExpenseItemModel.fromMap(json.decode(source));
}
