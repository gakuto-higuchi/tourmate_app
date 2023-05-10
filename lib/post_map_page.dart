import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tourmate/components/constants.dart';

const kGoogleApiKey = apiKey;
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class NewPostMap extends StatefulWidget {
  const NewPostMap({Key? key}) : super(key: key);
  @override
  _NewPostMapState createState() => _NewPostMapState();
}

class _NewPostMapState extends State<NewPostMap> {
  final _controller = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final Set<Marker> _markers = {};
  LatLng? _pickedLocation;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  late GoogleMapController _mapController;
  late StreamSubscription<Position> positionStream;
  Position? currentPosition;
  CameraPosition? _kGooglePlex;
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
      appBar: AppBar(title: const Text('Select Location')),
      body: _kGooglePlex != null
          ? Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex!,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  padding: const EdgeInsets.only(bottom: 60.0),
                  onMapCreated: (GoogleMapController controller) {
                    _onMapCreated(controller);
                  },
                  onTap: _onMapTap,
                  markers: _markers,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search location',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                        ),
                        onSubmitted: _searchLocation,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_pickedLocation != null) {
            Navigator.pop(context, _pickedLocation);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
      _markers.clear(); // Remove the previous marker
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      ));
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      String value = await DefaultAssetBundle.of(context)
          .loadString('lib/json/mapstyle_sample.json');
      GoogleMapController futureController = await _controller.future;
      futureController.setMapStyle(value);
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final location = Location(
          lat: currentPosition.latitude, lng: currentPosition.longitude);
      final result = await _places.searchByText(query,
          location: location, radius: 5000, language: 'ja');

      // 検索結果を表示
      print('Search result status: ${result.status}');
      for (var place in result.results) {
        print(
            'Place: ${place.name}, lat: ${place.geometry!.location.lat}, lng: ${place.geometry!.location.lng}');
      }

      if (result.status == 'OK' && result.results.isNotEmpty) {
        final place = result.results.first;
        final lat = place.geometry!.location.lat;
        final lng = place.geometry!.location.lng;
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lng), zoom: 14),
          ),
        );
      } else {
        print('No results found for the search query');
      }
    } catch (e) {
      print('Error searching location: $e');
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
