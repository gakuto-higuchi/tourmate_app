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
  LatLng? _pickedLocation;
  List<String> _categories = ["カフェ", "デート", "気軽に遊ぶ", "おしゃれなお店", "その他"];
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
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
                  'Add Photo*',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Add photo button
                TextButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Select Photo'),
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
                  'Add Location*',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Add location button
                TextButton.icon(
                  onPressed: _selectLocation,
                  icon: const Icon(Icons.add_location),
                  label: const Text('Select Location'),
                ),
                // Display picked location
                if (_pickedLocation != null)
                  Text(
                      'Location: ${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}'),
                SizedBox(height: 16),
                Text(
                  'Select Categories',
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
                  'Comment*',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Comment input
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add your comment here',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a comment';
                    }
                    return null;
                  },
                ),
                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _submitPost,
                    child: const Text('Submit'),
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
    final pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  Future<void> _selectLocation() async {
// Navigate to GoogleMapPage and get the picked location
// You need to implement the functionality to pick a location in GoogleMapPage and pass the picked location back
    final pickedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => NewPostMap(),
      ),
    );
    if (pickedLocation != null) {
      setState(() {
        _pickedLocation = pickedLocation;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
// Save the post to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final postRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('posts')
            .doc();
        await postRef.set({
          'images': _images!.map((image) => image.path).toList(),
          'location': GeoPoint(
            _pickedLocation!.latitude,
            _pickedLocation!.longitude,
          ),
          'categories': _selectedCategories,
          'comment': _commentController.text,
          'timestamp': Timestamp.now(),
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post submitted successfully')),
        );

        // Navigate back to the previous page
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
      }
    }
  }
}
