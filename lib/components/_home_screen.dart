import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:stepmotor/app/modules/home/controllers/home_controller.dart';
import 'package:stepmotor/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location locationController = Location();
  PanelController panelController = PanelController();
  HomeController homeController = Get.put(HomeController());

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  static const LatLng _pGooglePlex = LatLng(-6.885136, 107.5597973);
  static const LatLng _pApplePark = LatLng(-6.8734375620709, 107.5619819829425);
  LatLng? _currentP = const LatLng(0, 0);
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> routePoints = [];
  List<Geo.Placemark> placemarks = [];
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController googleMapController =
        await _controllerGoogleMap.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 16,
    );
    await googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getUserLocations() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await locationController.requestService();
      if (!_serviceEnabled) {
        print('Service not enabled');
        return;
      }
    }

    _permissionGranted = await locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('Permission not granted');
        return;
      }
    }

    locationController.onLocationChanged
        .listen((LocationData currentLocation) async {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );

          _cameraToPosition(_currentP!);
          getPolylinePoints(); // Refresh route whenever location changes
        });
      }
    });
  }

  BitmapDescriptor sourceMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationMarkerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIconSource() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/source.png')
        .then((icon) {
      setState(() {
        sourceMarkerIcon = icon;
      });
    });
  }

  void addCustomIconDestination() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/point.png')
        .then((icon) {
      setState(() {
        destinationMarkerIcon = icon;
      });
    });
  }

  Future<void> getPolylinePoints() async {
    if (_currentP == null) return; // Ensure current position is not null

    try {
      final List<ORSCoordinate> routeCoordinates =
          await client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
            latitude: _currentP!.latitude, longitude: _currentP!.longitude),
        endCoordinate: ORSCoordinate(
            latitude: _pApplePark.latitude, longitude: _pApplePark.longitude),
      );

      setState(() {
        routePoints = routeCoordinates
            .map((coordinate) =>
                LatLng(coordinate.latitude, coordinate.longitude))
            .toList();
      });
    } catch (e) {
      print('Failed to get route: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if _currentP is initialized
    getUserLocations().then((_) {
      addCustomIconDestination();
      addCustomIconSource();
      homeController.startLocationName.text =
          placemarks.first.street.toString();
    }).catchError((error) {
      print("Error getting user locations: $error");
    });
  }

  void togglePanel() {
    if (panelController.isPanelClosed) {
      panelController.open();
    } else {
      panelController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("placemarks TOT: ${placemarks.first.street}");
    Size size = MediaQuery.of(context).size;
    return _currentP == null
        ? const Center(child: CircularProgressIndicator())
        : Stack(alignment: Alignment.topCenter, children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition:
                  CameraPosition(target: _currentP!, zoom: 15),
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
              },
              markers: {
                if (_currentP != null)
                  Marker(
                    markerId: const MarkerId('_sourceLocation'),
                    position: _currentP!,
                    icon: sourceMarkerIcon,
                  ),
                Marker(
                  markerId: const MarkerId('_destinationLocation'),
                  position: _pApplePark,
                  icon: destinationMarkerIcon,
                ),
              },
              polylines: {
                if (routePoints.isNotEmpty)
                  Polyline(
                    polylineId: PolylineId('route'),
                    visible: true,
                    points: routePoints,
                    color: Colors.green,
                    width: 2,
                  ),
              },
            ),
            SizedBox(height: 50),
            SlidingUpPanel(
              backdropOpacity: 0.5,
              controller: panelController,
              maxHeight: size.height * 0.8,
              minHeight: size.height * 0.2,
              parallaxEnabled: true,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              panelBuilder: (controller) {
                return SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: togglePanel, // Call the function properly
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 15, bottom: 15),
                            height: 5,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300]!,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mau Kemana Hari Ini?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8),
                                child: GNav(
                                  rippleColor: Colors.grey[300]!,
                                  hoverColor: Colors.grey[100]!,
                                  activeColor: Colors.black,
                                  iconSize: 18,
                                  gap: 8,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 12),
                                  duration: const Duration(milliseconds: 400),
                                  tabBackgroundColor: Colors.green[300]!,
                                  color: Colors.black,
                                  tabs: const [
                                    GButton(
                                      icon: LineIcons.motorcycle,
                                      text: 'Step Motor',
                                    ),
                                    GButton(
                                      icon: LineIcons.shopware,
                                      text: 'Bengkel',
                                    ),
                                  ],
                                  selectedIndex:
                                      homeController.selectedIndexService.value,
                                  onTabChange: (index) {
                                    homeController.updateIndexService(index);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Obx(() {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: HomeController.widgetOptionsService.elementAt(
                              homeController.selectedIndexService.value),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ]);
  }
}
