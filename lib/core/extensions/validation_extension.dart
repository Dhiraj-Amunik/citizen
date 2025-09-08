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
    return RegExp(r'^[2-9][0-9]{3}\s[0-9]{4}\s[0-9]{4}$').hasMatch(this);
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



  String? validateDropDown({String? argument}) {
    if (this == 'null') {
      return argument;
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
    if ((this).length != 10) {
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
}
