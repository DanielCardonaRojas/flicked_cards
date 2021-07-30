import 'package:flutter/material.dart';
import 'shoe.dart';

class ShoeCard extends StatelessWidget {
  final Shoe shoe;
  final double progress;

  const ShoeCard({
    Key? key,
    required this.shoe,
    required this.progress,
  }) : super(key: key);

  double get t => progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const marginCenter = EdgeInsets.symmetric(horizontal: 0, vertical: 15);

    return Stack(
      children: [
        Stack(
          children: [
            Hero(
              tag: 'hero_background_${shoe.name}',
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: marginCenter,
                color: shoe.color,
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              margin: marginCenter,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shoe.name.split(' ').join('\n'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "\$${shoe.price}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: Hero(
            tag: 'hero_image_${shoe.name}',
            child: Image.asset(
              shoe.image,
              height: size.width / 2.5,
            ),
          ),
        ),
      ],
    );
  }
}
