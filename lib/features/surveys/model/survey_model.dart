class SurveyModel {
  int? responseCode;
  String? message;
  Data? data;

  SurveyModel({this.responseCode, this.message, this.data});

  SurveyModel.fromJson(Map<String, dynamic> json) {
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
  int? totalSurvey;
  int? page;
  int? pageSize;
  List<Survey>? survey;

  Data({this.totalSurvey, this.page, this.pageSize, this.survey});

  Data.fromJson(Map<String, dynamic> json) {
    totalSurvey = json['totalSurvey'];
    page = json['page'];
    pageSize = json['pageSize'];
    if (json['survey'] != null) {
      survey = <Survey>[];
      json['survey'].forEach((v) {
        survey!.add(new Survey.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalSurvey'] = this.totalSurvey;
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    if (this.survey != null) {
      data['survey'] = this.survey!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Survey {
  String? sId;
  Mla? mla;
  String? assemblyConstituency;
  String? title;
  String? description;
  List<Questions>? questions;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? hasResponded;

  Survey({
    this.sId,
    this.mla,
    this.assemblyConstituency,
    this.title,
    this.description,
    this.questions,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.hasResponded,
  });

  Survey.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mla = json['mla'] != null ? new Mla.fromJson(json['mla']) : null;
    assemblyConstituency = json['assemblyConstituency'];
    title = json['title'];
    description = json['description'];
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(new Questions.fromJson(v, parentSurveyId: sId));
      });
    }
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    hasResponded = json['hasResponded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.mla != null) {
      data['mla'] = this.mla!.toJson();
    }
    data['assemblyConstituency'] = this.assemblyConstituency;
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.questions != null) {
      data['questions'] = this.questions!.map((v) => v.toJson()).toList();
    }
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['hasResponded'] = this.hasResponded;
    return data;
  }
}

class Mla {
  String? sId;
  User? user;

  Mla({this.sId, this.user});

  Mla.fromJson(Map<String, dynamic> json) {
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

  User({this.sId, this.name, this.email, this.phone});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Questions {
  String? text;
  String? type;
  List<String>? options;
  bool? isRequired;
  String? sId;
  String? surveyID;
  UserAnswer? userAnswer;

  Questions({
    this.text,
    this.type,
    this.options,
    this.isRequired,
    this.sId,
    this.surveyID,
    this.userAnswer,
  });

  Questions.fromJson(Map<String, dynamic> json, {String? parentSurveyId}) {
    text = json['text'];
    type = json['type'];
    options = json['options'].cast<String>();
    isRequired = json['isRequired'];
    sId = json['_id'];
    surveyID = parentSurveyId;
    userAnswer = json['userAnswer'] != null
        ? new UserAnswer.fromJson(json['userAnswer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['type'] = this.type;
    data['options'] = this.options;
    data['isRequired'] = this.isRequired;
    data['_id'] = this.sId;
    data['surveyID'] = this.surveyID;
    if (this.userAnswer != null) {
      data['userAnswer'] = this.userAnswer!.toJson();
    }
    return data;
  }
}

class UserAnswer {
  String? question;
  String? selectedOptions;
  String? descriptionAnswer;
  String? sId;

  UserAnswer({
    this.question,
    this.selectedOptions,
    this.descriptionAnswer,
    this.sId,
  });

  UserAnswer.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    selectedOptions = json['selectedOptions'];
    descriptionAnswer = json['descriptionAnswer'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question'] = this.question;
    data['selectedOptions'] = this.selectedOptions;
    data['descriptionAnswer'] = this.descriptionAnswer;
    data['_id'] = this.sId;
    return data;
  }
}
