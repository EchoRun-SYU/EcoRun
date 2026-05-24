import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GpsService {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3,
  );

  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  double _totalDistanceKm = 0.0;
  final List<Position> _positionHistory = [];
  bool _active = false;

  final _distanceController = StreamController<double>.broadcast();
  final _positionController = StreamController<Position>.broadcast();

  Stream<double> get distanceStream => _distanceController.stream;
  Stream<Position> get positionStream => _positionController.stream;
  double get totalDistanceKm => _totalDistanceKm;
  List<Position> get positionHistory => List.unmodifiable(_positionHistory);

  static Future<LocationPermission> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermission.denied;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  void start() {
    _active = true;
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(_onNewPosition);
  }

  void _onNewPosition(Position position) {
    if (_active && _lastPosition != null) {
      final meters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistanceKm += meters / 1000.0;
      if (!_distanceController.isClosed) {
        _distanceController.add(_totalDistanceKm);
      }
    }
    _lastPosition = position;
    if (_active) {
      _positionHistory.add(position);
      if (!_positionController.isClosed) {
        _positionController.add(position);
      }
    }
  }

  void pause() => _active = false;

  void resume() {
    _active = true;
    // 재개 시 lastPosition을 유지하여 일시정지 중 이동거리 누적 방지
    _lastPosition = null;
  }

  void stop() {
    _active = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stop();
    _distanceController.close();
    _positionController.close();
  }
}
