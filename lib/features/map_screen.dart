import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _bikeIcon;

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
    _loadBikeIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real Time Location Tracker')),
      body: GoogleMap(
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onTap: (LatLng latLng) {
          print('Clicked on $latLng');
        },
        onLongPress: (LatLng latLng) {
          print('Long pressed on $latLng');
        },
        trafficEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(23.823179, 90.352446),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },

        // onCameraIdle: () {
        //   print('Dancing animation');
        // },
        // onCameraMove: (CameraPosition movingPosition) {
        //   // print(movingPosition.target);
        // },
        // onCameraMoveStarted: () {
        //   print('Hide Dancing Animation');
        // },
        mapType: .normal,
        markers: <Marker>{
          Marker(
            markerId: MarkerId('Home'),
            position: LatLng(23.823179, 90.352446),
            infoWindow: InfoWindow(
              title: 'Home',
              onTap: () {
                print('Tapped on Home');
              },
            ),
          ),
          Marker(
            markerId: MarkerId('Office'),
            position: LatLng(23.823544, 90.354537),
            infoWindow: InfoWindow(
              title: 'Office',
              onTap: () {
                print('Tapped on Office');
              },
            ),
            // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
            icon: _bikeIcon ?? BitmapDescriptor.defaultMarker,
          ),
        },
        circles: <Circle>{
          Circle(
            circleId: CircleId('red-zones'),
            center: LatLng(23.823544, 90.356940),
            radius: 100,
            fillColor: Colors.red.shade100,
            strokeColor:Colors.red,
            strokeWidth: 3,
            onTap: (){
              print('Tapped on red zone');
            },
            consumeTapEvents: true
          ),
          Circle(
            circleId: CircleId('green-zone'),
            center: LatLng(23.821738, 90.352799),
            radius: 100,
            fillColor: Colors.green.shade100,
            strokeColor:Colors.green,
            strokeWidth: 3,
            onTap: (){
              print('Tapped on green zone');
            },
            consumeTapEvents: true
          ),
        },
        polylines: <Polyline>{
          Polyline(
            polylineId: PolylineId('Init-Position'),
            points: [
              LatLng(23.821738, 90.352799),
              LatLng(23.826637, 90.356913),
              LatLng(23.826556, 90.351361),

            ],
            width: 4,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap
          )
        },
          polygons: <Polygon> {
            Polygon(
                polygonId: PolygonId('danger-area'),
                points: [
                  LatLng(23.778006586811767, 90.35922825336456),
                  LatLng(23.774350208584387, 90.34503668546677),
                  LatLng(23.76179525763401, 90.35215627402067),
                  LatLng(23.75785027918789, 90.3583263605833),
                  LatLng(23.760235814826416, 90.366489328444),
                  LatLng(23.76607150865706, 90.36912761628628),
                  LatLng(23.77268260579799, 90.36725409328938),
                  LatLng(23.777047783131415, 90.36143001168966),
                  LatLng(23.779566123425163, 90.35585939884186)
                ],
                fillColor: Colors.red.withAlpha(50),
                strokeColor: Colors.orange,
                strokeWidth: 3,
                consumeTapEvents: true,
                onTap: () {
                  print('Tapped on danger area');
                }
            )
          },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
