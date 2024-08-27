import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/modules/user/controllers/user_controller.dart';
import 'package:stepmotor/app/modules/user/views/user_view.dart';

import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/components/header.dart';
import 'package:stepmotor/theme.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    print('Routes.USER: ${Routes.USER}'); // Debug print
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: green2,
        elevation: 0,
        toolbarHeight: 80,
        title: Header(
            userName: controller.userDetail?['nama']!,
            email: controller.userDetail?['email']!),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 35,
              height: 35,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.lazyPut(() => UserController());
                      Get.to(() => const UserView());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35 / 2),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: controller.userDetail?['avatar'] != null &&
                              controller.userDetail?['avatar']
                                  .contains('https://api.dicebear.com')
                          ? SvgPicture.network(
                              controller.userDetail?['avatar']!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (BuildContext context) =>
                                  Container(
                                padding: const EdgeInsets.all(10.0),
                                child: const CircularProgressIndicator(),
                              ),
                            )
                          : Image.network(
                              controller.userDetail?['avatar']!,
                              fit: BoxFit.cover,

                              // Optional: You can add an errorBuilder here
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return SvgPicture.network(
                                  'https://api.dicebear.com/9.x/lorelei/svg?seed=${controller.userDetail?['username']}',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Container(
          child: HomeController.widgetOptions
              .elementAt(controller.selectedIndex.value),
        );
      }),
      bottomNavigationBar: Obx(
        () {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  activeColor: Colors.black,
                  iconSize: 18,
                  gap: 8,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: const [
                    GButton(
                      icon: LineIcons.home,
                      text: 'Home',
                    ),
                    GButton(
                      icon: LineIcons.fileInvoice,
                      text: 'History',
                    ),
                  ],
                  selectedIndex: controller.selectedIndex.value,
                  onTabChange: (index) {
                    controller.updateIndex(
                        index); // Update selectedIndex using GetX controller
                  }, // Update selectedIndex using GetX controller
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
