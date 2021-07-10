import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';

import 'animation_state.dart';
import 'card_deck_animation.dart';

class CardDeck extends StatefulWidget {
  final ProgressBuilder builder;
  final SwipeCompletion? onSwipedLeft;
  final SwipeCompletion? onSwipedRight;
  final CardDeckAnimation animationStyle;
  final double? backBackMinOpacity;
  final SwipeDirection dismissDirection;
  final bool debug;
  final int count;

  CardDeck({
    Key? key,
    required this.builder,
    CardDeckAnimation? animationStyle,
    required this.count,
    this.onSwipedLeft,
    this.onSwipedRight,
    this.backBackMinOpacity,
    this.dismissDirection = SwipeDirection.left,
    this.debug = false,
  }) : this.animationStyle = animationStyle ?? CardDeckAnimation.stacked();

  @override
  _CardDeckState createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> with TickerProviderStateMixin {
  late AnimationState _animationState;

  // List<Widget> _cached = [];
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

  void _completeAnimations() {
    // _animationState.log();
    _finishingAnimationController =
        AnimationController(vsync: this, duration: _endAnimationDuration);

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
              _animationState.scrub(target: targetValue);
              // _animationState = _animationState.copyWith();
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed &&
                _animationState.targetDirection != 0) {
              setState(() {
                _animationState.complete();

                if (_animationState.targetDirection.isNegative) {
                  widget.onSwipedLeft?.call(_animationState.currentIndex);
                } else {
                  widget.onSwipedRight?.call(_animationState.currentIndex);
                }
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
        _animationState.reset();
      },
      onHorizontalDragCancel: () {},
      onHorizontalDragEnd: (details) {
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
    return Stack(
      children: [
        // Previous Card
        if (_animationState.currentIndex > 1)
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
        if (_animationState.currentIndex + 1 < widget.count)
          // Next card
          _buildNextCard(_animationState, context),
        // Visible Card
        _buildCurrentCard(_animationState, context),
        if (_animationState.config.reversible &&
            _animationState.currentIndex > 0)
          // Previous Card
          _buildPreviousCard(_animationState, context),
      ],
    );
  }

  Transform _buildPreviousCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        animator: widget.animationStyle.previousCardAnimation,
        offset: widget.animationStyle.visibleCardFractionOffset,
        index: _animationState.currentIndex - 1,
        tag: widget.debug ? 'Previous' : null);
  }

  Transform _buildCurrentCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        animator: widget.animationStyle.visibleCardAnimation,
        offset: widget.animationStyle.visibleCardFractionOffset,
        index: _animationState.currentIndex,
        tag: widget.debug ? 'Current' : null);
  }

  Transform _buildNextCard(AnimationState config, BuildContext context) {
    return _buildCard(
        state: config,
        context: context,
        animator: widget.animationStyle.nextCardAnimation,
        offset: widget.animationStyle.nextCardFractionOffset,
        index: _animationState.currentIndex + 1,
        tag: widget.debug ? 'Next' : null);
  }

  Transform _buildCard(
      {required AnimationState state,
      required BuildContext context,
      required CardDeckAnimator animator,
      required FractionalOffset offset,
      required int index,
      required String? tag}) {
    return Transform(
      alignment: offset,
      transform: animator(state.progress.copyWith()),
      child: Column(
        children: [
          if (tag != null) Text(tag),
          Expanded(child: widget.builder(index, 1, context)),
        ],
      ),
    );
  }
}
