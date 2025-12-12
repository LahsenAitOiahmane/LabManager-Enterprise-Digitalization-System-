import 'package:flutter/material.dart';

/// A mixin that provides common animations for pages.
/// Use this with StatefulWidget states to add fade and slide animations.
mixin PageAnimationsMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  
  void initAnimations() {
    // Set up animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Fade in animation
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    
    // Slide up animation
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));
  }
  
  void disposeAnimations() {
    animationController.dispose();
  }
  
  /// Wrap a widget with fade and slide animations
  Widget animatedWidget({required Widget child}) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
  
  /// Start the animations
  void startAnimations() {
    animationController.forward();
  }
}

/// A widget that wraps its child with fade and slide animations.
/// Use this for simple widgets that don't need a StatefulWidget.
class AnimatedPageItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  
  const AnimatedPageItem({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });
  
  @override
  State<AnimatedPageItem> createState() => _AnimatedPageItemState();
}

class _AnimatedPageItemState extends State<AnimatedPageItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
} 