import 'dart:convert';

import 'package:album/photos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumsBody extends StatefulWidget {
  final String userId;
  final bool albumError;
  final bool photoError;

  AlbumsBody({this.userId, this.albumError, this.photoError});

  @override
  createState() => new AlbumsBodyState(userId, albumError, photoError);
}

class AlbumsBodyState extends State<AlbumsBody> {
  final String userId;
  final bool albumError;
  final bool photoError;

  AlbumsBodyState(this.userId, this.albumError, this.photoError);

  final myController = TextEditingController();

  List _arrayOfAlbums = [];

  List _filteredArrayOfAlbums = [];
  var jsonAlbum = [];

  var albumsData = [];

  Icon _searchIcon = new Icon(Icons.search);
  final TextEditingController _filter = new TextEditingController();
  Widget _appBarTitle = new Text( 'Albums' );

  getValues() async{
    var dataIsEmpty = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cachedJSON = (prefs.getString('albums') ?? {
      print(" Albums data is empty "),
      dataIsEmpty = true
    });
    if (!dataIsEmpty){
      albumsData.clear();
      jsonAlbum = json.decode(cachedJSON);
      for(var i = 0; i < jsonAlbum.length; i++) {
        if(jsonAlbum[i]["userId"].toString() == userId.toString()){
          albumsData.add(jsonAlbum[i]);
        }
      }
      setState(() {
        _arrayOfAlbums = albumsData;
        _filteredArrayOfAlbums = _arrayOfAlbums;
      });
    }
  }

  removeSpaces(String text) {
    var result = "";
    var prevChar = "";
    for (int i = 0; i < text.length; i++) {
      if(!(prevChar == " " && text[i] == ' ')){
        result += text[i];
        prevChar = text[i];
      }
    }
    return result.trim();
}

  searching(){
    setState(() {
        if (this._searchIcon.icon == Icons.search) {
          this._searchIcon = new Icon(Icons.close);
          this._appBarTitle = new TextField(
            controller: _filter,
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search),
                hintText: 'Search...',
            ),
            onChanged: (value){
                List tempList = new List();
                _filteredArrayOfAlbums = _arrayOfAlbums;
                for (int i = 0; i < _filteredArrayOfAlbums.length; i++) {
                  if (_filteredArrayOfAlbums[i]['title'].toLowerCase().contains(value.trim().toLowerCase())) {
                    tempList.add(_filteredArrayOfAlbums[i]);
                  }
                }
                setState(() {
                  _filteredArrayOfAlbums = tempList;
                });
            }
          );
        } else {
          this._searchIcon = new Icon(Icons.search);
          this._appBarTitle = new Text('Albums');
          _filteredArrayOfAlbums = _arrayOfAlbums;
          _filter.clear();
        }
    });

  }

  onChangeTitle(int index, String newTitle) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jsonAlbum[index]["title"] = newTitle;
    prefs.setString('albums', json.encode(jsonAlbum));
    getValues();
  }

  void _showChangeDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Новое название'),
            content: TextField(
              controller: myController,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  myController.text = "";
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
              FlatButton(
                onPressed: () {
                  onChangeTitle(index, myController.text);
                  myController.text = "";
                  Navigator.pop(context);
                },
                child: Text('Ok'),
              )
            ],
          );
        }
    );
  }

  onTapped(String id){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PhotosBody( albumId: id, photoError: photoError,
    )));
  }

  @override
  void initState() {
    //getAlbumData();
    getValues();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(title: _appBarTitle,
          actions: <Widget>[
            // action button
            IconButton(
              icon: _searchIcon,
              onPressed: () {
                searching();
              },
            ),
          ],),
        body:  Container (
            child:albumError ? Container(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Row(
                    children:[
                      Expanded(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text('Что-то пошло не так'),
                          ))])

            ) : _filteredArrayOfAlbums.length == 0 ? Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                  children:[
                    Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                          child: Text('Нет данных'),
                        ))])
              
            ) :
            Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded (
                    child: Container (
                      padding: EdgeInsets.only(top: 10),
                      // Если результаты поиска пустые говорим об этом, иначе строим список
                      child: ListView.builder(
                          itemCount: _arrayOfAlbums == null ? 0 : _filteredArrayOfAlbums.length,
                          itemBuilder: (context, i){
                            return new ListTile(
                              title: Container (
                                  color: Colors.white,
                                  child: Row(
                                      children:[
                                        Expanded(
                                            child: Container(
                                                child: Column (
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container (
                                                      padding: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArrayOfAlbums[i]["title"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container (
                                                      padding: EdgeInsets.fromLTRB(10, 2, 0, 10),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle.of(context).style,
                                                          children: <TextSpan>[
                                                            TextSpan(text: 'ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                            TextSpan(text: "${_filteredArrayOfAlbums[i]["id"]}"),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ))),
                                      ]
                                  )),
                              onTap: () =>  onTapped("${_filteredArrayOfAlbums[i]["id"]}"),
                              onLongPress: () =>  {
                                myController.text = "${_filteredArrayOfAlbums[i]["title"]}",
                                _showChangeDialog(i)
                              },);
                          }
                      ),
                    )
                ),
              ],
            ))
    );

  }
}
