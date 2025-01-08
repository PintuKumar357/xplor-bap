import 'package:flutter/material.dart';
import 'package:xplor/features/appointmet/domain/entities/CreateAppointmentArgs.dart';
import 'package:xplor/features/appointmet/presentation/pages/doctor/appointment_screen.dart';
import 'package:xplor/features/appointmet/presentation/pages/doctor/doctor.dart';
// import 'package:xplor/HealthRecords_Page.dart';
import 'package:xplor/features/my_orders/domain/entities/certificate_view_arguments.dart';
// import '../../DataTable_Page.dart';
import '../../features/appointmet/presentation/pages/create_appointment/add_beneficiary.dart';
import '../../features/appointmet/presentation/pages/create_appointment/create_appointment.dart';
import '../../features/apply_course/presentation/screens/apply_course_screen.dart';
import '../../features/apply_course/presentation/screens/course_documents_screen.dart';
import '../../features/apply_course/presentation/screens/thanks_for_applying_screen.dart';
import '../../features/appointmet/presentation/pages/create_appointment/health_documents.dart';
import '../../features/appointmet/presentation/pages/create_appointment/issue_prescription.dart';
import '../../features/appointmet/presentation/pages/create_appointment/profile_varification.dart';
import '../../features/appointmet/presentation/pages/create_appointment/view_appointment.dart';
import '../../features/appointmet/presentation/pages/create_appointment/view_beneficiary.dart';
import '../../features/appointmet/presentation/pages/doctor/doctor_detail_screen.dart';
import '../../features/my_orders/presentation/pages/my_orders_view.dart';
import '../../features/on_boarding/presentation/pages/choose_domain/choose_domain_screen.dart';
import '../../features/home/presentation/widgets/tab_bar_widget.dart';
import '../../features/mpin/presentation/pages/reset_mpin_screen.dart';
import '../../features/on_boarding/presentation/pages/complete_kyc/complete_profile_view_for_belem.dart';
import '../../features/on_boarding/presentation/pages/sign_in/phone_number_view.dart';
import '../../features/multi_lang/presentation/pages/select_lang_page.dart';
import '../../features/profile/presentation/pages/seeker_profile/seeker_edit_profile.dart';
import '../../features/seeker_home/presentation/pages/seeker_serach_result_view.dart';
import '../../features/walk_through/presentation/pages/splash_page.dart';
import '../../features/on_boarding/presentation/pages/choose_role/choose_role_view.dart';
import '../../features/on_boarding/presentation/pages/mpin/generate_mpin_screen.dart';
import '../../features/on_boarding/presentation/pages/otp/verify_otp_view.dart';
import '../../features/on_boarding/presentation/pages/select_category/select_category_screen.dart';
import '../../features/seeker_home/presentation/widgets/seeker_tab_bar_widget.dart';
import '../../features/wallet/presentation/pages/share_doc_screen.dart';
import '../../features/wallet/presentation/widgets/add_document_view.dart';
import '../../const/local_storage/shared_preferences_helper.dart';
import '../../core/dependency_injection.dart';
import '../../features/apply_course/presentation/screens/payment_screen.dart';
import '../../features/apply_course/presentation/screens/start_course_page.dart';
import '../../features/multi_lang/presentation/pages/location_screen.dart';
import '../../features/my_orders/presentation/pages/certificate_view.dart';
import '../../features/on_boarding/domain/entities/user_data_entity.dart';
import '../../features/on_boarding/presentation/pages/complete_kyc/complete_profile_view/complete_profile_view.dart';
import '../../features/seeker_dashboard/presentation/pages/seeker_dashboard_view.dart';
import '../../features/seeker_dashboard/presentation/pages/seekers_list_view.dart';
import '../../features/walk_through/presentation/pages/walk_through_pages/walk_through_pages.dart';
import '../../features/course_description/presentation/pages/course_description_view.dart';
import '../../features/walk_through/presentation/pages/welcome_page.dart';
import '../../features/wallet/presentation/pages/wallet_no_doc_view.dart';
import 'path_routing.dart';

/// Class responsible for handling app routes and generating appropriate route widgets.
class AppRoutes {
  /// Generates and returns the appropriate route based on the provided [RouteSettings].
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.main:
        // Return a material route for the main route, displaying HomeTabs widget.
        return _materialRoute(const SplashPage());

      case Routes.welcomePage:
        return customPageRoute(const WelcomePage());

      // case Routes.HealthRecordsPage:
      //   return customPageRoute(HealthRecordsPage());



      case Routes.createAppointmentsPage:
        final args = settings.arguments as CreateAppointmentArgs?;
        return customPageRoute(CreateAppointment(createAppointmentArgs: args,));

      case Routes.AddBeneficiaryPage:
        return customPageRoute(AddBeneficiaryPage());

      case Routes.IssuePrescriptionPage:
        final userData = settings.arguments as UserDataEntity?;
        return customPageRoute(IssuePrescriptionPage(userData: userData));


      case Routes.ViewBeneficiaryPage:
        return customPageRoute(ViewBeneficiaryPage());

      case Routes.viewAppointmentPage:
        final userData = settings.arguments as UserDataEntity?;
        return customPageRoute(ViewAppointment(userData: userData));
      case Routes.walkThrough:
        // Return a material route for the main route, displaying HomeTabs widget.
        return customPageRoute(const WalkThroughPages());
      case Routes.HealthDocuments:
      // Return a material route for the main route, displaying HomeTabs widget.
        return customPageRoute(HealthDocumentsPage());


      case Routes.walkThrough:
      // Return a material route for the main route, displaying HomeTabs widget.
        return customPageRoute(const WalkThroughPages());

      case Routes.accessLocationPage:
        // Return a material route for the main route, displaying HomeTabs widget.
        return customPageRoute(const LocationAccessPage());
      case Routes.selectLanguageScreen:
        // Return a material route for the main route, displaying HomeTabs widget.
        return customPageRoute(const SelectLanguageScreen());
      case Routes.login:
        // Return a material route for the main route, displaying HomeTabs widget.
        var userCheck = settings.arguments as bool?;
        userCheck ??= false;
        return customPageRoute(PhoneNumberView(userCheck: userCheck));
      case Routes.otp:
        return customPageRoute(
          const VerifyOtpView(),
        );
      case Routes.mpin:
        // Return a material route for the OTP route, displaying OtpView widget.
        return customPageRoute(
          const GenerateMpinScreen(),
        );
      case Routes.kyc:
        return sl<SharedPreferencesHelper>().getBoolean(PrefConstKeys.appForBelem)
            ? customPageRoute(const CompleteProfileViewBelem())
            : customPageRoute(const CompleteProfileView());
      case Routes.chooseRole:
        return customPageRoute(const ChooseRoleView());
      case Routes.home:
        return customPageRoute(const HomeTabBarWidget());
      case Routes.seekerHome:
        return customPageRoute(const SeekerTabBarWidget());
      case Routes.courseDescription:
        // Return a material route for the main route, displaying HomeTabs widget.
        var transactionId = settings.arguments as String?;
        transactionId ??= "";
        return customPageRoute(CourseDescriptionView(transactionId: transactionId));
      case Routes.startCoursePage:
        var courseUrl = settings.arguments as String?;
        courseUrl ??= "";
        return customPageRoute(StartCoursePage(courseUrl: courseUrl));
      case Routes.wallet:
        return customPageRoute(const WalletNoDocumentView());
      case Routes.resetMpin:
        return customPageRoute(const ResetMpinScreen());
      case Routes.chooseDomain:
        return customPageRoute(const ChooseDomainScreen());
      case Routes.selectCategory:
        return customPageRoute(const SelectCategoryScreen());
      case Routes.seekerOnSearchResult:
        return customPageRoute(const SeekerSearchResultView());
      case Routes.seekersList:
        return customPageRoute(const SeekersListView());
      case Routes.seekerDashboard:
        return customPageRoute(const SeekerDashboardView());
      case Routes.shareDocument:
        return customPageRoute(const ShareDocumentScreen());
      case Routes.addDoument:
        return customPageRoute(const AddDocumentView());
      case Routes.applyCourse:
        return customPageRoute(const ApplyCourseScreen());
      case Routes.courseDocument:
        return customPageRoute(const CourseDocumentScreen());
      case Routes.thanksForApplying:
        return customPageRoute(const ThanksForApplyingScreen());
      case Routes.myOrders:
        return customPageRoute(const MyOrdersView());
      case Routes.doctorDetail:
        final doctor = settings.arguments as Doctor;
        return customPageRoute(DoctorDetailScreen(doctor: doctor,));



      case Routes.certificate:
        final arguments = settings.arguments as CertificateViewArguments;
        return customPageRoute(CertificateView(arguments: arguments));
      case Routes.editProfile:
        final userData = settings.arguments as UserDataEntity?;
        return customPageRoute(SeekerEditProfile(userData: userData));
      case Routes.payment:
        final url = settings.arguments as String?;
        return customPageRoute(PaymentScreen(paymentUrl: url!));
      default:
        // Return a default material route, displaying SplashView for unknown routes.
        return customPageRoute(const SplashPage());
    }
  }

  /// Private method to create a [MaterialPageRoute] with the provided widget.
  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute<dynamic>(builder: (_) => view);
  }

  /// Private method to create a [customPageRoute] with the provided widget & animation.
  static Route<dynamic> customPageRoute(Widget view) {
    return PageRouteBuilder(
      // Builds the page with the specified [view].
      pageBuilder: (_, __, ___) => view,
      // Builds the transition animation.
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          // Animates the position from off-screen right to the center of the screen.
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Start position (off-screen right)
            end: Offset.zero, // End position (center of the screen)
          ).animate(animation),
          child: child, // Displays the child widget during the transition.
        );
      },
    );
  }
}
