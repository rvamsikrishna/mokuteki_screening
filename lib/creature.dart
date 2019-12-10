import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fast_noise/fast_noise.dart';

import 'dart:math' as math;

import 'package:random_color/random_color.dart';

class Creature extends StatefulWidget {
  final Color color;
  final double size;

  const Creature({
    Key key,
    this.color = Colors.white,
    this.size = 40.0,
  })  : assert(size >= 20.0),
        super(key: key);
  @override
  CreatureState createState() {
    return new CreatureState();
  }
}

class CreatureState extends State<Creature> with TickerProviderStateMixin {
  final RandomColor _randomColor = RandomColor();

  bool wiggle = false;
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

    // _creatureAnimController.repeat();

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
        var offset =
            PerlinNoise(frequency: math.pi).getPerlin2(xoff, _yoff) * 5.0;
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
  void didUpdateWidget(Creature oldWidget) {
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
    return Container(
      width: 2 * widget.size,
      height: 2 * widget.size,
      child: GestureDetector(
        onScaleStart: (ScaleStartDetails d) {},
        onScaleUpdate: (ScaleUpdateDetails d) {
          if (_radius < 20.0 ||
              _radius >= MediaQuery.of(context).size.width - 20.0) return;

          setState(() {
            _radius = _radius * d.scale;
          });
        },
        onTap: () {
          _startWiggle();
        },
        onDoubleTap: () {
          _changeColor(
              _colorAnimation.value,
              _randomColor.randomColor(
                colorSaturation: ColorSaturation.highSaturation,
              ));
        },
        onLongPress: () {
          if (_colorShiftingTimer == null) {
            _colorShiftingTimer =
                Timer.periodic(Duration(milliseconds: 500), (Timer t) {
              _changeColor(
                  _colorAnimation.value,
                  _randomColor.randomColor(
                    colorSaturation: ColorSaturation.highSaturation,
                  ));
            });
          } else {
            _colorShiftingTimer.cancel();
            _colorShiftingTimer = null;
            _colorAnimationController.stop();
          }
        },
        child: CustomPaint(
          painter: CreaturePainter(
            points: _points,
            color: _colorAnimation,
          ),
        ),
      ),
    );
  }

  void _startWiggle() {
    if (!wiggle) {
      wiggle = true;
      _creatureAnimController.addListener(_addCreaturePoints);
      _creatureAnimController.repeat();
    } else {
      _creatureAnimController.removeListener(_addCreaturePoints);
      _colorAnimationController.stop();
      wiggle = false;
    }
  }
}

class CreaturePainter extends CustomPainter {
  final List<Offset> points;
  final Animation<Color> color;

  CreaturePainter({this.color, this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    var paint = Paint()..color = color.value;
    if (points.isEmpty) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    } else {
      path.addPolygon(points, false);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

RefreshIndicator c;
