import 'package:flutter/material.dart';

class FoodParticleWidget extends StatefulWidget {
  final Size scrSize;
  final Size particleSize;
  final double beginOffset;
  final bool start;
  final Color color;
  final Function(double) onConsume;

  const FoodParticleWidget({
    Key key,
    @required this.scrSize,
    this.particleSize = const Size(20.0, 20.0),
    this.beginOffset = 0.0,
    this.start = false,
    this.color = Colors.white,
    this.onConsume,
  }) : super(key: key);
  @override
  _FoodParticleWidgetState createState() => _FoodParticleWidgetState();
}

class _FoodParticleWidgetState extends State<FoodParticleWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<RelativeRect> _position;

  @override
  void initState() {
    super.initState();
    final int durationinMs = (((widget.beginOffset + widget.scrSize.height) /
                widget.scrSize.height) *
            6000)
        .floor();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationinMs))
      ..addListener(() {
        widget.onConsume(_position.value.top + widget.particleSize.height);
      });

    final double initialLeftRight =
        (widget.scrSize.width - widget.particleSize.width) / 2;

    _position = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          initialLeftRight,
          -widget.beginOffset,
          initialLeftRight,
          widget.scrSize.height +
              widget.beginOffset -
              widget.particleSize.height),
      end: RelativeRect.fromLTRB(initialLeftRight, widget.scrSize.height,
          initialLeftRight, -widget.particleSize.height),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(FoodParticleWidget oldWidget) {
    if (oldWidget.start != widget.start) {
      if (widget.start) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PositionedTransition(
      rect: _position,
      child: Container(
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
