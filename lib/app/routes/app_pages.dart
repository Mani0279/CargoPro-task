import 'package:get/get.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/otp_verification_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/detail/bindings/detail_binding.dart';
import '../../modules/detail/views/detail_view.dart';
import '../../modules/object_form/bindings/object_form_binding.dart';
import '../../modules/object_form/views/object_form_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => OtpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.DETAIL,
      page: () => DetailView(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: Routes.CREATE,
      page: () => ObjectFormView(isEdit: false),
      binding: ObjectFormBinding(),
    ),
    GetPage(
      name: Routes.EDIT,
      page: () => ObjectFormView(isEdit: true),
      binding: ObjectFormBinding(),
    ),
  ];
}