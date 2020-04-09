import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/Tasks/TasksDBWorker.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TasksModel.dart' show tasksModel, TasksModel, Task;

class TasksList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext builderContext, Widget inChild, TasksModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = tasksModel.entityList[index];

                String sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate.split(",");

                  DateTime dueDate = DateTime(int.parse(dateParts[0]),
                                              int.parse(dateParts[1]),
                                              int.parse(dateParts[2]));

                  sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                }

                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actionExtentRatio: .25,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == "true" ? true : false,
                      onChanged: (inValue) async {
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData("tasks", TasksDBWorker.db);
                      },
                    ),
                    title: Text(
                        "${task.description}",
                    style: task.completed == "true" ? TextStyle(
                      color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough
                    ) : TextStyle(
                      color: Theme.of(context).textTheme.title.color
                    )
                    ),
                    subtitle: task.dueDate == null ? null : Text(sDueDate,
                                                                style: task.completed == "true" ? TextStyle(
                                                                    color: Theme.of(context).disabledColor,
                                                                    decoration: TextDecoration.lineThrough
                                                                ) : TextStyle(
                                                                    color: Theme.of(context).textTheme.title.color
                                                                )),
                    onTap: () async {
                      if (task.completed == "true") { return; }

                      tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);

                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate(null);
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }

                      tasksModel.setStackIndex(1);
                    },
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: "Delete",
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async => await _deleteTask(context, task)
                    )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteTask(BuildContext inContext, Task task) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content: Text("Are you sure you want to delete the task?"),
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
                  await TasksDBWorker.db.delete(task.id);
                  Navigator.of(inAlertContext).pop();
                  Scaffold.of(inContext).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Note Deleted"),
                      )
                  );

                  tasksModel.loadData("tasks", TasksDBWorker.db);
                },
              )
            ],
          );
        }
    );
  }

}