import 'package:flutter/material.dart';
import 'package:krang/components/navbar_admin.dart';

class SupportPageAdmin extends StatefulWidget {
  const SupportPageAdmin({super.key});

  @override
  State<SupportPageAdmin> createState() => _SupportPageAdminState();
}

class _SupportPageAdminState extends State<SupportPageAdmin> {
  final List<Map<String, dynamic>> feedbacks = [
    {
      "name": "Katie Smolin",
      "age": "17",
      "text":
          "Perhaps there is no such person who does not know about the online cinema \"Krang\". Everything is fine with me. I've even gotten used to the monthly subscription fee, which is quite affordable. The main thing that you like...",
      "viewed": false,
    },
    {
      "name": "John Parker",
      "age": "21",
      "text":
          "Great app, very convenient UI. I wish there were more filtering options for recommendations and better subtitles support.",
      "viewed": true,
    },
    {
      "name": "Maria Gomez",
      "age": "26",
      "text":
          "Customer support answered quickly. Found a small bug in the player — it sometimes freezes on skip. Please check.",
      "viewed": false,
    },
    {
      "name": "Alex Brown",
      "age": "19",
      "text":
          "Love the catalog. Could be nice to have a 'watch later' sync across devices.",
      "viewed": true,
    },
    {
      "name": "Sofia Lee",
      "age": "23",
      "text":
          "Everything works fine for me. The monthly pricing is ok. I'd like to see more anime.",
      "viewed": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121212);
    const unreadCardColor = Color(0xFF2E2F36);
    const readCardColor = Color(0xFF1C1D22);
    const subtitleColor = Color(0xFFAEB0B6);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: const NavbarAdmin(selectedIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Feedback',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Список карточек
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: feedbacks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = feedbacks[index];
                  final bool viewed = item["viewed"] == true;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        feedbacks[index]["viewed"] = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: viewed ? readCardColor : unreadCardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🧍 Аватар пользователя
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF414553),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/icons_admin/user.png',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                  color: viewed ? Colors.white54 : Colors.white,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // 👤 Имя и текст
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item["name"]}, ${item["age"]} y.o.',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: viewed
                                            ? Colors.white60
                                            : Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["text"] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: viewed
                                            ? subtitleColor.withOpacity(0.7)
                                            : subtitleColor,
                                        fontSize: 11.5,
                                        height: 1.35,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 🟢 точка
                          if (!viewed)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
