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
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _dolar;
  double _euro;

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
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                debugPrint(_dolar.toString());
                debugPrint(_euro.toString());

                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      Divider(),
                      buildTextField("Reais", "R\$"),
                      Divider(),
                      buildTextField("Dólares", "US\$"),
                      Divider(),
                      buildTextField("Euros", "€")
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

Widget buildTextField(String label, String prefix) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixStyle: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
        border: OutlineInputBorder(),
        prefixText: "$prefix "),
    style: TextStyle(color: Colors.white, fontSize: 25.0),
  );
}
