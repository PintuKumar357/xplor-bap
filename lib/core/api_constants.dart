//Dev URl
//const String domain = "https://implementation-layer-dev.thewitslab.com/";

//Staging URl
// const String domain = "https://testspar.dpgongcp.com/";
const String domain = "https://2887-203-201-231-35.ngrok-free.app//";
//Staging URl
//const String domain = "https://6h4kfp6q-8000.inc1.devtunnels.ms/";

const String applyFormSubmit = "${domain}submitApplication";

const String baseUrl = "${domain}api/v1/";

///payment method navigation url

const String successNavigation =
    "${domain}api/v1/payment/verify-payment?razorpay_payment_id=";
const String failedNavigation = "https://api.razorpay.com/v1/payments/";

const String eAuthWebHook = "${domain}kycForm";
const String eAuthDigilockerWebHook = "${domain}v1/e-auth/callback?code=";
const String signInWebHook =
    "https://digilocker.meripehchaan.gov.in/signin/oauth_partner";
const String eAuthWebHookError = "${domain}v1/e-auth/callback?error=";
// Api End points with base urla
const String verifyKycApi = "${baseUrl}user/kyc";
const String sendOtpApi = "${baseUrl}user/send-otp";
const String verifyOtpApi = "${baseUrl}user/verify-otp";
const String getUserJourneyApi = "${baseUrl}user/journey";
const String assignRoleApi = "${baseUrl}user/role";
const String getUserRoleApi = "${baseUrl}user/roles";
const String getAuthProvidersApi = "${baseUrl}e-auth";
const String addDocumentApi = "${baseUrl}wallet/file";
const String getWalletApi = "${baseUrl}wallet";
const String getWalletVcApi = "${baseUrl}wallet/vcs?walletId=";
const String sharedWalletVcApi = "${baseUrl}wallet/vc/share";
const String deletedWalletVcApi = "${baseUrl}wallet/vc?";
const String getMyConsentsApi = "${baseUrl}wallet/vc/shared/requests?";
const String updateConsentApi = "${baseUrl}wallet/vc/shared/requests/update?";
const String revokeConsentApi = "${baseUrl}wallet/vc/shared/requests/status?";
const String generateMpinApi = "${baseUrl}user/create-mpin";
const String verifyMpinApi = "${baseUrl}user/verify-mpin";
const String userDataApi = "${baseUrl}user";
const String refreshTokenUrl = "${baseUrl}user/access-token";
const String refreshTokenApi = "${baseUrl}user/access-token";
const String logoutApi = "${baseUrl}user/logout";
const String sendMpinOtp = "${baseUrl}user/send-mpin-otp";
const String resetPin = "${baseUrl}user/reset-mpin";
const String getCategoriesApi = "${baseUrl}ai-ml/categories";
const String sseKycApi = "${baseUrl}e-auth/sse";
const String updateDevicePreferenceApi = "${baseUrl}user/device-preference";
const String getDomainsApi = "${baseUrl}ai-ml/domains";
const String getLanguagesListApi = "${baseUrl}ai-ml/languages";
const String selectLanguagesApi = "${baseUrl}user/device-preference";
const String translationApi = "${baseUrl}ai-ml/translate";
const String seekerSearchApi = "${baseUrl}stg/search";
const String seekerSearchSSEApi = "${baseUrl}stg/sse?";
const String initRequestApi = "${baseUrl}stg/init";
//const String initRequestApi = "${baseUrl}stg/inits";
const String confirmRequestApi = "${baseUrl}stg/confirm";
const String statusRequestApi = "${baseUrl}stg/status";
const String selectRequestApi = "${baseUrl}stg/select";
const String myOrdersApi = "${baseUrl}user/orders";
const String getOrderDetailsApi = "${baseUrl}item";
const String addCertificateToWalletApi = "${baseUrl}wallet/file/certificate";
const String markAddToWalletApi = "${baseUrl}user/orders/mark-add-to-wallet";
