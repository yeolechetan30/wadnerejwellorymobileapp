
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'LocalDatabase.dart';



class PassbookApp extends StatelessWidget {
  const PassbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Membership Passbook',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF145C45),
        ),
        fontFamily: 'Roboto',
      ),
      home: const PassbookPage(registrationId: 1),
    );
  }
}

// --------------------------------------------------
// MODEL: PAYMENT ENTRY
// --------------------------------------------------

class PaymentEntry {
  final int paymentId;
  final String monthYearDisplay;
  final double amount;
  final DateTime? paymentDate;
  final String orderId;
  final String referenceId;
  final bool isRedeemed;
  final DateTime? redeemedDate;

  PaymentEntry({
    required this.paymentId,
    required this.monthYearDisplay,
    required this.amount,
    required this.paymentDate,
    required this.orderId,
    required this.referenceId,
    required this.isRedeemed,
    required this.redeemedDate,
  });

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      paymentId: json['paymentId'] ?? 0,
      monthYearDisplay: json['monthYearDisplay'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'])
          : null,
      orderId: json['orderId'] ?? '',
      referenceId: json['referenceId'] ?? '',
      isRedeemed: json['isRedeemed'] ?? false,
      redeemedDate: json['redeemedDate'] != null
          ? DateTime.tryParse(json['redeemedDate'])
          : null,
    );
  }
}

// --------------------------------------------------
// MODEL: PASSBOOK RESPONSE
// --------------------------------------------------

class Passbook {
  final int registrationId;
  final String customerName;
  final String membershipCode;
  final DateTime? memberSince;
  final DateTime? membershipValidTill;
  final bool isMembershipActive;
  final double totalSavedAmount;
  final double totalRedeemedAmount;
  final double availableBalance;
  final int totalPaidMonthsCount;
  final List<PaymentEntry> entries;

  Passbook({
    required this.registrationId,
    required this.customerName,
    required this.membershipCode,
    required this.memberSince,
    required this.membershipValidTill,
    required this.isMembershipActive,
    required this.totalSavedAmount,
    required this.totalRedeemedAmount,
    required this.availableBalance,
    required this.totalPaidMonthsCount,
    required this.entries,
  });

  factory Passbook.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] as List? ?? [];

    return Passbook(
      registrationId: json['registrationId'] ?? 0,
      customerName: json['customerName'] ?? '',
      membershipCode: json['membershipCode'] ?? '',
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'])
          : null,
      membershipValidTill: json['membershipValidTill'] != null
          ? DateTime.tryParse(json['membershipValidTill'])
          : null,
      isMembershipActive: json['isMembershipActive'] ?? false,
      totalSavedAmount:
      (json['totalSavedAmount'] as num?)?.toDouble() ?? 0,
      totalRedeemedAmount:
      (json['totalRedeemedAmount'] as num?)?.toDouble() ?? 0,
      availableBalance:
      (json['availableBalance'] as num?)?.toDouble() ?? 0,
      totalPaidMonthsCount: json['totalPaidMonthsCount'] ?? 0,
      entries: entriesJson
          .map((e) => PaymentEntry.fromJson(e))
          .toList(),
    );
  }
}

// --------------------------------------------------
// API SERVICE
// --------------------------------------------------





// Import your models, database and AuthService files.
// import 'passbook_model.dart';
// import 'local_database.dart';
// import 'auth_service.dart';

class PassbookService {
  static const String baseUrl =
      'https://dev-wadnerejwellors.runasp.net/api/MonthlyPayments/passbook';


  static Future<Passbook> getPassbook(int registrationId) async {
    final url = Uri.parse('$baseUrl/$registrationId');

    debugPrint('Passbook API URL: $url');

    String? accessToken =
    await LocalDatabase.instance.getAccessToken();
    print("accessToken:"+accessToken.toString());

    String? refreshToken =
    await LocalDatabase.instance.getRefreshToken();

    debugPrint(
      'Access token available: ${accessToken?.isNotEmpty == true}',
    );

    debugPrint(
      'Refresh token available: ${refreshToken?.isNotEmpty == true}',
    );

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception('Access token missing in SQLite.');
    }

    http.Response response = await _callPassbookApi(
      url,
      accessToken,
    );

    debugPrint('First passbook status: ${response.statusCode}');

    if (response.statusCode == 401) {
      debugPrint('401 received. Calling refresh API...');

      final refreshed = await AuthService.refreshAccessToken();

      if (!refreshed) {
        throw Exception('Token refresh failed. Please login again.');
      }

      accessToken =
      await LocalDatabase.instance.getAccessToken();

      if (accessToken == null || accessToken.trim().isEmpty) {
        throw Exception('New access token missing after refresh.');
      }

      response = await _callPassbookApi(url, accessToken);

      debugPrint('Retry passbook status: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Invalid passbook response.');
      }

      return Passbook.fromJson(jsonData);
    }

    if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    }

    if (response.statusCode == 403) {
      throw Exception('You are not authorized to access this passbook.');
    }

    throw Exception(
      'Passbook API failed: ${response.statusCode}, ${response.body}',
    );
  }


  // Makes one passbook API request.
  static Future<http.Response> _callPassbookApi(
      Uri url,
      String accessToken,
      ) async {
    return await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${accessToken.trim()}',
      },
    ).timeout(const Duration(seconds: 30));
  }
}

class AuthService {
  static const String refreshUrl =
      'https://dev-wadnerejwellors.runasp.net/api/Login/refresh-token';

  static Future<bool> refreshAccessToken() async {
    try {
      final oldAccessToken =
      await LocalDatabase.instance.getAccessToken();

      final oldRefreshToken =
      await LocalDatabase.instance.getRefreshToken();

      if (oldAccessToken == null ||
          oldAccessToken.isEmpty ||
          oldRefreshToken == null ||
          oldRefreshToken.isEmpty) {
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
          'accessToken': oldAccessToken,
          'refreshToken': oldRefreshToken,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Refresh status: ${response.statusCode}');
      debugPrint('Refresh token: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint('Refresh token request failed.');
        return false;
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic> ||
          data['success'] != true) {
        debugPrint('Refresh response unsuccessful.');
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
        debugPrint('New tokens missing from refresh response.');
        return false;
      }

      // Save both newly generated tokens.
      await LocalDatabase.instance.saveTokens(
        newAccessToken,
        newRefreshToken,
      );

      debugPrint('New authentication tokens saved.');

      return true;
    } catch (e, stackTrace) {
      debugPrint('Refresh token error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}


// --------------------------------------------------
// PASSBOOK PAGE
// --------------------------------------------------

class PassbookPage extends StatefulWidget {
  final int registrationId;

  const PassbookPage({
    super.key,
    required this.registrationId,
  });

  @override
  State<PassbookPage> createState() => _PassbookPageState();
}

class _PassbookPageState extends State<PassbookPage> {
  Passbook? passbook;
  bool isLoading = true;
  String? errorMessage;

  static const Color primaryColor = Color(0xFF145C45);
  static const Color backgroundColor = Color(0xFFF5F7F6);

  @override
  void initState() {
    super.initState();
    fetchPassbook();
  }



  Future<void> fetchPassbook() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final customer = await LocalDatabase.instance.getCustomer();

      if (customer == null) {
        throw Exception('Customer not found. Please login.');
      }

      final registrationId = int.tryParse(
        customer['registrationId'].toString(),
      );

      if (registrationId == null) {
        throw Exception('Invalid registration ID.');
      }

      debugPrint('Registration ID: $registrationId');

      // PassbookService automatically handles 401 and token refresh.
      final result = await PassbookService.getPassbook(registrationId);

      debugPrint('Passbook API SUCCESS');
      debugPrint('Customer: ${result.customerName}');
      debugPrint('Balance: ${result.availableBalance}');

      if (!mounted) return;

      setState(() {
        passbook = result;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('PASSBOOK API ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }



  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Passbook',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: fetchPassbook,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : errorMessage != null
          ? buildError()
          : passbook == null
          ? const Center(child: Text('No passbook data found'))
          : buildPassbook(),
    );
  }

  // --------------------------------------------------
  // ERROR VIEW
  // --------------------------------------------------

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 65,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Passbook',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchPassbook,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MAIN PASSBOOK
  // --------------------------------------------------

  Widget buildPassbook() {
    final data = passbook!;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: fetchPassbook,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildMembershipCard(data),

          const SizedBox(height: 20),

          buildSummary(data),

          const SizedBox(height: 24),

          buildMemberInformation(data),

          const SizedBox(height: 24),

          buildPaymentHistory(data),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MEMBERSHIP CARD
  // --------------------------------------------------

  Widget buildMembershipCard(Passbook data) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF145C45),
            Color(0xFF0B382C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'MEMBERSHIP PASSBOOK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: data.isMembershipActive
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.isMembershipActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: data.isMembershipActive
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            data.customerName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Membership ID: ${data.membershipCode}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            formatCurrency(data.availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          Divider(
            color: Colors.white.withOpacity(0.25),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCardFooter(
                'MEMBER SINCE',
                formatDate(data.memberSince),
              ),
              buildCardFooter(
                'VALID TILL',
                formatDate(data.membershipValidTill),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCardFooter(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // SUMMARY CARDS
  // --------------------------------------------------

  Widget buildSummary(Passbook data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: buildSummaryCard(
                'Total Saved',
                formatCurrency(data.totalSavedAmount),
                Icons.savings_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildSummaryCard(
                'Redeemed',
                formatCurrency(data.totalRedeemedAmount),
                Icons.shopping_bag_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: buildSummaryCard(
                'Available Balance',
                formatCurrency(data.availableBalance),
                Icons.account_balance_wallet_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildSummaryCard(
                'Paid Months',
                '${data.totalPaidMonthsCount}',
                Icons.calendar_month_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSummaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MEMBER INFORMATION
  // --------------------------------------------------

  Widget buildMemberInformation(Passbook data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Member Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          buildInfoRow(
            'Customer Name',
            data.customerName,
          ),

          buildInfoRow(
            'Registration ID',
            '${data.registrationId}',
          ),

          buildInfoRow(
            'Membership Code',
            data.membershipCode,
          ),

          buildInfoRow(
            'Member Since',
            formatDate(data.memberSince),
          ),

          buildInfoRow(
            'Valid Till',
            formatDate(data.membershipValidTill),
          ),

          buildInfoRow(
            'Membership Status',
            data.isMembershipActive ? 'Active' : 'Inactive',
            valueColor: data.isMembershipActive
                ? Colors.green
                : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // PAYMENT HISTORY
  // --------------------------------------------------

  Widget buildPaymentHistory(Passbook data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${data.entries.length} Transactions',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (data.entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 45,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'No payment records found',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ...data.entries.map(
                (entry) => buildPaymentItem(entry),
          ),
      ],
    );
  }

  Widget buildPaymentItem(PaymentEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F4ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: primaryColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.monthYearDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(entry.paymentDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(entry.amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: entry.isRedeemed
                          ? Colors.orange.withOpacity(0.12)
                          : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.isRedeemed ? 'REDEEMED' : 'PAID',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: entry.isRedeemed
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),

          const SizedBox(height: 12),

          buildTransactionRow(
            'Payment ID',
            '${entry.paymentId}',
          ),

          const SizedBox(height: 8),

          buildTransactionRow(
            'Order ID',
            entry.orderId,
          ),

          const SizedBox(height: 8),

          buildTransactionRow(
            'Reference ID',
            entry.referenceId,
          ),

          if (entry.isRedeemed) ...[
            const SizedBox(height: 8),
            buildTransactionRow(
              'Redeemed Date',
              formatDate(entry.redeemedDate),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTransactionRow(
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
