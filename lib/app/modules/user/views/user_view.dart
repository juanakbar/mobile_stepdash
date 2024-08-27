import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/data/login_provider.dart';
import 'package:stepmotor/app/modules/login/controllers/login_controller.dart';
import 'package:stepmotor/app/modules/user/views/user_detail.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/components/item_account.dart';
import 'package:stepmotor/components/modal_imagepicker.dart';
import 'package:stepmotor/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/user_controller.dart';
import 'package:sp_util/sp_util.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final userDetail = controller.userDetail;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          Obx(
            () {
              final imagePath = controller.imagePath.value;
              return (imagePath != '' && imagePath.isNotEmpty)
                  ? TextButton(
                      onPressed: () {
                        // Action saat tombol "Simpan" ditekan
                      },
                      child: const Text('Simpan'),
                    )
                  : const SizedBox.shrink(); // Mengembalikan widget kosong
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            const SizedBox(height: 20.0),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.grey[200]!),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => modalPicture(
                    ctx: context,
                    onPressedChange: () async {
                      Navigator.pop(context);
                      await controller.pickImageFromGallery();
                    },
                    onPressedTake: () async {
                      Navigator.pop(context);
                      await controller.pickImageFromCamera();
                    },
                  ),
                  child: Obx(
                    () {
                      final avatar = userDetail?['avatar'];
                      final imagePath = controller.imagePath.value;
                      if (imagePath.isNotEmpty) {
                        print('imagepath');
                        // Kondisi 3: Gambar dari galeri atau kamera
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(File(imagePath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      } else if (avatar != null &&
                          avatar.contains('https://api.dicebear.com/')) {
                        print('dicebar');
                        // Kondisi 1: Avatar dari Dicebear API
                        return Align(
                          alignment: Alignment.center,
                          child: SvgPicture.network(
                            avatar,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                            placeholderBuilder: (BuildContext context) =>
                                const CircularProgressIndicator(),
                          ),
                        );
                      } else if (avatar != null &&
                          Uri.tryParse(avatar)?.hasAbsolutePath == true) {
                        // Kondisi 2: Avatar dari API (bukan Dicebear)
                        print('api laravel');
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Kondisi default jika tidak ada gambar yang tersedia
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: TextCustom(
                text: userDetail?['nama'] ?? '',
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5.0),
            Center(
              child: TextCustom(
                text: userDetail?['email'] ?? '',
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 15.0),
            const TextCustom(text: 'Account', color: Colors.grey),
            const SizedBox(height: 10.0),
            ItemAccount(
              text: 'Profile setting',
              icon: Icons.person,
              colorIcon: 0xff01C58C,
              onPressed: () => {controller.getMyProfile()},
            ),
            ItemAccount(
              text: 'Change Password',
              icon: Icons.lock_rounded,
              colorIcon: 0xff1B83F5,
              onPressed: () => {},
            ),
            ItemAccount(
              text: 'Logout',
              icon: Icons.logout,
              colorIcon: 0xFFC62828,
              onPressed: () => {
                LoginController().logout(SpUtil.getString('token').toString())
                // LoginProvider().logout(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
