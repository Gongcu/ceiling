import 'package:ceiling/src/bloc/xlsx_bloc.dart';
import 'package:ceiling/src/model/MyStock.dart';
import 'package:flutter/material.dart';
import '../model/SavedStock.dart';
import '../db/MyStockDBHelper.dart';

class AddMyStockPage extends StatefulWidget {
  @override
  _AddMyStockPageState createState() => _AddMyStockPageState();
}

class _AddMyStockPageState extends State<AddMyStockPage> {
  final TextEditingController _filter = TextEditingController();
  FocusNode focusNode = FocusNode(); //현재 위젯에 포커스가 잇는지 확인
  String _searchText = "";

  _AddMyStockPageState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: Row(children: [
              Expanded(
                flex: 6,
                child: TextField(
                    focusNode: focusNode,
                    autofocus: true,
                    style: TextStyle(fontSize: 16),
                    controller: _filter,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[300],
                      ),
                      suffixIcon: focusNode.hasFocus
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.grey[300],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _filter.clear();
                                  _searchText = "";
                                });
                              },
                            )
                          : Container(),
                      hintText: "검색",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    )),
              )
            ]),
          ),
          _buildBody(),
        ],
      ),
    ));
  }

  Widget _buildBody() {
    return StreamBuilder<List<SavedStock>>(
      stream: xlsxBloc.savedStockContoller,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(snapshot.data);
      },
    );
  }

  Widget _buildList(List<SavedStock> savedStock) {
    List<SavedStock> searchedList = [];
    for (var item in savedStock) {
      if (containsIgnoreCase(_searchText, item.enterprise) ||
          containsIgnoreCase(_searchText, item.ticker)) searchedList.add(item);
    }
    return Expanded(
      child: ListView.separated(
        itemCount: searchedList.length,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {
                showInputDialog(searchedList[index]);
              },
              child: ListTile(
                subtitle: Text(searchedList[index].ticker),
                title: Text(searchedList[index].enterprise),
              ));
        },
        separatorBuilder: (contex, index) => Divider(),
      ),
    );
  }

  bool containsIgnoreCase(String s1, String s2) {
    return s2?.toLowerCase().contains(s1?.toLowerCase());
  }

  void showInputDialog(SavedStock selectedItem) {
    TextEditingController _tc1 = TextEditingController();
    TextEditingController _tc2 = TextEditingController();
    showDialog(
        context: context,
        barrierDismissible: false, //다이얼로그 외의 영역 터치 가능 여부
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: Text(
              '보유한 주식 정보',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tc1,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(gapPadding: 8),
                      labelText: '보유 수량을 입력하세요.'),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _tc2,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(gapPadding: 1),
                      labelText: '매수가를 입력하세요'),
                ),
              ],
            ),
            actions: [
              FlatButton(
                child: Text('확인', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () {
                  MyStockDBHelper().insertData(MyStock(
                      enterprise: selectedItem.enterprise,
                      symbol: selectedItem.ticker,
                      stockCount: int.parse(_tc1.text),
                      buying: double.parse(_tc2.text)));
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('취소', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }
}
