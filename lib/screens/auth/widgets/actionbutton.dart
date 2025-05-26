import 'package:flutter/material.dart';

Widget buildAuthButton(
  BuildContext context,
  String text,
  Color color,
  VoidCallback onPressed, {
  Color textColor = Colors.white,
  Color? borderColor,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
        elevation: borderColor != null ? 0 : 2,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ),
  );
}
