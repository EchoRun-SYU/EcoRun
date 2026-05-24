# 디자인 시스템 (`app_theme.dart` → `AppColors`)

## 주요 컬러
| 변수명 | 헥스 | 용도 |
|--------|------|------|
| `primary` | `#006E2F` | 텍스트 강조, 네비 활성 |
| `primaryContainer` | `#22C55E` | START 버튼, 프로그레스, 뱃지 |
| `onPrimaryContainer` | `#004B1E` | 진한 녹색 (Stop 버튼 등) |
| `secondaryContainer` | `#FD761A` | 수거 인증 액션, 오렌지 버튼 |
| `background` / `surface` | `#F7F9FB` | 앱 배경 |
| `surfaceLowest` | `#FFFFFF` | 카드 배경 |
| `surfaceContainerLow` | `#F2F4F6` | 서브 배경 |
| `surfaceContainer` | `#ECEEF0` | 칩, 태그 배경 |
| `onSurface` | `#191C1E` | 기본 텍스트 |
| `onSurfaceVariant` | `#3D4A3D` | 보조 텍스트 |
| `outline` | `#6D7B6C` | 비활성 아이콘, 보더 |
| `outlineVariant` | `#BCCBB9` | 구분선, 연한 보더 |

## 타이포그래피
- **폰트**: Plus Jakarta Sans (`google_fonts` 패키지)
- `displaySmall` → 36px, w800 (달리기 중 거리 숫자)
- `headlineLarge` → 30px, w800
- `headlineMedium` → 22px, w700
- `bodyLarge` → 18px, w600
- `bodyMedium` → 16px, w400
- `labelMedium` → 14px, w500, `onSurfaceVariant` 색상

## 컴포넌트 규칙
- **카드**: 흰 배경, 16px 라운드, `BoxShadow(blurRadius:16, y:2, alpha:8)`
- **버튼 (Primary)**: `primaryContainer` 배경, 흰 텍스트, `StadiumBorder` (완전 pill)
- **버튼 (Secondary/Stop)**: `onPrimaryContainer` 배경
- **수거 인증 버튼**: `secondaryContainer` (오렌지)
- **토글 스위치**: `activeThumbColor: primaryContainer`
- **프로그레스 바**: 8px 두께, 라운드 캡, `primaryContainer` 색
