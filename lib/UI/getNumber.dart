
import 'package:firebase_chat/UI/HomeScreen.dart';
import 'package:firebase_chat/Utils/Database.dart';
import 'package:firebase_chat/Utils/ShareManner.dart';
import 'package:flutter/material.dart';

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  void initState() {
    verify();
    super.initState();
  }

  verify() async {
    ShareMananer.getNumber().then((value) {
      if (value == "" || value == null || value.isEmpty) {
        print("value1 $value");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => GetNumber()));
      } else {
        print("value2$value");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class GetNumber extends StatefulWidget {
  @override
  _GetNumberState createState() => _GetNumberState();
}

class _GetNumberState extends State<GetNumber> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty || value.trim().isEmpty) {
                      return "Enter phone number";
                    }
                    return null;
                  },
                  controller: numberController,
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    icon: Icon(Icons.phone_android),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: MaterialButton(
                    color: Colors.green,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        login();
                      }
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  login() {
    Database.setUserNumber(numberController.text.trim()).then((value) async {
      ShareMananer.setNumber(numberController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => HomeScreen(),
        ),
      );
    });
  }
}
