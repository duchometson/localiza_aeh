import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'texthelper.dart';
import 'producttype.dart';
import 'main.dart';
import 'productmap.dart';
import 'request.dart';

List<Product> _products = [];

class Product {
  String nome = "";
  String codigo = "";
  IconData icone = Icons.apps_sharp;
  String localizacao = "";
  double lat;
  double long;
  DateTime horarioAdd = DateTime.now();
  var posNoVetor = 0;
  Key key;
  List<AtualizacaoDeProdutoCard> listaAtualizacoes = new List<AtualizacaoDeProdutoCard>();
  bool atualizado = false;


  Product( String nome, String codigo, IconData icone ) {
    this.nome = nome;
    this.codigo = codigo;
    this.icone = icone;
    this.horarioAdd =  DateTime.now();
    this.key = Key(nome);
    // Localizacao a ser atualizada a cada vez que request for feito
    // No momento marretado para acertar o layout


  }


  Product.fromProduct( Product product ) {
    this.nome = product.getNome();
    this.codigo = product.getCodigo();
    this.icone = product.getIcone();
    this.horarioAdd = product.getHorarioAdd();
    setListaAtualizacoes(product.getListaAtualizacoes());
    this.localizacao = product.getLocalizacao();
    this.lat = product.lat;
    this.long = product.long;
  }

  getNome() {
    return this.nome;
  }

  getCodigo() {
    return this.codigo;
  }

  getIcone() {
    return this.icone;
  }

  getHorarioAdd() {
    return this.horarioAdd;
  }

  setPosNoVetor( int pos ) {
    this.posNoVetor = pos;
  }

  getLocalizacao() {
    return this.localizacao;
  }

  setLocalizacao( String  local ) {
    this.localizacao = local;
  }

  getListaAtualizacoes() {
    return this.listaAtualizacoes;
  }

  setListaAtualizacoes(List<AtualizacaoDeProdutoCard> lA ) {
    this.listaAtualizacoes = new List<AtualizacaoDeProdutoCard>();
    this.listaAtualizacoes.addAll(lA);
  }

  Future updateAtualizacoes() async {
    RequestToCorreio request = RequestToCorreio(this.codigo);
    List lA = await request.getData();
    this.listaAtualizacoes = new List<AtualizacaoDeProdutoCard>();
    var i = 0;
    for (var atualizacao in lA) {
      DateTime dt = DateTime(
        int.parse(atualizacao['data'].toString().split("/")[2]),
        int.parse(atualizacao['data'].toString().split("/")[1]),
        int.parse(atualizacao['data'].toString().split("/")[0]),
        int.parse(atualizacao['hora'].toString().split(":")[0]),
        int.parse(atualizacao['hora'].toString().split(":")[1]),
      );
      this.listaAtualizacoes.add(AtualizacaoDeProdutoCard(dt,atualizacao['local'].toString(),atualizacao['mensagem'].toString(),this));

      if (i == 0) {
        this.localizacao = atualizacao['local'];
        this.lat = atualizacao['lat'];
        this.long = atualizacao['lng']; // Longitude
        i = i + 1;
      }
    }
    this.atualizado = true;
  }
}

class ProductCard extends StatefulWidget {

  Product product;
  ProductCard(Product p ) {
    this.product = Product.fromProduct(p);
  }

  @override
  _ProductCardState createState() => _ProductCardState(this.product);
}

class _ProductCardState extends State<ProductCard> {
  Offset _posicaoDeToque;
  Product product;

  _ProductCardState(Product p ) {
    this.product = Product.fromProduct(p);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor ,
      child: GestureDetector(
        onTapDown: (details) {
          _posicaoDeToque = details.globalPosition;
        },
        onLongPress: () async {
          final RenderBox overlay = Overlay.of(context).context.findRenderObject();
          var selected = await showMenu(
              context: context,
              position: RelativeRect.fromRect(
                  _posicaoDeToque & Size(40, 40),
                  Offset.zero & overlay.size
              ),              items: <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child:  Row(children: [ Icon(Icons.delete), Text('Deletar')]),
              value: 1,
            ),
          ]);
          print("Selected: "  + selected.toString());
          if( selected == 1 ) { // Deletar
            removeProduct(this.widget.product);
            Navigator.push(context , MaterialPageRoute(builder: (context) => MyApp()),);
          }
        },
        onTap: () {
          print('Card tapped.');
          Navigator.push(context , MaterialPageRoute(builder: (context) => SingleProductScreen(this.widget.product)),);
        },
        child: SizedBox(
          width: 300,
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child:
                  Icon(
                      this.widget.product.icone,
                      size:40
                  ),
                ),
                Expanded(
                    child: TextPadrao(this.widget.product.nome,25)
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        this.widget.product.listaAtualizacoes.isEmpty ? "CodigoInvalido" : this.widget.product.localizacao,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductListWidget extends StatefulWidget {
  @override
  State<ProductListWidget> createState() {
    return ProductList();
  }
}

List<Product> getProductList() {
  return _products;
}

void addProduct( Product p ) {
  p.updateAtualizacoes();
  _products.add(p);
  _products.last.setPosNoVetor(_products.length-1);
  print(_products);
}

void removeProduct( Product p ) {
  for( int i = 0; i < _products.length; i++ ) {
    if( _products[i].getHorarioAdd() == p.getHorarioAdd() ) {
      _products.removeAt(i);
      return;
    }
  }
}

bool todosProdutosAtualizados() {
  for( int i = 0; i < _products.length; i++ ) {
    if( !_products[i].atualizado ) {
      return false;
    }
  }
  return true;
}

class ProductList extends State<ProductListWidget> {
  bool reload = false;

  @override
  Widget build(BuildContext context) {
    // if( !todosProdutosAtualizados() ) {
    //   print("loading");
    //   return Center( child: Icon(Icons.download_outlined));
    // } else {
      return Center(
        child: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return ProductCard(_products[index]);
          },
        ),
      );
    }
  // }
}
// // Metodo temporario para receber as atualizacoes em json dos correios
// List<AtualizacaoDeProdutoCard> getAtualizacoes( Product product ) {
//   List<AtualizacaoDeProdutoCard> listaAtualizacoesProduto = new List<AtualizacaoDeProdutoCard>();
//
//
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,15,13,24), "CTE PORTO ALEGRE", "Postado", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,20,12,33), "CTE PORTO ALEGRE", "Saiu para entrega", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,22,11,23), "CTE PORTO ALEGRE", "Entrega Não Efetuada", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,23,13,32), "CTE PORTO ALEGRE", "Saiu para entrega", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,23,15,12), "CTE PORTO ALEGRE", "Entregue", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,15,13,24), "CTE PORTO ALEGRE", "Postado", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,20,12,33), "CTE PORTO ALEGRE", "Saiu para entrega", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,22,11,23), "CTE PORTO ALEGRE", "Entrega Não Efetuada", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,23,13,32), "CTE PORTO ALEGRE", "Saiu para entrega", product));
//   listaAtualizacoesProduto.add(AtualizacaoDeProdutoCard(DateTime(2021,4,23,15,12), "CTE PORTO ALEGRE", "Entregue", product));
//
//   return listaAtualizacoesProduto;
// }

// ignore: must_be_immutable
class SingleProductScreen extends StatelessWidget {
  Product product;

  SingleProductScreen( Product prd ) {
    this.product = Product.fromProduct(prd);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: this.product.getNome(),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.teal,
          appBar: AppBar(
            backgroundColor: Colors.black45,
            title: Text(this.product.getNome()),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(icon : Icon(this.product.getIcone())),
                Tab(icon : Icon(Icons.map_outlined))
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children:[ Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child:
                        SizedBox(
                          width: 500,
                          height: 120,
                          child:
                          Padding(
                            padding: EdgeInsets.all(15),
                            child:
                            Row(
                              children:[
                                Column(
                                  children: [
                                    Expanded(
                                        child:
                                        Icon(
                                          this.product.icone,
                                          size:40,)
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextPadrao("Codigo: ",15),
                                      TextPadrao("Localização Atual: ",15),
                                      TextPadrao("Adicionado em:",15),
                                      TextPadrao("Chega em:",15),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    TextPadrao(this.product.getCodigo(),15),
                                    TextPadrao(this.product.getLocalizacao(),15),
                                    TextPadrao( DateFormat('  yyyy-MM-dd – kk:mm').format(this.product.getHorarioAdd()),15),
                                    TextPadrao("3 dias",15),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  Expanded(child: ListaDeAtualizacoesDeProdutoWidget(this.product)),
                ],
              ),
              ProductMap([this.product]),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaDeAtualizacoesDeProdutoWidget extends StatefulWidget {
  Product product;
  ListaDeAtualizacoesDeProdutoWidget(Product p) {
    this.product = Product.fromProduct(p);
  }

  @override
  State<ListaDeAtualizacoesDeProdutoWidget> createState() {
    return ListaDeAtualizacoesDeProduto(this.product);
  }
}


class ListaDeAtualizacoesDeProduto extends State<ListaDeAtualizacoesDeProdutoWidget> {
  Product product;

  ListaDeAtualizacoesDeProduto(Product p) {
    this.product = Product.fromProduct(p);
  }

  void initState() {
    super.initState();
    this.product.updateAtualizacoes().then((value) {
      setState() {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child:
        ListView.builder(
          itemCount: this.product.getListaAtualizacoes().length,
          itemBuilder: (context, index) {
            return this.product.getListaAtualizacoes()[index];
          },
        ),
      );
  }
}


// ignore: must_be_immutable
class AtualizacaoDeProdutoCard extends StatelessWidget {

  DateTime data;
  String local = "";
  String situacao = "";
  Product product;

  AtualizacaoDeProdutoCard( DateTime dt, String lcl, String situ, Product p) {
    this.data = dt;
    this.local = lcl;
    this.situacao = situ;
    this.product = Product.fromProduct(p);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blueGrey,
            child:
            SizedBox(
              width: 500,
              height: 100,
              child:
              Padding(
                padding: EdgeInsets.all(15),
                child:
                Column(
                  children: [
                    Row(
                      children:
                      [
                        Expanded(
                          child: TextPadrao(DateFormat('  yyyy-MM-dd – kk:mm').format(this.data),15),
                        ),
                        Expanded(
                          child: TextPadrao(this.local,15),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(child: TextPadrao(this.situacao,15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() {
    return _MyAddProductState();
  }
}

class _MyAddProductState extends State<AddProduct> {
  String nomeAux;
  String codAux;
  String prodAux;
  IconData iconAux;

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title: Text('Adicionar Produto'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: ( nome ) async {
                nomeAux = nome;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome',
              ),
            ),
            TextField(
              onChanged: ( nome ) async {
                codAux = nome;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Codigo',
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Tipo do Produto:",
                    style: TextStyle(
                        fontSize: 17
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: prodAux,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      prodAux = newValue;
                      iconAux = TipoProdutos().getMap()[newValue];
                    });
                  },
                  items: TipoProdutos().getMap()
                      .map((description, value) {
                    return MapEntry(
                        description,
                        DropdownMenuItem<String>(
                          value: description,
                          child: Text(description),
                        ));
                  })
                      .values
                      .toList(),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: RaisedButton(
                color: Colors.orangeAccent,
                onPressed: () {
                  Product p = Product(nomeAux, codAux, iconAux);
                  p.updateAtualizacoes();
                  setState(() {
                    addProduct(p);
                  });
                  Navigator.pop(context);//push(context , MaterialPageRoute(builder: (context) => MyApp()),);
                },
                child: Text(
                  'Adicionar',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
    );
  }
}

class ConfigurationScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Configuração",
      home: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title: Text("Configuração"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body:
        Column(
          children: [
            Container(
              color: Colors.lightGreen,
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: TextPadrao("Reordenar Produtos",15),
            ),
            Expanded(child: RearangeProduct(), ),
          ],
        ),
      ),
    );
  }
}

class RearangeProduct extends StatefulWidget {
  @override
  State<RearangeProduct> createState() {
    return RearangeProductWidget();
  }

}
class RearangeProductWidget extends State<RearangeProduct> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      children: <Widget> [
        for( int index = 0; index < _products.length; index++)
          ListTile(
            tileColor: index % 2 == 0 ? Colors.blueGrey.withOpacity(0.75) : Colors.blueGrey,
            key: _products[index].key,
            title: Row( children: [ Expanded(child: Text(_products[index].getNome()) ), Expanded( child: Icon(Icons.view_headline_sharp) )]),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Product item = _products.removeAt(oldIndex);
          _products.insert(newIndex, item);
        });
      },
    );
  }
}


