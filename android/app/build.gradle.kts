plugins {
    id("com.android.application")

    // Firebase services plugin
    id("com.google.gms.google-services")

    // Kotlin
    id("kotlin-android")

    // Flutter (must be applied last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ua_dating_app"
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
        applicationId = "com.example.ua_dating_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required for multidex (especially with Firebase + Google Sign-In)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // Multidex support (optional but good with Firebase)
    implementation("androidx.multidex:multidex:2.0.1")
}
