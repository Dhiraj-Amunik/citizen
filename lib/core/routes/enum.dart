part of 'routes.dart';

enum Routes {
  wrapperPage(path: "/"),
  loginPage(path: "/LoginPage"),
  verifyOTPPage(path: "/VerifyOTPPage"),
  userRegisterPage(path: "/UserRegisterPage"),
  homePage(path: "/HomePage"),
  becomePartMemberPage(path: "/BecomePartMemberPage"),
  complaintsPage(path: "/ComplaintsPage"),
  lodgeComplaintPage(path: "/LodgeComplaintPage"),
  threadComplaintPage(path: "/ThreadComplaintPage"),
  eventsPage(path: "/EventsPage"),
  eventDetailsPage(path: "/EventDetailsPage"),
  profileEditView(path: "/ProfileEditView"),
  helpAndSupportPage(path: "/HelpAndSupportPage"),
  emergencyContactsPage(path: "/EmergencyContactsPage"),
  leadershipInfoPage(path: "/LeadershipInfoPage"),
  partyInformationPage(path: "/PartyInformationPage"),
  aboutPage(path: "/AboutPage"),
  requestMembershipPage(path: "/RequestMembershipPage"),
  requestAppointmentPage(path: "/RequestAppointmentPage"),
  appointmentPage(path: "/AppointmentPage"),
  appointmentDetailsPage(path: "/AppointmentDetailsPage"),
  userWallOfHelpPage(path: "/UserWallOfHelpPage"),
  partyWallOfHelpPage(path: "/PartyWallOfHelpPage"),
  myRequestsPage(path: "/MyRequestsPage"),
  myHelpRequestEditPage(path: "/MyHelpRequestEditPage"),
  myHelpMessagesListPage(path: "/myHelpMessagesListPage"),
  wallOfHelpDetailsPage(path: "/WallOfHelpDetailsPage"),
  contributePage(path: "/contributePage"),
  chatContributePage(path: "/chatContributePage"),
  requestWallOfHelpPage(path: "/RequestWallOfHelpPage"),
  beVolunteerPage(path: "/BeVolunteerPage"),
  idCardPage(path: "/IdCardPage"),
  donatePage(path: "/DonatePage"),
  pressReleasesDetailedPage(path: "/PressReleasesDetailedPage"),
  notificationsPage(path: "/NotificationsPage"),
  surveyPage(path: "/SurveyPage"),
  nearestMemberPage(path: "/NearestMemberPage"),
  chatMemberPage(path: "/ChatMemberPage"),
  myMembersMessagesListPage(path: "/MyMembersMessagesListPage"),
  photoDetailsPage(path: "/PhotoDetailsPage"),
  notifyRepresentativePage(path: "/NotifyRepresentativePage"),
  createNotifyRepresentativePage(path: "/CreateNotifyRepresentativePage"),
  updateNotifyRepresentativePage(path: "/UpdateNotifyRepresentativePage"),
  interviewDetailedPage(path: "/InterviewDetailedWidget");

  final String path;
  final AxisDirection direction;

  const Routes({required this.path, this.direction = AxisDirection.up});
}

Widget getPage(Routes route, {dynamic arguments}) {
  switch (route) {
    case Routes.wrapperPage:
      return WrapperView();
    case Routes.loginPage:
      return LoginView();
    case Routes.verifyOTPPage:
      return VerifyOtpView();
    case Routes.userRegisterPage:
      return UserRegisterView(data: arguments);
    case Routes.homePage:
      return HomeView();
    case Routes.becomePartMemberPage:
      return BecomePartMemberView();
    case Routes.complaintsPage:
      return ComplaintsView();
    case Routes.lodgeComplaintPage:
      return const LodgeComplaintView();
    case Routes.threadComplaintPage:
      return ThreadComplaintView(data: arguments);
    case Routes.eventsPage:
      return EventsView();
    case Routes.eventDetailsPage:
      return EventDetailsView(eventModel: arguments);
    case Routes.profileEditView:
      return ProfileEditView();
    case Routes.helpAndSupportPage:
      return HelpAndSupportView();
    case Routes.emergencyContactsPage:
      return EmergencyContactsView();
    case Routes.leadershipInfoPage:
      return LeadershipInfoView();
    case Routes.partyInformationPage:
      return PartyInformationView();
    case Routes.aboutPage:
      return AboutView();
    case Routes.requestMembershipPage:
      return RequestMembershipView();
    case Routes.requestAppointmentPage:
      return RequestAppointmentView();
    case Routes.appointmentPage:
      return AppointmentsView();
    case Routes.appointmentDetailsPage:
      return AppointmentDetailsView(appointment: arguments);
    case Routes.userWallOfHelpPage:
      return WallOfHelpUserView();
    case Routes.wallOfHelpDetailsPage:
      return WallOfHelpDetailsView(
        helpRequest: arguments["model"],
        isEditable: arguments["isEditable"],
      );
    case Routes.myRequestsPage:
      return MyHelpRequestsView();
    case Routes.myHelpRequestEditPage:
      return MyHelpRequestEditView(editableData: arguments);
    case Routes.myHelpMessagesListPage:
      return MyHelpMessagesListView(helpRequests: arguments);

    case Routes.partyWallOfHelpPage:
      return WallOfHelpPartyView();
    case Routes.contributePage:
      return ContributeView(helpRequest: arguments);
    case Routes.chatContributePage:
      return ChatContributeView(helpRequest: arguments);
    case Routes.requestWallOfHelpPage:
      return RequestWallOfHelpView();
    case Routes.beVolunteerPage:
      return BeAVolunteerView();
    case Routes.idCardPage:
      return IdCardView();
    case Routes.donatePage:
      return DonateView();
    case Routes.pressReleasesDetailedPage:
      return PressReleasesDetailedView(media: arguments);
    case Routes.notificationsPage:
      return NotificationsView();
    case Routes.surveyPage:
      return SurveyView();
    case Routes.photoDetailsPage:
      return PhotoDetailsView(media: arguments);
    case Routes.notifyRepresentativePage:
      return NotifyRepresentativeView();
    case Routes.createNotifyRepresentativePage:
      return CreateNotifyRepresentativeView();
    case Routes.updateNotifyRepresentativePage:
      return UpdateNotifyRepresentativeView(model: arguments);
    case Routes.interviewDetailedPage:
      return InterviewDetailedWidget(media: arguments);
    default:
      return LoginView();
  }
}
