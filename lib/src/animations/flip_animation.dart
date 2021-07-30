part of '../card_animation.dart';

class FlipAnimation extends CardAnimation {
  FlipAnimation();

  @override
  SwipeAnimation animationForCard({required int relativeIndex}) {
    final next = relativeIndex != 0.0 ? 1.0 : 0.0;
    return (progress) => Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(pi * -1 * progress + next * pi);
  }

  @override
  OpacityAnimation opacityForCard({required int relativeIndex}) {
    return (progress) {
      if (relativeIndex == 0) {
        return progress.abs() < 0.5 ? 1.0 : 0.0;
      } else if (relativeIndex == 1) {
        return progress.abs() > 0.5 ? 1.0 : 0.0;
      }

      return 1;
    };
  }

  @override
  FractionalOffset fractionalOffsetForCard({required int relativeIndex}) =>
      FractionalOffset.center;

  @override
  LayoutConfig get layoutConfig => LayoutConfig(cardsBefore: 0);
}
