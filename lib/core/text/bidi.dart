/// Wraps [text] in a first-strong isolate (U+2068 ... U+2069), so an amount
/// or a biller name keeps its own direction inside a sentence in the other
/// direction, and cannot reorder the words around it.
String isolate(String text) => '\u2068$text\u2069';
