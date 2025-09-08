class UploadProfilePicModel {
  String? message;
  int? responseCode;
  String? imagePath1;
  String? imagePath;

  UploadProfilePicModel(
      {this.message, this.responseCode, this.imagePath1, this.imagePath});

  UploadProfilePicModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    responseCode = json['responseCode'];
    imagePath1 = json['imagePath1'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['responseCode'] = this.responseCode;
    data['imagePath1'] = this.imagePath1;
    data['imagePath'] = this.imagePath;
    return data;
  }
}
