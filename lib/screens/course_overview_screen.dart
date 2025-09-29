import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'video_player_screen.dart';

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({super.key});

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchYouTubeLessons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchYouTubeLessons() async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=figma+design+course&type=video&maxResults=6&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        setState(() {
          lessons = items.map((item) {
            final snippet = item['snippet'];
            return {
              'title': snippet['title'] ?? 'Untitled Lesson',
              'videoId': item['id']['videoId'] ?? '',
              'thumbnail': snippet['thumbnails']?['high']?['url'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching YouTube lessons: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(screenHeight),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseHeader(),
                      const SizedBox(height: 24),
                      _buildTabBar(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: screenHeight * 0.55,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLessonsList(),
                            _buildDescription(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(Icons.arrow_back_ios_new, () {
                  Navigator.pop(context); // normal back navigation
                }),
                _circleButton(Icons.favorite_border, () {}),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomEnrollBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(double screenHeight) {
    return Container(
      height: screenHeight * 0.3,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://images.prismic.io/edapp-website/a50cf7ea-0988-4029-b1ab-80b2e29f21d4_best-online-learning-apps.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Figma master class for beginners',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
            SizedBox(width: 6),
            Text('Dynamic lessons from YouTube',
                style: TextStyle(fontSize: 15, color: Colors.blueGrey)),
            Spacer(),
            Icon(Icons.star, size: 18, color: Colors.amber),
            SizedBox(width: 6),
            Text('4.9', style: TextStyle(fontSize: 15, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
        ),
        tabs: const [
          Tab(text: 'Lessons'),
          Tab(text: 'Description'),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (lessons.isEmpty) return const Center(child: Text("No lessons found."));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final videoId = lesson['videoId'] ?? '';
        final title = lesson['title'] ?? 'Untitled Lesson';

        return InkWell(
          onTap: videoId.isNotEmpty
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(
                  videoId: videoId,
                  title: title,
                ),
              ),
            );
          }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient:
              const LinearGradient(colors: [Colors.white, Color(0xFFF0F9FF)]),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                    LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)]),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.blueGrey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "This course pulls dynamic video lessons directly from YouTube API. You’ll be able to watch and learn seamlessly in-app.",
        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }

  Widget _buildBottomEnrollBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFF8FAFC)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF2563EB),
        ),
        child: const Text(
          "Enroll Now",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
