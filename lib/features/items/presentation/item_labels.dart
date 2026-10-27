import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/item_category.dart';
import '../domain/item_kind.dart';

extension ItemLabels on AppLocalizations {
  String kindLabel(ItemKind kind) => switch (kind) {
    ItemKind.bill => kindBill,
    ItemKind.appointment => kindAppointment,
    ItemKind.expiry => kindExpiry,
    ItemKind.medicine => kindMedicine,
    ItemKind.task => kindTask,
  };

  String categoryLabel(ItemCategory category) => switch (category) {
    ItemCategory.electricity => categoryElectricity,
    ItemCategory.gas => categoryGas,
    ItemCategory.water => categoryWater,
    ItemCategory.internet => categoryInternet,
    ItemCategory.phone => categoryPhone,
    ItemCategory.school => categorySchool,
    ItemCategory.rent => categoryRent,
    ItemCategory.health => categoryHealth,
    ItemCategory.idDocument => categoryIdDocument,
    ItemCategory.warranty => categoryWarranty,
    ItemCategory.other => categoryOther,
  };
}

IconData kindIcon(ItemKind kind) => switch (kind) {
  ItemKind.bill => Icons.receipt_long_outlined,
  ItemKind.appointment => Icons.event_outlined,
  ItemKind.expiry => Icons.badge_outlined,
  ItemKind.medicine => Icons.medication_outlined,
  ItemKind.task => Icons.task_alt_outlined,
};
