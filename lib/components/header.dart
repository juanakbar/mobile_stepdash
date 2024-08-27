import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';

class Header extends StatelessWidget {
  final String userName;
  final String email;
  const Header({super.key, required this.userName, required this.email});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hallo, $userName !',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w200),
                    )
                  ],
                )),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }
}
