// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:stepmotor/app/controllers/user_controller.dart';
// import 'package:stepmotor/app/modules/profile/controllers/profile_controller.dart';
// import 'package:stepmotor/components/modal_imagepicker.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class ImagePicker extends StatelessWidget {
//   const ImagePicker({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 150,
//       width: 150,
//       decoration: BoxDecoration(
//         border: Border.all(style: BorderStyle.solid, color: Colors.grey[200]!),
//         shape: BoxShape.circle,
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(100),
//         onTap: () => modalPicture(
//           ctx: context,
//           onPressedChange: () async {
//             Navigator.pop(context);
//             await profileController.pickImageFromGallery();
//           },
//           onPressedTake: () async {
//             Navigator.pop(context);
//             await profileController.pickImageFromCamera();
//           },
//         ),
//         child: Obx(() {
//           // Cek apakah userDetail dan avatar tidak null
//           if (profileController.userDetail?['avatar'] != null) {
//             final avatarUrl = profileController.userDetail!['avatar'];

//             // Tentukan apakah avatar adalah URL dari API Dicebear atau gambar lokal
//             if (avatarUrl.contains('https://api.dicebear.com/')) {
//               // Kembalikan widget yang menampilkan SVG jika URL mengandung Dicebear
//               return Align(
//                 alignment: Alignment.center,
//                 child: SvgPicture.network(
//                   avatarUrl,
//                   height: 120,
//                   width: 120,
//                   fit: BoxFit.cover,
//                   placeholderBuilder: (BuildContext context) =>
//                       const CircularProgressIndicator(),
//                 ),
//               );
//             } else {
//               // Kembalikan widget yang menampilkan gambar bitmap (JPEG/PNG)
//               return Align(
//                 alignment: Alignment.center,
//                 child: Container(
//                   height: 120,
//                   width: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: profileController.imagePath.isNotEmpty
//                           ? FileImage(File(profileController.imagePath.value))
//                           : const AssetImage('assets/images/default_avatar.png')
//                               as ImageProvider,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               );
//             }
//           } else {
//             // Tampilkan CircularProgressIndicator jika tidak ada avatar atau imagePath
//             return const CircularProgressIndicator();
//           }
//         }),
//       ),
//     );
//   }
// }
