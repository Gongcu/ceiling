import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_words/english_words.dart';
import '../bloc/bloc.dart';
import '../model/Stock.dart';
import '../model/News.dart';
import '../model/Index.dart';
import 'service_page.dart';

final dummyImages = [
  'https://cdn.pixabay.com/photo/2014/07/01/12/35/taxi-381233__340.jpg',
  'https://cdn.pixabay.com/photo/2014/01/04/13/34/taxi-238478__340.jpg',
  'https://cdn.pixabay.com/photo/2017/01/28/02/24/japan-2014617__340.jpg',
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
        _buildGuideLineText('Stock Price', Icons.attach_money),
        _buildTop(),
        Divider(),
        _buildGuideLineText('News', Icons.my_library_books),
        _buildMiddle(),
        Divider(),
        _buildGuideLineText('Popular Stocks', Icons.legend_toggle),
        _buildBottom(),
      ],
    );
  }

  Widget _buildGuideLineText(String value, IconData icon) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: Row(
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.w600)),
          Icon(icon, size: 30)
        ],
      ),
    );
  }

  /**
   *  Start TOP Layout
   */
  Widget _buildTop() {
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
                  _buildIndexContainer(snapshot.data[0]),
                  _buildIndexContainer(snapshot.data[1]),
                  _buildIndexContainer(snapshot.data[2]),
                  _buildIndexContainer(snapshot.data[3]),
                ],
              ),
            );
          return Container(
            margin: EdgeInsets.symmetric(vertical: mWidth / 2),
            child: Center(
                child: SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.green[200])),
            )),
          );
        });
  }

  Widget _buildIndexContainer(Index item) {
    final mWidth = MediaQuery.of(context).size.width / 3;
    final isIncrement = item.rate.substring(0, 1) == '+' ? true : false;
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
  Widget _buildMiddle() {
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
              margin: EdgeInsets.symmetric(vertical: 126),
              child: Center(
                  child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.green[200])),
              )),
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
                      child: Image.network(
                        list[index].src,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width, //기기 가로 크기
                        height: 250,
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
              child: Center(
                  child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.green[200])),
              )),
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
}
