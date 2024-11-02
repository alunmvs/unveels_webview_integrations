enum ToneTab {
  matched,
  other,
}

extension ToneTabParsing on ToneTab {
  String get title {
    switch (this) {
      case ToneTab.matched:
        return 'Matched Shades';
      case ToneTab.other:
        return 'Other Shades';
    }
  }
}
