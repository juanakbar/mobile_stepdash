import 'package:get/get.dart';

import '../modules/driver/bindings/driver_binding.dart';
import '../modules/driver/views/driver_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/ride/bindings/ride_binding.dart';
import '../modules/ride/views/ride_view.dart';
import '../modules/tracking/bindings/tracking_binding.dart';
import '../modules/tracking/views/tracking_view.dart';
import '../modules/user/bindings/user_binding.dart';
import '../modules/user/views/user_detail.dart';
import '../modules/user/views/user_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.USER,
      page: () => const UserView(),
      binding: UserBinding(),
    ),
    GetPage(
        name: Routes.USER_DETAIL,
        page: () => UserDetail(),
        binding: UserBinding()),
    GetPage(
      name: _Paths.RIDE,
      page: () => RideView(),
      binding: RideBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER,
      page: () => const DriverView(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.TRACKING,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
    ),
  ];
}
