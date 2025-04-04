import 'package:flutter/material.dart';
import 'iframe_util.dart';
import 'package:provider/provider.dart';

import 'screens/dashboard_screen.dart';
import 'services/data_service.dart';
import 'theme/app_theme.dart';

void main() {
  dfInitMessageListener();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DataService>(
          create: (_) => DataService(),
        ),
      ],
      child: MaterialApp(
        title: 'La Pépinière',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}
