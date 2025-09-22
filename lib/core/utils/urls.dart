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

  //Image
  static const uploadImage = "/api/image/uploadImage"; /*Post*/
  static const uploadMultipleImage = "/api/image/multipleUpload"; /*Post*/

  //Party Member

  static const getUserDetails = "/api/user/get-user-details-by-phone"; /*Post*/
  static const becomePartyMember = "/api/user/become-party-member"; /*Post*/
  static const getParties = "/api/user/list-of-parties-dropdown";
  static const createVolunter = "/api/partymember/create-volunteer"; /*Post*/

  //User
  static const userMLAs = "/api/user/list-of-mlas-dropdown"; /*Get*/
  static const createAppointment = "/api/user/create-appointment"; /*POST*/
  static const userAppointment = "/api/user/list-Of-appointment"; /*POST*/

  static const userEvents = "/api/user/list-of-events"; /*Post*/
  static const userEventsDetails = "/api/user/get-single-event"; /*Post*/
  static const userLokVarta = "/api/user/lok-varta"; /*Post*/
  static const postDonation = "/api/user/create-donation"; /*Post*/
  static const pastDonation = "/api/user/list-of-donations-by-user"; /*Post*/
  static const userMlaDetails = "/api/user/mla-details-by-user"; /*Get*/

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
  static const requestFinancialHelp =
      "/api/user/createFinancialHelpRequest"; /*Post*/
  static const donateToHelpRequest =
      "/api/user/donateToFinancialHelpRequest"; /*Post*/

  //notifications
  static const notifications = "/api/user/notificationList"; /*Get*/
}
