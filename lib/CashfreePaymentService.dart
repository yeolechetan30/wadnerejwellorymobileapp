
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
//import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfcheckouttheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
//import 'package:flutter_cashfree_pg_sdk/utils/cfenvironment.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:http/http.dart' as http;

import 'LocalDatabase.dart';

class CashfreePaymentService {

  final CFPaymentGatewayService _cashfree =
  CFPaymentGatewayService();

  // Android emulator: 10.0.2.2 points to your computer.
  static const String baseUrl = 'https://dev-wadnerejwellors.runasp.net/api/Payments';


  Future<void> getRegistrationId() async {
    final customer = await LocalDatabase.instance.getCustomer();

    if (customer == null) {
      print('No customer found. Please log in.');
      return;
    }

    final String registrationId =
    customer['registrationId'] as String;

    print('Registration ID: $registrationId');

    // Use registrationId here.
  }
  Future<void> pay({
    required double amount,
    required String purpose,
    required void Function(String status, String orderId)
    onPaymentStatus,
  }) async {
    String currentStep = 'Starting payment';

    try {
      debugPrint('========== PAYMENT START ==========');

      // STEP 1: Load customer
      currentStep = 'Loading customer from SQLite';
      debugPrint('STEP 1: $currentStep');

      final customer = await LocalDatabase.instance.getCustomer();

      debugPrint('Customer found: ${customer != null}');

      if (customer == null) {
        throw Exception('Customer not found. Please log in again.');
      }

      // STEP 2: Load access token
      currentStep = 'Loading access token';
      debugPrint('STEP 2: $currentStep');

      final token = await LocalDatabase.instance.getAccessToken();

      debugPrint(
        'Access token exists: ${token != null && token.trim().isNotEmpty}',
      );

      if (token == null || token.trim().isEmpty) {
        throw Exception('Access token missing. Please log in again.');
      }

      // STEP 3: Read customer fields
      currentStep = 'Reading customer details';
      debugPrint('STEP 3: $currentStep');

      final registrationId =
          customer['registrationId']?.toString() ?? '';
      final customerName =
          customer['customerName']?.toString() ?? '';
      final mobileNumber =
          customer['mobileNumber']?.toString() ?? '';
      final customerEmail =
          customer['customerEmail']?.toString() ?? '';

      debugPrint('Registration ID: $registrationId');
      debugPrint('Customer name: $customerName');
      debugPrint('Mobile number: $mobileNumber');
      debugPrint('Customer email: $customerEmail');
      debugPrint('Amount: $amount');
      debugPrint('Purpose: $purpose');
      debugPrint('Token: $token');

      if (registrationId.isEmpty ||
          customerName.isEmpty ||
          mobileNumber.isEmpty) {
        throw Exception('Required customer details are missing.');
      }

      if (amount <= 0) {
        throw Exception('Amount must be greater than zero.');
      }

      // STEP 4: Prepare request body
      currentStep = 'Preparing create-order request';
      debugPrint('STEP 4: $currentStep');

      final requestBody = {
        'amount': amount,
        'registrationId': registrationId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': mobileNumber,
        'orderNote': purpose,
      };

      // Safe to print: this body excludes the bearer token.
      debugPrint('Request URL: $baseUrl/create-order');
      debugPrint('Request body: ${jsonEncode(requestBody)}');


      // STEP 5: Send request
      currentStep = 'Sending create-order request';
      debugPrint('STEP 5: $currentStep');

      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('STEP 5 completed: HTTP request returned');
      debugPrint('HTTP status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint('Response headers: ${response.headers}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'API returned HTTP ${response.statusCode}: '
              '${response.body}',
        );
      }

      // STEP 6: Decode JSON
      currentStep = 'Decoding API response';
      debugPrint('STEP 6: $currentStep');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'API response is not a JSON object.',
        );
      }

      debugPrint('JSON decoded successfully');

      // STEP 7: Read Cashfree values
      currentStep = 'Reading orderId and paymentSessionId';
      debugPrint('STEP 7: $currentStep');

      final orderId = decoded['orderId']?.toString();
      final paymentSessionId =
      decoded['paymentSessionId']?.toString();

      debugPrint('Order ID received: ${orderId != null && orderId.isNotEmpty}');
      debugPrint(
        'Payment session received: '
            '${paymentSessionId != null && paymentSessionId.isNotEmpty}',
      );

      if (orderId == null ||
          orderId.isEmpty ||
          paymentSessionId == null ||
          paymentSessionId.isEmpty) {
        throw FormatException(
          'Missing orderId or paymentSessionId. '
              'Response keys: ${decoded.keys.toList()}',
        );
      }

      // STEP 8: Register Cashfree callbacks
      currentStep = 'Registering Cashfree callbacks';
      debugPrint('STEP 8: $currentStep');

      _cashfree.setCallback(
            (String returnedOrderId) async {
          debugPrint('Cashfree success callback received');
          debugPrint('Callback order ID: $returnedOrderId');

          onPaymentStatus('VERIFYING', returnedOrderId);

          try {
            debugPrint('Calling payment status API');

      //      final result = await checkPaymentStatus(returnedOrderId);

          /*  final status = result['status']
                ?.toString()
                .toUpperCase() ??
                'UNKNOWN';*/

         //   debugPrint('Backend payment status: $status');

          //  onPaymentStatus(status, returnedOrderId);
          } catch (e, stackTrace) {
            debugPrint('Payment verification error: $e');
            debugPrintStack(stackTrace: stackTrace);

            onPaymentStatus(
              'VERIFICATION_ERROR',
              returnedOrderId,
            );
          }
        },
            (dynamic error, String returnedOrderId) {
          debugPrint('Cashfree error callback received');
          debugPrint('Order ID: $returnedOrderId');
          debugPrint('Cashfree error: $error');

          onPaymentStatus('CHECKOUT_ERROR', returnedOrderId);
        },
      );

      debugPrint('Cashfree callbacks registered');

      // STEP 9: Build Cashfree session
      currentStep = 'Building Cashfree session';
      debugPrint('STEP 9: $currentStep');

      final session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      debugPrint('Cashfree session built successfully');

      // STEP 10: Build theme
      currentStep = 'Building Cashfree theme';
      debugPrint('STEP 10: $currentStep');

      final theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor('#6A1B9A')
          .setNavigationBarTextColor('#FFFFFF')
          .setButtonBackgroundColor('#6A1B9A')
          .setButtonTextColor('#FFFFFF')
          .build();

      debugPrint('Cashfree theme built successfully');

      // STEP 11: Build checkout
      currentStep = 'Building Drop Checkout';
      debugPrint('STEP 11: $currentStep');

      final checkout = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      debugPrint('Checkout built successfully');

      // STEP 12: Open payment screen
      currentStep = 'Opening Cashfree checkout';
      debugPrint('STEP 12: $currentStep');

      _cashfree.doPayment(checkout);

      debugPrint('doPayment invoked');
      debugPrint('========== PAYMENT INITIALIZED ==========');
    } catch (e, stackTrace) {
      debugPrint('========== PAYMENT ERROR ==========');
      debugPrint('Failed step: $currentStep');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error details: $e');
      debugPrintStack(stackTrace: stackTrace);

      onPaymentStatus('START_FAILED', '');

      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(
      String orderId,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/status/$orderId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to check payment status: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
