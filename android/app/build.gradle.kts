plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_barishal_new"
    // আপনার প্লাগইনগুলোর জন্য compileSdk 36 করা হয়েছে
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Java 11 ব্যবহার নিশ্চিত করা হয়েছে
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.my_barishal_new"
        minSdk = flutter.minSdkVersion // এখানে সরাসরি 21 ব্যবহার করা নিরাপদ
        targetSdk = 36 // compileSdk-এর সাথে মিলিয়ে 36 করা হয়েছে
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // MultiDex চালু করা হয়েছে, যা বড় অ্যাপের জন্য জরুরি
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
    implementation(kotlin("stdlib-jdk8"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.core:core-ktx:1.12.0")
    // MultiDex লাইব্রেরি যোগ করা হয়েছে
    implementation("androidx.multidex:multidex:2.0.1")
}
