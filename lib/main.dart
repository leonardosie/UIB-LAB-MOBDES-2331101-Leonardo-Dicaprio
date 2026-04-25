import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/movie_provider.dart';
import 'providers/theme_provider.dart';
import 'views/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Hi Movie',
            debugShowCheckedModeBanner: false,

            // 🔥 GLOBAL THEME MODE
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // ☀️ LIGHT THEME
            theme: ThemeData(
              fontFamily: 'Poppins',
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5FA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1A1A2E),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),

            // 🌙 DARK THEME
            darkTheme: ThemeData(
              fontFamily: 'Poppins',
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
