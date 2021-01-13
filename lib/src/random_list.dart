import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'bloc/bloc.dart';
import 'saved.dart';

class RandomWord extends StatefulWidget {
  //상태가 바뀌면 호출됨
  @override
  State<StatefulWidget> createState() => _RandomWordState();
}

//State가 바뀌면 build가 발생
class _RandomWordState extends State<RandomWord> {
  final List<WordPair> _suggestion = <WordPair>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Startup name generator'), actions: <Widget>[
          IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SavedList()));
              })
        ]),
        body: _buildList());
  }

  Widget _buildList() {
    return StreamBuilder<Set<WordPair>>(
        stream: bloc.savedStream,
        builder: (context, snapshot) {
          //데이터가 변경되면 스냅샷
          //특정 뷰에서 ctrl . 하면 streambuilder 생성 가능
          return ListView.builder(itemBuilder: (context, index) {
            if (index.isOdd) return Divider();
            var mIndex = index ~/ 2;

            if (mIndex >= _suggestion.length)
              _suggestion.addAll(generateWordPairs().take(10));

            return _buildTile(snapshot.data, _suggestion[mIndex]);
          });
        });
  }

  Widget _buildTile(Set<WordPair> saved, WordPair pair) {
    final bool isSaved = saved == null ? false : saved.contains(pair);
    return ListTile(
      title: Text(pair.asCamelCase),
      trailing: Icon(isSaved ? Icons.favorite : Icons.favorite_border,
          color: Colors.pink),
      onTap: () {
        bloc.addOrRemoveFromSaved(pair);
      },
    );
  }
}
