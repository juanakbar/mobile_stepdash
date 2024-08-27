// import 'package:flutter/material.dart';

import 'package:get/get.dart';

// import '../controllers/payment_controller.dart';

// class PaymentView extends GetView<PaymentController> {
//   const PaymentView({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PaymentView'),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Text(
//           'PaymentView is working',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stepmotor/app/data/user_provider.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({Key? key}) : super(key: key);
  @override
  State<PaymentView> createState() => PaymentViewState();
}

class PaymentViewState extends State<PaymentView> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    final url = Get.arguments['url'];
    Map<String, dynamic> data = Get.arguments;
    print('INI WEBVIEW: $url');
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
                      Get.offAllNamed(Routes.TRACKING, arguments: data);
                      EasyLoading.show(
                          status:
                              'Pembayaran Berhasil, Sedang Mencari Driver...');
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
