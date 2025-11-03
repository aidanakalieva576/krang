import 'package:flutter/material.dart';

class Review {
  final String userName;
  final String userReviewsCount;
  final int rating;
  final String date;
  final String text;

  Review({
    required this.userName,
    required this.userReviewsCount,
    required this.rating,
    required this.date,
    required this.text,
  });
}

class EditMoviePage extends StatefulWidget {
  final String movieId;
  final String title;
  final String category;
  final String thumbnailUrl;

  const EditMoviePage({
    super.key,
    required this.movieId,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
  });

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  double scrollOffset = 0.0;

  final List<Review> reviews = [
    Review(
      userName: 'Full name',
      userReviewsCount: '1.1K reviews',
      rating: 4,
      date: 'August 29, 2023',
      text:
      'A lot of stupidity wrapped in a pretty package. In fact, it was hard to even finish watching the first season in places, let alone write a review of this empty waste. However, from a technical standpoint, there\'s ...',
    ),
    Review(
      userName: 'Jane Doe',
      userReviewsCount: '500 reviews',
      rating: 5,
      date: 'July 10, 2023',
      text: 'Absolutely loved the animation and storyline! It kept me hooked from start to finish.',
    ),
    Review(
      userName: 'John Smith',
      userReviewsCount: '200 reviews',
      rating: 3,
      date: 'June 5, 2023',
      text: 'Good visuals but the plot was somewhat predictable and slow at times.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double posterHeight = 280;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -scrollOffset * 0.4,
            left: 0,
            right: 0,
            child: SizedBox(
              height: posterHeight + scrollOffset * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/icons_user/lego_movie.jpeg',
                        fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0F0F0F),
                          Color(0xFF0F0F0F),
                        ],
                        stops: [0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  setState(() => scrollOffset = scrollInfo.metrics.pixels);
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/icons_admin/line_to_back.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: posterHeight - 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '7.8, ',
                                  style: TextStyle(
                                    color: Color(0xFF6C78BB),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: 'The Warner Animation Group',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '2 h  |  0+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                                  (index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'An ordinary LEGO construction worker, thought to be the prophesied as "special", is recruited to join a quest to stop an evil tyrant from gluing the LEGO universe into eternal stasis.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          buildInfoRow('Year of production', '2014'),
                          const SizedBox(height: 10),
                          buildInfoRow('Platform', 'Netflix'),
                          const SizedBox(height: 10),
                          buildInfoRow(
                            'Director',
                            'Phil Lord, Christopher Miller',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showReviewsSheet(context),
                        icon: const Icon(Icons.reviews_rounded,
                            color: Colors.white),
                        label: const Text(
                          'Reviews',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E2E2E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => print('Hide clicked'),
                          child: Image.asset(
                            'assets/icons_admin/hide.png',
                            width: 42,
                            height: 42,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/edit'),
                          child: Image.asset(
                            'assets/icons_admin/edit.png',
                            width: 42,
                            height: 42,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text(
                                    "Delete Movie",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this movie?",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        print("Movie deleted");
                                        // Здесь можно добавить реальную логику удаления
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            'assets/icons_admin/delete_movie.png',
                            width: 42,
                            height: 42,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showReviewsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _buildReviewItem(review),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReviewItem(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.userName,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  review.userReviewsCount,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.date,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          review.text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Movie Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const EditMoviePage(
        movieId: '1',
        title: 'The LEGO Movie',
        category: 'Animation',
        thumbnailUrl:
        'https://upload.wikimedia.org/wikipedia/en/1/10/The_Lego_Movie_poster.jpg',
      ),
    );
  }
}
