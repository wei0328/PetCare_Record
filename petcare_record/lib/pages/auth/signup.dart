import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/auth.dart';
import 'package:petcare_record/pages/auth/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _obscureText = true;

  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Obx(
      () => Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width / 36, vertical: height / 36),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo/logo-notext.png',
                      height: 200.h,
                    ),
                  ),
                  TextField(
                    controller: authController.emailController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 56,
                  ),
                  TextField(
                    controller: authController.passwordController,
                    obscureText: _obscureText,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.h,
                        ),
                        onPressed: _togglePasswordStatus,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 56,
                  ),
                  TextField(
                    controller: authController.firstNameController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 56,
                  ),
                  TextField(
                    controller: authController.lastNameController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 56,
                  ),
                  TextField(
                    controller: authController.phoneController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      authController.signUp(context);
                    },
                    child: Container(
                      height: height / 15,
                      width: width / 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: PetRecordColor.theme,
                      ),
                      child: Center(
                        child: authController.isLoading.value == true
                            ? const CircularProgressIndicator(
                                color: PetRecordColor.white)
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 20.sp, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have an account?  ",
                        style: TextStyle(fontSize: 14),
                      ),
                      InkWell(
                        splashColor: PetRecordColor.transparent,
                        highlightColor: PetRecordColor.transparent,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const Login();
                            },
                          ));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 14, color: PetRecordColor.theme),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
