import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:vouchersTW/model/nonGet_model.dart';

Future NonGet(cur_spot, c_type) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  final url = 'http://211.21.159.114:80/restv2/wowso/getLocations';
  print(url);
  var now = new DateTime.now();
  String lastUpdated = DateFormat('yyyyMMddkkmmss').format(now);

  Map body = {
    "Version": "01.00",
    "Token": "11",
    "MessageType": "GetLocations",
    "TransactionNumber": lastUpdated,
    "lastUpdatedDateTime": lastUpdated,
    "GetLocationsRequest": cur_spot
  };
  //print("request=================================");
  print(body);

  HttpClientRequest request = await client.postUrl(Uri.parse(url));

  request.headers.set(
    'content-type',
    'application/json',
  );

  request.add(utf8.encode(json.encode(body)));
  HttpClientResponse responseData = await request.close();
  String reply = await responseData.transform(utf8.decoder).join();
  //print("response=================================");
  print(reply);

  var parsedReply = json.decode(reply);
  var response = parsedReply["GetLocationsResponse"];

  List<GetLocationsResponse> locationList = [];
  List finList = [];

  if (response != null) {
    final oriData = getLocationsFromJson(reply);
    locationList = oriData.getLocationsResponse;
    //print("篩遠器在這邊");
    //print(locationList.length);
    for (var i = 0; i < locationList.length; i++) {
      if (locationList[i].couponType == c_type) {
        finList.add(locationList[i]);
      }
    }

    // for (var couponType in locationList) {
    //   print(couponType);
    // }
  }

  return finList;
}

Future NonGetReq(cur_spot, c_type) async {
  var jsonString = await NonGet(cur_spot, c_type);
  //print("fin=================================");
  return jsonString;
}
