import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinPartner extends StatefulWidget {
  const JoinPartner({super.key});

  @override
  State<JoinPartner> createState() => _JoinPartnerState();
}

class _JoinPartnerState extends State<JoinPartner> {
  TextEditingController _keyController = TextEditingController();
  TextEditingController _addKeyController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _keyController.text = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Connect with Your Partner".toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryColor,
        ),
        body: Column(
          children: [
            const ColoredBox(
              color: primaryColor,
              child: TabBar(
                indicatorColor: acsentColor,
                labelColor: Colors.white,
                unselectedLabelColor: secondryColor,
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    text: "Share The Key",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                    ),
                    text: "Add Partner Key",
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: SizedBox(
                          child: Column(
                            children: [
                              const Text(
                                "Share The Key",
                                style: TextStyle(
                                  fontFamily: 'BubbleBobble',
                                  fontSize: 26,
                                  color: primaryColor,
                                ),
                              ),
                              const Text(
                                "You can share the Key with your partner and he or she can connect with you easily.",
                                style: TextStyle(
                                  color: secondryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                controller: _keyController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.key,
                                    color: secondryColor,
                                  ),
                                  fillColor: Colors.black,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: secondryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      FlutterClipboard.copy(_keyController.text)
                                          .then(
                                        (value) {
                                          Fluttertoast.showToast(
                                            msg: "Copied to Clipboard!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            textColor: primaryColor,
                                            backgroundColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.copy_rounded,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return whatsappColor;
                                      }
                                      return Colors.white;
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  String url =
                                      'whatsapp://send?text=${_keyController.text}';

                                  Uri encodedUri = Uri.parse(url);
                                  setState(() {
                                    launchUrl(
                                      encodedUri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.send,
                                  color: whatsappColor,
                                ),
                                label: const Text(
                                  'Send via WhatsApp',
                                  style: TextStyle(
                                    color: whatsappColor,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: SizedBox(
                          child: Column(
                            children: [
                              const Text(
                                "Connect with the Partner",
                                style: TextStyle(
                                  fontFamily: 'BubbleBobble',
                                  fontSize: 26,
                                  color: primaryColor,
                                ),
                              ),
                              const Text(
                                "You can paste the key that your partner shared with you and press the connect button.",
                                style: TextStyle(
                                  color: secondryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                cursorColor: primaryColor,
                                controller: _addKeyController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.add,
                                    color: secondryColor,
                                  ),
                                  hintText: 'Paste the Key here...',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  fillColor: Colors.black,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: secondryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      FlutterClipboard.paste().then(
                                        (value) {
                                          setState(() {
                                            _addKeyController.text = value;
                                          });
                                          Fluttertoast.showToast(
                                            msg: "Pasted",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            textColor: primaryColor,
                                            backgroundColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.paste_rounded,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return secondryColor;
                                      }
                                      return primaryColor;
                                    },
                                  ),
                                ),
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    await connectWithPartner(
                                            _addKeyController.text)
                                        .then((value) => {
                                              Fluttertoast.showToast(
                                                msg: "Done",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                textColor: Colors.white,
                                                backgroundColor: Colors.green,
                                                fontSize: 16.0,
                                              ),
                                              _addKeyController.clear(),
                                            });
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                      msg: "Oops! Something went wrong!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.red,
                                      fontSize: 16.0,
                                    );
                                  }

                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.connect_without_contact,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Connect',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> connectWithPartner(String partnerKey) async {
  // Get the current user
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw Exception("User not signed in");
  }

  // Search for the document using the _addKeyController value
  DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(partnerKey)
      .get();

  if (!userDoc.exists) {
    throw Exception("User not found");
  }

  // Check if partnerId is null
  if (userDoc.data()?['partnerId'] != null) {
    throw Exception("User already connected with a partner");
  }

  // Create a new document in 'players' collection
  DocumentReference<Map<String, dynamic>> playerDoc =
      await FirebaseFirestore.instance.collection('players').add({
    'someField': 'someValue', // Add other fields as needed
  });

  // Get the document ID of the newly created 'players' document
  String playerInfoId = playerDoc.id;

  // Update the partner's document in 'users' collection
  await FirebaseFirestore.instance.collection('users').doc(partnerKey).update({
    'partnerId': currentUser.uid,
    'playerInfoId': playerInfoId,
  });

  // Update the current user's document in 'users' collection
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .update({
    'partnerId': partnerKey,
    'playerInfoId': playerInfoId,
  });
}
