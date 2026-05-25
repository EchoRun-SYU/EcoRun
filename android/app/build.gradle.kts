import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}

// 릴리스 서명 키 — 로컬: local.properties / CI: 환경변수
val keystoreFile = System.getenv("KEYSTORE_PATH")
    ?: localProps.getProperty("KEYSTORE_PATH", "")
val keystorePassword = System.getenv("KEYSTORE_PASSWORD")
    ?: localProps.getProperty("KEYSTORE_PASSWORD", "")
val keyAlias = System.getenv("KEY_ALIAS")
    ?: localProps.getProperty("KEY_ALIAS", "ecorun")
val keyPassword = System.getenv("KEY_PASSWORD")
    ?: localProps.getProperty("KEY_PASSWORD", "")

android {
    namespace = "com.example.ecorun"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (keystoreFile.isNotEmpty()) {
                storeFile = file(keystoreFile)
                storePassword = keystorePassword
                keyAlias = keyAlias
                keyPassword = keyPassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.ecorun"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] =
            localProps.getProperty("MAPS_API_KEY", System.getenv("MAPS_API_KEY") ?: "")
    }

    buildTypes {
        release {
            signingConfig = if (keystoreFile.isNotEmpty())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
