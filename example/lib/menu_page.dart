import 'package:animation_examples/animation_example1.dart';
import 'package:animation_examples/swiped_cards.dart';
import 'package:example/swiped_cards.dart';
import 'package:flutter/material.dart';

import 'animation_example2.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
      ),
      body: Container(
          color: Colors.black12,
          child: Center(
            child: Column(
              children: [
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AnimationExample3Page())),
                    child: Text('Example 3')),
              ],
            ),
          )),
    );
  }
}
