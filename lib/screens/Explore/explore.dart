import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:v4/controllers/location_controller.dart';
import 'package:get/get.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  double mapHeight = 0;
  bool isFullScreen = false;
  bool isLiveLocationOn = false;

  LatLng _initialPosition = const LatLng(0, 0);

  final locationController = Get.find<LocationController>();

  // Create a set of markers
  final Set<Marker> _markers = {};

  Timer? liveLocationTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    locationController.getPosition().then((Position position) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void updateMarker() async {
    Position position = await locationController.getPosition();

    // Add a marker to the new position
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position: LatLng(position.latitude, position.longitude),

        ),
      );
    });
  }

  void updateCameraPosition() async {
    Position position = await locationController.getPosition();

    // Get the current zoom level
    double currentZoomLevel = await _mapController?.getZoomLevel() ?? 16.0;

    // Update the map to the new position
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: currentZoomLevel,
        ),
      ),
    );
  }

  void toggleLiveLocation() {
    if (isLiveLocationOn) {
      liveLocationTimer?.cancel();
    } else {
      liveLocationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        updateMarker();
      });
    }
    setState(() {
      isLiveLocationOn = !isLiveLocationOn;
    });
  }

  @override
  void dispose() {
    liveLocationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapHeight = MediaQuery.of(context).size.height / 2.5;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Explore",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          backgroundColor: const Color(0xff0E1219),
          iconTheme: const IconThemeData(color: Color(0xffffffff)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
            height: mapHeight,
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 16.0,
                ),
                markers: _markers,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFullScreen = !isFullScreen;
                  mapHeight = isFullScreen
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.height / 2.5;
                });
              },
              child: isFullScreen
                  ? SvgPicture.asset('assets/SVG/Pill_up.svg')
                  : SvgPicture.asset('assets/SVG/Pill_down.svg'),
            ),
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width / 2 - 185,
            child: GestureDetector(
              onTap: () {
                toggleLiveLocation();
                updateCameraPosition();
              },
              child: isLiveLocationOn
                  ? SvgPicture.asset('assets/SVG/LiveOn.svg', height: 30,)
                  : SvgPicture.asset('assets/SVG/LiveOff.svg', height: 30,),
            ),
          ),
        ],
      ),
    );
  }
}
