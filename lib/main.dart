import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/app/app.dart';
import 'package:online_banking_system/core/session/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.instance.restoreSession();
  runApp(const ProviderScope(child: FinanceFlowApp()));
}
