import 'dart:async';
import 'dart:ui' as ui;
import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearByATMScreen extends StatefulWidget {
  const NearByATMScreen({Key? key}) : super(key: key);

  @override
  State<NearByATMScreen> createState() => _NearByATMScreenState();
}

class _NearByATMScreenState extends State<NearByATMScreen> {
  final atmList = [
    {
      "image": "assets/profile/image1.png",
      "atmName": "Finalan Techno ATM",
      "adress": "2464 Royal Ln. Mesa, New Jersey 45463",
      "time": "20 min",
      "latLang": const LatLng(40.7440, -74.0324),
      "id": "0"
    },
    {
      "image": "assets/profile/image2.png",
      "atmName": "Finalan Techno ATM",
      "adress": "1901 Thornridge Cir. Shiloh,Hawaii 81063",
      "time": "45 min",
      "latLang": const LatLng(40.7178, -74.0431),
      "id": "1"
    },
    {
      "image": "assets/profile/image3.png",
      "atmName": "Finalan Techno ATM",
      "adress": "6391 Elgin St. Celina, Delaware 10299",
      "time": "45 min",
      "latLang": const LatLng(40.7368, -73.9845),
      "id": "2"
    },
    {
      "image": "assets/profile/image1.png",
      "atmName": "Finalan Techno ATM",
      "adress": "2464 Royal Ln. Mesa, New Jersey 45463",
      "time": "20 min",
      "latLang": const LatLng(40.6580, -73.9941),
      "id": "3"
    },
    {
      "image": "assets/profile/image2.png",
      "atmName": "Finalan Techno ATM",
      "adress": "1901 Thornridge Cir. Shiloh,Hawaii 81063",
      "time": "45 min",
      "latLang": const LatLng(40.6602, -73.9690),
      "id": "4"
    },
    {
      "image": "assets/profile/image3.png",
      "atmName": "Finalan Techno ATM",
      "adress": "6391 Elgin St. Celina, Delaware 10299",
      "time": "45 min",
      "latLang": const LatLng(40.7305, -73.9515),
      "id": "5"
    },
  ];
  GoogleMapController? mapController;

  List<Marker> allMarkers = [];

  PageController pageController =
      PageController(viewportFraction: 0.85, initialPage: 1);
  double _currPageValue = 1.0;
  double scaleFactor = .8;
  double height = 170;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  marker() async {
    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: const LatLng(40.7128, -74.0060),
        infoWindow: const InfoWindow(title: "You are here"),
        icon: BytesMapBitmap(
          await getBytesFromAsset("assets/profile/currentLocation.png", 60),
          bitmapScaling: MapBitmapScaling.none,
        ),
      ),
    );

    for (int i = 0; i < atmList.length; i++) {
      allMarkers.add(
        Marker(
          markerId: MarkerId(atmList[i]['id'].toString()),
          position: atmList[i]['latLang'] as LatLng,
          infoWindow: InfoWindow(title: atmList[i]['atmName'].toString()),
          icon: BytesMapBitmap(
            await getBytesFromAsset("assets/profile/atmMarker.png", 60),
            bitmapScaling: MapBitmapScaling.none,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        foregroundColor: black33Color,
        shadowColor: blackColor.withValues(alpha: 0.4),
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'nearby_atms.nearby_ATMs'),
          style: appBarStyle,
        ),
      ),
      body: Stack(
        children: [
          googleMap(size),
          bankListContent(size),
        ],
      ),
    );
  }

  bankListContent(size) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: fixPadding * 2,
      child: SizedBox(
        height: 160.0,
        width: size.width,
        child: PageView.builder(
          onPageChanged: (index) {
            moveCamera(atmList[index]['latLang'] as LatLng);
          },
          controller: pageController,
          itemCount: atmList.length,
          itemBuilder: (context, index) {
            return _buildListContent(index, size);
          },
        ),
      ),
    );
  }

  googleMap(size) {
    return SizedBox(
      height: double.maxFinite,
      width: size.width,
      child: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: LatLng(40.6928, -74.0060), zoom: 12),
        markers: Set.from(allMarkers),
        onMapCreated: mapCreated,
      ),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    await marker();
    setState(() {});
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  moveCamera(LatLng target) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          bearing: 45.0,
          zoom: 14.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  _buildListContent(int index, Size size) {
    Matrix4 matrix = Matrix4.identity();

    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - scaleFactor);
      var currTrans = height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          scaleFactor + (_currPageValue - index + 1) * (1 - scaleFactor);
      var currTrans = height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - scaleFactor);
      var currTrans = height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, currTrans, 0.0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1.0, currScale, 1.0)
        ..setTranslationRaw(0.0, height * (1 - scaleFactor) / 2, 0.0);
    }
    return GestureDetector(
      onTap: () {
        moveCamera(atmList[index]['latLang'] as LatLng);
      },
      child: Transform(
        transform: matrix,
        child: Container(
          padding: const EdgeInsets.all(fixPadding),
          margin: const EdgeInsets.symmetric(
              horizontal: fixPadding, vertical: fixPadding),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: double.maxFinite,
                width: size.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(
                      atmList[index]['image'].toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              widthSpace,
              width5Space,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      atmList[index]['atmName'].toString(),
                      style: bold16Black33,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      atmList[index]['adress'].toString(),
                      style: semibold14Grey94,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: black33Color,
                        ),
                        width5Space,
                        Text(
                          atmList[index]['time'].toString(),
                          style: semibold14Black33,
                        )
                      ],
                    ),
                    Text(
                      getTranslation(context, 'nearby_atms.direction'),
                      style: bold14Primary,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    pageController.dispose();
    super.dispose();
  }
}
