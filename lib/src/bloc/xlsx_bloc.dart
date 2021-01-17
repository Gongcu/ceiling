import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:excel/excel.dart';
import '../model/SavedStock.dart';
import 'package:rxdart/rxdart.dart';

final tickersPath = 'assets/excels/tickers.xlsx';

class XlsxBloc {
  List<SavedStock> savedStocks = [];
  BehaviorSubject<List<SavedStock>> _subjectSavedStockList;

  XlsxBloc() {
    _subjectSavedStockList = BehaviorSubject.seeded(savedStocks);
    getData();
  }

  get savedStockContoller => _subjectSavedStockList.stream;

  getData() async {
    ByteData data = await rootBundle.load(tickersPath);
    //isolate을 통해 백그라운드 스레드에서 연산
    compute(parseStock, data).then((value) {
      _subjectSavedStockList.sink.add(value);
      print(value.length);
    });
  }

  dispose() {
    _subjectSavedStockList.close();
  }

  empty() {}
}

//compute can only take a top-level function
//클래스 내부에서 선언된 함수는 compute 수행안됨
List<SavedStock> parseStock(ByteData data) {
  List<SavedStock> list = [];
  var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  var excel = Excel.decodeBytes(bytes);
  for (var table in excel.tables.keys) {
    //table: sheet
    for (var row in excel.tables[table].rows) {
      //row 행 0열, 1열 출력
      list.add(SavedStock.fromXlsx(row));
    }
  }
  return list;
}

var xlsxBloc = XlsxBloc();
