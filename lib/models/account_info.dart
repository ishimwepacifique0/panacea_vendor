import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icupa_vendor/keys.dart';

class AccountInfo {
  String firstName,
      lastName,
      gender,
      identityNo,
      currency,
      countryCode,
      country,
      email,
      city;
  int mobileNo;
  Timestamp idIssue, idExpiry, dbDate;

  AccountInfo({
    required this.firstName,
    required this.lastName,
    required this.mobileNo,
    required this.gender,
    required this.identityNo,
    required this.idIssue,
    required this.idExpiry,
    required this.currency,
    required this.countryCode,
    required this.dbDate,
    required this.country,
    required this.email,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': 'ECO76383823',
      'affiliateCode': 'ENG',
      'firstName': firstName,
      'lastName': lastName,
      'mobileNo': mobileNo,
      'gender': gender,
      'identityNo': identityNo,
      'identityType': 'MOBILE_WALLET_NO',
      'IDIssueDate': idIssue.millisecondsSinceEpoch,
      'IDExpiryDate': idExpiry.millisecondsSinceEpoch,
      'ccy': currency,
      'country': countryCode,
      'branchCode': 'ENG',
      'dateOfBirth': dbDate.millisecondsSinceEpoch,
      'countryOfResidence': country,
      'email': email,
      'street': city,
      'city': city,
      'state': city,
      'secureHash': Keys.secureHash2
    };
  }
}
