class ErrorModel {
  String? message;
  String? error;

  ErrorModel({this.message, this.error});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    // If message is generic but error has details, use error as message
    if ((message == null || message!.isEmpty || message == "Server Error: The server encountered an error.") && error != null && error!.isNotEmpty) {
      message = error;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['error'] = error;
    return data;
  }
}
