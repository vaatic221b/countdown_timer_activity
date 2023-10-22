// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sucalit Countdown Timer Activity - Captcha',
      debugShowCheckedModeBanner: false,
      home: OTPVerificationScreen(),
    );
  }
}

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String _generatedOTP = '';
  String _enteredOTP = '';

  bool _isOTPGenerated = false;
  bool _isResendingOTP = false;
  int _resendCooldown = 20;
  Timer? _resendTimer;

  void generateOTP() {
    setState(() {
      _generatedOTP = _generateRandomOTP();
      _isOTPGenerated = true;
      _resendCooldown = 20; 
    });

    _startResendTimer();
  }

  void resendOTP() {
    setState(() {
      _isOTPGenerated = false;
    });

    _startResendTimer();
  }

  String _generateRandomOTP() {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random();
    const otpLength = 5;
    return String.fromCharCodes(
        List.generate(otpLength, (index) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  void _startResendTimer() {
    _resendTimer?.cancel(); 
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
        setState(() {
          _isResendingOTP = false;
        });
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
    setState(() {
      _isResendingOTP = true;
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel(); 
    super.dispose();
  }

  void verifyOTP(BuildContext context) {
    if (_generatedOTP == _enteredOTP) {
      _showVerificationDialog(context, 'Verified');
    } else {
      _showVerificationDialog(context, 'Verification Failed, Please try again');
    }
  }

  void _showVerificationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Result'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('Captcha Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.asset(
              'assets/images/verify.png', 
              width: 150, 
              height: 150, 
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 200,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    _isOTPGenerated ? _generatedOTP : '',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),


            const SizedBox(height: 20),
            const Text(
              'To verify you are not a bot, please match the characters generated above.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isResendingOTP ? null : () {
                    generateOTP();
                  },
                  child: Text(_isResendingOTP ? 'Get a new code ($_resendCooldown)' : 'Generate code'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 200,
              child: TextField(
                keyboardType: TextInputType.text,  
                onChanged: (value) {
                  setState(() {
                    _enteredOTP = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter captcha',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),


            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                verifyOTP(context);
              },
              child: const Text('Submit'),
            ),

          ],
        ),
      ),
    );
  }
}
