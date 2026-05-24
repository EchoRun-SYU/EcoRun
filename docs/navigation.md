# 내비게이션 흐름

```
LoginScreen
  ├─→ RegisterScreen → MainScaffold
  └─→ MainScaffold (로그인 성공)
        ├─ [탭0] HomeScreen
        ├─ [탭1] RunScreen
        │     └─→ ActiveRunScreen (START 버튼)
        │           ├─→ TrashCollectScreen (수거 인증 버튼)
        │           │     └─→ TrashResultScreen → (pop back)
        │           └─→ RunSummaryScreen (종료) → MainScaffold
        ├─ [탭2] RankingScreen
        └─ [탭3] ProfileScreen
                    └─→ SettingsScreen
```
