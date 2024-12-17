import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final Widget icon;
  final Widget child;
  final VoidCallback? onPressed;

  const ButtonWithIcon(
      {super.key,
      required this.icon,
      required this.child,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0), child: child)
        ],
      ),
    );
  }
}
