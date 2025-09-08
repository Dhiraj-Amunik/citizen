import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

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

  /// No description provided for @not_received.
  ///
  /// In en, this message translates to:
  /// **'Not Received?'**
  String get not_received;

  /// No description provided for @resend_code_in.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resend_code_in;

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
  /// **'     Select your Gender'**
  String get gender_validator;

  /// No description provided for @aadhar_card_number.
  ///
  /// In en, this message translates to:
  /// **'Aadhar card Number'**
  String get aadhar_card_number;

  /// No description provided for @aadhar_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter Id proof'**
  String get aadhar_validator;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

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

  /// No description provided for @enter_purpose_of_donation.
  ///
  /// In en, this message translates to:
  /// **'Enter purpose of donation'**
  String get enter_purpose_of_donation;

  /// No description provided for @payment_options.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get payment_options;

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
  /// **'NetBanking'**
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

  /// No description provided for @father_name.
  ///
  /// In en, this message translates to:
  /// **'Father\'s / Mother\'s Name'**
  String get father_name;

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
  /// **'Help and Support'**
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

  /// No description provided for @upload_photo.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get upload_photo;

  /// No description provided for @please_provide_valid_10_digit_number.
  ///
  /// In en, this message translates to:
  /// **'Please provide valid 10 digits number'**
  String get please_provide_valid_10_digit_number;

  /// No description provided for @enter_address.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enter_address;

  /// No description provided for @address_validator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your home address'**
  String get address_validator;

  /// No description provided for @request_appointment.
  ///
  /// In en, this message translates to:
  /// **'Request Appointment'**
  String get request_appointment;

  /// No description provided for @select_mla.
  ///
  /// In en, this message translates to:
  /// **'Select MLA'**
  String get select_mla;

  /// No description provided for @mla_validator.
  ///
  /// In en, this message translates to:
  /// **'Please select one MLA'**
  String get mla_validator;

  /// No description provided for @choose_your_mla.
  ///
  /// In en, this message translates to:
  /// **'Choose your MLA'**
  String get choose_your_mla;

  /// No description provided for @membership_id.
  ///
  /// In en, this message translates to:
  /// **'Membership ID'**
  String get membership_id;

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

  /// No description provided for @select_purpose.
  ///
  /// In en, this message translates to:
  /// **'Select Purpose'**
  String get select_purpose;

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

  /// No description provided for @wall_of_help.
  ///
  /// In en, this message translates to:
  /// **'Wall of Help'**
  String get wall_of_help;

  /// No description provided for @quick_access.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quick_access;

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

  /// No description provided for @requested_amount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get requested_amount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

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

  /// No description provided for @my_complaints.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get my_complaints;

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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
