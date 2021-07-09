import 'dart:math';

import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';

import 'card_deck_animation.dart';

class CardDeck extends StatefulWidget {
  final ProgressBuilder builder;
  final SwipeCompletion? onSwipedLeft;
  final SwipeCompletion? onSwipedRight;
  final CardDeckAnimation animationStyle;
  final double? backBackMinOpacity;
  final SwipeDirection dismissDirection;
  final bool debug;

  bool reversible;
  bool allowsBothDirections;

  final int count;

  CardDeck({
    Key? key,
    required this.builder,
    CardDeckAnimation? animationStyle,
    required this.count,
    this.onSwipedLeft,
    this.onSwipedRight,
    this.reversible = true,
    this.backBackMinOpacity,
    this.dismissDirection = SwipeDirection.left,
    this.allowsBothDirections = true,
    this.debug = false,
  })  : this.animationStyle = animationStyle ?? CardDeckAnimation.stacked(),
        super(key: key) {
    if (reversible) {
      this.allowsBothDirections = true;
    } else if (!allowsBothDirections) {
      this.reversible = true;
    }
  }

  @override
  _CardDeckState createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> with TickerProviderStateMixin {
  int _currentIndex = 0;
  double _positionX = 0;
  double _signedProgress = 0; // Ranges from -1 to 1
  List<Widget> _cached = [];
  AnimationController? _finishingAnimationController;
  Animation<double>? _finishingAnimation;

  static const _endAnimationDuration = Duration(milliseconds: 500);
  static const _progressThreshold = 0.25;

  SwipeDirection? get movingDirection {
    if (_signedProgress < 0.0) return SwipeDirection.left;
    if (_signedProgress > 0.0) return SwipeDirection.right;
    return null;
  }

  double get _target {
    final double target = _signedProgress.isNegative ? -1 : 1;
    final advances = target * widget.dismissDirection.value == 1;
    final targetIndex = _currentIndex + target * widget.dismissDirection.value;

    if (_signedProgress.abs() < _progressThreshold) return 0.0;
    if (targetIndex > widget.count - 1) return 0.0;
    if (!advances && _currentIndex == 0) return 0.0;
    return target;
  }

  int get _targetIndex {
    if (widget.reversible) {
      return (_currentIndex + _target.sign * widget.dismissDirection.value)
          .clamp(0, widget.count - 1)
          .toInt();
    }

    return (_currentIndex + 1).clamp(0, widget.count).toInt();
  }

  double get _invertedProgress => 1 - _signedProgress.abs();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _scrub({required double width, required double delta}) {
    setState(() {
      _positionX += delta;
      final centeredX = _positionX / width;
      _signedProgress =
          ((centeredX - 0.5) * 2).clamp(-1.0, 1.0); // Convert to range -1, 1
    });
  }

  void _completeAnimations() {
    _finishingAnimationController =
        AnimationController(vsync: this, duration: _endAnimationDuration);

    _finishingAnimation =
        Tween<double>(begin: _signedProgress, end: _target).animate(
      CurvedAnimation(
          parent: _finishingAnimationController!, curve: Curves.linear),
    )
          ..addListener(() {
            setState(() {
              _signedProgress = _finishingAnimation?.value ?? _signedProgress;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _target != 0) {
              setState(() {
                _currentIndex = _targetIndex;
                if (_target.isNegative) {
                  widget.onSwipedLeft?.call(_currentIndex);
                } else {
                  widget.onSwipedRight?.call(_currentIndex);
                }
                _signedProgress = 0;
              });
            }
          });

    _finishingAnimationController?.forward();
  }

  void _buildCache(AnimationState config, BuildContext context) {
    if (_currentIndex > 1) {
      _cached = List.generate(_currentIndex - 2, (index) {
        // final progressIncrement = 1 / _currentIndex * index.toDouble();
        final progressIncrement =
            1 / widget.count.toDouble() * index.toDouble();
        return Transform(
          alignment: widget.animationStyle.visibleCardFractionOffset,
          transform: widget.animationStyle.nextCardAnimation(config),
          child: widget.builder(index, 1, context),
        );
      });
    }
    print('>>> Cached length ${_cached.length}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      // behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        final advances =
            (details.delta.dx * widget.dismissDirection.value.sign) > 0 ||
                !widget.reversible;
        if (!widget.allowsBothDirections && !advances) return;
        if (advances && _currentIndex == widget.count - 1) return;

        _scrub(width: size.width, delta: details.delta.dx);
      },
      onHorizontalDragStart: (details) {
        _positionX = size.width * .5;
      },
      onHorizontalDragCancel: () {},
      onHorizontalDragEnd: (details) {
        print('target: $_target targetIndex: $_targetIndex');
        _completeAnimations();
      },
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: widget.animationStyle.usesInvertedLayout
                ? _cardStack(context)
                : _cardQueue(context),
          ),
        ],
      ),
    );
  }

  Stack _cardStack(BuildContext context) {
    final reversing = movingDirection != widget.dismissDirection &&
        widget.reversible &&
        movingDirection != null;

    final config = AnimationState(
        dismissDirection: widget.dismissDirection,
        reversible: widget.reversible,
        reversing: reversing,
        signedProgress: _signedProgress);

    return Stack(
      children: [
        // Previous Card
        if (_currentIndex > 1) _buildPreviousCard(config, context),
        if (_currentIndex < widget.count)
          // Current Card
          _buildCurrentCard(config, context),
        if (_currentIndex + 1 < widget.count)
          // Next Card
          _buildNextCard(config, context),
      ],
    );
  }

  Stack _cardQueue(BuildContext context) {
    final reversing = movingDirection != widget.dismissDirection &&
        widget.reversible &&
        movingDirection != null;

    final config = AnimationState(
        dismissDirection: widget.dismissDirection,
        reversible: widget.reversible,
        reversing: reversing,
        signedProgress: _signedProgress);

    return Stack(
      children: [
        if (_currentIndex + 1 < widget.count)
          // Next card
          _buildNextCard(config, context),
        // Visible Card
        _buildCurrentCard(config, context),
        if (widget.reversible && _currentIndex > 0)
          // Previous Card
          _buildPreviousCard(config, context),
      ],
    );
  }

  Transform _buildPreviousCard(AnimationState config, BuildContext context) {
    return _buildCard(
        config: config,
        context: context,
        animator: widget.animationStyle.previousCardAnimation,
        offset: widget.animationStyle.visibleCardFractionOffset,
        index: _currentIndex - 1,
        tag: widget.debug ? 'Previous' : null);
  }

  Transform _buildCurrentCard(AnimationState config, BuildContext context) {
    return _buildCard(
        config: config,
        context: context,
        animator: widget.animationStyle.visibleCardAnimation,
        offset: widget.animationStyle.visibleCardFractionOffset,
        index: _currentIndex,
        tag: widget.debug ? 'Current' : null);
  }

  Transform _buildNextCard(AnimationState config, BuildContext context) {
    return _buildCard(
        config: config,
        context: context,
        animator: widget.animationStyle.nextCardAnimation,
        offset: widget.animationStyle.nextCardFractionOffset,
        index: _currentIndex + 1,
        tag: widget.debug ? 'Next' : null);
  }

  Transform _buildCard(
      {required AnimationState config,
      required BuildContext context,
      required CardDeckAnimator animator,
      required FractionalOffset offset,
      required int index,
      required String? tag}) {
    return Transform(
      alignment: offset,
      transform: animator(config.copyWith()),
      child: Column(
        children: [
          if (tag != null) Text(tag),
          Expanded(child: widget.builder(index, _invertedProgress, context)),
        ],
      ),
    );
  }
}
