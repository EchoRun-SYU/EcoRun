# 핵심 로직

## ActiveRunScreen (`active_run_screen.dart`)
- `Timer.periodic(1s)` 로 초 카운트 → 거리/칼로리 시뮬레이션
- `_isPaused` bool 로 달리기 화면 ↔ 일시정지 화면 전환
- 일시정지 화면 하단 버튼 3개: **종료**(검정), **수거 인증**(오렌지), **재개**(초록)
- `TrashCollectScreen` 에서 `Navigator.push<int>` → 수거 개수 반환

## RankingScreen (`ranking_screen.dart`)
- `TabController` 로 LOCAL / CITY 탭 전환
- 상위 3명 포디움 + 리더보드 리스트
- 하단 고정 배너: 내 순위 표시

## 커스텀 페인터
- `_RoutePainter` (active_run_screen): 일시정지 화면 지도 경로
- `_SummaryRoutePainter` (run_summary_screen): 완료 요약 지도 경로
- 실제 지도 연동 시 `google_maps_flutter` 패키지로 교체 예정
