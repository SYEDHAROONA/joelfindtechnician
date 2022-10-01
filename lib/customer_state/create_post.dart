import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joelfindtechnician/alertdialog/my_dialog.dart';
import 'package:joelfindtechnician/model.dart';
import 'package:joelfindtechnician/models/notification_model.dart';
import 'package:joelfindtechnician/models/postcustomer_model.dart';
import 'package:joelfindtechnician/models/subdistruct_model.dart';
import 'package:joelfindtechnician/models/token_model.dart';
import 'package:joelfindtechnician/models/typetechnic_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/utility/find_token.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class CreatePost extends StatefulWidget {
  final String province;
  const CreatePost({Key? key, required this.province}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _formKey = GlobalKey<FormState>();
  File? image;
  String? imgUrl;
  List<String> provinces = MyConstant.provinces;

  String? province, amphur, subdistrict, typetechnic;
  bool amphurbool = true;
  bool subdistrictbool = true;
  int? provinceId;
  List<AmphurModel> amphurModels = [];
  List<SubDistrictModel> subdistrictModel = [];
  List<TypeTechnicModel> typetechnicModels = [];
  List<Widget> widgets = [];
  List<bool> typetechnicBool = [];
  List<String> typeTechnicStrings = [];

  bool imageBol = true; // true ==> Non Image
  List<File> files = [];

  TextEditingController addressController = TextEditingController();
  TextEditingController jobDescriptionController = TextEditingController();

  List<String> pathImages = [];
  List<String> titleTypeTechnics = [];

  String? uid, name, pathUrl, token;

  @override
  void initState() {
    super.initState();

    buildSetup();
    findCurrentUser();

    switch (province) {
      case 'เชียงใหม่':
        provinceId = 38;
        findAmphur();
        break;
      case 'กรุงเทพ':
        provinceId = 1;
        findAmphur();
        break;
      case 'ชลบุรี':
        provinceId = 11;
        findAmphur();
        break;
      default:
    }

    readAllType();

    findToken();
  }

  Future<void> findToken() async {
    token = await FindToken().processFindToken();
    print('#6jan token ที่ Create Account Post ==> $token');
  }

  Future<void> findCurrentUser() async {
    await Firebase.initializeApp().then((value) async {
      var firebaseUser = await FirebaseAuth.instance.currentUser;
      uid = firebaseUser!.uid;
      name = firebaseUser.displayName.toString();
      pathUrl = firebaseUser.photoURL;
    });
  }

  void buildSetup() {
    province = widget.province;
  }

  Future<void> readAllType() async {
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('typetechnic')
          .get()
          .then((value) {
        int index = 0;
        for (var item in value.docs) {
          TypeTechnicModel model = TypeTechnicModel.fromMap(item.data());
          setState(() {
            typetechnicModels.add(model);
            titleTypeTechnics.add(model.name);
            typetechnicBool.add(false);
            typeTechnicStrings.add('');
            widgets.add(creatWidget(model, index));
          });
          index++;
        }
      });
    });
  }

  Widget creatWidget(TypeTechnicModel model, int index) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(model.name),
        value: typetechnicBool[index],
        onChanged: (value) {
          setState(() {
            typetechnicBool[index] = !typetechnicBool[index];
            print('### typetechnicBool ==> $typetechnicBool');
          });
        },
      );

  _imageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, maxWidth: 800, maxHeight: 800);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      imageBol = false;
      image = pickedImageFile;
      files.add(image!);
    });
  }

  _imageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      imageBol = false;
      image = pickedImageFile;
      files.add(image!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(context),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildJobDescription(),
                  SizedBox(height: 15),
                  imageBol ? SizedBox() : listImage(),
                  buildAddress(),
                  ShowText(
                    title: 'จังหวัด ${province!}',
                    textStyle: MyConstant().h2Style(),
                  ),
                  amphurbool
                      ? SizedBox()
                      : amphur == null
                          ? buildAmphur()
                          : Text('อำเภอ ${amphur!}'),
                  subdistrictbool
                      ? SizedBox()
                      : subdistrict == null
                          ? buildSubDistrict()
                          : Text('ตำบล ${subdistrict!}'),
                  buildJobType(context),
                  newPostButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container newPostButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 50,
      width: 330,
      child: OutlinedButton(
        // textColor: Colors.white,
        // color: Colors.blueAccent,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (amphur?.isEmpty ?? true) {
              MyDialog().normalDialog(context, 'โปรดเลือกอำเภอ', '');
            } else if (subdistrict?.isEmpty ?? true) {
              MyDialog().normalDialog(context, 'โปรดเลือกตำบล', '');
            } else if (checkChooseType()) {
              processSentNotification();

              processPostData();
            } else {
              MyDialog().normalDialog(context, 'โปรดเลือกประเภทของงาน', '');
            }
          }
        },
        child: Text(
          'Post',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(20),
        ),
      // ),
    );
  }

  Future<void> processSentNotification() async {
    List<String> typeTechnics = [];
    for (var item in typeTechnicStrings) {
      if (item.isNotEmpty) {
        typeTechnics.add(item);
      }
    }
    print(
        '@@@@ province ==> $province, typeTech ==> $typeTechnics, job ==> ${jobDescriptionController.text}');

    for (var item in typeTechnics) {
      String typeTechnic = item;
      // print('@@@@ item ==>> $item');
      await FirebaseFirestore.instance
          .collection('user')
          .where('province', isEqualTo: province)
          .get()
          .then((value) async {
        for (var item2 in value.docs) {
          UserModelOld userModelOld = UserModelOld.fromMap(item2.data());
          if (checkHaveTypeTechnic(typeTechnic, userModelOld.typeTechnics)) {
            String docIdUser = item2.id;
            await FirebaseFirestore.instance
                .collection('user')
                .doc(docIdUser)
                .collection('mytoken')
                .doc('doctoken')
                .get()
                .then((value) async {
              if (value.data() != null) {
                print('@@@@@ value token ==>> ${value.data()}');
                // ยิ้ง Api
                TokenModel model = TokenModel.fromMap(value.data()!);
                String token = model.token;
                String title = 'หาช่าง $province';
                String body = jobDescriptionController.text;
                String apiSentNotification =
                    'https://www.androidthai.in.th/eye/apiNotification.php?isAdd=true&token=$token&title=$title&body=$body';

                await Dio().get(apiSentNotification).then((value) async {
                  print('#6jan success sent Noti');

                  await Firebase.initializeApp().then((value) async {
                    DateTime dateTime = DateTime.now();
                    Timestamp timeNoti = Timestamp.fromDate(dateTime);
                    NotificationModel model = NotificationModel(
                      title: title,
                      message: body,
                      status: 'unread',
                      timeNoti: timeNoti,
                      token: this.token!, 
                      uidCustomer: uid!,
                      
                    );
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(docIdUser)
                        .collection('mynotification')
                        .doc()
                        .set(model.toMap())
                        .then((value) => print('@@@@@@ insert Noti success'));
                  });
                });
              }
            });
          }
        }
      });
    }
  }

  bool checkHaveTypeTechnic(String typeTechnic, List<String> typeTechnics) {
    print('@@@@ typeTechnic ==> $typeTechnic');
    print('@@@@ typeTechnic ==> $typeTechnics');
    bool result = false; // true มี typeTechnic ใน typeTechnics
    for (var item in typeTechnics) {
      if (typeTechnic == item) {
        result = true;
      }
    }
    print('@@@@ result ==>>> $result');
    return result;
  }

  Widget listImage() => SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: files.length,
          itemBuilder: (context, index) => Container(
            margin: EdgeInsets.only(right: 4),
            width: 48,
            height: 48,
            child: Image.file(
              files[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

  AppBar buildAppbar(BuildContext context) {
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
      title: Text('Create Post'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              if (files.length < 6) {
                buildImageDialog(context);
              } else {
                MyDialog().normalDialog(context, 'รูปภาพไม่ควรเกิน 6 รูป', '');
              }
            },
            icon: Icon(Icons.camera_alt_outlined),
          ),
        ),
      ],
    );
  }

  Future<dynamic> buildImageDialog(BuildContext context) {
    return showDialog(
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
                  icon: Icon(Icons.camera, color: Colors.purpleAccent),
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
  }

  DropdownButton<String> buildProvince() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกจังหวัด'),
      onChanged: (value) {
        setState(() {
          if (amphurModels.isNotEmpty) {
            amphurModels.clear();
            amphur = null;
            subdistrictModel.clear();
            subdistrictbool = true;
          }
          province = value;

          switch (province) {
            case 'เชียงใหม่':
              provinceId = 38;
              findAmphur();

              break;
            case 'กทม':
              provinceId = 1;
              findAmphur();
              break;
            case 'ชลบุรี':
              provinceId = 11;
              findAmphur();
              break;
            default:
          }
        });
      },
      value: province,
      items: provinces
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e),
              value: e,
            ),
          )
          .toList(),
    );
  }

  Future<void> findAmphur() async {
    print('### province_id = $provinceId');
    String apiAmphur =
        'https://www.androidthai.in.th/eye/Amphur.php?isAdd=true&province_id=$provinceId';
    await Dio().get(apiAmphur).then((value) {
      for (var item in json.decode(value.data)) {
        AmphurModel model = AmphurModel.fromMap(item);
        // print('### amphure ==>> ${model.name_th}');

        setState(() {
          amphurModels.add(model);
          amphurbool = false;
        });
      }
      // print('### value amphur == $value');
    });
  }

  DropdownButton<String> buildAmphur() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกอำเภอ'),
      onChanged: (value) {
        setState(() {
          if (subdistrictModel.isNotEmpty) {
            subdistrictModel.clear();
            subdistrictbool = true;
          }

          amphur = value;
          subdistrictbool = false;
          findSubDistrict(amphur!);
        });
      },
      value: amphur,
      items: amphurModels
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e.name_th),
              value: e.name_th,
            ),
          )
          .toList(),
    );
  }

  Future<void> findSubDistrict(String nameAmphure) async {
    String amphure_id = '';
    for (var item in amphurModels) {
      if (nameAmphure == item.name_th) {
        amphure_id = item.id;
      }
    }

    print('### amphur_id ==>> $amphure_id');

    String apiSubDisTrict =
        'https://www.androidthai.in.th/eye/getDistriceByAmphure.php?isAdd=true&amphure_id=$amphure_id';
    await Dio().get(apiSubDisTrict).then((value) {
      for (var item in json.decode(value.data)) {
        SubDistrictModel model = SubDistrictModel.fromMap(item);
        setState(() {
          subdistrictModel.add(model);
        });
      }
    });
  }

  DropdownButton<String> buildSubDistrict() {
    return DropdownButton<String>(
      hint: Text('โปรดเลือกตำบล'),
      onChanged: (value) {
        setState(() {
          subdistrict = value;
        });
      },
      value: subdistrict,
      items: subdistrictModel
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e.name_th),
              value: e.name_th,
            ),
          )
          .toList(),
    );
  }

  Widget buildJobType(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ShowText(
              title: 'ประเภทของงาน',
              textStyle: MyConstant().h2Style(),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: typetechnicModels.length,
          itemBuilder: (context, index) => CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(typetechnicModels[index].name),
            value: typetechnicBool[index],
            onChanged: (value) {
              setState(() {
                typetechnicBool[index] = value!;
                if (value) {
                  typeTechnicStrings[index] = titleTypeTechnics[index];
                } else {
                  typeTechnicStrings.remove(titleTypeTechnics[index]);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  TextFormField buildAddress() {
    return TextFormField(
      controller: addressController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please fill your address';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Address",
        labelStyle: GoogleFonts.lato(
          color: Colors.grey,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextFormField buildJobDescription() {
    return TextFormField(
      controller: jobDescriptionController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please type job description';
        } else {}
      },
      maxLines: 10,
      decoration: InputDecoration(
        labelText: 'Job Description',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  bool checkChooseType() {
    bool result = false; // false ==> ยังไม่ได้เลือก
    for (var item in typetechnicBool) {
      if (item) {
        result = true;
      }
    }
    return result;
  }

  Future<void> processInsertData() async {
    String job = jobDescriptionController.text;
    String address = addressController.text;
    DateTime dateTime = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(dateTime);
    print('##### timestamp = $timestamp');
    print('##### typeTech ==> $typeTechnicStrings');
    print([job, address]);

    PostCustomerModel postCustomerModel = PostCustomerModel(
        address: address,
        amphur: amphur!,
        district: subdistrict!,
        job: job,
        pathImages: pathImages,
        province: province!,
        timePost: timestamp,
        typeTechnics: typeTechnicStrings,
        uidCustomer: uid!,
        name: name!,
        pathUrl: pathUrl!,
        status: 'online',
        token: token ?? '', socialReaded: false);

    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('postcustomer')
          .doc()
          .set(postCustomerModel.toMap())
          .then((value) {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    });
  }

  Future<void> processPostData() async {
    MyDialog().processDialog(context);
    if (!imageBol) {
      print('##### // Status Have Image');
      for (var item in files) {
        int i = Random().nextInt(100000);
        String nameImage = '${uid}$i.jpg';

        await Firebase.initializeApp().then((value) async {
          for (var item in files) {
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference reference =
                storage.ref().child('customerpost/$nameImage');
            UploadTask task = reference.putFile(item);
            await task.whenComplete(() async {
              await reference.getDownloadURL().then((value) {
                pathImages.add(value);
              });
            });
          }
        });
      }

      print('pathImages = $pathImages');
      processInsertData();
    } else {
      print('##### // Non Image');
      processInsertData();
    }
  }
}
