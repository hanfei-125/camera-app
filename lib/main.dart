import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/environment_confirmation_screen.dart';
import 'presentation/screens/camera_screen.dart';
import 'presentation/screens/analysis_result_screen.dart';
import 'presentation/screens/main_shot_screen.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/camera/camera_bloc.dart';
import 'presentation/bloc/analysis/analysis_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SmartCameraApp());
}

class SmartCameraApp extends StatelessWidget {
  const SmartCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => CameraBloc()),
        BlocProvider(create: (_) => AnalysisBloc()),
      ],
      child: MaterialApp(
        title: 'AI相机',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/environment-confirm': (context) => const EnvironmentConfirmationScreen(),
          '/camera': (context) => const CameraScreen(),
          '/analysis-result': (context) => const AnalysisResultScreen(),
          '/main-shot': (context) => const MainShotScreen(),
        },
      ),
    );
  }
}
