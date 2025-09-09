class PartyMemberRequestModel {
  final String? phone;
  final String? userName;
  final String? parentName;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? constituencyId;
  final String? partyId;
  final List<Document?>? documents;
  final String? reason;
  final String? preferredRole;

  PartyMemberRequestModel({
     this.phone,
     this.userName,
     this.parentName,
     this.dateOfBirth,
     this.gender,
     this.maritalStatus,
     this.constituencyId,
     this.partyId,
     this.documents,
     this.reason,
     this.preferredRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'userName': userName,
      'parentName': parentName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'constituencyId': constituencyId,
      'partyId': partyId,
      'document': documents?.map((doc) => doc?.toJson()).toList(),
      'reason': reason,
      'preferredRole': preferredRole,
    };
  }
}

class Document {
  final String? documentType;
  final String? documentUrl;
  final String? documentNumber;

  Document({
     this.documentType,
     this.documentUrl,
     this.documentNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'documentNumber': documentNumber,
    };
  }
}
