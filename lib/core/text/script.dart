/// Letters and marks of the Arabic script, which Urdu is written in.
/// Arabic-Indic digits are left out: like ASCII digits they are neutral and
/// sit happily inside text of either direction.
bool isArabicScript(int rune) =>
    (rune >= 0x0600 && rune <= 0x06FF && !isArabicDigit(rune)) ||
    (rune >= 0x0750 && rune <= 0x077F) ||
    (rune >= 0x08A0 && rune <= 0x08FF) ||
    (rune >= 0xFB50 && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

/// Arabic-Indic (٠-٩) and Extended Arabic-Indic (۰-۹) digits.
bool isArabicDigit(int rune) =>
    (rune >= 0x0660 && rune <= 0x0669) || (rune >= 0x06F0 && rune <= 0x06F9);
