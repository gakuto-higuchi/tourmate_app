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
  List<LatLng> _pickedLocations = [];
  List<String> _pickedNames = []; // New property to store picked names

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
      resizeToAvoidBottomInset: false,
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
          if (_pickedLocations.isNotEmpty && _pickedNames.isNotEmpty) {
            Navigator.pop(context, [_pickedLocations, _pickedNames]);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Name the location'),
        content: TextField(
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop(value);
          },
        ),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _pickedLocations.add(position);
          _pickedNames.add(value);
          _markers.add(
            Marker(
              markerId: MarkerId(value),
              position: position,
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        });
      }
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    _mapController = controller;
    if (currentPosition != null) {
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    _searchFocusNode.unfocus();
    PlacesSearchResponse response = await _places.searchByText(query);
    if (response.status == 'OK' && response.results.isNotEmpty) {
      PlacesSearchResult result = response.results.first;
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              result.geometry!.location.lat,
              result.geometry!.location.lng,
            ),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No results found for the search query'),
        ),
      );
    }
  }

  Future<void> _setInitialCameraPosition() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (currentPosition != null) {
      setState(() {
        _kGooglePlex = CameraPosition(
          target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          zoom: 15.0,
        );
      });
    }
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }
}
