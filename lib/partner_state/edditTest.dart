import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';

class EdditTest extends StatefulWidget {
  final UserModelOld userModelOld;
  const EdditTest({Key? key, required this.userModelOld}) : super(key: key);

  @override
  _EdditTestState createState() => _EdditTestState();
}

class _EdditTestState extends State<EdditTest> {
  final formKey = GlobalKey<FormState>();
  TextEditingController img = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController about = TextEditingController();

  File? image;
  String? imgUrl;
  String? docUserLogin;

  UserModelOld? userModelOld;
  Map<String, dynamic> map = {};

  bool change = false; // false ==> ไม่มีการเปลี่ยนแปลงเลย

  @override
  void initState() {
    super.initState();
    userModelOld = widget.userModelOld;
    name.text = userModelOld!.name;
    about.text = userModelOld!.jobScope;
  }

  _imageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
      change = true;
    });
  }

  _imageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      image = pickedImageFile;
      change = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Eddit Test'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: image == null ? currentAvatar() : fileAvatar(),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextFormField(
                          onChanged: (value) => change = true,
                          controller: name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Fill Name';
                            } else {}
                          },
                          decoration: InputDecoration(
                            labelText: "Name",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            labelStyle: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextFormField(
                          onChanged: (value) => change = true,
                          controller: about,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Fill About';
                            } else {}
                          },
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: "About",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            labelStyle: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Container(
                          height: 50,
                          width: 350,
                          child: OutlinedButton(
                            //color: Colors.blue,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (change) {
                                  print('### have change');

                                  if (image == null) {
                                    processUpdateProfile();
                                  } else {
                                    processUploadAvatar();
                                  }
                                } else {
                                  MyDialog()
                                      .normalDialog(context, 'No change ?', '');
                                }
                              }
                            },
                            child: Text(
                              'Update Profile',
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
                        ),
                     // ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 30,
                child: RawMaterialButton(
                  elevation: 10,
                  fillColor: Colors.blueGrey,
                  child: Icon(Icons.add_a_photo),
                  padding: EdgeInsets.all(5),
                  shape: CircleBorder(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Center(
                            child: Text(
                              'Choose Profile Photo',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                              ),
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _imageFromCamera();
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.camera,
                                      color: Colors.purpleAccent),
                                  label: Text('Camera'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _imageFromGallery();
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.purpleAccent,
                                  ),
                                  label: Text('Gallery'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> processUploadAvatar() async {
    await Firebase.initializeApp().then((value) async {
      int i = Random().nextInt(100000);
      String nameImage = 'editimages$i.jpg';

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference reference = storage.ref().child('Images/$nameImage');
      UploadTask task = reference.putFile(image!);
      await task.whenComplete(() async {
        await reference.getDownloadURL().then((value) {
          String urlImage = value;
          // print('### urlImage = $urlImage');
          map['img'] = urlImage;
          processUpdateProfile();
        });
      });
    });
  }

  Future<void> processUpdateProfile() async {
    map['name'] = name.text;
    map['jobScope'] = about.text;
    print('### map = ==> $map');

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: userModelOld!.uid)
          .get()
          .then((value) async {
        for (var item in value.docs) {
          String docId = item.id;
          print('### docId ==> $docId');

          await FirebaseFirestore.instance
              .collection('user')
              .doc(docId)
              .update(map)
              .then((value) => Navigator.pop(context));
        }
      });
    });
  }

  CircleAvatar fileAvatar() {
    return CircleAvatar(
      radius: 35,
      backgroundImage: FileImage(image!),
    );
  }

  CircleAvatar currentAvatar() {
    return CircleAvatar(
        radius: 35,
        backgroundImage: userModelOld!.img.isEmpty
            ? NetworkImage(MyConstant.urlNoAvatar)
            : NetworkImage(userModelOld!.img));
  }
}
