import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_flash_card/db/database.dart';

import 'package:my_flash_card/main.dart';
import 'edit_screen.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordList = [];

  bool _isSorted = false;

  @override
  void initState() {
    super.initState();

    _getAllWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("単語一覧"),
        actions: [
          IconButton(
            onPressed: _isSorted ? _getAllWords : _onSortWords,
            icon: Icon(Icons.sort),
            tooltip: "暗記済みが下に来るようにソートします",
          )
        ],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startWordListScreen(context),
        child: Icon(Icons.add),
        tooltip: "新しい単語の登録",
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _wordListWidget(),
      ),
    );
  }

  _startWordListScreen(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(editStatus: EditStatus.ADD)));
  }

  void _getAllWords() async {
    _wordList = await database.allWords;
    setState(() {
      _isSorted = false;
    });
  }

  void _onSortWords() async {
    _wordList = await database.allWordsSorted;
    setState(() {
      _isSorted = true;
    });
  }

  Widget _wordListWidget() {
    return ListView.builder(
      itemCount: _wordList.length,
      itemBuilder: (context, int position) => _wordItem(position),
    );
  }

  Widget _wordItem(int position) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.grey.shade800,
      child: ListTile(
        title: Text("${_wordList[position].strQuestion}"),
        subtitle: Text("${_wordList[position].strAnswer}",
            style: TextStyle(fontFamily: "Mont")),
        trailing:
            _wordList[position].isMemorized ? Icon(Icons.check_circle) : null,
        onLongPress: () => _deleteWord(_wordList[position]),
        onTap: () => _editWord(_wordList[position]),
      ),
    );
  }

  _deleteWord(Word selectedWord) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(selectedWord.strQuestion),
        content: Text("削除してもいいですか？"),
        actions: [
          TextButton(
            onPressed: () async {
              await database.deleteWord(selectedWord);
              Fluttertoast.showToast(
                  msg: "削除が完了しました", toastLength: Toast.LENGTH_LONG);
              _getAllWords();
              Navigator.pop(context);
            },
            child: Text("はい"),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("いいえ"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
          )
        ],
      ),
    );
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditScreen(editStatus: EditStatus.EDIT, word: selectedWord),
        ));
  }
}
