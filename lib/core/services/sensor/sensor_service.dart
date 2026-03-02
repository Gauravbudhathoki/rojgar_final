import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  double gyroX = 0;
  double gyroY = 0;
  double gyroZ = 0;

  static const double _shakeThreshold = 18.0;
  static const int _shakeCooldownMs = 1500;

  DateTime? _lastShakeTime;
  void Function()? onShake;
  void Function()? onGyroUpdate;

  void start() {
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldownMs) {
          _lastShakeTime = now;
          onShake?.call();
        }
      }
    });

    _gyroSub = gyroscopeEventStream().listen((event) {
      gyroX = event.x;
      gyroY = event.y;
      gyroZ = event.z;
      onGyroUpdate?.call();
    });
  }

  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
  }
}