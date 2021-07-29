import 'package:flicked_cards/flicked_cards.dart';
import 'package:flicked_cards/src/animation_config.dart';
import 'package:flutter/material.dart';

class TestStackAnimation extends AsymmetricCardAnimation {
  AnimationConfig config = AnimationConfig();
  LayoutConfig layoutConfig = LayoutConfig();
  TestStackAnimation();

  @override
  SwipeAnimation get dismissAnimation {
    return (progress) {
      final offset = -300 * .5;
      final x = offset * progress;
      return Matrix4.identity()..translate(x, 0);
    };
  }

  @override
  SwipeAnimation revealAnimation({required int relativeIndex}) {
    return (progress) {
      final offset = -50;

      if (progress == config.dismissDirection.value) {
        return Matrix4.identity()
          ..translate(0.0, offset * relativeIndex.toDouble());
      }

      final y = progress * offset + relativeIndex.toDouble() * offset;
      return Matrix4.identity()..translate(0.0, y);
    };
  }
}
