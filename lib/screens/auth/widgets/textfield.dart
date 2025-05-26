import 'package:flutter/material.dart';
import 'package:enva/utils/utils.dart';

Widget buildTextField(
    {required String label, required TextEditingController controller}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'Aldrich',
            color: AppColors.labelText,
          )),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: TextField(
          controller: controller,
          cursorColor: AppColors.grey,
          decoration: const InputDecoration(
              fillColor: AppColors.floralWhite,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.floralWhite,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: AppColors.floralWhite,
                  width: 2,
                ),
              )),
        ),
      ),
    ],
  );
}
