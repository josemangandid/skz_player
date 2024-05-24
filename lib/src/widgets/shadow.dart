import 'package:flutter/material.dart';

class ShadowWidget extends StatelessWidget {
  const ShadowWidget({
    super.key,
    required this.showMenu,
    required this.onTap,
    required this.onDoubleTap,
  });

  final bool showMenu;
  final Function() onTap;
  final Function() onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return showMenu
        ? GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black54),
            ),
          )
        : Container();
  }
}
