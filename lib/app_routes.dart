import 'package:get/get.dart';
import 'package:event_maker/views/splash/splash_view.dart';
import 'package:event_maker/views/splash/splash_binding.dart';
import 'package:event_maker/views/onboarding/onboarding_view.dart';
import 'package:event_maker/views/onboarding/onboarding_binding.dart';
import 'package:event_maker/views/auth/user_type_view.dart';
import 'package:event_maker/views/auth/login_view.dart';
import 'package:event_maker/views/auth/auth_binding.dart';
import 'package:event_maker/views/auth/signup_view.dart';
import 'package:event_maker/views/auth/forgot_password_view.dart';
import 'package:event_maker/views/auth/otp_verification_view.dart';
import 'package:event_maker/views/auth/reset_password_view.dart';
import 'package:event_maker/views/auth/congratulations_view.dart';
import 'package:event_maker/views/auth/signup_step_two_view.dart';
import 'package:event_maker/views/auth/provider_details_view.dart';
import 'package:event_maker/views/auth/get_started_view.dart';
import 'package:event_maker/views/auth/provider_request_sent_view.dart';
import 'package:event_maker/views/auth/language_selection_view.dart';
import 'package:event_maker/views/auth/language_selection_controller.dart';
import 'package:event_maker/views/service_provider_flow/profile/profile_view.dart' as sp_profile;
import 'package:event_maker/views/customer_flow/profile/profile_view.dart' as customer_profile;
import 'package:event_maker/views/profile/profile_settings_view.dart';
import 'package:event_maker/views/profile/add_image_view.dart';
import 'package:event_maker/views/profile/change_password_view.dart';
import 'package:event_maker/views/customer_flow/profile/transactions_view.dart';
import 'package:event_maker/views/service_provider_flow/profile/wallet_view.dart';
import 'package:event_maker/views/customer_flow/bookmarks/bookmarks_view.dart';
import 'package:event_maker/views/customer_flow/categories/categories_view.dart';
import 'package:event_maker/views/customer_flow/categories/categories_binding.dart';
import 'package:event_maker/views/profile/faq_view.dart';
import 'package:event_maker/views/profile/contact_us_view.dart';
import 'package:event_maker/views/profile/profile_binding.dart';
import 'package:event_maker/views/profile/profile_settings_binding.dart';
import 'package:event_maker/views/customer_flow/customer_flow_scaffold.dart';
import 'package:event_maker/views/customer_flow/home/customer_home_binding.dart';
import 'package:event_maker/views/service_provider_flow/service_provider_controller.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_controller.dart';
import 'package:event_maker/views/service_provider_flow/requests/requests_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:event_maker/views/service_provider_flow/service_provider_scaffold.dart';
import 'package:event_maker/views/customer_flow/map/map_results_view.dart';
import 'package:event_maker/views/customer_flow/map/map_results_binding.dart';
import 'package:event_maker/views/customer_flow/map/map_search_view.dart';
import 'package:event_maker/views/customer_flow/map/map_search_controller.dart';
import 'package:event_maker/views/notifications/customer_notification_view.dart';
import 'package:event_maker/views/notifications/notification_binding.dart';
import 'package:event_maker/views/notifications/notification_controller.dart';
import 'package:event_maker/views/notifications/notification_view.dart';
import 'package:event_maker/views/customer_flow/search/search_view.dart';
import 'package:event_maker/views/customer_flow/search/search_binding.dart';
import 'package:event_maker/models/vendor_profile_model.dart';
import 'package:event_maker/views/profile/vendor_profile.dart';
import 'package:event_maker/views/customer_flow/services/category_services_view.dart';
import 'package:event_maker/views/customer_flow/services/category_services_controller.dart';

import 'package:event_maker/views/customer_flow/service_booking/book_service_date_view.dart';
import 'package:event_maker/views/customer_flow/service_booking/book_service_request_view.dart';
import 'package:event_maker/views/customer_flow/service_booking/payment_confirmation_view.dart';
import 'package:event_maker/views/customer_flow/service_booking/payment_view.dart';
import 'package:event_maker/views/customer_flow/service_booking/booking_request_sent_view.dart';
import 'package:event_maker/views/customer_flow/service_booking/booking_binding.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_decision_view.dart';
import 'package:event_maker/views/service_provider_flow/services_details/sp_service_detail_view.dart';
import 'package:event_maker/views/service_provider_flow/services_details/sp_service_detail_controller.dart';
import 'package:event_maker/views/service_provider_flow/documents/documents_view.dart';
import 'package:event_maker/views/service_provider_flow/documents/add_document_view.dart';
import 'package:event_maker/views/service_provider_flow/documents/documents_binding.dart';
import 'package:event_maker/views/service_provider_flow/schedule/schedule_view.dart';
import 'package:event_maker/views/service_provider_flow/schedule/schedule_binding.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_list_view.dart';
import 'package:event_maker/views/service_provider_flow/certifications/view_certificate_view.dart'
    as sp_view;
import 'package:event_maker/views/service_provider_flow/certifications/add_edit_certificate_view.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_controller.dart';
import 'package:event_maker/views/service_provider_flow/active_orders/sp_active_orders_view.dart';
import 'package:event_maker/views/chats/chat_detail_view.dart';
import 'package:event_maker/views/chats/chat_view_binding.dart';
import 'package:event_maker/views/customer_flow/services/add_review_view.dart';
import 'package:event_maker/views/customer_flow/services/spam_report_view.dart';
import 'package:event_maker/views/customer_flow/services/view_certificate.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String languageSelection = '/language-selection';
  static const String userType = '/user-type';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPasswordNew = '/reset-password-new';
  static const String congratulations = '/congratulations';
  static const String signupStepTwo = '/signup-step-two';
  static const String providerDetails = '/provider-details';
  static const String getStarted = '/get-started';
  static const String providerRequestSent = '/request-sent';
  static const String customerProfile = '/customer-profile';
  static const String spProfile = '/sp-profile';
  static const String profileSettings = '/profile-settings';
  static const String addImage = '/add-image';
  static const String changePassword = '/change-password';
  static const String transactions = '/transactions';
  static const String bookmarks = '/bookmarks';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String customerHome = '/customer-home';
  static const String serviceProviderHome = '/service-provider-home';
  static const String notifications = '/notifications';
  static const String customerNotifications = '/customer-notifications';
  static const String serviceProviderNotifications =
      '/service-provider-notifications';
  static const String mapResults = '/map-results';
  static const String mapSearch = '/map-search';
  static const String vendorProfile = '/vendor-profile';
  static const String bookServiceDate = '/book-service-date';
  static const String bookServiceRequest = '/book-service-request';
  static const String payment = '/payment';
  static const String paymentConfirmation = '/payment-confirmation';
  static const String bookingRequestSent = '/booking-request-sent';
  static const String spamReport = '/spam-report';
  static const String viewCertificate = '/view-certificate';
  static const String addReview = '/add-review';
  static const String categoryServices = '/category-services';
  static const String serviceDetailWithDecision = '/service-detail-decision';
  static const String spDocuments = '/sp-documents-view';
  static const String spAddDocument = '/sp-add-document-view';
  static const String spSchedule = '/sp-schedule-view';
  static const String addService = '/add-service';
  static const String addEvent = '/add-event';
  static const String addTraining = '/add-training';
  static const String spWallet = '/sp-wallet';
  static const String spCertifications = '/sp-certifications';
  static const String spViewCertification = '/sp-view-certification';
  static const String spAddCertification = '/sp-add-certification';
  static const String spEditCertification = '/sp-edit-certification';
  static const String spActiveOrders = '/sp-active-orders';
  static const String chatDetail = '/chat-detail';
  static const String search = '/search';
  static const String categories = '/categories';
  static const String spServiceDetail = '/sp-service-detail';

  static final routes = [
    GetPage(
      name: notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: customerNotifications,
      page: () => const CustomerNotificationView(),
      binding: CustomerNotificationBinding(),
    ),
    GetPage(
      name: serviceProviderNotifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: spDocuments,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: spAddDocument,
      page: () => AddDocumentView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: spSchedule,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: languageSelection,
      page: () => const LanguageSelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LanguageSelectionController>(
          () => LanguageSelectionController(),
        );
      }),
    ),
    GetPage(
      name: userType,
      page: () => const UserTypeView(),
      binding: AuthBinding(),
    ),
    GetPage(name: login, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(
      name: signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: resetPasswordNew,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: congratulations,
      page: () => const CongratulationsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: signupStepTwo,
      page: () => const SignupStepTwoView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: providerDetails,
      page: () => const ProviderDetailsView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: getStarted,
      page: () => const GetStartedView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: providerRequestSent,
      page: () => const ProviderRequestSentView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: customerProfile,
      page: () => const customer_profile.ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: spProfile,
      page: () => const sp_profile.ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: profileSettings,
      page: () => const ProfileSettingsView(),
      binding: ProfileSettingsBinding(),
    ),
    GetPage(name: addImage, page: () => const AddImageView()),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(name: transactions, page: () => const TransactionsView()),
    GetPage(name: spWallet, page: () => const WalletView()),
    GetPage(
      name: bookmarks,
      page: () => const BookmarksView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: faq, page: () => const FAQView()),
    GetPage(name: contactUs, page: () => const ContactUsView()),
    GetPage(
      name: customerHome,
      page: () => const CustomerFlowScaffold(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: serviceProviderHome,
      page: () => const ServiceProviderScaffold(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ServiceProviderController>(
          () => ServiceProviderController(),
        );
        Get.lazyPut<SPHomeController>(() => SPHomeController());
        Get.lazyPut<RequestsController>(() => RequestsController());
        Get.lazyPut<SPServicesController>(() => SPServicesController());
        Get.lazyPut<NotificationController>(() => NotificationController());
        Get.put(
          ProfileController(),
        ); // Using put for profile as it might be needed by other views
      }),
    ),
    GetPage(
      name: mapResults,
      page: () => const MapResultsView(),
      binding: MapResultsBinding(),
    ),
    GetPage(
      name: mapSearch,
      page: () => const MapSearchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MapSearchController>(() => MapSearchController());
      }),
    ),
    GetPage(
      name: vendorProfile,
      page: () =>
          VendorProfileView(vendor: Get.arguments as VendorProfileModel),
    ),
    GetPage(
      name: bookServiceDate,
      page: () => const BookServiceDateView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: bookServiceRequest,
      page: () => const BookServiceRequestView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: payment,
      page: () => const PaymentView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: paymentConfirmation,
      page: () => const PaymentConfirmationView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: bookingRequestSent,
      page: () => const BookingRequestSentView(),
      binding: BookingBinding(),
    ),
    // Category Services route
    GetPage(
      name: categoryServices,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return CategoryServicesView(
          categoryType: arguments?['categoryType'] ?? 'catering',
          categoryName: arguments?['categoryName'] ?? 'Services',
        );
      },
      binding: BindingsBuilder(() {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final categoryType = arguments?['categoryType'] ?? 'catering';
        Get.lazyPut<CategoryServicesController>(
          () => CategoryServicesController(
            categoryType: categoryType,
            categoryName: arguments?['categoryName'] ?? 'Services',
          ),
          tag: '${categoryType}_${arguments?["categoryName"] ?? "Services"}',
        );
      }),
    ),
    GetPage(
      name: serviceDetailWithDecision,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return ServiceDetailDecisionView(request: arguments?['request']);
      },
    ),
    GetPage(
      name: addService,
      page: () => const AddServiceView(),
      binding: AddScreensBinding(),
    ),
    GetPage(
      name: spCertifications,
      page: () => const CertificationListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CertificationController>(() => CertificationController());
      }),
    ),
    GetPage(
      name: spViewCertification,
      page: () => const sp_view.ViewCertificateView(),
    ),
    GetPage(
      name: spAddCertification,
      page: () => const AddEditCertificateView(isEdit: false),
    ),
    GetPage(
      name: spEditCertification,
      page: () {
        final certId = Get.arguments as int;
        return AddEditCertificateView(isEdit: true, certificateId: certId);
      },
    ),
    GetPage(name: spActiveOrders, page: () => const SPActiveOrdersView()),
    GetPage(
      name: chatDetail,
      page: () => const ChatDetailView(),
      binding: ChatViewBinding(),
    ),
    GetPage(
      name: search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    // Service Provider - Service Detail route
    GetPage(
      name: spServiceDetail,
      page: () => const SPServiceDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SPServicedetailController>(() => SPServicedetailController());
      }),
    ),
    // Customer flow - vendor profile related routes
    GetPage(name: addReview, page: () => const AddReviewView()),
    GetPage(name: viewCertificate, page: () => const ViewCertificate()),
    GetPage(name: spamReport, page: () => const SpamReportView()),
  ];
}
