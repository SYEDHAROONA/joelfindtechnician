import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/customer_state/social_service.dart';
import 'package:joelfindtechnician/partner_state/partner_signin.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final formKey = new GlobalKey<FormState>();

  late String email;

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
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => PartnerSignin()));
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
                        "Forget",
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
                          "Password",
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
                        SizedBox(height: 20),
                        Container(
                          height: 50,
                          width: 330,
                          child: OutlinedButton(
                            //color: Colors.blue,
                            onPressed: () {
                              if (checkFields())
                                SocialService()
                                    .resetPasswordLink(email, context);
                            },
                            child: Text(
                              "Submit",
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
                        //),
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
