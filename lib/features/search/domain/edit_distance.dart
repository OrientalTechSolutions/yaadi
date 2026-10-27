/// Whether [a] becomes [b] with at most one insertion, deletion,
/// substitution or swap of two neighbouring characters: a
/// Damerau-Levenshtein distance of 0 or 1, checked in linear time.
bool withinOneEdit(String a, String b) {
  if (a == b) return true;
  final lengthA = a.length;
  final lengthB = b.length;
  if ((lengthA - lengthB).abs() > 1) return false;

  var i = 0;
  while (i < lengthA && i < lengthB && a.codeUnitAt(i) == b.codeUnitAt(i)) {
    i++;
  }

  if (lengthA == lengthB) {
    if (_sameTail(a, i + 1, b, i + 1)) return true;
    return i + 1 < lengthA &&
        a.codeUnitAt(i) == b.codeUnitAt(i + 1) &&
        a.codeUnitAt(i + 1) == b.codeUnitAt(i) &&
        _sameTail(a, i + 2, b, i + 2);
  }
  return lengthA < lengthB
      ? _sameTail(a, i, b, i + 1)
      : _sameTail(a, i + 1, b, i);
}

bool _sameTail(String a, int fromA, String b, int fromB) {
  if (a.length - fromA != b.length - fromB) return false;
  for (var i = 0; fromA + i < a.length; i++) {
    if (a.codeUnitAt(fromA + i) != b.codeUnitAt(fromB + i)) return false;
  }
  return true;
}
