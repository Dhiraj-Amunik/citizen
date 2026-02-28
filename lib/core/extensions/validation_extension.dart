import 'package:inldsevak/core/extensions/context_extension.dart';
import 'package:inldsevak/core/routes/routes.dart';

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

  // bool isValidUpiIdFormat() {
  //   // Basic format validation
  //   final RegExp upiRegex = RegExp(r"^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-]+$");

  //   // Common UPI provider patterns
  //   final RegExp providerRegex = RegExp(
  //     r"@(okicici|oksbi|okhdfc|okaxis|ybl|axl|paytm|ibl|ubi|idfcbank|indus|kotak|barodampay|rbl|yesbank|lvb|citi|freecharge|phonpe|upi)$",
  //     caseSensitive: false,
  //   );

  //   return upiRegex.hasMatch(this) && providerRegex.hasMatch(this);
  // }

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
    // Check if empty first
    if ((this).isEmpty) {
      if (argument != null) return argument;
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.please_check_your_contact_number;
        }
      } catch (_) {}
      return 'Please check you contact number';
    }
    // Check if length is less than 10
    if ((this).length < 10) {
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.please_provide_valid_10_digit_number;
        }
      } catch (_) {}
      return 'Please enter valid 10 digit number';
    }
    // Validate format when length is 10
    if ((this).length == 10) {
      if (RegExp(r'^[6-9][0-9]{9}$').hasMatch(this) == false) {
        if (argument != null) return argument;
        try {
          final context = RouteManager.navigatorKey.currentState?.context;
          if (context != null) {
            return context.localizations.please_check_your_contact_number;
          }
        } catch (_) {}
        return 'Please check you contact number';
      }
    }
    return null;
  }

  String? validateOTP(int length, {String? argument}) {
    if ((this).length != length) {
      if (argument != null) return argument;
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.please_check_your_otp;
        }
      } catch (_) {}
      return 'Please check you OTP';
    }
    return null;
  }

  String? validatePanCard({String? argument}) {
    if ((this).length != 10) {
      return argument;
    }
    return null;
  }

  String? validateUPI({String? argument}) {
    if ((this).isEmpty) {
      return argument;
    }
    // UPI ID must contain '@' and follow the format: localpart@provider
    final upiRegex = RegExp(r'^[a-zA-Z0-9._\-]+@[a-zA-Z0-9]+$');
    if (!upiRegex.hasMatch(this)) {
      return argument ?? 'Enter valid UPI ID';
    }
    return null;
  }

  String? validateAmount({String? argument, String? argument2}) {
    try {
      if ((this).isEmpty) {
        return argument;
      }
      final amount = int.parse(this);
      if (amount < 10) {
        return argument2 ?? argument;
      }
      return null;
    } catch (err) {
      return argument;
    }
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

  String? validatePincode({String? argument}) {
    if ((this).isEmpty) {
      return argument;
    }
    // Use tryParse to safely parse pincode - prevents FormatException
    final pincode = int.tryParse(this.trim());
    if (pincode == null) {
      // Invalid format - contains non-numeric characters
      return argument ?? "Please enter a valid 6-digit pincode";
    }
    // Check if pincode is exactly 6 digits
    if (this.trim().length != 6) {
      return argument ?? "Pincode must be 6 digits";
    }
    // Additional validation: pincode should be a valid range (100000 to 999999)
    if (pincode < 100000 || pincode > 999999) {
      return argument ?? "Please enter a valid 6-digit pincode";
    }
    return null;
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
      if (argument != null) return argument;
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.voter_id_cannot_be_empty;
        }
      } catch (_) {}
      return 'Voter ID cannot be empty';
    }

    if (!isValidVoterID) {
      if (argument != null) return argument;
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.invalid_voter_id;
        }
      } catch (_) {}
      return 'Invalid Voter ID.';
    }

    return null;
  }

  // Additional validation method with detailed error feedback
  String? validateAadhar({String? argument}) {
    if (isEmpty) {
      if (argument != null) return argument;
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.aadhar_no_cannot_be_empty;
        }
      } catch (_) {}
      return 'Aadhar No cannot be empty';
    }

    if (!isValidAadharNumber()) {
      try {
        final context = RouteManager.navigatorKey.currentState?.context;
        if (context != null) {
          return context.localizations.invalid_aadhar_id;
        }
      } catch (_) {}
      return 'Invalid Aadhar ID.';
    }

    return null;
  }
}
