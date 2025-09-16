class RequestPincodeModel {
  final String? pincode;
  const RequestPincodeModel({required this.pincode});
  Map<String, dynamic> toJson() {
    return {'pincode': pincode};
  }
}
