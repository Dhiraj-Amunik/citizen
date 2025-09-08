class DonationRequestModel {
  final String amount;
  final String purpose;

  DonationRequestModel({required this.amount, required this.purpose});

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'purpose': purpose,
      'partyId': "68b446f6246f16da72eae64a",
    };
  }
}
