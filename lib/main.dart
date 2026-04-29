import 'package:flutter/material.dart';
import 'package:repair_hub/core/dependency_injection/service_locator.dart';
import 'package:repair_hub/core/constants/app_secrets.dart';
import 'package:repair_hub/repair_hub_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  // Then setup DI
  configureDependencies();
  runApp(const RepairHubApp());
}
