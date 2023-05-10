import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/dumyData.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      height: 180,
      width: 260,
      decoration: BoxDecoration(
        color: widget.course.bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    widget.course.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                
                
              ],
            ),
          ),
          SvgPicture.asset(widget.course.iconSrc)
        ],
      ),
    );
  }
}
