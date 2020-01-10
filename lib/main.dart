import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

var dolar = _moeda("USD");
var euro  = _moeda("EUR");
var real  = _moeda("BRL");

String _moeda(String iso){
  return "http://www.rate-exchange-1.appspot.com/currency?from=${iso.toUpperCase()}&to=AOA";
}

void main() async{
  runApp(
      MaterialApp(
          title: "Conversor de Moedas",
          home: Home(),
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
            ),
            hintColor: Colors.amber,
            primaryColor: Colors.white
          ),
      )
  );
}
Future<Map> getData() async{
  var nome  = ["dolar", "euro", "real"];
  var lista = [dolar, euro, real];
  Map<String, double> dados = {};
  for(int i = 0; i < lista.length; i++){
    http.Response res = await http.get(lista[i]);
    dados[nome[i]] = json.decode(res.body)["rate"];
  }
  return dados;
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  final kwanzaController = TextEditingController();
  final dolarController  = TextEditingController();
  final euroController   = TextEditingController();
  final reaisController  = TextEditingController();

  Map<String, double> _dados;

  void _mudaKwanza(String texto){
    texto = texto.replaceAll(",", ".");
    double kz = double.parse(texto);
    dolarController.text = (kz/_dados["dolar"]).toStringAsFixed(2);
    euroController.text = (kz/_dados["euro"]).toStringAsFixed(2);
    reaisController.text = (kz/_dados["real"]).toStringAsFixed(2);
  }
  void _mudaDolar(String texto){
    texto = texto.replaceAll(",", ".");
    double _dolar = double.parse(texto);
    kwanzaController.text = (_dolar*_dados["dolar"]).toStringAsFixed(2);
    euroController.text = ((_dolar*_dados["dolar"])/_dados["euro"]).toStringAsFixed(2);
    reaisController.text = ((_dolar*_dados["dolar"])/_dados["real"]).toStringAsFixed(2);
  }
  void _mudaEuro(String texto){
    texto = texto.replaceAll(",", ".");
    double _euro = double.parse(texto);
    kwanzaController.text = (_euro*_dados["euro"]).toStringAsFixed(2);
    reaisController.text = ((_euro*_dados["euro"])/_dados["real"]).toStringAsFixed(2);
    dolarController.text = ((_euro*_dados["euro"])/_dados["dolar"]).toStringAsFixed(2);
  }
  void _mudaReais(String texto){
    texto = texto.replaceAll(",", ".");
    double _real = double.parse(texto);
    kwanzaController.text = (_real*_dados["real"]).toStringAsFixed(2);
    dolarController.text = ((_real*_dados["real"])/_dados["dolar"]).toStringAsFixed(2);
    euroController.text = ((_real*_dados["real"])/_dados["euro"]).toStringAsFixed(2);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child:Icon(Icons.refresh, size:25.0),
            onPressed: (){
              kwanzaController.text = "";
              dolarController.text = "";
              euroController.text = "";
              reaisController.text = "";
            },
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (contexto, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados!", style: TextStyle(color: Colors.amber, fontSize: 25.0), textAlign: TextAlign.center,)
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString(), style: TextStyle(color: Colors.amber, fontSize: 25.0), textAlign: TextAlign.center,)
                );
              }else{
                _dados = snapshot.data;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                      caixaTexto("KZ", "Kwanza", kwanzaController, _mudaKwanza),
                      caixaTexto("\$", "Dolar", dolarController, _mudaDolar),
                      caixaTexto("€", "Euro", euroController, _mudaEuro),
                      caixaTexto("R\$", "Reais", reaisController, _mudaReais)
                    ],
                  )
                );
              }
          }
        }
      )
    );
  }
}
Widget caixaTexto(String prefixo, String moeda, TextEditingController tec, Function func){
  return Padding(
    padding: EdgeInsets.all(5.0),
    child: TextField(
      controller: tec,
      decoration: InputDecoration(prefixText: prefixo, border: OutlineInputBorder(), labelText: moeda,
          labelStyle: TextStyle(color: Colors.amber)),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: func,
      keyboardType: TextInputType.number,
    )
  );
}