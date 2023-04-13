import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic>? paymentIntentData;

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> data = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: data,
          headers: {
            'Authorization':
                'Bearer (your api key here)',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (e) {
      print('Exception ${e.toString()}');
    }
  }

  calculateAmount(String amount) {
    var price = int.parse(amount) * 100;
    return price.toString();
  }

  Future<void> makePayement() async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        style: ThemeMode.dark,
        // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92'),
        merchantDisplayName: 'Wasib',
      ));
      displayPaymentSheet();
    } catch (e) {
      print('Exception ${e.toString()}');
    }
  }

  displayPaymentSheet() async {
    try {
      Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_outline_outlined,
                              color: Colors.green),
                          Text('Payment Succes'),
                        ],
                      )
                    ],
                  ),
                ));
        paymentIntentData = null;
      });
    } on StripeException catch (e) {
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stripe Gateway'),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                await makePayement();
              },
              child: const Text('Pay')),
        ));
  }
}
