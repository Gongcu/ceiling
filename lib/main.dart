import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'src/my_hompage.dart';

void main() => runApp(MyApp());

//빨간줄에서 ctrl+. 누르면 오버라이드 자동 생성 등
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
