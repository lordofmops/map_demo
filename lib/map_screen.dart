import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _controller;
  final locationService = LocationService();
  PlacemarkMapObject? userPlacemark;
  Point? userPoint;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final position = await locationService.getCurrentLocation();

    final point = Point(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState(() {
      userPoint = point;
      userPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('user_location'),
        point: point,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/user.png'),
            scale: 2,
          ),
        ),
      );
    });

    // Если контроллер уже готов — двигаем камеру сразу
    if (_controller != null) {
      _moveToUserLocation();
    }
  }

  void _moveToUserLocation() {
    if (_controller != null && userPoint != null) {
      _controller!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userPoint!, zoom: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Карта")),
      body: YandexMap(
        onMapCreated: (controller) {
          _controller = controller;
          _moveToUserLocation(); // ← когда контроллер готов, двигаем камеру
        },
        mapObjects: [
          if (userPlacemark != null) userPlacemark!,
        ],
      ),
    );
  }
}

