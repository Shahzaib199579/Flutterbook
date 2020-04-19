import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'BaseModel.dart';

Directory docsDir;

Future selectDate(
    BuildContext context, BaseModel inModel, String dateString) async {
  DateTime initialDateTime = DateTime.now();

  if (dateString != null) {
    List dateParts = dateString.split(",");
    initialDateTime = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),
        int.parse(dateParts[2]));
  }

  DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100));

  if (picked != null) {
    inModel.setChosenDate(DateFormat.yMMMMd("en_US").format(picked.toLocal()));
    return "${picked.year},${picked.month},${picked.day}";
  }
}
