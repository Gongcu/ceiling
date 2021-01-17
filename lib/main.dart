import 'package:ceiling/src/bloc/xlsx_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'src/my_hompage.dart';
import 'package:get/get.dart';
import './src/bloc/xlsx_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //The reason behind this is you are waiting for some data or running an async function inside main().
  xlsxBloc.empty();
  runApp(MyApp());
}

//빨간줄에서 ctrl+. 누르면 오버라이드 자동 생성 등
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MyHomePage(),
    );
  }
}
