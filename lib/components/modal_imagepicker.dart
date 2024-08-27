import 'package:flutter/material.dart';
import 'package:stepmotor/theme.dart';

void modalPicture({
  required BuildContext ctx,
  VoidCallback? onPressedChange,
  VoidCallback? onPressedTake,
}) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40.0),
    ),
    builder: (context) => Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: -5.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextCustom(
              text: 'Change profile picture',
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
            const SizedBox(height: 10),
            _buildOption(
              text: 'Select an image',
              onTap: onPressedChange,
            ),
            const SizedBox(height: 10),
            _buildOption(
              text: 'Take a picture',
              onTap: onPressedTake,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOption({
  required String text,
  VoidCallback? onTap,
}) {
  return SizedBox(
    height: 50,
    width: double.infinity,
    child: Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextCustom(
              text: text,
              fontSize: 17,
            ),
          ),
        ),
      ),
    ),
  );
}
