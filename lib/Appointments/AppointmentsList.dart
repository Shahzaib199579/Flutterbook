import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/Appointments/AppointmentsDBWorker.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AppointmentsModel.dart' show appointmentsModel, Appointment, AppointmentsModel;

class AppointmentsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList();

    for(int i = 0 ; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];

      List dateParts = appointment.apptDate.split(",");

      DateTime apptDate = DateTime(int.parse(dateParts[0]), 
                                    int.parse(dateParts[1]),
                                    int.parse(dateParts[2]));
      
      _markedDateMap.add(apptDate, Event(date: apptDate, icon: Container(
        decoration: BoxDecoration(color: Colors.blue),
      ))
      );
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget child, AppointmentsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();

                DateTime now = DateTime.now();

                appointmentsModel.entityBeingEdited.apptDate = "${now.year}, "
                                                                "${now.month}, "
                                                                "${now.day}";

                appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US")
                                                  .format(now.toLocal()));

                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, context);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime date, BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
            model: appointmentsModel,
            child: ScopedModelDescendant<AppointmentsModel>(
              builder: (BuildContext builderContext, Widget child, AppointmentsModel appt) {
                return Scaffold(
                  body: Container(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        child: Column(
                          children: <Widget>[
                            Text(DateFormat.yMMMMd("en_US").format(date.toLocal()),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).accentColor,
                              fontSize: 24),),
                            Divider(),
                            Expanded(
                              child: ListView.builder(itemCount: appointmentsModel.entityList.length,
                                  itemBuilder: (BuildContext inBuildContext, int index) {
                                Appointment appointment = appointmentsModel.entityList[index];

                                if (appointment.apptDate != "${date.year}, ${date.month}, ${date.day}") {
                                  return Container(height: 0);
                                }

                                String apptTime = "";
                                if (appointment.apptTime != null) {
                                  List timeParts = appointment.apptTime.split(",");

                                  TimeOfDay time = TimeOfDay(hour: int.parse(timeParts[0]),
                                                              minute: int.parse(timeParts[1]));

                                  apptTime = "(${time.format(context)})";
                                }

                                return Slidable(
                                  delegate: SlidableDrawerDelegate(),
                                  actionExtentRatio: .25,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    color: Colors.grey.shade300,
                                    child: ListTile(
                                      title: Text("${appointment.title}$apptTime"),
                                      subtitle: appointment.description == null ?
                                                                    null : Text("${appointment.description}"),
                                      onTap: () async {
                                        _editAppointment(context, appointment);
                                      },
                                    ),
                                  ),
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                        caption: "Delete",
                                        icon: Icons.delete,
                                        color: Colors.red,
                                      onTap: () async {
                                          await _deleteAppointment(context, appointment);
                                      },
                                    ),
                                  ],
                                );
                              }
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  void _editAppointment(BuildContext context, Appointment appointment) async {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(appointment.id);

    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");

      DateTime requiredDate = DateTime(int.parse(dateParts[0]),
                                      int.parse(dateParts[1]),
                                        int.parse(dateParts[2]));

      appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(requiredDate.toLocal()));
    }

    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime(null);
    } else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      
      TimeOfDay requiredTime = TimeOfDay(hour: int.parse(timeParts[0]),
                                         minute: int.parse(timeParts[1]));

      appointmentsModel.setApptTime(requiredTime.format(context));
    }

    appointmentsModel.setStackIndex(1);
    Navigator.pop(context);
  }

  Future _deleteAppointment(BuildContext context, Appointment appointment) async {
    return showDialog(
        context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Appointment"),
            content: Text("Are you sure you want to delete ${appointment.title}?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(inAlertContext).pop();
                },
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: () async {
                  await AppointmentsDBWorker.db.delete(appointment.id);
                  Navigator.of(inAlertContext).pop();

                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Appointment Deleted"),
                    )
                  );

                  appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
                },
              )
            ],
          );
      }
    );
  }
}