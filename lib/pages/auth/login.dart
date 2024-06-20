import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/models/auth.dart';
import 'package:petcare_record/pages/auth/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 150.h),
            Center(
              child: Image.asset(
                'assets/logo/logo-notext.png',
                height: 200.h,
              ),
            ),
            TextField(
              controller: _emailController,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                hintText: 'Email Address',
                filled: true,
                fillColor: Colors.grey[200],
                // prefixIcon: Padding(
                //   padding: const EdgeInsets.all(15),
                //   child: SvgPicture.asset(
                //       'assets/icons/mail.svg'), // Replace with your icon asset path
                // ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
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
            SizedBox(height: 30.h),
            InkWell(
              onTap: () {
                _authController.emailController.text = _emailController.text;
                _authController.passwordController.text =
                    _passwordController.text;
                _authController.login(context);
              },
              child: Container(
                height: 50.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: PetRecordColor.theme,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 20.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?  ",
                  style: TextStyle(fontSize: 14),
                ),
                InkWell(
                  splashColor: PetRecordColor.transparent,
                  highlightColor: PetRecordColor.transparent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const SignUp();
                      },
                    ));
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 14, color: PetRecordColor.theme),
                  ),
                ),
              ],
            ),
            // SizedBox(height: 30.h),
            // Text('or login with', style: TextStyle(fontSize: 14.sp)),
            // SizedBox(height: 10.h),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {
            //         //
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: PetRecordColor.white,
            //         padding: EdgeInsets.all(10),
            //         shape: CircleBorder(
            //           side: BorderSide(color: PetRecordColor.theme),
            //         ),
            //       ),
            //       child: Image.asset(
            //         'assets/icon/gmail.png',
            //         height: 24,
            //         width: 24,
            //       ),
            //     ),
            //     ElevatedButton(
            //       onPressed: () {
            //         // Implement your onPressed logic here
            //       },
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: Colors.black,
            //         backgroundColor: PetRecordColor.white,
            //         padding: EdgeInsets.all(10),
            //         shape: CircleBorder(
            //           side: BorderSide(color: PetRecordColor.theme),
            //         ),
            //       ),
            //       child: Icon(Icons.apple, size: 24, color: Colors.black),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
