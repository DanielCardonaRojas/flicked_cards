import 'dart:math';

import 'package:flickered_cards/flickered_cards.dart';
import 'package:flutter/material.dart';

class FlickerdCardsExample extends StatelessWidget {
  final CardAnimation cardAnimation;
  final SwipeDirection dismissDirection;
  final bool usesInvertedLayout;
  final String title;
  final bool reversible;

  static const colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
  ];

  const FlickerdCardsExample({
    Key? key,
    required this.cardAnimation,
    this.dismissDirection = SwipeDirection.right,
    this.usesInvertedLayout = false,
    required this.title,
    required this.reversible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 400, 10, 0),
            child: CardDeck(
              count: 6,
              debug: true,
              dismissDirection: dismissDirection,
              animationStyle: cardAnimation
                ..usesInvertedLayout = usesInvertedLayout
                ..canReverse = reversible,
              onSwiped: (idx, dir) => print('>>> $dir $idx'),
              builder: (index, progress, context) {
                return Center(
                  child: Container(
                    height: 600,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colors[index % colors.length],
                    ),
                    width: 300,
                    child: Center(
                      child: Transform.rotate(
                        angle: 2 * pi * progress,
                        child: Text(
                          'Card # $index',
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                      ),
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
