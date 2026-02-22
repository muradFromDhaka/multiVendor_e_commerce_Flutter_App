// lib/utils/logger.dart
import 'package:flutter/material.dart';

class Logger {
  static void info(String message) {
    debugPrint('📘 INFO: $message');
  }

  static void warning(String message) {
    debugPrint('⚠️ WARNING: $message');
  }

  static void error(String message) {
    debugPrint('❌ ERROR: $message');
  }

  static void success(String message) {
    debugPrint('✅ SUCCESS: $message');
  }

  static void api(String message) {
    debugPrint('🌐 API: $message');
  }
}