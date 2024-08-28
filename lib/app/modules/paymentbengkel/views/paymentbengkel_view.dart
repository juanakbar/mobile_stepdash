import 'package:get/get.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stepmotor/app/data/user_provider.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../controllers/paymentbengkel_controller.dart';

// class PaymentbengkelView extends GetView<PaymentbengkelController> {
//   const PaymentbengkelView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PaymentbengkelView'),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Text(
//           'PaymentbengkelView is working',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

class PaymentbengkelView extends StatefulWidget {
  const PaymentbengkelView({super.key});

  @override
  State<PaymentbengkelView> createState() => _PaymentbengkelViewState();
}

class _PaymentbengkelViewState extends State<PaymentbengkelView> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    final url = Get.arguments['url'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: WebView(
                initialUrl: url,
                onPageStarted: (url) {
                  setState(() {
                    loadingPercentage = 0;
                  });
                },
                onProgress: (progress) {
                  setState(() {
                    loadingPercentage = progress;
                  });
                },
                onPageFinished: (url) {
                  setState(() {
                    loadingPercentage = 100;
                    print(url);
                    if (url.contains("transaction_status=settlement")) {
                      Get.offAllNamed(Routes.HOME);
                      Get.snackbar("Berhasil", 'Pembayaran Berhasil');
                    }
                  });
                },
                navigationDelegate: (navigation) {
                  final host = Uri.parse(navigation.url).toString();
                  if (host.contains('gojek://') ||
                      host.contains('shopeeid://') ||
                      host.contains('//wsa.wallet.airpay.co.id/') ||
                      // This is handle for sandbox Simulator
                      host.contains('/gopay/partner/') ||
                      host.contains('/shopeepay/') ||
                      host.contains('/pdf')) {
                    _launchInExternalBrowser(Uri.parse(navigation.url));
                    return NavigationDecision.prevent;
                  } else {
                    return NavigationDecision.navigate;
                  }
                },
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInExternalBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
