import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static Future<void> setUserNumber(String number) async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(number)
        .set({"number": number, "pushToken": "", "chattingWith": ""});
  }

  static getLastMsg(String groupChatId) async* {
    yield FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .snapshots()
        .last;
  }

  static chatWith(id, number) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(number)
        .update({'chattingWith': id});
  }

  static sendMassage(groupChatId, number, peerId, content) {
    var documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        {
          'idFrom': number,
          'idTo': peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
        },
      );
    });
  }

   Future<bool> checkdata(title) {
    return FirebaseFirestore.instance
        .collection("messages")
        .get()
        .then((value) async {
      return value.docs.any((element) => element.id == title);
    });
  }
}
