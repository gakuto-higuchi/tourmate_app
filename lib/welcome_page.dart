import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tourmate/components/componets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(134, 93, 255, 1),
      // ignore: avoid_unnecessary_containers
      body: Column(
        children: [
          Container(
            height: 370,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'TourMate',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 70),
            child: SigninContainer(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: LoginContainer(),
          ),
          Container(
            height: 160,
            width: 225,
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () {},
              child: const Text('利用することで利用規約・プライバシーポリシーに同意したものとします。'),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 10,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO 背景を絵を追加した画像を作成し、背景にする。