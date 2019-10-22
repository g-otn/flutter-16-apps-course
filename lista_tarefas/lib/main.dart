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
  final _newTaskController = TextEditingController();

  List _taskList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedIndex;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _taskList = json.decode(data);
      });
    });
  }

  void _addTask() {
    setState(() {
      Map<String, dynamic> newTask = Map<String, dynamic>();
      newTask["title"] = _newTaskController.text;
      newTask["ok"] = false;

      _taskList.insert(0, newTask);
      _saveData();

      _newTaskController.text = "";
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _taskList.sort((a, b) {
        if (a["ok"] && !b["ok"]) return 1;
        else if (!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveData();
    });

    return null;
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
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _taskList.length,
                  itemBuilder: _buildItem),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.875, 0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_taskList[index]["title"]),
        value: _taskList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_taskList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _taskList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_taskList[index]);
          _lastRemovedIndex = index;
          _taskList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    print(_lastRemovedIndex);
                    _taskList.insert(_lastRemovedIndex, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
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
