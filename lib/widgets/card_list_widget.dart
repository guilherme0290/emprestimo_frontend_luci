import 'package:flutter/material.dart';

class CardListaWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final int index;

  const CardListaWidget({
    super.key,
    required this.child,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, offset, widget) {
        return Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: 1 - offset.dy,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
