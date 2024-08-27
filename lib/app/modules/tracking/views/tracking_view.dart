import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/data/places_api_provider.dart';
import 'package:stepmotor/app/modules/driver/views/driver_view.dart';
import 'package:stepmotor/app/modules/ride/directions_model.dart';
import 'package:stepmotor/driver_service.dart';
import 'package:stepmotor/theme.dart';

import '../controllers/tracking_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sp_util/sp_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrackingView extends StatefulWidget {
  const TrackingView({super.key});

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView> {
  final TrackingController rideController = Get.put(TrackingController());
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  Map<String, dynamic> data = Get.arguments;
  Map<String, dynamic>? userDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;
  final DriverService _driverService = DriverService();
  Timer? _timer; // Menyimpan referensi ke Timer
  String? _nearestDriver;
  bool _isLoading = false;
  LatLng? _driverLocation = const LatLng(0, 0);
  bool _hasSearched = false;
  RxList<Map<String, dynamic>> ordersDetail = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> driverDetail = <Map<String, dynamic>>[].obs;
  Directions? _info;
  RxBool isStatusAccepted = false.obs;
  Set<Marker> _markers = {};
  BitmapDescriptor destinationMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarker;
  StreamSubscription<DatabaseEvent>?
      _driverLocationSubscription; // Deklarasikan variabel untuk menyimpan StreamSubscription
  bool _updateRouteState = false;
  void addCustomIconDestination() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/flag.png', 150);

    setState(() {
      destinationMarkerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  void addCustomIconSource() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/pin.png', 100);

    setState(() {
      sourceMarkerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  void addCustomDriverSource() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/Motor.png', 100);

    setState(() {
      driverMarkerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _searchNearestDriver().then((value) {
      if (_nearestDriver != null) {
        getConfirmationFromDriver();
        getDetailOrders().then((_) {
          _startListeningToDriverLocation();
        });
        addCustomIconSource();
        addCustomIconDestination();
        addCustomDriverSource();
      }
    });

    // _listenToDriverLocation();
  }

  void getPolyLinePoint(
      {required LatLng origin, required LatLng destination}) async {
    final directions = await PlacesApiProvider()
        .getDirections(origin: origin!, destination: destination!);
    setState(() {
      _info = directions;
      CameraUpdate.newLatLngBounds(directions.bounds, 150.0);
    });
  }

  // void _listenToDriverLocation() async {
  //
  // }

  Future<void> getDetailOrders() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/${userDetail!['id']}");

    try {
      DatabaseEvent _ordersRef = await ref.once();
      Map<dynamic, dynamic>? orders =
          _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
      if (orders != null) {
        ordersDetail.add(Map<String, dynamic>.from(orders));
        print("orders['driverId'] ${orders['driverId']}");
        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref("drivers/${orders['driverId']}");
        DatabaseEvent _driverRef = await driverRef.once();
        Map<dynamic, dynamic>? driver =
            _driverRef.snapshot.value as Map<dynamic, dynamic>?;
        if (driver != null) {
          var pickupLoc =
              LatLng(data['pickup']['latitude'], data['pickup']['longitude']);
          var driverLoc = LatLng(
              driver['location']['latitude'], driver['location']['longitude']);
          driverDetail.add(Map<String, dynamic>.from(driver));
          _addMarker('_pickupLoacation', pickupLoc, sourceMarkerIcon);
          getPolyLinePoint(origin: driverLoc!, destination: pickupLoc!);
          print(driver);
        }

        print(orders);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchNearestDriver() async {
    // Hanya menjalankan pencarian jika belum dilakukan
    if (_hasSearched) return;

    setState(() {
      _isLoading = true;
    });

    try {
      EasyLoading.show(status: 'Sedang Mencari Driver...');
      double userLat = data['pickup']['latitude'];
      double userLong = data['pickup']['longitude'];

      String? driverId;
      // Lakukan pencarian berkala hingga driver ditemukan
      while (driverId == null) {
        driverId = await _driverService.findNearestDriver(userLat, userLong);

        if (driverId == null) {
          // Jika driver belum ditemukan, tunggu beberapa detik sebelum mencoba lagi
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      setState(() {
        _nearestDriver = driverId;
        _isLoading = false;
        _hasSearched = true;
      });

      // Update database dengan driverId yang ditemukan
      try {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("requestOrders/${userDetail!['id']}");
        await ref.update({
          "driverId": int.parse(driverId),
        });
        print('Data updated successfully.');
      } catch (e) {
        print('Failed to update data: $e');
      }

      EasyLoading.dismiss();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasSearched = true;
      });

      EasyLoading.dismiss();
      print("Error: $e");
    }
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController googleMapController =
        await _controllerGoogleMap.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 17,
      bearing: 10,
      tilt: 10,
    );
    await googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  void _addMarker(markerID, LatLng pos, icon) {
    final markerId = MarkerId(markerID);
    final marker = Marker(
      markerId: markerId,
      position: pos, // Contoh koordinat
      icon: icon,
    );

    setState(() {
      _markers.add(marker);
      _cameraToPosition(pos);
    });
  }

  void updateRoute() async {
    if (_updateRouteState == true) return;
    // Mendapatkan referensi ke node di Firebase Realtime Database
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/${userDetail!['id']}");

    DatabaseEvent _ordersRef = await ref.once();
    Map<dynamic, dynamic>? orders =
        _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
    if (_updateRouteState == false) {
      print('MASUK MASUK MASUK');
      if (orders != null && orders!['path'] == 'toDropOff') {
        setState(() {
          _updateRouteState = true;
          _markers.removeWhere(
              (marker) => marker.markerId.value == '_pickupLocation');
          var locDriver =
              LatLng(_driverLocation!.latitude, _driverLocation!.longitude);
          var pickUpLoc =
              LatLng(data['dropoff']['latitude'], data['dropoff']['longitude']);
          _addMarker('pickup_marker', locDriver, sourceMarkerIcon);
          _addMarker('dropoff_marker', pickUpLoc, destinationMarkerIcon);
          getPolyLinePoint(origin: _driverLocation!, destination: pickUpLoc!);
        });
      }
    }
  }

  void _startListeningToDriverLocation() {
    if (ordersDetail.isNotEmpty) {
      print("Memulai Listener untuk Lokasi Driver");

      DatabaseReference ref = FirebaseDatabase.instance
          .ref("drivers/${ordersDetail[0]['driverId']}");

      _driverLocationSubscription = ref.onValue.listen((DatabaseEvent event) {
        print("Data driver: ${event.snapshot.value}");

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? driver =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (driver != null) {
            double? lat = driver['location']['latitude'];
            double? lng = driver['location']['longitude'];
            if (lat != null && lng != null) {
              setState(() {
                _driverLocation = LatLng(lat, lng);
                // Update UI atau peta dengan lokasi baru
                _updateDriverLocationOnMap();
                updateRoute();
              });
              print(
                  "Lokasi driver diperbarui: Latitude: $lat, Longitude: $lng");
            }
          } else {
            print("Data driver tidak ditemukan atau kosong.");
          }
        }
      }, onError: (error) {
        print("Error mendapatkan data driver: $error");
      });
    } else {
      print("ordersDetail kosong, tidak memulai listener.");
    }
  }

  void _updateDriverLocationOnMap() async {
    // Update marker atau lokasi di peta jika perlu
    if (_driverLocation != null) {
      setState(() {
        _markers.removeWhere(
            (marker) => marker.markerId.value == '_driverLocation');
        _markers.add(
          Marker(
            markerId: MarkerId('_driverLocation'),
            position: _driverLocation!,
            icon: driverMarkerIcon,
          ),
        );
        _markers.add(
          Marker(
            markerId: MarkerId(
              '_pickupLocation',
            ),
            position: LatLng(
                data['pickup']['latitude'], data['pickup']['longitude'])!,
            icon: sourceMarkerIcon,
          ),
        );
      });
      // Pindahkan kamera ke lokasi driver
      await _cameraToPosition(_driverLocation!);
    }
  }

  void getConfirmationFromDriver() async {
    EasyLoading.show(status: 'Sedang Menunggu Konfirmasi Driver...');
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/${userDetail!['id']}");

    while (!isStatusAccepted.value) {
      try {
        DatabaseEvent _ordersRef = await ref.once();
        Map<dynamic, dynamic>? orderStatus =
            _ordersRef.snapshot.value as Map<dynamic, dynamic>?;

        if (orderStatus != null && orderStatus['status'] == 'accepted') {
          isStatusAccepted.value =
              true; // Status sudah berubah menjadi accepted
        } else {
          // Jika status belum berubah, tunggu sebentar sebelum melakukan pengecekan lagi
          await Future.delayed(
              const Duration(seconds: 1)); // Jeda selama 2 detik
        }
      } catch (e) {
        print('Failed to Get Orders data: $e');
        EasyLoading.dismiss();
        return; // Keluar dari fungsi jika terjadi error
      }
    }

    // Status sudah diterima, tutup EasyLoading
    EasyLoading.dismiss();
  }

  String shortenAddress(String address, {int maxLength = 30}) {
    if (address.length <= maxLength) {
      return address;
    } else {
      return address.substring(0, maxLength) + '...';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _driverLocationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_driverLocation: $_driverLocation");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamu Sedang Dalam Perjalanan'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            compassEnabled: true,
            markers: {
              // Marker(
              //   markerId: const MarkerId('_driverLocation'),
              //   position: LatLng(
              //       _driverLocation!.latitude, _driverLocation!.latitude)!,
              //   icon: sourceMarkerIcon,
              // ),
              ..._markers
            },
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.blue,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            initialCameraPosition: CameraPosition(
              target: _driverLocation!,
              zoom: 20,
            ),
          ),
          Obx(() => isStatusAccepted.value
              ? Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                      padding: const EdgeInsets.all(15.0),
                      height: 235,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.5),
                                blurRadius: 7,
                                spreadRadius: 5)
                          ]),
                      child: isStatusAccepted.value
                          ? Column(
                              children: [
                                const TextCustom(
                                    text:
                                        "Driver Kamu Sedang Dalam Perjalanan...",
                                    fontSize: 14,
                                    maxLine: 2),
                                const Divider(),
                                Row(
                                  children: [
                                    const Icon(Icons.location_history,
                                        size: 28, color: Colors.black87),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const TextCustom(
                                            text: 'Pickup Location',
                                            fontSize: 15,
                                            color: Colors.grey),
                                        TextCustom(
                                            text: shortenAddress(
                                                data['pickupLoc'] ?? ''),
                                            fontSize: 16,
                                            maxLine: 2),
                                      ],
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 28, color: Colors.black87),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const TextCustom(
                                            text: 'DropOff Locatian',
                                            fontSize: 15,
                                            color: Colors.grey),
                                        TextCustom(
                                            textOverflow: TextOverflow.ellipsis,
                                            text: shortenAddress(
                                                data['destinationLoc'] ?? ''),
                                            fontSize: 16,
                                            maxLine: 2),
                                      ],
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: driverDetail
                                                .isNotEmpty // Pengecekan apakah driverDetail tidak kosong
                                            ? SvgPicture.network(
                                                driverDetail[0]['avatar'] ?? '',
                                                fit: BoxFit.cover,
                                              )
                                            : Container(), // Placeholder jika driverDetail kosong
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    driverDetail
                                            .isNotEmpty // Pengecekan apakah driverDetail tidak kosong
                                        ? TextCustom(
                                            text: driverDetail[0]['nama'] ?? '')
                                        : Container(), // Placeholder jika driverDetail kosong
                                    const Spacer(),
                                    InkWell(
                                      // onTap: () async => await urlLauncherFrave
                                      //     .makePhoneCall('tel:${driverDetail[0]['telepon']}'),
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey[200]),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Color(0xff1977F3),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          : CircularProgressIndicator()),
                )
              : Container()),
        ],
      ),
    );
  }
}
