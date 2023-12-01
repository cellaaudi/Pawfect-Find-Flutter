import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResultPage();
  }
}

class _ResultPage extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> result = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String resultText = 'Result Page\n\n';
    for (var entry in result.entries) {
      resultText += '${entry.key}: ${entry.value}\n';
    }

    List<Widget> listResults() {
      List<Widget> temp = [];
      
      for (var r in result.entries) {
        Widget w = Card(
          child: Text("${r.value}"),
        );

        temp.add(w);
      }

      return temp;
    }

    return Scaffold(
      body: Center(
        child: Text(
          resultText,
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
      ),
    );

    // return Scaffold(
    //     body: SingleChildScrollView(
    //   child: Column(children: [
    //     Text("Your result :"),
    //     ListView(
    //       shrinkWrap: true,
    //       physics: NeverScrollableScrollPhysics(),
    //       children: listResults(),
    //     ),
    //     Divider(
    //       height: 100,
    //     )
    //   ]),
    // ));
  }
}