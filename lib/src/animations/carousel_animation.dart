part of '../card_animation.dart';

class CardDeckCarouselAnimation extends SymmetricCardAnimation {
  final double cardSpacing;

  CardDeckCarouselAnimation({
    this.cardSpacing = 300,
  });

  @override
  SwipeAnimation get revealAnimation {
    return (progress) => Matrix4.identity()..translate(cardSpacing * progress);
  }
}
