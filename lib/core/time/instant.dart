/// [time] in UTC, cut to whole milliseconds: exactly what the vault stores,
/// so a value reads back equal to what was written.
DateTime utcMillis(DateTime time) => DateTime.fromMillisecondsSinceEpoch(
  time.millisecondsSinceEpoch,
  isUtc: true,
);
