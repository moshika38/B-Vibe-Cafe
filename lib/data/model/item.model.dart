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
      id: map['id']?.toString(),
      categoryId: map['categoryId']?.toString() ?? '',
      itemName: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as String,
      cost: map['cost'] as String,
      imagePath: map['imagePath'] as String,
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
