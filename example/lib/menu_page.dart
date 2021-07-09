import 'package:example/swiped_cards.dart';
import 'package:flutter/material.dart';

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
