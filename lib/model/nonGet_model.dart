// To parse this JSON data, do
//
//     final getLocations = getLocationsFromJson(jsonString);

import 'dart:convert';

GetLocations getLocationsFromJson(String str) =>
    GetLocations.fromJson(json.decode(str));

String getLocationsToJson(GetLocations data) => json.encode(data.toJson());

class GetLocations {
  GetLocations({
    this.transactionNumber,
    this.transactionDateTime,
    this.originalTransactionNumber,
    this.getLocationsResponse,
  });

  String transactionNumber;
  String transactionDateTime;
  String originalTransactionNumber;
  List<GetLocationsResponse> getLocationsResponse;

  factory GetLocations.fromJson(Map<String, dynamic> json) => GetLocations(
        transactionNumber: json["TransactionNumber"],
        transactionDateTime: json["TransactionDateTime"],
        originalTransactionNumber: json["OriginalTransactionNumber"],
        getLocationsResponse: List<GetLocationsResponse>.from(
            json["GetLocationsResponse"]
                .map((x) => GetLocationsResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "TransactionNumber": transactionNumber,
        "TransactionDateTime": transactionDateTime,
        "OriginalTransactionNumber": originalTransactionNumber,
        "GetLocationsResponse":
            List<dynamic>.from(getLocationsResponse.map((x) => x.toJson())),
      };
}

class GetLocationsResponse {
  GetLocationsResponse({
    this.googlePlaceId,
    this.couponType,
    this.storeName,
    this.telephone,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.webSite,
    this.facebook,
  });

  String googlePlaceId;
  String couponType;
  String storeName;
  String telephone;
  String address;
  String latitude;
  String longitude;
  String description;
  dynamic webSite;
  dynamic facebook;

  factory GetLocationsResponse.fromJson(Map<String, dynamic> json) =>
      GetLocationsResponse(
        googlePlaceId: json["GooglePlaceID"],
        couponType: json["CouponType"],
        storeName: json["StoreName"],
        telephone: json["Telephone"],
        address: json["Address"],
        latitude: json["Latitude"],
        longitude: json["Longitude"],
        description: json["Description"],
        webSite: json["WebSite"] == null ? "" : json["WebSite"].trim(),
        facebook: json["Facebook"] == null ? "" : json["Facebook"].trim(),
      );

  Map<String, dynamic> toJson() => {
        "GooglePlaceID": googlePlaceId,
        "CouponType": couponType,
        "StoreName": storeName,
        "Telephone": telephone,
        "Address": address,
        "Latitude": latitude,
        "Longitude": longitude,
        "Description": description,
        "WebSite": webSite,
        "Facebook": facebook,
      };
}
