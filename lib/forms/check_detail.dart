// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:joelfindtechnician/forms/c.dart';
import 'package:joelfindtechnician/models/appointment_model.dart';
import 'package:joelfindtechnician/models/customer_noti_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_form.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class CheckDetail extends StatefulWidget {
  final CustomerNotiModel? customerNotiModel;
  const CheckDetail({
    Key? key,
    this.customerNotiModel,
  }) : super(key: key);

  @override
  _CheckDetailState createState() => _CheckDetailState();
}

class _CheckDetailState extends State<CheckDetail> {
  File? image;
  int? _selectChoice;

  CustomerNotiModel? customerNotiModel;
  UserModelOld? userModelOld; // สำหรับ หาข้อมูลของช่าง
  AppointmentModel? appointmentModel;

  bool load = true;
  bool? haveData;

  var user = FirebaseAuth.instance.currentUser;

  String? appointDateStr;

  @override
  void initState() {
    super.initState();
    customerNotiModel = widget.customerNotiModel;
    // print('#29mar customerNotiModel ==>> ${customerNotiModel?.toMap()}');
    if (customerNotiModel == null) {
      setState(() {
        load = false;
        haveData = false;
      });
    } else {
      findDataTechnic();
    }
  }

  Future<void> findDataTechnic() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(customerNotiModel!.socialMyNotificationModel!.docIdTechnic)
        .get()
        .then((value) async {
      load = false;

      if (value.data() == null || customerNotiModel == null) {
        haveData = false;
      } else {
        haveData = true;
        userModelOld = UserModelOld.fromMap(value.data()!);
        // print('#29mar userModelOlu ==>> ${userModelOld!.toMap()}');

        String? customerName = customerNotiModel!.customerName;
        String docIdPostcustomer =
            customerNotiModel!.socialMyNotificationModel!.docIdPostCustomer;

        await FirebaseFirestore.instance
            .collection('user')
            .doc(customerNotiModel!.socialMyNotificationModel!.docIdTechnic)
            .collection('appointment')
            .where('customerName', isEqualTo: customerName)
            .where('docIdPostcustomer', isEqualTo: docIdPostcustomer)
            .get()
            .then((value) {
          for (var item in value.docs) {
            // print('#29mar itme== ${item.data()}');
            appointmentModel = AppointmentModel.fromMap(item.data());
            appointDateStr =
                TimeToString(timestamp: appointmentModel!.timeAppointment)
                    .findString();
            setState(() {});
          }
        });
      }

      setState(() {});
    });
  }

  _imageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
    });
  }

  _imageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: newAppBar(context),
      body: load
          ? Center(child: ShowProgress())
          : haveData!
              ? newContent(context)
              : Center(child: ShowText(title: 'No Data')),
    );
  }

  Container newContent(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please pay before :',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Shop name : ${userModelOld!.name}',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer name : ${appointmentModel!.customerName}',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email address : ${appointmentModel!.emailAddress}',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ShowForm(label: 'TaxID', changeFunc: (string) {}),
                    SizedBox(height: 8),
                    Text(
                      'Order number :',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Appointment Date : $appointDateStr',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 3),
                    SizedBox(height: 8),
                    Text(
                      'Address : ',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 3),
                    SizedBox(height: 8),
                    Text(
                      'Detail of work :',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 3),
                    Text(
                      'Total Price :',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 3),
                    Text(
                      'Payment methods :',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Column(
                    // children: [
                    // Row(
                    // children: [
                    // Radio(
                    // activeColor: Colors.amber,
                    // value: 1,
                    // groupValue: _selectChoice,
                    // onChanged: (value) {
                    // setState(() {
                    // _selectChoice = 1;
                    // });
                    // },
                    // ),
                    // SizedBox(width: 10),
                    // Text('QR Code')
                    // ],
                    // ),
                    // Row(
                    // children: [
                    // Radio(
                    // activeColor: Colors.amber,
                    // value: 2,
                    // groupValue: _selectChoice,
                    // onChanged: (value) {
                    // setState(() {
                    // _selectChoice = 2;
                    // });
                    // },
                    // ),
                    // SizedBox(width: 10),
                    // Text(
                    // 'Credit Card',
                    // ),
                    // ],
                    // ),
                    // ],
                    // ),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Card(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: Icon(
                                        Icons.qr_code,
                                      ),
                                    ),
                                    Text(
                                      'QR Code',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.amberAccent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Card(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => c()),
                                          );
                                        },
                                        child: Icon(Icons.credit_card)),
                                    Text(
                                      'Credit card',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.amberAccent,
                            ),
                          ),
                        ],
                      ),

                      // TextButton.icon(
                      // onPressed: () {
                      // showDialog(
                      // context: context,
                      // builder: (BuildContext context) {
                      // return AlertDialog(
                      // title: Center(
                      // child: Text(
                      // 'Choose your slip',
                      // style: GoogleFonts.lato(
                      // fontWeight: FontWeight.bold,
                      // color: Colors.purpleAccent,
                      // ),
                      // ),
                      // ),
                      // content: SingleChildScrollView(
                      // child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // children: [
                      // FlatButton.icon(
                      // onPressed: () {
                      // _imageFromCamera();
                      // Navigator.of(context).pop();
                      // },
                      // icon: Icon(Icons.camera,
                      // color: Colors.purpleAccent),
                      // label: Text('Camera'),
                      // ),
                      // FlatButton.icon(
                      // onPressed: () {
                      // _imageFromGallery();
                      // Navigator.of(context).pop();
                      // },
                      // icon: Icon(
                      // Icons.image,
                      // color: Colors.purpleAccent,
                      // ),
                      // label: Text('Gallery'),
                      // ),
                      // ],
                      // ),
                      // ),
                      // );
                      // },
                      // );
                      // },
                      // icon: Icon(Icons.upload_outlined),
                      // label: Text(
                      // 'Upload Slip',
                      // ),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              child: FlatButton(
                textColor: Colors.white,
                color: Colors.blueAccent,
                onPressed: () {},
                child: Text(
                  'Confirm Payment',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar newAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      title: Text('Check detail'),
    );
  }
}
