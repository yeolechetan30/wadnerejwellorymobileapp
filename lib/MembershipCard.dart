import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'LocalDatabase.dart';

class MembershipCard extends StatefulWidget {
  @override
  State<MembershipCard> createState() => _MembershipCardState();

}

class _MembershipCardState extends State<MembershipCard> {
  static const Color navy = Color(0xFF101D2D);
  static const Color navyDark = Color(0xFF0A1422);
  static const Color navyLight = Color(0xFF1D3046);

  static const Color gold = Color(0xFFD4A72C);
  static const Color goldLight = Color(0xFFE8CB70);
  static const Color goldDark = Color(0xFFB88918);

  static const Color cream = Color(0xFFFFFCF4);
  static const Color textDark = Color(0xFF172333);
  bool hasActiveMembership = false;
  bool canRenew = false;

  String membershipCode = '';
  String membershipFromDate = '';
  String membershipToDate = '';
  String membershipMessage = '';
  dynamic membershipAmount;
  late String firstName;
  late String lastName;
  late String mobileNumber;
  late String anniversaryDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMembershipStatus();
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
         firstName =
            result['registration']?['firstName']?.toString() ?? '';

         lastName = result['registration']?['lastName']?.toString() ?? '';
        mobileNumber = result['registration']?['mobileNumber']?.toString() ?? '';
        anniversaryDate = result['registration']?['anniversaryDate']?.toString() ?? '';
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
    /*final url = Uri.parse(
      '$baseUrl/status/$registrationId',
    );*/
    final url = Uri.parse(
      '$baseUrl/status/1',
    );

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        padding: const EdgeInsets.only(
          top: 50,
          left: 10,
          right: 10,
          bottom: 50
        ),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                Container(
                  margin: EdgeInsets.only(left: 10,right: 10,bottom: 30),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(22),
                  ),
                //  height: 100,
                  width: double.infinity,
                  child: Card(
                    color: navy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                          'Gold Savings Code',style: TextStyle(fontSize: 20,color: gold, fontWeight:
                        FontWeight.w800,),
                        ),),
                        Container(
                          margin: EdgeInsets.only(left: 15,bottom: 5),
                          height: 25,
                          width: 50,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            '$membershipCode',style: TextStyle(fontSize: 16,color: Colors.white, fontWeight:
                          FontWeight.w400,),
                          ),),
                        Container(
                          padding: EdgeInsets.only(left: 15,top: 5),
                          child: Row(
                            children: [
                              Container(child: Text('Name :',style: TextStyle(fontSize: 16,color: Colors.white, fontWeight:
                              FontWeight.w100,),),),
                              SizedBox(width: 10,),
                              Container(child: Text('$firstName $lastName',style: TextStyle(fontSize: 15,color: Colors.white, fontWeight:
                              FontWeight.w400,),),)
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15,top: 5),
                          child: Row(
                            children: [
                              Container(child: Text('Mobile :',style: TextStyle(fontSize: 16,color: Colors.white, fontWeight:
                              FontWeight.w100,),),),
                              SizedBox(width: 10,),
                              Container(child: Text('$mobileNumber ',style: TextStyle(fontSize: 15,color: Colors.white, fontWeight:
                              FontWeight.w400,),),)
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15,top: 5,bottom: 5),
                          child: Row(
                            children: [
                              Container(child: Text('Anniversary :',style: TextStyle(fontSize: 16,color: Colors.white, fontWeight:
                              FontWeight.w100,),),),
                              SizedBox(width: 10,),
                              Container(child: Text('$anniversaryDate' ,style: TextStyle(fontSize: 15,color: Colors.white, fontWeight:
                              FontWeight.w400,),),)
                            ],
                          ),
                        ),// Your widgets here
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            navyDark,
            navy,
            navyLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: const Border(
          bottom: BorderSide(
            color: gold,
            width: 4,
          ),
        ),
          borderRadius: BorderRadius.only(topRight: Radius.circular(22),topLeft: Radius.circular(22)),
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 21,
      ),

      child: Row(
        children: [

          // PREMIUM ICON
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: gold.withOpacity(.12),
              shape: BoxShape.circle,

              border: Border.all(
                color: gold,
                width: 1.2,
              ),
            ),

            child: const Icon(
              Icons.card_membership_outlined,
              color: goldLight,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              'Virtual MembershipCard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: .3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}