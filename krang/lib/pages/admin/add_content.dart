import 'package:flutter/material.dart';

class AddScheduleModalPage extends StatefulWidget {
  const AddScheduleModalPage({super.key});

  @override
  State<AddScheduleModalPage> createState() => _AddScheduleModalPageState();
}

class _AddScheduleModalPageState extends State<AddScheduleModalPage> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  String? _afterValue;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _openEpisodesWindow() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xFFB9B9B9), // серый фон как на скрине
      builder: (_) => const _EpisodesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFB9B9B9);
    const panel = Color(0xFF0E0F10);
    const fieldGrey2 = Color(0xFF4E4E4E);
    const textGrey = Color(0xFFE9E9E9);
    const divider = Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 300,
            height: 560,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                  color: Colors.black45,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                children: [
                  // Upload area -> открывает окно выбора эпизода
                  GestureDetector(
                    onTap: _openEpisodesWindow,
                    child: Container(
                      height: 210,
                      decoration: BoxDecoration(
                        color: const Color(0xFF777777),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 6),
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.ios_share_rounded,
                          size: 54,
                          color: Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name:',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(height: 1, color: divider.withOpacity(0.8)),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Text(
                        'After:',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: fieldGrey2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.10),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _afterValue,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                              ),
                              dropdownColor: const Color(0xFF1A1B1C),
                              hint: const SizedBox.shrink(),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              items: const [
                                DropdownMenuItem(value: 'Option 1', child: Text('')),
                                DropdownMenuItem(value: 'Option 2', child: Text('')),
                                DropdownMenuItem(value: 'Option 3', child: Text('')),
                              ],
                              onChanged: (v) => setState(() => _afterValue = v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        'Duration:',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                        ),
                        child: TextField(
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'min',
                        style: TextStyle(
                          color: textGrey.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _RoundActionButton(
                        diameter: 42,
                        fill: Color(0xFF2E6D4B),
                        icon: Icons.check_rounded,
                        onTap: null,
                      ),
                      SizedBox(width: 18),
                      _RoundActionButton(
                        diameter: 42,
                        fill: Color(0xFF7A2E2E),
                        icon: Icons.close_rounded,
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodesDialog extends StatefulWidget {
  const _EpisodesDialog();

  @override
  State<_EpisodesDialog> createState() => _EpisodesDialogState();
}

class _EpisodesDialogState extends State<_EpisodesDialog> {
  final ScrollController _scroll = ScrollController();

  final List<_EpisodeItem> _items = List.generate(
    10,
        (i) => _EpisodeItem(title: 'Episode ${i + 1}'),
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const panel = Color(0xFF0E0F10);
    const card = Color(0xFF2B2B2B);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 500,
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: Offset(0, 10),
                    color: Colors.black45,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // plus icon
                  const Positioned(
                    left: 14,
                    top: 12,
                    child: Icon(Icons.add, color: Colors.white, size: 20),
                  ),

                  // list + scrollbar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 42, 10, 14),
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thickness: MaterialStateProperty.all(4),
                        radius: const Radius.circular(10),
                        thumbColor: MaterialStateProperty.all(
                          Colors.white.withOpacity(0.75),
                        ),
                      ),
                      child: Scrollbar(
                        controller: _scroll,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _scroll,
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final e = _items[index];
                            return Container(
                              height: 78,
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  // thumbnail (пока заглушка, но стиль как на скрине)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      color: const Color(0xFF111111),
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.white54,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      e.title,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // minus icon (как маленькая полоска)
                                  Container(
                                    width: 14,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // close button under panel
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 5),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.close, size: 16, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeItem {
  final String title;
  _EpisodeItem({required this.title});
}

class _RoundActionButton extends StatelessWidget {
  final double diameter;
  final Color fill;
  final IconData icon;

  /// для превью можешь оставить null — тогда кнопка просто выглядит, но не нажимается
  final VoidCallback? onTap;

  const _RoundActionButton({
    required this.diameter,
    required this.fill,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: diameter / 2,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Colors.black26),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}
