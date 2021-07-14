import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';

import 'animation_state.dart';
import 'card_animation.dart';

class FlickeredCards extends StatefulWidget {
  final ProgressBuilder builder;
  final SwipeCompletion? onSwiped;
  final CardAnimation animationStyle;
  final SwipeDirection dismissDirection;
  final bool debug;
  final int count;

  FlickeredCards({
    Key? key,
    required this.builder,
    CardAnimation? animationStyle,
    required this.count,
    this.onSwiped,
    this.dismissDirection = SwipeDirection.left,
    this.debug = false,
  }) : this.animationStyle = animationStyle ?? DeckAnimation();

  @override
  _FlickeredCardsState createState() => _FlickeredCardsState();
}

class _FlickeredCardsState extends State<FlickeredCards>
    with TickerProviderStateMixin {
  late AnimationState _animationState;
  bool _isDragging = false;
  bool _isAnimating = false;

  bool get isIddle => !(_isDragging || _isAnimating);

  Map<int, Widget> _cached = {};
  AnimationController? _finishingAnimationController;
  Animation<double>? _finishingAnimation;

  static const _endAnimationDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    _animationState = AnimationState(
      config: AnimationConfig(
        cardCount: widget.count,
        dismissDirection: widget.dismissDirection,
      ),
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
              // _animationState = _animationState.copyWith();
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
    _animationState.config.reversible = widget.animationStyle.canReverse;
    widget.animationStyle.state = _animationState;
    // _animationState.log();

    return GestureDetector(
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
        print('Velocity $normalizedVelocity');
        _isDragging = false;
        _completeAnimations(normalizedVelocity);
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
    return Stack(
      children: [
        // Previous Card
        if (_animationState.currentIndex > 0)
          _buildPreviousCard(_animationState, context),
        if (_animationState.currentIndex < widget.count)
          // Current Card
          _buildCurrentCard(_animationState, context),
        if (_animationState.currentIndex + 1 < widget.count)
          // Next Card
          _buildNextCard(_animationState, context),
      ],
    );
  }

  Stack _cardQueue(BuildContext context) {
    return Stack(
      children: [
        ..._buildCardsAfterNext(context),
        if (_animationState.currentIndex + 1 < widget.count)
          // Next card
          _buildNextCard(_animationState, context),
        // Visible Card
        _buildCurrentCard(_animationState, context),
        if (_animationState.config.reversible &&
            _animationState.currentIndex > 0)
          // Previous Card
          _buildPreviousCard(_animationState, context),
        ..._buildCardsBeforePrevious(context),
      ],
    );
  }

  List<Widget> _buildCardsBeforePrevious(BuildContext context) {
    final count = widget.animationStyle.cardsBeforePrevious;

    final extraBefore = List.generate(count, (index) {
      final relativeIndex = -(index + 1);
      final cardIndex = _animationState.currentIndex + relativeIndex;
      if (cardIndex < 0 || cardIndex >= widget.count) return null;

      final cardBeforePrevious =
          _cached[cardIndex] ?? widget.builder(cardIndex, 1, context);

      final offset = widget.animationStyle
          .fractionalOffsetForCard(relativeIndex: relativeIndex);

      final transformation =
          widget.animationStyle.animationForCard(relativeIndex: relativeIndex);

      return Transform(
        alignment: offset,
        transform: transformation(_animationState.progress.value),
        child: Column(
          children: [
            Text('Extra'),
            Expanded(child: cardBeforePrevious),
          ],
        ),
      );
    }).whereType<Widget>().toList();

    return extraBefore;
  }

  List<Widget> _buildCardsAfterNext(BuildContext context) {
    final count = widget.animationStyle.cardsAfterNext;

    final extraAfter = List.generate(count, (index) {
      final relativeIndex = count - index + 1;
      final cardIndex = _animationState.currentIndex + relativeIndex;
      if (cardIndex < 0 || cardIndex >= widget.count) return null;

      final cardAfterNext =
          _cached[cardIndex] ?? widget.builder(cardIndex, 1, context);

      final offset = widget.animationStyle
          .fractionalOffsetForCard(relativeIndex: relativeIndex);

      final transformation =
          widget.animationStyle.animationForCard(relativeIndex: relativeIndex);

      return Transform(
        alignment: offset,
        transform: transformation(_animationState.progress.value),
        child: Column(
          children: [
            Text('Extra'),
            Expanded(child: cardAfterNext),
          ],
        ),
      );
    }).whereType<Widget>().toList();

    return extraAfter;
  }

  Transform _buildPreviousCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        relativeIndex: -1,
        tag: widget.debug ? 'Previous' : null);
  }

  Transform _buildCurrentCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        relativeIndex: 0,
        tag: widget.debug ? 'Current' : null);
  }

  Transform _buildNextCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        relativeIndex: 1,
        tag: widget.debug ? 'Next' : null);
  }

  Transform _buildCard(
      {required AnimationState state,
      required BuildContext context,
      required int relativeIndex,
      required String? tag}) {
    final spec = widget.animationStyle;
    final offset = spec.fractionalOffsetForCard(relativeIndex: relativeIndex);
    final transformation = spec.animationForCard(relativeIndex: relativeIndex);
    final opacity = spec.opacityForCard(relativeIndex: relativeIndex);

    final index = state.currentIndex + relativeIndex;
    final card = widget.builder(index, 1, context);

    if (relativeIndex == 0) {
      _cached[index] = card;
    }

    return Transform(
      alignment: offset,
      transform: transformation(state.progress.value),
      child: Column(
        children: [
          if (tag != null) Text(tag),
          Expanded(
            child: Opacity(
              opacity: opacity(state.progress.value),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatableCard extends StatelessWidget {
  final AnimationState state;
  final int relativeIndex;
  final Matrix4 animation;
  final FractionalOffset offset;
  final String? tag;
  final Widget child;

  const _AnimatableCard({
    Key? key,
    required this.state,
    required this.relativeIndex,
    required this.animation,
    required this.offset,
    required this.child,
    this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: offset,
      transform: animation,
      child: Column(
        children: [
          if (tag != null) Text(tag!),
          Expanded(
            child: Opacity(
              opacity: 1,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
