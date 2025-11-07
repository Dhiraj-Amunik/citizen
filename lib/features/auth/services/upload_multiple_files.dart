class UploadMultipleFilesModel {
  String? message;
  int? responseCode;
  List<Files>? files;

  UploadMultipleFilesModel({this.message, this.responseCode, this.files});

  UploadMultipleFilesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    responseCode = json['responseCode'];
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(new Files.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['responseCode'] = this.responseCode;
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Files {
  String? imagePath1;
  String? imagePath;

  Files({this.imagePath1, this.imagePath});

  Files.fromJson(Map<String, dynamic> json) {
    imagePath1 = json['imagePath1'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imagePath1'] = this.imagePath1;
    data['imagePath'] = this.imagePath;
    return data;
  }
}
