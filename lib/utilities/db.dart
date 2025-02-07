import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helper.dart';

mixin DB {
  // https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/encryption_support.md
  static Database? _database;

  static Database get instance {
    return _database!;
  }

  static Future<void> get initialize async {
    final databaseFactory = databaseFactoryFfi;
    final databasePath = await Helper.getDatabasePath();
    final database = await databaseFactory.openDatabase(databasePath,
        options: OpenDatabaseOptions(
          onCreate: (db, version) {
            // Run the CREATE TABLE statement on the database.
            db.execute(
              'CREATE TABLE credentials(id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE, team_id INTEGER, type INTEGER NOT NULL, password TEXT, private_key TEXT, deleted_at DATETIME)',
            );
            db.execute(
              'CREATE TABLE tags(id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL UNIQUE, team_id INTEGER, remote_id INTEGER, local_updated_on DATETIME, remote_updated_on DATETIME, deleted_at DATETIME)',
            );
            db.execute(
              'CREATE TABLE hosts(id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL, team_id INTEGER, address TEXT NOT NULL, port INTEGER NOT NULL, username TEXT NOT NULL, credential_id INTEGER REFERENCES credentials(id), tag_id INTEGER REFERENCES tags(id), remote_id INTEGER, local_updated_on DATETIME, remote_updated_on DATETIME, deleted_at DATETIME)',
            );
          },
          version: 1,
        ));
    _database = database;
  }
}
