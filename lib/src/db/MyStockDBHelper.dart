import 'package:sqflite/sqflite.dart';
import '../model/MyStock.dart';
import 'package:path/path.dart';
import '../bloc/bloc.dart';

final dbName = "ceiling.db";
final tableName = "MyStock";

class MyStockDBHelper {
  MyStockDBHelper._();
  static final MyStockDBHelper _db = MyStockDBHelper._();
  factory MyStockDBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY,enterprise TEXT,symbol TEXT,stockCount INTEGER,buying REAR)');
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  insertData(MyStock item) async {
    final db = await database;
    var id = await db.rawInsert(
        'INSERT INTO $tableName(enterprise,symbol, stockCount, buying) VALUES(?,?,?,?)',
        [item.enterprise, item.symbol, item.stockCount, item.buying]);
    item.id = id;
    bloc.insertFromMyStock(item);
    return id;
  }

  Future<List<MyStock>> getAll() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $tableName');
    List<MyStock> list = res.isNotEmpty
        ? res
            .map((e) => MyStock(
                  id: e['id'],
                  enterprise: e['enterprise'],
                  symbol: e['symbol'],
                  stockCount: e['stockCount'],
                  buying: double.parse(e['buying'].toString()),
                ))
            .toList()
        : [];
    return list;
  }

  updateData(MyStock item) async {
    final db = await database;
    var res = db.rawUpdate(
        'UPDATE $tableName SET stockCount=?,buying=? WHERE id=?',
        [item.stockCount, item.buying, item.id]);
    return res;
  }

  deleteData(MyStock item) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $tableName WHERE id=?', [item.id]);
    bloc.deleteFromMyStock(item);
    return res;
  }

  deleteDataBySymbol(String symbol) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $tableName WHERE symbol=?', [symbol]);
    return res;
  }

  dispose() async {
    final db = await database;
    await db.close();
  }
}
