import 'package:flutter/material.dart';
import 'page/home_page.dart';
import 'page/my_info_page.dart';
import 'page/service_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _page = 0;
  var _pageList = [HomePage(), ServicePage(), MyInfoPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pageList[_page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        currentIndex: _page,
        items: <BottomNavigationBarItem>[
          _buildBNBI(Icon(Icons.home), 'home'),
          _buildBNBI(Icon(Icons.assignment), 'service'),
          _buildBNBI(Icon(Icons.account_circle), 'my info'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBNBI(Icon icon, String label) {
    return BottomNavigationBarItem(icon: icon, label: label);
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        '금융 정보',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      actions: [
        IconButton(icon: Icon(Icons.add), onPressed: null),
      ],
    );
  }
}
