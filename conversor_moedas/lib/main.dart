import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  try {
    return json.decode(response.body);
  } catch (ex) {
    throw "error: " + ex.toString() + "\n\nresponse body:\n" + response.body;
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _realController = TextEditingController();
  final _dolarController = TextEditingController();
  final _euroController = TextEditingController();
  final _poundSterlingController = TextEditingController();
  final _argentinePesoController = TextEditingController();
  final _bitcoinController = TextEditingController();

  double _dolar;
  double _euro;
  double _poundSterling;
  double _argentinePeso;
  double _bitcoin;

  void _realChanged(String text) {
    double real = double.parse(text);
    _dolarController.text = (real / _dolar).toStringAsFixed(2);
    _euroController.text = (real / _euro).toStringAsFixed(2);
    _poundSterlingController.text = (real / _poundSterling).toStringAsFixed(2);
    _argentinePesoController.text = (real / _argentinePeso).toStringAsFixed(2);
    _bitcoinController.text = (real / _bitcoin).toStringAsFixed(6);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    double dolarInReais = dolar * this._dolar;
    _realController.text = dolarInReais.toStringAsFixed(2);
    _euroController.text = (dolarInReais / _euro).toStringAsFixed(2);
    _poundSterlingController.text = (dolarInReais / _poundSterling).toStringAsFixed(2);
    _argentinePesoController.text = (dolarInReais / _argentinePeso).toStringAsFixed(2);
    _bitcoinController.text = (dolarInReais / _bitcoin).toStringAsFixed(6);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    double euroInReais = euro * this._euro;
    _realController.text = euroInReais.toStringAsFixed(2);
    _dolarController.text = (euroInReais / _dolar).toStringAsFixed(2);
    _poundSterlingController.text = (euroInReais / _poundSterling).toStringAsFixed(2);
    _argentinePesoController.text = (euroInReais / _argentinePeso).toStringAsFixed(2);
    _bitcoinController.text = (euroInReais / _bitcoin).toStringAsFixed(6);
  }

  void _poundSterlingChanged(String text) {
    double pound = double.parse(text);
    double poundInReais = pound * this._poundSterling;
    _realController.text = poundInReais.toStringAsFixed(2);
    _dolarController.text = (poundInReais / _dolar).toStringAsFixed(2);
    _euroController.text = (poundInReais / _euro).toStringAsFixed(2);
    _argentinePesoController.text = (poundInReais / _argentinePeso).toStringAsFixed(2);
    _bitcoinController.text = (poundInReais / _bitcoin).toStringAsFixed(6);
  }

  void _argentinePesoChanged(String text) {
    double peso = double.parse(text);
    double pesoInReais = peso * this._argentinePeso;
    _realController.text = pesoInReais.toStringAsFixed(2);
    _dolarController.text = (pesoInReais / _dolar).toStringAsFixed(2);
    _euroController.text = (pesoInReais / _euro).toStringAsFixed(2);
    _poundSterlingController.text = (pesoInReais / _poundSterling).toStringAsFixed(2);
    _bitcoinController.text = (pesoInReais / _bitcoin).toStringAsFixed(6);
  }

  void _bitcoinChanged(String text) {
    double btc = double.parse(text);
    double btcInReais = btc * this._bitcoin;
    _realController.text = btcInReais.toStringAsFixed(2);
    _dolarController.text = (btcInReais / _dolar).toStringAsFixed(2);
    _euroController.text = (btcInReais / _euro).toStringAsFixed(2);
    _poundSterlingController.text = (btcInReais / _poundSterling).toStringAsFixed(2);
    _argentinePesoController.text = (btcInReais / _argentinePeso).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Color.fromRGBO(20, 20, 20, 1),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando dados",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0)));
            default:
              if (snapshot.hasError) {
                return SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            "Erro ao Carregar Dados :(",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 25.0),
                            textAlign: TextAlign.center,
                          ),
                          Divider(),
                          Text(
                            snapshot.error.toString() + "\n\n",
                            style: TextStyle(color: Colors.redAccent),
                          )
                        ]));
              } else {
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                _poundSterling = snapshot.data["results"]["currencies"]["GBP"]["buy"];
                _argentinePeso = snapshot.data["results"]["currencies"]["ARS"]["buy"];
                _bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      Divider(),
                      buildTextField(
                          "Reais", "R\$", _realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$", _dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€ ", _euroController, _euroChanged),
                      Divider(),
                      buildTextField(
                          "Libras Esterlinas", "£ ", _poundSterlingController, _poundSterlingChanged),
                      Divider(),
                      buildTextField(
                          "Pesos Argentinos", "\$ ", _argentinePesoController, _argentinePesoChanged),
                      Divider(),
                      buildTextField(
                          "Bitcoin", "₿ ", _bitcoinController, _bitcoinChanged),
                      Divider()
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixStyle: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
        border: OutlineInputBorder(),
        prefixText: "$prefix "),
    style: TextStyle(color: Colors.white, fontSize: 25.0),
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
