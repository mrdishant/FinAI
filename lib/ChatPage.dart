import 'dart:convert' as convert;
import 'dart:io';
import 'package:financial_ai/LoadingDialog.dart';
import 'package:financial_ai/Util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Chatpage extends StatefulWidget {
  String fileName;
  String? user;

  Chatpage(this.fileName, {this.user});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  List messages = [];

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeech();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        leading: CloseButton(),
        title: Column(
          children: [
            Text("Chat with FinAI", style: TextStyle(fontSize: 22)),
            widget.user == null
                ? Container()
                : Text("for: ${widget.user}", style: TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message["sender"] == "user";

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.purple[100] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft:
                                isUser ? Radius.circular(15) : Radius.zero,
                            bottomRight:
                                isUser ? Radius.zero : Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          message["text"]!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                  itemCount: messages.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: TextField(
                          controller: messageController,
                          onSubmitted: (context) {
                            sendQuery();
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "Message...",
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_speechEnabled?CupertinoIcons.mic_circle_fill:CupertinoIcons.mic_circle
                          , color: _speechEnabled?Colors.green:Colors.grey,
                      ),
                      onPressed: () {
                        startListening();
                      },
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.arrow_up_circle_fill),
                      onPressed: () {
                        sendQuery();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendQuery() async {
    if (messageController.text.isEmpty) {
      return;
    }
    // messages.add({"text": messageController.text, "sender": "user"});
    String url_string =
        base_url +
        'query?q=' +
        messageController.text +
        "&f=" +
        widget.fileName;
    if (widget.user != null) {
      url_string = url_string + "&user=" + widget.user!;
    }
    var url = Uri.parse(url_string);

    messageController.clear();
    LoadingDialog.show(context,message: "Analyzing...");
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      messages = jsonResponse['messages'];
      LoadingDialog.dismiss(context);
      setState(() {});
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    setState(() {});
  }

  void fetchMessages() async {
    var url = Uri.parse(base_url + 'messages?q=' + widget.fileName);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      messages = jsonResponse['messages'];
      setState(() {});
      _scrollToBottom();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // Use animateTo if you want smooth scrolling
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.easeOut,
    // );
  }

  // Get your API key from the Deepgram console if you don't have one https://console.deepgram.com/
  // String apiKey = "c7b8eddde1347a0bfaa8edf15269db2c7a9646c7";

  stt.SpeechToText speech = stt.SpeechToText();
  bool _speechEnabled = false;

  /// This has to happen only once per app
  void _initSpeech() async {
    await speech.initialize();
    setState(() {});
  }

  void startListening() async {
    if (_speechEnabled) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await speech.listen(onResult: _onSpeechResult);
    _speechEnabled = true;
    // LoadingDialog.show(context, message: "listening", barrierDismissible: true);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await speech.stop();
    _speechEnabled = false;
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // _lastWords = result.recognizedWords;
      messageController.text = result.recognizedWords;
      print(result.recognizedWords);
    });
  }
}
