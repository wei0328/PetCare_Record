import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pet_care/petcare/petcare_constants/app_config.dart';
// import 'package:pet_care/petcare/petcare_constants/snack_bars.dart';
// import 'package:pet_care/petcare/petcare_dashboard/petcare_dashboard.dart';
// import 'package:pet_care/petcare/petcare_database/auth.dart';
// import 'package:pet_care/petcare/petcare_pages/petcare_authentication/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  var isLoading = false.obs;

  signUp(BuildContext context) async {
    isLoading.value = true;
    try {
      final response =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      isLoading.value = false;

      if (response.user != null) {
        await FirebaseFirestore.instance.collection('users').add({
          'id': response.user!.uid,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'phoneNumber': phoneController.text,
          'address': ''
        });

        // setUserInformation(
        //     firstNameController.text,
        //     lastNameController.text,
        //     emailController.text,
        //     passwordController.text,
        //     phoneController.text);

        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PetCareDashboard("0");
          },
        ));

       
  }

  login(BuildContext context) async {
    isLoading.value = true;

    try {
      final response = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      isLoading.value = false;

      if (response.user != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PetCareDashboard("0");
          },
        ));

       
  }

  verifyOTP(BuildContext context) async {
    isLoading.value = true;

    var response = await AuthenticationApi().postRequest(
      context,
      url: AppConfig.validate_otp,
      body: {
        'email': emailController.text,
        'code': otpController.text,
      },
    );
    isLoading.value = false;

    if (response != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return PetCareDashboard("0");
        },
      ));


      clearControllers();
    }
  }

  resendOTP(BuildContext context) async {
    isLoading.value = true;
    var response = await AuthenticationApi().postRequest(
      context,
      url: AppConfig.resend_otp,
      body: {"email": emailController.text},
    );

    isLoading.value = false;

    if (response != null) {
      customInfoSnackBar(
          context, 'OTP has been resent, please check your email.');
    }
  }

  void clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
  }

  //new
  UserData? userData;

  void setUserInformation(String firstName, String lastName, String email,
      String password, String phoneNumber) {
    userData = UserData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber);
  }
}

//new
class UserData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;

  UserData(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.phoneNumber});
}
