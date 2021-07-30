import 'superheroes/superheroes_example.dart';
import 'package:flicked_cards/flicked_cards.dart';
import 'shoes_store/shoe_store_example.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flickered Cards Demo'),
      ),
      body: Container(
          color: Colors.black12,
          child: Center(
            child: Column(
              children: [
                _buildExample(
                  context: context,
                  title: 'deck + reversible + swipe right',
                  animation: DeckAnimation(
                      dismissDirection: SwipeDirection.right, reversible: true),
                ),
                _buildExample(
                    context: context,
                    title: 'roll + non reversible',
                    animation: RollAnimation()),
                _buildExample(
                    context: context,
                    title: 'flip + non reversible',
                    animation: FlipAnimation()),
                _buildExample(
                    context: context,
                    title: 'unstacked deck + reversible + swipe left',
                    animation: DeckAnimation(
                        reversible: true,
                        usesInvertedLayout: true,
                        dismissDirection: SwipeDirection.left)),
                _buildExample(
                  context: context,
                  title: 'stacked deck + not reversible',
                  animation: DeckAnimation(
                      reversible: false, dismissDirection: SwipeDirection.left),
                ),
                _buildExample(
                    context: context,
                    title: 'carousel + swipe left',
                    animation: CarouselAnimation(
                        dismissDirection: SwipeDirection.left)),
                _buildExample(
                    context: context,
                    title: 'carousel + swipe right',
                    animation: CarouselAnimation(
                        dismissDirection: SwipeDirection.right)),
                _buildShoeStoreExample(
                    context: context,
                    title: 'perspective carousel + swipe left',
                    animation: PerspectiveCarouselAnimation()),
              ],
            ),
          )),
    );
  }

  TextButton _buildShoeStoreExample({
    required BuildContext context,
    required String title,
    required CardAnimation animation,
  }) {
    return TextButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShoeStoreExample(
                      cardAnimation: animation,
                      title: title,
                    ))),
        child: Text(title));
  }

  TextButton _buildExample({
    required BuildContext context,
    required String title,
    required CardAnimation animation,
  }) {
    return TextButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuperheroesExample(
                      cardAnimation: animation,
                      title: title,
                    ))),
        child: Text(title));
  }
}
