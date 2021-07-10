part of '../card_deck_animation.dart';

class CardDeckCarouselAnimation extends CardDeckAnimation {
  final double cardSpacing;

  CardDeckCarouselAnimation({
    this.cardSpacing = 300,
  });

  // @override
  // void configure(bool reversing, double signedProgress) {
  //   if (!reversible)
  //     throw '''
  //   CardDeckCarouselAnimation can only be used in reversible CardDeck
  //   please set reversible to true
  //   ''';

  //   super.configure(reversing, signedProgress);
  // }

  @override
  CardDeckAnimator get nextCardAnimation {
    return (progress) => _baseAnimation(progress.computedWith(
        (p) => p.offsetBy(state.config.dismissDirection.value * -1)));
  }

  @override
  CardDeckAnimator get previousCardAnimation {
    return (progress) => _baseAnimation(progress
        .computedWith((p) => p.offsetBy(state.config.dismissDirection.value)));
  }

  @override
  CardDeckAnimator get visibleCardAnimation {
    return (state) => _baseAnimation(state);
  }

  Matrix4 _baseAnimation(AnimationProgress state) {
    return Matrix4.identity()..translate(cardSpacing * state.computed);
  }
}
