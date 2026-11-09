
import 'package:flutter/material.dart';
import 'CashfreePaymentService.dart';
import 'LocalDatabase.dart';
import 'cashfree_payment_service.dart';


import 'dart:convert';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:http/http.dart' as http;
/*import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
//import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfcheckouttheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
//import 'package:flutter_cashfree_pg_sdk/utils/cfenvironment.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';*/

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController(text: '500');

  String _purpose = 'Wallet top-up';
  bool _loading = false;

  final _paymentService = CashfreePaymentService();
  static const String baseUrl =
      'https://dev-wadnerejwellors.runasp.net/api/Membership';

  static const String refreshUrl =
      'https://dev-wadnerejwellors.runasp.net/api/Login/refresh-token';
  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    final customer =
    await LocalDatabase.instance.getCustomer();

    if (customer == null) {
      debugPrint('Customer not found. Please login.');
      return;
    }

    debugPrint('Customer found.');
  }

  Future<http.Response> createMembershipOrder({
    required int registrationId,
    required double amount,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/create-order');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${accessToken.trim()}',
      },
      body: jsonEncode({
        'registrationId': registrationId,
        'amount': amount,
      }),
    );

    debugPrint('Create Order Status: ${response.statusCode}');
    debugPrint('Create Order Response: ${response.body}');

    return response;
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
  Future<Map<String, dynamic>> createMembershipOrderWithRefresh({
    required double amount,
  }) async
  {
    try {
      // 1. Get customer details
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

      // 2. Get access token
      String? accessToken =
      await LocalDatabase.instance.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token missing. Please login.');
      }

      // 3. First create-order API call
      debugPrint('STEP 1: Calling create-order API');

      http.Response response = await createMembershipOrder(
        registrationId: registrationId,
        amount: amount,
        accessToken: accessToken,
      );

      // 4. Check authentication failure
      if (isAuthenticationError(response)) {
        debugPrint('STEP 2: Authentication failed. Refreshing token.');

        // 5. Call refresh-token API
        final refreshed = await refreshToken();

        if (!refreshed) {
          throw Exception('Token refresh failed. Please login again.');
        }

        // 6. Get new access token from SQLite
        accessToken =
        await LocalDatabase.instance.getAccessToken();

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('New access token not found.');
        }

        // 7. Retry create-order API using new token
        debugPrint('STEP 3: Retrying create-order API');

        response = await createMembershipOrder(
          registrationId: registrationId,
          amount: amount,
          accessToken: accessToken,
        );
      }

      // 8. Check final response
      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Create order failed: ${response.statusCode} ${response.body}',
        );
      }

      final result =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (result['success'] != true) {
        throw Exception(
          result['message'] ?? 'Order creation failed.',
        );
      }

      debugPrint('Membership order created successfully.');
      _pay();
      return result;
    } catch (e) {
      debugPrint('Membership Order Error: $e');
      rethrow;
    }
  }
  Future<void> onPayButtonPressed() async {
    try {
      final result =
      await createMembershipOrderWithRefresh(amount: 500);

      debugPrint('Order result: $result');

      // Continue with Cashfree payment using the order details.
    } catch (e) {
      debugPrint('Payment initialization failed: $e');
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _paymentService.pay(
        amount: double.parse(_amountController.text.trim()),
        purpose: 'PURPOSE_MEMBERSHIP',
        onPaymentStatus: (status, orderId) {
          if (!mounted) return;

          String message;

          switch (status) {
            case 'VERIFYING':
              message = 'Verifying payment...';
              break;

            case 'PAID':
              message = 'Payment successful!';
              break;

            case 'ACTIVE':
              message = 'Payment is pending confirmation.';
              break;

            case 'VERIFICATION_ERROR':
              message = 'Unable to verify payment. Please try again.';
              break;

            case 'CHECKOUT_ERROR':
              message = 'Cashfree checkout encountered an error.';
              break;

            case 'START_FAILED':
              message = 'Unable to start payment. Check the error logs.';
              break;

            default:
              message = 'Payment status: $status';
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message)),
            );

          debugPrint('Payment status: $status');
          if (orderId.isNotEmpty) {
            debugPrint('Order ID: $orderId');
          }

          if (status == 'PAID') {
            // Refresh the wallet balance here.
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start payment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  static const Color gold = Color(0xFFD4A72C);
  static const Color lightGold = Color(0xFFE3C46B);
  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add Money'),backgroundColor: Colors.white,),
      body:
      SafeArea(

        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.diamond, size: 52),
              const SizedBox(height: 12),
              const Text(
                'Add money to your jeweller account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
/*
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty
                    ? 'Enter customer name'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null ||
                    !RegExp(r'^[6-9]\d{9}$')
                        .hasMatch(v.trim())
                    ? 'Enter a valid 10-digit mobile number'
                    : null,
              ),
              const SizedBox(height: 16),*/

              const Text(
                'Select amount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: ['500', '1000', '2000'].map((value) {
                  return ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Text('₹$value'),
                    selected: _amountController.text == value,
                  //  selectedColor: gold,
                  //  selectedShadowColor: lightGold,

                    onSelected: (_) {
                      setState(() => _amountController.text = value);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (INR)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null ||
                      !value.isFinite ||
                      value < 1 ||
                      value > 100000 ||
                      (value * 100).roundToDouble() != value * 100) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),


              const SizedBox(height: 20),

              Card(
                color: Colors.white,
                child: const ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Cashfree Secure Checkout'),
                  subtitle: Text('UPI, cards and other enabled methods'),
                  trailing: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total payable'),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              FilledButton(
              //  onPressed: _loading ? null : _pay,
                onPressed: _loading ? null : onPayButtonPressed,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text('Proceed to Pay ₹${amount.toStringAsFixed(2)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




/*class CashfreePaymentService {
  // Android emulator. Change this for a physical device or production server.
  static const String backendUrl = 'http://10.0.2.2:5080';

  final CFPaymentGatewayService _cashfree =
  CFPaymentGatewayService();

  Future<void> pay({
    required String customerName,
    required String customerPhone,
    required double amount,
    required String purpose,
  }) async {
    // 1. Create order through your .NET backend.
    final response = await http.post(
      Uri.parse('$backendUrl/api/payments/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': 'demo-customer',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'amount': amount,
        'purpose': purpose,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Order creation failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final orderId = data['orderId'] as String;
    final paymentSessionId = data['paymentSessionId'] as String;

    // 2. Register checkout callbacks.
    _cashfree.setCallback(
          (String returnedOrderId) {
        // The AddMoneyPage should verify the order with the backend
        // after checkout. This callback alone does not prove payment.
        print('Cashfree checkout completed: $returnedOrderId');
      },
          (error, returnedOrderId) {
        print('Cashfree checkout error: ${error.getMessage()}');
      },
    );

    // 3. Create Sandbox session.
    final session = CFSessionBuilder()
        .setEnvironment(CFEnvironment.SANDBOX)
        .setOrderId(orderId)
        .setPaymentSessionId(paymentSessionId)
        .build();

    final theme = CFThemeBuilder()
        .setNavigationBarBackgroundColorColor('#815A24')
        .setNavigationBarTextColor('#FFFFFF')
        .build();
    // 4. Open Cashfree checkout.
    final checkout = CFDropCheckoutPaymentBuilder()
        .setSession(session)
        .setTheme(theme)
        .build();

    _cashfree.doPayment(checkout);
  }
}*/
