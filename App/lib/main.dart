import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:convert';
import 'package:google_maps_webservice/places.dart' as gmwplaces;
import 'package:google_maps_webservice/directions.dart' as gmwdirections;
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MapPage());
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

TextEditingController toController = TextEditingController(text: "");
TextEditingController fromController = TextEditingController();

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Paytm Hack",
      home: Scaffold(
        //appBar: AppBar(title: const Text('Google Maps demo')),
        body: MapsDemo(),
      ),
    );
  }
}

var location = loc.Location();
String destination = "Maujpur Metro Station";
gmwdirections.Location dest = gmwdirections.Location(0.0, 0.0),
    begin = gmwdirections.Location(0.0, 0.0);
LatLng currentLocation = LatLng(0.0, 0.0);
GoogleMapController mapController;
bool isStartVisible = false;
Image img;
double north, east, south, west;
StreamSubscription<Map<String, double>> _locationSubscription;

class MapsDemo extends StatefulWidget {
  @override
  State createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  @override
  void initState() {
    super.initState();

    _locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = LatLng(result["latitude"], result["longitude"]);
        print(
            "Changed Location ${currentLocation.latitude} ${currentLocation.longitude}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                options: GoogleMapOptions(
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
              ),
              (img != null)
                  ? GestureDetector(
                      /*onVerticalDragUpdate: (details) {
                        mapController.moveCamera(
                            CameraUpdate.scrollBy(0.0, -details.delta.dy));
                      },
                      onHorizontalDragUpdate: (details) {
                        mapController.moveCamera(
                            CameraUpdate.scrollBy(-details.delta.dx, 0.0));
                      },*/
                      child: Opacity(
                        child: img,
                        opacity: 0.60,
                      ),
                    )
                  : Container(),
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 30.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.blue,
                              )),
                          child: TextFormField(
                            controller: toController,
                            onFieldSubmitted: (str) => SearchLocation(str),
                            decoration: InputDecoration(
                                labelText: "To",
                                contentPadding: EdgeInsets.all(5.0)),
                          )),
                    ),
                  ],
                ),
              ),
              (!isStartVisible)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RaisedButton(
                            onPressed: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Added Light to (${currentLocation.latitude} , ${currentLocation.longitude})")));
                            },
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                            shape: CircleBorder(),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, bottom: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100.0),
                                border:
                                    Border.all(color: Colors.blue, width: 2.0)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: FlatButton(
                                    child: Container(),
                                    onPressed: () {
                                      UpdateLocation();
                                      sendReview(currentLocation.latitude,
                                          currentLocation.longitude, 1);
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              "Rated (${currentLocation.latitude} , ${currentLocation.longitude}) as Bad")));
                                    },
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.yellow,
                                  child: FlatButton(
                                    child: Container(),
                                    onPressed: () {
                                      UpdateLocation();
                                      sendReview(currentLocation.latitude,
                                          currentLocation.longitude, 2);
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              "Rated (${currentLocation.latitude} , ${currentLocation.longitude}) as Average")));
                                    },
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: FlatButton(
                                    child: Container(),
                                    onPressed: () async {
                                      await UpdateLocation();
                                      sendReview(currentLocation.latitude,
                                          currentLocation.longitude, 3);
                                      Scaffold.of(context).showSnackBar(SnackBar(
                                          content: Text(
                                              "Rated (${currentLocation.latitude} , ${currentLocation.longitude}) as Good")));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
              (!isStartVisible)
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: RaisedButton(
                              onPressed: () async {
                                print("Getting img");
                                var response = await http.get(
                                    "http://ayush789.pythonanywhere.com/gettowermap?n=$north&e=$east&w=$west&s=$south");
                                print(response.body);
                                var bytes = base64Decode(response.body);
                                setState(() {
                                  img = Image.memory(
                                    bytes,
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                  );
                                });
                                print(north);
                                print(south);
                                print(east);
                                print(west);
                                /*mapController.addMarker(MarkerOptions(
                                    position: LatLng(north, east)));
                                mapController.addMarker(MarkerOptions(
                                    position: LatLng(south, west)));
                              */
                              },
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.settings_input_antenna,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                              shape: CircleBorder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: RaisedButton(
                              onPressed: () async {
                                print("Getting img");
                                print("$north");
                                var response = await http.get(
                                    "http://ayush789.pythonanywhere.com/getmap?n=$north&e=$east&w=$west&s=$south");
                                print(response.body);
                                var bytes = base64Decode(response.body);
                                setState(() {
                                  img = Image.memory(
                                    bytes,
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                  );
                                });
                                print(north);
                                print(south);
                                print(east);
                                print(west);
                                /*mapController.addMarker(MarkerOptions(
                                    position: LatLng(north, east)));
                                mapController.addMarker(MarkerOptions(
                                    position: LatLng(south, west)));
                              */
                              },
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                              shape: CircleBorder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  img = null;
                                });
                              },
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.map,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                              shape: CircleBorder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 0.0),
                            child: RaisedButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: launchUber,
                              color: Colors.black,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.local_taxi,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              (isStartVisible)
                  ? Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                padding: EdgeInsets.all(10.0),
                                child: FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      isStartVisible = false;
                                    });
                                  },
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: CircleAvatar(
                                  minRadius: 30.0,
                                  backgroundColor: Colors.blue,
                                  child: FlatButton(
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        setState(() {
                                          isStartVisible = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30.0,
                                      )),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.red,
          child: FlatButton(
            child: Text(
              "Call For Help",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            color: Colors.red,
            onPressed: call,
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      location.getLocation().then((Map<String, double> myloc) {
        setState(() {
          begin = gmwdirections.Location(myloc["latitude"], myloc["longitude"]);
        });
        mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(myloc["latitude"], myloc["longitude"]),
              zoom: 17.0,
            ),
          ),
        );

        east = myloc["longitude"] + 0.00150;
        west = myloc["longitude"] - 0.00150;
        north = myloc["latitude"] + 0.0020;
        south = myloc["latitude"] - 0.0020;
        /*
        mapController.addMarker(MarkerOptions(
          position: LatLng(myloc["latitude"], myloc["longitude"]),
        ));*/
      });
    });
  }

  void SearchLocation(String text) async {
    print("Searching for location");
    //if (toController.text == "") return;
    print("text $text");
    if (text == "") {
      print("Going to clear");
      mapController.clearMarkers();
      mapController.clearPolylines();
      await mapController.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation,zoom: 17.0)));
      print("Cleared");
      return;
    }
    var places = gmwplaces.GoogleMapsPlaces(
      apiKey: "Your Api Key",
    );
    var val = await places.searchByText(text).catchError((e) {
      print("Error: $e}");
      return;
    });
    print(val.results.length);
    if (val.results.length == 0) {
      return;
    }
    dest = val.results[0].geometry.location;
    print("New Dest $dest");

    mapController.clearMarkers();
    mapController.clearPolylines();
    mapController.addMarker(
      MarkerOptions(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: LatLng(dest.lat, dest.lng),
      ),
    );
    mapController.addMarker(
      MarkerOptions(
        position: LatLng(begin.lat, begin.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    var directions = gmwdirections.GoogleMapsDirections(
      apiKey: "Your Api Key",
    );
    print(directions.url);
    var dirresp =
        await directions.directionsWithLocation(begin, dest).catchError(
      (e) {
        print("Error: $e}");
        return;
      },
    );

    print("dirresp.isOkay ${dirresp.isOkay}");
    print(dirresp.routes.length);

    dirresp.routes.forEach((route) {
      List<LatLng> points = [];
      double e, w, n, s;
      e = w = begin.lng;
      n = s = begin.lat;
      points.add(LatLng(begin.lat, begin.lng));
      double totalDistance = 0;
      route.legs[0].steps.forEach(
        (gmwdirections.Step step) {
          n = (n > step.endLocation.lat) ? n : step.endLocation.lat;
          s = (s < step.endLocation.lat) ? s : step.endLocation.lat;
          e = (e > step.endLocation.lng) ? e : step.endLocation.lng;
          w = (w < step.endLocation.lng) ? w : step.endLocation.lng;

          points.add(
            LatLng(step.endLocation.lat, step.endLocation.lng),
          );
          totalDistance += step.distance.value;
        },
      );
      points.add(LatLng(dest.lat, dest.lng));
      n = (n > dest.lat) ? n : dest.lat;
      s = (s < dest.lat) ? s : dest.lat;
      e = (e > dest.lng) ? e : dest.lng;
      w = (w < dest.lng) ? w : dest.lng;

      print(n);
      print(s);
      print(w);
      print(e);

      print("Total Distance : $totalDistance");

      n += (n - s) * 0.23;
      e -= (w - e) * 0.2;
      print(n);
      print(s);
      print(w);
      print(e);

      //mapController.addMarker(MarkerOptions(position: LatLng(n, e)));
      //mapController.addMarker(MarkerOptions(position: LatLng(s, w)));
      mapController.addPolyline(PolylineOptions(
        points: points,
        color: Colors.purple.value,
        endCap: Cap.squareCap,
      ));
      mapController.moveCamera(
        CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(s, w),
              northeast: LatLng(n, e),
            ),
            20.0),
      );

      setState(() {
        north = n;
        south = s;
        east = e;
        west = w;
      });
    });
    print("Changed");
    setState(() {
      //isStartVisible = true;
    });
  }

  Future sendReview(double lat0, double lon0, int review) async {
    await UpdateLocation();

    double lat = currentLocation.latitude, lon = currentLocation.longitude;
    String url =
        "http://ayush789.pythonanywhere.com/addreview?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&rev=$review";
    print("Sending $lat $lon");
    var response = await http.get(url);
    print(response.body);
    setState(() {
      print("Located At: $lat $lon");
      /*mapController.addMarker(
        MarkerOptions(
            position: LatLng(lat, lon),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange)),
      );*/
    });
    return;
  }

  void UpdateLocation() async {
    location = loc.Location();
    var myloc = await location.getLocation();
    setState(() {
      currentLocation = LatLng(myloc["latitude"], myloc["longitude"]);
      print(
          "Chnaged Location ${currentLocation.latitude} ${currentLocation.longitude}");
    });
  }
}

launchUber() async {
  await launch("uber://?action=setPickup&pickup=my_location");
}

call() async {
  await launch("tel:0000000000");
}
