import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/Contacts/ContactsDBWorker.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsModel.dart' show ContactsModel, contactsModel, Contact;
import '../utils.dart' as utils;
import 'package:path/path.dart';

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget child, ContactsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, "avatar"));

                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = contactsModel.entityList[index];

                File avatarFile =
                    File(join(utils.docsDir.path, contact.id.toString()));

                bool avatarFileExists = avatarFile.existsSync();

                return Column(
                  children: <Widget>[
                    Slidable(
                      delegate: SlidableDrawerDelegate(),
                      actionExtentRatio: .25,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage:
                              avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists
                              ? null
                              : Text(
                                  contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null
                            ? null
                            : Text("${contact.phone}"),
                        onTap: () async {
                          File avatarFile =
                              File(join(utils.docsDir.path, "avatar"));

                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }

                          contactsModel.entityBeingEdited =
                              await ContactsDBWorker.db.get(contact.id);

                          if (contactsModel.entityBeingEdited.birthday ==
                              null) {
                            contactsModel.setChosenDate(null);
                          } else {
                            List dateParts = contactsModel
                                .entityBeingEdited.birthday
                                .split(",");

                            DateTime date = DateTime(
                                dateParts[0], dateParts[1], dateParts[2]);

                            contactsModel.setChosenDate(
                                DateFormat.yMMMMd("en_US").format(date));
                          }

                          contactsModel.setStackIndex(1);
                        },
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: "Delete",
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () async {
                            await _deleteContact(context, contact);
                          },
                        )
                      ],
                    ),
                    Divider()
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteContact(BuildContext context, Contact contact) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Contact"),
            content: Text("Do you want to delete contact ${contact.name}?"),
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
                  File avatarFile =
                      File(join(utils.docsDir.path, contact.id.toString()));

                  if (await avatarFile.exists()) {
                    await avatarFile.delete();
                  }

                  await ContactsDBWorker.db.delete(contact);

                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Contact Deleted"),
                  ));

                  contactsModel.loadData("contacts", ContactsDBWorker.db);
                },
              )
            ],
          );
        });
  }
}
