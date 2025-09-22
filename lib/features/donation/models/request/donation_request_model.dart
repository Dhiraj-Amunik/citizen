class DonationRequestModel {
  final String amount;
  // final String? purpose;

  DonationRequestModel({
    required this.amount,
    // required this.purpose
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      // 'purpose': purpose,
    };
  }
}
