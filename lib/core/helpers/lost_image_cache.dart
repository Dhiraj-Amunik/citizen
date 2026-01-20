import 'package:image_picker/image_picker.dart';

/// Cache for recovered lost camera images
/// Used when Android kills the app while camera is open
class LostImageCache {
  LostImageCache._();
  static final instance = LostImageCache._();

  XFile? file;
  
  void clear() {
    file = null;
  }
}
