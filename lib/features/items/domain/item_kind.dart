/// What sort of reminder an item is. Stored by name, so values may be
/// reordered freely but renaming one needs a migration.
enum ItemKind {
  bill,
  appointment,

  /// Something that runs out: a CNIC, a passport, a warranty.
  expiry,

  /// Times the user typed in. Yaadi never suggests a dose or a time.
  medicine,
  task;

  /// Only tasks may be undated.
  bool get requiresDate => this != task;
}
