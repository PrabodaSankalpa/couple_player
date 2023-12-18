import 'dart:async';
import 'dart:math';

//import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:couple_player/screens/settings.dart';
import 'package:couple_player/utils/ad_mob_service.dart';
import 'package:couple_player/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as youtube;

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  TextEditingController _searchController = TextEditingController();
  final confettiController = ConfettiController();

  List<youtube.Video> ytResult = [];
  bool isSearching = false;
  bool isConfettiPlaying = false;
  final Duration _debounceTime = const Duration(milliseconds: 500);
  Timer? _debounceTimer;
  late AudioPlayer _audioPlayer;
  String audioTitle = "";
  String userName = '';
  String partnerName = '';
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _getUserNames();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
    confettiController.dispose();
  }

  void _getUserNames() async {
    await getUserNames();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () {
                      confettiController.stop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Thanks..."),
                  )
                ],
                title: const Text('Happy Birthday Suduu...❤😘'),
                contentPadding: const EdgeInsets.all(20.0),
                content: const Text("S💕S"),
              ),
            );
            confettiController.play();
          },
          child: const Text(
            "Couple Player",
            style: TextStyle(color: Colors.white),
          ),
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
            icon: const Icon(
              Icons.settings,
              color: secondryColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                shouldLoop: true,
                blastDirection: pi / 2,
                gravity: 0.2,
                numberOfParticles: 10,
                minBlastForce: 1,
                maxBlastForce: 50,
                emissionFrequency: 0.10,

              ),
            ),
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

                if (playerInfoId == null || playerInfoId == '') {
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
                        //_audioPlayer.resume();
                        var position = playerData?['position'] ?? 0;
                        _audioPlayer.seek(Duration(seconds: position));
                        _audioPlayer.play();
                        updatePlaybackState("play");
                        break;
                      case 'pause':
                        _audioPlayer.pause();
                        break;
                      case 'stop':
                        _audioPlayer.stop();
                        clearAudioTitle();
                        _showInterstitialAd();
                        break;

                      case 'play':
                        var audioStreamUrl = playerData?['audioUrl'];
                        var position = playerData?['position'] ?? 0;
                        var isNew = playerData?['isNew'];

                        // String? currentAudioStreamUrl =
                        //     _audioPlayer.audioSource is UriAudioSource
                        //         ? (_audioPlayer.audioSource as UriAudioSource)
                        //             .uri
                        //             .toString()
                        //         : null;

                        // if (currentAudioStreamUrl != audioStreamUrl &&
                        //     _audioPlayer.playing) {
                        //   _audioPlayer.stop();
                        // }

                        if ((audioStreamUrl != null || audioStreamUrl != '') &&
                            isNew == true) {
                          // Create an AudioSource using AudioPlayer
                          var audioSource = ConcatenatingAudioSource(
                            children: [
                              AudioSource.uri(
                                Uri.parse(audioStreamUrl),
                                tag: MediaItem(
                                  id: '', // Use a unique ID for each media item
                                  album: "Couple Player",
                                  title: playerData?['audioTitle'],
                                  artUri: null,
                                ),
                              ),
                            ],
                          );

                          // Set the new audio source
                          _audioPlayer.setAudioSource(audioSource);

                          // Seek to the specified position
                          _audioPlayer.seek(Duration(seconds: position));

                          //setIsNew
                          setIsNew();

                          // Play the audio
                          _audioPlayer.play();
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

                                    if (playerInfoId == null ||
                                        playerInfoId == '') {
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

        if (playerInfoId != null || playerInfoId != '') {
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
              'isNew': true,
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

      if (playerInfoId != null || playerInfoId != '') {
        var playerDoc =
            FirebaseFirestore.instance.collection('players').doc(playerInfoId);

        // Get the current position before updating the state
        var currentPosition = _audioPlayer.position;

        // Update the 'state' and 'position' fields directly in the playerDoc
        await playerDoc.update({
          'state': state,
          'position': currentPosition.inSeconds,
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

      if (playerInfoId != null || playerInfoId != '') {
        var playerDoc =
            FirebaseFirestore.instance.collection('players').doc(playerInfoId);

        // Update the 'audioTitle' field directly in the playerDoc
        await playerDoc.update({
          'audioTitle': "",
          'audioUrl': '',
          'duration': 0,
          'position': 0,
          'state': '',
          'isNew': true,
        });
      }
    }
  }

  Future<void> setIsNew() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      var userSnapshot = await userDoc.get();
      var playerInfoId = userSnapshot['playerInfoId'];

      if (playerInfoId != null || playerInfoId != '') {
        var playerDoc =
            FirebaseFirestore.instance.collection('players').doc(playerInfoId);

        // Update the 'audioTitle' field directly in the playerDoc
        await playerDoc.update({
          'isNew': false,
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

          if (partnerInfoId != null || partnerInfoId != '') {
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

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
