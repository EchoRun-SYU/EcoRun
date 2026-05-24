# EcoRun 개발 스케줄

## 완료된 작업

| 날짜 | 작업 내용 |
|------|-----------|
| ~2026-05-25 | 초기 UI 구축 (12개 화면 Stitch 기반) |
| ~2026-05-25 | GPS 연동 (`geolocator` + `GpsService`) |
| ~2026-05-25 | 지도 연동 (`google_maps_flutter` — 런 경로 실시간/요약) |
| ~2026-05-25 | AI 쓰레기 인식 (`image_picker` + `/trash/analyze` API) |
| ~2026-05-25 | 백엔드 API 전체 연동 (Auth/User/Run/Trash/EXP/Ranking) |
| ~2026-05-25 | 구글 OAuth 로그인 + 세션 복원 |

---

## 진행 예정

### 1순위 — 푸시 알림 (FCM)
- **목표**: 주요 이벤트 발생 시 유저에게 푸시 알림 전송
- **구현 범위**:
  - `firebase_core` + `firebase_messaging` 패키지 추가
  - Android(`google-services.json`) / iOS(`GoogleService-Info.plist`) Firebase 설정
  - FCM 토큰 발급 후 백엔드에 등록 (`POST /users/me/fcm-token`)
  - 알림 수신 핸들러 (포그라운드 / 백그라운드 / 앱 종료 상태)
  - 로컬 알림 표시 (`flutter_local_notifications`)
  - 알림 종류: 플로깅 완료, 주간 랭킹 변동, 7일 미활동 리마인더
- **예상 소요**: 1~2일

### 2순위 — 뱃지 시스템
- **목표**: 프로필 화면 뱃지 섹션 실제 데이터 연동
- **구현 범위**:
  - `ApiService.getBadges()` 추가 (`GET /users/me/badges`)
  - `BadgeModel` 완성 (백엔드 응답 매핑)
  - 뱃지 달성 조건 정의 (첫 런, 5km 달성, 쓰레기 10개 수거 등)
  - 런 완료 시 신규 뱃지 달성 여부 체크 → 팝업 표시
- **예상 소요**: 0.5~1일

### 3순위 — BPM 센서
- **목표**: 활성 런 화면 BPM '--' 표시 → 실제 심박수
- **구현 방식 검토**:
  - 옵션 A: 카메라 플래시 PPG (`camera` 패키지 — 별도 하드웨어 불필요)
  - 옵션 B: 블루투스 심박계 연동 (`flutter_blue_plus`)
- **선택 후 구현 예정**

### 4순위 — 카카오 / 네이버 로그인
- **목표**: 로그인 화면 '준비중' 버튼 활성화
- **구현 범위**:
  - `kakao_flutter_sdk_user` 패키지 + 카카오 개발자 앱 등록
  - 네이버 로그인 SDK 또는 웹뷰 방식
  - 백엔드 `/auth/kakao` / `/auth/naver` 엔드포인트 협의
- **예상 소요**: 1~2일 (백엔드 협의 포함)

---

## 코드 감사 결과 (2026-05-25)

### 🔴 Critical — 실제로 동작 안 함

- [x] **RegisterScreen — MockApiService 사용 중** (`lib/screens/register_screen.dart:36`)
  - Google OAuth 전용으로 전환 → `register_screen.dart`, `mock_api_service.dart` 삭제
  - 신규 유저는 구글 로그인 후 `NicknameSetupScreen`으로 이동하는 기존 흐름 유지

### 🟠 데이터 오염 — 화면은 보이지만 틀린 값 표시

- [x] **랭킹 weeklyExp 계산 오류** (`lib/models/ranking_model.dart:43`)
  - 백엔드 `RankingResponse`에 `exp` 필드 추가, 프론트 `totalDistance * 10` 근사치 → 실제 `exp` 사용
- [x] **홈 "이번 달" 통계 오염** (`lib/models/stats_model.dart:72-80`)
  - `getMyStats()`에서 `/runs` 병렬 호출 → 이번 달 완료 런만 필터링해 monthly 필드 계산
- [x] **TrashResultScreen 설정 토글 하드코딩** (`lib/screens/trash_result_screen.dart:130`)
  - SettingsScreen에 SharedPreferences 저장/로드 추가
  - TrashResultScreen이 `settings_auto_pause` / `settings_voice_feedback` 키로 실제값 읽음

### 🟡 미연동 UI — 화면은 있지만 기능 없음

- [x] **ProfileScreen 뱃지 빈 배열 하드코딩** (`lib/screens/profile_screen.dart`)
  - stats 기반 클라이언트 사이드 뱃지 계산 (`_computeBadges`) — 첫 걸음/5K/쓰레기 전사/꾸준한 러너/10K 5종
- [x] **SettingsScreen 설정값 저장 안 됨** (`lib/screens/settings_screen.dart`)
  - `SharedPreferences` 저장/로드 완료 (이전 작업에서 완료됨)
- [x] **RunScreen 오늘의 목표 "0 / 3" 하드코딩** (`lib/screens/run_screen.dart`)
  - `getRuns()` 호출 후 오늘 완료 런 필터링 → 실제 카운트 표시
- [x] **RunScreen 설정 버튼 빈 콜백** (`lib/screens/run_screen.dart`)
  - `SettingsScreen`으로 push 연결
- [x] **RunSummaryScreen 공유하기 버튼 빈 콜백** (`lib/screens/run_summary_screen.dart`)
  - `share_plus` 패키지로 런 요약 텍스트 공유
- [x] **SettingsScreen 권한 항목 탭 빈 콜백** (`lib/screens/settings_screen.dart`)
  - `app_settings` 패키지로 시스템 앱 설정 화면 이동

### 수정 권장 순서
1. RegisterScreen — MockApiService 제거 (Critical)
2. SettingsScreen — SharedPreferences 저장 연동 (다른 화면도 의존)
3. ProfileScreen — 뱃지 API 연동
4. 나머지 하드코딩 정리
