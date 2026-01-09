import 'package:flutter/material.dart';

class ScrollHint extends StatefulWidget {
  final String label;
  final Axis axis;
  final Color color;
  final IconData? icon;

  const ScrollHint({
    super.key,
    required this.label,
    this.axis = Axis.vertical,
    this.color = Colors.grey,
    this.icon,
  });

  @override
  State<ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _offset = Tween<double>(
    begin: 0,
    end: 6,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon ??
        (widget.axis == Axis.vertical
            ? Icons.keyboard_arrow_down
            : Icons.swipe);
    return Center(
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          return Transform.translate(
            offset: widget.axis == Axis.vertical
                ? Offset(0, _offset.value)
                : Offset(_offset.value, 0),
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: widget.color),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(fontSize: 12, color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
