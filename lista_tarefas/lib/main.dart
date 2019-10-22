import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _taskList = [];

  final _newTaskController = TextEditingController();

  void _addTask() {
    setState(() {
      Map<String, dynamic> newTask = Map<String, dynamic>();
      newTask["title"] = _newTaskController.text;
      newTask["ok"] = false;

      _taskList.add(newTask);

      _newTaskController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                    controller: _newTaskController,
                  )),
                  RaisedButton(
                    color: Colors.blueAccent,
                    child: Text("Adicionar",
                        style: TextStyle(color: Colors.white)),
                    onPressed: _addTask,
                  )
                ],
              )),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _taskList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_taskList[index]["title"]),
                  value: _taskList[index]["ok"],
                  secondary: CircleAvatar(
                    child: Icon(
                        _taskList[index]["ok"] ? Icons.check : Icons.error),
                  ),
                  onChanged: (c) {
                    setState(() {
                      _taskList[index]["ok"] = c;
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveDate() async {
    String data = json.encode(_taskList);
    final File file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
