part of '../card_animation.dart';

class CarouselAnimation extends SymmetricCardAnimation {
  final double cardSpacing;

  CarouselAnimation({
    this.cardSpacing = 300,
  });

  @override
  SwipeAnimation get revealAnimation {
    return (progress) => Matrix4.identity()..translate(cardSpacing * progress);
  }
}
