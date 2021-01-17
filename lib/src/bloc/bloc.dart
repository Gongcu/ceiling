import 'package:rxdart/rxdart.dart';
import '../network/parser.dart' as parse;
import '../model/News.dart';
import '../model/Stock.dart';
import '../model/Index.dart';
import '../model/MyStock.dart';
import '../db/MyStockDBHelper.dart';
import 'package:flutter/foundation.dart';

class Bloc {
  List<Stock> stocks = [];
  List<News> newsList = [];
  List<Index> indexs = [];
  List<MyStock> mStocks = [];
  List<MyStock> updatedMyStocks = [];

  BehaviorSubject<List<Index>> _subjectIndexList;
  BehaviorSubject<List<Stock>> _subjectStockList;
  BehaviorSubject<List<News>> _subjectNewsList;
  BehaviorSubject<List<MyStock>> _subjectMyStockList;
  BehaviorSubject<List<MyStock>> _subjectUpdatedMyStockList;

  Bloc() {
    _subjectIndexList = BehaviorSubject<List<Index>>.seeded(indexs);
    _subjectStockList = BehaviorSubject<List<Stock>>.seeded(stocks);
    _subjectNewsList = BehaviorSubject<List<News>>.seeded(newsList);
    _subjectMyStockList = BehaviorSubject<List<MyStock>>.seeded(mStocks);
    _subjectUpdatedMyStockList =
        BehaviorSubject<List<MyStock>>.seeded(updatedMyStocks);

    networking();

    MyStockDBHelper().getAll().then((value) {
      if (value.length == 0)
        successGetMyStockInfo([]);
      else {
        mStocks = value;
        parse.getMyStockInfo(mStocks, updatedMyStocks);
      }
    });
  }

  get indexObservable => _subjectIndexList.stream;
  get newsObservable => _subjectNewsList.stream;
  get stockObservable => _subjectStockList.stream;
  get myStockObservable => _subjectMyStockList.stream;

  successGetStocksInfo() {
    _subjectStockList.sink.add(stocks);
  }

  successGetNewsInfo() {
    _subjectNewsList.sink.add(newsList);
  }

  successGetIndexInfo() {
    _subjectIndexList.sink.add(indexs);
  }

  successGetMyStockInfo(List<MyStock> myStocks) {
    _subjectMyStockList.sink.add(myStocks);
  }

  insertFromMyStock(MyStock item) {
    mStocks.add(item);
    parse.getMyStockInfo(mStocks, updatedMyStocks);
  }

  deleteFromMyStock(MyStock item) {
    updatedMyStocks.remove(item);
    _subjectMyStockList.sink.add(updatedMyStocks);
  }

  networking() async {
    parse.main(stocks);
    parse.getIndex(indexs);
    parse.getForeginIndex(indexs);
  }

  dispose() {
    _subjectIndexList.close();
    _subjectStockList.close();
    _subjectNewsList.close();
    _subjectMyStockList.close();
    _subjectUpdatedMyStockList.close();
  }
}

var bloc = Bloc();
