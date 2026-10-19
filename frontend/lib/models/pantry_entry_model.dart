import 'pantry_item_model.dart';

/// Uma linha da despensa do usuario: quantos pacotes de um item ele tem.
///
/// `quantity` e contagem de pacotes, sem unidade; quantidade 0 e representada
/// pela *ausencia* da linha, entao a quantidade de uma entrada e sempre >= 1.
class PantryEntry {
  final int id;
  final int itemId;
  final int quantity;
  final PantryItem item;

  PantryEntry({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.item,
  });

  factory PantryEntry.fromJson(Map<String, dynamic> json) {
    return PantryEntry(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      quantity: json['quantity'] as int,
      item: PantryItem.fromJson(json['item'] as Map<String, dynamic>),
    );
  }

  String get name => item.name;
  String get emoji => item.emoji;
  String get domain => item.domain;

  PantryEntry copyWith({int? quantity}) {
    return PantryEntry(
      id: id,
      itemId: itemId,
      quantity: quantity ?? this.quantity,
      item: item,
    );
  }
}

/// O resultado parcial devolvido por `PATCH /api/pantry`: ou a linha salva, ou
/// uma remocao (quantidade chegou a 0) reportada como
/// `{ removed: true, item_id }`.
class PantryQuantityResult {
  final PantryEntry? entry;
  final int? removedItemId;

  const PantryQuantityResult({this.entry, this.removedItemId});

  bool get isRemoved => removedItemId != null;
}
