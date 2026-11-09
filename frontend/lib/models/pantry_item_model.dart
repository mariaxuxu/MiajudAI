/// Um item do catalogo: uma entrada de produto global, extensivel por qualquer
/// usuario.
///
/// Itens carregam um emoji em vez de uma imagem — a feature nao tem upload,
/// storage nem serving de binario em lugar nenhum. [domain] e `food` (Cozinha)
/// ou `domestic` (Domestico), o mesmo vocabulario das tags do diario.
class PantryItem {
  final int id;
  final String name;
  final String emoji;
  final String domain;

  PantryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.domain,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      domain: json['domain'] as String? ?? PantryDomain.food.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'emoji': emoji, 'domain': domain};
  }
}

/// Os dois dominios a que um item pode pertencer. Espelha `PANTRY_DOMAINS` do
/// backend (`food` / `domestic`): [value] e o valor de rede e [label] o titulo
/// da secao na UI.
enum PantryDomain {
  food(value: 'food', label: 'Cozinha'),
  domestic(value: 'domestic', label: 'Doméstico');

  const PantryDomain({required this.value, required this.label});

  final String value;
  final String label;

  /// O dominio de um item, pelo valor que veio da API. Um valor desconhecido
  /// cai em [food] — o catalogo so produz `food` ou `domestic`.
  static PantryDomain of(String value) => values.firstWhere(
        (domain) => domain.value == value,
        orElse: () => food,
      );
}
