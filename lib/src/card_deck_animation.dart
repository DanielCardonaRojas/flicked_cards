import 'dart:math';

import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

part './animations/stacked_animation.dart';
part './animations/carousel_animation.dart';

typedef CardDeckAnimator = Matrix4 Function(AnimationState);

abstract class CardDeckAnimation {
  FractionalOffset get visibleCardFractionOffset =>
      FractionalOffset.bottomCenter;

  FractionalOffset get nextCardFractionOffset => FractionalOffset.bottomCenter;

  CardDeckAnimator get visibleCardAnimation;

  CardDeckAnimator get nextCardAnimation;

  CardDeckAnimator get previousCardAnimation;

  /// Animations can opt in to support 2 types of animations the either incrementally pile or removes from a pile
  /// When false cards are layed out inside a Stack widget like this: [Previous, Current, Next]
  /// otherwise will be stack in the following manner: [Next, Current, Previous]
  /// Also note that for the index 0 Previous will not be shown.
  bool get usesInvertedLayout => false;

  static CardDeckAnimation stacked({bool inverted = false}) =>
      CardDeckStackedAnimation(inverted: inverted);
  static CardDeckAnimation carousel({double? cardSpacing}) =>
      CardDeckCarouselAnimation(cardSpacing: cardSpacing ?? 320);
}

class AnimationState {
  final SwipeDirection dismissDirection;
  final bool reversible;
  final bool reversing;
  double signedProgress = 0;

  AnimationState(
      {required this.dismissDirection,
      required this.reversible,
      required this.reversing,
      required this.signedProgress});

  double get invertedProgress =>
      dismissDirection.value - signedProgress.abs() * -1;
  double get visibleCardProgress => reversing ? 0 : signedProgress;
  double get reversedCardProgress =>
      reversing ? invertedProgress : dismissDirection.value;

  AnimationState offsetBy(double offset) {
    return copyWith(signedProgress: signedProgress + offset);
  }

  AnimationState scaledBy(double offset) {
    return copyWith(signedProgress: signedProgress * offset);
  }

  AnimationState freezedWhenReversed() {
    return copyWith(signedProgress: reversing ? 0 : signedProgress);
  }

  AnimationState copyWith({double? signedProgress}) {
    return AnimationState(
        dismissDirection: dismissDirection,
        reversible: reversible,
        reversing: reversing,
        signedProgress: signedProgress ?? this.signedProgress);
  }

  void log() {
    print('% $signedProgress');
  }

  AnimationState mappedBy({required double outMin, required double outMax}) {
    final newProgress = MapRange.withIntervals(
            inMin: -1, inMax: 1, outMin: outMin, outMax: outMax)
        .call(signedProgress)
        .toDouble();
    return copyWith(signedProgress: newProgress);
  }

  AnimationState modifiedBy(double Function(double) expression) {
    return copyWith(signedProgress: expression(signedProgress));
  }

  AnimationState clamped({required double outMin, required double outMax}) {
    return copyWith(signedProgress: signedProgress.clamp(outMin, outMax));
  }
}
