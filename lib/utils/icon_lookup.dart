import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Every icon used by the 15 default categories, plus a small curated set of
/// extra choices offered when a user creates a custom category.
const Map<String, IconData> kIconLookup = {
  'restaurant': Symbols.restaurant,
  'directions_bus': Symbols.directions_bus,
  'shopping_bag': Symbols.shopping_bag,
  'receipt_long': Symbols.receipt_long,
  'movie': Symbols.movie,
  'ecg_heart': Symbols.ecg_heart,
  'flight': Symbols.flight,
  'school': Symbols.school,
  'home_work': Symbols.home_work,
  'category': Symbols.category,
  'payments': Symbols.payments,
  'work': Symbols.work,
  'redeem': Symbols.redeem,
  'card_giftcard': Symbols.card_giftcard,
  'savings': Symbols.savings,
  'pets': Symbols.pets,
  'sports_esports': Symbols.sports_esports,
  'local_cafe': Symbols.local_cafe,
  'fitness_center': Symbols.fitness_center,
  'checkroom': Symbols.checkroom,
};

IconData symbolFor(String name) => kIconLookup[name] ?? Symbols.category;
