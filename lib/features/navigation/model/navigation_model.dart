class NavigationModel {
  String? imagePath;
  String? text;

  NavigationModel({this.imagePath, this.text}) {
    assert(imagePath != null || text != null, "Icon or IconPath must be set");
  }
}
