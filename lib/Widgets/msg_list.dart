import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MsgList extends StatelessWidget {
  final DocumentSnapshot document;
  final String number;
  MsgList({this.document, this.number});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: document.data()['idFrom'] == number ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
          decoration: BoxDecoration(
              color: document.data()['idFrom'] == number ? Colors.yellow[50] : Colors.white,
              borderRadius: BorderRadius.circular(8.0)),
          margin: document.data()['idFrom'] == number
              ? EdgeInsets.only(right: 10.0, bottom: 10.0)
              : EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                DateFormat('Hm').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(
                    document.data()['timestamp'],
                  ),
                )),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
