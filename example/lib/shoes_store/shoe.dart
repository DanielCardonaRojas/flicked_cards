import 'package:flutter/material.dart';

class Shoe {
  final String name;
  final String image;
  final double price;
  final Color color;

  const Shoe({
    required this.name,
    required this.image,
    required this.price,
    required this.color,
  });

  static const shoes = [
    const Shoe(
        name: 'NIKE EPICT-REACT',
        price: 130.00,
        image: 'assets/img/shoes/1.png',
        color: Color(0xFF5574b9)),
    const Shoe(
        name: 'NIKE AIR-MAX',
        price: 130.00,
        image: 'assets/img/shoes/2.png',
        color: Color(0xFF52b8c3)),
    const Shoe(
        name: 'NIKE AIR-270',
        price: 150.00,
        image: 'assets/img/shoes/3.png',
        color: Color(0xFFE3AD9B)),
    const Shoe(
        name: 'NIKE EPICT-REACTII',
        price: 160.00,
        image: 'assets/img/shoes/4.png',
        color: Color(0xFF444547)),
  ];
}
