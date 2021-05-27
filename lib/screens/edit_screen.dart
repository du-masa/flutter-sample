import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moor/ffi.dart';
import 'package:my_flash_card/db/database.dart';
import 'package:my_flash_card/main.dart';
import 'package:my_flash_card/screens/word_list_screen.dart';

import 'package:sqlite3/src/api/exception.dart';

enum EditStatus {
  ADD,
  EDIT,
}

class EditScreen extends StatefulWidget {
  final EditStatus editStatus;
  final Word? word;

  EditScreen({required this.editStatus, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";

  bool _isQuestionEnabled = true;

  @override
  void initState() {
    super.initState();

    if (widget.editStatus == EditStatus.ADD) {
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
      _isQuestionEnabled = true;
    } else {
      _titleText = "登録した単語の修正";
      questionController.text = widget.word!.strQuestion;
      answerController.text = widget.word!.strAnswer;
      _isQuestionEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWardScreen(context),
      child: Scaffold(
          appBar: AppBar(
            title: Text(_titleText),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.done),
                tooltip: "登録",
                onPressed: _onWordRegister,
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.0),
                Center(
                  child: Text(
                    "問題と答えを入力して「登録」ボタンを押してください",
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                SizedBox(height: 30.0),
                _questionInputPart(),
                SizedBox(height: 80.0),
                _answerInputPart()
              ],
            ),
          )),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 10.0),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Text(
            "答え",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Future<bool> _backToWardScreen(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));

    return Future.value(false);
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
          msg: "問題と回答の両方を入力しないと登録できません",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    var word = Word(
      strQuestion: questionController.text,
      strAnswer: answerController.text,
      isMemorized: false,
    );

    try {
      await database.addWord(word);

      questionController.clear();
      answerController.clear();
      // TODO登録完了メッセージ

      Fluttertoast.showToast(
          msg: "登録完了しました",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
    } on SqliteException catch (e) {
      Fluttertoast.showToast(
          msg: "既に登録済みの単語です",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM
      );
    }
  }

  void _onWordRegister() {
    if (widget.editStatus == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Fluttertoast.showToast(
          msg: "問題と回答の両方を入力しないと登録できません",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM
      );
      return;
    }

    var word = widget.word
        !.copyWith(strAnswer: answerController.text, isMemorized: false);

    try {
      await database.updateWord(word);

      _backToWardScreen(context);
    } on SqliteException catch (e) {
      Fluttertoast.showToast(
          msg: "何らかの理由で更新できませんでした",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
    }
  }
}
