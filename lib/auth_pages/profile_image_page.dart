// ignore_for_file: sized_box_for_whitespace

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourmate/auth_pages/user_name_page.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File? _image;
  final _picker = ImagePicker();
  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper()
          .cropImage(sourcePath: pickedFile.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ], uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ]);
      setState(() {
        if (croppedFile != null) {
          _image = File(croppedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像を選択してください'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ユーザログインできていません'),
      ));
      return;
    }

    try {
      //storageに保存
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile_image');
      final uploadTask = await storageRef.putFile(_image!);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      //firestoreに保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${user.uid}')
          .set({'profile_image': imageUrl}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('アイコンを変更しました'),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("アイコンの変更に失敗しましたa: ${e.toString()}"),
        ),
      );
    }
  }

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
              'あなたのアイコンは？',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_image != null)
            CircleAvatar(
              radius: 100,
              backgroundImage: FileImage(_image!),
            )
          else
            IconButton(
              onPressed: _getImage,
              icon: const Icon(Icons.add_a_photo),
              iconSize: 50,
            ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
            child: Container(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadImage,

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
