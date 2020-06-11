namespace RemObjects.Elements.RTL;

type
  Unicode = assembly class
  assembly

    const IsWhiteSpaceFlag = $80;
    const IsUpperCaseLetterFlag = $40;
    const IsLowerCaseLetterFlag = $20;
    const UnicodeCategoryMask = $1F;

    // Contains information about the C0, Basic Latin, C1, and Latin-1 Supplement ranges [ U+0000..U+00FF ], with:
    // - $80 bit if set means 'is whitespace'
    // - $40 bit if set means 'is uppercase letter'
    // - $20 bit if set means 'is lowercase letter'
    // - bottom 5 bits are the UnicodeCategory of the character
    //
    // n.b. This data is locked to an earlier version of the Unicode standard (2.0, perhaps?), so
    // the UnicodeCategory data contained here doesn't necessarily reflect the UnicodeCategory data
    // contained within the CharUnicodeInfo or Rune types, which generally follow the latest Unicode
    // standard.
    const Latin1CharInfo: array of Byte =
    [
        $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $8E, $8E, $8E, $8E, $8E, $0E, $0E, // U+0000..U+000F
        $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, // U+0010..U+001F
        $8B, $18, $18, $18, $1A, $18, $18, $18, $14, $15, $18, $19, $18, $13, $18, $18, // U+0020..U+002F
        $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $18, $18, $19, $19, $19, $18, // U+0030..U+003F
        $18, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, // U+0040..U+004F
        $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $14, $18, $15, $1B, $12, // U+0050..U+005F
        $1B, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, // U+0060..U+006F
        $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $14, $19, $15, $19, $0E, // U+0070..U+007F
        $0E, $0E, $0E, $0E, $0E, $8E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, // U+0080..U+008F
        $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, // U+0090..U+009F
        $8B, $18, $1A, $1A, $1A, $1A, $1C, $1C, $1B, $1C, $21, $16, $19, $13, $1C, $1B, // U+00A0..U+00AF
        $1C, $19, $0A, $0A, $1B, $21, $1C, $18, $1B, $0A, $21, $17, $0A, $0A, $0A, $18, // U+00B0..U+00BF
        $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, // U+00C0..U+00CF
        $40, $40, $40, $40, $40, $40, $40, $19, $40, $40, $40, $40, $40, $40, $40, $21, // U+00D0..U+00DF
        $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, // U+00E0..U+00EF
        $21, $21, $21, $21, $21, $21, $21, $19, $21, $21, $21, $21, $21, $21, $21, $21, // U+00F0..U+00FF
    ];

  end;

end.