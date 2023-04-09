package com.example.flutter_rust_bridge_template

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    init {
        System.loadLibrary("engine");
        System.out.println("after engine load");
    }
}
