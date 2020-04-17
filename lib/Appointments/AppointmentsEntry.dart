import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterbook/Appointments/AppointmentsDBWorker.dart';
import 'package:flutterbook/Appointments/AppointmentsModel.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleController.text;
    });

    _descriptionController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget child, AppointmentsModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());

                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text("Save"),
                    onPressed: () {
                      _save(context, appointmentsModel);
                    },
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Title"),
                      controller: _titleController,
                      validator: (String inValue) {
                        if (inValue.length == 0) {
                          return "Please enter a title";
                        }

                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      decoration: InputDecoration(hintText: "Description"),
                      controller: _descriptionController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Date"),
                    subtitle: Text(appointmentsModel.chosenDate == null ? "" : appointmentsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {

                        String chosenDate = await utils.selectDate(context,
                                                                  appointmentsModel,
                                                              appointmentsModel.entityBeingEdited.apptDate);

                        if (chosenDate != null) {
                          appointmentsModel.setChosenDate(chosenDate);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Time"),
                    subtitle: Text(appointmentsModel.apptTime == null ? "" :
                                                        appointmentsModel.apptTime),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {

                        await _selectedTime(context);
                      },
                    ),
                  )
                ],
              )
            ),
          );
        },
      ),
    );
  }


  Future _selectedTime(BuildContext context) async {

    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      var timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");

      initialTime = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
    }

    var picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(context));
    }
  }

  void _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (model.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(model.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(model.entityBeingEdited);
    }

    model.loadData("appointments", AppointmentsDBWorker.db);

    model.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
        content: Text("Appointment Saved"),
      )
    );
  }
}