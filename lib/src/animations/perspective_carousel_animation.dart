part of '../card_animation.dart';

class PerspectiveCarouselAnimation extends SymmetricCardAnimation {
  final double cardSpacingWidthFactor;

  PerspectiveCarouselAnimation({this.cardSpacingWidthFactor = 1.0});

  @override
  AnimationConfig get config =>
      AnimationConfig(reversible: true, dismissDirection: SwipeDirection.right);

  @override
  FractionalOffset fractionalOffsetForCard({required int relativeIndex}) =>
      FractionalOffset.center;

  @override
  SwipeAnimation get revealAnimation {
    return (progress) {
      final scaling = 1 - progress.abs() * 0.3;
      final translation =
          cardSpacingWidthFactor * (screenSize?.width ?? 500) * progress;

      return Matrix4.identity()
        ..scale(scaling, scaling)
        ..translate(translation, 0, 1 - progress.abs() * 100)
        ..setEntry(3, 2, 0.001)
        ..rotateY(pi * 0.4 * progress);
    };
  }
}
