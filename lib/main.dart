import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'Appointments/Appointments.dart';
import 'Contacts/Contacts.dart';
import 'Notes/Notes.dart';
import 'Tasks/Tasks.dart';
import 'utils.dart' as utils;
import 'package:simple_permissions/simple_permissions.dart';

void main() {
  startMeUp() async {
    Directory docsDir;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      PermissionStatus permissionResult = await
                SimplePermissions.requestPermission(Permission. WriteExternalStorage);

      if (permissionResult == PermissionStatus.authorized){
        docsDir = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
    }

    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("FlutterBook"),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.date_range),
                  text: "Appointments",
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: "Contacs",
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_returned),
                  text: "Tasks",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              //Appointments(),
              Text("Appointments"),
              Text("Contacts"),
              //Contacts(),
              Notes(),
              Text("Tasks"),
              //Tasks()
            ],
          ),
        ),
      ),
    );
  }

}