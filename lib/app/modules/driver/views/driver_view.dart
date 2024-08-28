import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/data/login_provider.dart';
import 'package:stepmotor/app/data/places_api_provider.dart';
import 'package:stepmotor/app/data/user_provider.dart';
import 'package:stepmotor/app/modules/History/views/history_view.dart';
import 'package:stepmotor/app/modules/driver/controllers/driver_controller.dart';
import 'package:stepmotor/app/modules/login/controllers/login_controller.dart';
import 'package:stepmotor/app/modules/ride/directions_model.dart';
import 'package:stepmotor/app/modules/user/controllers/user_controller.dart';
import 'package:stepmotor/app/modules/user/views/user_view.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/failure.dart';
import 'package:stepmotor/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sp_util/sp_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as serviceHttp;
import 'package:url_launcher/url_launcher.dart';

class DriverView extends StatefulWidget {
  const DriverView({super.key});

  @override
  State<DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<DriverView> {
  Map<String, dynamic>? driverDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;
  final GlobalKey bottomSheet = GlobalKey();
  final dragController = DraggableScrollableController();
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  bool _locationServiceStarted = true;
  bool isModalShown = false;
  RxBool isOtw = false.obs;
  // Inisialisasi controller
  final DriverController controller = Get.put(DriverController());
  RxList<Map<String, dynamic>> getRequest = <Map<String, dynamic>>[].obs;
  LatLng? _driverLocation = const LatLng(0, 0);
  Directions? _info;
  bool requestIn = false;
  int ordersId = 0;
  int orderIDAPI = 0;
  BitmapDescriptor destinationMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarker;
  RxBool isStatusAccepted = false.obs;
  Set<Marker> _markers = {};
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

  void _getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData? _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("Layanan lokasi tidak diaktifkan.");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Izin lokasi tidak diberikan.");
        return;
      }
    }

    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      updateAndSetDataDriver(
          currentLocation.latitude!, currentLocation.longitude!);
      if (_locationServiceStarted) {
        setState(() {
          _driverLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_driverLocation!);
        });
      }
    });
  }

  void updateAndSetDataDriver(double lat, double long) async {
    // Check if driverDetail is null
    if (driverDetail == null || driverDetail!['id'] == null) {
      print('Driver details are incomplete or missing.');
      return;
    }

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("drivers/${driverDetail!['id']}");

    try {
      await ref.update({
        "location": {
          "latitude": lat,
          "longitude": long,
        },
      });

      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  void createRef() async {
    // Check if driverDetail is null
    if (driverDetail == null || driverDetail!['id'] == null) {
      print('Driver details are incomplete or missing.');
      return;
    }

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("drivers/${driverDetail!['id']}");

    try {
      await ref.set({
        ...driverDetail!,
        "status": "Offline",
        "busy": false,
      });

      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  void updateStatus(String status) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("drivers/${driverDetail!['id']}");
    try {
      await ref.update({
        "status": status,
      });
      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
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

  void onChanged() {
    final currentSize = dragController.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);

  void anchor() => animateSheet(getSheet.snapSizes!.last);

  void expand() => animateSheet(getSheet.maxChildSize);

  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    dragController.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  DraggableScrollableSheet get getSheet =>
      (bottomSheet.currentWidget as DraggableScrollableSheet);
  @override
  void initState() {
    // TODO: implement initState
    _getCurrentLocation();
    // _startPolling();
    addCustomIconSource();
    addCustomIconDestination();
    addCustomDriverSource();
    createRef();
    dragController.addListener(onChanged);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dragController.dispose();
    super.dispose();
  }

  void _startPolling() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("requestOrders");
    while (!requestIn) {
      // if (controller.isOnline.value) {
      print("Looping sampai requestIn menjadi true");
      // Looping sampai requestIn menjadi true
      try {
        DatabaseEvent _ordersRef = await ref.once();
        Map<dynamic, dynamic>? orders =
            _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
        print("DATA ORDERS $orders");
        if (orders != null) {
          orders.forEach((key, value) {
            print("VALUE: $value");
            if (value is Map &&
                value['status'] == 'pending' &&
                value['driverId'] == driverDetail!['id']) {
              print('Data found: $value');

              setState(() {
                requestIn = true;
                getRequest.add(Map<String, dynamic>.from(
                    value)); // Jika data ditemukan, set requestIn ke true
                ordersId = int.parse(key);
              });
            }
          });
        } else {
          print('No data found.');
        }

        print('Data updated successfully.');
      } catch (e) {
        print('Failed to update data: $e');
      }

      // Menunggu sebelum melakukan loop berikutnya
      await Future.delayed(
          const Duration(seconds: 1)); // Menunggu 2 detik sebelum mengulang
      // }
    }

    print('Loop berhenti karena requestIn: $requestIn');
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

  void getPolyLinePoint(
      {required LatLng origin, required LatLng destination}) async {
    final directions = await PlacesApiProvider()
        .getDirections(origin: origin!, destination: destination!);
    setState(() {
      _info = directions;
      CameraUpdate.newLatLngBounds(directions.bounds, 150.0);
    });
  }

  void updateRoute() async {
    // Mendapatkan referensi ke node di Firebase Realtime Database
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/$ordersId");
    try {
      await ref.update({
        'path': 'toDropOff',
      });
      _markers.clear();
      var locDriver =
          LatLng(_driverLocation!.latitude, _driverLocation!.longitude);
      var pickUpLoc = LatLng(getRequest[0]['dropoff']['latitude'],
          getRequest[0]['dropoff']['longitude']);
      _addMarker('pickup_marker', locDriver, sourceMarkerIcon);
      _addMarker('dropoff_marker', pickUpLoc, destinationMarkerIcon);
      getPolyLinePoint(origin: _driverLocation!, destination: pickUpLoc!);
      isOtw.value = true;
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  Future<void> createOrder(data, int requestId) async {
    // Tampilkan indikator loading
    EasyLoading.show(status: 'Tunggu Sebentar...');

    // Mendapatkan referensi ke node di Firebase Realtime Database
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/$requestId");
    try {
      var response = await serviceHttp.post(
        Uri.parse("http://10.0.2.2:8000/api/create_order"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
        body: data,
      );
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        await ref.update({
          'status': 'accepted',
        });
        setState(() {
          orderIDAPI = jsonResponse['id'];
        });
        var locDriver =
            LatLng(_driverLocation!.latitude, _driverLocation!.longitude);
        var pickUpLoc = LatLng(getRequest[0]['pickup']['latitude'],
            getRequest[0]['pickup']['longitude']);
        print("LOC DRIVER $locDriver");

        _addMarker('pickup_marker', locDriver, sourceMarkerIcon);
        _addMarker('driver_marker', pickUpLoc, destinationMarkerIcon);

        // Mendapatkan polyline untuk rute
        getPolyLinePoint(origin: locDriver, destination: pickUpLoc);

        // Mengubah status permintaan menjadi diterima
        isStatusAccepted.value = true;
        print('Request has been accepted.');

        // Sembunyikan indikator loading
        EasyLoading.dismiss();
      } else {
        print(
            'Failed to create order: ${response.statusCode} + ${response.body}');
        EasyLoading.showError('Failed to create order.');
        EasyLoading.dismiss();
      }
    } catch (e) {
      print('Failed to update request status: $e');
      EasyLoading.showError('Failed to update request status.');
      EasyLoading.dismiss();
    }
  }

  void completedOrder() async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("requestOrders/$ordersId");
    try {
      final response = await serviceHttp.post(
        Uri.parse("http://10.0.2.2:8000/api/create_pembayaran"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
        body: jsonEncode(
            {"order_id": orderIDAPI, "total": getRequest[0]['harga']}),
      );
      if (response.statusCode == 200) {
        var data = jsonEncode({"id": orderIDAPI, "status": "completed"});
        final responseUpdate = await serviceHttp.put(
          Uri.parse("http://10.0.2.2:8000/api/update_status_order"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Authorization": 'Bearer ${SpUtil.getString('token')}',
            'Accept': 'application/json',
          },
          body: data,
        );
        if (responseUpdate.statusCode == 200) {
          await ref.update({
            'status': 'completed',
            'harga': getRequest[0]['harga'],
          });
          setState(() {
            isModalShown = false;
            requestIn = false;
            ordersId = 0;
            orderIDAPI = 0;
            getRequest.value = [];
            _markers.clear();
            _startPolling();
            isStatusAccepted.value = false;
          });
          // Sembunyikan indikator loading
          EasyLoading.dismiss();
          Get.snackbar('Success', 'Pekerjaan Selesai');
        } else {
          print(
              'Failed to create order: ${responseUpdate.statusCode} + ${responseUpdate.body}');
          EasyLoading.showError('Failed to Update order.');
          EasyLoading.dismiss();
        }
      } else {
        print(
            'Failed to create order: ${response.statusCode} + ${response.body}');
        EasyLoading.showError('Failed to create order.');
        EasyLoading.dismiss();
      }

      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  String shortenAddress(String address, {int maxLength = 20}) {
    if (address.length <= maxLength) {
      return address;
    } else {
      return address.substring(0, maxLength) + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    print("REQUEST ID $orderIDAPI");
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Ikon untuk membuka drawer
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Membuka drawer
              },
            );
          },
        ),
      ),
      drawer: Obx(
        () => Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [green2, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                            controller.driverDetail.value['avatar']
                            //     ??
                            // 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.driverDetail.value['nama'] ?? 'Nama Pengguna',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.driverDetail.value['email'] ??
                          'email@example.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              const Divider(),
              ListTile(
                leading: Icon(Icons.history, color: green2),
                title: const Text('History Perjalanan'),
                onTap: () {
                  // Tindakan ketika item 1 di-tap
                  Get.to(() => HistoryView());
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: green2),
                title: const Text('Profile'),
                onTap: () {
                  Get.lazyPut(() => UserController());
                  Get.to(() => const UserView());
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), // Durasi animasi
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Tween animasi untuk efek slide
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Mulai dari bawah
                end: const Offset(0.0, 0.0), // Akhir di posisi asalnya
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            child: controller.isOnline.value
                ? FloatingActionButton.extended(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    key: const ValueKey(
                        'online'), // Key unik untuk AnimatedSwitcher
                    icon: const Icon(
                      Icons.power_settings_new,
                      size: 30,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      controller.isOnline.value = false;
                      updateStatus("Offline");
                      requestIn = true;
                    },
                    label: const Text("Online"),
                  )
                : FloatingActionButton(
                    key: const ValueKey(
                        'offline'), // Key unik untuk AnimatedSwitcher
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onPressed: () async {
                      controller.isOnline.value = true;
                      updateStatus("Online");
                      requestIn = false;
                      _startPolling();
                    },
                    child: const Icon(
                      Icons.power_settings_new,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _driverLocation!,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('_driverLocation'),
                position: _driverLocation!,
                icon: driverMarkerIcon,
              ),
              ..._markers
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
          Obx(() {
            // Cek apakah RxList getRequest memiliki data
            // Cek apakah RxList getRequest memiliki data dan modal belum ditampilkan
            if (getRequest.isNotEmpty && !isModalShown) {
              // Jika ya, tampilkan modal dan set isModalShown menjadi true
              Future.delayed(Duration.zero, () {
                isModalShown = true;
                _showModal(context, getRequest);
              });
            }
            return Container();
          }),
          Obx(() => Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: isStatusAccepted.value && controller.isOnline.value
                    ? Container(
                        padding: const EdgeInsets.all(15.0),
                        height: 250,
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_history,
                                    size: 28, color: Colors.black87),
                                const SizedBox(width: 15.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TextCustom(
                                        text: 'Pickup Location',
                                        fontSize: 15,
                                        color: Colors.grey),
                                    TextCustom(
                                        text: getRequest.isNotEmpty
                                            ? shortenAddress(
                                                getRequest[0]['pickupLoc'])
                                            : '',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TextCustom(
                                        text: 'DropOff Locatian',
                                        fontSize: 15,
                                        color: Colors.grey),
                                    TextCustom(
                                        text: getRequest.isNotEmpty
                                            ? shortenAddress(
                                                getRequest[0]['destinationLoc'])
                                            : '',
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
                                    child: getRequest.isNotEmpty
                                        ? SvgPicture.network(
                                            getRequest[0]['user']['avatar'],
                                            fit: BoxFit
                                                .cover, // To ensure the SVG scales properly
                                          )
                                        : CircularProgressIndicator(),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                TextCustom(
                                    text: getRequest.isNotEmpty
                                        ? getRequest[0]['user']['nama']
                                        : ''),
                                const Spacer(),
                                InkWell(
                                  // onTap: () async => await urlLauncherFrave
                                  //     .makePhoneCall('tel:${getRequest[0]['user']['telepon']}'),
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
                            const SizedBox(height: 10.0),
                            // Obx(() {
                            //   return
                            isOtw.value
                                ? SwipeButton.expand(
                                    height: 40,
                                    thumb: const Icon(
                                      Icons.double_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                    activeThumbColor: green1,
                                    activeTrackColor: Colors.grey.shade300,
                                    onSwipe: () async {
                                      completedOrder();
                                    },
                                    child: const Text(
                                      "Selesaikan Perjalanan",
                                    ),
                                  )
                                : BtnFrave(
                                    height: 45,
                                    text: 'Sudah Di Titik Jemput',
                                    fontWeight: FontWeight.w500,
                                    onPressed: updateRoute,
                                  ),
                            // }),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(15.0),
                        height: 60,
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCustom(
                                      text: controller.isOnline.value
                                          ? 'Sedang Mencari Penumpang...'
                                          : "Anda Sedang Offline",
                                      fontSize: 20,
                                      maxLine: 2,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
              )),
        ],
      ),
    );
  }

  Future<void> makePhoneCall(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showModal(
      BuildContext context, List<Map<String, dynamic>> requestData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomModalWidget(requestData: requestData);
      },
    );
  }

  Widget _CustomModalWidget({required List<Map<String, dynamic>> requestData}) {
    print("requestData : $requestData");

    // Pastikan requestData memiliki data sebelum digunakan
    if (requestData.isEmpty) {
      return AlertDialog(
        title: const Text('No Data'),
        content: const Text('Tidak ada data yang tersedia.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup modal
            },
            child: const Text('OK'),
          ),
        ],
      );
    }

    // Mengambil data pickup dan dropoff dari requestData
    final pickupLocation =
        requestData[0]['pickup'] ?? {'latitude': '', 'longitude': ''};
    final dropoffLocation =
        requestData[0]['dropoff'] ?? {'latitude': '', 'longitude': ''};

    return AlertDialog(
      title: const Text('Order Masuk'),
      content: SizedBox(
        // Menentukan ukuran modal dengan lebar 300 dan tinggi sesuai konten
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ukuran modal mengikuti konten
          children: [
            Row(
              children: [
                const Icon(Icons.location_history,
                    size: 28, color: Colors.black87),
                const SizedBox(width: 15.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextCustom(
                      text: 'Pickup Location',
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                    TextCustom(
                      text: shortenAddress(requestData[0]
                          ['pickupLoc']), // Menampilkan data pickup
                      fontSize: 16,
                      maxLine: 2,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 28, color: Colors.black87),
                const SizedBox(width: 15.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextCustom(
                      text: 'DropOff Location',
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                    TextCustom(
                      text: shortenAddress(requestData[0]
                          ['destinationLoc']), // Menampilkan data dropoff
                      fontSize: 16,
                      maxLine: 2,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(text: 'Jarak', fontSize: 15, color: Colors.grey),
                    TextCustom(text: "2KM", fontSize: 16, maxLine: 2),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextCustom(
                        text: 'Harga', fontSize: 15, color: Colors.grey),
                    TextCustom(
                        text: "Rp. ${requestData[0]['harga']}",
                        fontSize: 16,
                        maxLine: 2),
                  ],
                ),
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
                    child: SvgPicture.network(
                      requestData[0]['user']['avatar'],
                      fit: BoxFit.cover, // To ensure the SVG scales properly
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextCustom(text: requestData[0]['user']['nama']),
              ],
            ),
            const SizedBox(height: 20.0), // Jarak vertikal sebelum tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var data = jsonEncode({
                      "id_layanan": requestData[0]['service_name'],
                      "id_user": requestData[0]['user']['id'],
                      "pickup": requestData[0]['pickupLoc'],
                      "dropoff": requestData[0]['destinationLoc'],
                      "status": 'on_the_way',
                    });
                    print("DATA ORDER PERPARE : $data");
                    await createOrder(data, ordersId);
                    Navigator.of(context).pop(); // Tutup modal
                    // Tambahkan logika untuk menerima order di sini
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Colors.green, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Sudut melengkung
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0), // Padding tombol
                    elevation: 5, // Bayangan tombol
                  ),
                  child: const Text('Terima', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup modal
                    // Tambahkan logika untuk menolak order di sini
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Sudut melengkung
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0), // Padding tombol
                    elevation: 5, // Bayangan tombol
                  ),
                  child: const Text('Tolak', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class CustomModalWidget extends StatelessWidget {
//   final List<Map<String, dynamic>> requestData;

//   CustomModalWidget();

//   @override
//   Widget build(BuildContext context) {
//     print("requestData: $requestData");
//   }
// }

class BtnFrave extends StatelessWidget {
  final String text;
  final Color color;
  final double height;
  final double width;
  final double borderRadius;
  final Color textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final VoidCallback? onPressed;

  const BtnFrave(
      {required this.text,
      this.color = const Color(0xff0C6CF2),
      this.height = 50,
      this.width = double.infinity,
      this.borderRadius = 8.0,
      this.textColor = Colors.white,
      this.fontWeight = FontWeight.normal,
      this.fontSize = 18,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius))),
        child: TextCustom(
          text: text,
          fontSize: fontSize,
          color: textColor,
          fontWeight: fontWeight,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
