import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestToCorreio {

  String codigo;

  RequestToCorreio( String codigo ) {
    this.codigo = codigo;
  }
  Future<List<dynamic>> getData() async {
    var url = 'localiza-app.herokuapp.com';
    var path = '/rastreio';
    http.Response response = await http.post(Uri.http(url, path),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'codigo': this.codigo,
        }));
    try {
      List data = jsonDecode(utf8.decode(response.bodyBytes));
      // var i = 0;
      // for (var information in data) {
      //   if (i == 0) {
      //     print(information['local']); // Local do objeto
      //     print(information['data']); // Data da mudanca de status
      //     print(information['hora']); // Hora da mudanca de status
      //     print(information['mensagem']); // Mensagem do respectivo status
      //     print(information['lat']); // Latitude
      //     print(information['lng']); // Longitude
      //
      //   } else {
      //     print(information['local']); // Local do objeto
      //     print(information['data']); // Data da mudanca de status
      //     print(information['hora']); // Hora da mudanca de status
      //     print(information['mensagem']); // Mensagem do respectivo stat     us
      //   }
      //
      //   i = i + 1;
      // }
      return Future.value(data);

    } catch (e) {
      print("Error: $e");
    }
  }
}
