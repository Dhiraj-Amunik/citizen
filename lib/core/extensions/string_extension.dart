extension LocalizedStringExtension on String? {
  String  isNull(String text) {
    if (this == null || this!.trim().isEmpty) {
      return text;
    }
    return this!;
  }
}


extension BoolExtension on String? {
  bool get showDataNull {
    if (this == null || this!.trim().isEmpty) {
      return false;
    }
    return true;
  }
}