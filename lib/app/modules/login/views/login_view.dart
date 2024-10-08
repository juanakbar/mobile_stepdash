import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/modules/register/controllers/register_controller.dart';
import 'package:stepmotor/app/modules/register/views/register_view.dart';
import 'package:stepmotor/components/main_button.dart';
import 'package:stepmotor/components/text_field.dart';

import '../controllers/login_controller.dart';
import 'package:stepmotor/theme.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackBG,
      body: Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50.0,
              ),
              Text(
                'Welcome Back!',
                style: headline1,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'Please sign in to your account',
                style: headline3,
              ),
              const SizedBox(
                height: 60.0,
              ),
              textFild(
                controller: controller.TextEditingControllers['email'],
                image: 'user.svg',
                hintTxt: 'Username',
              ),
              textFild(
                controller: controller.TextEditingControllers['password'],
                image: 'hide.svg',
                isObs: true,
                hintTxt: 'Password',
              ),
              const SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: headline3,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Mainbutton(
                      onTap: () {
                        controller.login();
                      },
                      text: 'Sign in',
                      btnColor: blueButton,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.lazyPut(() => RegisterController());
                        Get.to(() => const RegisterView());
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Don\' have an account? ',
                            style: headline.copyWith(
                              fontSize: 14.0,
                            ),
                          ),
                          TextSpan(
                            text: ' Sign Up',
                            style: headlineDot.copyWith(
                              fontSize: 14.0,
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    // Scaffold(
    //   appBar: AppBar(
    //     iconTheme: const IconThemeData(color: Colors.white),
    //     backgroundColor: Colors.transparent,
    //     elevation: 0,
    //   ),
    //   extendBodyBehindAppBar: true,
    //   body: Stack(
    //     children: [
    //       Image.asset(
    //         'assets/images/bg1.png',
    //         fit: BoxFit.cover,
    //         width: double.infinity,
    //         height: double.infinity,
    //       ),
    //       SafeArea(
    //         child: Column(
    //           children: [
    //             const Expanded(
    //               flex: 1,
    //               child: SizedBox(
    //                 height: 10,
    //               ),
    //             ),
    //             Expanded(
    //               flex: 7,
    //               child: Container(
    //                 padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
    //                 decoration: const BoxDecoration(
    //                   color: Colors.white,
    //                   borderRadius: BorderRadius.only(
    //                     topLeft: Radius.circular(40.0),
    //                     topRight: Radius.circular(40.0),
    //                   ),
    //                 ),
    //                 child: SingleChildScrollView(
    //                   child: Form(
    //                     key: controller.formKey,
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           'Login',
    //                           style: TextStyle(
    //                             fontSize: 30.0,
    //                             fontFamily: 'Poppins',
    //                             fontWeight: FontWeight.w900,
    //                             color: lightColorScheme.primary,
    //                           ),
    //                         ),
    //                         const SizedBox(
    //                           height: 40.0,
    //                         ),
    //                         TextFormField(
    //                           keyboardType: TextInputType.emailAddress,
    //                           controller:
    //                               controller.TextEditingControllers['email'],
    //                           validator: (value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter Email';
    //                             }
    //                             return null;
    //                           },
    //                           decoration: InputDecoration(
    //                             label: const Text('Email'),
    //                             hintText: 'Enter Email',
    //                             hintStyle: const TextStyle(
    //                               fontFamily: 'Poppins',
    //                               color: Colors.black26,
    //                             ),
    //                             border: OutlineInputBorder(
    //                               borderSide: const BorderSide(
    //                                 color:
    //                                     Colors.black12, // Default border color
    //                               ),
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                             enabledBorder: OutlineInputBorder(
    //                               borderSide: const BorderSide(
    //                                 color:
    //                                     Colors.black12, // Default border color
    //                               ),
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(
    //                           height: 25.0,
    //                         ),
    //                         TextFormField(
    //                           controller:
    //                               controller.TextEditingControllers['password'],
    //                           obscureText: true,
    //                           obscuringCharacter: '*',
    //                           validator: (value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter Password';
    //                             }
    //                             return null;
    //                           },
    //                           decoration: InputDecoration(
    //                             label: const Text('Password'),
    //                             hintText: 'Enter Password',
    //                             hintStyle: const TextStyle(
    //                               fontFamily: 'Poppins',
    //                               color: Colors.black26,
    //                             ),
    //                             border: OutlineInputBorder(
    //                               borderSide: const BorderSide(
    //                                 color:
    //                                     Colors.black12, // Default border color
    //                               ),
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                             enabledBorder: OutlineInputBorder(
    //                               borderSide: const BorderSide(
    //                                 color:
    //                                     Colors.black12, // Default border color
    //                               ),
    //                               borderRadius: BorderRadius.circular(10),
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(
    //                           height: 25.0,
    //                         ),
    //                         const SizedBox(
    //                           height: 25.0,
    //                         ),
    //                         SizedBox(
    //                           width: double.infinity,
    //                           child: ElevatedButton(
    //                             style: ElevatedButton.styleFrom(
    //                               minimumSize: Size(80, 50),
    //                               backgroundColor: controller.isLoading.value
    //                                   ? Colors.grey
    //                                   : lightColorScheme.primary,
    //                               elevation: 0,
    //                               shape: const RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.all(
    //                                   Radius.circular(50),
    //                                 ),
    //                               ),
    //                             ),
    //                             onPressed: () {
    //                               controller.isLoading.value
    //                                   ? null
    //                                   : controller.login();
    //                             },
    //                             child: Obx(
    //                               () {
    //                                 return controller.isLoading.value
    //                                     ? const CircularProgressIndicator(
    //                                         color: Colors.white,
    //                                         strokeWidth: 4,
    //                                       )
    //                                     : const Text(
    //                                         'Login',
    //                                         style:
    //                                             TextStyle(color: Colors.white),
    //                                       );
    //                               },
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(
    //                           height: 25.0,
    //                         ),
    //                         const SizedBox(
    //                           height: 25.0,
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
