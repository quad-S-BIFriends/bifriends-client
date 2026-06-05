class ClosetItem {
  final String itemCode;
  final String name;
  final String category;
  final String imageKey;
  final int price;
  final bool owned;

  const ClosetItem({
    required this.itemCode,
    required this.name,
    required this.category,
    required this.imageKey,
    this.price = 0,
    this.owned = false,
  });

  static const _itemAssets = <String, String>{
    'OUTFIT_DEFAULT': 'assets/images/leo_default.png',
    'OUTFIT_STUDYING': 'assets/images/leo_studyhard.png',
    'GIFT_1': 'assets/images/leo_studying.png',
    'GIFT_2': 'assets/images/leo_ribbon.png',
    'GIFT_3': 'assets/images/leo_flower.png',
    'GIFT_4': 'assets/images/leo_sunglasses.png',
    'GIFT_5': 'assets/images/leo_dinosaur.png',
    'GIFT_6': 'assets/images/leo_scientist.png',
    'GIFT_7': 'assets/images/leo_singer.png',
  };

  String get localAssetPath =>
      _itemAssets[itemCode] ?? 'assets/images/leo_default.png';

  static String assetPathForCode(String? code) =>
      _itemAssets[code] ?? 'assets/images/leo_default.png';

  factory ClosetItem.fromShopJson(Map<String, dynamic> json) => ClosetItem(
    itemCode: json['itemCode'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    imageKey: json['imageKey'] as String,
    price: json['price'] as int? ?? 0,
    owned: json['owned'] as bool? ?? false,
  );

  factory ClosetItem.fromMyItemJson(Map<String, dynamic> json) => ClosetItem(
    itemCode: json['itemCode'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    imageKey: json['imageKey'] as String,
    owned: true,
  );

  ClosetItem copyWith({bool? owned}) => ClosetItem(
    itemCode: itemCode,
    name: name,
    category: category,
    imageKey: imageKey,
    price: price,
    owned: owned ?? this.owned,
  );
}

class EquippedItems {
  final String? outfitCode;

  const EquippedItems({this.outfitCode});

  factory EquippedItems.fromJson(Map<String, dynamic> json) => EquippedItems(
    outfitCode: json['outfitCode'] as String?,
  );

  bool isEquipped(String itemCode) => itemCode == outfitCode;

  EquippedItems clear() => const EquippedItems();
}
