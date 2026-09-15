import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/medicine/view_models/medicine_view_model.dart';
import 'ui/features/device/view_models/device_view_model.dart';
import 'ui/features/splash/views/splash_view.dart';

class SmartMedApp extends StatelessWidget {
  const SmartMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
        ChangeNotifierProvider(create: (_) => DeviceViewModel()),
      ],
      child: MaterialApp(
        title: 'SmartMed',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashView(),
      ),
    );
  }
}
