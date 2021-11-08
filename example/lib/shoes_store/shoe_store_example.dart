import 'package:flicked_cards/flicked_cards.dart';
import 'package:flutter/material.dart';
import 'shoe.dart';
import 'shoe_card.dart';

class ShoeStoreExample extends StatelessWidget {
  final CardAnimation cardAnimation;
  final String title;

  const ShoeStoreExample({
    Key? key,
    required this.cardAnimation,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 90),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: FlickedCards(
              count: Shoe.shoes.length,
              debug: false,
              animationStyle: cardAnimation,
              onSwiped: (idx, dir) => print('>>> $dir $idx'),
              builder: (index, progress, context) {
                final p = MapRange.withIntervals(
                        inMin: -1.0, inMax: 1.0, outMin: 0, outMax: 1)
                    .call(progress)
                    .toDouble();
                return Center(
                  child: Container(
                    height: 350,
                    width: 500,
                    child: ShoeCard(
                      shoe: Shoe.shoes[index],
                      progress: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
