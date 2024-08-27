import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/modules/user/controllers/user_controller.dart';
import 'package:stepmotor/theme.dart';
import 'package:stepmotor/components/form_field.dart';

class UserDetail extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    final userDetail = controller.userDetail;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    children: [
                      FormFieldApp(
                        label: 'Nama',
                        controller: controller.namaController,
                        hintText: 'Masukkan Nama Anda',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 25.0),
                      FormFieldApp(
                        label: 'Nomor Telepon',
                        controller: controller.teleponController,
                        hintText: 'Masukkan Nomor Telepon',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20.0),
                      FormFieldApp(
                        label: 'User Name',
                        controller: controller.usernameController,
                        hintText: 'Masukkan User Name Anda',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 25.0),
                      FormFieldApp(
                        label: 'Alamat',
                        controller: controller.alamatController,
                        hintText: 'Masukkan Alamat Anda',
                        keyboardType: TextInputType.streetAddress,
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),

              // Tombol Update Profile di bagian bawah layar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Panggil fungsi untuk update profile
                    controller.updateProfile();
                  },
                  child: const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
