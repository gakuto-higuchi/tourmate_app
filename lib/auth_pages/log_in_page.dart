import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String infoText = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(227, 132, 255, 1),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'ログインする？',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'メールアドレス',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'パスワード',
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                      obscureText: true,
                      onChanged: (String value) {
                        setState(() {
                          _password = value;
                        });
                      }),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  // ここにエラーの文字が出るはず
                  child: Text(infoText),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
            // ignore: sized_box_for_whitespace
            child: Container(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // ignore: omit_local_variable_types
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    await auth.signInWithEmailAndPassword(
                        email: _email, password: _password);
                    // ignore: use_build_context_synchronously
                    await Navigator.of(context)
                        .pushReplacementNamed('/google_map');
                    // ignore: avoid_catches_without_on_clauses
                  } catch (e) {
                    setState(() {
                      infoText = 'ログインに失敗しました: ${e.toString()}';
                    });
                  }
                },
                // ignore: sort_child_properties_last
                child: const Text('次へ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
