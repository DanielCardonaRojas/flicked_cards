part of '../card_animation.dart';

class CarouselAnimation extends SymmetricCardAnimation {
  final double cardSpacing;
  final SwipeDirection dismissDirection;

  CarouselAnimation({
    required this.dismissDirection,
    this.cardSpacing = 500,
  });
  @override
  AnimationConfig get config =>
      AnimationConfig(dismissDirection: dismissDirection, reversible: true);

  @override
  LayoutConfig get layoutConfig => LayoutConfig();

  @override
  SwipeAnimation get revealAnimation {
    return (progress) => Matrix4.identity()..translate(cardSpacing * progress);
  }
}
