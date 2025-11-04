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
      'A lot of stupidity wrapped in a pretty package...',
    ),
    Review(
      userName: 'Jane Doe',
      userReviewsCount: '500 reviews',
      rating: 5,
      date: 'July 10, 2023',
      text:
      'Absolutely loved the animation and storyline!',
    ),
    Review(
      userName: 'John Smith',
      userReviewsCount: '200 reviews',
      rating: 3,
      date: 'June 5, 2023',
      text: 'Good visuals but predictable at times.',
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
          /// Постер
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

          /// Контент
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
                    /// Верхняя панель с кнопкой "Назад" и фото
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 16, top: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Image.asset(
                              'assets/icons_admin/line_to_back.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showUploadForm(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/icons_admin/add_movie.png', // ← твоя локальная иконка
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
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

                    /// Описание
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
                            'An ordinary LEGO construction worker ...',
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

                    /// Инфо
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          buildInfoRow('Year of production', '2014'),
                          const SizedBox(height: 10),
                          buildInfoRow('Platform', 'Netflix'),
                          const SizedBox(height: 10),
                          buildInfoRow('Director', 'Phil Lord, Christopher Miller'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Кнопка отзывов
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

  /// 🧩 Инфо ряд
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

  /// 🧾 Показываем форму UploadFormPage как модальное окно
  void _showUploadForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: UploadFormContent(),
      ),
    );
  }

  /// Отзывы
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
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.black54),
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
          style: const TextStyle(color: Colors.white54, fontSize: 12),
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

/// 🎬 Контент формы (из UploadFormPage)
class UploadFormContent extends StatefulWidget {
  const UploadFormContent({super.key});

  @override
  State<UploadFormContent> createState() => _UploadFormContentState();
}

class _UploadFormContentState extends State<UploadFormContent> {
  String? selectedOption;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.upload, color: Colors.black, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Name:", style: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("After:",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButton<String>(
                        value: selectedOption,
                        dropdownColor: Colors.grey[800],
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        hint: const Text("Options",
                            style: TextStyle(color: Colors.white70)),
                        items: ["Option 1", "Option 2", "Option 3"]
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style:
                                const TextStyle(color: Colors.white)),
                          ),
                        )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedOption = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child:
                Text("Duration:", style: TextStyle(color: Colors.white)),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text("min",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // логика подтверждения
                    },
                    child: Image.asset(
                      'assets/icons_admin/done.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons_admin/cross.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
