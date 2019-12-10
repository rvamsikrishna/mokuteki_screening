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
    this.size = 20.0,
  })  : assert(size >= 20.0),
        super(key: key);
  @override
  CreatureState createState() {
    return new CreatureState();
  }
}

class CreatureState extends State<Creature> with TickerProviderStateMixin {
  final RandomColor _randomColor = RandomColor();

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
    )..addListener(_addCreaturePoints);

    _creatureAnimController.repeat();

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
        _points.add(Offset(x + widget.size, y + widget.size));
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
        onTap: () {
          _changeColor(_colorAnimation.value, _randomColor.randomColor());
        },
        onDoubleTap: () {
          if (_colorShiftingTimer == null) {
            _colorShiftingTimer =
                Timer.periodic(Duration(milliseconds: 500), (Timer t) {
              _changeColor(_colorAnimation.value, _randomColor.randomColor());
            });
          } else {
            _colorShiftingTimer.cancel();
            _colorShiftingTimer = null;
            _colorAnimationController.stop();
          }
          // // setState(() {
          //   _discoColors = !_discoColors;
          // // });
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
}

class CreaturePainter extends CustomPainter {
  final List<Offset> points;
  final Animation<Color> color;

  CreaturePainter({this.color, this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.addPolygon(points, false);

    canvas.drawPath(path, Paint()..color = color.value);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
