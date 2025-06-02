import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final YandexMapController _mapController;
  final LocationService _locationService = LocationService();
  final List<MapObject> _mapObjects = [];
  Point? _userLocation;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
      ),
      body: Column(
        children: [
          Expanded(
            child: YandexMap(
              onMapCreated: (controller) async {
                _mapController = controller;
                await _initUserLocation();
                _drawRoute();
              },
              mapObjects: _mapObjects,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  // Метод для инициализации местоположения пользователя
  Future<void> _initUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      _userLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _updateUserPlacemark();
      await _moveToUserLocation();
    } catch (e) {
      _showError('Ошибка получения местоположения: $e');
    }
  }

  // Метод для обновления метки местоположения пользователя на карте
  void _updateUserPlacemark() {
    if (_userLocation == null) return;

    _mapObjects.removeWhere((obj) => obj.mapId == const MapObjectId('user_location'));

    _mapObjects.add(PlacemarkMapObject(
      mapId: const MapObjectId('user_location'),
      point: _userLocation!,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('lib/assets/user.png'),
          scale: 1.5,
        ),
      ),
    ));

    setState(() {});
  }

  // Метод для перемещения камеры на местоположение пользователя
  Future<void> _moveToUserLocation() async {
    if (_userLocation == null) return;

    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: 15),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
    );
  }

  // Метод для отображения маршрута на карте с помощью PolylineMapObject
  void _drawRoute() async {
    if (_userLocation == null) return;

    const destination = Point(latitude: 55.7600, longitude: 37.6200);

    try {
      final (session, resultFuture) = await YandexDriving.requestRoutes(
        points: [
          RequestPoint(
            point: _userLocation!,
            requestPointType: RequestPointType.wayPoint,
          ),
          RequestPoint(
            point: destination,
            requestPointType: RequestPointType.wayPoint,
          ),
        ],
        drivingOptions: const DrivingOptions(),
      );

      final result = await resultFuture;

      if (result.routes != null && result.routes!.isNotEmpty) {
        final route = result.routes!.first;

        _mapObjects.removeWhere((obj) => obj.mapId == const MapObjectId('route'));

        final routePolyline = PolylineMapObject(
          mapId: const MapObjectId('route'),
          polyline: route.geometry,
          strokeColor: Colors.blue,
          strokeWidth: 3,
          gapLength: 5,
          dashLength: 10
        );

        _mapObjects.add(routePolyline);
        setState(() {});
      } else {
        _showError('Не удалось построить маршрут');
      }
    } catch (e) {
      _showError('Ошибка построения маршрута: $e');
    }
  }

  // Метод для отображения ошибок на экране
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    debugPrint(message);
  }
}


