import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the app's theme mode (Light or Dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);