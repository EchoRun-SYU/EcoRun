import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_theme.dart';
import '../models/run_model.dart';

class RecordDetailScreen extends StatelessWidget {
  final RunModel run;

  const RecordDetailScreen({super.key, required this.run});

  static String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _formatDate(String iso) {
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일 $hh:$mm';
  }

  List<LatLng> _parseRoute() {
    if (run.routeJson == null) return [];
    try {
      final list = json.decode(run.routeJson!) as List;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return LatLng(
          (m['lat'] as num).toDouble(),
          (m['lng'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = run.durationSeconds ?? 0;
    final distance = run.distanceKm ?? 0.0;
    final paceSeconds = distance > 0 ? (duration / distance).round() : 0;
    final paceMin = paceSeconds ~/ 60;
    final paceSec = (paceSeconds % 60).toString().padLeft(2, '0');
    final routePoints = _parseRoute();
    final mapCenter = routePoints.isNotEmpty
        ? routePoints[routePoints.length ~/ 2]
        : const LatLng(37.5665, 126.9780);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              _formatDate(run.startedAt),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: 13),
            ),
            Text('플로깅 기록',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 10)),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child:
              Container(height: 1, color: AppColors.outlineVariant.withAlpha(80)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── 지도 카드 ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.55,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: mapCenter, zoom: 15),
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      polylines: routePoints.isNotEmpty
                          ? {
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: routePoints,
                                color: AppColors.primaryContainer,
                                width: 5,
                                startCap: Cap.roundCap,
                                endCap: Cap.roundCap,
                              ),
                            }
                          : {},
                      markers: routePoints.isNotEmpty
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
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(110)
                            ],
                            stops: const [0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          Icon(Icons.eco_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text('EcoRun',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(duration),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${distance.toStringAsFixed(2)} ',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17),
                            ),
                            const TextSpan(
                              text: 'KM',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── 통계 row ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12)
                ],
              ),
              child: Row(
                children: [
                  _statCell(context, "$paceMin'$paceSec\"", '평균 페이스'),
                  _vDivider(),
                  _statCell(context, '${run.calories ?? 0}', '칼로리'),
                  _vDivider(),
                  _statCell(
                    context,
                    '${run.trashCollected ?? 0}',
                    '수거 완료',
                    valueColor: AppColors.primaryContainer,
                  ),
                ],
              ),
            ),

            // ── EXP 카드 ──────────────────────────────────────────
            if ((run.expGained ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFB923C), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.secondaryContainer.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 4))
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
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('획득한 EXP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                    Text('+${run.expGained}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24)),
                    const Text(' EXP',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],

            // ── 수거 인증 내역 ─────────────────────────────────────
            const SizedBox(height: 12),
            if ((run.trashCollected ?? 0) > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(6), blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          color: AppColors.primaryContainer, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('수거 인증 완료',
                              style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            '이번 플로깅에서 ${run.trashCollected}개의 쓰레기를 수거했어요',
                            style: const TextStyle(
                                color: AppColors.outline, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(6), blurRadius: 8)
                  ],
                ),
                child: const Column(
                  children: [
                    Text('🗑️', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 10),
                    Text('수거 인증 내역이 없어요',
                        style: TextStyle(
                            color: AppColors.outline, fontSize: 13)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCell(BuildContext context, String value, String label,
      {Color? valueColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: valueColor ?? AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.outline, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 40,
        color: AppColors.outlineVariant.withAlpha(80),
      );
}
