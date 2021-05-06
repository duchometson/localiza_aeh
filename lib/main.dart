import 'dart:async';
import 'package:flutter/material.dart';
import 'product.dart';
import 'productmap.dart';

void main() {
  addProduct( Product("Monitor","OO283250145BR", Icons.add_to_queue) );
  addProduct( Product("Sofa","OO283250145BR", Icons.weekend_sharp) );
  addProduct( Product("Relogio","OO283250145BR", Icons.watch) );

  runApp(
      MaterialApp(
          home: MyApp()
      )
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() {
    return HomePage();
  }
}

class HomePage extends State<MyApp> {
  static const String _title = 'Localiza Aeh';
  bool reload = false;

  FutureOr quandoVoltar(dynamic value) {
    print("voltei pra main");
    setState(() {
      atualizaLista().then( (value ) {
        setState(() {
          print("setState");
          this.reload = true;
        });
      });
    });
  }

  FutureOr quandoVoltarAdicao(dynamic value) {
    print("adicionei e voltei pra main");
    setState(() {
      atualizaAdicionado().then( (value ) {
        setState(() {
          print("setState");
          this.reload = true;
        });
      });
    });
  }


  void initState() {
    super.initState();
    atualizaLista().then( (value ) {
      setState(() {
        print("setState");
        this.reload = true;
      });
    });
  }

  Future atualizaAdicionado() async {
    print("Atualizando individual");
    getProductList().last.updateAtualizacoes();
    while(!todosProdutosAtualizados()) {
      await new Future.delayed(new Duration(milliseconds: 250));
    }
    print("Terminei atualizar");

  }

  Future atualizaLista() async {
    print("Atualizando");
    for( int i = 0; i < getProductList().length; i++ ) {
      getProductList()[i].updateAtualizacoes();
    }
    while(!todosProdutosAtualizados()) {
      await new Future.delayed(new Duration(milliseconds: 250));
    }
    print("Terminei atualizar");
  }

  @override
  Widget build(BuildContext context) {
    if( !todosProdutosAtualizados() ) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(color:Colors.lightGreen),
              child:
              Center(
                child:
                Image.asset(
                  "img/Magnify-1s-200px.gif",
                  height: 125.0,
                  width: 125.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return MaterialApp(
        title: _title,
        theme:
        ThemeData(
          primaryColor: Colors.lightGreen,
          scaffoldBackgroundColor: Colors.teal,
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar:
            AppBar(
              title:
              Text(
                _title,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black45,
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.list, color: Colors.white,)),
                  Tab(icon: Icon(Icons.map_outlined, color: Colors.white))
                ],
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Route route = MaterialPageRoute(
                        builder: (context) => ConfigurationScreen());
                    Navigator.push(context, route).then(quandoVoltar);
                  },
                ),
              ],
            ),
            floatingActionButton:
            FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => AddProduct());
                Navigator.push(context, route).then(quandoVoltarAdicao);
              },
              tooltip: 'Increment Counter',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            body: TabBarView(
              children: [
                ProductListWidget(),
                ProductMap(getProductList()),
              ],
            ),
          ),
        ),
      );
    }
  }
}

