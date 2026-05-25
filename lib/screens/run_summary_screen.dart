import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../app_theme.dart';
import 'main_scaffold.dart';

class RunSummaryScreen extends StatelessWidget {
  final int seconds;
  final double distance;
  final int calories;
  final int collected;
  final int expGained;
  final List<LatLng> routePoints;

  const RunSummaryScreen({
    super.key,
    required this.seconds,
    required this.distance,
    required this.calories,
    required this.collected,
    required this.expGained,
    this.routePoints = const [],
  });

  String get _timeDisplay {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _pace {
    if (distance < 0.01) return "8'24\"";
    final paceSeconds = (seconds / distance).round();
    final pm = paceSeconds ~/ 60;
    final ps = paceSeconds % 60;
    return "$pm'${ps.toString().padLeft(2, '0')}\"";
  }

  void _shareResult() {
    final text = '🌱 EcoRun 플로깅 완료!\n'
        '📅 $_dateString\n'
        '⏱️ 시간: $_timeDisplay\n'
        '🏃 거리: ${distance.toStringAsFixed(2)} km\n'
        '🗑️ 수거: $collected 개\n'
        '⚡ 획득 EXP: +$expGained\n'
        '평균 페이스: $_pace\n\n'
        '#EcoRun #플로깅 #환경보호';
    Share.share(text);
  }

  String get _dateString {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScaffold()),
            (_) => false,
          ),
        ),
        title: Column(
          children: [
            Text(_dateString, style: Theme.of(context).textTheme.bodyLarge),
            Text('플로깅 완료',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScaffold()),
              (_) => false,
            ),
            icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    _buildSummaryMap(),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('EcoRun',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(_timeDisplay,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Text(
                        '${distance.toStringAsFixed(2)} KM',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 16,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  _stat(context, _pace, '평균 페이스'),
                  _divider(),
                  _stat(context, '$calories', '칼로리'),
                  _divider(),
                  _stat(context, '$collected', '수거 완료'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('플로깅 완료!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                  Text('+$expGained',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  const Text(' EXP',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCarbonSection(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('공유하기'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScaffold()),
                      (_) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: AppColors.outlineVariant),
                      shape: const StadiumBorder(),
                    ),
                    child: Text('플로깅 종료하기',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: AppColors.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryMap() {
    final hasRoute = routePoints.isNotEmpty;
    final center = hasRoute
        ? routePoints[routePoints.length ~/ 2]
        : const LatLng(37.5665, 126.9780);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: center, zoom: 15),
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      polylines: hasRoute
          ? {
              Polyline(
                polylineId: const PolylineId('summary_route'),
                points: routePoints,
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
                position: routePoints.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('end'),
                position: routePoints.last,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            }
          : {},
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: AppColors.outlineVariant);

  Widget _buildCarbonSection() {
    final drivingCarbonG = (distance * 210).round();
    final trashCarbonG = collected * 83;
    final totalCarbonG = drivingCarbonG + trashCarbonG;
    final treeDays = (totalCarbonG / 60).round();
    final carbonDisplay = totalCarbonG >= 1000
        ? '${(totalCarbonG / 1000).toStringAsFixed(2)} kg'
        : '$totalCarbonG g';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withAlpha(70),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.air_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('탄소 절감량',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    Text('달리기 + 쓰레기 수거 합산',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: carbonDisplay,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          fontFamily: 'PlusJakartaSans'),
                    ),
                    const TextSpan(
                      text: ' CO₂',
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          fontFamily: 'PlusJakartaSans'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _carbonChip('🏃',
                drivingCarbonG >= 1000
                    ? '${(drivingCarbonG / 1000).toStringAsFixed(1)}kg'
                    : '${drivingCarbonG}g',
                '달리기 절감'),
            const SizedBox(width: 8),
            _carbonChip(
                '♻️',
                trashCarbonG >= 1000
                    ? '${(trashCarbonG / 1000).toStringAsFixed(1)}kg'
                    : '${trashCarbonG}g',
                '수거 절감'),
            const SizedBox(width: 8),
            _carbonChip('🌳', '$treeDays일', '나무 흡수 환산',
                valueColor: AppColors.primaryContainer),
          ],
        ),
      ],
    );
  }

  Widget _carbonChip(String emoji, String value, String label,
      {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(8), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.outline, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
