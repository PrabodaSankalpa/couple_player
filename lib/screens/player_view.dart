import 'dart:async';

import 'package:couple_player/screens/settings.dart';
import 'package:couple_player/utils/colors.dart';
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
                  builder: (context) => const Settings(),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Nimal",
                      style: TextStyle(
                        fontFamily: "BubbleBobble",
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("❤"),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Kamala",
                      style: TextStyle(
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
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: primaryColor),
                  ),
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
                          // Handle tap on video result (you can navigate to a detailed view)
                        },
                        child: Card(
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
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Card(
                  elevation: 3,
                  color: Colors.white,
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
                              child: (const SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  "Api Pawena Loke - Wayo - Anagathaya",
                                  style: TextStyle(
                                    color: primaryColor,
                                  ),
                                ),
                              )),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.stop),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.pause),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
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
}
