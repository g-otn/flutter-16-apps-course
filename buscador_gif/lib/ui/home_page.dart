import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    const String API_URL = "https://api.giphy.com/v1";
    const String API_KEY = "QbyzNQRGH9L61agYIWyKTFA20lsw5gtd";

    if (_search == null || _search == "")
      response = await http.get("$API_URL/gifs/trending?api_key=$API_KEY&limit=20&rating=G");
    else
      response = await http.get("$API_URL/gifs/search?api_key=$API_KEY&limit=20&rating=G&q=$_search&lang=pt");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                    break;
                  default:
                    return snapshot.hasError ? Container() : _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
        itemCount: snapshot.data["data"].length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Image.network(snapshot.data["data"][index]["images"]["fixed_height_small"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                return Container(
                  width: 300.0,
                  height: 300.0,
                  alignment: Alignment.center,
                  child: () {
                    if (loadingProgress != null)
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 15.0,
                        value: loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes,
                      );
                    else
                      return child;
                  }()
                );
              },
            ),
          );
        }
    );
  }
}
