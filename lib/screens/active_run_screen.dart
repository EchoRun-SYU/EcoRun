import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/gps_service.dart';
import '../state/app_state.dart';
import 'trash_collect_screen.dart';
import 'run_summary_screen.dart';

class ActiveRunScreen extends StatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  final _gpsService = GpsService();
  StreamSubscription<double>? _distanceSubscription;
  StreamSubscription<Position>? _positionSubscription;

  Timer? _timer;
  int _seconds = 0;
  double _distance = 0.0;
  int _calories = 0;
  int _collected = 0;
  bool _isPaused = false;
  bool _stopping = false;
  bool _gpsActive = false;
  int? _runId;

  // 지도 관련
  GoogleMapController? _mapController;
  final List<LatLng> _routePoints = [];
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startRun();
  }

  Future<void> _startRun() async {
    _runId = await ApiService.instance.startRun();
    AppState.instance.setCurrentRunId(_runId);
    await _initGps();
  }

  Future<void> _initGps() async {
    final permission = await GpsService.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS 권한 없음 — 거리는 추정값으로 표시됩니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    _distanceSubscription = _gpsService.distanceStream.listen((distance) {
      if (mounted) setState(() => _distance = distance);
    });

    _positionSubscription = _gpsService.positionStream.listen(_onPosition);

    setState(() => _gpsActive = true);
    _gpsService.start();
  }

  void _onPosition(Position position) {
    if (!mounted) return;
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = latLng;
      _routePoints.add(latLng);
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
          if (!_gpsActive) _distance += 0.003;
          if (_seconds % 10 == 0) _calories++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _distanceSubscription?.cancel();
    _positionSubscription?.cancel();
    _mapController?.dispose();
    _gpsService.dispose();
    super.dispose();
  }

  String get _timeDisplay {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _pace {
    if (_distance < 0.01) return "--'--\"";
    final paceSeconds = (_seconds / _distance).round();
    final pm = paceSeconds ~/ 60;
    final ps = paceSeconds % 60;
    return "$pm'${ps.toString().padLeft(2, '0')}\"";
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _gpsService.pause();
    } else {
      _gpsService.resume();
    }
  }

  Future<void> _stopRun() async {
    if (_stopping) return;
    _timer?.cancel();
    _gpsService.stop();
    setState(() => _stopping = true);

    final expGained = (_distance * 20 + _collected * 10).round();
    if (_runId != null) {
      await ApiService.instance.endRun(
        _runId!,
        distance: _distance,
        duration: _seconds,
      );
    }

    AppState.instance.setCurrentRunId(null);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RunSummaryScreen(
          seconds: _seconds,
          distance: _distance,
          calories: _calories,
          collected: _collected,
          expGained: expGained,
          routePoints: _routePoints,
        ),
      ),
    );
  }

  Future<void> _collectTrash() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
          builder: (_) => TrashCollectScreen(runId: _runId ?? 0)),
    );
    if (result != null) setState(() => _collected += result);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPaused) return _buildRunning();
    return _buildPaused();
  }

  Widget _buildRunning() {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _topStat(_pace, '페이스'),
                  _topStat('--', 'BPM'),
                  _topStat(_timeDisplay, '시간'),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _distance.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Text(
                      '킬로미터',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    if (_gpsActive)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed,
                                color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text('GPS',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.pause_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaused() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildRouteMap(),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimaryContainer.withAlpha(220),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('일시정지',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.surfaceLowest,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _pausedStat(_distance.toStringAsFixed(2), '킬로미터'),
                      _pausedStat(_pace, '평균 페이스'),
                      _pausedStat(_timeDisplay, '시간'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _pausedStat('$_calories', '칼로리'),
                      _pausedStat('$_collected', '수거완료'),
                      _pausedStat('--', 'BPM'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.surfaceLowest,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(
                    Icons.stop_rounded,
                    _stopping
                        ? AppColors.onPrimaryContainer.withAlpha(120)
                        : AppColors.onPrimaryContainer,
                    '종료',
                    _stopping ? () {} : _stopRun,
                  ),
                  _controlButton(Icons.delete_outline_rounded,
                      AppColors.secondaryContainer, '수거 인증', _collectTrash),
                  _controlButton(Icons.play_arrow_rounded,
                      AppColors.primaryContainer, '재개', _togglePause),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMap() {
    final hasRoute = _routePoints.isNotEmpty;
    final initialTarget = _currentPosition ??
        (_routePoints.isNotEmpty ? _routePoints.last : const LatLng(37.5665, 126.9780));

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 16,
      ),
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: _gpsActive,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      polylines: hasRoute
          ? {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: AppColors.primaryContainer,
                width: 5,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            }
          : {},
      markers: hasRoute
          ? {
              Marker(
                markerId: const MarkerId('start'),
                position: _routePoints.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: '출발'),
              ),
            }
          : {},
    );
  }

  Widget _topStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _pausedStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800, fontSize: 20)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _controlButton(
      IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
