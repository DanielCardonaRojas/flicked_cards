import 'dart:math';

import 'package:flickered_cards/flickered_cards.dart';
import 'package:flutter/material.dart';

class FlickerdCardsExample extends StatelessWidget {
  final CardAnimation cardAnimation;
  final String title;

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
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              SizedBox(
                height: 400,
                child: FlickeredCards(
                  count: 6,
                  debug: true,
                  animationStyle: cardAnimation,
                  onSwiped: (idx, dir) => print('>>> $dir $idx'),
                  builder: (index, progress, context) {
                    return _buildCard(index, progress);
                  },
                ),
              ),
            ]),
      ),
    );
  }

  Widget _buildCard(int index, double progress) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors[index % colors.length],
      ),
      child: Center(
        child: Transform.rotate(
          angle: 2 * pi * progress,
          child: Text(
            'Card # $index',
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
