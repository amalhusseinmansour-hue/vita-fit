/// نموذج بيانات المنتج - Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discount; // خصم (اختياري)
  final String category; // ملابس، معدات، مكملات، إكسسوارات
  final List<String> images;
  final double rating;
  final int reviews;
  final List<String> sizes; // المقاسات المتوفرة
  final List<String> colors; // الألوان المتوفرة
  final bool inStock;
  final int stock; // الكمية المتوفرة

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discount,
    required this.category,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.sizes,
    required this.colors,
    required this.inStock,
    required this.stock,
  });

  // السعر بعد الخصم
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  // نسبة الخصم
  String get discountText {
    if (discount != null && discount! > 0) {
      return '${discount!.toInt()}%';
    }
    return '';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      category: json['category'] as String,
      images: List<String>.from(json['images'] as List),
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      sizes: List<String>.from(json['sizes'] as List),
      colors: List<String>.from(json['colors'] as List),
      inStock: json['inStock'] as bool,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'category': category,
      'images': images,
      'rating': rating,
      'reviews': reviews,
      'sizes': sizes,
      'colors': colors,
      'inStock': inStock,
      'stock': stock,
    };
  }
}
