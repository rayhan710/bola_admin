import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // WAJIB ADA: Untuk setting Mouse
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bola Admin',
        home: const LoginPage(),
        // AKTIFKAN SCROLL MOUSE DI SINI
        scrollBehavior: MyCustomScrollBehavior(),
      ),
    ),
  );
}

// --- CLASS TAMBAHAN AGAR BISA DRAG PAKAI MOUSE DI WINDOWS ---
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // Untuk HP (Sentuh)
    PointerDeviceKind.mouse, // Untuk Windows (Klik & Geser)
  };
}
