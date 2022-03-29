import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SocialMyNotificationModel {
  final String docIdPostCustomer;
  final String docIdTechnic;
  final Timestamp timeConfirm;
  final bool readed;
  final String customerName;
  final String detailOfWork;
  final String waranty;
  final String totalPrice;
  SocialMyNotificationModel({
    required this.docIdPostCustomer,
    required this.docIdTechnic,
    required this.timeConfirm,
    required this.readed,
    required this.customerName,
    required this.detailOfWork,
    required this.waranty,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docIdPostCustomer': docIdPostCustomer,
      'docIdTechnic': docIdTechnic,
      'timeConfirm': timeConfirm,
      'readed': readed,
      'customerName': customerName,
      'detailOfWork': detailOfWork,
      'waranty': waranty,
      'totalPrice': totalPrice,
    };
  }

  factory SocialMyNotificationModel.fromMap(Map<String, dynamic> map) {
    return SocialMyNotificationModel(
      docIdPostCustomer: (map['docIdPostCustomer'] ?? '') as String,
      docIdTechnic: (map['docIdTechnic'] ?? '') as String,
      timeConfirm: (map['timeConfirm']),
      readed: (map['readed'] ?? false) as bool,
      customerName: (map['customerName'] ?? '') as String,
      detailOfWork: (map['detailOfWork'] ?? '') as String,
      waranty: (map['waranty'] ?? '') as String,
      totalPrice: (map['totalPrice'] ?? '') as String,
    );
  }

  factory SocialMyNotificationModel.fromJson(String source) =>
      SocialMyNotificationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
