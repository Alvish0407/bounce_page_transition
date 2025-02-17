import 'dart:developer';

import 'package:flutter/material.dart';

class BouncePageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final bouncyChild = BouncePageEffect(child: child);

    final targetPlatform = Theme.of(context).platform;
    final targetPlatformTransitionBuilder = switch (targetPlatform) {
      TargetPlatform.android || TargetPlatform.fuchsia => FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux || TargetPlatform.windows => ZoomPageTransitionsBuilder(),
    };

    final bouncePageTransitionBuilder = targetPlatformTransitionBuilder //
        .buildTransitions(route, context, animation, secondaryAnimation, bouncyChild);

    return bouncePageTransitionBuilder;
  }
}

class BouncePageEffect extends StatefulWidget {
  const BouncePageEffect({super.key, required this.child});

  final Widget child;

  @override
  State<BouncePageEffect> createState() => _BouncePageEffectState();
}

class _BouncePageEffectState extends State<BouncePageEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Durations.short4,
      reverseDuration: Durations.short4,
    );
    _animation = Tween(end: 0.98, begin: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        reverseCurve: Curves.ease, //
        curve: Curves.fastOutSlowIn,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void onTap() {
    if (_controller.isAnimating) _controller.reset();

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      child: ScaleTransition(scale: _animation, child: widget.child),
      onTapInside: (_) {
        log('BouncePageTransition: onTap');
        onTap();
      },
      onTapUpInside: (_) {
        log('BouncePageTransition: onTapUpInside');
      },
    );
  }
}
