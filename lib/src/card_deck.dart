import 'dart:math';

import 'package:flutter/material.dart';

part './stacked_animation.dart';
part './carousel_animation.dart';

typedef ProgressBuilder = Widget Function(int, double, BuildContext);
typedef SwipeCompletion = void Function(int);
enum SwipeDirection { left, right }

extension SwipeDirectionValue on SwipeDirection {
  double get value {
    switch (this) {
      case (SwipeDirection.left):
        return -1;
      case (SwipeDirection.right):
        return 1;
      default:
        return 0;
    }
  }

  bool get isLeft => this == SwipeDirection.left;
  bool get isRight => this == SwipeDirection.right;
}

class CardDeck extends StatefulWidget {
  final ProgressBuilder builder;
  final SwipeCompletion? onSwipedLeft;
  final SwipeCompletion? onSwipedRight;
  final CardDeckAnimation animationStyle;
  final double? backBackMinOpacity;
  final SwipeDirection dismissDirection;
  final bool asStack;

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
    this.asStack = false,
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
            child: widget.asStack ? _cardStack(context) : _cardQueue(context),
          ),
        ],
      ),
    );
  }

  Stack _cardStack(BuildContext context) {
    final reversing = movingDirection != widget.dismissDirection &&
        widget.reversible &&
        movingDirection != null;

    final config = AnimationConfig(
        asStack: widget.asStack,
        dismissDirection: widget.dismissDirection,
        reversible: widget.reversible,
        reversing: reversing,
        signedProgress: _signedProgress);

    return Stack(
      children: [
        // Previous Card
        if (_currentIndex - 1 > 0)
          Transform(
            alignment: widget.animationStyle.visibleCardFractionOffset,
            transform:
                widget.animationStyle.previousCardAnimation(config.copyWith()),
            child: Column(children: [
              Text('Previous'),
              Expanded(child: widget.builder(_currentIndex - 1, 1, context)),
            ]),
          ),
        if (_currentIndex < widget.count)
          // Current Card
          Transform(
            alignment: widget.animationStyle.visibleCardFractionOffset,
            transform: widget.animationStyle.visibleCardAnimation(config),
            child: Column(children: [
              Text('Current'),
              Expanded(
                  child: widget.builder(
                      _currentIndex, _signedProgress.abs(), context)),
            ]),
          ),
        if (_currentIndex + 1 < widget.count)
          // Next Card
          Transform(
            alignment: widget.animationStyle.nextCardFractionOffset,
            transform:
                widget.animationStyle.nextCardAnimation(config.copyWith()),
            child: Column(
              children: [
                Text('Next'),
                Expanded(
                    child: widget.builder(
                        _currentIndex + 1, _invertedProgress, context)),
              ],
            ),
          ),
      ],
    );
  }

  void _buildCache(AnimationConfig config, BuildContext context) {
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

  Stack _cardQueue(BuildContext context) {
    final reversing = movingDirection != widget.dismissDirection &&
        widget.reversible &&
        movingDirection != null;

    final config = AnimationConfig(
        asStack: widget.asStack,
        dismissDirection: widget.dismissDirection,
        reversible: widget.reversible,
        reversing: reversing,
        signedProgress: _signedProgress);

    return Stack(
      children: [
        if (_currentIndex + 1 < widget.count)
          // Next card
          Transform(
            transform:
                widget.animationStyle.nextCardAnimation(config.copyWith()),
            alignment: widget.animationStyle.nextCardFractionOffset,
            child: Opacity(
                opacity:
                    (_signedProgress.abs() + (widget.backBackMinOpacity ?? 1))
                        .clamp(0, 1),
                child: widget.builder(
                    _currentIndex + 1, _signedProgress.abs(), context)),
          ),
        // Visible Card
        Transform(
          alignment: widget.animationStyle.visibleCardFractionOffset,
          transform:
              widget.animationStyle.visibleCardAnimation(config.copyWith()),
          child: widget.builder(_currentIndex, 1, context),
        ),
        if (widget.reversible && _currentIndex > 0)
          // Previous Card
          Transform(
            alignment: widget.animationStyle.visibleCardFractionOffset,
            transform: widget.animationStyle.previousCardAnimation(config),
            child:
                widget.builder(_currentIndex - 1, _invertedProgress, context),
          ),
      ],
    );
  }
}

class AnimationConfig {
  final SwipeDirection dismissDirection;
  final bool reversible;
  final bool reversing;
  final bool asStack;
  double signedProgress = 0;

  AnimationConfig(
      {required this.dismissDirection,
      required this.reversible,
      required this.reversing,
      required this.asStack,
      required this.signedProgress});

  double get invertedProgress =>
      dismissDirection.value - signedProgress.abs() * -1;
  double get visibleCardProgress => reversing ? 0 : signedProgress;
  double get reversedCardProgress =>
      reversing ? invertedProgress : dismissDirection.value;

  AnimationConfig offsetBy(double offset) {
    return copyWith(signedProgress: signedProgress + offset);
  }

  AnimationConfig scaledBy(double offset) {
    return copyWith(signedProgress: signedProgress * offset);
  }

  AnimationConfig freezedWhenReversed() {
    return copyWith(signedProgress: reversing ? 0 : signedProgress);
  }

  AnimationConfig copyWith({double? signedProgress}) {
    return AnimationConfig(
        asStack: asStack,
        dismissDirection: dismissDirection,
        reversible: reversible,
        reversing: reversing,
        signedProgress: signedProgress ?? this.signedProgress);
  }

  void log() {
    print('% $signedProgress');
  }

  AnimationConfig mappedBy({required double outMin, required double outMax}) {
    final newProgress = MapRange.withIntervals(
            inMin: -1, inMax: 1, outMin: outMin, outMax: outMax)
        .call(signedProgress)
        .toDouble();
    return copyWith(signedProgress: newProgress);
  }

  AnimationConfig modifiedBy(double Function(double) expression) {
    return copyWith(signedProgress: expression(signedProgress));
  }

  AnimationConfig clamped({required double outMin, required double outMax}) {
    return copyWith(signedProgress: signedProgress.clamp(outMin, outMax));
  }
}

typedef CardDeckAnimator = Matrix4 Function(AnimationConfig);

abstract class CardDeckAnimation {
  FractionalOffset get visibleCardFractionOffset =>
      FractionalOffset.bottomCenter;

  FractionalOffset get nextCardFractionOffset => FractionalOffset.bottomCenter;

  CardDeckAnimator get visibleCardAnimation;

  CardDeckAnimator get nextCardAnimation;

  CardDeckAnimator get previousCardAnimation;

  static CardDeckAnimation stacked() => CardDeckStackedAnimation();
  static CardDeckAnimation carousel() => CardDeckCarouselAnimation();
}

typedef RangeMapper = num Function(num);

extension MapRange on num {
  static RangeMapper withIntervals(
      {required num inMin,
      required num inMax,
      required num outMin,
      required num outMax}) {
    return (num value) =>
        (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
}
