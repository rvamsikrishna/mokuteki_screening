import 'package:flutter/material.dart';

class Creature extends StatelessWidget {
  const Creature({
    Key key,
    @required List<Offset> points,
    @required Animation<Color> colorAnimation,
    @required this.size,
  })  : _points = points,
        _colorAnimation = colorAnimation,
        super(key: key);

  final double size;
  final List<Offset> _points;
  final Animation<Color> _colorAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CreaturePainter(
          points: _points,
          color: _colorAnimation,
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
