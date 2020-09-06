import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/Utils/ShareManner.dart';
import 'package:firebase_chat/Widgets/Chat_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'chat.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String number;

  @override
  void initState() {
    setNumber();
    registerNotification();
    configLocalNotification();
    super.initState();
  }

  setNumber() async {
    number = await ShareMananer.getNumber();
    setState(() {});
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    try {
      firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        Platform.isAndroid
            ? showNotification(message['notification'])
            : showNotification(message['aps']['alert']);
        return;
      }, onResume: (Map<String, dynamic> message) {
        print('onResume: ${message['notification']["title"]}');
        return;
      }, onLaunch: (Map<String, dynamic> message) {
        print('onLaunch: ${message['notification']["title"].toString()}');
        return;
      });
    } catch (e) {
      print(e);
    }

    try {
      firebaseMessaging.getToken().then((token) {
        print('token: $token');
        FirebaseFirestore.instance
            .collection('user')
            .doc(number)
            .update({'pushToken': token});
      }).catchError((err) {
        print(err.toString());
      });
    } catch (e) {
      print(e);
    }
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    /* onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload) */

    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /* Future onSelectNotification(String title) async {
    print("payload $title");
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatScreen(
                peerId: title,
              )),
    );
  } */

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.example.firebase_chat' : '',
      'Chat App',
      'description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
      sound:RawResourceAndroidNotificationSound('song'), 
      visibility: NotificationVisibility.Public,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print("ok $message");

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('user').snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            } else {
              return ListView.builder(
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => ChatScreen(
                                  peerId: snapshot.data.documents[index]
                                      .data()['number'],
                                )));
                  },
                  child: ChatList(
                      document: snapshot.data.documents[index], number: number),
                ),
                itemCount: snapshot.data.documents.length,
              );
            }
          },
        ),
      ),
    );
  }
}
