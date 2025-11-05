plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin должен идти после Android и Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.krang"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.krang"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // пока подпись debug, чтобы flutter run --release работал
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase Authentication для входа по телефону
    implementation("com.google.firebase:firebase-auth:22.3.1")

    // (опционально, если потом понадобится Firestore)
    implementation("com.google.firebase:firebase-firestore:25.0.0")
}

apply(plugin = "com.google.gms.google-services")
