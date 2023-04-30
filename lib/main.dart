import 'package:alert_up_project/provider/admin_provider.dart';
import 'package:alert_up_project/provider/app_provider.dart';
import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/location_provider.dart';
import 'package:alert_up_project/provider/reports_provider.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/utilities/firebase.dart';
import 'package:alert_up_project/utilities/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'provider/user_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      systemNavigationBarContrastEnforced: true));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();  
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiseasesProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'AlertUp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: APP_COLOR_THEME,
          textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            displayLarge:
                GoogleFonts.poppins(textStyle: textTheme.displayLarge),
            displayMedium:
                GoogleFonts.poppins(textStyle: textTheme.displayMedium),
            displaySmall:
                GoogleFonts.poppins(textStyle: textTheme.displaySmall),
            headlineLarge:
                GoogleFonts.poppins(textStyle: textTheme.headlineLarge),
            headlineMedium:
                GoogleFonts.poppins(textStyle: textTheme.headlineMedium),
            headlineSmall:
                GoogleFonts.poppins(textStyle: textTheme.headlineSmall),
            titleLarge: GoogleFonts.poppins(textStyle: textTheme.titleLarge),
            titleMedium: GoogleFonts.poppins(textStyle: textTheme.titleMedium),
            titleSmall: GoogleFonts.poppins(textStyle: textTheme.titleSmall),
            labelSmall: GoogleFonts.poppins(textStyle: textTheme.labelSmall),
            labelMedium: GoogleFonts.poppins(textStyle: textTheme.labelMedium),
            labelLarge: GoogleFonts.poppins(textStyle: textTheme.labelLarge),
            bodySmall: GoogleFonts.poppins(textStyle: textTheme.bodySmall),
            bodyMedium: GoogleFonts.poppins(textStyle: textTheme.bodyMedium),
            bodyLarge: GoogleFonts.poppins(textStyle: textTheme.bodyLarge),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
