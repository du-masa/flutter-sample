import 'package:flutter/material.dart';
import 'package:my_flash_card/db/database.dart';
import 'package:my_flash_card/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludeMemorizedWords;

  TestScreen({required this.isIncludeMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;

  String _txtQuestion = "";

  String _txtAnswer = "";

  bool _isMemorized = false;

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;

  List<Word> _textDataList = [];

  late TestStatus _textStatus;
  late Word _currentWord;

  int _index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTestWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("かくにんテスト"),
          centerTitle: true,
        ),
        floatingActionButton: _isFabVisible ? FloatingActionButton(
          onPressed: _goNextStatus,
          child: Icon(Icons.skip_next),
          tooltip: "次へ進む",
        ) : null,
        body: Stack(
          children: [
            Column(children: [
              SizedBox(height: 10.0),
              _numberOfQuestionPart(),
              SizedBox(height: 20.0),
              _questionCardPart(),
              SizedBox(height: 20.0),
              _answerCardPart(),
              SizedBox(height: 20.0),
              _isMemorizedCheckPart(),
            ]),
            _endMessage(),
          ],
        ));
  }

  Widget _numberOfQuestionPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("残り問題数", style: TextStyle(fontSize: 12.0)),
        SizedBox(width: 15.0),
        Text(_numberOfQuestion.toString(), style: TextStyle(fontSize: 14.0)),
      ],
    );
  }

  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _txtQuestion,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
          )
        ],
      );
    } else {
      return Container();
    }

  }

  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _txtAnswer,
            style: TextStyle(fontSize: 20.0),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CheckboxListTile(
          title: Text("暗記済みにする場合はチェックを入れてください", style: TextStyle(fontSize: 12.0)),
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value!;
            });
          },
        ),
      );
    } else {
      return Container();
    }

  }

  void _getTestWords() async {
    if (widget.isIncludeMemorizedWords) {
      _textDataList = await database.allWords;
    } else {
      _textDataList = await database.allWordsExcludeMemorised;
    }

    _textStatus = TestStatus.BEFORE_START;
    _textDataList.shuffle();

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _numberOfQuestion = _textDataList.length;
      _index = 0;
    });
  }

  _goNextStatus() async {
    switch (_textStatus) {
      case TestStatus.BEFORE_START:
        _textStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _textStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        _updateMemorisedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _textStatus = TestStatus.FINISHED;
            _isFabVisible = false;
          });
        } else {
          _textStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _showQuestion() {
    _currentWord = _textDataList[_index];

    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _txtQuestion = _currentWord.strQuestion;
    });

    _numberOfQuestion -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFabVisible = true;
      _txtAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  void _updateMemorisedFlag() {
    var word = Word(strAnswer: _currentWord.strAnswer, strQuestion: _currentWord.strQuestion, isMemorized: _isMemorized);
    database.updateWord(word);
  }

  Widget _endMessage() {
    if (_textStatus == TestStatus.FINISHED) {
      return Center(child: Text("テスト終了", style: TextStyle(fontSize: 50.0, color: Colors.red)));
    } else {
      return Container();
    }
  }
}
