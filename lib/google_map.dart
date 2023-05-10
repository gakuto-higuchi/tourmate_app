import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'components/bottombar.dart';
import 'components/constants.dart';

const kGoogleApiKey = apiKey;
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final _controller = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Position? currentPosition;
  final _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final Set<Marker> _markers = {};
  late StreamSubscription<Position> positionStream;
  /*
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(43.0686606, 141.3485613),
    zoom: 14,
  );
  */
  late CameraPosition _kGooglePlex;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();

    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    });

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
    _setInitialCameraPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            padding: const EdgeInsets.only(bottom: 60.0),
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
            padding: EdgeInsets.only(
              top: 33,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(134, 93, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: '検索したい地域を入力してね',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search,
                        size: 30, color: Color.fromRGBO(227, 132, 255, 1)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  ),
                  // ignore: unnecessary_lambdas
                  onSubmitted: (value) {
                    _searchNearbyPlaces(value);
                  },
                ),
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
      String value = await DefaultAssetBundle.of(context)
          .loadString('lib/json/mapstyle_sample.json');
      GoogleMapController futureController = await _controller.future;
      futureController.setMapStyle(value);
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

  Future<void> _searchNearbyPlaces(String query) async {
    if (currentPosition != null) {
      try {
        final location = Location(
            lat: currentPosition!.latitude, lng: currentPosition!.longitude);
        final result =
            await _places.searchByText(query, location: location, radius: 5000);

        if (result.status == "OK" && result.results.isNotEmpty) {
          final place = result.results.first;
          final lat = place.geometry!.location.lat;
          final lng = place.geometry!.location.lng;

          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14,
            ),
          ));
          _loadNearbyPlaces(lat, lng);
        } else {
          print('No results found for the search query');
        }
      } catch (e) {
        print('Error searching nearby places: $e');
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

  Future<void> _setInitialCameraPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // ignore: avoid_print
      print('Error getting current location: $e');
      setState(() {
        _kGooglePlex = const CameraPosition(
          target: LatLng(43.0686606, 141.3485613),
          zoom: 14,
        );
      });
    }
  }
}
