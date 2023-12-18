import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_player/auth/join_partner.dart';
import 'package:couple_player/auth/sign_in.dart';
import 'package:couple_player/screens/player_view.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';

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

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  MobileAds.instance.initialize();

  runApp(const MyApp());
}

@override
void initState() {}

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
      home: FutureBuilder(
        future: beforeLoad(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ?? Container();
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            );
          }
        },
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
