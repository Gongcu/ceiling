import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:excel/excel.dart';
import '../model/SavedStock.dart';
import 'package:rxdart/rxdart.dart';

final tickersPath = 'assets/excels/tickers.xlsx';
final koreaStockPath = 'assets/excels/korea_stock.xlsx';
final americaStockPath = 'assets/excels/america_stock.xlsx';

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
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      //table: sheet
      for (var row in excel.tables[table].rows) {
        //row 행 0열, 1열 출력
        savedStocks.add(SavedStock.fromXlsx(row));
      }
    }
    /*
    ByteData kdata = await rootBundle.load(koreaStockPath);
    ByteData adata = await rootBundle.load(americaStockPath);

    var kbytes =
        kdata.buffer.asUint8List(kdata.offsetInBytes, kdata.lengthInBytes);
    //var abytes =
    //    adata.buffer.asUint8List(adata.offsetInBytes, adata.lengthInBytes);

    var kexcel = Excel.decodeBytes(kbytes);
    var aexcel = Excel.decodeBytes(abytes);

    print('get xlsx');

    for (var table in kexcel.tables.keys) {
      //table: sheet
      for (var row in kexcel.tables[table].rows) {
        //row 행 0열, 1열 출력
        savedStocks.add(SavedStock.fromXlsx(row));
      }
    }*/
    /*
    for (var table in aexcel.tables.keys) {
      //table: sheet
      for (var row in aexcel.tables[table].rows) {
        //row 행 0열, 1열 출력
        savedStocks.add(SavedStock.fromXlsx(row));
      }
    }*/
    _subjectSavedStockList.sink.add(savedStocks);
  }

  dispose() {
    _subjectSavedStockList.close();
  }

  empty() {}
}

var xlsxBloc = XlsxBloc();
