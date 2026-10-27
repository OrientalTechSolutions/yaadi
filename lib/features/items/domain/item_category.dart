/// What an item is about. Search and the bill rules key off it. Stored by
/// name, like every enum in the vault.
enum ItemCategory {
  electricity,
  gas,
  water,
  internet,
  phone,
  school,
  rent,
  health,
  idDocument,
  warranty,
  other;

  /// Utility bills change every month, and Pakistani utilities carry arrears
  /// into the next bill, so their amount is not copied forward. Rent, fees
  /// and instalments stay the same.
  bool get hasFixedAmountByDefault => switch (this) {
    electricity || gas || water || phone => false,
    _ => true,
  };
}
