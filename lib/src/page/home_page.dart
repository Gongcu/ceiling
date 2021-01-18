import 'package:ceiling/src/db/MyStockDBHelper.dart';
import 'package:ceiling/src/page/add_my_stock_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_words/english_words.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/bloc.dart';
import '../model/Stock.dart';
import '../model/News.dart';
import '../model/Index.dart';
import '../model/MyStock.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

final dummyImages = [
  'https://cdn.pixabay.com/photo/2016/12/13/22/15/chart-1905225__340.jpg',
  'https://cdn.pixabay.com/photo/2016/12/13/22/15/chart-1905224__340.jpg',
  'https://cdn.pixabay.com/photo/2016/11/27/21/42/stock-1863880__340.jpg',
];

final imagePath = [
  'assets/chart3.jpg',
  'assets/chart2.jpg',
  'assets/chart1.jpg',
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool modifyAvailable = true;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildGuideLineText('Domestic index', Icons.bar_chart, false),
        _buildIndexTab(),
        Divider(),
        //_buildGuideLineText('News', Icons.my_library_books, false),
        //_buildNewsTab(),
        //Divider(),
        _buildGuideLineText('My Tickers', Icons.money, true),
        _buildMyStocksLayout(),
        Divider(),
        _buildGuideLineText('Popular Tickers', Icons.legend_toggle, false),
        _buildBottom(),
      ],
    );
  }

  Widget _buildGuideLineText(String value, IconData icon, bool button) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.w600)),
          Icon(icon, size: 30),
          Spacer(),
          if (button)
            IconButton(
                icon: Icon(Icons.addchart),
                onPressed: () {
                  Get.to(
                    AddMyStockPage(),
                    transition: Transition.zoom,
                    duration: Duration(milliseconds: 400),
                  );
                }), //
        ],
      ),
    );
  }

  /**
   *  Start TOP Layout
   */
  Widget _buildIndexTab() {
    return StreamBuilder<List<Index>>(
        stream: bloc.indexObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0)
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 0.7,
                    autoPlay: true,
                    scrollDirection: Axis.vertical,
                  ),
                  items: _buildIndexContainerList(snapshot.data)),
            );
          else
            return Container(
              //margin: EdgeInsets.symmetric(vertical: 125),
              child: myCircularIndicator(),
            );
        });
  }

  List<Widget> _buildIndexContainerList(List<Index> list) {
    return List.generate(list.length, (index) {
      var isIncrement =
          list[index].percent.substring(0, 1) == '+' ? true : false;
      return Container(
          margin: EdgeInsets.symmetric(vertical: 10.0), //아이템별 마진
          child: Stack(
            children: [
              ClipRRect(
                //위젯을 둥근 사각형으로 자르는 위젯
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath[index % 3],
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width, //기기 가로 크기
                  height: 200,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(4),
                  color: Colors.black.withOpacity(0.6),
                  width: double.infinity, //match_parent
                  height: double.infinity, //match_parent
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        list[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            list[index].point,
                            style: TextStyle(
                              color: isIncrement ? Colors.red : Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            list[index].rate,
                            style: TextStyle(
                              color: isIncrement ? Colors.red : Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            list[index].percent,
                            style: TextStyle(
                              color: isIncrement ? Colors.red : Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ));
    });
  }

  /**
   * Start MyStock Layout
   */
  Widget _buildMyStocksLayout() {
    return StreamBuilder<List<MyStock>>(
        stream: bloc.myStockObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: _buildMyStockTile(snapshot.data),
            );
          } else {
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.all(5),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[200],
                        highlightColor: Colors.grey[100],
                        child: ListTile(
                          tileColor: Colors.grey[200],
                        ),
                      ),
                    ));
          }
        });
  }

  List<Widget> _buildMyStockTile(List<MyStock> items) {
    return List.generate(items.length, (index) {
      bool isNegative =
          (items[index].currPrice - items[index].buying).isNegative;
      return Dismissible(
        key: Key(items[index].id.toString()),
        onDismissed: (direction) async {
          MyStockDBHelper().deleteData(items[index]);
          Get.snackbar('삭제', '${items[index].enterprise}가 삭제되었습니다.',
              backgroundColor: Colors.white.withAlpha(230));
        },
        confirmDismiss: (direction) async {
          return await showConfirmDialog();
        },
        background: Container(
          color: Colors.grey[200],
        ),
        child: ListTile(
          leading: isNegative
              ? Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                )
              : Icon(Icons.arrow_drop_up, color: Colors.red),
          title: Text(items[index].enterprise),
          trailing: Text(
            '${items[index].rate.toString()}%',
            style: TextStyle(color: isNegative ? Colors.blue : Colors.red),
          ),
          onTap: () {
            myStockInfo(items[index]);
          },
        ),
      );
    });
  }

  Future<bool> showConfirmDialog() {
    return showGeneralDialog(
      context: context,
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {},
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                title: Text('해당 주식을 삭제하시겠습니까?'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('네'),
                    onPressed: () {
                      Get.back(result: true);
                    },
                  ),
                  FlatButton(
                    child: const Text('아니오'),
                    onPressed: () {
                      Get.back(result: false);
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  void myStockInfo(MyStock item) {
    bool isNegative = item.rate.isNegative;
    TextEditingController _tc1 = TextEditingController();
    TextEditingController _tc2 = TextEditingController();
    showGeneralDialog(
      context: context,
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {},
      transitionBuilder: (context, a1, a2, widget) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.enterprise,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${item.symbol}',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  content: Wrap(
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (modifyAvailable) Text('매입가'),
                          if (modifyAvailable)
                            Text('${item.buying}',
                                style: TextStyle(color: Colors.black87))
                          else
                            Expanded(
                              child: TextField(
                                controller: _tc1,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[200])),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[200])),
                                    labelText: '매입가를 입력하세요'),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('현재가'),
                          Text('${item.currPrice}',
                              style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (modifyAvailable) Text('수량'),
                          if (modifyAvailable)
                            Text('${item.stockCount}',
                                style: TextStyle(color: Colors.black87))
                          else
                            Expanded(
                              child: TextField(
                                controller: _tc2,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[200])),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[200])),
                                    labelText: '매입 수량을 입력하세요'),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('수익률'),
                          Row(
                            children: [
                              isNegative
                                  ? Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue,
                                    )
                                  : Icon(Icons.arrow_drop_up,
                                      color: Colors.red),
                              Text(
                                '${item.rate}',
                                style: TextStyle(
                                    color:
                                        isNegative ? Colors.blue : Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('평가금액'),
                          Text(
                              (item.stockCount * item.buying)
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                  color:
                                      isNegative ? Colors.blue : Colors.red)),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    FlatButton(
                      child: Text(modifyAvailable ? '수정' : '저장',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () {
                        setState(() {
                          if (modifyAvailable == false) {
                            //save clicked
                            if (_tc1.text.isNum &&
                                _tc2.text.isNum &&
                                !double.parse(_tc1.text).isNegative &&
                                !int.parse(_tc2.text).isNegative) {
                              item.buying = double.parse(_tc1.text);
                              item.stockCount = int.parse(_tc2.text);
                              MyStockDBHelper().updateData(item).then((value) {
                                if (value == 1) Get.back();
                                Get.snackbar(
                                    value == 1 ? '수정 완료' : '오류',
                                    value == 1
                                        ? '${item.enterprise} 정보 변경이 완료되었습니다.'
                                        : '정상적인 값을 입력하세요.',
                                    backgroundColor:
                                        Colors.white.withAlpha(230));
                              });
                            } else {
                              Get.snackbar('오류', '정상적인 값을 입력하세요.',
                                  backgroundColor: Colors.white.withAlpha(230));
                            }
                          }
                          modifyAvailable = !modifyAvailable;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text(modifyAvailable ? '확인' : '취소',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () {
                        modifyAvailable = true;
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /**
   *  Start MIDDLE Layout
   */
  Widget _buildNewsTab() {
    return StreamBuilder<List<News>>(
        stream: bloc.newsObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0)
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: CarouselSlider(
                  options: CarouselOptions(height: 250, autoPlay: true),
                  items: _buildImageContainerList(snapshot.data)),
            );
          else
            return Container(
              margin: EdgeInsets.symmetric(vertical: 125),
              child: myCircularIndicator(),
            );
        });
  }

  List<Widget> _buildImageContainerList(List<News> list) {
    return List.generate(
        list.length,
        (index) => GestureDetector(
            onTap: () {
              //Get.to(ServicePage(url: list[index].url));
            },
            child: Container(
                width: MediaQuery.of(context).size.width, //기기 가로 크기
                margin: EdgeInsets.symmetric(horizontal: 5.0), //아이템별 마진
                child: Stack(
                  children: [
                    ClipRRect(
                      //위젯을 둥근 사각형으로 자르는 위젯
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: list[index].src,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width, //기기 가로 크기
                        height: 250,
                        placeholder: (context, url) => myCircularIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                        padding: EdgeInsets.all(4),
                        color: Colors.white.withOpacity(0.8),
                        width: double.infinity, //match_parent

                        child: Text(
                          list[index].title,
                          style: TextStyle(backgroundColor: Colors.transparent),
                        ),
                      ),
                    )
                  ],
                ))));
  }

  /**
   *  Start Bottom Layout
   */
  Widget _buildBottom() {
    return StreamBuilder<List<Stock>>(
        stream: bloc.stockObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length != 0)
            return ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: _buildTile(snapshot.data),
            );
          else
            return Container(
              margin: EdgeInsets.symmetric(vertical: 50),
              child: myCircularIndicator(),
            );
        });
  }

  List<Widget> _buildTile(List<Stock> stocks) {
    return List.generate(
        stocks.length,
        (i) => ListTile(
            leading: Text(
              stocks[i].rank.toString(),
              style: TextStyle(height: 1.5),
            ),
            title: Text(stocks[i].enterprise),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(stocks[i].price,
                    style: TextStyle(
                      color: stocks[i].isIncrement ? Colors.red : Colors.blue,
                    )),
                bloc.stocks[i].isIncrement
                    ? Icon(Icons.arrow_drop_up, color: Colors.red, size: 20)
                    : Icon(Icons.arrow_drop_down, color: Colors.blue, size: 20),
              ],
            )));
  }

  Widget myCircularIndicator() {
    return Center(
        child: SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Colors.green[200],
        ),
      ),
    ));
  }
}
