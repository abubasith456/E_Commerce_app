import 'package:path_provider/path_provider.dart';
import 'package:shop_app/models/likedDB_model.dart';
import 'package:shop_app/models/user.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/my_db_model.dart';

class LikedDatabase {
  static final LikedDatabase instance = LikedDatabase._init();
  static final filePath = 'LikedDb.db';
  static Database? _database;
  static DatabaseFactory? databaseFactory;

  LikedDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(filePath);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY';
    final textType = 'TEXT';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    // await db.execute(
    //     'CREATE TABLE $CartData (id INTEGER PRIMARY KEY, name TEXT, price TEXT, description REAL, categoryId TEXT, productImage TEXT, productId TEXT)');

    await db.execute('''
CREATE TABLE $LikedData (
  ${LikedFields.id} $idType,
  ${LikedFields.name} $textType,
  ${LikedFields.price} $textType,
  ${LikedFields.description} $textType,
  ${LikedFields.productImage} $textType,
  ${LikedFields.productId} $textType,
  ${LikedFields.isLiked} $textType
  )
''');
  }

  Future<Liked> create(Liked cart) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(LikedData, cart.toJson());
    print("Like added");
    return cart.copy(id: id);
  }

  Future<Liked> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      LikedData,
      columns: LikedFields.values,
      where: '${LikedFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Liked.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Liked>> readAllcart() async {
    final db = await instance.database;

    final name = '${LikedFields.name} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(LikedData, orderBy: name);

    return result.map((json) => Liked.fromJson(json)).toList();
  }

  Future<int> update(Liked liked) async {
    final db = await instance.database;

    return db.update(
      LikedData,
      liked.toJson(),
      where: '${LikedFields.productId} = ?',
      whereArgs: [liked.productId],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      LikedData,
      where: '${LikedFields.productId} = ?',
      whereArgs: [id],
    );
  }

  Future deleteTable() async {
    final db = await instance.database;
    db.execute("delete from " + LikedData);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Future<Database> setDatabase() async {
//   var directory = await getApplicationDocumentsDirectory();
//   var path = join(directory.path, 'MY_DB');
//   var database =
//       await openDatabase(path, version: 1, onCreate: _createDatabase);
//   return database;
// }

// Future<void> _createDatabase(Database database, int version) async {
//   String sql =
//       "CREATE TABLE users (id INTEGER PRIMARY KEY,userIdTEXT,emalTEXT,passwordText);";
//   await database.execute(sql);
// }
