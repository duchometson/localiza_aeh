import 'package:flutter/material.dart';
import 'dart:async';
import 'product.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ProductMap extends StatelessWidget {

  List<Product> productList = new List<Product>();

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

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return new GoogleMap(
      markers: markers ,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 10.0,
      ),
    );
  }

}