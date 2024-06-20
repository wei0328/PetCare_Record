import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double height = 0.00;
  double width = 0.00;
  final AuthController authController = Get.find<AuthController>();
  late String email = '';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
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
            firstNameController.text = userData['firstName'] ?? '';
            lastNameController.text = userData['lastName'] ?? '';
            phoneController.text = userData['phoneNumber'] ?? '';
          });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width / 15,
          vertical: height / 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / 56),
            Text(
              "Email Address",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: PetRecordColor.lightgrey),
              child: TextFormField(
                controller: TextEditingController(text: email),
                enabled: false,
                cursorColor: PetRecordColor.grey,
                style: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.immutableText,
                ),
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  prefixIcon: Icon(Icons.email, color: PetRecordColor.theme),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: height / 56),
            Text(
              "First Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: firstNameController,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              cursorColor: PetRecordColor.grey,
              style: TextStyle(
                fontSize: 15,
                color: PetRecordColor.black,
              ),
              decoration: InputDecoration(
                hintText: 'First Name',
                filled: true,
                fillColor: PetRecordColor.lightgrey,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.grey,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefixIcon: Icon(Icons.person, color: PetRecordColor.theme),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {},
            ),
            SizedBox(height: height / 56),
            Text(
              "Last Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: lastNameController,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              cursorColor: PetRecordColor.grey,
              style: TextStyle(
                fontSize: 15,
                color: PetRecordColor.black,
              ),
              decoration: InputDecoration(
                hintText: 'Last Name',
                filled: true,
                fillColor: PetRecordColor.lightgrey,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.grey,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: PetRecordColor.theme,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {},
            ),
            SizedBox(height: height / 56),
            Text(
              "Phone Number",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: phoneController,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              cursorColor: PetRecordColor.grey,
              style: TextStyle(
                fontSize: 15,
                color: PetRecordColor.black,
              ),
              decoration: InputDecoration(
                hintText: 'Phone Number',
                filled: true,
                fillColor: PetRecordColor.lightgrey,
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: PetRecordColor.grey,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefixIcon: Icon(
                  Icons.phone,
                  color: PetRecordColor.theme,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {},
            ),
            SizedBox(height: height / 28),
            InkWell(
                onTap: () async {
                  await saveInfo();
                  Navigator.pop(context, true);
                },
                child: Center(
                  child: Container(
                    height: 40.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: PetRecordColor.theme,
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> saveInfo() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDocSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('id', isEqualTo: user.uid)
            .get();
        if (userDocSnapshot.docs.isNotEmpty) {
          var userData = userDocSnapshot.docs.first;
          await userData.reference.update({
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'phoneNumber': phoneController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved')),
          );
        } else {
          print('User document does not exist');
        }
      } else {
        print('No user currently signed in');
      }
    } catch (e) {
      print('Error updating: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save')),
      );
    }
  }
}
