import 'package:flutter/material.dart';
import 'package:flutterbook/Contacts/ContactsEntry.dart';
import 'package:flutterbook/Contacts/ContactsList.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsModel.dart' show contactsModel, ContactsModel;
import 'ContactsDBWorker.dart';

class Contacts extends StatelessWidget {
  Contacts() {
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget child, ContactsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[ContactsList(), ContactsEntry()],
          );
        },
      ),
    );
  }
}
