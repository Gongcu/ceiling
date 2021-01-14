import 'package:flutter/material.dart';
import '../bloc/xlsx_bloc.dart';

class MyInfoPage extends StatefulWidget {
  MyInfoPage() {
    xlsxBloc.empty();
  }
  @override
  _MyInfoPageState createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('My Informent'),
    );
  }
}
