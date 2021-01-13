import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'bloc/bloc.dart';

class SavedList extends StatefulWidget {
  @override
  _SavedListState createState() => _SavedListState();
}

class _SavedListState extends State<SavedList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved'),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return StreamBuilder<Set<WordPair>>(
        stream: bloc.savedStream,
        initialData: bloc.saved,
        builder: (context, snapshot) {
          return ListView.builder(
            itemBuilder: (context, index) {
              if (index.isOdd) return Divider();
              var mIndex = index ~/ 2;
              return _buildTile(snapshot.data.toList()[mIndex]);
            },
            itemCount: snapshot.data.length * 2,
          );
        });
  }

  Widget _buildTile(WordPair pair) {
    return ListTile(
      title: Text(pair.asCamelCase),
      onTap: () {
        bloc.addOrRemoveFromSaved(pair);
      },
    );
  }
}
