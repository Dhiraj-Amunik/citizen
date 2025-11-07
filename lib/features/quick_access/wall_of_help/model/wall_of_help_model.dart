class WallOfHelpModel {
  int? responseCode;
  String? message;
  Data? data;

  WallOfHelpModel({this.responseCode, this.message, this.data});

  WallOfHelpModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? totalFinancialHelpRequest;
  int? page;
  int? pageSize;
  List<FinancialRequest>? financialRequest;

  Data(
      {this.totalFinancialHelpRequest,
      this.page,
      this.pageSize,
      this.financialRequest});

  Data.fromJson(Map<String, dynamic> json) {
    totalFinancialHelpRequest = json['totalFinancialHelpRequest'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['financialRequest'] != null) {
      financialRequest = <FinancialRequest>[];
      json['financialRequest'].forEach((v) {
        financialRequest!.add(new FinancialRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalFinancialHelpRequest'] = this.totalFinancialHelpRequest;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.financialRequest != null) {
      data['financialRequest'] =
          this.financialRequest!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FinancialRequest {
  String? sId;
  PartyMember? partyMember;
  String? name;
  String? phone;
  int? amountRequested;
  String? urgency;
  String? description;
  List<String>? documents;
  String? status;
  bool? isActive;
  bool? isDeleted;
  int? amountCollected;
  String? address;
  String? uPI;
  TypeOfHelp? typeOfHelp;
  TypeOfHelp? preferredWayForHelp;
  String? othersWayForHelp;
  String? othersTypeOfHelp;
  List<Transactions>? transactions;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<MessageDetails>? messageDetails;
  String? messageId;
  String? title;

  FinancialRequest(
      {this.sId,
      this.partyMember,
      this.name,
      this.phone,
      this.amountRequested,
      this.urgency,
      this.description,
      this.documents,
      this.status,
      this.isActive,
      this.isDeleted,
      this.amountCollected,
      this.address,
      this.uPI,
      this.typeOfHelp,
      this.preferredWayForHelp,
      this.othersWayForHelp,
      this.othersTypeOfHelp,
      this.transactions,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.messageDetails,
      this.messageId,
      this.title});

  FinancialRequest.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    partyMember = json['partyMember'] != null
        ? new PartyMember.fromJson(json['partyMember'])
        : null;
    name = json['name'];
    phone = json['phone'];
    amountRequested = json['amountRequested'];
    urgency = json['urgency'];
    description = json['description'];
     documents = json['documents'] != null
        ? json['documents'].cast<String>()
        : [];
    status = json['status'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    amountCollected = json['amountCollected'];
    address = json['address'];
    uPI = json['UPI'];
    typeOfHelp = json['typeOfHelp'] != null
        ? new TypeOfHelp.fromJson(json['typeOfHelp'])
        : null;
    preferredWayForHelp = json['preferredWayForHelp'] != null
        ? new TypeOfHelp.fromJson(json['preferredWayForHelp'])
        : null;
    othersWayForHelp = json['othersWayForHelp'];
    othersTypeOfHelp = json['othersTypeOfHelp'];
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(new Transactions.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['messageDetails'] != null) {
      messageDetails = <MessageDetails>[];
      json['messageDetails'].forEach((v) {
        messageDetails!.add(new MessageDetails.fromJson(v));
      });
    }
    messageId = json['messageId'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.partyMember != null) {
      data['partyMember'] = this.partyMember!.toJson();
    }
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['amountRequested'] = this.amountRequested;
    data['urgency'] = this.urgency;
    data['description'] = this.description;
    data['documents'] = this.documents;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['amountCollected'] = this.amountCollected;
    data['address'] = this.address;
    data['UPI'] = this.uPI;
    if (this.typeOfHelp != null) {
      data['typeOfHelp'] = this.typeOfHelp!.toJson();
    }
    if (this.preferredWayForHelp != null) {
      data['preferredWayForHelp'] = this.preferredWayForHelp!.toJson();
    }
    data['othersWayForHelp'] = this.othersWayForHelp;
    data['othersTypeOfHelp'] = this.othersTypeOfHelp;
    if (this.transactions != null) {
      data['transactions'] = this.transactions!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.messageDetails != null) {
      data['messageDetails'] =
          this.messageDetails!.map((v) => v.toJson()).toList();
    }
    data['messageId'] = this.messageId;
    data['title'] = this.title;
    return data;
  }
}

class PartyMember {
  String? sId;
  User? user;

  PartyMember({this.sId, this.user});

  PartyMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? phone;
  String? avatar;

  User({this.sId, this.name, this.email, this.phone, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    return data;
  }
}

class TypeOfHelp {
  String? sId;
  String? name;

  TypeOfHelp({this.sId, this.name});

  TypeOfHelp.fromJson(Map<String, dynamic> json) {
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

class Transactions {
  String? donor;
  String? donorModel;
  int? amount;
  String? donatedAt;
  String? paymentMethod;
  String? transactionId;
  String? sId;

  Transactions(
      {this.donor,
      this.donorModel,
      this.amount,
      this.donatedAt,
      this.paymentMethod,
      this.transactionId,
      this.sId});

  Transactions.fromJson(Map<String, dynamic> json) {
    donor = json['donor'];
    donorModel = json['donorModel'];
    amount = json['amount'];
    donatedAt = json['donatedAt'];
    paymentMethod = json['paymentMethod'];
    transactionId = json['transactionId'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['donor'] = this.donor;
    data['donorModel'] = this.donorModel;
    data['amount'] = this.amount;
    data['donatedAt'] = this.donatedAt;
    data['paymentMethod'] = this.paymentMethod;
    data['transactionId'] = this.transactionId;
    data['_id'] = this.sId;
    return data;
  }
}

class MessageDetails {
  String? messageId;
  PartyMember? relatedDetails;

  MessageDetails({this.messageId, this.relatedDetails});

  MessageDetails.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    relatedDetails = json['relatedDetails'] != null
        ? new PartyMember.fromJson(json['relatedDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    if (this.relatedDetails != null) {
      data['relatedDetails'] = this.relatedDetails!.toJson();
    }
    return data;
  }
}

