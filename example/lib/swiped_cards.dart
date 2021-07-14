import 'dart:math';

import 'package:flickered_cards/flickered_cards.dart';
import 'package:flutter/material.dart';

class AnimationExample3Page extends StatelessWidget {
  static const colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example 3'),
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 400, 10, 0),
            child: CardDeck(
              count: 6,
              debug: true,
              dismissDirection: SwipeDirection.right,
              animationStyle: CardAnimation.stacked()
                ..usesInvertedLayout = true,
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
