import 'package:flutter/material.dart';
import 'package:my_flash_card/parts/button_with_icon.dart';
import 'package:my_flash_card/screens/test_screen.dart';
import 'package:my_flash_card/screens/word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludeMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(child: Image.asset("assets/images/image_title.png")),
          _titleText(),
          Divider(
            height: 30.0,
            color: Colors.white,
            indent: 8.0,
            endIndent: 8.0,
          ),
          ButtonWithIcon(
            onPressed: () => _startTestScreen(context),
            icon: Icon(Icons.play_arrow),
            label: "確認テストをする",
            color: Colors.brown,
          ),
          SizedBox(
            height: 10.0,
          ),
          _radioButtons(),
          SizedBox(
            height: 30.0,
          ),
          ButtonWithIcon(
            onPressed: () => _startWordListScreen(context),
            icon: Icon(Icons.list),
            label: "単語一覧を見る",
            color: Colors.green,
          ),
          SizedBox(
            height: 60.0,
          ),
          Text("powered by Msasahiko", style: TextStyle(fontFamily: "Mont")),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    ));
  }

  Widget _titleText() {
    return Column(
      children: [
        Text("私だけの単語帳", style: TextStyle(fontSize: 40.0)),
        Text("My Own Fresh Card", style: TextStyle(fontSize: 24.0)),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: [
          RadioListTile(
            value: false,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を含む",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludeMemorizedWords = value;
      print("$valueが選ばれた！");
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(isIncludeMemorizedWords: isIncludeMemorizedWords)));
  }
}
