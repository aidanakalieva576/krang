import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const Search({super.key, required this.onChanged});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // временные подсказки (потом заменишь на фильмы из БД)
  final List<String> _mockSuggestions = [
    "The Lego Movie",
    "The Boys",
    "Stranger Things",
    "Breaking Bad",
    "Interstellar",
    "The Matrix",
  ];

  List<String> _filtered = [];

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 42),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];

                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.white54),
                    title: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _controller.text = item;
                      widget.onChanged(item);
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onTextChanged(String text) {
    widget.onChanged(text);

    if (text.isEmpty) {
      _removeOverlay();
      return;
    }

    setState(() {
      _filtered = _mockSuggestions
          .where((s) => s.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });

    if (_filtered.isNotEmpty) {
      _showOverlay(context);
    } else {
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF343641),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            hintText: "Search movies, series, actors...",
            hintStyle: TextStyle(
              color: Color(0xFF52566C),
              fontSize: 13,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 40),
          ),
        ),
      ),
    );
  }
}
