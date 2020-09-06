import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/Utils/Database.dart';
import 'package:firebase_chat/Widgets/msg_list.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;

  ChatScreen({Key key, @required this.peerId}) : super(key: key);

  @override
  State createState() => ChatScreenState(peerId: peerId);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId});

  String peerId;
  String number;

  List<DocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";
  SharedPreferences prefs;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        print("reach the top");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        print("reach the bottom");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    number = prefs.getString('number');

    if (number.hashCode <= peerId.hashCode) {
      groupChatId = '$number-$peerId';
    } else {
      groupChatId = '$peerId-$number';
    }

    Database.chatWith(peerId, number);

    setState(() {});
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();
      Database.sendMassage(groupChatId, number, peerId, content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] == number) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != number) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    Database.chatWith("", number);
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Database.chatWith("", number);
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back)),
                SizedBox(
                  width: 5,
                ),
                Hero(
                  tag: peerId,
                  child: CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.person),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  peerId,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            )),
        body: Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),
            // Input content
            buildInput(),
          ],
        ),
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildInput() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 5, right: 2, left: 2),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              controller: textEditingController,
              decoration:  InputDecoration(
                  border:  OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  filled: true,
                  hintStyle: new TextStyle(color: Colors.grey[800]),
                  hintText: "Type a massage",
                  fillColor: Colors.grey[100]),
            ),
          ),
          Material(
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => onSendMessage(textEditingController.text),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green)));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => MsgList(
                      document: snapshot.data.documents[index],
                      number: number,
                    ),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
