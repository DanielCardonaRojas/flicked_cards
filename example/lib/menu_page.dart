import 'package:example/swiped_cards.dart';
import 'package:flickered_cards/flickered_cards.dart';
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
                    dismissDirection: SwipeDirection.right,
                    animation: DeckAnimation()),
                _buildExample(
                    context: context,
                    title: 'roll + non reversible',
                    reversible: false,
                    animation: RollAnimation()),
                _buildExample(
                    context: context,
                    title: 'flip + non reversible',
                    reversible: false,
                    animation: FlipAnimation()),
                _buildExample(
                    context: context,
                    title: 'unstacked deck + reversible + swipe left',
                    dismissDirection: SwipeDirection.left,
                    inverted: true,
                    reversible: true,
                    animation: CardAnimation.stacked()),
                _buildExample(
                    context: context,
                    title: 'stacked deck + not reversible',
                    reversible: false,
                    animation: CardAnimation.stacked()),
                _buildExample(
                    context: context,
                    title: 'carousel + swipe left',
                    animation: CardAnimation.carousel()),
                _buildExample(
                    context: context,
                    dismissDirection: SwipeDirection.right,
                    title: 'carousel + swipe right',
                    animation: CardAnimation.carousel()),
              ],
            ),
          )),
    );
  }

  TextButton _buildExample({
    required BuildContext context,
    required String title,
    required CardAnimation animation,
    bool reversible = true,
    bool inverted = false,
    SwipeDirection dismissDirection = SwipeDirection.left,
  }) {
    return TextButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FlickerdCardsExample(
                      reversible: reversible,
                      cardAnimation: animation,
                      dismissDirection: dismissDirection,
                      usesInvertedLayout: inverted,
                      title: title,
                    ))),
        child: Text(title));
  }
}
