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
import 'service_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final List<WordPair> _suggestion = <WordPair>[];

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMyStockPage(),
                    ),
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
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity, //match_parent
                  height: double.infinity, //match_parent
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        list[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        list[index].point,
                        style: TextStyle(
                            color: isIncrement ? Colors.red : Colors.blue),
                      ),
                      Text(
                        list[index].rate,
                        style: TextStyle(
                            color: isIncrement ? Colors.red : Colors.blue),
                      ),
                      Text(
                        list[index].percent,
                        style: TextStyle(
                            color: isIncrement ? Colors.red : Colors.blue),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ));
    });
  }
  /*
  Widget _buildIndexTab() {
    final mWidth = MediaQuery.of(context).size.width / 3;
    return StreamBuilder<List<Index>>(
        stream: bloc.indexObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0)
            return Container(
              height: mWidth,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  for (var item in snapshot.data) _buildIndexContainer(item),
                ],
              ),
            );
          return Container(
            height: mWidth,
            child: myCircularIndicator(),
          );
        });
  }*/

  Widget _buildIndexContainer(Index item) {
    final mWidth = MediaQuery.of(context).size.width / 3;
    final isIncrement = item.percent.substring(0, 1) == '+' ? true : false;
    return Container(
      height: mWidth,
      width: mWidth,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            item.name,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
          ),
          Text(
            item.point,
            style: TextStyle(color: isIncrement ? Colors.red : Colors.blue),
          ),
          Text(
            item.rate,
            style: TextStyle(color: isIncrement ? Colors.red : Colors.blue),
          ),
          Text(
            item.percent,
            style: TextStyle(color: isIncrement ? Colors.red : Colors.blue),
          ),
        ],
      ),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServicePage(url: list[index].url)));
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

  /**
   * Start MyStock Layout
   */
  Widget _buildMyStocksLayout() {
    return StreamBuilder<List<MyStock>>(
        stream: bloc.myStockObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data[0].rate != null) {
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
      bool isNegative = items[index].rate.isNegative;
      return ListTile(
        leading: isNegative
            ? Icon(
                Icons.arrow_drop_down,
                color: Colors.blue,
              )
            : Icon(Icons.arrow_drop_up, color: Colors.red),
        title: Text(items[index].enterprise),
        trailing: Text(
          items[index].rate.toString() + '%',
          style: TextStyle(color: isNegative ? Colors.blue : Colors.red),
        ),
      );
    });
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
