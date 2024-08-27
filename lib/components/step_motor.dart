import 'package:flutter/material.dart';
import 'package:stepmotor/app/modules/home/controllers/home_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class StepMotor extends StatefulWidget {
  const StepMotor({Key? key}) : super(key: key);

  @override
  _StepMotorState createState() => _StepMotorState();
}

class _StepMotorState extends State<StepMotor> {
  final HomeController homeController = HomeController();
  PanelController panelController = PanelController();
  @override
  void initState() {
    super.initState();
    homeController.startLocationFocusNode.addListener(_handleFocusChange);
    homeController.endLocationFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    // Pastikan untuk melepaskan FocusNodes ketika tidak digunakan lagi
    homeController.startLocationFocusNode.dispose();
    homeController.endLocationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationInputRow(
            focusNode: homeController.startLocationFocusNode,
            iconData: Icons.radio_button_checked,
            color: Colors.orange,
            controller: homeController.startLocationName,
            hintText: 'Lokasi Kamu',
          ),
          const Divider(
            color: Colors.black26,
            indent: 24.0,
            endIndent: 24.0,
          ),
          _buildLocationInputRow(
            focusNode: homeController.endLocationFocusNode,
            iconData: Icons.location_on,
            color: Colors.red,
            controller: homeController.endLocationName,
            hintText: 'Lokasi Tujuan Kamu',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputRow({
    required IconData iconData,
    required Color color,
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: color),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
              onChanged: (text) {
                // Memperbarui UI setelah teks diubah
                setState(() {});
              },
            ),
          ),
          controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                )
              : const SizedBox
                  .shrink(), // Mengembalikan widget kosong jika teks kosong
        ],
      ),
    );
  }

  void _handleFocusChange() {
    if (homeController.startLocationFocusNode.hasFocus ||
        homeController.endLocationFocusNode.hasFocus) {
      panelController.open();
    }
  }
}
