import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/core/dependency_injection/service_locator.dart';
import 'package:repair_hub/core/constants/app_secrets.dart';
import 'package:repair_hub/feature/customer_website/presentation/cubit/web_tracking_cubit.dart';
import 'package:repair_hub/feature/customer_website/presentation/screens/customer_tracking_screen.dart';
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
  if (kIsWeb) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocProvider.value(
          value: serviceLocator<WebTrackingCubit>(),
          child: const CustomerTrackingScreen(),
        ),
      ),
    );
  } else {
    runApp(const RepairHubApp());
  }
}
