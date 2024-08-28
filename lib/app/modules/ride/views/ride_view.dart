import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stepmotor/app/data/places_api_provider.dart';
import 'package:stepmotor/app/modules/driver/views/driver_view.dart';
import 'package:stepmotor/app/modules/home/controllers/home_controller.dart';
import 'package:stepmotor/app/modules/ride/controllers/ride_controller.dart';
import 'package:stepmotor/app/modules/ride/directions_model.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/snap_web_view_screen.dart';
import 'package:stepmotor/theme.dart';
import 'package:stepmotor/tokenService.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:location/location.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as serviceHttp;
import 'package:sp_util/sp_util.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sp_util/sp_util.dart';

class RideView extends StatefulWidget {
  const RideView({super.key});

  @override
  State<RideView> createState() => _RideViewState();
}

class _RideViewState extends State<RideView> {
  final RideController rideController = Get.put(RideController());
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  RxInt harga = 0.obs;
  List<dynamic> settings = [];
  MidtransSDK? _midtrans;
  RxDouble MINIMUM_FARE = 0.0.obs;
  final RxBool _showSuggestionsPickup =
      false.obs; // Observable boolean to toggle suggestion visibility
  final RxBool _showSuggestionsDropOff =
      false.obs; // Observable boolean to toggle suggestion visibility
  FocusNode _focusNodePickup = FocusNode();
  FocusNode _focusNodeDropOff = FocusNode();
  LatLng? _pickupLocation = const LatLng(0, 0);
  LatLng? _destinationLocation = const LatLng(0, 0);
  bool _locationServiceStarted =
      true; // Flag untuk menandai apakah lokasi sudah diambil
  PolylinePoints polylinePoints = PolylinePoints();
// Fungsi untuk memuat ikon kustom
  BitmapDescriptor sourceMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationMarkerIcon = BitmapDescriptor.defaultMarker;
  List<dynamic> listPlacesPickup = [];
  List<dynamic> listPlacesDropOff = [];
  Set<Polyline> _polylines = {};
  Directions? _info;
  Map<String, dynamic>? userDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;
  List<LatLng> polyLinesTrack = [];
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void addCustomIconSource() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/pin.png', 100);

    setState(() {
      sourceMarkerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  void getPolyLinePoint(
      {required LatLng origin, required LatLng destination}) async {
    final directions = await PlacesApiProvider()
        .getDirections(origin: origin!, destination: destination!);

    calculateAndSetPrice(directions.totalDistance, 5000);
    setState(() {
      _info = directions;
      CameraUpdate.newLatLngBounds(directions.bounds, 150.0);
    });
  }

  Future<void> getHarga() async {
    try {
      serviceHttp.get(
        Uri.parse('http://localhost:8000/api/settings'),
        headers: {
          'Accept': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
      ).then((value) {
        setState(() {
          settings = jsonDecode(value.body[0]);
          MINIMUM_FARE.value = (settings[0]['minimum_fare'] as num).toDouble();

          print("settingsFARE : $settings");
        });
      }).catchError((error) {
        return null;
      });
    } catch (e) {
      print('Error occurred in getHarga: $e');
    }
  }

  void addCustomIconDestination() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/flag.png', 150);

    setState(() {
      destinationMarkerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  void makeSugegstionPickup(String input) async {
    await PlacesApiProvider().getSuggestions(input).then((value) {
      if (value.body['status'] == 'OK') {
        setState(() {
          listPlacesPickup = value.body['predictions'];
        });
      }
    });
  }

  void makeSugegstionDropOff(String input) async {
    await PlacesApiProvider().getSuggestions(input).then((value) {
      if (value.body['status'] == 'OK') {
        setState(() {
          listPlacesDropOff = value.body['predictions'];
        });
      }
    });
  }

  void createOrder() async {
    // Check if driverDetail is null
    if (userDetail == null || userDetail!['id'] == null) {
      print('Driver details are incomplete or missing.');
      return;
    }

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/${userDetail!['id']}");

    try {
      await ref.set({
        "user": userDetail,
        "pickup": {
          "latitude": _pickupLocation!.latitude,
          "longitude": _pickupLocation!.longitude,
        },
        "dropoff": {
          "latitude": _destinationLocation!.latitude,
          "longitude": _destinationLocation!.longitude,
        },
        "service_name": 1,
        "pickupLoc": _startLocationController.text,
        "destinationLoc": _endLocationController.text,
        "status": 'pending',
        "harga": harga.value
      });

      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  Future<void> convertAddressToLatLng(String address, String variable) async {
    try {
      GeoData data = await Geocoder2.getDataFromAddress(
        address: address,
        googleMapApiKey: "AIzaSyBJcFAXOkV0woU4RaV9rHbTQRpUcMrJ8Ww",
      );

      setState(() {
        _locationServiceStarted = false;
        if (variable == 'pickup') {
          _pickupLocation = LatLng(data.latitude, data.longitude);
          _cameraToPosition(_pickupLocation!);
        } else if (variable == 'dropoff') {
          _destinationLocation = LatLng(data.latitude, data.longitude);
          _cameraToPosition(_destinationLocation!);
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;

    // Cek apakah layanan lokasi aktif
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      // Meminta pengguna untuk mengaktifkan layanan lokasi
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Jika pengguna menolak, kembalikan null
        print("Layanan lokasi tidak diaktifkan.");
        return;
      }
    }

    // Cek apakah aplikasi memiliki izin lokasi
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      // Meminta izin lokasi dari pengguna
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // Jika pengguna menolak, kembalikan null
        print("Izin lokasi tidak diberikan.");
        return;
      }
    }

    // Dapatkan data lokasi saat ini
    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (_locationServiceStarted == true) {
        GeoData data = await Geocoder2.getDataFromCoordinates(
            googleMapApiKey: "AIzaSyBJcFAXOkV0woU4RaV9rHbTQRpUcMrJ8Ww",
            latitude: currentLocation.latitude!,
            longitude: currentLocation.longitude!);
        setState(() {
          _pickupLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _startLocationController.text = data.address;
          addCustomIconSource();
          addCustomIconDestination();
          _cameraToPosition(_pickupLocation!);
        });
      }
    });
  }

  @override
  void initState() {
    _focusNodePickup.addListener(() {
      if (_focusNodePickup.hasFocus) {
        _showSuggestionsPickup.value = true;
      } else {
        _showSuggestionsPickup.value = false;
      }
    });
    _focusNodeDropOff.addListener(() {
      if (_focusNodeDropOff.hasFocus) {
        _showSuggestionsDropOff.value = true;
      } else {
        _showSuggestionsDropOff.value = false;
      }
    });
    getHarga();

    _getCurrentLocation().then((_) {});
    super.initState();
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController googleMapController =
        await _controllerGoogleMap.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 15,
    );
    await googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNodePickup.dispose();
    _focusNodeDropOff.dispose();
    super.dispose();
  }

  void calculateAndSetPrice(String distanceStr, double ratePerKm) {
    print('MASUK BBOSSS $distanceStr $ratePerKm');
    double distanceKm = parseDistance(distanceStr);
    double cost = calculateCost(distanceKm, ratePerKm);
    harga.value = cost.toInt(); // Update harga dengan nilai integer
  }

  double parseDistance(String distance) {
    // Menghapus satuan "km" dan mengkonversi string menjadi double
    return double.tryParse(distance.replaceAll(' km', '').trim()) ?? 0.0;
  }

  double calculateCost(double distance, double rate) {
    return distance * rate;
  }

  @override
  Widget build(BuildContext context) {
    print("MINIMUM_FARE : $MINIMUM_FARE");
    print("harga : $harga");
    print('settinng $settings');
    print(
        "_pickupLocation : $_pickupLocation; _destination: $_destinationLocation");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('Mau Kemana ?'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                color: Colors.grey.shade300,
                child: Center(
                  child: Stack(children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) async {
                        _controllerGoogleMap.complete(controller);
                      },
                      initialCameraPosition: CameraPosition(
                        target: _pickupLocation!,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('_sourceLocation'),
                          position: _pickupLocation!,
                          icon: sourceMarkerIcon,
                        ),
                        Marker(
                          markerId: const MarkerId('_destinationLocation'),
                          position: _destinationLocation!,
                          icon: destinationMarkerIcon,
                        ),
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
                    ),
                    Positioned(
                      bottom: harga.value == 0 ? 20 : 220,
                      left: 20,
                      child: FloatingActionButton.extended(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        onPressed: () {
                          // Respond to button press
                          _getCurrentLocation();
                        },
                        icon: Icon(Icons.near_me, color: Colors.grey[800]),
                        label: const Text("Gunakan Lokasi Saya"),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
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
                      iconData: Icons.radio_button_checked,
                      color: Colors.orange,
                      controller: _startLocationController,
                      focusNode: _focusNodePickup,
                      hintText: 'Lokasi Anda',
                      onChanged: (value) {
                        _handleInputPickup(value);
                        makeSugegstionPickup(value);
                        setState(() {
                          _locationServiceStarted = false;
                        });
                      },
                    ),
                    Obx(
                      () => _showSuggestionsPickup.value == true
                          ? _buildFloatingSuggestionsPickup(context)
                          : Container(),
                    ),
                    const Divider(
                      color: Colors.black26,
                      indent: 24.0,
                      endIndent: 24.0,
                    ),
                    _buildLocationInputRow(
                      iconData: Icons.location_on,
                      color: Colors.red,
                      controller: _endLocationController,
                      hintText: 'Lokasi Tujuan Anda',
                      onChanged: (value) {
                        _handleInputBackOff(value);
                        makeSugegstionDropOff(value);
                      },
                      focusNode: _focusNodeDropOff,
                    ),
                    Obx(
                      () => _showSuggestionsDropOff.value
                          ? _buildFloatingSuggestionsDropOff(context)
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          harga.value == 0
              ? Container()
              : AnimatedPositioned(
                  duration: const Duration(milliseconds: 300), // Durasi animasi
                  curve: Curves.easeInOut, // Kurva animasi
                  bottom: harga == 0
                      ? -100
                      : 20, // Posisi widget jika harga == 0 maka akan tersembunyi

                  left: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed,
                                size: 28, color: Colors.black87),
                            const SizedBox(width: 15.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextCustom(
                                    text: 'Jarak',
                                    fontSize: 15,
                                    color: Colors.grey),
                                TextCustom(
                                    text: "${_info?.totalDistance}",
                                    fontSize: 16,
                                    maxLine: 2),
                              ],
                            )
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.paid,
                                size: 28, color: Colors.black87),
                            const SizedBox(width: 15.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextCustom(
                                    text: 'Harga',
                                    fontSize: 15,
                                    color: Colors.grey),
                                TextCustom(
                                    text: "Rp. $harga",
                                    fontSize: 16,
                                    maxLine: 2),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
//                   // Obx(() {
//                   //   return
                        BtnFrave(
                          height: 45,
                          text: 'Cari Driver',
                          fontWeight: FontWeight.w500,
                          onPressed: () async {
                            EasyLoading.show(status: "Tunggu Sebentar...");
                            var payload = {
                              "service_name": "Step Motor",
                              "harga": harga.value
                            };

                            var payloadJson = jsonEncode(payload);
                            final result =
                                await TokenService().getToken(payloadJson);
                            if (result.isRight()) {
                              String? tokenJson =
                                  result.fold((l) => null, (r) => r.token);
                              String token = tokenJson!
                                  .replaceAll(RegExp(r'[\[\]\"]'), '');
                              print("token $tokenJson");
                              var data = {
                                "url": token,
                                "service_name": 1,
                                "pickupLoc": _startLocationController.text,
                                "destinationLoc": _endLocationController.text,
                                "user": userDetail,
                                "pickup": {
                                  "latitude": _pickupLocation!.latitude,
                                  "longitude": _pickupLocation!.longitude,
                                },
                                "dropoff": {
                                  "latitude": _destinationLocation!.latitude,
                                  "longitude": _destinationLocation!.longitude,
                                },
                                "status": 'pending',
                                'harga': harga.value
                              };
                              // Get.offAllNamed(Routes.TRACKING, arguments: data);
                              Get.offAllNamed(Routes.PAYMENT, arguments: data);
                              EasyLoading.dismiss();
                              createOrder();
                            }
                          },
                        ),
//                   // }),
                      ],
                    ),
                  ),
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
    required ValueChanged<String> onChanged,
    required focusNode,
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
              onChanged: onChanged,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleInputPickup(String value) {
    if (value.isNotEmpty) {
      _showSuggestionsPickup.value = true; // Show suggestions when typing
    } else {
      _showSuggestionsPickup.value =
          false; // Hide suggestions when input is empty
    }
  }

  void _handleInputBackOff(String value) {
    if (value.isNotEmpty) {
      _showSuggestionsDropOff.value = true; // Show suggestions when typing
    } else {
      _showSuggestionsDropOff.value =
          false; // Hide suggestions when input is empty
    }
  }

  Widget _buildFloatingSuggestionsPickup(BuildContext context) {
    return Positioned(
      top: 130,
      left: 15,
      right: 15,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200, // Set max height to enable scrolling
            ),
            child: SingleChildScrollView(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: listPlacesPickup.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(listPlacesPickup[index]['description']),
                  onTap: () async {
                    _startLocationController.text = listPlacesPickup[index]
                        ['structured_formatting']['main_text'];
                    _showSuggestionsPickup.value = false;
                    await convertAddressToLatLng(
                        _startLocationController.text, 'pickup');
                  },
                );
              },
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSuggestionsDropOff(BuildContext context) {
    return Positioned(
      top: 130,
      left: 15,
      right: 15,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500, // Set max height to enable scrolling
            ),
            child: SingleChildScrollView(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: listPlacesDropOff.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(listPlacesDropOff[index]['description']),
                  onTap: () async {
                    _endLocationController.text = listPlacesDropOff[index]
                        ['structured_formatting']['main_text'];
                    _showSuggestionsDropOff.value = false;
                    await convertAddressToLatLng(
                        _endLocationController.text, 'dropoff');
                    if (_pickupLocation != null &&
                        _destinationLocation != null) {
                      getPolyLinePoint(
                          origin: _pickupLocation!,
                          destination: _destinationLocation!);
                    }
                  },
                );
              },
            )),
          ),
        ),
      ),
    );
  }

  void initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: "SB-Mid-client-eLgwMGnqaeOpdH85",
        merchantBaseUrl: "",
        colorTheme: ColorTheme(
          colorPrimary: Theme.of(context).colorScheme.secondary,
          colorPrimaryDark: Theme.of(context).colorScheme.secondary,
          colorSecondary: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
      showPaymentStatus: true,
    );
    _midtrans!.setTransactionFinishedCallback((result) {
      print("BERES BAYAR: ${result.toJson()}");
    });
  }
}
