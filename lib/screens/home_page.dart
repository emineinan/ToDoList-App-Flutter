import 'package:flutter/material.dart';
import 'package:to_do_list/models/notes.dart';
import 'package:to_do_list/utils/dbHelper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Notes> allNotes = new List<Notes>();
  bool isActive = false;
  var _controllerTitle = TextEditingController();
  var _controllerDesc = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  int clickedNoteID;

  void getNotes() async {
    var notesFuture = _databaseHelper.getAllNotes();
    await notesFuture.then((data) {
      setState(() {
        this.allNotes = data;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TO DO LIST"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  buildForm(_controllerTitle, "Title"),
                  buildForm(_controllerDesc, "Description"),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildButton("SAVE", Colors.purple[200], saveObject),
                buildButton("UPDATE", Colors.yellow[300], updateObject),
              ],
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: allNotes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _controllerTitle.text = allNotes[index].title;
                              _controllerDesc.text =
                                  allNotes[index].description;
                              clickedNoteID = allNotes[index].id;
                            });
                          },
                          title: Text(allNotes[index].title),
                          subtitle: Text(allNotes[index].description),
                          trailing: GestureDetector(
                            onTap: () {
                              _deleteNote(allNotes[index].id, index);
                            },
                            child: Icon(Icons.delete),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }

  buildForm(TextEditingController textEditingController, String str) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        autofocus: false,
        controller: textEditingController,
        decoration:
            InputDecoration(labelText: str, border: OutlineInputBorder()),
      ),
    );
  }

  buildButton(String str, Color buttonColor, Function eventFunc) {
    return RaisedButton(
      onPressed: eventFunc,
      child: Text(str),
      color: buttonColor,
    );
  }

  void updateObject() {
    if (clickedNoteID != null) {
      if (_formKey.currentState.validate()) {
        _updateNote(Notes.withId(
            clickedNoteID, _controllerTitle.text, _controllerDesc.text));
      } else {
        showAlertDialog();
      }
    }
  }

  void saveObject() {
    if (_formKey.currentState.validate()) {
      _addNote(Notes(_controllerTitle.text, _controllerDesc.text));
    }
  }

  //CRUD METHODS
  void _addNote(Notes note) async {
    await _databaseHelper.insert(note);

    setState(() {
      getNotes();
      _controllerTitle.text = "";
      _controllerDesc.text = "";
    });
  }

  void _updateNote(Notes note) async {
    await _databaseHelper.update(note);

    setState(() {
      getNotes();
      _controllerTitle.text = "";
      _controllerDesc.text = "";
      clickedNoteID = null;
    });
  }

  void _deleteNote(int deletedID, int deletedIndex) async {
    await _databaseHelper.delete(deletedID);
    setState(() {
      getNotes();
    });
  }

  void showAlertDialog() {
    AlertDialog alertDialog = AlertDialog(
      title: Text("There is no selected note!"),
      content: Text("Please enter a note to list for updating list."),
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}
