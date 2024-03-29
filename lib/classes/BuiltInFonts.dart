class BuiltInFonts {
  static const List<String> fonts = [
    "Abril Fatface",
    "Alfa Slab One",
    "Arima Madurai",
    "Arvo",
    "Averia Serif Libre",
    "Bebas Neue",
    "Cardo",
    "Chonburi",
    "Cinzel",
    "Comfortaa",
    "Concert One",
    "Cormorant Garamond",
    "EB Garamond",
    "Fredoka One",
    "Gravitas One",
    "Libre Baskerville",
    "Limelight",
    "Lobster Two",
    "Lobster",
    "Lora",
    "Merriweather",
    "PT Serif",
    "Passion One",
    "Patua One",
    "Playfair Display",
    "Righteous",
    "Special Elite",
    "Staatliches",
    "Tinos",
    "Vollkorn",
  ];

  static final Set<String> _asSet = fonts.toSet();

  static bool lookup(String familyName) => _asSet.contains(familyName);
}
