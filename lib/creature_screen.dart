import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:mokuteki_screening/creature.dart';
import 'package:mokuteki_screening/food_particle.dart';

import 'dart:math' as math;

import 'package:mokuteki_screening/model.dart';
import 'package:random_color/random_color.dart';

class CreatureScreen extends StatefulWidget {
  final Color color;
  final double size;

  const CreatureScreen({
    Key key,
    this.color = Colors.white,
    this.size = 40.0,
  })  : assert(size >= 20.0),
        super(key: key);
  @override
  CreatureScreenState createState() {
    return new CreatureScreenState();
  }
}

class CreatureScreenState extends State<CreatureScreen>
    with TickerProviderStateMixin {
  final RandomColor _randomColor = RandomColor();

  double _center = 0.5;
  bool _start = false;
  List<FoodParticle> _foodParticles = foodParticles;
  AnimationController _creatureAnimController;
  double _radius;
  List<Offset> _points = [];
  double _yoff = 0.0;
  AnimationController _colorAnimationController;
  Animation<Color> _colorAnimation;
  // bool _discoColors = false;
  Timer _colorShiftingTimer;

  @override
  void initState() {
    super.initState();
    _radius = widget.size;
    _creatureAnimController = AnimationController(
      duration: Duration(milliseconds: 1),
      vsync: this,
    );

    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _colorAnimation = ColorTween(
      begin: widget.color,
      end: widget.color,
    ).animate(_colorAnimationController);
  }

  void _addCreaturePoints() {
    setState(() {
      _points.clear();

      double xoff = 0;
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        //creates the point to draw a circle but adds a variation to the points
        //on circurmference with the use of perlin noise.
        var offset = PerlinNoise(frequency: math.pi).getPerlin2(xoff, _yoff) *
            _radius *
            0.25;
        var r = _radius + offset;
        var x = r * math.cos(angle);
        var y = r * math.sin(angle);
        xoff += 0.2;
        _points.add(Offset(x + _radius, y + _radius));
      }

      _yoff += 0.01;
    });
  }

  @override
  void dispose() {
    _creatureAnimController.dispose();
    _colorAnimationController.dispose();
    _colorShiftingTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CreatureScreen oldWidget) {
    if (oldWidget.color != widget.color) {
      _changeColor(oldWidget.color, widget.color);
    }

    super.didUpdateWidget(oldWidget);
  }

  void _changeColor(Color oldColor, Color newColor) {
    _colorAnimation = ColorTween(
      begin: oldColor,
      end: newColor,
    ).animate(_colorAnimationController);

    _colorAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Size scrSize = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Slider(
          onChanged: (double value) {
            setState(() {
              _center = value;
            });
          },
          value: _center,
          activeColor: Colors.transparent,
          inactiveColor: Colors.transparent,
        ),
        ..._foodParticles.map((f) {
          return FoodParticleWidget(
            particleSize: f.size,
            scrSize: scrSize,
            beginOffset: f.offset,
            color: f.color,
            start: _start,
            onConsume: (double offset) {
              final double left = (scrSize.width * _center) - _radius;
              if (offset >= scrSize.height / 2 - _radius &&
                  offset < scrSize.height / 2 + _radius &&
                  (left > scrSize.width / 2 - f.size.width - 2 * _radius) &&
                  (left < scrSize.width / 2 + f.size.width)) {
                setState(() {
                  // _foodParticles.removeAt(0);
                });

                _changeColor(_colorAnimation.value, f.color);
              }
            },
          );
        }),
        AnimatedPositioned(
          duration: Duration(milliseconds: 100),
          top: scrSize.height / 2 - _radius,
          left: (scrSize.width * _center) - _radius,
          child: GestureDetector(
            onTap: () {
              _startWiggle();
            },
            onDoubleTap: () {
              _changeColor(
                _colorAnimation.value,
                _randomColor.randomColor(
                    colorSaturation: ColorSaturation.highSaturation),
              );
            },
            onLongPress: () {
              _toggleColorShifting();
            },
            child: Creature(
              size: 2 * widget.size,
              points: _points,
              colorAnimation: _colorAnimation,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleColorShifting() {
    if (_colorShiftingTimer == null) {
      _colorShiftingTimer =
          Timer.periodic(Duration(milliseconds: 300), (Timer t) {
        _changeColor(
          _colorAnimation.value,
          _randomColor.randomColor(
              colorSaturation: ColorSaturation.highSaturation),
        );
      });
    } else {
      _colorShiftingTimer.cancel();
      _colorShiftingTimer = null;
      _colorAnimationController.stop();
    }
  }

  void _startWiggle() {
    if (!_start) {
      _start = true;
      _creatureAnimController.addListener(_addCreaturePoints);
      _creatureAnimController.repeat();
    } else {
      _creatureAnimController.removeListener(_addCreaturePoints);
      _colorAnimationController.stop();
      setState(() {
        _start = false;
      });
    }
  }
}
