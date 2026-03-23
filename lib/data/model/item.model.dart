class ItemModel {
  final String? id;
  final String categoryId;
  final String name;
  final String description;
  final String price;
  final String cost;
  final String imagePath;

  ItemModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.imagePath,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      cost: map['cost'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'imagePath': imagePath,
    };
  }
}