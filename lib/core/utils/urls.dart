class URLs {
  URLs._privateConstructor();

  static const baseURL = "https://citi.cortexaics.info";

  //auth
  static const generateOTP = "/api/user/generateOtp"; /*Post*/
  static const verifyOTP = "/api/user/verifyOtp"; /*Post*/

  //profile
  static const userRegister = "/api/user/Register"; /*Post*/
  static const getUserProfile = "/api/user/getUserProfile"; /*Get*/
  static const editUser = "/api/user/editUser"; /*Put*/

  //dashboard
  static const getDashboard = "/api/user/getUserDashboard"; /*Get*/
  static const getVolunteerAnalytics =
      "/api/user/getVolunteerAnalytics"; /*Get*/

  //Image
  static const uploadImage = "/api/image/uploadImage"; /*Post*/
  static const uploadMultipleImage = "/api/image/multipleUpload"; /*Post*/

  //Party Member

  static const getUserDetails = "/api/user/get-user-details-by-phone"; /*Post*/
  static const becomePartyMember = "/api/user/become-party-member"; /*Post*/
  static const getParties = "/api/user/list-of-parties-dropdown";
  static const createVolunter = "/api/user/create-volunteer"; /*Post*/
  static const surveys = "/api/user/list-of-survey"; /*Post*/
  static const submitSurveys = "/api/user/create-survey-response"; /*Post*/

  //User
  static const userMLAs = "/api/user/list-of-mlas-dropdown"; /*Get*/
  static const createAppointment = "/api/user/create-appointment"; /*POST*/
  static const userAppointment = "/api/user/list-Of-appointment"; /*POST*/

  static const userEvents = "/api/user/list-of-events"; /*Post*/
  static const userEventsDetails = "/api/user/get-single-event"; /*Post*/
  static const attendEvent = "/api/user/attend-Event"; /*Post*/
  static const userLokVarta = "/api/user/lok-varta"; /*Post*/
  static const postDonation = "/api/user/create-donation"; /*Post*/
  static const pastDonation = "/api/user/list-of-donations-by-user"; /*Post*/
  static const userMlaDetails = "/api/user/mla-details-by-user"; /*Get*/
  static const lokVartaDetails = "/api/user/getSinglelokVarta"; /*Post*/

  //complaints

  static const addComplaint = "/api/complaint/sendmail"; /*Post*/
  static const getComplaintByThreadID =
      "/api/complaint/getchatbythreadId"; /*Post*/
  static const replyToComplaintByThreadID =
      "/api/complaint/replythread"; /*Post*/
  static const getComplaintByUserID = "/api/complaint/getComplaints"; /*Get*/
  static const getDepartments = "/api/user/list-of-department-dropdown"; /*Get*/
  static const getAuthority = "/api/user/list-of-authorities-dropdown"; /*Get*/
  static const getConstituencies =
      "/api/user/list-of-constituencies-dropdown"; /*Get*/
 
  static const getPincodeConstituencies =
      "/api/user/get-constituency-by-pincode"; /*Get*/
  static const getParliamentaryConstituency =
      "/api/user/get-parliamentary-constituency-by-pincode"; /*Post*/
  static const getAssemblyConstituency =
      "/api/user/get-assembly-constituency"; /*Post*/

  // wall of help
  static const getUserWallOFHelpData =
      "/api/user/list-of-financial-help-requests"; /*Get*/
  static const getMyWallOfHelpLists =
      "/api/user/list-of-my-financial-help-requests"; /*Post*/
  static const requestFinancialHelp =
      "/api/user/create-financial-help-request"; /*Post*/
  static const updateFinancialHelp =
      "/api/user/update-financial-help-request"; /*Post*/
  static const donateToHelpRequest =
      "/api/user/donateToFinancialHelpRequest"; /*Post*/
  static const getTypesOfHelpsDD = "/api/user/type-of-help-dropdown"; /*Get*/
  static const getPreferredWaysDD =
      "/api/user/preferred-way-for-help-dropdown"; /*Get*/
  static const getFinancialMessages =
      "/api/user/get-financial-message-by-messageId"; /*Post*/
  static const replyFinancialMessages =
      "/api/user/reply-financial-help-request-message"; /*Post*/
  static const completeMyFinancialHelp =
      "/api/user/completeMyFinancialHelpRequests"; /*Post*/
      

  //notifications
  static const notifications = "/api/user/notificationList"; /*Get*/

  //Nearest Member
  static const getNearestMembers = "/api/user/nearest-party-member"; /*Post*/
  static const getNearestMemberMessages = "/api/user/get-messages"; /*Post*/
  static const postNearestMemberMessage = "/api/user/send-mla-message"; /*Post*/
  static const getMyMembersChats = "/api/user/get-All-Chats"; /*Get*/

  // Notify representative

  static const getNotifyEventTypes = "/api/user/list-of-event-type-dropdown";
  static const postNotifyRepresentative =
      "/api/user/create-update-notify-representative";
  static const getListNotifyRepresentative =
      "/api/user/list-of-notify-representative";
  static const deleteNotifyRepresentative =
      "/api/user/delete-notify-representative";
}
