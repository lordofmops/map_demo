import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.locationWhenInUse.status;
  if (!status.isGranted) {
    await Permission.locationWhenInUse.request();
  }

  if (await Permission.locationAlways.isDenied) {
    await Permission.locationAlways.request();
  }
}
