import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_player/auth/join_partner.dart';
import 'package:couple_player/auth/sign_in.dart';
import 'package:couple_player/screens/player_view.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: primaryColor,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Couple Player",
      home: EasySplashScreen(
        logo: Image.asset('assets/sign_up_cover.webp'),
        title: const Text(
          "Couple Player",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        showLoader: true,
        loadingText: const Text("Loading..."),
        futureNavigator: beforeLoad(),
      ),
    );
  }

  Future<Widget> beforeLoad() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not logged in, show SignIn
      return const SignIn();
    } else {
      // User is logged in, check 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Check if partnerId is null
        if (userDoc.data()?['partnerId'] == null) {
          // partnerId is null, show JoinPartner
          return const JoinPartner();
        } else {
          // partnerId is not null, show PlayerView
          return const PlayerView();
        }
      } else {
        // User document not found, handle accordingly (you may want to show an error screen)
        return const Scaffold(
          body: Center(
            child: Text("Error"),
          ),
        );
      }
    }
  }
}
