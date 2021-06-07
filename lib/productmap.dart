import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'product.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ProductMap extends StatelessWidget {

  List<Product> productList = new List<Product>();
  Position currentPosition;
  var geoLocator = Geolocator();

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  void locatePosition() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPos = LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  LatLng center = const LatLng(45.521563, -122.677433);
  Set<Marker> markers = Set();

  ProductMap( List<Product> pList) {
    this.productList.addAll(pList);
    if( this.productList.first.lat != null ) {
      center = LatLng(this.productList.first.lat, this.productList.first.long);
      for (int i = 0; i < this.productList.length; i++) {
        if( this.productList[i].lat != null ) {
         markers.add(Marker(markerId: MarkerId(this.productList[i].nome),
            position: LatLng(
                this.productList[i].lat, this.productList[i].long)));
        }
      }
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return new GoogleMap(
      markers: markers ,
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 10.0,
      ),
    );
  }

}