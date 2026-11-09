import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wadnere/HomePage.dart';
import 'package:wadnere/PaymentTestPage.dart';
import 'package:wadnere/signup.dart';

import 'LocalDatabase.dart';
import 'MyApp1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
      //  home: LoginPage(),
     // home: HomePage(),
      home: const AuthCheck(),
    //  home: PaymentTestPage(),
      //home: ResetPassword(mobileNumber: '7588938234', forgotPassword: true,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final accessToken =
      await LocalDatabase.instance.getAccessToken();

      final customer =
      await LocalDatabase.instance.getCustomer();

      if (!mounted) return;

      final isLoggedIn =
          accessToken != null &&
              accessToken.trim().isNotEmpty &&
              customer != null;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? HomePage()
              : const LoginPage(),
        ),
      );
    } catch (e) {
      debugPrint('Login status check error: $e');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController mobileController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
bool forgotpassword= false;
  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);

  bool isLoading = false;

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 8),

                    // Brand
                    const Text(
                      'WADNERE JEWELLERS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: lightGold,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Page title
                    const Text(
                      'USER LOGIN',
                      style: TextStyle(
                        color: lightGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Mobile label
                    _buildLabel('Mobile Number'),

                    const SizedBox(height: 7),

                    // Mobile field
                    _buildMobileField(),

                    const SizedBox(height: 14),

                    // Password label
                    _buildLabel('Password'),

                    const SizedBox(height: 7),

                    // Password field
                    _buildPasswordField(),

                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          forgotPassword();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: lightGold, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login button
                    _buildLoginButton(),

                    const SizedBox(height: 55),

                    // Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: lightGold,
                              fontSize: 14,
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

            // Bottom navigation
            // _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LOGO
  // --------------------------------------------------

  Widget _buildLogo() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1),
      ),
      child: const Center(
        child: Text(
          'W',
          style: TextStyle(
            color: lightGold,
            fontSize: 48,
            fontWeight: FontWeight.w300,
            fontFamily: 'serif',
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LABEL
  // --------------------------------------------------

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MOBILE FIELD
  // --------------------------------------------------

  Widget _buildMobileField() {
    return TextField(
      controller: mobileController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Mobile Number',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 16,
        ),

        prefixIcon: const Icon(Icons.phone_android, color: gold, size: 24),

        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: lightGold),

        filled: true,
        fillColor: Colors.transparent,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightGold, width: 2),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PASSWORD FIELD
  // --------------------------------------------------

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 16,
        ),

        prefixIcon: const Icon(Icons.lock, color: gold, size: 23),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: gold,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightGold, width: 2),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LOGIN BUTTON
  // --------------------------------------------------

  Future<void> _login() async {
    if (isLoading) return;

    final mobileText = mobileController.text.trim();
    final password = passwordController.text;

    if (mobileText.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile number and password'),
        ),
      );
      return;
    }

    final parsedMobileNumber = int.tryParse(mobileText);

    if (parsedMobileNumber == null || mobileText.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://dev-wadnerejwellors.runasp.net/api/Login',
        ),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': parsedMobileNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid server response');
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true) {

        final responseMobileNumber =
            decoded['mobileNumber']?.toString() ?? mobileText;

        final bool requiresOtp =
            decoded['requiresOtpVerification'] == true;

        // CASE 1: OTP required
        if (requiresOtp) {
          if (!mounted) return;

          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Verify your account'),
                content: Text(
                  decoded['message']?.toString() ??
                      'OTP sent to your registered email and WhatsApp.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      verify_otp(responseMobileNumber);
                    },
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          );

          return;
        }

        // CASE 2: OTP not required
        final registrationId =
            decoded['registrationId']?.toString() ?? '';

        final fullName =
            decoded['fullName']?.toString() ?? '';

        final emailAddress =
            decoded['emailAddress']?.toString() ?? '';

        final accessToken =
            decoded['accessToken']?.toString() ?? '';

        final refreshToken =
            decoded['refreshToken']?.toString() ?? '';

        final bool isAdmin = decoded['isAdmin'] == true;

        if (registrationId.isEmpty ||
            accessToken.isEmpty ||
            refreshToken.isEmpty) {
          throw Exception('Required login details are missing.');
        }

        await LocalDatabase.instance.saveTokens(
          accessToken,
          refreshToken,
        );

        await LocalDatabase.instance.saveCustomer(
          registrationId: registrationId,
          customerName: fullName,
          mobileNumber: responseMobileNumber,
          customerEmail: emailAddress,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isadmin: isAdmin,
        );



        final customer =
        await LocalDatabase.instance.getCustomer();

        if (customer == null) {
          throw Exception('Customer was not saved in SQLite.');
        }

        debugPrint('Customer saved successfully.');
        debugPrint('Registration ID: $registrationId');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
              (route) => false,
        );

      } else {
        final message =
            decoded['message']?.toString() ??
                'Login failed. Check your credentials.';

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again.'),
        ),
      );
    } on FormatException catch (e) {
      debugPrint('Login format error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid response received from server.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  Future<void> _login1() async {
    if (isLoading) return;

    final mobileText = mobileController.text.trim();
    final password = passwordController.text;

    // 1. Validate input
    if (mobileText.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile number and password'),
        ),
      );
      return;
    }

    final parsedMobileNumber = int.tryParse(mobileText);

    if (parsedMobileNumber == null || mobileText.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 2. Call Login API
      final response = await http
          .post(
        Uri.parse(
          'https://dev-wadnerejwellors.runasp.net/api/Login',
        ),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobileNumber': parsedMobileNumber,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 30));

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid server response');
      }

      if (!mounted) return;

      // 3. Check API response
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true) {

        final registrationId =
            decoded['registrationId']?.toString() ?? '';

        final fullName =
            decoded['fullName']?.toString() ?? '';

        final emailAddress =
            decoded['emailAddress']?.toString() ?? '';

        final accessToken =
            decoded['accessToken']?.toString() ?? '';

        final refreshToken =
            decoded['refreshToken']?.toString() ?? '';

        final responseMobileNumber =
            decoded['mobileNumber']?.toString() ?? mobileText;

        final bool isAdmin = decoded['isAdmin'] == true;

        final bool requiresOtp =
            decoded['requiresOtpVerification'] == true;

        // 4. CASE 1: OTP verification required
        if (requiresOtp) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Verify your account'),
                content: Text(
                  decoded['message']?.toString() ??
                      'OTP sent to your registered email.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      // Open OTP verification page.
                      // Save customer only after OTP succeeds.
                      verify_otp(responseMobileNumber);
                    },
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          );
        }

        // 5. CASE 2: OTP verification not required
        else {
          // Save tokens
          await LocalDatabase.instance.saveTokens(
            accessToken,
            refreshToken,
          );

          // Save customer details
          /*await LocalDatabase.instance.saveCustomer(
            registrationId: registrationId,
            customerName: fullName,
            mobileNumber: responseMobileNumber,
            customerEmail: emailAddress,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isadmin: isAdmin,
          );*/
          await LocalDatabase.instance.saveCustomer(
            registrationId: registrationId,
            customerName: fullName,
            mobileNumber: responseMobileNumber,
            customerEmail: emailAddress,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isadmin: isAdmin,
          );

          // Verify customer was saved
          final customer =
          await LocalDatabase.instance.getCustomer();


          final savedCustomer =
          await LocalDatabase.instance.getCustomer();

          debugPrint('Customer saved: ${savedCustomer != null}');
          debugPrint('Customer data: $savedCustomer');

          if (savedCustomer == null) {
            throw Exception('Customer insert failed in SQLite.');
          }
          if (customer == null) {
            throw Exception('Customer was not saved in SQLite');
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
            ),
          );

          // Navigate to HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
                (route) => false,
          );
        }
      } else {
        // 6. Login failed
        final message =
            decoded['message']?.toString() ??
                'Login failed. Check your credentials.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again.'),
        ),
      );
    } on FormatException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid response received from server.'),
        ),
      );
    } catch (e) {
      debugPrint('Login error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        /*  onPressed: () {
          final mobile =
          mobileController.text.trim();

          final password =
              passwordController.text;

          debugPrint('Mobile: $mobile');
          debugPrint('Password: $password');

         */
        /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );*/
        /*

          _login();

        },*/
       // onPressed: isLoading ? null : _login,
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'LOG IN',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BOTTOM NAVIGATION
  // --------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true),
          _navItem(Icons.collections_bookmark_outlined, 'Collections', false),
          _navItem(Icons.person_outline, 'Profile', false),
          _navItem(Icons.phone, 'Contact', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: selected ? gold : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  void verify_otp(String mobileNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(mobileNumber: mobileNumber,forgotPassword: false,),
      ),
    );
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: 'Enter your mobile number',
              prefixIcon: Icon(Icons.phone_android),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
             //   ForgotPasswordAPI(mobileController.text);

              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final mobile = mobileController.text.trim();

                if (mobile.length != 10 ||
                    !RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid 10-digit mobile number',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                // TODO: Call your forgot-password API.
                debugPrint('Mobile number: $mobile');
                ForgotPasswordAPI(mobileController.text);

              //  OtpVerificationPage(mobileNumber: mobileController.text,forgotPassword: true,);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  Future<void> ForgotPasswordAPI(String mobileNumber) async {
    final url = Uri.parse(
      'https://dev-wadnerejwellors.runasp.net/api/ForgotPassword',
    );

    final requestBody = {
      "mobileNumber": mobileNumber,
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

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final message = responseData['message'] ??
            'OTP sent successfully.';

        forgotpassword = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.toString())),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(
              mobileNumber: mobileNumber,
              forgotPassword: true,
            ),
          ),
        );
      } else {
        final message = responseData['message'] ??
            responseData['error'] ??
            'Failed to send OTP';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.toString())),
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Forgot Password API Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Error: $e')),
      );
    }
  }


}


// ==========================================================
// OTP VERIFICATION PAGE
// ==========================================================

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final bool forgotPassword;

  const OtpVerificationPage({super.key, required this.mobileNumber,required this.forgotPassword});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final otpController = TextEditingController();

  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);

  late String currentOtp;

  Timer? timer;

  int remainingSeconds = 300;

  bool isExpired = false;
late bool forgotPassword;
  @override
  void initState() {
    super.initState();
    String mobileNumber = widget.mobileNumber;
    forgotPassword=widget.forgotPassword;
    print("ForgotPassword:"+forgotPassword.toString());
  }

  // ----------------------------------------------------------
  // TIMER
  // ----------------------------------------------------------

  // ----------------------------------------------------------
  // RESEND OTP
  // ----------------------------------------------------------

  // ----------------------------------------------------------
  // VERIFY OTP
  // ----------------------------------------------------------
  void navigatetoHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString();

    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightGold),
        title: const Text(
          'Verify WhatsApp',
          style: TextStyle(color: lightGold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.5),
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
                    'email id',
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
                    keyboardType: TextInputType.number,
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
                        color: Colors.white.withOpacity(.25),
                        letterSpacing: 8,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: gold),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: gold, width: 1.3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
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
                      style: const TextStyle(color: lightGold, fontSize: 14),
                    )
                  else
                    const Text(
                      'OTP expired',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),

                  const SizedBox(height: 25),

                  // Verify
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: verifyOtp,
                       /* onPressed:  (){if(forgotPassword==false){
                  verifyOtp();
                  }
                  else{
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) =>ResetPassword()));
                        }
                        },*/

                      // onPressed: navigatetoHomePage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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

                  /* const SizedBox(height: 12),

                  // Resend
                  TextButton(
                    onPressed: sendOtp,
                    child: Text(
                      isExpired
                          ? 'Resend OTP'
                          : 'Resend OTP',
                      style: const TextStyle(
                        color: lightGold,
                        fontSize: 14,
                      ),
                    ),
                  ),*/
                  const SizedBox(height: 20),

                  // Demo information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: gold.withOpacity(.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: gold, size: 18),
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

  Future<void> verifyOtp() async {
    print('inside verifyotp');
    final url = Uri.parse(
      'https://dev-wadnerejwellors.runasp.net/api/Login/verify-otp',
    );

    final requestBody = {
      "mobileNumber": widget.mobileNumber,
      "otpCode": otpController.text,
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
      print("response:" + response.body);
    /*  if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        final message =
            responseData['message'] ?? 'OTP verification successful.';

        if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomePage(successMessage: message)), (route) => false,);

      }*/

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {

        final message =
            responseData['message']?.toString() ??
                'OTP verification successful.';

        final registrationId =
            responseData['registrationId']?.toString() ?? '';

        final mobileNumber =
            responseData['mobileNumber']?.toString() ??
                widget.mobileNumber;

        final fullName =
            responseData['fullName']?.toString() ?? '';

        final emailAddress =
            responseData['emailAddress']?.toString() ?? '';

        final accessToken =
            responseData['accessToken']?.toString() ?? '';

        final refreshToken =
            responseData['refreshToken']?.toString() ?? '';

        final bool isAdmin =
            responseData['isAdmin'] == true;

        // Validate response
        if (registrationId.isEmpty ||
            accessToken.isEmpty ||
            refreshToken.isEmpty) {
          throw Exception('Required customer details are missing.');
        }

        // 1. Save tokens
        await LocalDatabase.instance.saveTokens(
          accessToken,
          refreshToken,
        );

        // 2. Save customer
        await LocalDatabase.instance.saveCustomer(
          registrationId: registrationId,
          customerName: fullName,
          mobileNumber: mobileNumber,
          customerEmail: emailAddress,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isadmin: isAdmin,
        );

        // 3. Verify SQLite insertion
        final customer =
        await LocalDatabase.instance.getCustomer();

        if (customer == null) {
          throw Exception('Customer insert failed in SQLite.');
        }

        debugPrint('OTP customer saved successfully.');
        debugPrint('Registration ID: ${customer['registrationId']}');
        debugPrint('Customer name: ${customer['customerName']}');

        if (!mounted) return;

        // 4. Navigate only after saving
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(successMessage: message),
          ),
              (route) => false,
        );
      }
    else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  responseData['error'] ??
                  'OTP verification failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('API Error: $e')));
    }
  }

}

class ResetPassword extends StatefulWidget{
  final String mobileNumber;
  final bool forgotPassword;

  const ResetPassword({super.key, required this.mobileNumber,required this.forgotPassword});

  @override
  State<ResetPassword> createState()=> _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>{
  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
       backgroundColor: navy,
       appBar: AppBar(
         backgroundColor: navy,
         elevation: 0,
         iconTheme: const IconThemeData(color: lightGold),
         title: const Text(
           'Reset Password',
           style: TextStyle(color: lightGold),
         ),
       ),
       body: SafeArea(
           child: Column(
             children: [
           Expanded(
           child: SingleChildScrollView(
           padding: const EdgeInsets.symmetric(
             horizontal: 24,
             vertical: 20,
           ),
           child: Column(
               children: [
                 const SizedBox(height: 20),

                 // Logo


                 const SizedBox(height: 8),

                 // Brand
                 const Text(
                   'WADNERE JEWELLERS',
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     color: lightGold,
                     fontSize: 24,
                     fontWeight: FontWeight.w500,
                     letterSpacing: 1.2,
                   ),
                 ),

                 const SizedBox(height: 26),
                 _buildLabel('OTP'),
                 const SizedBox(height: 20),
                 TextField(
                   controller: otpController,
                   keyboardType: TextInputType.number,
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
                       color: Colors.white.withOpacity(.25),
                       letterSpacing: 8,
                     ),
                     prefixIcon: const Icon(Icons.lock_outline, color: gold),
                     contentPadding: const EdgeInsets.symmetric(vertical: 10),
                     enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                       borderSide: const BorderSide(color: gold, width: 1.3),
                     ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                       borderSide: const BorderSide(
                         color: lightGold,
                         width: 2,
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(height: 20),
                 _buildLabel('Password'),
                 const SizedBox(height: 20),
                 _buildPasswordField(),
                     const SizedBox(height: 20),

                 const SizedBox(height: 20),
                 _buildLabel('Confirm Password'),
                 const SizedBox(height: 20),
                 TextField(
                   controller: confirmpasswordController,
                   obscureText: !isPasswordVisible,
                   style: const TextStyle(color: Colors.white, fontSize: 16),
                   decoration: InputDecoration(
                     hintText: 'Confirm Password',
                     hintStyle: TextStyle(
                       color: Colors.white.withOpacity(0.45),
                       fontSize: 16,
                     ),

                     prefixIcon: const Icon(Icons.lock, color: gold, size: 23),

                     suffixIcon: IconButton(
                       onPressed: () {
                         setState(() {
                           isPasswordVisible = !isPasswordVisible;
                         });
                       },
                       icon: Icon(
                         isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                         color: gold,
                       ),
                     ),

                     contentPadding: const EdgeInsets.symmetric(
                       horizontal: 16,
                       vertical: 10,
                     ),

                     enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                       borderSide: const BorderSide(color: gold, width: 1.5),
                     ),

                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(10),
                       borderSide: const BorderSide(color: lightGold, width: 2),
                     ),
                   ),
                 ),
                 const SizedBox(height: 25),
                 const SizedBox(height: 25),
                 _buildResetPasswordButton(),
                   ])))])));
  }
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 16,
        ),

        prefixIcon: const Icon(Icons.lock, color: gold, size: 23),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: gold,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightGold, width: 2),
        ),
      ),
    );
  }
  Widget _buildResetPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(

        onPressed:(){ResetPasswordAPI();},
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }


  Future<void> ResetPasswordAPI() async {
    debugPrint('Inside ResetPasswordAPI');

    final url = Uri.parse(
      'https://dev-wadnerejwellors.runasp.net/api/ResetPassword',
    );

    final requestBody = {
      "mobileNumber": widget.mobileNumber,
      "otpCode": otpController.text.trim(),
      "newPassword": passwordController.text,
      "confirmPassword": confirmpasswordController.text,
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

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final String message =
        (responseData['message'] ??
            'Password reset successfully.')
            .toString();

        debugPrint('Password reset successful');
        debugPrint('Navigating to HomePage');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomePage(
              successMessage: message,
            ),
          ),
              (route) => false,
        );
      } else {
        final String errorMessage =
        (responseData['message'] ??
            responseData['error'] ??
            'Password reset failed.')
            .toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ResetPasswordAPI error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Error: $e')),
      );
    }
  }


}



