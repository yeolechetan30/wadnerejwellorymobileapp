import 'dart:convert';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wadnere/AddMoneyPage.dart';
import 'package:wadnere/MembershipCard.dart';
import 'package:wadnere/MembershipPage.dart';
import 'package:wadnere/main.dart';
import 'package:wadnere/signup.dart';

import 'LocalDatabase.dart';
import 'PassbookApp.dart';

class HomePage extends StatefulWidget {
  final String? successMessage;

  const HomePage({super.key, this.successMessage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String gold24KPer10Gram="";
  String silverPerKg="";
  String gold22KPer10Gram = '';

  bool hasActiveMembership = false;
  bool canRenew = false;

  String membershipCode = '';
  String membershipFromDate = '';
  String membershipToDate = '';
  String membershipMessage = '';

  dynamic membershipAmount;
  bool isLoggedIn = false;
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadMembershipStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final message = widget.successMessage;

      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });
    loadRates();

  }
  Future<void> checkLoginStatus() async {
    final token = await LocalDatabase.instance.getAccessToken();

    if (!mounted) return;

    setState(() {
      isLoggedIn = token != null && token.trim().isNotEmpty;
    });
  }
  Future<void> loadMembershipStatus() async {
    try {
      final result = await getMembershipStatusWithRefresh();

      setState(() {
        hasActiveMembership =
            result['hasActiveMembership'] == true;
      print("hasActiveMembership:"+hasActiveMembership.toString());
        membershipCode =
            result['membershipCode']?.toString() ?? '';

        membershipAmount =
            result['amount'] ?? 0;

        membershipFromDate =
            result['fromDate']?.toString() ?? '';

        membershipToDate =
            result['toDate']?.toString() ?? '';

        canRenew = result['canRenew'] == true;

        membershipMessage =
            result['message']?.toString() ?? '';
      });

    } catch (e) {
      debugPrint('Unable to load membership: $e');
    }
  }
  static const String baseUrl =
      'https://dev-wadnerejwellors.runasp.net/api/Membership';
  static const String refreshUrl =
      'https://dev-wadnerejwellors.runasp.net/api/Login/refresh-token';
  Future<http.Response> getMembershipStatus({
    required int registrationId,
    required String accessToken,
  }) async
  {
    final url = Uri.parse(
      '$baseUrl/status/$registrationId',
    );
   /* final url = Uri.parse(
      '$baseUrl/status/1',
    );*/

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${accessToken.trim()}',
      },
    );

    debugPrint('Membership Status: ${response.statusCode}');
    debugPrint('Membership Response: ${response.body}');

    return response;
  }
  Future<Map<String, dynamic>> getMembershipStatusWithRefresh() async {
    try {
      // STEP 1: Get customer from SQLite
      final customer =
      await LocalDatabase.instance.getCustomer();

      if (customer == null) {
        throw Exception('Customer not found. Please login.');
      }

      final registrationId =
      int.tryParse(customer['registrationId'].toString());
     //  isAdmin = (customer['isAdmin']);
       isAdmin =
          customer['isadmin'] == 1 || customer['isadmin'] == true;

      debugPrint('Customer loaded successfully');
      debugPrint('Registration ID: $registrationId');
      debugPrint('Admin status: $isAdmin');
      if (registrationId == null) {
        throw Exception('Invalid registration ID.');
      }

      // STEP 2: Get access token
      String? accessToken =
      await LocalDatabase.instance.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token missing. Please login.');
      }

      // STEP 3: First status API call
      debugPrint('STEP 1: Calling membership status API');

      http.Response response = await getMembershipStatus(
        registrationId: registrationId,
        accessToken: accessToken,
      );

      // STEP 4: Check JWT authentication failure
      if (isAuthenticationError(response)) {
        debugPrint('STEP 2: Token expired. Refreshing token.');

        // STEP 5: Refresh token
        final refreshed = await refreshToken();

        if (!refreshed) {
          throw Exception('Token refresh failed. Please login again.');
        }

        // STEP 6: Get new access token
        accessToken =
        await LocalDatabase.instance.getAccessToken();

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('New access token not found.');
        }

        // STEP 7: Retry status API
        debugPrint('STEP 3: Retrying membership status API');

        response = await getMembershipStatus(
          registrationId: registrationId,
          accessToken: accessToken,
        );
      }

      // STEP 8: Check final response
      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Membership status failed: '
              '${response.statusCode} ${response.body}',
        );
      }

      final result =
      jsonDecode(response.body) as Map<String, dynamic>;

      debugPrint('Membership status fetched successfully.');

      return result;

    } catch (e) {
      debugPrint('Membership Status Error: $e');
      rethrow;
    }
  }
  bool isAuthenticationError(http.Response response) {
    if (response.statusCode == 401) {
      return true;
    }

    if (response.statusCode == 400) {
      final body = response.body.toLowerCase();

      return body.contains('token expired') ||
          body.contains('invalid token') ||
          body.contains('jwt authentication failed');
    }

    return false;
  }
  Future<bool> refreshToken() async {
    try {
      final accessToken =
      await LocalDatabase.instance.getAccessToken();

      final refreshToken =
      await LocalDatabase.instance.getRefreshToken();

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        debugPrint('Tokens missing. Please login again.');
        return false;
      }

      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        }),
      );

      debugPrint('Refresh Status: ${response.statusCode}');
      debugPrint('Refresh Response: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        return false;
      }

      final newAccessToken =
      data['accessToken']?.toString();

      final newRefreshToken =
      data['refreshToken']?.toString();

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        return false;
      }

      await LocalDatabase.instance.saveTokens(
        newAccessToken,
        newRefreshToken,
      );

      debugPrint('New tokens saved successfully.');

      return true;
    } catch (e) {
      debugPrint('Refresh Token Error: $e');
      return false;
    }
  }

  Future<void> loadRates() async {
    try {
      final rates = await getLatestRates();

      if (!mounted) return;

      setState(() {
        gold24KPer10Gram = rates['gold24K_Per10Gram']?.toString() ?? '';
        silverPerKg = rates['silver_PerKg']?.toString() ?? '';
        gold22KPer10Gram = rates['gold22K_Per10Gram']?.toString() ?? '';
      });
    } catch (e) {
      debugPrint('Error loading gold rates: $e');
    }
  }
  static const Color navy = Color(0xFF101D2D);
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,

      // --------------------------------------------------
      // DRAWER
      // --------------------------------------------------
      drawer: _buildDrawer(context),

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,

        iconTheme: const IconThemeData(color: lightGold),

        title: const Text(
          'WADNERE JEWELLERS',
          style: TextStyle(
            color: lightGold,
            fontSize: 19,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),

        centerTitle: true,
      ),

      // --------------------------------------------------
      // BODY
      // --------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Image.asset('assets/download.jpg'),
                    width: 100,
                  ),
                  Container(
                    child: Image.asset('assets/download.jpg'),
                    width: 100,
                  ),
                  Container(
                    child: Image.asset('assets/download.jpg'),
                    width: 100,
                  ),
                ],
              ),

              const SizedBox(height: 50),

              LayoutBuilder(
                builder: (context, constraints) {
                  //final isNarrow = constraints.maxWidth < 360;
                  final isNarrow = constraints.maxWidth < 180;
                  final cardWidth = isNarrow
                      ? (constraints.maxWidth - 8) / 2
                      : (constraints.maxWidth - 16) / 3;

                  final cards = [
                    _buildRateCard(
                      title: '24K Gold',
                      rate: '₹$gold24KPer10Gram',
                      subtitle: 'Per 10 gram',
                      icon: Icons.workspace_premium_outlined,
                    ),
                    _buildRateCard(
                      title: '22K Gold',
                      rate: '₹$gold22KPer10Gram',
                      subtitle: 'Per 10 gram',
                      icon: Icons.workspace_premium_outlined,
                    ),
                    _buildRateCard(
                      title: 'Silver',
                      rate: '₹$silverPerKg',
                      subtitle: 'Per kg',
                      icon: Icons.circle_outlined,
                    ),
                  ];

                  return Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: cards.map((card) {
                      return SizedBox(
                        width: cardWidth,
                        child: card,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      title: 'Installment Premium',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () {
                        // Navigate to Installment Premium
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
          if(hasActiveMembership==false)
                  Expanded(
                    child: _buildButton(
                      title: 'Join Membership',
                      icon: Icons.card_membership_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMoneyPage(),
                          ),
                        );
                        // Navigate to Membership
                      },
                    ),
                  ),
                ],
              ),

              // --------------------------------------------------
              // GOLD RATE
              // --------------------------------------------------

              // --------------------------------------------------
              // MEMBERSHIP
              // --------------------------------------------------
              const SizedBox(height: 50),
              // _buildMembershipCard(context),
              Container(child: Image.asset('assets/welcome_image.png')),
              const SizedBox(height: 25),

              // --------------------------------------------------
              // LAST UPDATED
              // --------------------------------------------------
              Center(
                child: Text(
                  'Rates updated today • 10:30 AM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.45),
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      //bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),

        child: Ink(
          height: 75,

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F334A), Color(0xFF142335)],
            ),

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: gold.withOpacity(.65), width: 1),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color: gold.withOpacity(.12),
                    shape: BoxShape.circle,

                    border: Border.all(color: gold.withOpacity(.35)),
                  ),

                  child: Icon(icon, color: gold, size: 21),
                ),

                const SizedBox(width: 10),

                // Title
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: gold.withOpacity(.8),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateCard({
    required String title,
    required String rate,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF18283B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gold.withOpacity(.65), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withOpacity(.12),
              border: Border.all(color: gold.withOpacity(.5)),
            ),

            child: Icon(icon, color: gold, size: 24),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            rate,
            style: const TextStyle(
              color: lightGold,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // MEMBERSHIP CARD
  // ======================================================

  Widget _buildMembershipCard(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),

        gradient: const LinearGradient(
          colors: [Color(0xFFD4A72C), Color(0xFFE3C46B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(Icons.card_membership, color: Colors.black, size: 28),

              SizedBox(width: 10),

              Text(
                'Jewellery Membership',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Join our membership and enjoy exclusive '
            'benefits, offers and rewards.',
            style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 17),

          SizedBox(
            height: 43,

            child: ElevatedButton(
              onPressed: () {
                // Navigate to membership screen
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: lightGold,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'JOIN MEMBERSHIP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .7,
                    ),
                  ),

                  SizedBox(width: 8),

                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // DRAWER
  // ======================================================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: navy,

      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [navy, const Color(0xFF18283B)],
                ),

                border: Border(bottom: BorderSide(color: gold.withOpacity(.5))),
              ),

              child: Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.5),
                    ),

                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          color: lightGold,
                          fontSize: 48,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'WADNERA JEWELARS',
                    style: TextStyle(
                      color: lightGold,
                      fontSize: 19,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Your trusted jewellery partner',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                 // if (isLoggedIn == false)
                  if(isAdmin==true)
                    _drawerItem(
                      context,
                      icon: Icons.login,
                      title: 'Registration',
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                        // Navigate to Login
                      },
                    ),
                  if (isLoggedIn == false)
                  _drawerItem(
                    context,
                    icon: Icons.login,
                    title: 'Login',
                    onTap: () {
                      print('login');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      // Navigate to Login
                    },
                  ),
                  if (isLoggedIn == true)
                  _drawerItem(
                    context,
                    icon: Icons.login,
                    title: 'Logout',
                    onTap: () async {
                      print('Logout');
                      await LocalDatabase.instance.deleteAccessToken();
                      await LocalDatabase.instance.clearDatabase();

                      if (!mounted) return;

                      setState(() {
                        isLoggedIn = false;
                      });

                      Navigator.pop(context);
                      // Navigate to Login
                    },
                  ),


                  _drawerItem(
                    context,
                    icon: Icons.card_membership,
                    title: 'Join Membership',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Membershippage(),
                        ),
                      );
                      // Navigate to Membership
                    },
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.menu_book_outlined,
                    title: 'Passbook',

                    onTap: () async {
                      final customer =
                      await LocalDatabase.instance.getCustomer();

                      if (customer == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Customer details not found'),
                          ),
                        );
                        return;
                      }

                      final registrationId = int.tryParse(
                        customer['registrationId'].toString(),
                      );

                      if (registrationId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid registration ID'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassbookPage(
                            registrationId: 1,
                          ),
                        ),
                      );
                    },

                  ),

                  _drawerItem(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Notification',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Notifications
                    },
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Contact
                    },
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to About
                    },
                  ),

                  _drawerItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Privacy Policy
                    },
                  ),
           if(hasActiveMembership==true)
                  _drawerItem(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'View Membership Card',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembershipCard(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '© ${DateTime.now().year} Wadnere Jewelars',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // DRAWER ITEM
  // ======================================================

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,

      contentPadding: const EdgeInsets.symmetric(horizontal: 22),

      leading: Icon(icon, color: gold, size: 22),

      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),

      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
        size: 20,
      ),
    );
  }

  // ======================================================
  // BOTTOM NAVIGATION
  // ======================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 68,
      color: Colors.white,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _navItem(Icons.home, 'Home', true),

          _navItem(Icons.collections_bookmark_outlined, 'Collections', false),

          _navItem(Icons.person_outline, 'Profile', false),

          _navItem(Icons.phone_outlined, 'Contact', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(icon, size: 21, color: selected ? gold : Colors.grey),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }




    Future<Map<String, dynamic>> getLatestRates() async {
      const String _url =
          'https://dev-wadnerejwellors.runasp.net/api/rates/latest';
      debugPrint('Fetching latest gold and silver rates...');

      final response = await http.get(
        Uri.parse(_url),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Rates API status: ${response.statusCode}');
      debugPrint('Rates API response: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to load rates: HTTP ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected a JSON object from the rates API.',
        );
      }

      return decoded;
    }
  }

