import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @login_or_signup.
  ///
  /// In en, this message translates to:
  /// **'Login Or Signup'**
  String get login_or_signup;

  /// No description provided for @hello_welcome_to_your_account.
  ///
  /// In en, this message translates to:
  /// **'Hello, welcome to your account'**
  String get hello_welcome_to_your_account;

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile_number;

  /// No description provided for @enter_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enter_mobile_number;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send Otp'**
  String get send_otp;

  /// No description provided for @by_continuing_u_agree_to_our.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get by_continuing_u_agree_to_our;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @terms_of_services.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_services;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enter_otp;

  /// No description provided for @otp_description.
  ///
  /// In en, this message translates to:
  /// **'Enter 4 - digit verification code sent to your mobile number.'**
  String get otp_description;

  /// No description provided for @resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Resend Otp'**
  String get resend_otp;

  /// No description provided for @change_your_phone_no.
  ///
  /// In en, this message translates to:
  /// **'Change your Phone No ? '**
  String get change_your_phone_no;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verify_otp;

  /// No description provided for @complete_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get complete_your_profile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get name_validator;

  /// No description provided for @father_name.
  ///
  /// In en, this message translates to:
  /// **'Father Name'**
  String get father_name;

  /// No description provided for @father_name_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your father name'**
  String get father_name_validator;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enter_email;

  /// No description provided for @email_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mail'**
  String get email_validator;

  /// No description provided for @date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get date_of_birth;

  /// No description provided for @date_of_birth_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select your birthday'**
  String get date_of_birth_validator;

  /// No description provided for @dd_mm_yyyy.
  ///
  /// In en, this message translates to:
  /// **'DD-MM-YYYY'**
  String get dd_mm_yyyy;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get select_gender;

  /// No description provided for @gender_validator.
  ///
  /// In en, this message translates to:
  /// **'Select your Gender'**
  String get gender_validator;

  /// No description provided for @aadhaar_no.
  ///
  /// In en, this message translates to:
  /// **'Aadhar No'**
  String get aadhaar_no;

  /// No description provided for @aadhar_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your aadhar number'**
  String get aadhar_validator;

  /// No description provided for @voter_id.
  ///
  /// In en, this message translates to:
  /// **'Voter Id'**
  String get voter_id;

  /// No description provided for @voter_id_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your voter id number'**
  String get voter_id_validator;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @city_village.
  ///
  /// In en, this message translates to:
  /// **'City / Village'**
  String get city_village;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @pincode_6_digits.
  ///
  /// In en, this message translates to:
  /// **'6 digits'**
  String get pincode_6_digits;

  /// No description provided for @upload_aadhar.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhar'**
  String get upload_aadhar;

  /// No description provided for @upload_voter_id.
  ///
  /// In en, this message translates to:
  /// **'Upload Voter Id'**
  String get upload_voter_id;

  /// No description provided for @whatapp_no.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp No'**
  String get whatapp_no;

  /// No description provided for @contribute_with_love.
  ///
  /// In en, this message translates to:
  /// **'Contribute with love'**
  String get contribute_with_love;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donate_for.
  ///
  /// In en, this message translates to:
  /// **'Donation For'**
  String get donate_for;

  /// No description provided for @donate_for_description.
  ///
  /// In en, this message translates to:
  /// **'Your support, in any form, will help us create wonderful memories at this party. More importantly, your contribution goes beyond celebration - it becomes a source of hope for those in need. Every donation you make will be directed toward helping underprivileged citizens and supporting community welfare initiatives. Whether it is providing essential resources, medical assistance, or financial aid, your kindness will make a meaningful difference in someone’s life. By standing with us, you are not just donating - you are joining hands in building a stronger, more caring society. Together, we can ensure that joy is shared with everyone, especially those who need it most.'**
  String get donate_for_description;

  /// No description provided for @donation_history.
  ///
  /// In en, this message translates to:
  /// **'Donate History'**
  String get donation_history;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enter_amount;

  /// No description provided for @select_payment_options.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Options'**
  String get select_payment_options;

  /// No description provided for @razorpay.
  ///
  /// In en, this message translates to:
  /// **'Razorpay'**
  String get razorpay;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @net_banking.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get net_banking;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @become_part_mem.
  ///
  /// In en, this message translates to:
  /// **'Become a Party Member'**
  String get become_part_mem;

  /// No description provided for @party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get party;

  /// No description provided for @select_yout_party.
  ///
  /// In en, this message translates to:
  /// **'Select your party'**
  String get select_yout_party;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @enter_your_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enter_your_full_name;

  /// No description provided for @parents_name.
  ///
  /// In en, this message translates to:
  /// **'Father\'s / Mother\'s Name'**
  String get parents_name;

  /// No description provided for @enter_parent_name.
  ///
  /// In en, this message translates to:
  /// **'Enter parent name'**
  String get enter_parent_name;

  /// No description provided for @marital_status.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get marital_status;

  /// No description provided for @select_status.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get select_status;

  /// No description provided for @constituency.
  ///
  /// In en, this message translates to:
  /// **'Constituency'**
  String get constituency;

  /// No description provided for @assembly_constituency.
  ///
  /// In en, this message translates to:
  /// **'Assembly Constituency'**
  String get assembly_constituency;

  /// No description provided for @parliamentary_constituency.
  ///
  /// In en, this message translates to:
  /// **'Parliamentary Constituency'**
  String get parliamentary_constituency;

  /// No description provided for @select_your_constituency.
  ///
  /// In en, this message translates to:
  /// **'Select your constituency'**
  String get select_your_constituency;

  /// No description provided for @photography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get photography;

  /// No description provided for @click_to_upload_images.
  ///
  /// In en, this message translates to:
  /// **'Click to upload photography'**
  String get click_to_upload_images;

  /// No description provided for @max_file_size.
  ///
  /// In en, this message translates to:
  /// **'Max file size : 5MB'**
  String get max_file_size;

  /// No description provided for @reason_for_joining_party.
  ///
  /// In en, this message translates to:
  /// **'Reason for joining party'**
  String get reason_for_joining_party;

  /// No description provided for @explain_why_join_party.
  ///
  /// In en, this message translates to:
  /// **'Explain why you want to join our party( max 150 characters )'**
  String get explain_why_join_party;

  /// No description provided for @preferred_role.
  ///
  /// In en, this message translates to:
  /// **'Preferred Role(If applicable)'**
  String get preferred_role;

  /// No description provided for @enter_your_role.
  ///
  /// In en, this message translates to:
  /// **'Enter your role'**
  String get enter_your_role;

  /// No description provided for @submit_application.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submit_application;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @upcoming_events.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcoming_events;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'see all'**
  String get see_all;

  /// No description provided for @event_details.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get event_details;

  /// No description provided for @edit_details.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get edit_details;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get update_profile;

  /// No description provided for @complaint_title.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaint_title;

  /// No description provided for @enter_title.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enter_title;

  /// No description provided for @please_enter_a_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get please_enter_a_title;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @select_department.
  ///
  /// In en, this message translates to:
  /// **'Select Department'**
  String get select_department;

  /// No description provided for @detailed_desc.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailed_desc;

  /// No description provided for @provide_detailed_info.
  ///
  /// In en, this message translates to:
  /// **'Provide detailed information about the issue...'**
  String get provide_detailed_info;

  /// No description provided for @please_provide_a_detailed_desc.
  ///
  /// In en, this message translates to:
  /// **'Please provide a detailed description'**
  String get please_provide_a_detailed_desc;

  /// No description provided for @authority.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get authority;

  /// No description provided for @select_authority.
  ///
  /// In en, this message translates to:
  /// **'Select Authority'**
  String get select_authority;

  /// No description provided for @submit_new_complaint.
  ///
  /// In en, this message translates to:
  /// **'Submit New Complaint'**
  String get submit_new_complaint;

  /// No description provided for @raise_complaint.
  ///
  /// In en, this message translates to:
  /// **'Raise Complaint'**
  String get raise_complaint;

  /// No description provided for @contact_information.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contact_information;

  /// No description provided for @get_in_touch_with_our_support_team.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team'**
  String get get_in_touch_with_our_support_team;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phone_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter you mobile number'**
  String get phone_validator;

  /// No description provided for @support_24_7.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support_24_7;

  /// No description provided for @response_within_24_hours.
  ///
  /// In en, this message translates to:
  /// **'Response within 24 hours'**
  String get response_within_24_hours;

  /// No description provided for @help_and_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_and_support;

  /// No description provided for @search_for_help.
  ///
  /// In en, this message translates to:
  /// **'search for help'**
  String get search_for_help;

  /// No description provided for @frequently_asked_questions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequently_asked_questions;

  /// No description provided for @how_do_i_submit_a_complaint.
  ///
  /// In en, this message translates to:
  /// **'How do I submit a Complaint?'**
  String get how_do_i_submit_a_complaint;

  /// No description provided for @fill_the_complaint_form_with_details_and_submit.
  ///
  /// In en, this message translates to:
  /// **'Fill the complaint form with details and submit.'**
  String get fill_the_complaint_form_with_details_and_submit;

  /// No description provided for @how_long_does_it_take_to_resolve_a_complaint.
  ///
  /// In en, this message translates to:
  /// **'How long does it take to resolve a complaint?'**
  String get how_long_does_it_take_to_resolve_a_complaint;

  /// No description provided for @can_i_upload_multiple_photos_with_my_complaint.
  ///
  /// In en, this message translates to:
  /// **'Can I upload multiple photos with my complaint?'**
  String get can_i_upload_multiple_photos_with_my_complaint;

  /// No description provided for @how_do_i_track_my_complaint_status.
  ///
  /// In en, this message translates to:
  /// **'How do I track my complaint status?'**
  String get how_do_i_track_my_complaint_status;

  /// No description provided for @is_my_personal_information_secure.
  ///
  /// In en, this message translates to:
  /// **'Is my personal information secure?'**
  String get is_my_personal_information_secure;

  /// No description provided for @emergency_contacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergency_contacts;

  /// No description provided for @emergency_services.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergency_services;

  /// No description provided for @emergency_services_info.
  ///
  /// In en, this message translates to:
  /// **'These numbers are for immediate emergency assistance. Use them responsibly.'**
  String get emergency_services_info;

  /// No description provided for @emergency_help.
  ///
  /// In en, this message translates to:
  /// **'Emergency Help'**
  String get emergency_help;

  /// No description provided for @emergency_help_info.
  ///
  /// In en, this message translates to:
  /// **'INLD Sevak is always will be available for help'**
  String get emergency_help_info;

  /// No description provided for @police_emergency.
  ///
  /// In en, this message translates to:
  /// **'Police Emergency'**
  String get police_emergency;

  /// No description provided for @police_emergency_info.
  ///
  /// In en, this message translates to:
  /// **'For immediate police assistance'**
  String get police_emergency_info;

  /// No description provided for @fire_department.
  ///
  /// In en, this message translates to:
  /// **'Fire Department'**
  String get fire_department;

  /// No description provided for @fire_department_info.
  ///
  /// In en, this message translates to:
  /// **'Fire emergency and rescue services'**
  String get fire_department_info;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @ambulance_info.
  ///
  /// In en, this message translates to:
  /// **'Medical emergency services'**
  String get ambulance_info;

  /// No description provided for @electricity_board.
  ///
  /// In en, this message translates to:
  /// **'Electricity Board'**
  String get electricity_board;

  /// No description provided for @electricity_board_info.
  ///
  /// In en, this message translates to:
  /// **'Power outage and electrical emergencies'**
  String get electricity_board_info;

  /// No description provided for @water_department.
  ///
  /// In en, this message translates to:
  /// **'Water Department'**
  String get water_department;

  /// No description provided for @water_department_info.
  ///
  /// In en, this message translates to:
  /// **'Water supply and pipeline emergencies'**
  String get water_department_info;

  /// No description provided for @request_membership.
  ///
  /// In en, this message translates to:
  /// **'Request Membership'**
  String get request_membership;

  /// No description provided for @contact_number.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contact_number;

  /// No description provided for @aadhar_voter_id.
  ///
  /// In en, this message translates to:
  /// **'Aadhar/Voter ID'**
  String get aadhar_voter_id;

  /// No description provided for @enter_aadhar_voter.
  ///
  /// In en, this message translates to:
  /// **'Enter Aadhar/Voter ID'**
  String get enter_aadhar_voter;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @address_details.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get address_details;

  /// No description provided for @eg_address.
  ///
  /// In en, this message translates to:
  /// **'E.g. Floor, House no, Street'**
  String get eg_address;

  /// No description provided for @select_address.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get select_address;

  /// No description provided for @upload_photo.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get upload_photo;

  /// No description provided for @upload_photos.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos (Optional)'**
  String get upload_photos;

  /// No description provided for @please_provide_valid_10_digit_number.
  ///
  /// In en, this message translates to:
  /// **'Please provide valid 10 digits number'**
  String get please_provide_valid_10_digit_number;

  /// No description provided for @click_to_upload_doc_and_photo.
  ///
  /// In en, this message translates to:
  /// **'Click to Upload Documents or Photos'**
  String get click_to_upload_doc_and_photo;

  /// No description provided for @maximum_5_are_allowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 are allowed'**
  String get maximum_5_are_allowed;

  /// No description provided for @enter_address.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enter_address;

  /// No description provided for @enter_your_address.
  ///
  /// In en, this message translates to:
  /// **'Enter your Address'**
  String get enter_your_address;

  /// No description provided for @address_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your home address'**
  String get address_validator;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @request_appointment.
  ///
  /// In en, this message translates to:
  /// **'Request Appointment'**
  String get request_appointment;

  /// No description provided for @scheduled_date.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduled_date;

  /// No description provided for @rescheduled_date.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled Date'**
  String get rescheduled_date;

  /// No description provided for @appointment_note.
  ///
  /// In en, this message translates to:
  /// **'Note: As per the availability of Associate can rescheduled ur preferred date in appointment'**
  String get appointment_note;

  /// No description provided for @appointment_list.
  ///
  /// In en, this message translates to:
  /// **'Appointment List'**
  String get appointment_list;

  /// No description provided for @select_mla.
  ///
  /// In en, this message translates to:
  /// **'Select MLA'**
  String get select_mla;

  /// No description provided for @select_associate.
  ///
  /// In en, this message translates to:
  /// **'Select Associate'**
  String get select_associate;

  /// No description provided for @your_notified_events.
  ///
  /// In en, this message translates to:
  /// **'Your Notified Events'**
  String get your_notified_events;

  /// No description provided for @book_for.
  ///
  /// In en, this message translates to:
  /// **'Book for'**
  String get book_for;

  /// No description provided for @membership_id.
  ///
  /// In en, this message translates to:
  /// **'Membership ID'**
  String get membership_id;

  /// No description provided for @membership_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter Membership ID'**
  String get membership_validator;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @please_select_your_appointment_date.
  ///
  /// In en, this message translates to:
  /// **'Please select your appointment date'**
  String get please_select_your_appointment_date;

  /// No description provided for @mla_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select one MLA'**
  String get mla_validator;

  /// No description provided for @choose_your_associate.
  ///
  /// In en, this message translates to:
  /// **'Choose your Associate'**
  String get choose_your_associate;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone_number;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @time_slot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get time_slot;

  /// No description provided for @preferred_date.
  ///
  /// In en, this message translates to:
  /// **'Preferred Date'**
  String get preferred_date;

  /// No description provided for @select_time_slot.
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Time Slot'**
  String get select_time_slot;

  /// No description provided for @purpose_of_appointment.
  ///
  /// In en, this message translates to:
  /// **'Purpose of Appointment'**
  String get purpose_of_appointment;

  /// No description provided for @enter_your_appointment_reason.
  ///
  /// In en, this message translates to:
  /// **'Enter your appointment reason'**
  String get enter_your_appointment_reason;

  /// No description provided for @upload_documents.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get upload_documents;

  /// No description provided for @description_info.
  ///
  /// In en, this message translates to:
  /// **'Enter detail description for an appointment'**
  String get description_info;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @wall_of_help.
  ///
  /// In en, this message translates to:
  /// **'Wall of Help'**
  String get wall_of_help;

  /// No description provided for @helping_hands_gains_love.
  ///
  /// In en, this message translates to:
  /// **'Helping hands gains love'**
  String get helping_hands_gains_love;

  /// No description provided for @quick_links.
  ///
  /// In en, this message translates to:
  /// **'Quick Links'**
  String get quick_links;

  /// No description provided for @request_help.
  ///
  /// In en, this message translates to:
  /// **'Request Help'**
  String get request_help;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @raise_amount.
  ///
  /// In en, this message translates to:
  /// **'Raise Amount'**
  String get raise_amount;

  /// No description provided for @raised_amount.
  ///
  /// In en, this message translates to:
  /// **'Raised Amount'**
  String get raised_amount;

  /// No description provided for @raise_amount_validator.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be empty'**
  String get raise_amount_validator;

  /// No description provided for @requested_amount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get requested_amount;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enter_your_issue.
  ///
  /// In en, this message translates to:
  /// **'Enter your issue'**
  String get enter_your_issue;

  /// No description provided for @enter_your_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enter_your_name;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enter_your_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your title'**
  String get enter_your_title;

  /// No description provided for @please_enter_the_cause_for_raising_request.
  ///
  /// In en, this message translates to:
  /// **'Please enter cause for raising request'**
  String get please_enter_the_cause_for_raising_request;

  /// No description provided for @please_enter_few_words.
  ///
  /// In en, this message translates to:
  /// **'Please enter few words'**
  String get please_enter_few_words;

  /// No description provided for @type_of_help_needed.
  ///
  /// In en, this message translates to:
  /// **'Type of Help Needed'**
  String get type_of_help_needed;

  /// No description provided for @choose_the_options.
  ///
  /// In en, this message translates to:
  /// **'Choose the options'**
  String get choose_the_options;

  /// No description provided for @dropdown_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select one option'**
  String get dropdown_validator;

  /// No description provided for @enter_description_of_request.
  ///
  /// In en, this message translates to:
  /// **'Enter description of request'**
  String get enter_description_of_request;

  /// No description provided for @urgency_level.
  ///
  /// In en, this message translates to:
  /// **'Urgency Level'**
  String get urgency_level;

  /// No description provided for @preferred_way_to_receive_help.
  ///
  /// In en, this message translates to:
  /// **'Preferred Way to Receive Help'**
  String get preferred_way_to_receive_help;

  /// No description provided for @supporting_documents.
  ///
  /// In en, this message translates to:
  /// **'Supporting Documents (If Any)'**
  String get supporting_documents;

  /// No description provided for @less_amount_validator.
  ///
  /// In en, this message translates to:
  /// **'Minimun 10rs is allowed'**
  String get less_amount_validator;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @my_chat.
  ///
  /// In en, this message translates to:
  /// **'My Chats'**
  String get my_chat;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @enter_detail_description.
  ///
  /// In en, this message translates to:
  /// **'Enter detail description'**
  String get enter_detail_description;

  /// No description provided for @date_of_submission.
  ///
  /// In en, this message translates to:
  /// **'Date of Submission'**
  String get date_of_submission;

  /// No description provided for @enter_contact_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Number'**
  String get enter_contact_number;

  /// No description provided for @request_details.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get request_details;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount_already_contributed.
  ///
  /// In en, this message translates to:
  /// **'Amount Already Contributed'**
  String get amount_already_contributed;

  /// No description provided for @balance_needed.
  ///
  /// In en, this message translates to:
  /// **'Balance Needed'**
  String get balance_needed;

  /// No description provided for @contribution_input.
  ///
  /// In en, this message translates to:
  /// **'Contribution Input'**
  String get contribution_input;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @date_of_request.
  ///
  /// In en, this message translates to:
  /// **'Date of request'**
  String get date_of_request;

  /// No description provided for @previous_contributions.
  ///
  /// In en, this message translates to:
  /// **'Previous Contributions'**
  String get previous_contributions;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get my_requests;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @my_complaints.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get my_complaints;

  /// No description provided for @not_found.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get not_found;

  /// No description provided for @id_card.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get id_card;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @be_a_volunteer.
  ///
  /// In en, this message translates to:
  /// **'Be a Volunteer'**
  String get be_a_volunteer;

  /// No description provided for @become_a_volunteer.
  ///
  /// In en, this message translates to:
  /// **'Become a Volunteer'**
  String get become_a_volunteer;

  /// No description provided for @enter_age.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enter_age;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @age_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get age_validator;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @enter_occupation.
  ///
  /// In en, this message translates to:
  /// **'Enter Occupation'**
  String get enter_occupation;

  /// No description provided for @occupation_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your occupation'**
  String get occupation_validator;

  /// No description provided for @preferred_time_slots.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time Slots'**
  String get preferred_time_slots;

  /// No description provided for @select_time_preferrence.
  ///
  /// In en, this message translates to:
  /// **'Select Time Preferences'**
  String get select_time_preferrence;

  /// No description provided for @time_slot_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred time slot'**
  String get time_slot_validator;

  /// No description provided for @hours_per_week.
  ///
  /// In en, this message translates to:
  /// **'Hours Per Week'**
  String get hours_per_week;

  /// No description provided for @select_hours.
  ///
  /// In en, this message translates to:
  /// **'Select Hours'**
  String get select_hours;

  /// No description provided for @hours_per_week_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred volunteer duration'**
  String get hours_per_week_validator;

  /// No description provided for @area_of_interest.
  ///
  /// In en, this message translates to:
  /// **'Area of Interest'**
  String get area_of_interest;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @survey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get survey;

  /// No description provided for @party_information.
  ///
  /// In en, this message translates to:
  /// **'Party Information'**
  String get party_information;

  /// No description provided for @know_our_identity_slogan.
  ///
  /// In en, this message translates to:
  /// **'Know our identity & slogan'**
  String get know_our_identity_slogan;

  /// No description provided for @party_slogan.
  ///
  /// In en, this message translates to:
  /// **'Party Slogan'**
  String get party_slogan;

  /// No description provided for @established_year.
  ///
  /// In en, this message translates to:
  /// **'Established Year'**
  String get established_year;

  /// No description provided for @party_type.
  ///
  /// In en, this message translates to:
  /// **'Party type'**
  String get party_type;

  /// No description provided for @leadership_information.
  ///
  /// In en, this message translates to:
  /// **'Leadership Information'**
  String get leadership_information;

  /// No description provided for @meet_our_leaders_key_member.
  ///
  /// In en, this message translates to:
  /// **'Meet our leaders & key members'**
  String get meet_our_leaders_key_member;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @key_focus_area.
  ///
  /// In en, this message translates to:
  /// **'Key Focus Area'**
  String get key_focus_area;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_section.
  ///
  /// In en, this message translates to:
  /// **'About Section'**
  String get about_section;

  /// No description provided for @app_mission_vision_history.
  ///
  /// In en, this message translates to:
  /// **'App mission, vision & history'**
  String get app_mission_vision_history;

  /// No description provided for @lok_varta.
  ///
  /// In en, this message translates to:
  /// **'Lok Varta'**
  String get lok_varta;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get language;

  /// No description provided for @language_subtext.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language, Your Way.'**
  String get language_subtext;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions;

  /// No description provided for @terms_and_conditions_subtext.
  ///
  /// In en, this message translates to:
  /// **'App usage rules'**
  String get terms_and_conditions_subtext;

  /// No description provided for @privacy_policy_subtext.
  ///
  /// In en, this message translates to:
  /// **'Your data safety'**
  String get privacy_policy_subtext;

  /// No description provided for @help_and_support_subtext.
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get help_and_support_subtext;

  /// No description provided for @emergency_contacts_subtext.
  ///
  /// In en, this message translates to:
  /// **'quick access to emergency services'**
  String get emergency_contacts_subtext;

  /// No description provided for @share_app.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get share_app;

  /// No description provided for @share_app_subtext.
  ///
  /// In en, this message translates to:
  /// **'You can Share this app to your friends and family members'**
  String get share_app_subtext;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from your account?'**
  String get logout_confirmation;

  /// No description provided for @notify_representative.
  ///
  /// In en, this message translates to:
  /// **'Notify Representative'**
  String get notify_representative;

  /// No description provided for @notify.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notify;

  /// No description provided for @notify_mla.
  ///
  /// In en, this message translates to:
  /// **'Notify Mla'**
  String get notify_mla;

  /// No description provided for @notify_description.
  ///
  /// In en, this message translates to:
  /// **'Beyond politics, we build trust and support. With the Wall of Help, you’re never alone assistance is always near.'**
  String get notify_description;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @view_how_member_notified.
  ///
  /// In en, this message translates to:
  /// **'View how members Notified'**
  String get view_how_member_notified;

  /// No description provided for @nearest_member.
  ///
  /// In en, this message translates to:
  /// **'Nearest Member'**
  String get nearest_member;

  /// No description provided for @list_of_nearest_member.
  ///
  /// In en, this message translates to:
  /// **'List Of Nearest Member'**
  String get list_of_nearest_member;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @phone_no.
  ///
  /// In en, this message translates to:
  /// **'Phone No'**
  String get phone_no;

  /// No description provided for @notify_description_validatore.
  ///
  /// In en, this message translates to:
  /// **'Enter detail description to notify'**
  String get notify_description_validatore;

  /// No description provided for @event_title_validatore.
  ///
  /// In en, this message translates to:
  /// **'Please enter event name'**
  String get event_title_validatore;

  /// No description provided for @event_time_validatore.
  ///
  /// In en, this message translates to:
  /// **'Please select event time'**
  String get event_time_validatore;

  /// No description provided for @event_date_validatore.
  ///
  /// In en, this message translates to:
  /// **'Please select your event date'**
  String get event_date_validatore;

  /// No description provided for @event_date.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get event_date;

  /// No description provided for @event_type.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get event_type;

  /// No description provided for @event_time.
  ///
  /// In en, this message translates to:
  /// **'Event Time'**
  String get event_time;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get select_time;

  /// No description provided for @enter_location.
  ///
  /// In en, this message translates to:
  /// **'Enter Location'**
  String get enter_location;

  /// No description provided for @event_location_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter event location'**
  String get event_location_validator;

  /// No description provided for @location_venue.
  ///
  /// In en, this message translates to:
  /// **'Location / Venue'**
  String get location_venue;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
