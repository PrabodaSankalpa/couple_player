import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_player/main.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              color: primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/sign_up_cover.webp',
                    height: 200,
                  ),
                  const Text(
                    "Couple Player",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontFamily: "BubbleBobble",
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    "The Lovers' Music Player!",
                    style: TextStyle(
                      color: secondryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });

                        signInWithGoogle().then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp()),
                          );
                        });
                      },
                      icon: const Icon(
                        Icons.login_rounded,
                        color: primaryColor,
                      ),
                      label: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  //Loader
                  isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user?.email);

    // Check if the user document exists in the Firestore collection
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .get();

    if (!userDoc.exists) {
      // If the document does not exist, create it with initial data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'displayName': userCredential.user?.displayName
            ?.split(" ")[0], // Save the first part of displayName
        'partnerId': null,
        'playerInfoId': null,
      });
    }
  }
}
