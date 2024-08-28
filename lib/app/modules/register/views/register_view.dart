import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/components/main_button.dart';
import 'package:stepmotor/components/tabItem.dart';
import 'package:stepmotor/components/text_field.dart';
import 'package:stepmotor/theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../controllers/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  RegisterController controller = Get.put(RegisterController());

  final List<String> roleItems = [
    'Driver',
    'Customer',
    'Mekanik',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackBG,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              const Text(
                'Create new account',
                style: headline1,
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Please fill in the form to continue',
                style: headline3,
              ),
              const SizedBox(height: 60.0),
              textFild(
                controller: controller.nama,
                image: 'user.svg',
                keyBordType: TextInputType.name,
                hintTxt: 'Nama',
              ),
              textFild(
                controller: controller.userName,
                image: 'user.svg',
                keyBordType: TextInputType.name,
                hintTxt: 'Username',
              ),
              textFild(
                controller: controller.userEmail,
                keyBordType: TextInputType.emailAddress,
                image: 'user.svg',
                hintTxt: 'Email Address',
              ),
              textFild(
                controller: controller.userPh,
                image: 'user.svg',
                keyBordType: TextInputType.phone,
                hintTxt: 'Phone Number',
              ),
              textFild(
                controller: controller.userPass,
                isObs: true,
                image: 'hide.svg',
                hintTxt: 'Password',
              ),
              textFild(
                controller: controller.alamat,
                isObs: true,
                image: 'user.svg',
                hintTxt: 'Alamat',
              ),
              Container(
                height: 70.0,
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: blackTextFild,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 270.0,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Pilih Peran Kamu',
                          style: hintStyle,
                        ),
                        items: roleItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item,
                                      style: const TextStyle(color: black)),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Mohon Pilih Peran.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          //Do something when selected item is changed.
                          controller.role.text = value.toString();
                        },
                        onSaved: (value) {
                          selectedValue = value.toString();
                        },
                        // buttonStyleData: const ButtonStyleData(
                        //   padding: EdgeInsets.only(right: 8),
                        // ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80.0),
              Mainbutton(
                onTap: () {
                  controller.register();
                },
                text: 'Sign Up',
                btnColor: blueButton,
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Have an account? ',
                      style: headline.copyWith(
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: ' Sign In',
                      style: headlineDot.copyWith(
                        fontSize: 14.0,
                      ),
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
