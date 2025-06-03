import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDAT_mhwlRc-D3TZ5isbP-NWqcBFz69B3M",
      authDomain: "vmouse-fa09d.firebaseapp.com",
      projectId: "vmouse-fa09d",
      storageBucket: "vmouse-fa09d.appspot.com",
      messagingSenderId: "1085317557158",
      appId: "1:1085317557158:android:a1d5e9628d3d440ee3bd67",  // Replace with your actual App ID from Firebase settings
      measurementId: "G-YOUR_MEASUREMENT_ID",  // Optional, only for analytics
    );
  }
}
