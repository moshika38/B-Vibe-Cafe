class CategoriesModel {
  final String? id;
  final String itemName;
  final int iconNumber;

  CategoriesModel({this.id, required this.itemName, required this.iconNumber});

  // from map and to map

  factory CategoriesModel.fromMap(Map<String, dynamic> map) {
    return CategoriesModel(
      id: map['id']?.toString(),
      itemName: map['itemName'] as String,
      iconNumber: map['iconNumber'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'itemName': itemName, 'iconNumber': iconNumber};
  }
}
