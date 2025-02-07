extension Comparison on String {
  bool isEqual(String value, {bool caseSensitive = false}) {
    if (caseSensitive) {
      return this == value;
    }
    else {
      return toUpperCase() == value.toUpperCase();
    }
  }
}