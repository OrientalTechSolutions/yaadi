import 'package:meta/meta.dart';

import '../../items/domain/item_category.dart';
import '../../items/domain/item_kind.dart';
import 'region.dart';

enum ConceptType { category, kind, biller, alias }

/// Something a household word means, whichever script and spelling it is
/// written in: a category (bijli, بجلی, electricity), a kind of item (dawai,
/// دوا, medicine), a company that bills for a category (LESCO), or an alias
/// that links the spellings of one word (ammi, امی, mum).
@immutable
final class Concept {
  const Concept.category(ItemCategory this.category, this._terms, {this.region})
    : type = ConceptType.category,
      kind = null,
      name = null;

  const Concept.kind(ItemKind this.kind, this._terms)
    : type = ConceptType.kind,
      category = null,
      name = null,
      region = null;

  /// A company that bills for [category], found by its [name] and any
  /// other spellings in [alsoWritten]. An item that names it is tagged with
  /// the category too, so "bijli" finds a LESCO bill; a search for "lesco"
  /// looks for LESCO only, never for IESCO or PESCO.
  const Concept.biller(
    String this.name,
    ItemCategory this.category, {
    required Region this.region,
    List<String> alsoWritten = const [],
  }) : _terms = alsoWritten,
       type = ConceptType.biller,
       kind = null;

  const Concept.alias(String this.name, this._terms, {this.region})
    : type = ConceptType.alias,
      category = null,
      kind = null;

  final ConceptType type;
  final ItemCategory? category;
  final ItemKind? kind;
  final String? name;

  /// Null for language words; set for names that belong to one country.
  final Region? region;

  final List<String> _terms;

  /// Natural spellings, up to three words each. They pass through the
  /// search normalizer once, when the lexicon is built.
  List<String> get terms => [if (type == ConceptType.biller) name!, ..._terms];

  /// What a search that names this concept looks for.
  String get id => switch (type) {
    ConceptType.category => categoryId(category!),
    ConceptType.kind => kindId(kind!),
    ConceptType.biller => 'biller:$name',
    ConceptType.alias => 'alias:$name',
  };

  /// What an item whose text names this concept is tagged with.
  Set<String> get itemTags => {
    id,
    if (type == ConceptType.biller) categoryId(category!),
  };

  bool appliesIn(Region active) => region == null || region == active;

  static String categoryId(ItemCategory category) =>
      'category:${category.name}';

  static String kindId(ItemKind kind) => 'kind:${kind.name}';

  @override
  String toString() => 'Concept($id)';
}
