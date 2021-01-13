import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:rxdart/rxdart.dart';
import '../network/parser.dart' as parse;
import '../model/News.dart';
import '../model/Stock.dart';
import '../model/Index.dart';

class Bloc {
  List<Stock> stocks = [];
  List<News> newsList = [];
  List<Index> indexs = [];

  Set<WordPair> saved = Set<WordPair>();

  BehaviorSubject<List<Index>> _subjectIndexList;
  BehaviorSubject<List<Stock>> _subjectStockList;
  BehaviorSubject<List<News>> _subjectNewsList;

  Bloc() {
    _subjectIndexList = BehaviorSubject<List<Index>>.seeded(indexs);
    _subjectStockList = BehaviorSubject<List<Stock>>.seeded(stocks);
    _subjectNewsList = BehaviorSubject<List<News>>.seeded(newsList);

    parse.main(stocks);
    parse.getNews(newsList);
    parse.getIndex(indexs);
  }

  get indexObservable => _subjectIndexList.stream;
  get newsObservable => _subjectNewsList.stream;
  get stockObservable => _subjectStockList.stream;

  //broadcast: 스냅샷을 여러 곳으로 보냄
  final _savedContoller = StreamController<Set<WordPair>>.broadcast();

  //get:return type 자동 판단
  get savedStream => _savedContoller.stream;

  addOrRemoveFromSaved(WordPair item) {
    if (saved.contains(item))
      saved.remove(item);
    else
      saved.add(item);

    _savedContoller.sink.add(saved); //변경을 알림 -> 스트림
  }

  successGetStocksInfo() {
    _subjectStockList.sink.add(stocks);
  }

  successGetNewsInfo() {
    _subjectNewsList.sink.add(newsList);
  }

  successGetIndexInfo() {
    _subjectIndexList.sink.add(indexs);
  }

  dispose() {
    _savedContoller.close();

    _subjectIndexList.close();
    _subjectStockList.close();
    _subjectNewsList.close();
  }
}

var bloc = Bloc();
