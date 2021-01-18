import 'package:ceiling/src/bloc/xlsx_bloc.dart';
import 'package:ceiling/src/model/MyStock.dart';
import 'package:flutter/material.dart';
import '../model/SavedStock.dart';
import '../db/MyStockDBHelper.dart';
import 'package:get/get.dart';

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
        if (_searchText.isBlank) return Container(color: Colors.white);
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
                showBottomSheet(searchedList[index]);
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

  void showBottomSheet(SavedStock selectedItem) {
    TextEditingController _tc1 = TextEditingController();
    TextEditingController _tc2 = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '보유한 주식 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _tc1,
              maxLines: 1,
              keyboardType: TextInputType.numberWithOptions(signed: false),
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[200])),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[200])),
                  labelText: '보유 수량을 입력하세요.'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _tc2,
              maxLines: 1,
              keyboardType: TextInputType.numberWithOptions(signed: false),
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200])),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[200])),
                labelText: selectedItem.ticker.substring(
                            selectedItem.ticker.length - 2,
                            selectedItem.ticker.length) ==
                        'kr'
                    ? '매수가를 입력하세요 (단위:원화)'
                    : '매수가를 입력하세요 (단위:USD)',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FlatButton(
                  child: Text(
                    '확인',
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    if (_tc1.text.isNum &&
                        _tc2.text.isNum &&
                        !int.parse(_tc1.text).isNegative &&
                        !double.parse(_tc2.text).isNegative) {
                      MyStockDBHelper().insertData(MyStock(
                          enterprise: selectedItem.enterprise,
                          symbol: selectedItem.ticker,
                          stockCount: int.parse(_tc1.text),
                          buying: double.parse(_tc2.text)));
                      Get.back();
                      Get.snackbar('알림', '${selectedItem.enterprise}가 추가되었습니다.',
                          backgroundColor: Colors.white.withAlpha(230));
                    } else {
                      Get.snackbar('오류', '정상적인 값을 입력하세요.',
                          backgroundColor: Colors.white.withAlpha(230));
                    }
                  },
                ),
                FlatButton(
                  child: Text(
                    '취소',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => Get.back(),
                )
              ],
            )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isScrollControlled: true,
    );
  }
}
