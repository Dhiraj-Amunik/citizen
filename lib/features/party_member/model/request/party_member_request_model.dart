class PartyMemberRequestModel {
  final String phone;
  final String? userName;
  final String? parentName;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String parliamentaryConstituencyId;
  final String assemblyConstituenciesID;
  final List<Document?>? documents;
  final List<String?>? images;
  final String? reason;

  PartyMemberRequestModel({
    required this.phone,
    this.userName,
    this.parentName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    required this.parliamentaryConstituencyId,
    required this.assemblyConstituenciesID,
    this.documents,
    this.reason,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': "",
      'userName': userName,
      'parentName': parentName,
      'dateOfBirth': dateOfBirth,
      'gender': gender?.toLowerCase(),
      'maritalStatus': maritalStatus?.toLowerCase(),
      'parliamentaryConstituencyId': parliamentaryConstituencyId,
      'assemblyConstituencyId': assemblyConstituenciesID,
      'document': documents?.map((doc) => doc?.toJson()).toList(),
      'reason': reason,
      'images':images
    };
  }
}

class Document {
  final String? documentType;
  final String? documentUrl;
  final String? documentNumber;

  Document({this.documentType, this.documentUrl, this.documentNumber});

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'documentNumber': documentNumber,
    };
  }
}
