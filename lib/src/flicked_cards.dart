import 'package:flicked_cards/src/base_types.dart';
import 'package:flutter/material.dart';

import 'animation_state.dart';
import 'card_animation.dart';

/// A gesture driven widget to animate cards
class FlickedCards extends StatefulWidget {
  final ProgressBuilder builder;
  final SwipeCompletion? onSwiped;
  final CardAnimation animationStyle;
  final bool debug;
  final int count;

  /// Main constructor
  /// [builder] a closure that builds a widget from a relative index and swipe progress
  /// [count] the total number of cards
  /// [animationStyle] the animation to be used
  const FlickedCards({
    Key? key,
    required this.builder,
    required this.count,
    required this.animationStyle,
    this.onSwiped,
    this.debug = false,
  }) : super(key: key);

  @override
  _FlickedCardsState createState() => _FlickedCardsState();
}

class _FlickedCardsState extends State<FlickedCards>
    with TickerProviderStateMixin {
  late AnimationState _animationState;
  bool _isDragging = false;
  bool _isAnimating = false;

  bool get isIddle => !(_isDragging || _isAnimating);

  final Map<int, Widget> _cached = {};
  AnimationController? _finishingAnimationController;
  Animation<double>? _finishingAnimation;

  static const _endAnimationDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    _animationState = AnimationState(
      cardCount: widget.count,
      config: widget.animationStyle.config,
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleDrag({required double width, required double delta}) {
    setState(() {
      _animationState.update(delta: delta);
    });
  }

  void _completeAnimations(double velocity) {
    // _animationState.log();
    final duration = _endAnimationDuration -
        (_endAnimationDuration * velocity.abs().clamp(0, 1));
    _finishingAnimationController =
        AnimationController(vsync: this, duration: duration);

    _finishingAnimation = Tween<double>(
            begin: _animationState.progress.value,
            end: _animationState.targetDirection)
        .animate(
      CurvedAnimation(
          parent: _finishingAnimationController!, curve: Curves.linear),
    )
          ..addListener(() {
            setState(() {
              final targetValue = _finishingAnimation?.value;
              if (targetValue == null) return;
              _isAnimating = true;
              _animationState.scrub(target: targetValue);
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _isAnimating = false;
            }
            if (status == AnimationStatus.completed &&
                _animationState.targetDirection != 0) {
              setState(() {
                _animationState.complete();

                widget.onSwiped?.call(
                  _animationState.currentIndex,
                  _animationState.targetDirection.isNegative
                      ? SwipeDirection.left
                      : SwipeDirection.right,
                );
                _animationState.reset();
                // _animationState = _animationState.copyWith();
              });
            }
          });

    _finishingAnimationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _animationState.configureWith(screenWidth: size.width);
    // _animationState.log();

    return GestureDetector(
      key: const Key('FlickedCardsGesture'),
      // behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        _handleDrag(width: size.width, delta: details.delta.dx);
      },
      onHorizontalDragStart: (details) {
        _isDragging = true;
        _animationState.reset();
      },
      onHorizontalDragCancel: () {},
      onHorizontalDragEnd: (details) {
        final velocityX = details.primaryVelocity;
        final normalizedVelocity = 0.1 * (velocityX ?? 0) / size.width;
        _isDragging = false;
        _completeAnimations(normalizedVelocity);
      },
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: _buildStack(context),
          ),
        ],
      ),
    );
  }

  Stack _buildStack(BuildContext context) {
    final indices = widget.animationStyle.layoutConfig
        .relativeIndicesForLayout(cardCount: widget.count)
        .reversed;
    final cards = indices
        .map((idx) => _buildCard(
              state: _animationState,
              context: context,
              relativeIndex: idx,
            ))
        .whereType<_AnimatableCard>()
        .map((e) => Positioned.fill(child: e))
        .toList();

    return Stack(
      children: cards,
    );
  }

  _AnimatableCard? _buildCard({
    required AnimationState state,
    required BuildContext context,
    required int relativeIndex,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final spec = widget.animationStyle;
    spec.screenSize = screenSize;

    final offset = spec.fractionalOffsetForCard(relativeIndex: relativeIndex);
    final transformation = spec.animationForCard(relativeIndex: relativeIndex);
    final opacity = spec.opacityForCard(relativeIndex: relativeIndex);
    final tag = widget.debug ? '$relativeIndex' : null;

    final index = state.currentIndex + relativeIndex;

    if (index < 0 || index >= widget.count) return null;

    final cardProgress = state.cardProgress(relativeIndex: relativeIndex);

    final card = widget.builder(index, cardProgress, context);

    if (relativeIndex == 0) {
      _cached[index] = card;
    }

    return _AnimatableCard(
      animation: transformation(state.progress.value),
      offset: offset,
      tag: tag,
      opacity: opacity(state.progress.value),
      child: card,
    );
  }
}

class _AnimatableCard extends StatelessWidget {
  final Matrix4 animation;
  final FractionalOffset offset;
  final String? tag;
  final double opacity;
  final Widget child;

  const _AnimatableCard({
    Key? key,
    required this.animation,
    required this.offset,
    required this.child,
    required this.opacity,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tag != null) {
      return Transform(
        alignment: offset,
        transform: animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tag != null) Text(tag!, textAlign: TextAlign.center),
            Expanded(
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          ],
        ),
      );
    }
    return Transform(
      alignment: offset,
      transform: animation,
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }
}
