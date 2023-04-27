import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'components/bottombar.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyDwFLScwhjMtDIRrOzXKQVS4wgwDS9U7p4";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final _controller = Completer<GoogleMapController>();
  Position? currentPosition;
  final _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final Set<Marker> _markers = {};
  //late GoogleMapController _controller;
  late StreamSubscription<Position> positionStream;
  //初期位置
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(43.0686606, 141.3485613),
    zoom: 14,
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();

    //位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    //現在位置を更新し続ける
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Disable the default button
            padding:
                const EdgeInsets.only(bottom: 60.0), // Add padding to the map
            onMapCreated: (GoogleMapController controller) {
              _onMapCreated(controller);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                heroTag: "current_location_button",
                backgroundColor: Color.fromRGBO(134, 93, 255, 1),
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location,
                    size: 35, color: Color.fromRGBO(227, 132, 255, 1)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingActionButton(
                heroTag: "search_nearby_places_button",
                backgroundColor: Color.fromRGBO(134, 93, 255, 1),
                onPressed: _searchNearbyPlaces,
                child: const Icon(Icons.search,
                    size: 35, color: Color.fromRGBO(227, 132, 255, 1)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      String value = await DefaultAssetBundle.of(context).loadString(
          'lib/json/mapstyle_sample.json'); // Jsonファイルをcustom-mapを読み込む
      GoogleMapController futureController = await _controller.future;
      futureController.setMapStyle(value); // Controllerを使ってMapをSetする
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          zoom: 14,
        ),
      ));
      _loadNearbyPlaces(currentPosition!.latitude, currentPosition!.longitude);
    }
  }

  Future<void> _searchNearbyPlaces() async {
    if (currentPosition != null) {
      try {
        Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay,
          language: "ja",
        );

        if (p != null) {
          // 追加: p が null でないことを確認
          PlacesDetailsResponse detail =
              await _places.getDetailsByPlaceId(p.placeId!);
          final lat = detail.result.geometry!.location.lat;
          final lng = detail.result.geometry!.location.lng;

          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14,
            ),
          ));
          _loadNearbyPlaces(lat, lng);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _loadNearbyPlaces(double lat, double lng) async {
    _markers.clear();

    final location = Location(lat: lat, lng: lng);
    final result = await _places.searchNearbyWithRadius(location, 1500);

    if (result.status == "OK") {
      setState(() {
        for (final place in result.results) {
          final marker = Marker(
            markerId: MarkerId(place.placeId),
            position: LatLng(
                place.geometry!.location.lat, place.geometry!.location.lng),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.vicinity,
            ),
          );
          _markers.add(marker);
        }
      });
    } else {
      print('Error searching nearby places: ${result.errorMessage}');
    }
  }
}
//gakuto.higuchi@gmail.com