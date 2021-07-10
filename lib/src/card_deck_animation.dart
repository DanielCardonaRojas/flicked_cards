import 'dart:math';

import 'package:flickered_cards/src/base_types.dart';
import 'package:flutter/material.dart';
import 'animation_state.dart';

part './animations/stacked_animation.dart';
part './animations/carousel_animation.dart';

typedef CardDeckAnimator = Matrix4 Function(AnimationProgress);

abstract class CardDeckAnimation {
  late AnimationState state;

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

  /// Is this animatable to bring back swiped cards ?
  bool get canReverse => true;

  static CardDeckAnimation stacked({bool inverted = false}) =>
      CardDeckStackedAnimation(inverted: inverted);
  static CardDeckAnimation carousel({double? cardSpacing}) =>
      CardDeckCarouselAnimation(cardSpacing: cardSpacing ?? 320);
}
