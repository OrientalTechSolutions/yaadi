/// A made-up family the demo can show. Stored by name in settings.
enum DemoHousehold {
  /// Lahore: rupees, titles in English, Urdu and both.
  khan('PKR'),

  /// Manchester: pounds, titles in English.
  taylor('GBP');

  const DemoHousehold(this.currency);

  /// The household's money, which also decides whose billers search knows.
  final String currency;

  static DemoHousehold? byName(String? name) {
    for (final household in values) {
      if (household.name == name) return household;
    }
    return null;
  }
}
