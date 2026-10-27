/// The country whose proper nouns search understands. Language words such
/// as bijli or بجلی apply everywhere; company names apply only at home, so
/// "Tesco" in a Manchester household is a shop, not an electricity company.
enum Region {
  pk,
  uk,
  us;

  /// Pakistan unless the household counts in pounds or dollars.
  static Region forCurrency(String code) => switch (code) {
    'GBP' => uk,
    'USD' => us,
    _ => pk,
  };
}
