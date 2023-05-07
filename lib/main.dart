import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tourmate/firebase_options.dart';
import 'package:tourmate/auth_pages/log_in_page.dart';
import 'package:tourmate/auth_pages/sign_up_page.dart';
import 'package:tourmate/google_map.dart';
import 'package:tourmate/new_post_page.dart';
import 'package:tourmate/welcome_page.dart';
import 'package:tourmate/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_pages/profile_image_page.dart';
import 'auth_pages/user_name_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TourMate',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Hiragano Sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(134, 93, 255, 1),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/signup': (context) => const SignUpPage(), //新規登録
        '/login': (context) => const LogInPage(), //ログイン
        '/home': (context) => const HomePage(), //ホーム
        '/user_name': (context) => const UserNamePage(), //ユーザネーム
        '/profile_image': (context) => const ImagePage(), //プロフィール画像
        '/google_map': (context) => const GoogleMapPage(), //GoogleMap
        '/new_post': (context) => const NewPostPage(), //新規投稿
      },
    );
  }
}
