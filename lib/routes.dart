import 'package:feqh_book/core/const/approutes.dart';
import 'package:feqh_book/view/homescreen.dart';
import 'package:feqh_book/view/splashscreen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(name: Approutes.splashScreen, page: () => SplashScreen()),
  GetPage(name: Approutes.homeScreen, page: () => HomeScreen()),
];
