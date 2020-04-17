import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsList.dart';
import 'AppointmentsEntry.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class Appointments extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant(
        builder: (BuildContext context, Widget child, AppointmentsModel appt) {
          return IndexedStack(
            index: appt.stackIndex,
            children: <Widget>[
              AppointmentsList(),
              AppointmentsEntry()
            ],
          );
        },
      ),
    );
  }

}