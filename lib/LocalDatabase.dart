import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static Database? _database;

  /// Get the database instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = join(await getDatabasesPath(), 'jewellery.db');
    /*CREATE TABLE customers (
            registrationId TEXT PRIMARY KEY,
            customerName TEXT NOT NULL,
            mobileNumber TEXT NOT NULL,
            customerEmail TEXT NOT NULL DEFAULT ''
          )*/
    _database = await openDatabase(
      dbPath,
      version: 4,

      // Create tables for a new installation.
      onCreate: (db, version) async {
      /*  await db.execute('''
        CREATE TABLE customers (
        registrationId TEXT,
        customerName TEXT,
        mobileNumber TEXT,
        customerEmail TEXT,
        accessToken TEXT,
        refreshToken TEXT
)
        ''');*/
        await db.execute('''
  CREATE TABLE customers (
    registrationId TEXT PRIMARY KEY,
    customerName TEXT,
    mobileNumber TEXT,
    customerEmail TEXT DEFAULT '',
    accessToken TEXT,
    refreshToken TEXT,
    isadmin INTEGER NOT NULL DEFAULT 0
  )
''');

        /*  await db.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY,
            accessToken TEXT NOT NULL
          )
        ''');*/
        await db.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY,
            accessToken TEXT NOT NULL,
            refreshToken TEXT
          )
        ''');
      },

      // Upgrade existing installations without deleting customer data.
      /* onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE customers
            ADD COLUMN customerEmail TEXT NOT NULL DEFAULT ''
          ''');
        }
      },*/
      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 2) {
          await db.execute('''
      ALTER TABLE customers
      ADD COLUMN customerEmail TEXT NOT NULL DEFAULT ''
    ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
      ALTER TABLE app_settings
      ADD COLUMN refreshToken TEXT
    ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
      ALTER TABLE customers
      ADD COLUMN isadmin INTEGER NOT NULL DEFAULT 0
    ''');
        }
      },
    );

    return _database!;
  }

  /// Save or update customer information.
  /* Future<void> saveCustomer({
    required String registrationId,
    required String customerName,
    required String mobileNumber,
    required String customerEmail,
  }) async {
    final db = await database;

    await db.insert('customers', {
      'registrationId': registrationId,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'customerEmail': customerEmail,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }*/
  Future<void> saveCustomer({
    required String registrationId,
    required String customerName,
    required String mobileNumber,
    required String customerEmail,
    required String accessToken,
    required String refreshToken,
    required bool isadmin,
  }) async {
    final db = await database;

    await db.insert(
      'customers',
      {
        'registrationId': registrationId,
        'customerName': customerName,
        'mobileNumber': mobileNumber,
        'customerEmail': customerEmail,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'isadmin': isadmin ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('Customer inserted successfully.');

    final rows = await db.query('customers');
    debugPrint('Customer rows after insert: ${rows.length}');
  }

  /// Get the first saved customer.
  /* Future<Map<String, dynamic>?> getCustomer() async {
    final db = await database;

    final rows = await db.query('customers', limit: 1);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }*/
  Future<Map<String, dynamic>?> getCustomer() async {
    final db = await database;

    final rows = await db.query(
      'customers',
      limit: 1,
    );

    debugPrint('Customer rows: $rows');

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  /// Get a customer by registration ID.
  Future<Map<String, dynamic>?> getCustomerByRegistrationId(
    String registrationId,
  ) async {
    final db = await database;

    final rows = await db.query(
      'customers',
      where: 'registrationId = ?',
      whereArgs: [registrationId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  /// Save or update the access token.
  Future<void> saveAccessToken(String accessToken) async {
    final db = await database;

    await db.insert('app_settings', {
      'id': 1,
      'accessToken': accessToken,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieve the saved access token.

  Future<String?> getAccessToken() async {
    final db = await database;

    final result = await db.query(
      'app_settings',
      columns: ['accessToken'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['accessToken'] as String?;
  }


  /// Delete the saved customer.
  Future<void> deleteCustomer() async {
    final db = await database;
    await db.delete('customers');
  }

  /// Delete the saved access token.
  Future<void> deleteAccessToken() async {
    final db = await database;
    await db.delete('app_settings', where: 'id = ?', whereArgs: [1]);
  }

  /// Close the database connection.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all saved customer data and access token.
  Future<void> clearDatabase() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('customers');
      await txn.delete('app_settings');
    });
  }

  // Save or update refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    final db = await database;

    await db.insert('app_settings', {
      'id': 1,
      'accessToken': await getAccessToken() ?? '',
      'refreshToken': refreshToken,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve refresh token

  Future<String?> getRefreshToken() async {
    final db = await database;

    final result = await db.query(
      'app_settings',
      columns: ['refreshToken'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['refreshToken'] as String?;
  }


  // Delete refresh token only
  Future<void> deleteRefreshToken() async {
    final db = await database;

    await db.update(
      'app_settings',
      {'refreshToken': null},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /*Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async
  {
    final db = await database;

    await db.insert(
      'app_settings',
      {
        'id': 1,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/

  Future<void> saveTokens(
      String accessToken,
      String refreshToken,
      ) async {
    final db = await database;

    await db.insert(
      'app_settings',
      {
        'id': 1,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('Access and refresh tokens saved successfully.');
  }

}
