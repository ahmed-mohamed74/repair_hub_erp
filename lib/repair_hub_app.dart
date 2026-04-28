import 'package:flutter/material.dart';
import 'package:repair_hub/core/routes/app_router.dart';
import 'package:repair_hub/core/theme/app_theme.dart';

class RepairHubApp extends StatelessWidget {
  const RepairHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Repair Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
