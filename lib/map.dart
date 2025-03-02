import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' show Ellipsoid;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:osrm/osrm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'app_localizations.dart';
import 'Secrets.dart' as s;

// TODO: Andere Map Styles einfügen

class Distance {
  final Ellipsoid ellipsoid;

  Distance({required this.ellipsoid});

  double as(LengthUnit unit, LatLng start, LatLng end) {
    final double lat1 = start.latitude * (3.141592653589793 / 180.0);
    final double lon1 = start.longitude * (3.141592653589793 / 180.0);
    final double lat2 = end.latitude * (3.141592653589793 / 180.0);
    final double lon2 = end.longitude * (3.141592653589793 / 180.0);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final double distance = ellipsoid.a * c;

    return distance;
  }
}

class Ellipsoid {
  final double a; // semi-major axis
  final double b; // semi-minor axis
  final double f; // flattening

  const Ellipsoid(this.a, this.b, this.f);

  static const Ellipsoid WGS84 = Ellipsoid(6378137.0, 6356752.314245, 1 / 298.257223563);
  static const Ellipsoid GRS80 = Ellipsoid(6378137.0, 6356752.314140, 1 / 298.257222101);
  static const Ellipsoid Bessel1841 = Ellipsoid(6377397.155, 6356078.963, 1 / 299.1528128);
  static const Ellipsoid Krassowski1940 = Ellipsoid(6378245.0, 6356863.0188, 1 / 298.3);
  static const Ellipsoid International1924 = Ellipsoid(6378388.0, 6356911.946, 1 / 297.0);
  static const Ellipsoid Clarke1866 = Ellipsoid(6378206.4, 6356583.8, 1 / 294.9786982);
  static const Ellipsoid Everest1830 = Ellipsoid(6377276.345, 6356075.413, 1 / 300.8017);
}


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  double _zoomLevel = 5.9;
  bool _showSlider = false;
  bool _isSearchMode = false;
  LatLng? _currentPosition;
  LatLng? _searchedPosition;
  List<String> _suggestions = [];
  List<LatLng> _routePoints = [];
  List<Marker> _stationMarkers = [];
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool _isSearchActive = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  final FocusNode _focusNode = FocusNode();
  double _totalDistance = 0.0;
  double _directDistance = 0.0;
  bool _isMetric = true;
  String _selectedSpheroid = 'WGS84'; // Initialize with a default value
  String _mapStyle = 'Standard';


  void _onSliderChanged(double value) {
    setState(() {
      _zoomLevel = value;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
    });
  }

  void _clearInputs() {
    _startController.clear();
    _endController.clear();
    setState(() {
      _currentPosition = null;
      _searchedPosition = null;
      _routePoints = [];
      _totalDistance = 0.0;
      _directDistance = 0.0;
    });
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMetric = prefs.getBool('isMetric') ?? true;
      _selectedSpheroid = prefs.getString('spheroid') ?? 'WGS84';
      _mapStyle = prefs.getString('mapStyle') ?? 'Standard';
    });
  }

  String _getMapUrlTemplate() {
    switch (_mapStyle) {
      case 'OpenCycle':
        return "https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Transport':
        return "https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Landscape':
        return "https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Transport Dark':
        return "https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Outdoors':
        return "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Spinal Map':
        return "https://tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Pioneer':
        return "https://tile.thunderforest.com/pioneer/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Atlas':
        return "https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Mobile Atlas':
        return "https://tile.thunderforest.com/mobile-atlas/{z}/{x}/{y}.png?apikey=${s.thunderforestApiKey}";
      case 'Mapbox':
        return "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}?access_token=${s.mapboxApiKey}";
      case 'Satellite Image':
        return "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/{z}/{x}/{y}?access_token=${s.mapboxApiKey}";
      case 'Standard':
      default:
        return "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
    }
  }

  String _formatDistance(double distanceInMeters) {
    if (_isMetric) {
      return distanceInMeters.toStringAsFixed(2);
    } else {
      double distanceInMiles = distanceInMeters * 0.000621371;
      return distanceInMiles.toStringAsFixed(2);
    }
  }

  Ellipsoid _getEllipsoid() {
    switch (_selectedSpheroid) {
      case 'GRS80':
        return Ellipsoid.GRS80;
      case 'Bessel 1841':
        return Ellipsoid.Bessel1841;
      case 'Krassowski 1940':
        return Ellipsoid.Krassowski1940;
      case 'International 1924':
        return Ellipsoid.International1924;
      case 'Clarke 1866':
        return Ellipsoid.Clarke1866;
      case 'Everest 1830':
        return Ellipsoid.Everest1830;
      case 'WGS84':
      default:
        return Ellipsoid.WGS84;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 100.0, end: 300.0).animate(_animationController);
    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.85).animate(_animationController);
    _loadSettings();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _zoomLevel = 15.0;
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.moveAndRotate(_currentPosition!, _zoomLevel, 0.0);
    });
  }

  void _searchLocation(String query, {bool isStart = false}) async {
    try {
      if (query.isEmpty) {
        return;
      }

      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _zoomLevel = 15.0;
          if (isStart) {
            _currentPosition = LatLng(location.latitude, location.longitude);
          } else {
            _searchedPosition = LatLng(location.latitude, location.longitude);
          }
          _mapController.move(LatLng(location.latitude, location.longitude), _zoomLevel);
        });

        if (_currentPosition != null && _searchedPosition != null) {
          //print('Calling _getRoute');
          _getRoute();
        }
      }
    } catch (e) {
      print('Error occurred while searching location: $e');
    }
  }

  Future<void> _getRoute() async {
    if (_currentPosition != null && _searchedPosition != null) {
      final osrm = Osrm();

      final options = RouteRequest(
        coordinates: [
          (_currentPosition!.longitude, _currentPosition!.latitude),
          (_searchedPosition!.longitude, _searchedPosition!.latitude),
        ],
        geometries: OsrmGeometries.geojson,
        overview: OsrmOverview.full,
        alternatives: OsrmAlternative.number(2),
        annotations: OsrmAnnotation.true_,
        steps: true,
      );

      try {
        final route = await osrm.route(options);
        List<LatLng> routePoints = route.routes.first.geometry!.lineString!.coordinates.map((e) {
          return LatLng(e.$2, e.$1);
        }).toList();

        setState(() {
          _routePoints = routePoints;
          _totalDistance = _calculateTotalDistance(routePoints);
          _directDistance = _calculateDirectDistance(_currentPosition!, _searchedPosition!);
        });
      } catch (e) {
        print('Error occurred while fetching route: $e');
      }
    } else {
      print('Current position or searched position is null');
    }
  }

  /*
  double _calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Distance().as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return totalDistance;
  }

  double _calculateDirectDistance(LatLng start, LatLng end) {
    return Distance().as(LengthUnit.Meter, start, end);
  }
   */

  double _calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Distance(ellipsoid: _getEllipsoid()).as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return totalDistance;
  }

  double _calculateDirectDistance(LatLng start, LatLng end) {
    return Distance(ellipsoid: _getEllipsoid()).as(LengthUnit.Meter, start, end);
  }

  Timer? _debounce;
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _getSuggestions(query).then((suggestions) {
        setState(() {
          _suggestions = suggestions;
        });
      });
    });
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (query.length < 2) {
      return [];
    }
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        return [];
      }

      List<String> suggestions = [];
      for (var location in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, location.longitude,
        );
        suggestions.addAll(
          placemarks.map((placemark) {
            return [
              placemark.locality,
              placemark.postalCode,
              placemark.administrativeArea
            ].where((element) => element != null && element.isNotEmpty).join(', ');
          }).where((s) => s.isNotEmpty),
        );
      }
      return suggestions.toSet().take(5).toList();
    } catch (e) {
      print('Error occurred while fetching suggestions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(51.1460157, 10.5109841),
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: _getMapUrlTemplate(), //"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_searchedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _searchedPosition!,
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _stationMarkers,
              ),
            ],
          ),
          if (!_isSearchMode)
            Positioned(
              top: screenHeight / 17,
              left: 10.0,
              right: 10.0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Center(
                    child: Container(
                      width: _focusNode.hasFocus ? screenWidth : screenWidth / 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800]!.withOpacity(_opacityAnimation.value) : Colors.white.withOpacity(_opacityAnimation.value),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode
                          ..addListener(() {
                            if (_focusNode.hasFocus) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          }),
                        decoration: InputDecoration(
                          hintText: localizations.search,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                          alignLabelWithHint: true,
                        ),
                        onSubmitted: (value) {
                          _searchLocation(value);
                          _searchController.clear();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_isSearchMode)
            Positioned(
              top: 40.0,
              right: 10.0,
              child: Column(
                children: [
                  Container(
                    width: screenWidth / 3,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800]!.withOpacity(_opacityAnimation.value) : Colors.white.withOpacity(_opacityAnimation.value),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startController,
                            decoration: InputDecoration(
                              hintText: localizations.startpoint,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                              alignLabelWithHint: true,
                            ),
                            onSubmitted: (value) {
                              _searchLocation(value, isStart: true);
                              //_startController.clear();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.my_location),
                          tooltip: localizations.curpos,
                          onPressed: () {
                            if (_currentPosition != null) {
                              _startController.text = '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: screenWidth / 3,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800]!.withOpacity(_opacityAnimation.value) : Colors.white.withOpacity(_opacityAnimation.value),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      controller: _endController,
                      decoration: InputDecoration(
                        hintText: localizations.endpoint,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                        alignLabelWithHint: true,
                      ),
                      onSubmitted: (value) {
                        _searchLocation(value);
                        //_endController.clear();
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    ),
                    onPressed: _clearInputs,
                    child: Text(localizations.clearinput, style: TextStyle(color: Colors.amber[800]),),
                  ),
                ],
              ),
            ),
          if (_showSlider)
            Positioned(
              right: 10,
              top: 100,
              bottom: 100,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: _zoomLevel,
                  min: 1.0,
                  max: 18.0,
                  onChanged: _onSliderChanged,
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Text(
                      _totalDistance < 1000
                          ? '${localizations.linedistance}: ${_isMetric ? _totalDistance.toStringAsFixed(2) : _formatDistance(_totalDistance)} ${_isMetric ? localizations.m : localizations.mi}'
                          : '${localizations.linedistance}: ${_isMetric ? (_totalDistance / 1000).toStringAsFixed(2) : _formatDistance(_totalDistance)} ${_isMetric ? localizations.km : localizations.mi}',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _directDistance < 1000
                          ? '${localizations.distance}: ${_isMetric ? _directDistance.toStringAsFixed(2) : _formatDistance(_directDistance)} ${_isMetric ? localizations.m : localizations.mi}'
                          : '${localizations.distance}: ${_isMetric ? (_directDistance / 1000).toStringAsFixed(2) : _formatDistance(_directDistance)} ${_isMetric ? localizations.km : localizations.mi}',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: screenHeight / 37.5, // Center the FAB vertically in the lower third
            left: (screenWidth / 2 + 135), // Center the FAB horizontally
            child: FloatingActionButton(
              tooltip: _isSearchMode == false ? localizations.searchactive : localizations.searchinactive,
              onPressed: _toggleSearchMode,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              child: Icon(_isSearchMode ? Icons.close : Icons.search, color: Colors.amber[800]),
            ),
          ),
          Positioned(
            bottom: screenHeight / 37.5, // Center the FAB vertically in the lower third
            left: (screenWidth / 2 - 190), // Center the FAB horizontally
            child: FloatingActionButton(
              tooltip: localizations.uppos,
              onPressed: _getCurrentLocation,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              child: Icon(Icons.my_location, color: Colors.amber[800]),
            ),
          ),
        ],
      ),
    );
  }
}