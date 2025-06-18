/// Die Schwierigkeitsstufe bzw. Seltenheit eines Erfolgs oder einer Sammelkarte.
///
/// Die Stufen reichen von häufig (Holz) bis extrem selten (Galaktisch).
enum Schwierigkeit {
  /// Sehr häufig – niedrigste Stufe.
  Holz,

  /// Häufig – eine Stufe über Holz.
  Stein,

  /// Ungewöhnlich – niedrige Belohnung.
  Bronze,

  /// Mittelmäßig – Standardstufe für erkennbare Leistung.
  Silber,

  /// Selten – hohe Leistung.
  Gold,

  /// Extrem selten – phänomenale Leistung.
  Galaktisch,
}
