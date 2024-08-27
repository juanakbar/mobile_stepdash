import 'package:flutter/material.dart';
import 'package:stepmotor/theme.dart';

class Bengkel {
  final String namabengkel;
  final double distance;

  Bengkel({
    required this.namabengkel,
    required this.distance,
  });

  factory Bengkel.fromMap(Map<String, dynamic> map) {
    return Bengkel(
      namabengkel: map['namabengkel'],
      distance: map['distance'],
    );
  }

  // Static data
  static List<Bengkel> get staticBengkels => [
        Bengkel(
          namabengkel: 'Yamaha Just Great Cibeureum',
          distance: 15000,
        ),
        Bengkel(
          namabengkel: 'Yamaha Cimahi Motor Official',
          distance: 25000,
        ),
        Bengkel(
          namabengkel: 'Yamaha Metro Cimahi Motor',
          distance: 30000,
        ),
      ];
}

class BengkelCard extends StatelessWidget {
  final Bengkel bengkel;

  const BengkelCard({super.key, required this.bengkel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black54, blurRadius: 4, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bengkel.namabengkel,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.motorcycle,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 16,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '> ${bengkel.distance} km',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  )
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
