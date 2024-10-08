import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the firebase_options.dart file
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MusicStreamingApp());
}

class MusicStreamingApp extends StatelessWidget {
  const MusicStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Streaming',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MusicScreen(),
    );
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int _currentSongIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Sample song data
  final List<String> songImages = [
    'assets/song1.jpg',
    'assets/song2.jpg',
    'assets/song3.jpg',
    'assets/song4.jpg',
    'assets/song5.jpg',
    'assets/song6.jpg',
    'assets/song7.jpg',
    'assets/song8.jpg',
    'assets/song9.jpg',
    'assets/song10.jpg',
  ];

  // Song and artist names
  final List<String> songNames = [
    'Creative',
    'Forest',
    'Happy',
    'Lazy',
    'Lofi',
    'Nature',
    'Nightfall',
    'Radiant',
    'Twilight',
    'Song 10'
  ];

  final List<String> artistNames = [
    'Artist 1',
    'Artist 2',
    'Artist 3',
    'Artist 4',
    'Artist 5',
    'Artist 6',
    'Artist 7',
    'Artist 8',
    'Artist 9',
    'Artist 10'
  ];

  // Firebase Storage paths
  final List<String> songFiles = [
    'creative.mp3',
    'forest.mp3',
    'happy.mp3',
    'lazy.mp3',
    'lofi.mp3',
    'nature.mp3',
    'nightfall.mp3',
    'radiant.mp3',
    'twilight.mp3'
  ];

  List<String> songUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchSongUrls();
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _fetchSongUrls() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    List<String> urls = [];
    for (String fileName in songFiles) {
      try {
        String url = await storage.ref(fileName).getDownloadURL();
        urls.add(url);
      } catch (e) {
        print("Error fetching URL for $fileName: $e");
      }
    }

    setState(() {
      songUrls = urls;
    });
  }

  void _playSong(int index) async {
    if (songUrls.isNotEmpty) {
      await _audioPlayer.setUrl(songUrls[index]);
      _audioPlayer.play();
    }
  }

  void _pauseSong() {
    _audioPlayer.pause();
  }

  void _stopSong() {
    _audioPlayer.stop();
  }

  void _nextSong() {
    if (_currentSongIndex < songUrls.length - 1) {
      setState(() {
        _currentSongIndex++;
      });
      _playSong(_currentSongIndex);
    }
  }

  void _previousSong() {
    if (_currentSongIndex > 0) {
      setState(() {
        _currentSongIndex--;
      });
      _playSong(_currentSongIndex);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Music Streaming',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE1BEE7), Color(0xFFFFFFFF)], // Gradient
          ),
        ),
        child: songUrls.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Cards at the top
                  Expanded(
                    child: CarouselSlider.builder(
                      itemCount: songImages.length,
                      itemBuilder:
                          (BuildContext context, int index, int realIndex) {
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.asset(
                              songImages[_currentSongIndex],
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            ).animate().scale(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 300.0,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentSongIndex = index;
                          });
                          _playSong(index);
                        },
                      ),
                    ),
                  ),
                  // Displaying song name and artist name
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          songNames[_currentSongIndex],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          artistNames[_currentSongIndex],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Song controls and duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: _previousSong,
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _playSong(_currentSongIndex),
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: _pauseSong,
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: _stopSong,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _nextSong,
                      ),
                    ],
                  ),
                  // Displaying song duration and position
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      final newPosition = Duration(seconds: value.toInt());
                      _audioPlayer.seek(newPosition);
                    },
                  ),
                  Text(
                    "${_position.toString().split('.').first} / ${_duration.toString().split('.').first}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Cards list at the bottom
                  Container(
                    height: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 6.0,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: songImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          bool isSelected = _currentSongIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentSongIndex = index;
                              });
                              _playSong(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: isSelected
                                    ? const Color.fromARGB(255, 223, 163, 243)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      songImages[index],
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      songNames[index],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
