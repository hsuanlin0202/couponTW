import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

Future NonGet(cur_spot) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  final url = 'http://192.168.0.94:12384/restv2/wowso/getLocations';
  //print(url);
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
  print("request=================================");
  print(body);

  HttpClientRequest request = await client.postUrl(Uri.parse(url));

  request.headers.set(
    'content-type',
    'application/json',
  );

  request.add(utf8.encode(json.encode(body)));
  HttpClientResponse responseData = await request.close();
  String reply = await responseData.transform(utf8.decoder).join();
  print("response=================================");
  print(reply);

  return null;
}

Future NonGetReq(cur_spot) async {
  var jsonString = await NonGet(cur_spot);
  print("fin=================================");
  return jsonString;
}
