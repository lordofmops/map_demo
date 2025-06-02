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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Карта")),
      body: YandexMap(
        onMapCreated: (controller) async {
          _controller = controller;
          await _initUserLocation();
        },
        mapObjects: userPlacemark != null ? [userPlacemark!] : [],
      ),
    );
  }

  Future<void> _initUserLocation() async {
    try {
      final position = await locationService.getCurrentLocation();

      userPoint = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      userPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('user_location'),
        point: userPoint!,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('lib/assets/user.png')
          ),
        ),
      );

      await _controller?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userPoint!, zoom: 15),
        ),
      );

      setState(() {});
    } catch (e) {
      debugPrint('Ошибка получения местоположения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить местоположение')),
      );
    }
  }
}

