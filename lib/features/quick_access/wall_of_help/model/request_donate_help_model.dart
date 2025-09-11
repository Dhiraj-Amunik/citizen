class RequestDonateHelpModel {
  final String? requestId;
  final int? amount;
  final String? paymentMethod;
  final String? transactionId;

  RequestDonateHelpModel({
    required this.requestId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }
}