import 'package:flutter/material.dart';

class TipoProdutos {
  Map<String, IconData> _tipoProdutos = {
    "Eletrodoméstico" : Icons.kitchen,
    "Tecnologia"      : Icons.monitor,
    "Outros"          : Icons.apps_sharp,
  };

  Map<String, IconData> getMap() {
    return _tipoProdutos;
  }
}