import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/models/user_model.dart';

import 'package:joelfindtechnician/partner_state/partner_signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  get form => null;

  final formKey = new GlobalKey<FormState>();

  late String email, password;

  checkFields() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      formKey.currentState!.reset();
      return true;
    }
    return false;
  }

  String? validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp("");
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PartnerSignin(),
            ));
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: ListView(
            children: [
              SizedBox(height: 50),
              Container(
                height: 125,
                width: 200,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Text(
                        "Create",
                        style: GoogleFonts.fredokaOne(
                          fontSize: 60,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Text(
                          "Account",
                          style: GoogleFonts.fredokaOne(
                            fontSize: 60,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
                child: Form(
                  key: formKey,
                  child: Container(
                    child: Column(
                      children: [
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            onChanged: (value) {
                              this.email = value;
                            },
                            validator: (value) => value!.isEmpty
                                ? 'Please Enter Email Address'
                                : validateEmail(value)),
                        TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              this.password = value;
                            },
                            validator: (value) => value!.isEmpty
                                ? 'Please Enter Password'
                                : null),
                        SizedBox(height: 20),
                        Container(
                          height: 50,
                          width: 330,
                          child: OutlinedButton(
                            // color: Colors.blue,
                            onPressed: () async {
                              if (checkFields()) {
                                print('email = $email, password = $password');

                                await Firebase.initializeApp()
                                    .then((value) async {
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .where('email', isEqualTo: email)
                                      .get()
                                      .then((event) async {
                                    if (event.docs.length == 0) {
                                      MyDialog().normalDialog(
                                          context,
                                          'No Email',
                                          'ไม่มี Email นี่ใน ฐานข้อมูล');
                                    } else {
                                      for (var item in event.docs) {
                                        UserModelFirebase userModelFirebase =
                                            UserModelFirebase.fromMap(
                                                item.data());
                                        String docId = item.id;
                                        if (userModelFirebase.accept) {
                                          print('### OK Accept True');

                                          await FirebaseAuth.instance
                                              .createUserWithEmailAndPassword(
                                                  email: email,
                                                  password: password)
                                              .then((value) async {
                                            String uid = value.user!.uid;
                                            print(
                                                'Success Create Account uid = $uid');
                                            Map<String, dynamic> map = {};
                                            map['uid'] = uid;
                                            await FirebaseFirestore.instance
                                                .collection('user')
                                                .doc(docId)
                                                .update(map)
                                                .then((value) {
                                              print('Success Update UID');
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PartnerSignin()),
                                                  (route) => false);
                                            });
                                          }).catchError((value) {
                                            MyDialog().normalDialog(
                                                context,
                                                'Cannot Create Acount',
                                                value.message);
                                          });
                                        } else {
                                          MyDialog().normalDialog(
                                              context,
                                              'Wait Accept',
                                              'รอแป้ป กำลังตรวจสอนอยู่');
                                        }
                                      }
                                    }
                                  });
                                });
                              }
                            },
                            child: Text(
                              "Signup",
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
