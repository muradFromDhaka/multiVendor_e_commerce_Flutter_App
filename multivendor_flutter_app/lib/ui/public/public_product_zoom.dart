// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';

// class PublicProductZoomPage extends StatefulWidget {
//   final List<String> imageUrls; // multiple images
//   final int initialIndex; // start from this index

//   const PublicProductZoomPage({
//     super.key,
//     required this.imageUrls,
//     this.initialIndex = 0,
//   });

//   @override
//   State<PublicProductZoomPage> createState() => _PublicProductZoomPageState();
// }

// class _PublicProductZoomPageState extends State<PublicProductZoomPage> {
//   late PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: _currentIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: widget.imageUrls.length,
//             onPageChanged: (index) {
//               setState(() => _currentIndex = index);
//             },
//             itemBuilder: (_, index) {
//               final url = widget.imageUrls[index];
//               return Center(
//                 child: InteractiveViewer(
//                   maxScale: 5.0,
//                   child: CachedNetworkImage(
//                     imageUrl: url,
//                     placeholder: (context, url) => const CircularProgressIndicator(),
//                     errorWidget: (context, url, error) =>
//                         const Icon(Icons.error, color: Colors.white),
//                   ),
//                 ),
//               );
//             },
//           ),
//           // Close button
//           Positioned(
//             top: 40,
//             left: 16,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           // Image index indicator
//           if (widget.imageUrls.length > 1)
//             Positioned(
//               bottom: 40,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Text(
//                   "${_currentIndex + 1} / ${widget.imageUrls.length}",
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------------------------------

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PublicProductZoomPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const PublicProductZoomPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<PublicProductZoomPage> createState() => _PublicProductZoomPageState();
}

class _PublicProductZoomPageState extends State<PublicProductZoomPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isControlsVisible = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _startControlsTimer();
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isControlsVisible) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    if (_isControlsVisible) {
      _startControlsTimer();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main Image Viewer
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startControlsTimer();
              },
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                return Center(
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.8,
                    panEnabled: true,
                    scaleEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    onInteractionStart: (_) {
                      _controlsTimer?.cancel();
                    },
                    onInteractionEnd: (_) {
                      _startControlsTimer();
                    },
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Top Controls Bar
            FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isControlsVisible ? kToolbarHeight + 40 : 0,
                color: _isControlsVisible
                    ? Colors.black.withOpacity(0.5)
                    : Colors.transparent,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Close button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        // Image counter
                        if (widget.imageUrls.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_currentIndex + 1} / ${widget.imageUrls.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Share button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          onPressed: _shareImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Navigation arrows (for multiple images)
            if (widget.imageUrls.length > 1 && _isControlsVisible) ...[
              // Left arrow
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentIndex > 0 ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                    ),
                  ),
                ),
              ),

              // Right arrow
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentIndex < widget.imageUrls.length - 1
                        ? 1.0
                        : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: _currentIndex < widget.imageUrls.length - 1
                          ? _goToNext
                          : null,
                    ),
                  ),
                ),
              ),
            ],

            // Bottom thumbnails (for multiple images)
            if (widget.imageUrls.length > 1 && _isControlsVisible)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white54,
                                width: _currentIndex == index ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[900]),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Loading overlay for page transitions
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 0,
                duration: Duration.zero,
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareImage() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
