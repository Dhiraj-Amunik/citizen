class RequestFinancialHelpModel {
  final String? financialHelpRequestId;
  final String? name;
  final String? phone;
  final int? amountRequested;
  final String? urgency;
  final String? description;
  final List<String>? documents;
  final String? typeOfHelpId;
  final String? otherTypeOfHelp;
  final String? address;
  final String? upi;
  final String? preferredWayForHelpId;
  final String? otherPreferredWay;

  RequestFinancialHelpModel({
    this.financialHelpRequestId,
    this.name,
    this.phone,
    this.amountRequested,
    this.urgency,
    this.description,
    this.documents,
    this.typeOfHelpId,
    this.address,
    this.preferredWayForHelpId,
    this.otherPreferredWay,
    this.otherTypeOfHelp,
    this.upi,
  });

  Map<String, dynamic> toJson() {
    return {
      'financialHelpRequestId': financialHelpRequestId,
      'name': name,
      'phone': phone,
      'amountRequested': amountRequested,
      'urgency': urgency,
      'description': description,
      'documents': documents,
      'typeOfHelpId': typeOfHelpId,
      'othersTypeOfHelp': otherTypeOfHelp,
      'address': address,
      'preferredWayForHelpId': preferredWayForHelpId,
      'othersWayForHelp': otherPreferredWay,
      'UPI': upi,
    };
  }
}
