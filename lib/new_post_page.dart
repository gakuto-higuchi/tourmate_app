import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourmate/post_map_page.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images;
  List<LatLng> _pickedLocations = [];
  List<String> _pickedNames = []; // New property to store picked names
  List<String> _categories = ["カフェ", "デート", "気軽に遊ぶ", "おしゃれなお店", "その他"];
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('appbarいらんくね？'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '投稿する写真を入れてね',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Add photo button
                TextButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('写真を選択してください'),
                ),
                // Display selected photos
                _images != null
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _images!
                            .map((image) => Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      )
                    : Container(),
                SizedBox(height: 16),
                Text(
                  '投稿したい位置を入れてね(タップしたらできるよ)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Add location button
                TextButton.icon(
                  onPressed: _selectLocation,
                  icon: const Icon(Icons.add_location),
                  label: const Text('位置を選択してください'),
                ),
                // Display picked locations
                if (_pickedLocations.isNotEmpty)
                  Text(
                      'Locations: ${_pickedLocations.map((location) => '(${location.latitude}, ${location.longitude})').join(', ')}'),
                SizedBox(height: 16),
                Text(
                  'カテゴリ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Select categories
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map((category) => ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategories.contains(category),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'コメント内容',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Comment input
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'コメントをここに入力してください',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'コメント入れてくれやで';
                    }
                    return null;
                  },
                  maxLines: null,
                ),
                SizedBox(height: 16),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text('投稿'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _images = images;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${images.length}枚の写真が追加されました')), // Provide feedback
      );
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPostMap(),
      ),
    );

    if (result != null && result is List<List>) {
      setState(() {
        _pickedLocations = result[0].cast<LatLng>();
        _pickedNames = result[1].cast<String>();
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _images != null &&
        _pickedLocations.isNotEmpty &&
        _pickedNames.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('posts')
          .doc();

      // Save post details to Firestore
      await docRef.set({
        'comment': _commentController.text,
        'createdAt': Timestamp.now(),
        'categories': _selectedCategories,
        'locations': _pickedLocations
            .asMap()
            .entries
            .map((entry) => {
                  'latitude': entry.value.latitude,
                  'longitude': entry.value.longitude,
                  'name': _pickedNames[entry.key],
                })
            .toList(),
      });

      // Save photos to Firebase Storage
      // ... (Firebase Storage への画像のアップロードコードをここに追加)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿できたよ')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('全部入力してくれやで')),
      );
    }
  }
}
