import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpError {
  final String title, discription, buttonText;
  SignUpError({
    required this.title,
    required this.discription,
    required this.buttonText,
  });

  Future<bool>? errorsignup(BuildContext context, e) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: dialogContent(context),
        );
      },
    );
  }
}

dialogContent(BuildContext context) {
  String title;
  return Stack(
    children: <Widget>[
      Container(
        padding: EdgeInsets.only(
          top: 100,
          bottom: 16,
          left: 16,
          right: 16,
        ),
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Error",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Same Email",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "ตกลง",
                  style: GoogleFonts.lato(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        left: 16,
        right: 16,
        child: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          radius: 50,
          backgroundImage: AssetImage('assets/images/emoji.png'),
        ),
      ),
    ],
  );
}
