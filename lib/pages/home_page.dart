import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vouchersTW/model/nonGet.dart';
import 'package:vouchersTW/util/stylesheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;

  double _currentZoom = 17;

  bool _isMapLoading = true;

  bool _mapMoved = false;

  final GlobalKey scaffoldKey = GlobalKey();

  List isSelected = <bool>[true, true, true];

  int isProcessed = 0;

  BitmapDescriptor cusIcon1, cusIcon2, cusIcon3, emptyIcon;

  Uint8List markerIcon1, markerIcon2, markerIcon3;

  String x1, x2, y1, y2;

  List<LatLng> _marker1 = [];
  List<LatLng> _marker2 = [];
  List<LatLng> _marker3 = [];

  List<Marker> markers = [];

  List locates1, locates2, locates3;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/icon1.png')
        .then((onValue) {
      setState(() {
        cusIcon1 = onValue;
      });
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/icon2.png')
        .then((onValue) {
      setState(() {
        cusIcon2 = onValue;
      });
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/icon3.png')
        .then((onValue) {
      setState(() {
        cusIcon3 = onValue;
      });
    });

    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    //print("地圖開好了");
    mapController = controller;
    _controller.complete(controller);

    setState(() {
      _isMapLoading = false;
      _spotFactory();
    });
  }

  Position _currentPosition;
  Key map;

  void checkProgress() {
    isProcessed = isProcessed + 1;
    if (isProcessed == 3) {
      dismissProgressDialog();
    }
  }

  Map _spotFactory() {
    isProcessed = 0;
    var dialog = showProgressDialog(
      context: context,
      loadingText: "搜尋店家中...",
      backgroundColor: cis_m_bluelit,
      orientation: ProgressOrientation.vertical,
    );
    mapController.getVisibleRegion().then((value) {
      //print(value);
      LatLng sw = value.southwest;
      LatLng ne = value.northeast;
      Map area;
      setState(() {
        area = {
          "LatitudeLow": sw.latitude.toString(),
          "LatitudeHigh": ne.latitude.toString(),
          "LongitudeLow": sw.longitude.toString(),
          "LongitudeHigh": ne.longitude.toString(),
        };
        locates1 = [];
        locates2 = [];
        locates3 = [];
        _marker1 = [];
        _marker2 = [];
        _marker3 = [];
      });
      //找到type:1的座標
      NonGetReq(area, "1").then(
        (value) {
          if (mounted) {
            setState(() {
              locates1 = value;
              print("locater1的筆數：" + locates1.length.toString());
              for (var i = 0; i < locates1.length; i++) {
                var lat = double.parse(locates1[i].latitude);
                var lng = double.parse(locates1[i].longitude);
                _marker1.add(LatLng(lat, lng));
              }
              dismissProgressDialog();
              if (_marker1.length > 0) {
                _initMarkers();
              }
              checkProgress();
            });
          }
        },
      );

      //找到type:2的座標
      NonGetReq(area, "2").then(
        (value) {
          if (mounted) {
            setState(() {
              locates2 = value;
              print("locater2的筆數：" + locates2.length.toString());
              for (var i = 0; i < locates2.length; i++) {
                var lat = double.parse(locates2[i].latitude);
                var lng = double.parse(locates2[i].longitude);
                _marker2.add(LatLng(lat, lng));
              }
              if (_marker2.length > 0) {
                _initMarkers();
              }
              checkProgress();
            });
          }
        },
      );

      //找到type:3的座標
      NonGetReq(area, "3").then(
        (value) {
          if (mounted) {
            setState(() {
              locates3 = value;
              print("locater3的筆數：" + locates3.length.toString());
              for (var i = 0; i < locates3.length; i++) {
                var lat = double.parse(locates3[i].latitude);
                var lng = double.parse(locates3[i].longitude);
                _marker3.add(LatLng(lat, lng));
              }
              if (_marker3.length > 0) {
                _initMarkers();
              }
              checkProgress();
            });
          }
        },
      );
    });
  }

  void _initMarkers() async {
    markerIcon1 = await getBytesFromAsset('assets/images/icon1.png', 100);
    markerIcon2 = await getBytesFromAsset('assets/images/icon2.png', 100);
    markerIcon3 = await getBytesFromAsset('assets/images/icon3.png', 100);
//把圖片顯示在座標上
    setState(() {
      markers = [];
      List finalList1 = _marker1;
      List finalList2 = _marker2;
      List finalList3 = _marker3;
      print("finalList:");
      print(finalList1.length);
      print(finalList2.length);
      print(finalList3.length);
      if (isSelected[0] == true) {
        for (LatLng markerLocation in finalList1) {
          String idnum = finalList1.indexOf(markerLocation).toString();
          //print("idnum1=============================");
          //print(idnum);
          markers.add(
            Marker(
              markerId: MarkerId("111" + idnum),
              position: markerLocation,
              icon: BitmapDescriptor.fromBytes(markerIcon1),
              onTap: () {
                _showModalBottomSheet(context, idnum, locates1, "農遊");
                //print("01_" + idnum);
              },
            ),
          );
        }
      }

      if (isSelected[1] == true) {
        for (LatLng markerLocation in finalList2) {
          String idnum = finalList2.indexOf(markerLocation).toString();
          //print("idnum2=============================");
          //print(idnum);
          markers.add(
            Marker(
              markerId: MarkerId("222" + idnum),
              position: markerLocation,
              icon: BitmapDescriptor.fromBytes(markerIcon2),
              onTap: () {
                _showModalBottomSheet(context, idnum, locates2, "藝FUN");
                //print(idnum);
              },
            ),
          );
        }
        print("總地標數量=============================");
        print(markers.length);
      }

      if (isSelected[2] == true) {
        for (LatLng markerLocation in finalList3) {
          String idnum = finalList3.indexOf(markerLocation).toString();
          // print("idnum3=============================");
          // print(idnum);
          markers.add(
            Marker(
              markerId: MarkerId("333" + idnum),
              position: markerLocation,
              icon: BitmapDescriptor.fromBytes(markerIcon3),
              onTap: () {
                _showModalBottomSheet(context, idnum, locates3, "動滋");
                //print(idnum);
              },
            ),
          );
        }
      }
    });
  }

  void _getCurrentLocation() {
    if (_currentPosition == null) {
      //print("我要去取現在位置囉");
      final geolocator = Geolocator()..forceAndroidLocationManager;

      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();
    if (_currentPosition != null) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(mainTitle),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[cis_m_blue, cis_m_bluelit],
              ),
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.share),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Opacity(
              opacity: _isMapLoading ? 0 : 1,
              child: GoogleMap(
                key: map,
                mapToolbarEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _currentPosition.latitude, _currentPosition.longitude),
                  zoom: _currentZoom,
                ),
                markers: Set.from(markers),
                onMapCreated: (controller) => _onMapCreated(controller),
                myLocationEnabled: true,
                onCameraMoveStarted: () {
                  setState(() {
                    _mapMoved = true;
                  });
                },
                onTap: (argument) {
                  print(argument);
                },
              ),
            ),
            Icon(Icons.location_searching, size: 50),
            Positioned(
              bottom: 40,
              child: Opacity(
                opacity: _mapMoved == true ? 1 : 0,
                child: RaisedButton(
                  textColor: Colors.white,
                  color: cis_m_blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "搜尋此區域",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _mapMoved = false;
                      _marker1 = [];
                      markers = [];
                      //print("-------markers");
                      //print(markers);
                      _spotFactory();
                      //_initMarkers();
                    });
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      RawMaterialButton(
                        onPressed: () {
                          setState(() {
                            isSelected[0] = !isSelected[0];
                            _initMarkers();
                          });
                        },
                        elevation: 2.0,
                        fillColor:
                            isSelected[0] == true ? cis_org : Colors.white,
                        child: Text(
                          "農",
                          style: TextStyle(
                              color: isSelected[0] == true
                                  ? Colors.white
                                  : cis_org_lit,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.all(2),
                        shape: CircleBorder(
                            side: BorderSide(
                                color: isSelected[0] == true
                                    ? cis_org
                                    : cis_org_lit,
                                width: 2)),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          setState(() {
                            isSelected[1] = !isSelected[1];
                            _initMarkers();
                          });
                        },
                        elevation: 2.0,
                        fillColor:
                            isSelected[1] == true ? cis_pink : Colors.white,
                        child: Text(
                          "藝",
                          style: TextStyle(
                              color: isSelected[1] == true
                                  ? Colors.white
                                  : cis_pink_lit,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.all(2.0),
                        shape: CircleBorder(
                            side: BorderSide(
                                color: isSelected[1] == true
                                    ? cis_pink
                                    : cis_pink_lit,
                                width: 2)),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          setState(() {
                            isSelected[2] = !isSelected[2];
                            _initMarkers();
                          });
                        },
                        elevation: 2.0,
                        fillColor:
                            isSelected[2] == true ? cis_blue : Colors.white,
                        child: Text(
                          "動",
                          style: TextStyle(
                              color: isSelected[2] == true
                                  ? Colors.white
                                  : cis_blue_lit,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.all(2),
                        shape: CircleBorder(
                            side: BorderSide(
                                color: isSelected[2] == true
                                    ? cis_blue
                                    : cis_blue_lit,
                                width: 2)),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(mainTitle),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[cis_m_blue, cis_m_bluelit],
              ),
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.more_vert),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: Stack(
          children: <Widget>[
            Opacity(
              opacity: _isMapLoading ? 1 : 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }
  }

  void _showModalBottomSheet(
      BuildContext context, String idnum, var info, String name) {
    showModalBottomSheet<void>(
      backgroundColor: Color(0x00FFFFFF),
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: _BottomSheetContent(idnum, info, name),
            );
          },
        );
      },
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String idnum, name;
  var info;
  _BottomSheetContent(this.idnum, this.info, this.name);

  @override
  Widget build(BuildContext context) {
    //print(name + "-------" + idnum + "-------資料筆數：" + info.length.toString());
    double mainWidth = MediaQuery.of(context).size.width;
    double mainHeight = MediaQuery.of(context).size.height;
    int id = int.parse(idnum);
    List bgcolor = <Color>[];
    Color click, search;
    double boxheight;
    if (name == "農遊") {
      bgcolor = <Color>[cis_m_org, cis_m_orglit];
      click = cis_m_org;
      search = cis_m_orglit;
    } else if (name == "藝FUN") {
      bgcolor = <Color>[cis_m_pink, cis_m_pinklit];
      click = cis_m_pink;
      search = cis_m_pinklit;
    } else {
      bgcolor = <Color>[cis_m_blue, cis_m_bluelit];
      click = cis_m_blue;
      search = cis_m_bluelit;
    }

    String msgText =
        "[振興券怎麼花]${name}券：${info[id].storeName}（${info[id].telephone}）- https://www.google.com.tw/maps/place/${info[id].address}";
    //print(info[id]);
    return Container(
      height: mainHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: mainWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: bgcolor,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              name + "券合作商家",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Opacity(
                                    opacity: info[id].webSite == "" ? 0.3 : 1,
                                    child: InkWell(
                                      onTap: () {
                                        if (info[id].webSite.length != 0) {
                                          print((info[id].webSite));
                                          _gotoUrl(info[id].webSite);
                                        }
                                      },
                                      child: Icon(
                                        Icons.home,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Opacity(
                                    opacity: info[id].facebook == "" ? 0.3 : 1,
                                    child: InkWell(
                                      onTap: () {
                                        if (info[id].facebook.length != 0) {
                                          print((info[id].facebook));
                                          _gotoUrl(info[id].facebook);
                                        }
                                      },
                                      child: Image.asset(
                                        'assets/images/fb.png',
                                        width: 15,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  InkWell(
                                    onTap: () => {
                                      _googleLaunchURL(info[id].storeName +
                                          "+" +
                                          info[id].address)
                                    },
                                    child: Container(
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.center,
                                            height: 20,
                                            child: Text(
                                              "   搜尋商家   ",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9),
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                bottomLeft:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 20,
                                            height: 20,
                                            child: Icon(
                                              Icons.search,
                                              color: search,
                                              size: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${info[id].storeName}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black26,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () => {_gotoMap(info[id].address)},
                            child: Container(
                                width: mainWidth - 80,
                                child: Text(
                                  "${info[id].address}",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: click,
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.call,
                            color: Colors.black26,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () => {
                              if (info[id].telephone.trim() != "")
                                {launch("tel://" + info[id].telephone)}
                            },
                            child: Text(
                              info[id].telephone.trim() != ""
                                  ? "${info[id].telephone}"
                                  : "暫無電話",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: info[id].telephone.trim() != ""
                                      ? click
                                      : Colors.black26,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.subject,
                            color: Colors.black26,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: mainWidth - 80,
                            child: Text(
                              info[id].description != ""
                                  ? "${info[id].description}"
                                  : "暫無商家簡介",
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: info[id].description != ""
                                      ? click
                                      : Colors.black26,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        height: 40,
                        child: RaisedButton.icon(
                          onPressed: () {
                            final RenderBox box = context.findRenderObject();
                            Share.share(msgText,
                                subject: "振興券怎麼花",
                                sharePositionOrigin:
                                    box.localToGlobal(Offset.zero) & box.size);
                          },
                          icon: Icon(
                            Icons.share,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            "分享",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          color: click,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            child: Container(
              width: mainWidth * 0.2,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_googleLaunchURL(name) async {
  String url = 'https://www.google.com/search?q=' + name;
  url = Uri.encodeFull(url);
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}

_gotoMap(maplink) async {
  String url = 'https://www.google.com.tw/maps/place/' + maplink;
  url = Uri.encodeFull(url);
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}

_gotoUrl(url) async {
  if (url.substring(0, 4) != "http") {
    url = "http://" + url;
  }
  print(url);
  url = Uri.encodeFull(url);
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true, enableJavaScript: true);
  } else {
    throw 'Could not launch $url';
  }
}

Future SignInDialog(BuildContext context, message) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Text(
          message + "即將推出！",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            textColor: cis_green,
            child: Text("我知道了"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
