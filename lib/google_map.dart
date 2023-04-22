import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final _controller = Completer<GoogleMapController>();
  final _markers = <Marker>{};
  LatLng? ontapLatLng;
  final initiLatLng = const LatLng(34.2925247, 134.0644547);
  final double maxZoomLevel = 18;
  final double minZoomLevel = 6;

  late final _initPosition = CameraPosition(target: initiLatLng, zoom: 14.0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(227, 132, 255, 1),
        body: GoogleMap(
          initialCameraPosition: _initPosition,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _onMapCreated(controller);
          },
          minMaxZoomPreference:
              MinMaxZoomPreference(minZoomLevel, maxZoomLevel),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    String value = await DefaultAssetBundle.of(context).loadString(
        'lib/json/mapstyle_sample.json'); // Jsonファイルをcustom-mapを読み込む
    GoogleMapController futureController = await _controller.future;
    futureController.setMapStyle(value); // Controllerを使ってMapをSetする
  }

  @override
  void initState() {
    super.initState();
  }
}
//gakuto.higuchi@gmail.com