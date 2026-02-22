
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageZoomPage extends StatefulWidget {
  final List<String> imageUrls; // multiple images
  final int initialIndex; // start from this index

  const ImageZoomPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageZoomPage> createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends State<ImageZoomPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (_, index) {
              final url = widget.imageUrls[index];
              return Center(
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          // Close button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Image index indicator
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "${_currentIndex + 1} / ${widget.imageUrls.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}