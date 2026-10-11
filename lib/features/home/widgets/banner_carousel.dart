import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BannerItem {
  final String title;
  final String discount;
  final String subtitle;
  final String assetImage;

  const BannerItem({
    required this.title,
    required this.discount,
    required this.subtitle,
    required this.assetImage,
  });
}

class BannerCarousel extends StatefulWidget {
  final VoidCallback? onBannerTap;

  const BannerCarousel({super.key, this.onBannerTap});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<BannerItem> _banners = const [
    BannerItem(
      subtitle: 'CHEF\'S SPECIAL',
      title: 'Experience our\ndelicious new dish',
      discount: '30% OFF',
      assetImage: 'assets/images/banner_1.jpg',
    ),
    BannerItem(
      subtitle: 'WEEKEND DEAL',
      title: 'Handcrafted Gourmet\nMeals & Drinks',
      discount: '25% OFF',
      assetImage: 'assets/images/banner_2.jpg',
    ),
    BannerItem(
      subtitle: 'LIMITED OFFER',
      title: 'Fresh, Crisp &\nTasty Asian Flavors',
      discount: '40% OFF',
      assetImage: 'assets/images/banner_3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full Image Banner Carousel
        SizedBox(
          height: 145.0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];

              return GestureDetector(
                onTap: widget.onBannerTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Whole image filling the entire banner card
                        Image.asset(
                          banner.assetImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF5B842),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // 2. Soft elegant vignette gradient for high contrast readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.50),
                                Colors.black.withValues(alpha: 0.25),
                                Colors.black.withValues(alpha: 0.05),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),

                        // 3. Text written directly on the image
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Promo pill tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  banner.subtitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6.0),

                              // Main headline
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4.0),

                              // Big discount text
                              Text(
                                banner.discount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10.0),

        // Indicator dots below
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              height: 5.5,
              width: isActive ? 18.0 : 6.0,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryOrange : const Color(0xFFF3DEC0),
                borderRadius: BorderRadius.circular(6.0),
              ),
            );
          }),
        ),
      ],
    );
  }
}
