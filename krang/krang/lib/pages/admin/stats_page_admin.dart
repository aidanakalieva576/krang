import 'dart:math';
import 'package:flutter/material.dart';
import 'package:krang/components/navbar_admin.dart';

class StatsPageAdmin extends StatelessWidget {
  const StatsPageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121212);
    const pillSelected = Color(0xFF8B8CA0);
    const pillUnselected = Color(0xFF2E2E31);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reports & Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
                  const SizedBox(height: 14),

                  // ⏱️ Пилы
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TimePill(
                          label: 'Today',
                          selected: true,
                          colorSelected: pillSelected,
                          colorUnselected: pillUnselected,
                        ),
                        const SizedBox(width: 10),
                        _TimePill(
                          label: 'Week',
                          selected: false,
                          colorSelected: pillSelected,
                          colorUnselected: pillUnselected,
                        ),
                        const SizedBox(width: 10),
                        _TimePill(
                          label: 'Month',
                          selected: false,
                          colorSelected: pillSelected,
                          colorUnselected: pillUnselected,
                        ),
                        const SizedBox(width: 10),
                        _TimePill(
                          label: 'Year',
                          selected: false,
                          colorSelected: pillSelected,
                          colorUnselected: pillUnselected,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🎬 Top watched movies
                  const Text(
                    'Top Watched Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(width: 2),
                        _MovieCard(
                          image: 'assets/icons_admin/the_last_of_us.png',
                          title: 'The Last of Us',
                        ),
                        SizedBox(width: 12),
                        _MovieCard(
                          image: 'assets/icons_admin/conjuring.png',
                          title: 'The Conjuring: Last Rites',
                        ),
                        SizedBox(width: 12),
                        _MovieCard(
                          image: 'assets/icons_admin/haikyuu.png',
                          title: 'Haikyuu!',
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 📈 Viewing time
                  const Text(
                    'Viewing time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: _LineChartPainter(),
                      child: Container(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🌀 Top Genres
                  const Text(
                    'Top Genres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(140),
                          ),
                          child: CustomPaint(
                            painter: _PieChartPainter(),
                            child: Container(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _GenreColumn(name: 'Drama', percent: '37%'),
                              _GenreColumn(name: 'Romance', percent: '26%'),
                              _GenreColumn(name: 'Horror', percent: '18%'),
                              _GenreColumn(name: 'Fantasy', percent: '19%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // запас под navbar
                ],
              ),
            ),
          ),

          // 🧭 Навбар поверх контента (через Stack)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavbarAdmin(selectedIndex: 2),
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color colorSelected;
  final Color colorUnselected;
  const _TimePill({
    required this.label,
    required this.selected,
    required this.colorSelected,
    required this.colorUnselected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colorSelected : colorUnselected,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final String image;
  final String title;
  const _MovieCard({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 96,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _GenreColumn extends StatelessWidget {
  final String name;
  final String percent;
  const _GenreColumn({required this.name, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          percent,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.transparent;
    canvas.drawRect(Offset.zero & size, bg);
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;

    const graphShift = 13.0;
    canvas.drawLine(
      Offset(20 + graphShift, 8),
      Offset(20 + graphShift, size.height - 28),
      axisPaint,
    );
    canvas.drawLine(
      Offset(20 + graphShift, size.height - 28),
      Offset(size.width - 12 + graphShift, size.height - 28),
      axisPaint,
    );

    final values = <double>[55, 20, 45, 42, 27, 42, 25, 50];
    final maxVal = 60.0;
    final left = 24.0 + graphShift;
    final top = 16.0;
    final bottom = size.height - 32;
    final plotWidth = size.width - left - 24;
    final dxStep = plotWidth / (values.length - 1);

    final double lineY = top + (1 - (37 / maxVal)) * (bottom - top);
    final dashPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    double startX = left;
    while (startX < left + plotWidth) {
      canvas.drawLine(
        Offset(startX, lineY),
        Offset(startX + dashWidth, lineY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = left + dxStep * i;
      final y = top + (1 - (values[i] / maxVal)) * (bottom - top);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < values.length; i++) {
      final x = left + dxStep * i;
      final y = top + (1 - (values[i] / maxVal)) * (bottom - top);
      canvas.drawCircle(Offset(x, y), 4.0, dotPaint);
      canvas.drawCircle(Offset(x, y), 2.0, Paint()..color = Colors.black87);
    }

    final tickPaint = Paint()..color = Colors.white24;
    final ticks = 8;
    final tickStep = plotWidth / (ticks - 1);
    for (int i = 0; i < ticks; i++) {
      final x = left + i * tickStep;
      canvas.drawLine(Offset(x, bottom), Offset(x, bottom + 6), tickPaint);
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: '37 min',
        style: TextStyle(color: Colors.white70, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(0, lineY - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    final paints = [
      Paint()..color = const Color(0xFF8B8CA0),
      Paint()..color = const Color(0xFFA1A2B8),
      Paint()..color = const Color(0xFF9A9BAB),
      Paint()..color = const Color(0xFF7F798C),
    ];

    final slices = [37.0, 26.0, 18.0, 19.0];
    final total = slices.reduce((a, b) => a + b);

    double startRadian = -pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i] / total) * 2 * pi;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startRadian, sweep, true, paints[i]);
      startRadian += sweep;
    }

    // рамка
    final border = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);

    // 💬 текстовые подписи внутри кругов
    final labels = ['Drama', 'Romance', 'Horror', 'Fantasy'];
    startRadian = -pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final sweep = (slices[i] / total) * 2 * pi;
      final mid = startRadian + sweep / 2;

      final labelPos = Offset(
        center.dx + (radius * 0.45) * cos(mid),
        center.dy + (radius * 0.45) * sin(mid),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
      );

      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
