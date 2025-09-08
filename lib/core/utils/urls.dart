class URLs {
  URLs._privateConstructor();

  static const baseURL = "http://143.110.246.44:8000";

  //auth
  static const generateOTP = "/api/user/generateOtp"; /*Post*/
  static const verifyOTP = "/api/user/verifyOtp"; /*Post*/

  //profile
  static const userRegister = "/api/user/Register"; /*Post*/
  static const getUserProfile = "/api/user/getUserProfile"; /*Get*/
  static const editUser = "/api/user/editUser"; /*Put*/
  static const uploadImage = "/uploadImage"; /*Post*/

  //Donation

  //Party Member

  static const getUserDetails = "/api/user/get-user-details-by-phone"; /*Post*/
  static const becomePartyMember = "/api/user/become-party-member"; /*Post*/
  static const createVolunter = "/api/partymember/create-volunteer"; /*Post*/

  //User
  static const userMLAs = "/api/user/list-of-mlas-dropdown"; /*Get*/
  static const userAppointment = "/api/user/create-appointment"; /*Get*/
  static const getUserWallOFHelpData =
      "/api/user/listOfFinancialHelpRequests"; /*Get*/
  static const userEvents = "/api/user/list-of-events"; /*Post*/
  static const userEventsDetails = "/api/user/get-single-event"; /*Post*/
  static const userLokVarta = "/api/user/lok-varta"; /*Post*/
  static const postDonation = "/api/user/create-donation"; /*Post*/
  static const pastDonation = "/api/user/list-of-donations-by-user"; /*Post*/

  //complaints

  static const addComplaint = "/api/complaint/sendmail"; /*Post*/
  static const getComplaintByThreadID =
      "/api/complaint/getchatbythreadId"; /*Post*/
  static const replyToComplaintByThreadID =
      "/api/complaint/replythread"; /*Post*/
  static const getComplaintByUserID = "/api/complaint/getComplaints"; /*Get*/
  static const getDepartments = "/api/user/list-of-department-dropdown"; /*Get*/
  static const getAuthority = "/api/user/list-of-authorities-dropdown"; /*Get*/
  static const getConstituencies = "/api/user/list-of-constituencies-dropdown"; /*Get*/
}
