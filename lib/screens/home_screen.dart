import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:learning_app/widgets/discovery_card.dart';
import 'package:learning_app/widgets/lesson_card.dart';
import 'package:learning_app/screens/course_overview_screen.dart';
import 'package:learning_app/screens/profile_screen.dart';
import 'package:learning_app/screens/saved_screen.dart';
import 'package:learning_app/screens/video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    CourseOverviewScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  final List<Map<String, String>> _discoverList = [
    {
      'title': 'Discover Top Picks',
      'subtitle': '+100 lessons',
      'imageUrl':
      'https://tse3.mm.bing.net/th/id/OIP.EkzZGy5_ebTmpqnw6X0F2QHaE7?pid=Api&h=220&P=0',
    },
    {
      'title': 'New Arrivals',
      'subtitle': '50+ new courses',
      'imageUrl':
      'https://tse3.mm.bing.net/th/id/OIP.EkzZGy5_ebTmpqnw6X0F2QHaE7?pid=Api&h=220&P=0',
    },
  ];

  final List<Map<String, dynamic>> _popularLessons = [
    {
      'title': 'Figma Master Class UI Design',
      'category': 'UI Design',
      'duration': '28 lessons',
      'rating': 4.9,
      'imageUrl':
      'https://tse4.mm.bing.net/th/id/OIP.N7tbb05kwxu7A-hZW6GGeQHaEH?pid=Api&h=220&P=0',
    },
    {
      'title': 'Web Design for UX Design',
      'category': 'UX Design',
      'duration': '14 lessons',
      'rating': 4.8,
      'imageUrl':
      'https://www.creative-tim.com/blog/content/images/2022/07/UX-design-courses.jpg',
    },
    {
      'title': 'Mobile App Development with Flutter',
      'category': 'Development',
      'duration': '40 lessons',
      'rating': 4.7,
      'imageUrl':
      'https://tse1.mm.bing.net/th/id/OIP.kBnZlyDE26sHuNBG65bPiAHaEK?pid=Api&h=220&P=0',
    },
  ];

  Future<void> _searchYouTube(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=5&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['items'] ?? [];
        });
      } else {
        debugPrint("YouTube API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("YouTube API Exception: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false, // remove unwanted back arrow
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E learning',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            Text(
              'Find your lessons today!',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[400]),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.blue),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEBF4FF), Color(0xFFEFF6FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _searchYouTube,
                        decoration: InputDecoration(
                          hintText: 'Search now...',
                          hintStyle: TextStyle(color: Colors.blueGrey[300]),
                          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _searchYouTube(_searchController.text),
                    ),
                  ),
                ],
              ),
            ),

            /// ⏳ Loader
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              ),

            /// 🎥 YouTube Results
            if (_searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: _searchResults.map((video) {
                    final snippet = video['snippet'];
                    final videoId = video['id']?['videoId'] ?? '';
                    return GestureDetector(
                      onTap: () {
                        if (videoId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerScreen(
                                videoId: videoId,
                                title: snippet['title'] ?? 'Video',
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.network(
                                snippet['thumbnails']?['default']?['url'] ?? '',
                                width: 120,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                snippet['title'] ?? 'No title',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            /// 🎯 Discover Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Discover Top Picks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.blue[900]),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: _discoverList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: DiscoveryCard(
                      title: item['title']!,
                      subtitle: item['subtitle']!,
                      imageUrl: item['imageUrl']!,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CourseOverviewScreen()),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            /// 📚 Popular Lessons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Lessons',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.blue[900]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CourseOverviewScreen()),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// 🔥 Popular Lessons Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: _popularLessons.map((lesson) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CourseOverviewScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: LessonCard(
                        title: lesson['title'],
                        category: lesson['category'],
                        duration: lesson['duration'],
                        rating: lesson['rating'],
                        imageUrl: lesson['imageUrl'],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
