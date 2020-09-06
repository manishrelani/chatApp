import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final DocumentSnapshot document;
  final String number;
  ChatList({this.document, this.number});

  @override
  Widget build(BuildContext context) {
    if (document.data()['number'] == number) {
      return Container();
    } else {
      return Column(
        children: [
          ListTile(
            leading: Hero(
              tag: document.data()['number'],
              child: CircleAvatar(
                radius: 25,
                child: Icon(Icons.person),
              ),
            ),
            title: Text(
              document.data()['number'],
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Divider(
              indent: 50.0,
              color: Colors.grey.withOpacity(0.3),
              height: 18.0,
            ),
          )
        ],
      );
    }
  }
}
