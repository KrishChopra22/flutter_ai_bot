import 'dart:convert';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/messages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI bot',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI bot'),
      ),
      body: Container(
        child: Column(children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.teal.shade800,
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
                IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          )
        ]),
      ),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      print('No Message found');
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      Uri uri = Uri.parse("https://demo-bot.skyadav.repl.co/api/$text");
      print("Api Get Call : $uri");
      final responsed = await http.get(uri);
      String responseBody = utf8.decoder.convert(responsed.bodyBytes);
      final Map<String, dynamic> responseJson = json.decode(responseBody);
      print("Response : $responseJson");

      setState(() {
        addMessage(Message(text: DialogText(text: [responseJson['response']])));
      });

      // DetectIntentResponse response = await dialogFlowtter.detectIntent(
      //     queryInput: QueryInput(text: TextInput(text: text)));
      // if (response.message == null) return;
      // setState(() {
      //   addMessage(response.message!);
      // });
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
  }
}
