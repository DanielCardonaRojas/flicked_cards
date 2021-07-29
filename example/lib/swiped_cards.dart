import 'dart:math';

import 'package:example/superheroes/superhero.dart';
import 'package:example/superheroes/superhero_card.dart';
import 'package:flicked_cards/flicked_cards.dart';
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
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FlickedCards(
                          count: Superhero.marvelHeroes.length,
                          debug: false,
                          animationStyle: cardAnimation,
                          onSwiped: (idx, dir) => print('>>> $dir $idx'),
                          builder: (index, progress, context) {
                            final superHeroe = Superhero.marvelHeroes[index];
                            return Container(
                              child: Center(
                                child: SuperheroCard(
                                    superhero: superHeroe,
                                    factorChange: 1 - progress),
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
              ))),
    );
  }
}
