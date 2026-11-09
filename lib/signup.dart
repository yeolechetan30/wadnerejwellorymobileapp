
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'HomePage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});



  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final  firstnameController = TextEditingController();
  final  lastnameController = TextEditingController();
  final  emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final talukaController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();

  DateTime? anniversaryDate;
  DateTime? birthDate;

  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);


  Future<void> selectAnniversaryDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: gold,
              onPrimary: Colors.black,
              surface: navy,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        anniversaryDate = pickedDate;
      });
    }
  }

  String get formattedAnniversary {
    if (anniversaryDate == null) {
      return 'Select anniversary date';
    }

    final date = anniversaryDate!;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> selectBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: gold,
              onPrimary: Colors.black,
              surface: navy,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        birthDate = pickedDate;
      });
    }
  }

  String get formattedBirthDay {
    if (birthDate == null) {
      return 'Select birth date';
    }

    final date = birthDate!;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
  // ----------------------------------------------------------
  // GENERATE RANDOM OTP
  // ----------------------------------------------------------

/*  String generateOtp() {
    final random = Random();

    return (100000 + random.nextInt(900000)).toString();
  }*/

  // ----------------------------------------------------------
  // REGISTER
  // ----------------------------------------------------------
/*
  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final district = districtController.text.trim();
    final mobile = mobileController.text.trim();

    // Validation

    if (name.isEmpty) {
      showError('Please enter your name.');
      return;
    }

    if (address.isEmpty) {
      showError('Please enter your address.');
      return;
    }

    if (city.isEmpty) {
      showError('Please enter your city.');
      return;
    }

    if (district.isEmpty) {
      showError('Please enter your district.');
      return;
    }

    if (mobile.isEmpty) {
      showError('Please enter your WhatsApp number.');
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      showError(
        'Please enter a valid 10-digit WhatsApp number.',
      );
      return;
    }

    if (anniversaryDate == null) {
      showError('Please select your anniversary date.');
      return;
    }

    // Generate OTP
    final otp = generateOtp();

    debugPrint('Generated OTP: $otp');

    // Open WhatsApp
   */
  /* final success = await sendOtpToWhatsApp(


      mobile,
      otp,
    );

    if (!success) {
      showError(
        'Could not open WhatsApp. Please check if WhatsApp is installed.',
      );
      return;
    }*/
  /*

    if (!mounted) return;

    // Navigate to OTP page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          mobileNumber: mobile,
          generatedOtp: otp,
          name: name,
          address: address,
          city: city,
          district: district,
          anniversaryDate: anniversaryDate!,
        ),
      ),
    );
  }*/

  // ----------------------------------------------------------
  // SEND OTP TO WHATSAPP
  // ----------------------------------------------------------

  /*Future<bool> sendOtpToWhatsApp(
      String mobile,
      String otp,
      ) async
  {
    final message =
    '''
Wadnera Jewellers

Your verification OTP is:

$otp

This OTP is valid for 5 minutes.

Please do not share this OTP with anyone.
''';

    final url = Uri.parse(
      'https://wa.me/91$mobile'
          '?text=${Uri.encodeComponent(message)}',
    );

    try {
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('WhatsApp error: $e');
      return false;
    }
  }*/

  // ----------------------------------------------------------
  // ERROR
  // ----------------------------------------------------------

  void showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------


  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    talukaController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: Column(
                    children: [

                      // Title
                      const Text(
                        'CUSTOMER REGISTRATION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: lightGold,
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // NAME
                      _buildLabel('First Name'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: firstnameController,
                        hint: 'Enter your first name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),
                      _buildLabel('Last Name'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: lastnameController,
                        hint: 'Enter your last name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),
                      _buildLabel('Email ID'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: emailController,
                        hint: 'Enter your Email ID',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),
                      _buildLabel(
                        "Mobile Number",
                      ),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: mobileController,
                        hint: 'Enter mobile number',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      ),

                      const SizedBox(height: 14),
                      // ADDRESS
                      _buildLabel('Address'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: addressController,
                        hint: 'Enter your address',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 14),

                      // CITY
                      _buildLabel('City'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: cityController,
                        hint: 'Enter your city',
                        icon: Icons.location_city_outlined,
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('Taluka'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: talukaController,
                        hint: 'Enter your Taluka',
                        icon: Icons.location_city_outlined,
                      ),

                      const SizedBox(height: 14),
                      // DISTRICT
                      _buildLabel('Dist'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: districtController,
                        hint: 'Enter your district',
                        icon: Icons.map_outlined,
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('State'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: stateController,
                        hint: 'Enter your state',
                        icon: Icons.map_outlined,
                      ),

                      const SizedBox(height: 14),

                      _buildLabel('Pincode'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: pincodeController,
                        hint: 'Enter pincode',
                        icon: Icons.map_outlined,
                      ),

                      const SizedBox(height: 14),


                      // ANNIVERSARY
                      _buildLabel('Birth Date'),

                      const SizedBox(height: 6),

                      _buildbirthDateField(),

                      const SizedBox(height: 28),
                      _buildLabel('Anniversary Date'),

                      const SizedBox(height: 6),

                      _buildDateField(),

                      const SizedBox(height: 28),

                      _buildLabel('Password'),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: passwordController,
                        hint: 'Enter password',
                        icon: Icons.map_outlined,
                        maxLength: 7
                      ),

                      const SizedBox(height: 14),
                      // CREATE ACCOUNT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          //onPressed: registerUser,
                          onPressed: (){
                          /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                              
                            );*/
                            registerCustomer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(9),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                'REGISTER',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LOGIN
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: lightGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            //_buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // LOGO
  // ----------------------------------------------------------



  // ----------------------------------------------------------
  // LABEL
  // ----------------------------------------------------------

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TEXT FIELD
  // ----------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: gold,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: gold,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: lightGold,
            width: 1.8,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // DATE FIELD
  // ----------------------------------------------------------

  Widget _buildDateField() {
    return InkWell(
      onTap: selectAnniversaryDate,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: gold,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: gold,
              size: 20,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                formattedAnniversary,
                style: TextStyle(
                  color: anniversaryDate == null
                      ? Colors.white.withOpacity(.4)
                      : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: lightGold,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildbirthDateField() {
    return InkWell(
      onTap: selectBirthDate,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: gold,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: gold,
              size: 20,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                formattedBirthDay,
                style: TextStyle(
                  color: birthDate == null
                      ? Colors.white.withOpacity(.4)
                      : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: lightGold,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
  void registrationSuccess() {}

  // ----------------------------------------------------------
  // BOTTOM NAVIGATION
  // ----------------------------------------------------------



Future<void> registerCustomer() async {
  final url = Uri.parse(
    'https://dev-wadnerejwellors.runasp.net/api/Register'
  );

  final requestBody = {
    //"registrationId": '',
    "firstName": firstnameController.text,
    "lastName": lastnameController.text,
    "emailAddress": emailController.text,
    "mobileNumber": int.tryParse(mobileController.text) ?? 0,
    "isMobileVerified": true,
    "passwordHash": passwordController.text,
    "addressLine1": addressController.text,
    "addressLine2": "",
    "village_City": cityController.text,
    "taluka": talukaController.text,
    "district": districtController.text,
    "state": stateController.text,
    "pincode": pincodeController.text,
    "dateOfBirth": birthDate?.toIso8601String(),
    "anniversaryDate": anniversaryDate?.toIso8601String(),
    "isActive": true,
    "isAdmin": true,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final message =
          responseData['message'] ?? 'User registered successfully.';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseData['message'] ??
                responseData['error'] ??
                'Registration failed',
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('API Error: $e')),
    );
  }
}
}

// ==========================================================
// OTP VERIFICATION PAGE
// ==========================================================

/*
class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final String generatedOtp;

  final String name;
  final String address;
  final String city;
  final String district;
  final DateTime anniversaryDate;

  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
    required this.generatedOtp,
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.anniversaryDate,
  });

  @override
  State<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState
    extends State<OtpVerificationPage> {
  final otpController = TextEditingController();

  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);

  late String currentOtp;

  Timer? timer;

  int remainingSeconds = 300;

  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    currentOtp = widget.generatedOtp;

    startTimer();
  }

  // ----------------------------------------------------------
  // TIMER
  // ----------------------------------------------------------

  void startTimer() {
    timer?.cancel();

    remainingSeconds = 300;

    isExpired = false;

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          setState(() {
            isExpired = true;
          });

          timer.cancel();
        }
      },
    );
  }

  // ----------------------------------------------------------
  // RESEND OTP
  // ----------------------------------------------------------

  Future<void> resendOtp() async {
    if (!isExpired && remainingSeconds > 270) {
      showError(
        'Please wait before requesting another OTP.',
      );
      return;
    }

    final random = Random();

    final newOtp =
    (100000 + random.nextInt(900000)).toString();

    currentOtp = newOtp;

    debugPrint('New OTP: $newOtp');

    final message =
    '''
Wadnera Jewellers

Your new verification OTP is:

$newOtp

This OTP is valid for 5 minutes.

Please do not share this OTP with anyone.
''';

    final url = Uri.parse(
      'https://wa.me/91${widget.mobileNumber}'
          '?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showError('Could not open WhatsApp.');
        return;
      }

      startTimer();

      showSuccess(
        'New OTP generated.',
      );
    } catch (e) {
      showError(
        'Could not open WhatsApp.',
      );
    }
  }

  // ----------------------------------------------------------
  // VERIFY OTP
  // ----------------------------------------------------------
void navigatetoHomePage(){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
}
  void verifyOtp() {

    final enteredOtp = otpController.text.trim();

    if (enteredOtp.length != 6) {
      showError(
        'Please enter the 6-digit OTP.',
      );
      return;
    }

    if (isExpired) {
      showError(
        'OTP has expired. Please request a new OTP.',
      );
      return;
    }

    if (enteredOtp != currentOtp) {
      showError(
        'Invalid OTP. Please try again.',
      );
      return;
    }

    // OTP correct
    registrationSuccess();
  }

  // ----------------------------------------------------------
  // REGISTRATION SUCCESS
  // ----------------------------------------------------------

  void registrationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.check_circle,
                color: gold,
                size: 65,
              ),
              SizedBox(height: 15),
              Text(
                'Registration Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lightGold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your WhatsApp number has been verified successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          actionsAlignment:
          MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Remove OTP screen
                Navigator.pop(context);

                // You can navigate to Home here
              },
              child: const Text(
                'CONTINUE',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // ERROR
  // ----------------------------------------------------------

  void showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // SUCCESS
  // ----------------------------------------------------------

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    timer?.cancel();

    otpController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final minutes =
    (remainingSeconds ~/ 60).toString();

    final seconds =
    (remainingSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: lightGold,
        ),
        title: const Text(
          'Verify WhatsApp',
          style: TextStyle(
            color: lightGold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gold,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_chat_read_outlined,
                      color: lightGold,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'VERIFY WHATSAPP',
                    style: TextStyle(
                      color: lightGold,
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'We sent an OTP to',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.75),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '+91 ${widget.mobileNumber}',
                    style: const TextStyle(
                      color: lightGold,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OTP
                  TextField(
                    controller: otpController,
                    keyboardType:
                    TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '------',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(.25),
                        letterSpacing: 8,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: gold,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(
                          color: gold,
                          width: 1.3,
                        ),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(
                          color: lightGold,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Timer
                  if (!isExpired)
                    Text(
                      'OTP expires in $minutes:$seconds',
                      style: const TextStyle(
                        color: lightGold,
                        fontSize: 14,
                      ),
                    )
                  else
                    const Text(
                      'OTP expired',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 25),

                  // Verify
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                     // onPressed: verifyOtp,
                      onPressed: navigatetoHomePage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'VERIFY OTP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Resend
                  TextButton(
                    onPressed: resendOtp,
                    child: Text(
                      isExpired
                          ? 'Resend OTP'
                          : 'Resend OTP',
                      style: const TextStyle(
                        color: lightGold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Demo information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius:
                      BorderRadius.circular(8),
                      border: Border.all(
                        color: gold.withOpacity(.3),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: gold,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'WhatsApp will open with the OTP message. '
                                'Tap Send in WhatsApp to deliver it.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
