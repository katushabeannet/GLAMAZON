import 'package:flutter/material.dart';
import 'package:glamazon/screens/splash.dart';
import 'package:glamazon/screens/profile_page.dart'; 
import 'package:glamazon/screens/edit_profile_page.dart';
import 'package:glamazon/utils/colors.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  HydratedBloc.storage= await HydratedStorage.build(storageDirectory: await getApplicationDocumentsDirectory());
  runApp(const MyApplication());
}

class MyApplication extends StatelessWidget {
  const MyApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Splash(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/profile': (context) => ProfilePage(
              // profileImageUrl: 'https://example.com/profile.jpg',
              // salonName: 'Glamazon Salon',
              // location: '123 Beauty Street, Glamour City',
              // ownerName: 'Alinda Tracy',
              // contact: '123-456-7890',
              // email: 'alinda.tracy@example.com',
              // websiteUrl: 'https://example.com',
              // aboutUs:
                  // 'Welcome to Glamazon Salon, where beauty meets excellence!',
            ),
        '/edit-profile': (context) => const EditProfilePage(),
      },
    );
  }
}
