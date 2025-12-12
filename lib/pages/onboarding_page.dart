import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Sample Tracking',
      description: 'Track your lab samples from collection to results with ease',
      animation: 'assets/animations/sample-tracking.json',
    ),
    OnboardingItem(
      title: 'Real-time Notifications',
      description: 'Get notified when sample results are ready or need attention',
      animation: 'assets/animations/notifications.json',
    ),
    OnboardingItem(
      title: 'Analytics & Reports',
      description: 'Generate detailed reports and analyze lab performance',
      animation: 'assets/animations/analytics.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _markOnboardingComplete() async {
    // During development, we're not permanently marking onboarding as complete
    // This is just a temporary navigation without saving state
    
    // Comment out the permanent storage during development
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('has_logged_in_before', true);
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingItemWidget(item: _items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == _items.length - 1 ? 180 : 60,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: _currentPage == _items.length - 1 ? 8 : 2,
                        backgroundColor: _currentPage == _items.length - 1 
                            ? Theme.of(context).primaryColor 
                            : null,
                        foregroundColor: _currentPage == _items.length - 1
                            ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.black87 // Dark text on light button for dark mode
                                : Colors.white   // Light text on dark button for light mode
                            : null,
                      ),
                      onPressed: () {
                        if (_currentPage < _items.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _markOnboardingComplete();
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: _currentPage == _items.length - 1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Get Started',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black87  // Dark text for dark mode
                                          : Colors.white,   // Light text for light mode
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.rocket_launch,
                                  size: 18,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black87  // Dark icon for dark mode
                                      : Colors.white,   // Light icon for light mode
                                ),
                              ],
                            )
                          : const Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String animation;
  
  OnboardingItem({
    required this.title,
    required this.description,
    required this.animation,
  });
}

class OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item;
  
  const OnboardingItemWidget({
    super.key,
    required this.item,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            item.animation,
            height: 300,
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 