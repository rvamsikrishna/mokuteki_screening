import 'dart:ui';

import 'package:flutter/material.dart';

List<FoodParticle> foodParticles = [
  FoodParticle(size: Size(20.0, 20.0), color: Colors.red, offset: 200.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.amberAccent, offset: 450.0),
  FoodParticle(size: Size(20.0, 20.0), color: Colors.green, offset: 800.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.pinkAccent, offset: 1000.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.orangeAccent, offset: 1300.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.blueAccent, offset: 1600.0),
  FoodParticle(size: Size(20.0, 20.0), color: Colors.redAccent, offset: 1950.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.deepPurple, offset: 2300.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.cyanAccent, offset: 2700.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.yellowAccent, offset: 3000.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.tealAccent, offset: 3500.0),
  FoodParticle(
      size: Size(20.0, 20.0), color: Colors.blueAccent, offset: 3850.0),
];

class FoodParticle {
  final double offset;
  final Color color;
  final Size size;
  FoodParticle({this.size, this.offset = 0.0, this.color = Colors.white});
}
