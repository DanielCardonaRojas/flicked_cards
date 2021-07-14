import 'dart:math';

import 'package:flickered_cards/flickered_cards.dart';
import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';
import 'animation_state.dart';

part './animations/deck_animation.dart';
part './animations/carousel_animation.dart';
part './animations/circular_animation.dart';
part './animations/flip_animation.dart';

typedef SwipeAnimation = Matrix4 Function(double progress);
typedef OpacityAnimation = double Function(double progress);

abstract class CardAnimation {
  late AnimationState state;

  int get cardsAfterNext => 0;
  int get cardsBeforePrevious => 0;

  /// Animations can opt in to support 2 types of animations the either incrementally pile or removes from a pile
  /// When false cards are layed out inside a Stack widget like this: [Previous, Current, Next]
  /// otherwise will be stack in the following manner: [Next, Current, Previous]
  /// Also note that for the index 0 Previous will not be shown.
  bool usesInvertedLayout = false;

  /// Is this animatable to bring back swiped cards ?
  bool canReverse = true;

  SwipeAnimation animationForCard({required int relativeIndex});

  OpacityAnimation opacityForCard({required int relativeIndex}) {
    return (_) => 1;
  }

  FractionalOffset fractionalOffsetForCard({required int relativeIndex});

  static CardAnimation stacked() => DeckAnimation();
  static CardAnimation carousel() => CarouselAnimation();
}

/// Animation in which the dismissed and the next card have
/// different animations hence not symmetric.
abstract class AsymmetricCardAnimation extends CardAnimation {
  SwipeAnimation get dismissAnimation;
  SwipeAnimation revealAnimation({required int relativeIndex});

  @override
  FractionalOffset fractionalOffsetForCard({required int relativeIndex}) =>
      FractionalOffset.bottomCenter;

  @override
  SwipeAnimation animationForCard({required int relativeIndex}) {
    return usesInvertedLayout
        ? _stackingAnimationForCard(relativeIndex: relativeIndex)
        : _unstackingAnimationForCard(relativeIndex: relativeIndex);
  }

  SwipeAnimation _unstackingAnimationForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex > 0) {
        return revealAnimation(relativeIndex: relativeIndex).call(progress);
      } else if (relativeIndex < 0) {
        return dismissAnimation(progress + state.config.dismissDirection.value);
      } else if (relativeIndex == 0 && state.reversing) {
        return revealAnimation(relativeIndex: 0).call(progress);
      }
      return dismissAnimation(progress);
    };
  }

  SwipeAnimation _stackingAnimationForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex > 0) {
        return dismissAnimation
            .call(progress - state.config.dismissDirection.value);
      } else if (relativeIndex < 0) {
        return revealAnimation(relativeIndex: relativeIndex).call(progress);
      } else if (relativeIndex == 0 && state.reversing) {
        return dismissAnimation.call(progress);
      }
      return revealAnimation(relativeIndex: relativeIndex).call(progress);
    };
  }
}

/// Simple animation where the next and previous cards can be
/// animated with same dismissAnimation and applying an offset.
abstract class SymmetricCardAnimation extends CardAnimation {
  SwipeAnimation get revealAnimation;

  @override
  FractionalOffset fractionalOffsetForCard({required int relativeIndex}) =>
      FractionalOffset.bottomCenter;

  @override
  SwipeAnimation animationForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex > 0) {
        return revealAnimation
            .call(progress + state.config.dismissDirection.opposite.value);
      } else if (relativeIndex < 0) {
        return revealAnimation(progress + state.config.dismissDirection.value);
      }
      return revealAnimation(progress);
    };
  }
}
