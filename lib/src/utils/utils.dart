import 'package:flutter/material.dart';

double calculateAspectRatio(Size screenSize) {
  final width = screenSize.width;
  final height = screenSize.height;
  return width > height ? width / height : height / width;
}
