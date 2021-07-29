import 'dart:math';

import 'package:flicked_cards/flicked_cards.dart';
import 'package:flicked_cards/src/base_types.dart';
import 'package:flutter/material.dart';
import 'animation_config.dart';

part './animations/deck_animation.dart';
part './animations/carousel_animation.dart';
part './animations/circular_animation.dart';
part './animations/flip_animation.dart';

typedef SwipeAnimation = Matrix4 Function(double progress);
typedef OpacityAnimation = double Function(double progress);

abstract class CardAnimation {
  AnimationConfig get config;
  LayoutConfig get layoutConfig;

  SwipeAnimation animationForCard({required int relativeIndex});

  OpacityAnimation opacityForCard({required int relativeIndex}) {
    return (_) => 1;
  }

  FractionalOffset fractionalOffsetForCard({required int relativeIndex});
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
    return layoutConfig.usesInvertedLayout
        ? _stackingAnimationForCard(relativeIndex: relativeIndex)
        : _unstackingAnimationForCard(relativeIndex: relativeIndex);
  }

  SwipeAnimation _unstackingAnimationForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex > 0) {
        return revealAnimation(relativeIndex: relativeIndex).call(progress);
      } else if (relativeIndex < 0) {
        return dismissAnimation(progress + config.dismissDirection.value);
      } else if (relativeIndex == 0 && isReversing(progress)) {
        return revealAnimation(relativeIndex: 0).call(progress);
      }
      return dismissAnimation(progress);
    };
  }

  SwipeAnimation _stackingAnimationForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex > 0) {
        return dismissAnimation.call(progress - config.dismissDirection.value);
      } else if (relativeIndex < 0) {
        return revealAnimation(relativeIndex: relativeIndex).call(progress);
      } else if (relativeIndex == 0 && isReversing(progress)) {
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
            .call(progress + config.dismissDirection.opposite.value);
      } else if (relativeIndex < 0) {
        return revealAnimation(progress + config.dismissDirection.value);
      }
      return revealAnimation(progress);
    };
  }
}

extension CardAnimationX on CardAnimation {
  /// Calculate the moving direction
  SwipeDirection? movingDirection(double progress) {
    if (progress < 0.0) return SwipeDirection.left;
    if (progress > 0.0) return SwipeDirection.right;
    return null;
  }

  bool isReversing(double progress) {
    final dir = movingDirection(progress);
    return dir != config.dismissDirection && config.reversible && dir != null;
  }
}
