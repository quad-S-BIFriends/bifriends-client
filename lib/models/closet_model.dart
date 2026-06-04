import '../config/api_config.dart';

class ClosetItem {
  final int id;
  final String name;
  final String category; // HAT, GLASSES, CLOTHES, BACKGROUND
  final String imageKey;
  final int price;
  final bool owned;

  const ClosetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageKey,
    this.price = 0,
    this.owned = false,
  });

  String get imageUrl {
    if (imageKey.startsWith('http')) return imageKey;
    return '${ApiConfig.baseUrl}/$imageKey';
  }

  factory ClosetItem.fromShopJson(Map<String, dynamic> json) => ClosetItem(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String,
    imageKey: json['imageKey'] as String,
    price: json['price'] as int? ?? 0,
    owned: json['owned'] as bool? ?? false,
  );

  factory ClosetItem.fromMyItemJson(Map<String, dynamic> json) => ClosetItem(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String,
    imageKey: json['imageKey'] as String,
    owned: true,
  );

  ClosetItem copyWith({bool? owned}) => ClosetItem(
    id: id,
    name: name,
    category: category,
    imageKey: imageKey,
    price: price,
    owned: owned ?? this.owned,
  );
}

class EquippedItems {
  final int? hatId;
  final int? glassesId;
  final int? clothesId;
  final int? backgroundId;

  const EquippedItems({
    this.hatId,
    this.glassesId,
    this.clothesId,
    this.backgroundId,
  });

  factory EquippedItems.fromJson(Map<String, dynamic> json) => EquippedItems(
    hatId: json['hatId'] as int?,
    glassesId: json['glassesId'] as int?,
    clothesId: json['clothesId'] as int?,
    backgroundId: json['backgroundId'] as int?,
  );

  bool isEquipped(int itemId) =>
      itemId == hatId ||
      itemId == glassesId ||
      itemId == clothesId ||
      itemId == backgroundId;

  int? equippedIdForCategory(String category) {
    switch (category) {
      case 'HAT':
        return hatId;
      case 'GLASSES':
        return glassesId;
      case 'CLOTHES':
        return clothesId;
      case 'BACKGROUND':
        return backgroundId;
      default:
        return null;
    }
  }

  EquippedItems clearCategory(String category) => EquippedItems(
    hatId: category == 'HAT' ? null : hatId,
    glassesId: category == 'GLASSES' ? null : glassesId,
    clothesId: category == 'CLOTHES' ? null : clothesId,
    backgroundId: category == 'BACKGROUND' ? null : backgroundId,
  );
}
