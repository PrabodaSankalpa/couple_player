import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_player/screens/settings.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as youtube;

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  TextEditingController _searchController = TextEditingController();

  List<youtube.Video> ytResult = [];
  bool isSearching = false;
  final Duration _debounceTime = const Duration(milliseconds: 500);
  Timer? _debounceTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String audioTitle = "";
  String userName = '';
  String partnerName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserNames();
  }

  void _getUserNames() async {
    await getUserNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Couple Player",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSettings(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: secondryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      partnerName,
                      style: const TextStyle(
                        fontFamily: "BubbleBobble",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("❤"),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: "BubbleBobble",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    // Clear the results if the search text is empty
                    setState(() {
                      ytResult.clear();
                    });
                  } else {
                    searchYouTube(
                        value); // Call searchYouTube when text changes
                  }
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            // Clear the search text and results
                            setState(() {
                              _searchController.clear();
                              setState(() {
                                ytResult.clear();
                              });
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (isSearching)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ) // Display CircularProgressIndicator while searching
            else if (ytResult.isEmpty)
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/sign_up_cover.webp',
                    width: 200,
                    filterQuality: FilterQuality.none,
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),
              ) // Display a message if no results are found
            else
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: ytResult.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          playAudioFromYouTube(ytResult[index]);
                        },
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Image.network(
                                  ytResult[index].thumbnails.highResUrl),
                              title: Text(ytResult[index].title),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth
                      .instance.currentUser!.uid) // Current user's document
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const CircularProgressIndicator();
                }

                var playerInfoId = snapshot.data!['playerInfoId'];

                if (playerInfoId == null) {
                  return const Text('Player info not available');
                }

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('players')
                      .doc(
                          playerInfoId) // Use the playerInfoId from the user document
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          playerSnapshot) {
                    if (!playerSnapshot.hasData ||
                        playerSnapshot.data == null) {
                      return const CircularProgressIndicator();
                    }

                    var playerData = playerSnapshot.data!.data();
                    var playerState = playerData?['state'];

                    switch (playerState) {
                      case 'resume':
                        _audioPlayer.resume();
                        break;
                      case 'pause':
                        _audioPlayer.pause();
                        break;
                      case 'stop':
                        _audioPlayer.stop();
                        clearAudioTitle();
                        break;

                      case 'play':
                        var audioStreamUrl = playerData?['audioUrl'];
                        var position = playerData?['position'] ?? 0;

                        if (audioStreamUrl != null) {
                          _audioPlayer.stop();
                          _audioPlayer.play(
                            UrlSource(audioStreamUrl),
                            position: Duration(seconds: position),
                          );
                        }
                        break;
                      // Add more cases as needed

                      default:
                        break;
                    }
                    return Container();
                  },
                );
              },
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Card(
                  elevation: 3,
                  color: primaryColor,
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              constraints: const BoxConstraints(maxHeight: 100),
                              child: (SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth.instance.currentUser!
                                          .uid) // Current user's document
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const CircularProgressIndicator();
                                    }

                                    var playerInfoId =
                                        snapshot.data!['playerInfoId'];

                                    if (playerInfoId == null) {
                                      return const Text(
                                          'Player info not available');
                                    }

                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('players')
                                          .doc(
                                              playerInfoId) // Use the playerInfoId from the user document
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>
                                              playerSnapshot) {
                                        if (!playerSnapshot.hasData ||
                                            playerSnapshot.data == null) {
                                          return const CircularProgressIndicator();
                                        }

                                        var playerData =
                                            playerSnapshot.data!.data();
                                        audioTitle = playerData?['audioTitle'];
                                        var audioState = playerData?['state'];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              audioTitle != ''
                                                  ? audioState
                                                      .toString()
                                                      .toUpperCase()
                                                  : ''.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              audioTitle != ''
                                                  ? audioTitle
                                                  : "No Audio Selected Yet",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              )),
                            ),
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Your custom audio controls
                                Row(
                                  children: [
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        shape: CircleBorder(),
                                        color: secondryColor,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.stop,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          updatePlaybackState('stop');
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: Ink(
                                        decoration: const ShapeDecoration(
                                          shape: CircleBorder(),
                                          color: secondryColor,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            updatePlaybackState('pause');
                                          },
                                        ),
                                      ),
                                    ),
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        shape: CircleBorder(),
                                        color: secondryColor,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          updatePlaybackState('resume');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to search YouTube videos based on the user input
  void searchYouTube(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () async {
      setState(() {
        isSearching = true;
      });

      try {
        var yt = youtube.YoutubeExplode();
        var result = await yt.search.getVideos(query);

        // Convert search results to a list of videos
        ytResult = result.toList();

        // Dispose of the YoutubeExplode instance
        yt.close();
      } catch (e) {
        print('Error searching YouTube: $e');
        // Handle the error as needed
      }

      setState(() {
        isSearching = false;
      });
    });
  }

  Future<void> playAudioFromYouTube(youtube.Video video) async {
    setState(() {
      isSearching = true;
    });

    try {
      var yt = youtube.YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(video.id);

      // Find the audio stream
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      var audioStreamUrl = audioStreamInfo.url;

      // Get the duration of the audio stream
      var duration = video.duration?.inSeconds ?? 0;

      // Dispose of the YoutubeExplode instance
      yt.close();

      // Play the audio using the AudioPlayer
      // await _audioPlayer.stop(); // Stop any existing audio
      // await _audioPlayer.play(
      //   UrlSource(audioStreamUrl.toString()),
      //   position: const Duration(seconds: 0),
      // );

      // Update the 'players' collection document using playerInfoId
      // Assuming playerInfoId is a field in the 'users' collection document
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var userDoc =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        var userSnapshot = await userDoc.get();
        var playerInfoId = userSnapshot['playerInfoId'];

        if (playerInfoId != null) {
          var playerDoc = FirebaseFirestore.instance
              .collection('players')
              .doc(playerInfoId);

          // Update the 'state' field directly in the playerDoc
          await playerDoc.update(
            {
              'audioTitle': video.title,
              'audioUrl': audioStreamUrl.toString(),
              'duration': duration, // Store the duration in the document
              'position': 0, // Initial position is set to 0
              'state': 'play', // Change this based on your logic
            },
          );
        }
      }
    } catch (e) {
      print('Error playing audio from YouTube: $e');
      // Handle the error as needed
    }

    setState(() {
      isSearching = false;
    });
  }

  Future<void> updatePlaybackState(String state) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      var userSnapshot = await userDoc.get();
      var playerInfoId = userSnapshot['playerInfoId'];

      if (playerInfoId != null) {
        var playerDoc =
            FirebaseFirestore.instance.collection('players').doc(playerInfoId);

        // Update the 'state' field directly in the playerDoc
        await playerDoc.update({
          'state': state,
        });
      }
    }
  }

  Future<void> clearAudioTitle() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      var userSnapshot = await userDoc.get();
      var playerInfoId = userSnapshot['playerInfoId'];

      if (playerInfoId != null) {
        var playerDoc =
            FirebaseFirestore.instance.collection('players').doc(playerInfoId);

        // Update the 'audioTitle' field directly in the playerDoc
        await playerDoc.update({
          'audioTitle': "",
          'audioUrl': null,
          'duration': 0,
          'position': 0,
          'state': null,
        });
      }
    }
  }

  Future<void> getUserNames() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          // userName = userDoc['displayName'];
          var partnerInfoId = userDoc['partnerId'];

          if (partnerInfoId != null) {
            var partnerDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(partnerInfoId)
                .get();

            if (partnerDoc.exists) {
              // partnerName = partnerDoc['displayName'];
              setState(() {
                userName = userDoc['displayName'];
                partnerName = partnerDoc['displayName'];
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error retrieving user names: $e');
      // Handle the error as needed
    }
  }
}
