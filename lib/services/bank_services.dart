import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icupa_vendor/keys.dart';
import 'package:icupa_vendor/models/account_info.dart';
import 'package:icupa_vendor/utils.dart';

class BankServices {
  static const String baseUrl = 'https://developer.ecobank.com/corporateapi';

  static Future<String?> getAccessToken() async {
    const endPoint = '$baseUrl/user/token';
    final body =
        json.encode({'userId': Keys.userId, 'password': Keys.password});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'developer.ecobank.com'
    };
    try {
      final response = await http.post(
        Uri.parse(endPoint),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final data = response.body;
        final decodedData = jsonDecode(data);
        final accessToken = decodedData['token'];
        return accessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> openXpressAccount(AccountInfo accountInfo) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'developer.ecobank.com',
          'Authorization': 'Bearer $accessToken'
        };
        const endPoint = '$baseUrl/merchant/createexpressaccount';
        final body = jsonEncode(accountInfo.toJson());

        final response = await http.post(
          Uri.parse(endPoint),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 200) {
          final data = response.body;
          final decodedData = jsonDecode(data);
          return decodedData['response_content']['accountNo'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<double> getBalance(String account) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'developer.ecobank.com',
          'Authorization': 'Bearer $accessToken'
        };
        const endPoint = '$baseUrl/merchant/accountbalance';
        final body = jsonEncode({
          'requestId': randomReqId('1423243'),
          'affiliateCode': 'EGH',
          'accountNo': '6500184371',
          'clientId': 'ECO00184371123',
          'companyName': 'ECOBANK TEST CO',
          'secureHash': Keys.secureHash3,
        });

        final response = await http.post(
          Uri.parse(endPoint),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 200) {
          final data = response.body;
          final decodedData = jsonDecode(data);
          return decodedData['response_content']['availableBalance'];
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> makePayment(String account, int amount) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'developer.ecobank.com',
          'Authorization': 'Bearer $accessToken'
        };
        const endPoint = '$baseUrl/merchant/payment';
        final body = jsonEncode({
          'paymentHeader': {
            'clientid': 'ECO00184371123',
            'batchsequence': '1',
            'batchamount': 520,
            'transactionamount': 520,
            'batchid': 'EG1593490',
            'transactioncount': 6,
            'batchcount': 6,
            'transactionid': 'E12T443308',
            'debittype': 'Multiple',
            'affiliateCode': 'EGH',
            'totalbatches': '1',
            'execution_date': formatPDateTime(DateTime.now()),
          },
          'extension': [
            {
              'request_id': randomReqId('EGHTelc'),
              'request_type': 'domestic',
              'creditAccountNo': account,
              'debitAccountNo': '6500184371',
              'amount': amount,
              'ccy': 'GHS',
              'rate_type': 'spot'
            }
          ],
          'secureHash': Keys.secureHash,
        });

        final response = await http.post(
          Uri.parse(endPoint),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> ResendToVendor(
      String Senderaccount, String VendorAccount, double amount) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'developer.ecobank.com',
          'Authorization': 'Bearer $accessToken'
        };
        const endPoint = '$baseUrl/merchant/payment';
        final body = jsonEncode({
          'paymentHeader': {
            'clientid': 'ECO00184371123',
            'batchsequence': '1',
            'batchamount': 520,
            'transactionamount': 520,
            'batchid': 'EG1593490',
            'transactioncount': 6,
            'batchcount': 6,
            'transactionid': 'E12T443308',
            'debittype': 'Multiple',
            'affiliateCode': 'EGH',
            'totalbatches': '1',
            'execution_date': formatPDateTime(DateTime.now()),
          },
          'extension': [
            {
              'request_id': randomReqId('EGHTelc'),
              'request_type': 'domestic',
              'creditAccountNo': Senderaccount,
              'debitAccountNo': VendorAccount,
              'amount': amount,
              'ccy': 'GHS',
              'rate_type': 'spot'
            }
          ],
          'secureHash': Keys.secureHash,
        });

        final response = await http.post(
          Uri.parse(endPoint),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
