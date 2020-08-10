import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vouchersTW/model/nonGet.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();

  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = Set();

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  bool _mapMoved = false;

  final GlobalKey scaffoldKey = GlobalKey();

  final isSelected = <bool>[true, true, true];

  BitmapDescriptor cusIcon1, cusIcon2, cusIcon3, emptyIcon;

  List<LatLng> _search(List<LatLng> mainMap) {
    List<LatLng> finalMap = [];
    var lat = _movedPos.latitude;
    var lng = _movedPos.longitude;

    for (int i = 0; i < mainMap.length; i++) {
      var con_lat = mainMap[i].latitude - lat;

      if (con_lat > -0.030 && con_lat < 0.030) {
        var con_lng = mainMap[i].longitude - lng;

        if (con_lng > -0.015 && con_lng < 0.015) {
          finalMap.add(mainMap[i]);
        }
      }
    }
    return finalMap;
  }

  Map _spotFactory(cur_sopt) {
    print(cur_sopt);
    Map area = {
      // "LatitudeLow": (cur_sopt.latitude) - 0.030,
      // "LatitudeHigh": (cur_sopt.latitude) + 0.030,
      // "LongitudeLow": (cur_sopt.longitude) - 0.015,
      // "LongitudeHigh": (cur_sopt.longitude) + 0.015,
      "LatitudeLow": 25.1445198,
      "LatitudeHigh": 25.2445198,
      "LongitudeLow": 121.5683672,
      "LongitudeHigh": 121.6683672,
    };
    print("我產生四個點了");
    print(area);
    NonGetReq(area).then((value) {
      if (mounted) {
        print("********");
      }
    });
  }

  final List<LatLng> _marker1 = [];
  //final List<LatLng> _marker2 = [];
  //final List<LatLng> _marker3 = [];

  List<Marker> markers = [];

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(30, 30)), 'assets/images/icon1.png')
        .then((onValue) {
      setState(() {
        cusIcon1 = onValue;
      });
    });
    /*
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(30, 30)), 'assets/images/icon2.png')
        .then((onValue) {
      cusIcon2 = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(30, 30)), 'assets/images/icon3.png')
        .then((onValue) {
      cusIcon3 = onValue;
    });
    */
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(27, 27)), 'assets/images/icone.png')
        .then((onValue) {
      emptyIcon = onValue;
    });
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });
  }

  void _initMarkers() async {
    markers = [];
    List finalList1 = _search(_marker1);
    for (LatLng markerLocation in finalList1) {
      String idnum = finalList1.indexOf(markerLocation).toString();
      markers.add(
        Marker(
          markerId: MarkerId("01_" + idnum),
          position: markerLocation,
          icon: isSelected[0] == true ? cusIcon1 : emptyIcon,
          onTap: () {
            _showModalBottomSheet(context, idnum + " from Mark1");
          },
        ),
      );
    }
/*
    List finalList2 = _search(_marker2);
    for (LatLng markerLocation in finalList2) {
      String idnum = finalList2.indexOf(markerLocation).toString();
      markers.add(
        Marker(
          markerId: MarkerId("02_" + idnum),
          position: markerLocation,
          icon: isSelected[1] == true ? cusIcon2 : emptyIcon,
          onTap: () {
            _showModalBottomSheet(context, idnum + " from Mark2");
          },
        ),
      );
    }

    List finalList3 = _search(_marker3);
    for (LatLng markerLocation in finalList3) {
      String idnum = finalList3.indexOf(markerLocation).toString();
      markers.add(
        Marker(
          markerId: MarkerId("03_" + idnum),
          position: markerLocation,
          icon: isSelected[2] == true ? cusIcon3 : emptyIcon,
          onTap: () {
            _showModalBottomSheet(context, idnum + " from Mark3");
          },
        ),
      );
    }*/
  }

  Position _currentPosition;
  LatLng _movedPos = LatLng(25.07215399581608, 121.54667861759663);
  Key map;

  _getCurrentLocation() {
    if (_currentPosition == null) {
      print("我要去取現在位置囉");
      final geolocator = Geolocator()..forceAndroidLocationManager;

      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
          print("我要去工廠囉");
          _spotFactory(_currentPosition);
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  void _showModalBottomSheet(BuildContext context, String idnum) {
    showModalBottomSheet<void>(
      barrierColor: Colors.white10,
      context: context,
      builder: (context) {
        return _BottomSheetContent(idnum);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentLocation();
    if (_isMapLoading == true) {
      _initMarkers();
    }
    //print(_currentPosition);
    if (_currentPosition != null) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Example'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Google Map widget
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
                  //print("move start");
                  setState(() {
                    _mapMoved = true;
                  });
                },
                onCameraIdle: () {
                  //print(_movedPos);
                },
                onCameraMove: (pos) {
                  _movedPos = pos.target;
                  //print(pos.zoom);
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
                child: FlatButton(
                  color: Colors.amber,
                  child: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _mapMoved = false;
                      //print(markers.length);
                      markers = [];
                      _initMarkers();
                    });
                  },
                ),
              ),
            ),

            /*
            Positioned(
              top: 0,
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: ToggleButtons(
                  children: const [
                    Icon(Icons.ac_unit),
                    Icon(Icons.call),
                    Icon(Icons.cake),
                  ],
                  onPressed: (index) {
                    setState(() {
                      isSelected[index] = !isSelected[index];
                      _initMarkers();
                    });
                  },
                  isSelected: isSelected,
                ),
              ),
            ),
            */
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Example'),
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
}

class _BottomSheetContent extends StatelessWidget {
  final String idnum;
  _BottomSheetContent(this.idnum);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.blueAccent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "場館名稱：${idnum}",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("藝fun券",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14))
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text("10:00 ~ 20:00",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.map,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text("10461台北市中山區中山北路三段181號")
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.call,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text("02-2595-7656")
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
