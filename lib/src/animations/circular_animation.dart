part of '../card_animation.dart';

class RollAnimation extends AsymmetricCardAnimation {
  RollAnimation();

  @override
  SwipeAnimation get dismissAnimation {
    return (progress) => Matrix4.identity()
      ..translate(800 * progress, progress.abs() * -200)
      ..rotateZ(pi * 0.5 * progress);
  }

  @override
  SwipeAnimation revealAnimation({required int relativeIndex}) {
    return (_) => Matrix4.identity();
  }

  @override
  AnimationConfig get config => AnimationConfig();

  @override
  LayoutConfig get layoutConfig => LayoutConfig(cardsBefore: 0);
}
