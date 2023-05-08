import 'package:flutter/material.dart';

class Course {
  final String title, description, iconSrc;
  final Color bgColor;

  Course({
    required this.title,
    this.description = "Build and animate an iOS app from scratch",
    this.iconSrc = "assets/icons/ios.svg",
    this.bgColor = const Color(0xFF7553F6),
  });
}

List<Course> courses = [
  Course(
    title: "GPS Location",
    description: "Lat: 79.004 Lon: 6.4404",
    iconSrc: "assets/icons/code.svg",
    bgColor: const Color(0xFF7553F6),
    ),
  Course(
    title: "Speed",
    description: "20 kmph",
    iconSrc: "assets/icons/code.svg",
    bgColor: const Color(0xFF80A4FF),
  ),
  Course(
    title: "Heading",
    description: "N 154.00°",
    iconSrc: "assets/icons/code.svg",
    bgColor: const Color(0xFF80A4FF),
  ),
  Course(
    title: "Acceleration",
    description: "0.5",
    iconSrc: "assets/icons/code.svg",
    bgColor: const Color(0xFF80A4FF),
  ),
];


