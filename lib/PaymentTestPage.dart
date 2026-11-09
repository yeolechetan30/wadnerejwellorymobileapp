
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
//import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfcheckouttheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
//import 'package:flutter_cashfree_pg_sdk/utils/cfenvironment.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:http/http.dart' as http;

class PaymentTestPage extends StatefulWidget {
  const PaymentTestPage({super.key});

  @override
  State<PaymentTestPage> createState() => _PaymentTestPageState();
}

class _PaymentTestPageState extends State<PaymentTestPage> {
  final CFPaymentGatewayService cashfree =
  CFPaymentGatewayService();

  String result = 'Tap the button to open Cashfree Checkout';

  @override
  void initState() {
    super.initState();

    cashfree.setCallback(
          (orderId) {
        setState(() {
          result = 'Checkout callback received for order: $orderId';
        });
      },
          (error, orderId) {
        setState(() {
          result = 'Error for order $orderId: $error';
        });
      },
    );
  }

  void openCheckout() {
    // Replace with the order_id from the SAME Postman response.
    const orderId = 'jewel_topup_10001';

    // Use the payment_session_id returned by Postman.
    const paymentSessionId = 'session_60nVQNDyHRZGVXkBIhCj561nzucIfAhNMjuP0sGVuHlYjivenF3ensLegT_pvKWAOSuNij37JucFgw6pPy4hAXdGDA37tbjYY6HpWWhA3PX_vxvwDJKxtyCZxbfWZgpaymentpayment';

    try {
      final session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor('#6A1B9A')
          .setNavigationBarTextColor('#FFFFFF')
          .setButtonBackgroundColor('#6A1B9A')
          .setButtonTextColor('#FFFFFF')
          .build();

      final checkout = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();

      setState(() {
        result = 'Opening Cashfree Checkout...';
      });

      cashfree.doPayment(checkout);
    } catch (e) {
      setState(() {
        result = 'Could not open checkout: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashfree Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: openCheckout,
              child: const Text('Open Cashfree Checkout'),
            ),
            const SizedBox(height: 20),
            Text(result),
          ],
        ),
      ),
    );
  }
}