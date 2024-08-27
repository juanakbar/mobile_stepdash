import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stepmotor/app/data/user_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stepmotor/app/routes/app_pages.dart';

class UserController extends GetxController {
  final count = 0.obs;

  var imagePath = ''.obs;
  Map<String, dynamic>? userDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;

  Future<void> pickImageFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? photo =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo != null) {
      imagePath.value = photo.path;
    }
  }

  final namaController = TextEditingController();
  final teleponController = TextEditingController();
  final alamatController = TextEditingController();
  final usernameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void onInit() {
    userDetail = SpUtil.getObject('userDetail') as Map<String, dynamic>?;

    super.onInit();
  }

  void updateUserDetails() {
    userDetail = SpUtil.getObject('userDetail') as Map<String, dynamic>?;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void getMyProfile() async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    await UserProvider().getMyProfile().then((value) {
      if (value.statusCode == 200) {
        var myProfile = value.body['user'];
        namaController.text = myProfile['nama'].toString();
        teleponController.text = myProfile['telepon'].toString();
        usernameController.text = myProfile['username'].toString();
        alamatController.text = myProfile['alamat'].toString();

        Get.toNamed(Routes.USER_DETAIL);
      }
    });
    EasyLoading.dismiss();
  }

  void updateProfile() async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    final nama = namaController.text;
    final telepon = teleponController.text;
    final alamat = alamatController.text;
    final username = usernameController.text;
    final data = {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'username': username,
    };
    await UserProvider().updateProfile(data).then((value) async {
      if (value.statusCode == 200) {
        // Simpan data terbaru ke SpUtil
        await SpUtil.putObject('userDetail', value.body['user']);

        // Ambil kembali data yang baru disimpan
        var updatedUserDetail =
            SpUtil.getObject('userDetail') as Map<String, dynamic>?;

        // Perbarui variabel userDetail dengan data terbaru
        userDetail = updatedUserDetail;

        // Memastikan UI terupdate dengan data terbaru
        update();

        // Kembali ke halaman sebelumnya
        updateUserDetails();
        Get.back();
        Get.snackbar('Berhasil', 'Berhasil mengubah data');
      } else {
        print(value.body);
      }
    });
    EasyLoading.dismiss();
  }

  void increment() => count.value++;
}
