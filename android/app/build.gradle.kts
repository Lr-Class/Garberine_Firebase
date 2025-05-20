plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Plugin de servicios de Google
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin debe ir después
}

android {
    namespace = "com.example.app_garb"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }


    defaultConfig {
        applicationId = "com.example.app_garb"
        minSdkVersion(24)
        targetSdkVersion(flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-storage-ktx")
    implementation("androidx.multidex:multidex:2.0.1")
}
