import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/image.dart';
import 'package:petcare_record/pages/auth/login.dart';
import 'package:petcare_record/pages/setting/password.dart';
import 'package:petcare_record/pages/setting/preferences.dart';
import 'package:petcare_record/pages/setting/profile.dart';
import 'package:http/http.dart' as http;

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String firstName = '';
  String email = '';
  String phoneNumber = '';
  String lastName = '';
  String profileImage = '';

  Uint8List? userImage;

  @override
  void initState() {
    fetchUserInfo();
    super.initState();
  }

  Future<void> fetchUserInfo() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('id', isEqualTo: user.uid)
            .get();
        if (userDocSnapshot.docs.isNotEmpty) {
          var userData = userDocSnapshot.docs.first.data();
          setState(() {
            email = userData['email'] ?? '';
            firstName = userData['firstName'] ?? '';
            lastName = userData['lastName'] ?? '';
            phoneNumber = userData['phoneNumber'] ?? '';
            profileImage = userData['userImage'] ?? '';
          });
          if (profileImage.isNotEmpty) {
            print("Profile image name: $profileImage");
            Uint8List? imageBytes =
                await downloadImage("userImages/$profileImage");
            if (imageBytes != null) {
              setState(() {
                userImage = imageBytes;
              });
              print("Image set successfully");
            } else {
              print("Image download returned null");
            }
          } else {
            print("No profile image found");
          }
        } else {
          print('User document does not exist');
        }
      } else {
        print('No user currently signed in');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  Future<bool> onbackpressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PetRecordColor.white,
        content: Text(
          "Are you sure to logout from this app?",
          style: TextStyle(fontSize: 17),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () async {
              Get.offAll(() => const Login());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PetRecordColor.primary,
              minimumSize: Size(80, 40),
            ),
            child: Text(
              "Yes",
              style: TextStyle(fontSize: 16, color: PetRecordColor.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PetRecordColor.primary,
              minimumSize: Size(80, 40),
            ),
            child: Text(
              "No",
              style: TextStyle(fontSize: 16, color: PetRecordColor.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: PetRecordColor.theme,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
            child: Column(
              children: [
                SizedBox(
                  height: 50.h,
                ),
                Center(
                  child: Stack(
                    children: [
                      userImage != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(userImage!),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await uploadUserImage();
                            await fetchUserInfo();
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    firstName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 0.0),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      'Profile',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.75,
                              child: ProfilePage(),
                            ),
                          );
                        },
                      );
                      // Fetch user info again when returning from ProfilePage
                      fetchUserInfo();
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.75,
                              child: PasswordPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text(
                      'Notification',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      // Handle notification tap
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      onbackpressed();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
