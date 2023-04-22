import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserNamePage extends StatefulWidget {
  const UserNamePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UserNamePageState createState() => _UserNamePageState();
}

class _UserNamePageState extends State<UserNamePage> {
  String infoText = '';
  String user_name = '';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(227, 132, 255, 1),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'あなたのなまえは？',
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
                    hintText: 'ユーザーネーム',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      user_name = value;
                    });
                  },
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
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId!.uid)
                      .set({
                    'user_name': user_name,
                    'email': email,
                    'time': DateTime.now()
                  }, SetOptions(merge: true));
                  Navigator.pushReplacementNamed(context, '/profile_image');
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
