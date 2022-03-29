import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joelfindtechnician/customer_state/social_service.dart';
import 'package:joelfindtechnician/forms/formto_technician.dart';
import 'package:joelfindtechnician/models/appointment_model.dart';
import 'package:joelfindtechnician/models/notification_model.dart';
import 'package:joelfindtechnician/models/partner_noti_model.dart';
import 'package:joelfindtechnician/models/user_model_old.dart';
import 'package:joelfindtechnician/state/community_page.dart';
import 'package:joelfindtechnician/partner_state/home_page.dart';
import 'package:joelfindtechnician/partner_state/mywallet.dart';
import 'package:joelfindtechnician/partner_state/partner_aboutus.dart';
import 'package:joelfindtechnician/partner_state/partner_contactus.dart';
import 'package:joelfindtechnician/partner_state/partner_howtouseapp.dart';
import 'package:joelfindtechnician/partner_state/partner_orderhistory.dart';
import 'package:joelfindtechnician/partner_state/partner_signin.dart';
import 'package:joelfindtechnician/partner_state/partner_termandconditon.dart';
import 'package:joelfindtechnician/state/showDetail_Noti.dart';
import 'package:joelfindtechnician/utility/my_constant.dart';
import 'package:joelfindtechnician/utility/time_to_string.dart';
import 'package:joelfindtechnician/widgets/show_progress.dart';
import 'package:joelfindtechnician/widgets/show_text.dart';

class PartnerNotification extends StatefulWidget {
  final String? docUser;
  final UserModelOld? userModelold;
  const PartnerNotification({Key? key, this.docUser, this.userModelold})
      : super(key: key);

  @override
  _PartnerNotificationState createState() => _PartnerNotificationState();
}

class _PartnerNotificationState extends State<PartnerNotification> {
  String? docUser;
  bool load = true;
  bool? haveData;
  UserModelOld? userModelOld;

  List<NotificationModel> notificationModels = [];

  var appointMentModels = <AppointmentModel>[];
  var partnerNotiModels = <PartnerNotiModel>[];
  var partnerNotiModelsorteds = <PartnerNotiModel>[];

  @override
  void initState() {
    super.initState();
    docUser = widget.docUser;
    userModelOld = widget.userModelold;
    readAllNoti();
  }

  Future<void> readAllNoti() async {
    //for myNotifiaction
    await Firebase.initializeApp().then((value) async {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(docUser)
          .collection('mynotification')
          .orderBy('timeNoti', descending: true)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          setState(() {
            load = false;
            haveData = false;
          });
        } else {
          for (var item in value.docs) {
            NotificationModel model = NotificationModel.fromMap(item.data());
            PartnerNotiModel partnerNotiModel = PartnerNotiModel(
              title: model.message,
              timestamp: model.timeNoti,
              bolCollection: true,
              status: model.status,
              docId: item.id,
            );
            setState(() {
              load = false;
              haveData = true;
              notificationModels.add(model);
              partnerNotiModels.add(partnerNotiModel);
            });
          }
        }
      });
    });

    //for appointment
    await FirebaseFirestore.instance
        .collection('user')
        .doc(docUser)
        .collection('appointment')
        .orderBy('timeAppointment', descending: true)
        .get()
        .then((value) {
      for (var item in value.docs) {
        AppointmentModel appointmentModel =
            AppointmentModel.fromMap(item.data());
        PartnerNotiModel partnerNotiModel = PartnerNotiModel(
          title: appointmentModel.nameSocial,
          timestamp: appointmentModel.timeContact,
          bolCollection: false,
          status: appointmentModel.approve,
          docId: item.id,
          appointmentModel: appointmentModel,
        );
        setState(() {
          appointMentModels.add(appointmentModel);
          partnerNotiModels.add(partnerNotiModel);
        });
      }
    });
    var partnerNotiMaps = <Map<String, dynamic>>[];

    for (var item in partnerNotiModels) {
      var partnerNotiMap = item.toMap();
      partnerNotiMaps.add(partnerNotiMap);
    }
    print('#1feb partnerNOtiMap ==> $partnerNotiMaps');
    partnerNotiMaps.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    print(
        '#1feb ################## partnerNOtiMap sorted ==> $partnerNotiMaps');
    for (var item in partnerNotiMaps) {
      PartnerNotiModel partnerNotiModel = PartnerNotiModel.fromMap(item);
      setState(() {
        partnerNotiModelsorteds.add(partnerNotiModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: newAppBar(context),
      body: load
          ? ShowProgress()
          : haveData!
              ? oldListView()
              : Center(
                  child: ShowText(
                    title: 'ไม่มีการแจ้งเตือน',
                  ),
                ),
    );
  }

  ListView testListView() {
    return ListView.builder(
      itemCount: partnerNotiModelsorteds.length,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShowText(title: partnerNotiModelsorteds[index].title),
          ShowText(
              title: TimeToString(
                      timestamp: partnerNotiModelsorteds[index].timestamp)
                  .findString()),
        ],
      ),
    );
  }

  ListView oldListView() {
    return ListView.builder(
        itemCount: partnerNotiModelsorteds.length,
        itemBuilder: (context, index) => buildContent(
              partnerNotiModelsorteds[index].title,
              TimeToString(timestamp: partnerNotiModelsorteds[index].timestamp)
                  .findString(),
              partnerNotiModelsorteds[index].status,
              'title',
              partnerNotiModelsorteds[index].docId,
              partnerNotiModelsorteds[index].bolCollection,
              partnerNotiModelsorteds[index].appointmentModel,
              appointMentModels[index].customerName,
            ));
  }

  Widget buildContent(
    String message,
    String dateStr,
    String status,
    String title,
    String docId,
    bool bolCollection,
    AppointmentModel? appointmentModel,
    String customerName, //true ==> myNotificatio, false ==> appointment
  ) {
    return GestureDetector(
      onTap: () {
        print('#28Nov Click message ==> $message');
        if (bolCollection) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailNoti(
                  userModelOld: userModelOld!,
                  title: title,
                  message: message,
                ),
              ));
        } else {
          print('#2feb customerName ==>> ${appointmentModel?.customerName}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormtoTechnician(
                  docIdAppointment: docId,
                  appointmentModel: appointmentModel!,
                  customerName: customerName,
                ),
              ));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
                child: Container(
                  width: 200,
                  child: ShowText(
                    title: message,
                    textStyle: status == 'unread'
                        ? MyConstant().h2Style()
                        : MyConstant().h4Style(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  dateStr,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
      title: Text('Partner Notification'),
    );
  }
}
