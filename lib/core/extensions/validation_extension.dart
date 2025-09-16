import 'dart:developer';

extension ExtendedString on String {
  bool get isValidEmail {
    const emailRegex =
        r"^[a-z0-9!#$%&'*+\=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$";
    return RegExp(
      emailRegex,
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 6;
  }

  bool isValidAadharNumber() {
    String? value = (this).replaceAll(" ", '');
    return RegExp(r'^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}$').hasMatch(value);
  }

  bool isStrongPassword1(String password) {
    // Define the criteria for a strong password
    final RegExp hasUppercase = RegExp(r'[A-Z]');
    final RegExp hasLowercase = RegExp(r'[a-z]');
    final RegExp hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    // Check if the password meets the criteria
    return hasUppercase.hasMatch(password) &&
        hasLowercase.hasMatch(password) &&
        hasSpecialCharacters.hasMatch(password);
  }

  bool isStrongPassword(String password) {
    bool minLength = password.length >= 8;
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    bool hasNumber = RegExp(r'\d').hasMatch(password);
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);

    return minLength && hasSpecialChar && hasNumber && hasUppercase;
  }

  bool get isValidPhoneNumber {
    return length == 10;
  }

  //converting string to integer
  int get convertToInt {
    return int.parse(this);
  }

  String? validate({String? argument}) {
    if ((this).isEmpty) {
      return argument;
    }
    return null;
  }

  String? validateName({String? argument}) {
    if ((this).isEmpty) {
      return argument;
    }
    if ((this).length <= 2 || RegExp(r'\d').hasMatch(this)) {
      return argument;
    }
    return null;
  }

  String? validateDropDown({String? argument}) {
    if (this == 'null') {
      return "        $argument";
    }
    return null;
  }

  String? validateEmail({String? argument}) {
    if (!(this).isValidEmail) {
      return argument;
    }
    return null;
  }

  String? validatePassword({String? text}) {
    if (text == null || text.isEmpty) {
      return 'Please enter a password';
    } else if (text.length < 8) {
      return 'Please enter min 8 digit';
    }
    return null;
  }

  String? validateNumber({String? argument}) {
    if ((this).length != 10 || RegExp(r'^[6-9][0-9]{9}$').hasMatch(this) == false) {
      return argument ?? 'Please check you contact number';
    }
    return null;
  }

  String? validateOTP(int length, {String? argument}) {
    if ((this).length != length) {
      return argument ?? 'Please check you OTP';
    }
    return null;
  }

  String? validatePanCard({String? argument}) {
    if ((this).length != 10) {
      return argument;
    }
    return null;
  }

  String? validateAmount({String? argument}) {
    if ((this).isEmpty) {
      return argument;
    }
    final amount = int.parse(this);
    if (amount < 10) {
      return argument;
    }
    return null;
  }

  String? validateMaxAmount(
    int maxAmount, {
    String? argument,
    String? argument2,
  }) {
    try {
      if ((this).isEmpty) {
        return argument;
      }
      final amount = int.parse(this);
      if (amount < 10) {
        return argument;
      }
      if (maxAmount < amount) {
        return argument2;
      }
      return null;
    } catch (err) {
      return argument;
    }
  }

  //voter id validator

  bool get isValidVoterID {
    // Voter ID format: 3 letters followed by 7 digits (e.g., ABC1234567)
    final voterIdRegex = r'^[A-Z]{3}[0-9]{7}$';
    return RegExp(voterIdRegex, caseSensitive: true).hasMatch(this);
  }

  // Additional validation method with detailed error feedback
  String? validateVoterID({String? argument}) {
    if (isEmpty) {
      return argument ?? 'Voter ID cannot be empty';
    }

    if (!isValidVoterID) {
      return argument ?? 'Invalid Voter ID.';
    }

    return null;
  }

  // Additional validation method with detailed error feedback
  String? validateAadhar({String? argument}) {
    if (isEmpty) {
      return argument ?? 'Aadhar No cannot be empty';
    }

    if (!isValidAadharNumber()) {
      return 'Invalid Aadhar ID.';
    }

    return null;
  }
}
