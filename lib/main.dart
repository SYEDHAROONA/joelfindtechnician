// @dart=2.9

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:joelfindtechnician/customer_state/create_post.dart';
import 'package:joelfindtechnician/customer_state/ctm_notification.dart';
import 'package:joelfindtechnician/customer_state/ctm_ordethistory.dart';
import 'package:joelfindtechnician/customer_state/login_success.dart';
import 'package:joelfindtechnician/forms/check_detail.dart';
import 'package:joelfindtechnician/forms/confirm_job.dart';

import 'package:joelfindtechnician/forms/formcontact_partner.dart';
import 'package:joelfindtechnician/forms/formto_technician.dart';
import 'package:joelfindtechnician/forms/job_done.dart';
import 'package:joelfindtechnician/partner_state/home_page.dart';
import 'package:joelfindtechnician/partner_state/mywallet.dart';
import 'package:joelfindtechnician/partner_state/partner_notification.dart';
import 'package:joelfindtechnician/partner_state/partner_orderhistory.dart';
import 'package:joelfindtechnician/forms/c.dart';
import 'package:joelfindtechnician/state/community_page.dart';
import 'package:joelfindtechnician/state/detail_noti_social.dart';
import 'package:joelfindtechnician/state/list_technic_where_type.dart';
import 'package:joelfindtechnician/state/login_page.dart';
import 'package:joelfindtechnician/state/show_general_profile.dart';
import 'package:joelfindtechnician/state/show_profile.dart';

final Map<String, WidgetBuilder> map = {
  // '/loginPage': (BuildContext context) => LoginPage(),
  // '/homePage': (BuildContext context) => HomePage(),
  // '/authenAdmin': (BuildContext context) => AuthenAdmin(),
  // '/adminService': (BuildContext context) => AdminService(),
  // '/myReferance': (BuildContext context) => MyReferance(),
  // '/addReferance': (BuildContext context) => AddReferance(),
};

String firstPage;

Future main() async {
  HttpOverrides.global = MyHttpOverride();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // firstPage = '/loginPage';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginPage(), 
      home: DetailNotiSocial(reply: 'helloUng2'),
     
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '',
              height: 120,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cer, String host, int port) => true;
  }
}
