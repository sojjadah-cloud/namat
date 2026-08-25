import 'package:flutter/material.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../l10n/app_localizations.dart';

/// One of the four worlds inside NAMAT.
///
/// A field is how a member thinks about their day, not how the database
/// groups rows: "I want to move" covers gyms, studios and classes, and nobody
/// distinguishes those at the moment of deciding.
enum NamatField {
  meals(NamatIcons.meals, NamatColors.food, NamatColors.foodSoft),
  fitness(NamatIcons.fitness, NamatColors.fitness, NamatColors.fitnessSoft),
  consult(NamatIcons.consultation, NamatColors.nutrition, NamatColors.nutritionSoft),
  stores(NamatIcons.store, NamatColors.products, NamatColors.productsSoft);

  const NamatField(this.icon, this.accent, this.tint);

  final NamatIcons icon;
  final Color accent;
  final Color tint;

  String title(L l) => switch (this) {
        NamatField.meals => l.fieldMeals,
        NamatField.fitness => l.fieldFitness,
        NamatField.consult => l.fieldConsult,
        NamatField.stores => l.fieldStores,
      };

  String subtitle(L l) => switch (this) {
        NamatField.meals => l.fieldMealsSub,
        NamatField.fitness => l.fieldFitnessSub,
        NamatField.consult => l.fieldConsultSub,
        NamatField.stores => l.fieldStoresSub,
      };

  String searchHint(L l) => switch (this) {
        NamatField.meals => l.searchMeals,
        NamatField.fitness => l.searchFitness,
        NamatField.consult => l.searchConsult,
        NamatField.stores => l.searchStores,
      };

  /// Filters differ per field on purpose. "High protein" is meaningless for a
  /// gym and "pickup" is meaningless for a consultation; one shared filter row
  /// is what makes a wellness app feel like a directory.
  List<String> filters(L l) => switch (this) {
        NamatField.meals => [
            l.filterNearest, l.filterTopRated, l.filterHighProtein,
            l.filterSubscriptions, l.filterDelivery, l.filterPickup,
          ],
        NamatField.fitness => [l.filterNearest, l.filterTopRated],
        NamatField.consult => [l.filterNearest, l.filterTopRated],
        NamatField.stores => [l.filterNearest, l.filterTopRated, l.filterDelivery],
      };

  static NamatField? byKey(String key) =>
      NamatField.values.where((f) => f.name == key).firstOrNull;
}
