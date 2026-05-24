package com.example.ecorun

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.RenderMode

// FlutterActivity → FlutterFragmentActivity:
//   Android 16 (API 36) 에뮬레이터에서 FlutterActivity + SurfaceView 조합이
//   surface width=0으로 초기화되어 검은 화면이 발생함.
//   FlutterFragmentActivity는 Fragment 레이어를 통해 surface를 생성하여
//   DisplayPresentTime 비-zero(실제 화면 출력)를 확인한 유일한 조합.
// RenderMode.texture:
//   SurfaceView 대신 TextureView를 사용하여 SurfaceHolder 타이밍 문제를 우회.
class MainActivity : FlutterFragmentActivity() {
    override fun getRenderMode(): RenderMode = RenderMode.texture
}
