class ItemModel {
  final String? id;
  final String categoryId;
  final String itemName;
  final String description;
  final String price;
  final String cost;
  final String imagePath;
  final bool isRetail;

  ItemModel({
    this.id,
    required this.categoryId,
    required this.itemName,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
    required this.isRetail,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      categoryId: map['categoryId'],
      itemName: map['name'],
      description: map['description'],
      price: map['price'],
      cost: map['cost'],
      imagePath: map['imagePath'],
      isRetail: map['isRetail'] == 1 || map['isRetail'] == '1',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': itemName,
      'description': description,
      'price': price,
      'cost': cost,
      'imagePath': imagePath,
      'isRetail': isRetail ? 1 : 0,
    };
  }
}
