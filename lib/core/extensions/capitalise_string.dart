extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this; // Return empty string as is
    }
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
