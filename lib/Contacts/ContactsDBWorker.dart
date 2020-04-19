import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'ContactsModel.dart';

class ContactsDBWorker {
  ContactsDBWorker._();

  static final ContactsDBWorker db = ContactsDBWorker._();

  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    return _db;
  }

  Future init() async {
    String path = join(utils.docsDir.path, "contacts.db");

    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDb, int version) async {
      await inDb.execute("CREATE TABLE IF NOT EXISTS contacts"
          "(id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "email TEXT,"
          "phone TEXT,"
          "birthday TEXT)");
    });

    return db;
  }

  Contact contactFromMap(Map inMap) {
    Contact contact = Contact();

    contact.id = inMap["id"];
    contact.name = inMap["name"];
    contact.email = inMap["email"];
    contact.phone = inMap["phone"];
    contact.birthday = inMap["birthday"];

    return contact;
  }

  Map<String, dynamic> contactToMap(Contact contact) {
    Map<String, dynamic> map = Map<String, dynamic>();

    map["id"] = contact.id;
    map["name"] = contact.name;
    map["phone"] = contact.phone;
    map["email"] = contact.email;
    map["birthday"] = contact.birthday;

    return map;
  }

  Future create(Contact contact) async {
    Database db = await database;

    var val = await db.rawQuery("SELECT MAX(id)+1 as id FROM contacts");

    int id = val.first["id"];

    if (id == null) {
      id = 1;
    }

    return await db.rawInsert(
        "INSERT INTO contacts(id, name, email, phone, birthday)"
        "VALUES(?, ?, ?, ?, ?)",
        [id, contact.name, contact.email, contact.phone, contact.birthday]);
  }

  Future get(int id) async {
    Database db = await database;

    var rec = await db.query("contacts", where: "id = ?", whereArgs: [id]);

    return contactFromMap(rec.first);
  }

  Future getAll() async {
    Database db = await database;

    var rec = await db.query("contacts");

    var list = rec.isNotEmpty ? rec.map((c) => contactFromMap(c)).toList() : [];

    return list;
  }

  Future update(Contact contact) async {
    Database db = await database;

    return await db.update("contacts", contactToMap(contact),
        where: "id = ?", whereArgs: [contact.id]);
  }

  Future delete(Contact contact) async {
    Database db = await database;

    return await db
        .delete("contacts", where: "id = ?", whereArgs: [contact.id]);
  }
}
