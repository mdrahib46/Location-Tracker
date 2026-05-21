import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? currentPosition;

  final LatLng _initialPosition = const LatLng(23.823192, 90.352723);

  late GoogleMapController googleMapController;

  Marker? userMarker;

  final List<LatLng> polylineCoordinates = [];

  final Set<Polyline> polyLines = {};

  BitmapDescriptor? _bikeIcon;

  bool isTracking = false;

  Future<void> _loadBikeIcon() async {
    _bikeIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/bike.png',
      height: 32,
      width: 32,
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadBikeIcon();
    listenCurrentLocation();
  }

  Future<void> listenCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnable = await checkGPSServiceEnable();

      if (isServiceEnable) {
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        ).listen((position) {
          LatLng currentLatLng = LatLng(
            position.latitude,
            position.longitude,
          );

          setState(() {
            currentPosition = position;

            if (isTracking) {
              if (polylineCoordinates.isEmpty ||
                  polylineCoordinates.last != currentLatLng) {
                polylineCoordinates.add(currentLatLng);
              }

              polyLines.clear();
              polyLines.add(
                Polyline(
                  polylineId: const PolylineId('tracking-polyline'),
                  color: Colors.blue,
                  width: 6,
                  points: polylineCoordinates,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                  jointType: JointType.round
                ),
              );
            }

            userMarker = Marker(
              markerId: const MarkerId('user-marker'),
              position: currentLatLng,
              infoWindow: InfoWindow(
                title: 'My Current Location',
                snippet:
                'Lat: ${currentLatLng.latitude}, Lng: ${currentLatLng.longitude}',
              ),
              icon:
              _bikeIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
            );
          });

          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLatLng,
                zoom: 16,
              ),
            ),
          );
        });
      } else {
        await Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();

      if (result) {
        getCurrentLocation();
      } else {
        await Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> checkGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();

    if (isGranted) {
      final isServiceEnable = await checkGPSServiceEnable();

      if (isServiceEnable) {
        Position position = await Geolocator.getCurrentPosition();

        setState(() {
          currentPosition = position;
        });
      } else {
        await Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();

      if (result) {
        getCurrentLocation();
      } else {
        await Geolocator.openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Tracking'),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'tracking-btn',
            backgroundColor:
            isTracking ? Colors.red : Colors.blue,
            onPressed: () {
              setState(() {
                isTracking = !isTracking;

                if (isTracking) {
                  polylineCoordinates.clear();
                  polyLines.clear();
                }
              });
            },
            child: Icon(
              isTracking ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            heroTag: 'location-btn',
            backgroundColor: Colors.green,
            onPressed: () {
              if (currentPosition != null) {
                googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      zoom: 18,
                      target: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Current location not available yet',
                    ),
                  ),
                );
              }
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            zoom: 16,
            target: _initialPosition,
          ),
          markers: {
            if (userMarker != null) userMarker!,
            Marker(
              markerId: const MarkerId('home'),
              position: _initialPosition,
              infoWindow: InfoWindow(
                title: 'My Home',
                snippet:
                'Lat: ${_initialPosition.latitude}, '
                    'Lng: ${_initialPosition.longitude}',
              ),
            ),
          },
          polylines: polyLines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          trafficEnabled: true,
        ),
      ),
    );
  }
}