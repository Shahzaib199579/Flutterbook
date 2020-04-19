import 'package:flutterbook/BaseModel.dart';

class Contact {
  int id;
  String name;
  String phone;
  String email;
  String birthday;
}

class ContactsModel extends BaseModel {
  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();
