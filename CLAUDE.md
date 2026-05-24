# EcoRun Flutter 프로젝트 가이드

## 앱 개요
**EcoRun** — 플로깅(plogging) 앱. 달리면서 쓰레기를 줍고 EXP를 획득하는 에코 러닝 서비스.
- 언어: 한국어 UI / 플랫폼: Flutter (Android/iOS)

## 파일 구조

```
lib/
  main.dart                      # 앱 진입점 → 세션 복원 → LoginScreen / MainScaffold
  app_theme.dart                 # 컬러/타이포그래피 디자인 시스템
  screens/
    login_screen.dart            # 로그인 (구글 OAuth — 카카오/네이버 준비중)
    register_screen.dart         # 회원가입
    nickname_setup_screen.dart   # 신규 유저 닉네임 설정
    main_scaffold.dart           # 바텀 네비 컨트롤러 (홈/러닝/랭킹/프로필)
    home_screen.dart             # 홈 대시보드 (통계/레벨/랭킹 미리보기)
    run_screen.dart              # 플로깅 시작 화면 (START 버튼)
    active_run_screen.dart       # 활성 런 + 일시정지 상태 (GPS + 지도)
    trash_collect_screen.dart    # 수거 인증 (카메라/갤러리 → AI 분석)
    trash_result_screen.dart     # 수거 인증 결과 (+EXP 표시)
    run_summary_screen.dart      # 플로깅 완료 요약 (경로 지도 포함)
    ranking_screen.dart          # 랭킹 (LOCAL / CITY 탭)
    profile_screen.dart          # 내 프로필 (레벨, 통계, 뱃지)
    settings_screen.dart         # 설정 (권한, 자동일시중지, 음성피드백)
  services/
    api_service.dart             # 백엔드 REST API 클라이언트 (싱글톤)
    gps_service.dart             # GPS 스트림 · 거리 누적 서비스
  state/
    app_state.dart               # 전역 상태 (로그인 토큰, 유저, 레벨)
  models/
    user_model.dart / level_model.dart / stats_model.dart
    run_model.dart / ranking_model.dart
    trash_model.dart / badge_model.dart / exp_model.dart
```

## 의존성 (`pubspec.yaml`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  http: ^1.2.2
  shared_preferences: ^2.3.2
  image_picker: ^1.1.2
  google_sign_in: ^6.2.1
  geolocator: ^12.0.0
  google_maps_flutter: ^2.9.0
```

## 구현 현황

### 완료 ✅
- [x] 실제 GPS → `geolocator` (`GpsService` — 거리 누적, 일시정지/재개)
- [x] 지도 → `google_maps_flutter` (활성 런 경로 실시간 표시, 요약 화면 경로 뷰)
- [x] AI 쓰레기 인식 → `image_picker` + 백엔드 `/trash/analyze` API
- [x] 백엔드 API 연동 — 구글 OAuth 로그인, 유저/레벨/통계, 런 시작·종료, 쓰레기 등록, EXP, 랭킹

### 미구현 🔲
- [ ] 푸시 알림 (FCM) — 플로깅 완료 알림, 주간 랭킹 변동, 활동 리마인더
- [ ] BPM 센서 — 현재 '--' 표시 (카메라 PPG 또는 블루투스 심박계 연동)
- [ ] 뱃지 시스템 — UI 존재하나 badges=[] 빈 상태, 백엔드 /badges API 연동 필요
- [ ] 카카오 / 네이버 로그인 (현재 '준비중' 비활성)

---

## 상세 문서
- [내비게이션 흐름](docs/navigation.md)
- [디자인 시스템 (컬러/타이포/컴포넌트)](docs/design-system.md)
- [핵심 로직 (ActiveRun, Ranking, Painter)](docs/core-logic.md)
- [Stitch 원본 스크린 목록](docs/stitch-screens.md)

## Clean Code 큐칙
naming — 이름
변수·함수명은 의도를 드러낸다
d, tmp, data 금지. elapsedTimeInDays, getUserById처럼 읽으면 바로 파악 가능해야 함.
검색 가능한 이름을 사용한다
매직 넘버 금지. 86400 대신 SECONDS_PER_DAY = 86400 로 상수화.
인코딩·접두어를 붙이지 않는다
헝가리안 표기법(strName, iCount) 금지. 타입은 타입 시스템이 표현.
클래스명은 명사, 함수명은 동사
Customer, WikiPage / deletePage(), save(), isValid()
functions — 함수
함수는 한 가지 일만 한다
함수 내부를 추상화 수준 한 단계로 유지. 여러 섹션으로 나뉜다면 분리 신호.
인자는 최대 3개 이하
4개 이상이면 인자 객체(options, config)로 묶는다.
부수 효과(side effect)를 없앤다
함수 이름이 암시하지 않는 동작(전역 변수 수정, IO 등)을 몰래 하지 않음.
명령과 조회를 분리한다 (CQS)
상태 변경 함수는 값을 반환하지 않음. 값을 반환하는 함수는 상태를 바꾸지 않음.
DRY — 중복을 제거한다
코드가 세 번 반복되면 함수로 추출. 동일한 로직이 두 곳에 있으면 한 곳으로.
comments — 주석
주석보다 코드로 설명한다
주석이 필요한 순간은 코드가 의도를 못 드러낸다는 신호. 먼저 이름과 구조를 개선.
좋은 주석만 남긴다
법적 주석, 의도 설명, 경고, TODO, 공개 API JSDoc/docstring 은 허용.
주석 처리된 코드는 즉시 삭제한다
버전 관리가 있다. 죽은 코드는 git이 기억함.
formatting — 형식
파일 세로 길이를 작게 유지한다
한 파일 200~500줄 이내 목표. 길어지면 분리 신호.
개념적으로 가까운 코드는 세로로 붙인다
서로 관련된 함수·변수는 파일 내에서 가깝게 배치. 호출하는 함수가 호출되는 함수 위에.
팀 규칙을 우선한다
개인 취향보다 prettier / eslint / linter 설정을 따름. 자동화가 곧 규칙.
error handling — 오류 처리
오류 코드 대신 예외를 사용한다
반환값으로 오류를 전달하면 호출부가 즉시 확인해야 함. 예외로 분리.
null을 반환하지 않는다
null 반환 → 호출부에 null 체크 강요. 빈 컬렉션, Optional, 예외를 대신 사용.
오류 메시지에 맥락을 담는다
어떤 연산이 실패했는지, 어디서 발생했는지 정보를 포함.
classes — 클래스
클래스는 작아야 한다 — SRP
단일 책임 원칙. 클래스를 한 문장으로 설명할 수 없으면 분리.
높은 응집도를 유지한다
메서드가 클래스 변수 대부분을 사용해야 함. 변수를 조금만 쓰는 메서드는 분리 후보.
변경에 닫히고 확장에 열린다 (OCP)
기존 코드를 수정하지 않고 새 기능을 추가할 수 있는 구조를 지향


## 개발 흐름의 규칙
1. 개발 예정 내용은 Schedule.md 파일에 작성해둘것
2. 개발 완료 후 빌드 / 작동 테스트를 진행할것
3. 기능에 문제가 있을경우 디버깅 및 수정 작업을 거칠 것.
4. 개발 완료 후 git내역 커밋할것(내 명의만 사용하여)
**필요할 경우 ecorunBackend 에 있는 Backend 와 비교분석및 교차개발할것"