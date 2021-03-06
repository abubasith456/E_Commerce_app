final String CartData = 'mycart';

class CartFields {
  static final List<String> values = [
    /// Add all fields
    id, name, price, description, productImage, productId
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String price = 'price';
  static final String description = 'description';
  static final String productImage = 'productImage';
  static final String productId = 'productId';
  static final String quantity = 'quantitiy';
}

class Cart {
  final int? id;
  final String name;
  final String price;
  final String description;
  final String productImage;
  final String productId;
  final String quantity;

  const Cart({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.productImage,
    required this.productId,
    required this.quantity,
  });

  Cart copy({
    int? id,
    String? name,
    String? price,
    String? description,
    String? productImage,
    String? productId,
    String? quantity,
  }) =>
      Cart(
          id: id ?? this.id,
          name: name ?? this.name,
          price: price ?? this.price,
          description: description ?? this.description,
          productImage: productImage ?? this.productImage,
          productId: productId ?? this.productId,
          quantity: quantity ?? this.quantity);

  static Cart fromJson(Map<String, Object?> json) => Cart(
      id: json[CartFields.id] as int?,
      name: json[CartFields.name] as String,
      price: json[CartFields.price] as String,
      description: json[CartFields.description] as String,
      productImage: json[CartFields.productImage] as String,
      productId: json[CartFields.productId] as String,
      quantity: json[CartFields.quantity] as String);

  Map<String, Object?> toJson() => {
        CartFields.id: id,
        CartFields.name: name,
        CartFields.price: price,
        CartFields.description: description,
        CartFields.productImage: productImage,
        CartFields.productId: productId,
        CartFields.quantity: quantity,
      };
}
