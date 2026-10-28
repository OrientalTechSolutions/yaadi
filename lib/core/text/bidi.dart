/// Wraps [text] in a first-strong isolate (U+2068 ... U+2069), so an amount
/// or a biller name keeps its own direction inside a sentence in the other
/// direction, and cannot reorder the words around it.
String isolate(String text) => '\u2068$text\u2069';

/// U+00A0, which joins the words on either side into one unbreakable run.
const noBreakSpace = '\u00A0';

/// [text] with its spaces made unbreakable, for short runs such as "Sat,
/// Oct 31" that read badly split across lines at large text sizes.
String unbreakable(String text) => text.replaceAll(' ', noBreakSpace);
