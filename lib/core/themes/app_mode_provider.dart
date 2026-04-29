import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Riverpod Notifier that holds and updates the current [ThemeMode].
class AppModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default to light; could be extended to restore from persistence.
    return ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    if (state != mode) state = mode;
  }
}

/// Exposes the current [ThemeMode] and allows updates via the notifier.
final appModeProvider = NotifierProvider<AppModeNotifier, ThemeMode>(
  AppModeNotifier.new,
);
