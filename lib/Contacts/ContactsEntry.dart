import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterbook/Contacts/ContactsDBWorker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsModel.dart' show contactsModel, ContactsModel, Contact;
import '../utils.dart' as utils;
import 'package:path/path.dart';

class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    _nameController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameController.text;
    });

    _phoneController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneController.text;
    });

    _emailController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailController.text;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (contactsModel.entityBeingEdited != null) {
      _nameController.text = contactsModel.entityBeingEdited.name;
      _phoneController.text = contactsModel.entityBeingEdited.phone;
      _emailController.text = contactsModel.entityBeingEdited.email;
    }
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget child, ContactsModel inModel) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));

          if (avatarFile.existsSync() == false) {
            if (contactsModel.entityBeingEdited != null &&
                contactsModel.entityBeingEdited.id != null) {
              avatarFile = File(join(utils.docsDir.path,
                  contactsModel.entityBeingEdited.id.toString()));
            }
          }

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      avatarFile = File(join(utils.docsDir.path, "avatar"));

                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }

                      FocusScope.of(context).requestFocus(FocusNode());

                      contactsModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text("Save"),
                    onPressed: () async {
                      await _save(context, contactsModel);
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
                    title: avatarFile.existsSync()
                        ? Image.file(avatarFile)
                        : Text("No avatar image for this contact"),
                    trailing: IconButton(
                      color: Colors.blue,
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await _selectAvatar(context);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Name"),
                      controller: _nameController,
                      validator: (String nameValue) {
                        if (nameValue.length == 0) {
                          return "Please enter name";
                        }

                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Phone number"),
                      controller: _phoneController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: "Email"),
                      controller: _emailController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Birthday"),
                    subtitle: Text(contactsModel.chosenDate == null
                        ? ""
                        : contactsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(context,
                            inModel, contactsModel.entityBeingEdited.birthday);

                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _selectAvatar(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Take a picture"),
                    onTap: () async {
                      var cameraImage = await ImagePicker.pickImage(
                          source: ImageSource.camera);

                      if (cameraImage != null) {
                        cameraImage
                            .copySync(join(utils.docsDir.path, "avatar"));

                        contactsModel.triggerRebuild();
                      }

                      Navigator.of(inAlertContext).pop();
                    },
                  ),
                  GestureDetector(
                    child: Text("Select from Gallery"),
                    onTap: () async {
                      var galleryImage = await ImagePicker.pickImage(
                          source: ImageSource.gallery);

                      if (galleryImage != null) {
                        galleryImage
                            .copySync(join(utils.docsDir.path, "avatar"));

                        contactsModel.triggerRebuild();
                      }

                      Navigator.of(inAlertContext).pop();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future _save(BuildContext context, ContactsModel contactsModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    var id;

    if (contactsModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File avatarFile = File(join(utils.docsDir.path, "avatar"));

    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);

    contactsModel.setStackIndex(0);

    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text("Contact saved"),
    ));
  }
}
