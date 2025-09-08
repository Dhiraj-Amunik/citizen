class WallOfHelpModel {
  int? responseCode;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  WallOfHelpModel(
      {this.responseCode, this.message, this.data, this.pagination});

  WallOfHelpModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  User? user;
  String? subject;
  String? reason;
  int? amountRequested;
  String? additionalDetails;
  Party? party;
  Party? constituency;
  List<Documents>? documents;
  String? status;
  bool? isActive;
  bool? isDeleted;
  int? amountCollected;
  List<Transactions>? transactions;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.user,
      this.subject,
      this.reason,
      this.amountRequested,
      this.additionalDetails,
      this.party,
      this.constituency,
      this.documents,
      this.status,
      this.isActive,
      this.isDeleted,
      this.amountCollected,
      this.transactions,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    subject = json['subject'];
    reason = json['reason'];
    amountRequested = json['amountRequested'];
    additionalDetails = json['additionalDetails'];
    party = json['party'] != null ? new Party.fromJson(json['party']) : null;
    constituency = json['constituency'] != null
        ? new Party.fromJson(json['constituency'])
        : null;
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
    status = json['status'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    amountCollected = json['amountCollected'];
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(new Transactions.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['subject'] = this.subject;
    data['reason'] = this.reason;
    data['amountRequested'] = this.amountRequested;
    data['additionalDetails'] = this.additionalDetails;
    if (this.party != null) {
      data['party'] = this.party!.toJson();
    }
    if (this.constituency != null) {
      data['constituency'] = this.constituency!.toJson();
    }
    if (this.documents != null) {
      data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['amountCollected'] = this.amountCollected;
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;

  User({this.sId, this.name, this.email});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}

class Party {
  String? sId;
  String? name;

  Party({this.sId, this.name});

  Party.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class Documents {
  String? fileName;
  String? fileUrl;
  String? sId;
  String? uploadedAt;

  Documents({this.fileName, this.fileUrl, this.sId, this.uploadedAt});

  Documents.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileUrl = json['fileUrl'];
    sId = json['_id'];
    uploadedAt = json['uploadedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['fileUrl'] = this.fileUrl;
    data['_id'] = this.sId;
    data['uploadedAt'] = this.uploadedAt;
    return data;
  }
}

class Transactions {
  String? donor;
  String? donorModel;
  int? amount;
  String? paymentMethod;
  String? transactionId;
  String? sId;
  String? donatedAt;

  Transactions(
      {this.donor,
      this.donorModel,
      this.amount,
      this.paymentMethod,
      this.transactionId,
      this.sId,
      this.donatedAt});

  Transactions.fromJson(Map<String, dynamic> json) {
    donor = json['donor'];
    donorModel = json['donorModel'];
    amount = json['amount'];
    paymentMethod = json['paymentMethod'];
    transactionId = json['transactionId'];
    sId = json['_id'];
    donatedAt = json['donatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['donor'] = this.donor;
    data['donorModel'] = this.donorModel;
    data['amount'] = this.amount;
    data['paymentMethod'] = this.paymentMethod;
    data['transactionId'] = this.transactionId;
    data['_id'] = this.sId;
    data['donatedAt'] = this.donatedAt;
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    return data;
  }
}
